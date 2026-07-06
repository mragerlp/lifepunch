# Cornerman headless drop worker — runbook (Slice 1: dry-run)

**Status:** Slice 1 shipped — dry-run validation/report only
**Node:** Green (Cornerman) · testable anywhere with `-BaseDir` scratch dirs
**Authoritative design:** `lifepunch/docs/handoff/CORNERMAN_HEADLESS_DROP_WORKER_OPUS_V2_PLAN_2026-07-06.md` (Part B supersedes Part A)
**Read with:** `CORNERMAN_DROP_WORKFLOW.md` · `GREEN_EXECUTION_MODEL.md` · `BRANCH_MODEL.md` · `WORKTREE_LANE_SAFETY.md`

---

## What Slice 1 is (and is not)

The worker picks up **one** `task-*.json` packet from the Cornerman inbox, validates it
against **task schema v2**, verifies the target repo clone's identity and cleanliness,
enforces lane/branch/input/output law, runs the **no-IP / AI-trailer scan** for
`dxrp-official` tasks, and writes a **dry-run validation report** to the outbox.

| Slice 1 DOES | Slice 1 does NOT |
|---|---|
| Validate schema v2 packets | Call LM Studio / Qwen (no model calls) |
| Resolve `repoProfile` via registry | Install a scheduler / Task Scheduler task |
| Verify clone path + git remotes | Create or apply patches |
| Dirty-tree gate (untracked = dirty) | Commit, push, or open PRs |
| Focus/profile + branch-law checks | Claim runtime/editor proof |
| Input path safety (repo-relative, no `..`) | Mutate git in any way (no fetch/checkout/pull) |
| Output-type gate + forbidden-scope gate | Ship a Red drop helper |
| No-IP / AI-trailer scan (dxrp-official) | Loosen constraints from packet content |
| Report + `meta.json` + ack + history move | |

Future slices (model call, scheduler, candidate-patch mode) each require a separate
Bloodwave GO. `mode: candidate-patch` packets are **rejected** by the Slice 1 worker.

---

## Files

| File | Purpose |
|---|---|
| `lifepunch/scripts/cornerman/Invoke-CornermanDropWorker.ps1` | Orchestrator (one packet per run) |
| `lifepunch/scripts/cornerman/CornermanDropWorker.Lib.ps1` | Shared validation/scan/lock/IO functions |
| `lifepunch/docs/schemas/cornerman-task-packet.schema.json` | Task packet schema v2 (JSON Schema draft-07) |
| `lifepunch/docs/schemas/cornerman-task-packet.example.json` | Valid example packet (`lifepunch-private`) |
| `lifepunch/docs/schemas/cornerman-repo-profiles.example.json` | Repo-profile registry template |

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

1. the candidate/generated report text
2. the packet instruction
3. context notes (`inputs.contextNotes`)
4. **cited input file contents** — every file listed in `inputs.readFiles` is loaded
   from the resolved clone and scanned. Only files the packet explicitly cites are
   read — the worker never scans the whole repo. `readGlobs` are **not** expanded in
   Slice 1, so their content is honestly reported as *not scanned* (warning in the
   report + `meta.json`; glob expansion lands with the model-call slice).

On any hit: no normal report, `error.md` + failed `meta.json` (with the blocked token
and offending file path for cited-input hits), failed ack, packet moved to history as
failed. `meta.json` records `scannedInputFiles` (list) and `inputContentScan`
(`pass` / `fail` / `not-run` / `not-applicable`).

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
# Live (Green):
powershell -NoProfile -File C:\Projects\lifepunch\lifepunch\scripts\cornerman\Invoke-CornermanDropWorker.ps1

# Scratch test (any node) — isolated BaseDir + registry:
powershell -NoProfile -File Invoke-CornermanDropWorker.ps1 `
    -BaseDir C:\tmp\cdw-test `
    -RegistryPath C:\tmp\cdw-test\repo-profiles.json
```

Exit behavior: `IDLE` (empty inbox), `SKIP` (lock held), `OK` (dry-run pass),
`FAIL` (validation failure — details in `error.md`).

First-time Green setup: copy `cornerman-repo-profiles.example.json` to
`C:\lifepunch\cornerman\config\repo-profiles.json` (paths already match Green).

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

1. **Slice 1 (this):** docs + schema v2 + dry-run worker with repo profiles ✅
2. Model call (LM Studio `:1234`) + real report generation
3. Scheduler install (Windows Task Scheduler, logon user)
4. Red drop helper (`Push-CornermanTaskPacket.ps1`) + status extension
5. Candidate-patch mode (outbox-only patches; explicit GO + allowlist)
