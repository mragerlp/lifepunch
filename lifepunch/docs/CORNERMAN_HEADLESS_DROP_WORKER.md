# Cornerman headless drop worker — runbook (Slice 2: opt-in model call)

**Status:** Slice 2 shipped — dry-run by default; opt-in local model call + real report generation
**Node:** Green (Cornerman) · testable anywhere with `-BaseDir` scratch dirs
**Authoritative design:** `lifepunch/docs/handoff/CORNERMAN_HEADLESS_DROP_WORKER_OPUS_V2_PLAN_2026-07-06.md` (Part B supersedes Part A) · `lifepunch/docs/handoff/CORNERMAN_DROP_WORKER_SLICE2_MODEL_CALL_PLAN_2026-07-06.md`
**Read with:** `CORNERMAN_DROP_WORKFLOW.md` · `GREEN_EXECUTION_MODEL.md` · `BRANCH_MODEL.md` · `WORKTREE_LANE_SAFETY.md`

---

## What the worker is (and is not)

The worker picks up **one** `task-*.json` packet from the Cornerman inbox, validates it
against **task schema v2**, verifies the target repo clone's identity and cleanliness,
enforces lane/branch/input/output law, runs the **no-IP / AI-trailer scan** for
`dxrp-official` tasks, and then either writes a **dry-run validation report** (default)
or — with the Slice 2 **double opt-in** — calls the **local LM Studio endpoint** and
writes a real generated report.

| The worker DOES | The worker does NOT |
|---|---|
| Validate schema v2 packets | Install a scheduler / Task Scheduler task |
| Resolve `repoProfile` via registry | Create or apply patches |
| Verify clone path + git remotes | Commit, push, or open PRs |
| Dirty-tree gate (untracked = dirty) | Claim runtime/editor proof |
| Focus/profile + branch-law checks | Mutate git in any way (no fetch/checkout/pull) |
| Input path safety + glob expansion | Ship a Red drop helper |
| Output-type gate + forbidden-scope gate | Loosen constraints from packet content |
| No-IP / AI-trailer scan (dxrp-official), pre **and** post model call | Make any network request beyond localhost |
| Opt-in local model call (LM Studio `:1234`) + real report | Fall back to a different/cloud model |
| Report + `meta.json` + ack + history move | |

Future slices (scheduler, Red drop helper, candidate-patch mode) each require a
separate Bloodwave GO. `mode: candidate-patch` packets are **rejected**.

---

## Model call — double opt-in (Slice 2)

**Default behavior is dry-run, permanently.** A model call happens only when **both**
sides opt in:

1. **Operator:** the worker is started with the `-EnableModelCall` switch.
2. **Packet:** the packet carries `"modelCall": { "enabled": true }`.

| `-EnableModelCall` | `modelCall.enabled` | `constraints.noModelCall` | Result |
|---|---|---|---|
| no  | absent / false | any          | dry-run (zero HTTP) |
| no  | true           | any          | **fail closed** — `model-call-requested-but-worker-not-enabled` (zero HTTP) |
| yes | absent / false | any          | dry-run (zero HTTP) |
| yes | true           | true         | **fail closed** — packet self-contradiction (zero HTTP) |
| yes | true           | false/absent | model call — only after **every** pre-HTTP gate passes |

- Legacy Slice 1 packets (no `modelCall` object) always dry-run — a model call can
  never happen by accident.
- `meta.json` records `workerModelCallEnabled` + `packetModelCallRequested` so every
  artifact explains why the model was or was not called.

### Packet field

```json
"modelCall": {
  "enabled": false,
  "requiredModel": null,
  "allowFallback": false
}
```

- `requiredModel` — optional exact model id; must agree with the routeTag's configured
  model (`model-route-conflict` otherwise) and be loaded at the endpoint.
- `allowFallback` — reserved; **ignored in Slice 2** (warning only). A missing model
  always fails closed as `model-unavailable`. No silent substitution, ever.

### Endpoint + routing (`config\model-endpoints.json`)

- Probe: `http://127.0.0.1:1234/v1/models` · Call: `http://127.0.0.1:1234/v1/chat/completions`
- **Localhost only, enforced in code** — a non-`127.0.0.1`/`localhost` URL fails closed.
- routeTag → model id via the config `routes` map:
  `GREEN DEEP REQUIRED` → deep/distill model (first live: `qwen/qwen3.6-35b-a3b`),
  `GREEN CODE REQUIRED` → coder model (`qwen2.5-coder-32b-instruct`).
  `AUTO OK` is **rejected** for model runs (belongs on Red).
- Request tuning (temperature, maxTokens, maxPromptChars context ceiling) lives in the
  config `request` object. Over-ceiling inputs fail closed — **no silent truncation**.
- Deploy the live copy from `lifepunch/docs/schemas/cornerman-model-endpoints.example.json`
  to `C:\lifepunch\cornerman\config\model-endpoints.json`.

### Pre-HTTP hard gates

**No HTTP request — not even the `/v1/models` probe — happens until ALL of these
pass:** JSON parse · schema (incl. `modelCall` shape + `deliverable.format`) ·
repoProfile/registry · clone exists · remotes match · dirty-tree · focus/profile ·
branch law · input path safety · glob expansion + combined maxBytes + context cap ·
forbiddenScope · output types · routeTag/model route · localhost-only endpoint ·
modelCall opt-in policy · dxrp-official pre-call scan (instruction, contextNotes,
readFiles content, expanded readGlobs content). Any failure: `error.md` + failed
`meta.json` (+ `failureStage`) + failed ack + history `.fail.json` + lock released —
zero HTTP.

### Format-aware output validation

Dispatch on `deliverable.format` (unsupported values fail at schema, before any HTTP):

- `markdown` — non-empty + scan pass; `expectedSections` matched best-effort — missing
  sections are **warnings** (`missingExpectedSections` in meta), all-missing fails as
  `model-invalid`.
- `json` — full body must parse as JSON after stripping one optional outer code fence;
  written as `report.json`. Never rejected for lacking markdown headings.
- `text` — non-empty text; written as `report.txt`.

### Failure stages (model runs)

`model-call-requested-but-worker-not-enabled` · `packet-self-contradiction` ·
`model-route-conflict` · `endpoint-not-localhost` · `endpoint-down` ·
`model-unavailable` · `model-timeout` · `model-empty` · `model-invalid` ·
`output-scan-blocked` — each recorded as `failureStage` in `meta.json`. On
`output-scan-blocked` the generated text is discarded and never written anywhere
(including logs); only the blocked token names are recorded.

Startup guard: `-StaleLockMinutes` (default 30) must exceed the configured
`callTimeoutSec` (default 300s) or the run fails closed before HTTP.

---

## Files

| File | Purpose |
|---|---|
| `lifepunch/scripts/cornerman/Invoke-CornermanDropWorker.ps1` | Orchestrator (one packet per run) |
| `lifepunch/scripts/cornerman/CornermanDropWorker.Lib.ps1` | Shared validation/scan/lock/IO/model functions |
| `lifepunch/docs/schemas/cornerman-task-packet.schema.json` | Task packet schema v2 (JSON Schema draft-07) |
| `lifepunch/docs/schemas/cornerman-task-packet.example.json` | Valid example packet (`lifepunch-private`) |
| `lifepunch/docs/schemas/cornerman-repo-profiles.example.json` | Repo-profile registry template |
| `lifepunch/docs/schemas/cornerman-model-endpoints.example.json` | Model endpoint/routing config template (Slice 2) |

## Green paths (live deployment)

| Path | Purpose |
|---|---|
| `C:\lifepunch\cornerman\inbox\` | `task-*.json` packets dropped by Red |
| `C:\lifepunch\cornerman\outbox\<task-id>\` | `report.md` or `error.md` + `meta.json` |
| `C:\lifepunch\cornerman\outbox\workflow-ack.ndjson` | Ack log (one JSON line per run) |
| `C:\lifepunch\cornerman\history\` | Processed packets (`<id>.ok.json` / `<id>.fail.json`) |
| `C:\lifepunch\cornerman\logs\` | Daily worker logs |
| `C:\lifepunch\cornerman\lock\worker.lock` | Single-run lock |
| `C:\lifepunch\cornerman\config\repo-profiles.json` | Live profile registry (deploy from the example) |

---

## Repo profiles

`repoProfile` is **required** on every packet. Allowed values only:

### `lifepunch-private`

- Green clone: `C:\Projects\lifepunch` · origin `mragerlp/lifepunch`
- Branch law: `main` for clean truth/export/stability (Green default);
  `develop` only when the packet explicitly targets active work.

### `dxrp-official`

- Green clone: `C:\Projects\dxrp-public` · origin `mragerlp/dxrp-public` · upstream `dxura/dxrp`
- Base is always `upstream/develop`; reviewing an existing PR branch requires an
  explicit `reviewBranch` in the packet.
- No LifePunch headers/IP/paths/private assumptions. No commits/pushes/PR opening.
  No portal/permission backend work unless maintainer-approved.
- Inputs under `lifepunch/`, `lifepunchaddons/`, `lifepunchdxrp/` are **rejected**.

### Fail-closed conditions

The worker writes `error.md` + failed `meta.json`, acks failure, and moves the packet
to history as `fail` when any of these hold:

- `repoProfile` missing or unknown (not in registry)
- Green clone path missing / not a git repo
- git remotes do not match the registry's `expectedRemotes`
- resolved clone is dirty (**untracked files count as dirty in v1**)
- `focus` does not agree with `repoProfile` (`LifePunch` ↔ `lifepunch-private`, `DXRP` ↔ `dxrp-official`)
- `baseRemote`/`baseBranch` violates profile branch law
- input path is absolute, contains `..`, or (dxrp-official) references `lifepunch/**`
- task text touches a `forbiddenScope` token
- `mode: candidate-patch` (not available in Slice 1)
- no-IP / AI-trailer scan hit (dxrp-official)

---

## No-IP / AI-trailer scan (dxrp-official only)

Run **before** any dxrp-official artifact is written, on:

1. the candidate/generated report text — for model runs this means the **raw model
   output, post-call, before any write** (`output-scan-blocked` on a hit)
2. the packet instruction
3. context notes (`inputs.contextNotes`)
4. **cited input file contents** — every file listed in `inputs.readFiles` **and every
   file matched by `inputs.readGlobs`** (globs are expanded since Slice 2) is loaded
   from the resolved clone and scanned. Only files the packet explicitly cites are
   read — the worker never scans the whole repo.

On any hit: no normal report, `error.md` + failed `meta.json` (with the blocked token
and offending file path for cited-input hits), failed ack, packet moved to history as
failed. `meta.json` records `scannedInputFiles` (list), `inputContentScan`
(`pass` / `fail` / `not-run` / `not-applicable`) and `outputScan`
(`pass` / `fail` / `not-applicable`).

**Allowed public identifiers** (never blocked): `mragerlp/dxrp-public`,
`github.com/mragerlp/dxrp-public`, `mragerlp-party-*` branch names,
`mragerlp <mragerlp@gmail.com>`, `dxura/dxrp`, `upstream/develop`, issue/PR refs like `#111`.
**`mragerlp` by itself is never blocked** — it is the public fork owner / commit author identity.

**Blocked private identifiers:** `LIFEPUNCH™`, `LIFEPUNCH`, `LifePunch`, `lifepunch.co`,
`C:\Users\jared\Projects\lifepunch`, `C:\Projects\lifepunch`, `lifepunch/`,
`lifepunchaddons/`, `lifepunchdxrp/`, `PROPRIETARY`, `PRIVATE LIFEPUNCH`, `LIFEPUNCH PRIVATE`.

**Blocked AI attribution trailers:** `Co-authored-by: Cursor|Claude|Copilot|AI|agent`,
`cursoragent@cursor.com`, `Generated-by:`, `Assisted-by:`, `AI-authored-by:`.

---

## Locking / dirty tree

- Lock file: `<BaseDir>\lock\worker.lock` — atomic exclusive create; one worker run at a time.
- Stale locks (dead pid, or older than `-StaleLockMinutes`, default 30) are reclaimed with a log note.
- Lock released in `finally` — always, including on failure.
- Dirty-tree check runs **before** any output can be marked success. The worker never
  runs `git reset` / `clean` / `stash` / `restore` — a dirty clone is a human problem.

---

## Running it

```powershell
# Live (Green) — dry-run only (default; never performs HTTP):
powershell -NoProfile -File C:\Projects\lifepunch\lifepunch\scripts\cornerman\Invoke-CornermanDropWorker.ps1

# Live (Green) — model calls unlocked for packets that opt in:
powershell -NoProfile -File C:\Projects\lifepunch\lifepunch\scripts\cornerman\Invoke-CornermanDropWorker.ps1 -EnableModelCall

# Scratch test (any node) — isolated BaseDir + registry + model config:
powershell -NoProfile -File Invoke-CornermanDropWorker.ps1 `
    -BaseDir C:\tmp\cdw-test `
    -RegistryPath C:\tmp\cdw-test\repo-profiles.json `
    -ModelConfigPath C:\tmp\cdw-test\model-endpoints.json
```

Exit behavior: `IDLE` (empty inbox), `SKIP` (lock held), `OK` (dry-run pass or model
report generated), `FAIL` (validation/model failure — details in `error.md`).

First-time Green setup: copy `cornerman-repo-profiles.example.json` to
`C:\lifepunch\cornerman\config\repo-profiles.json` and
`cornerman-model-endpoints.example.json` to
`C:\lifepunch\cornerman\config\model-endpoints.json` (paths already match Green).

---

## Task schema v2 — lifecycle contract

The schema models the full lifecycle (idea → brief → agent → proof → review → commit/PR)
even though Slice 1 only validates/reports. Highlights:

- **identity:** `id`, `title`, `type`, `createdBy`, `createdTs`, `owner`
- **routing:** `repoProfile`, `repoPath`, `baseRemote`, `baseBranch`, `reviewBranch`, `routeTag`, `focus`
- **scope:** `allowedOutputTypes`, `forbiddenScope`, `requiresMaintainerApproval`, `mode`, `slice`, `phase`, `doNotTouch`
- **inputs:** `readFiles`, `readGlobs`, `maxBytes`, `requiredDocs`, `contextNotes`
- **deliverable:** `outboxName`, `format`, `expectedSections`, `audience`
- **proof (reserved):** checklist generation only — Cornerman never claims runtime proof
- **review (reserved):** `codexRequired`, `architectRequired`, `ownerGoRequired`
- **commit/PR (reserved):** handoff hints for Red only; `commit.allowed=false` → report
  states "commit forbidden" and carries no commit instructions; `pr.allowed` additionally
  requires `pr-body` in `allowedOutputTypes` before PR text may ever be drafted
- **constraints:** `noCommit`, `noPush`, `noProof`, `noModelCall`, `noPatch`, `noScheduler`,
  `noSourceEdit` — worker-enforced defaults; packets can restate/tighten, never loosen

---

## Slice roadmap (each future slice = separate Bloodwave GO)

1. **Slice 1:** docs + schema v2 + dry-run worker with repo profiles ✅
2. **Slice 2 (this):** opt-in model call (LM Studio `:1234`) + real report generation ✅
3. Scheduler install (Windows Task Scheduler, logon user)
4. Red drop helper (`Push-CornermanTaskPacket.ps1`) + status extension
5. Candidate-patch mode (outbox-only patches; explicit GO + allowlist)
