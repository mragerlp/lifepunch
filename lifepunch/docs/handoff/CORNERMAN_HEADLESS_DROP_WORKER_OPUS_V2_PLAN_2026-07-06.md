# CORNERMAN HEADLESS DROP WORKER — OPUS PLAN v2 REVIEW ARTIFACT

Status: Plan review artifact only.
No implementation performed.
Opus v2 is authoritative.
Implementation remains blocked until Codex PASS + Bloodwave GO.

---

> **Reading order for Codex:** Part B (Opus v2 repo-profile delta) is **authoritative**. Part A
> (Opus v1) is the complete base plan; where Part B revises a section, the Part B version wins.
> Unchanged v1 sections (1–7, 11, 14–16, 22) stand as written, with §19 Slice 1 expanded per Part B.

---

# PART A — OPUS v1 PLAN (BASE)

## 1. OPUS VERDICT ON GROK FILE MAP

Accurate and usable. Confirmed against source:

- The **transport layer already exists** and is mature: `Cornerman-Workflow.ps1` defines inbox root `C:\lifepunch\cornerman\inbox`, ack log `C:\lifepunch\cornerman\outbox\workflow-ack.ndjson`, Green monorepo `C:\Projects\lifepunch`, plus SSH exec/file-push helpers and `Write-CornermanWorkflowInbox` / `Add-CornermanWorkflowAck`.
- **Critical distinction Grok did not fully surface:** every existing "worker-ish" script (`Send-CornermanWorkflow.ps1`, `Get-CornermanWorkflowStatus.ps1`, `Pull-CornermanPatches.ps1`) runs **on Red and reaches into Green over SSH**. There is **no Green-resident consumer** that reads its own inbox and processes packets. That is precisely the gap the drop worker fills — it is a **Green-side daemon**, not another Red push script.
- Inbox today carries tiny control records (`{id, action, message, execute}`) — **not** rich distill task packets. The schema must be extended (new packet type), not reused verbatim.
- One correction to the map: `Invoke-CornermanHeadlessBoot.ps1` is the existing **scheduled-task payload** pattern (idempotent, logs to `C:\lifepunch\cornerman\headless-boot.log`). The worker's scheduler design should mirror it, not reinvent it.

Verdict: **green-light the plan**, build the worker as a new Green-resident consumer on top of the existing path + ack conventions.

## 2. DIRTY WORKTREE BLOCKER ASSESSMENT

**Live-preflight rule (authoritative):** Implementation GO requires a live preflight check. Before any implementation, VENGEANCE must run `git status --porcelain` in `C:\Users\jared\Projects\lifepunch` and verify the tree is clean except for explicitly approved plan artifacts. The worker itself must also perform dirty-tree checks on the resolved Green clone for the selected `repoProfile` and fail closed on uncommitted changes. Historical dirty-file lists in this plan are context only, not the current source of truth.

> **Historical context from Grok scout; verify live before GO.**
> Red worktree on `develop` was reported dirty at scout time:
> - 9 modified tracked scripts — all **DXRP routing / addon-mount lane** (`Set-DxrpLifepunch*`, `Pull-Dxrp*`, `Sync-LifePunchAddonsToDxrp`, `Initialize-LpAddonDevProject`).
> - 1 untracked: **`lifepunch/scripts/LifePunch-RepoPaths.ps1`** — a path-helper in progress.

Two blocker implications (from the historical snapshot; re-confirm via live preflight):

1. **General:** No new files may be created or committed until the owner parks/commits this lane (`WORKTREE_LANE_SAFETY.md` §4). The worker code is additive and touches none of these files, but the tree must be clean before any commit.
2. **Specific collision:** My plan wants a canonical path helper. **`LifePunch-RepoPaths.ps1` is already being authored** in the dirty tree. The worker should consume that file rather than introduce a competing one — but I cannot read/depend on it while it's another lane's uncommitted work. **Path-helper reuse is BLOCKED pending that lane landing.** Slice 1 must either wait for it or ship a worker-local path block that later refactors onto it.

No stash/reset/restore proposed. Owner resolves per §23.

## 3. EXISTING FILES / SCRIPTS TO REUSE

| Asset | Reuse as |
|---|---|
| `Cornerman-Workflow.ps1` (path constants, `New-CornermanWorkflowId`, ack JSON shape) | Import on Red side; **mirror the constants** on Green side (Green cannot dot-source Red-only SMB functions cleanly, but path + id + ack conventions must match) |
| Inbox root `C:\lifepunch\cornerman\inbox` | Worker input dir (existing) |
| Outbox root `C:\lifepunch\cornerman\outbox` + `workflow-ack.ndjson` | Worker output + run-ack append |
| `Invoke-CornermanHeadlessBoot.ps1` pattern (elevation check, `Add-Content` logfile, idempotent) | Template for worker structure + scheduler payload |
| `Enable-CornermanHeadless.ps1` / `Install-CornermanHeadlessBoot.ps1` | Template for the scheduled-task installer (Slice 3) |
| `Start-CornermanLmStudio.ps1` (serves `:1234`, warm daily/coder) | Worker's model-availability precheck / warm trigger |
| `Send-CornermanWorkflow.ps1` `-Action Inbox` | Extend/parallel for the Red drop helper (Slice 4) |
| `Get-CornermanWorkflowStatus.ps1` | Extend to surface worker run history/outbox |
| `Sync-CornermanRebootScripts.ps1` | Existing channel that copies Red scripts → `C:\lifepunch\cornerman\` (how the worker reaches Green) |

## 4. EXISTING FILES / SCRIPTS TO AVOID

- **`Pull-CornermanPatches.ps1`** — push/`git am`/`git push origin main` path. Out of scope; worker never commits or pushes. Only relevant far later if Slice 5 candidate patches are adopted, and even then Red drives it manually.
- **All `Push-Cornerman*Brief.ps1` / `*Task.ps1`** — one-off, task-specific; do not generalize or refactor them into the worker.
- **Voice/relay/whisper scripts** (`Start-CornermanVoiceRelay`, `watch-cornerman-voice`, `Apply-CornermanWhisperFix`, PTT) — unrelated subsystem.
- **`Reset-CornermanClone.ps1`, `Repair-CornermanMonorepo.ps1`** — destructive clone management; worker must never call these (they can `reset`/rewrite the Green clone).
- **Bridge/SMB/tunnel scripts** — editor-runtime concern; worker is eyes-covered and needs none of it.

## 5. FILES TO CREATE

All new, additive (Green-resident worker + Red-side helper + docs/schema):

| Path | Role | Slice |
|---|---|---|
| `lifepunch/docs/CORNERMAN_HEADLESS_DROP_WORKER.md` | Canonical design + operator runbook | 1 |
| `lifepunch/docs/schemas/cornerman-task-packet.schema.json` | Task packet JSON Schema | 1 |
| `lifepunch/docs/schemas/cornerman-task-packet.example.json` | Reference packet | 1 |
| `lifepunch/scripts/cornerman/Invoke-CornermanDropWorker.ps1` | **The worker** (Green-resident; runs one pass) | 1 (dry-run) → 2 (model) |
| `lifepunch/scripts/cornerman/CornermanDropWorker.Lib.ps1` | Shared worker funcs (packet parse/validate, lock, log, branch guard, dirty check) | 1 |
| `lifepunch/scripts/cornerman/Invoke-CornermanLocalModel.ps1` | LM Studio `:1234` OpenAI-compatible caller (isolated for testing) | 2 |
| `lifepunch/scripts/Install-CornermanDropWorkerTask.ps1` | Scheduled-task installer (mirrors `Enable-CornermanHeadless`) | 3 |
| `lifepunch/scripts/Send-CornermanDropTask.ps1` | **Red-side** packet builder + inbox drop | 4 |
| `lifepunch/docs/handoff/templates/CORNERMAN_DROP_TASK_TEMPLATE.json` | Copy-paste packet template | 4 |

Note: worker scripts live under a new `lifepunch/scripts/cornerman/` subfolder (one already exists: `scripts/cornerman/Run-ModelDocGreenfieldSweep.ps1`), keeping worker code grouped.

## 6. FILES TO MODIFY

Minimal, and each **only after the dirty lane lands**:

| File | Change | Guard |
|---|---|---|
| `lifepunch/docs/CORNERMAN_DROP_WORKFLOW.md` | Add "Headless drop worker" section + cross-link | Safe (doc) |
| `lifepunch/docs/handoff/AGENT_GROUNDING_INDEX.md` | One row pointing at the worker runbook | Safe (doc) |
| `Get-CornermanWorkflowStatus.ps1` | Optional: also tail worker `history/` + `logs/` | Low risk; additive |
| `lifepunch/scripts/LifePunch-RepoPaths.ps1` | **Consume** for canonical paths | **BLOCKED — untracked, another lane's WIP. Do not touch until it lands; until then worker uses a local path block.** |

No modification to any of the 9 dirty DXRP scripts is proposed.

## 7. FILES NOT TO TOUCH

- The 9 dirty DXRP routing scripts (§2).
- `lifepunch/scripts/LifePunch-RepoPaths.ps1` (untracked WIP) — read-only-later, not now.
- `lifepunchaddons/**` (product code).
- Historical packets in `lifepunch/docs/handoff/cornerman-outbox/**` and `cornerman-inbox/**` (record).
- `Pull-CornermanPatches.ps1`, `Reset-CornermanClone.ps1`, `Repair-CornermanMonorepo.ps1`, all bridge/voice scripts.
- Any `.cursor/rules/*` (law — separate owner-gated change if ever needed).

## 8. PROPOSED INBOX / OUTBOX / HISTORY / LOG / LOCK PATHS

Green-resident (matches existing convention; only `inbox`/`outbox` exist today):

```
C:\lifepunch\cornerman\inbox      # task-*.json packets (NEW packet type alongside wf-*.json)
C:\lifepunch\cornerman\outbox     # <task-id>/ report dir + append workflow-ack.ndjson
C:\lifepunch\cornerman\history    # NEW — processed packets moved here (success or fail)
C:\lifepunch\cornerman\logs       # NEW — per-run + rolling worker log
C:\lifepunch\cornerman\lock       # NEW — worker.lock (single-run guard)
```

Repo path (Green clone, per `Cornerman-Workflow.ps1`): **`C:\Projects\lifepunch`** (not the Red `C:\Users\jared\Projects\lifepunch`). The worker runs on Green and reads the Green clone. The Red path in the task is used only by the Red drop helper.

Packet naming: `task-YYYYMMDD-HHmmss-<slug>.json` (distinct from control `wf-*.json` so the worker only claims its own type).

Outbox report layout per task:
```
outbox\<task-id>\report.md
outbox\<task-id>\meta.json      # inputs, branch, model, timings, status
outbox\<task-id>\error.md       # only on failure
```

## 9. TASK PACKET SCHEMA

```jsonc
{
  "schemaVersion": 1,
  "id": "task-20260706-041500-hub-vs-hashd",     // required, unique
  "type": "cornerman-distill",                    // required: distill | audit | summarize
  "createdBy": "vengeance",                       // required
  "createdTs": "2026-07-06T08:15:00Z",            // required (ISO-8601 UTC)
  "focus": "LifePunch",                           // required: LifePunch | DXRP (never both)
  "routeTag": "GREEN DEEP REQUIRED",              // required: GREEN DEEP REQUIRED | GREEN CODE REQUIRED | AUTO OK
  "branch": "main",                               // required: main | develop (explicit; worker never chooses)
  "repoRoot": "C:\\Projects\\lifepunch",          // required (Green clone)
  "model": {                                      // required
    "endpoint": "http://127.0.0.1:1234/v1/chat/completions",
    "name": "qwen-distill",                       // logical name; worker verifies availability
    "maxTokens": 4096,
    "temperature": 0.2
  },
  "inputs": {                                     // required
    "readFiles": [                                // repo-relative; worker refuses absolute/`..`
      "lifepunchaddons/Code/Addons/lifepunch/lpbitcoin/bitcoinhub/code/ui/LpHashdPanel.razor.scss"
    ],
    "readGlobs": [],                              // optional, bounded
    "maxBytes": 400000                            // hard cap on total input
  },
  "instruction": "Compare HUB panel to HASHD terminal style; list traits to borrow, functions not to touch.",
  "deliverable": {                                // required
    "outboxName": "HUB_VS_HASHD_STYLE",
    "format": "markdown"
  },
  "mode": "report",                               // required: report (default) | candidate-patch (Slice 5, GO-gated)
  "constraints": {                                // optional overrides (defaults enforced regardless)
    "noCommit": true, "noPush": true, "noProof": true
  }
}
```

**Required fields (stop if missing):** `id, type, focus, routeTag, branch, repoRoot, model.endpoint, inputs.readFiles|readGlobs, instruction, deliverable.outboxName`.
**Hard rejects:** `branch` not in {`main`,`develop`}; `focus` = both; any input path absolute or containing `..`; `mode: candidate-patch` without a separate GO flag file (Slice 5).

## 10. WORKER RUN FLOW

`Invoke-CornermanDropWorker.ps1` (one pass; scheduler invokes repeatedly):

1. **Elevation/context check** (mirror headless-boot); ensure Green paths exist.
2. **Acquire lock** (§11). If held → log "busy", exit 0.
3. **Select one packet:** oldest `task-*.json` in inbox by `LastWriteTimeUtc`. None → release lock, exit 0.
4. **Parse + validate** against schema (§9). Missing/invalid required field → **failure report + move to history**, exit non-zero.
5. **Branch guard** (§13): read `branch`; enforce main-default / develop-only-if-specified; worker never substitutes.
6. **Sync the specified branch only:** `git -C <repoRoot> fetch` then checkout+`pull --rebase` the packet branch. Never `reset/clean/stash`.
7. **Dirty-tree gate** (§12): `git status --porcelain`. Dirty → **stop, failure report, move to history**, exit non-zero. (No mutation attempted.)
8. **Gather inputs:** resolve repo-relative files/globs, enforce `maxBytes`, refuse traversal.
9. **Model precheck:** ping `:1234` (`/v1/models`). Unreachable → optional single warm attempt via `Start-CornermanLmStudio.ps1`; still down → **failure report** (§17).
10. **Call model** (§14) with system prompt injecting eyes-covered footer + no-commit/no-proof constraints.
11. **Write outbox:** `outbox\<id>\report.md` (+ required footer), `meta.json` (timings, model, input list, byte counts).
12. **Append ack** to `workflow-ack.ndjson` (existing shape: `{ts,id,action:"drop-worker",ok,detail}`).
13. **Move packet** inbox → `history\<id>.json` with status suffix.
14. **Release lock**; write run log (§16); exit 0 (success) / non-zero (handled failure).

Every terminal path releases the lock and writes a log line.

## 11. LOCKING / CONCURRENCY PLAN

- Lock file: `C:\lifepunch\cornerman\lock\worker.lock` containing `{pid, host, startedUtc}`.
- **Acquire:** create-new-exclusive. If exists → read; if `pid` alive and started < staleMinutes → exit 0 (busy). If stale (process dead or age > 30 min) → reclaim with a logged warning.
- **One packet per run** (never batch) — bounds runtime and simplifies recovery.
- **Release** in `finally`. Scheduler overlap disabled (task setting) as belt-and-suspenders.
- No cross-node locking needed (worker is Green-only); Red drop helper only writes packets, never runs the worker.

## 12. DIRTY-TREE SAFETY PLAN

- Gate at step 7 **before** any model call: `git -C <repoRoot> status --porcelain`.
- **Any** tracked modification → STOP; write `error.md` ("Green clone dirty — worker will not run on an unclean tree"), move packet to history, ack `ok:false`, exit non-zero.
- Worker **never** runs `restore/reset/clean/stash/checkout --`—it only ever `fetch` + `checkout <branch>` + `pull --rebase`, and even those abort on dirty.
- Untracked-only files: treat as **dirty for safety** in v1 (report + stop) to avoid masking WIP; a future allow-list can relax this.
- Mirrors the same guard already used in `Pull-CornermanPatches.ps1` (Red side), keeping behavior consistent.

## 13. BRANCH BEHAVIOR PLAN

- Branch comes **only** from the packet. Default authored by Red is `main` (truth/export/stability).
- `develop` permitted **only** when the packet explicitly sets it (active/`develop`-bound audit) — matches `BRANCH_MODEL.md` Green nuance.
- Worker **rejects** any branch outside {`main`,`develop`} and **never infers** one.
- Worker does **not** create, delete, merge, or push branches. Checkout + `pull --rebase` only.
- If checkout fails (e.g. dirty, or branch missing) → failure report, no force.

## 14. MODEL ENDPOINT PLAN

- Endpoint: LM Studio OpenAI-compatible `http://127.0.0.1:1234/v1/chat/completions`; models probe `…/v1/models`.
- Isolated in `Invoke-CornermanLocalModel.ps1` (testable standalone): takes system+user prompt, returns text + token/timing meta; `Invoke-RestMethod` with explicit timeout.
- **System prompt hardening:** inject eyes-covered law, "distill from provided repo text only," "no commit/push/proof/editor claims," and require the mandatory footer.
- **Warm coupling:** route tag maps to warm model — `GREEN DEEP REQUIRED`→`daily`/distill, `GREEN CODE REQUIRED`→`coder` (reuse `Start-CornermanLmStudio.ps1 -WarmModel`).
- **Failure:** connect/HTTP/timeout/empty completion → structured failure (§17); never emit a partial report as success.
- No network egress beyond localhost; no cloud fallback.

## 15. WINDOWS TASK SCHEDULER PLAN

- `Install-CornermanDropWorkerTask.ps1` mirrors `Enable-CornermanHeadless.ps1`/`Install-CornermanHeadlessBoot.ps1`:
  - Task `LifePunch-Cornerman-DropWorker`, runs `Invoke-CornermanDropWorker.ps1` from `C:\lifepunch\cornerman\`.
  - Trigger: every N minutes (default 5) **or** at logon; **overlap disabled** (`MultipleInstances IgnoreNew`).
  - Runs as the **logon user** (LM Studio serves under the interactive session, per headless-boot's SYSTEM caveat) — not SYSTEM.
  - Idempotent register/update; `-WhatIf` support; logs registration to worker log.
- Installer is **Slice 3** and **not run** by anyone but the owner on Green; the plan only authors it. No task is installed during planning.

## 16. LOGGING / HISTORY PLAN

- **Per-run log:** `logs\worker-YYYYMMDD.log` — append `[ts] id=… branch=… status=… model=… ms=… bytes=…` (mirrors headless-boot's `Add-Content` style).
- **Ack stream:** append one line to existing `outbox\workflow-ack.ndjson` per run (keeps `Get-CornermanWorkflowStatus.ps1` working).
- **History:** processed packet JSON → `history\<id>.<ok|fail>.json`; report artifacts stay under `outbox\<id>\`.
- **meta.json** per task captures inputs, byte counts, model name, timings, exit status for later audit.
- Log rotation: date-stamped files; no unbounded single log.

## 17. FAILURE MODES AND STOP CONDITIONS

| Condition | Action |
|---|---|
| Lock held / another run | Log busy, exit 0 (no packet touched) |
| No packet | Exit 0 |
| Missing/invalid required field | `error.md`, move to history `.fail`, ack false, exit 1 |
| `branch` not main/develop, or focus=both | Reject → failure report |
| Input path absolute / contains `..` / over `maxBytes` | Reject → failure report |
| Green clone dirty | STOP, failure report, no git mutation |
| `git fetch/checkout/pull` fails | Failure report, no force/reset |
| Model endpoint unreachable after one warm attempt | Failure report (`error.md`), ack false |
| Model returns empty/HTTP error/timeout | Failure report; never mark success |
| `candidate-patch` mode without GO flag | Reject (Slice 5 gate) |
| Any unexpected exception | `finally` releases lock, logs, ack false |

**Never** on any path: commit, push, proof/editor claim, portal edit, branch decision, restore/reset/clean/stash, source edit (until Slice 5 GO — and then only `.patch` to outbox).

## 18. TEST PLAN

**Slice 1 (dry-run, no model):**
- Schema validation: valid packet passes; each missing required field fails deterministically.
- Path traversal / absolute / oversize inputs rejected.
- Lock: second concurrent invocation exits busy; stale lock reclaimed.
- Dirty-clone gate: seed a dummy dirty file in a **throwaway** clone → worker stops (tested on a scratch clone, never the live Green clone).
- Branch guard: packet with `feature/x` rejected; `develop` honored only when specified.
- History move + ack line + log line all written.

**Slice 2 (model):**
- `Invoke-CornermanLocalModel.ps1` standalone against `:1234` returns text + meta.
- Endpoint-down path yields failure report, not a partial.
- Footer + constraints present in output.

**Slice 3:** installer `-WhatIf`; task registered with overlap disabled; manual trigger runs one pass.

**Slice 4:** `Send-CornermanDropTask.ps1` writes a schema-valid packet to inbox (dry `-WhatIf` first).

All destructive-adjacent tests use **scratch clones/dirs**, never the live Green clone or Red worktree.

## 19. IMPLEMENTATION SLICES

1. **Docs + schema + dry-run worker** (no model): runbook, JSON Schema + example, `CornermanDropWorker.Lib.ps1`, `Invoke-CornermanDropWorker.ps1` through step 8 with a stubbed model step. Local path block (not `LifePunch-RepoPaths.ps1` yet).
2. **Model call:** `Invoke-CornermanLocalModel.ps1`, wire steps 9–11, warm coupling, failure reports.
3. **Scheduler installer:** `Install-CornermanDropWorkerTask.ps1` (+ `-WhatIf`).
4. **Red drop helper:** `Send-CornermanDropTask.ps1` + packet template; optional `Get-CornermanWorkflowStatus.ps1` tail extension.
5. **Candidate-patch mode (separate GO):** `mode:candidate-patch` writes `.patch` to `outbox\<id>\candidate\` only; requires a GO flag file on Green; still no commit/push. Refactor onto `LifePunch-RepoPaths.ps1` once that lane has landed.

Each slice = one commit, owner-GO gated, on a clean tree.

## 20. RISKS

- **Path-helper collision** with in-flight `LifePunch-RepoPaths.ps1` → mitigate by worker-local paths in Slices 1–4, refactor in Slice 5.
- **Green vs Red path confusion** (`C:\Projects\lifepunch` vs `C:\Users\jared\Projects\lifepunch`) → repoRoot is explicit in the packet; worker asserts it's the Green clone.
- **LM Studio not warm / interactive-session dependency** → precheck + single warm attempt + fail-closed.
- **Scheduler running as SYSTEM** would break LM Studio access → installer pins logon user.
- **Scope creep to a "second shipper"** → hard constraints + Slice 5 gate keep it read-only/distill.
- **Untracked-as-clean masking WIP** → v1 treats untracked as dirty (stop).
- **Long inputs / token blowups** → `maxBytes` + `maxTokens` caps.
- **Encoding** (existing scripts fight BOM/UTF-8) → worker writes UTF-8 no-BOM like `Push-CornermanText`.

## 21. CODEX REVIEW CHECKLIST

- [ ] No `git commit/push/reset/clean/stash/restore/checkout --` anywhere in worker paths.
- [ ] Dirty-clone gate precedes model call and any git mutation.
- [ ] Branch strictly from packet; only main/develop; no inference.
- [ ] Lock acquired/released on every exit (incl. exceptions); overlap disabled.
- [ ] Required-field validation fails closed; failure reports written + history move + ack.
- [ ] Input paths repo-relative only; traversal/absolute/oversize rejected.
- [ ] Model failure never yields a "success" report; footer + constraints injected.
- [ ] Outbox/ack/log/history all written; UTF-8 no-BOM.
- [ ] No editor/bridge/proof claims; eyes-covered footer present.
- [ ] Slice 5 patch mode gated by explicit GO flag; `.patch` to outbox only, never applied.
- [ ] Does not touch the 9 dirty DXRP scripts or `LifePunch-RepoPaths.ps1`.
- [ ] No secrets in packets/logs.

## 22. RECOMMENDED COMMIT ORDER

Each on a clean tree, own-lane, `mragerlp` author, no AI trailers, owner GO per commit:

1. `docs(cornerman): headless drop worker design + task packet schema` (Slice 1 docs/schema)
2. `feat(cornerman): dry-run drop worker + lib (no model call)` (Slice 1 code)
3. `feat(cornerman): local LM Studio model call + failure reports` (Slice 2)
4. `feat(cornerman): drop-worker scheduled task installer` (Slice 3)
5. `feat(cornerman): Red-side drop-task helper + template` (Slice 4)
6. *(separate GO)* `feat(cornerman): candidate-patch mode (outbox .patch only)` (Slice 5)

## 23. WHAT BLOODWAVE MUST RESOLVE BEFORE IMPLEMENTATION GO

1. **Clean the Red worktree** — commit or park (`WORKTREE_LANE_SAFETY.md` §4) the 9 DXRP routing scripts + untracked `LifePunch-RepoPaths.ps1`. Nothing is created/committed until then.
2. **Decide `LifePunch-RepoPaths.ps1` coupling** — should the worker consume it (wait for it to land) or ship worker-local paths first and refactor in Slice 5? (I recommend the latter to avoid blocking.)
3. **Confirm Green paths + run identity** — worker runs as the **logon user** on Cornerman with LM Studio serving `:1234`; confirm that's the intended account.
4. **Confirm scheduler cadence** — every 5 min vs logon-only vs manual-only for v1.
5. **Confirm packet author** — Red authors packets via `Send-CornermanDropTask.ps1` (Slice 4); until then packets are hand-dropped for testing.
6. **Explicitly keep Slice 5 gated** — candidate-patch mode stays off until a separate GO; default worker is report-only.
7. **GO scope** — confirm we start at **Slice 1 (docs + schema + dry-run only)**.

---

# PART B — OPUS v2 REPO-PROFILE DELTA (AUTHORITATIVE)

> This delta supersedes the v1 sections it revises. Unchanged v1 sections (1–7, 11, 14–16, 22)
> stand as written, with §19 Slice 1 now expanded to include `repoProfile` support.

Confirmed environment fact: `dxrp-public` has `origin=mragerlp/dxrp-public`, `upstream=dxura/dxrp`,
currently on `develop` (ahead 17 / behind 2 vs `origin/develop`).

## NEW SECTION: DXRP OFFICIAL LANE SUPPORT (repo profiles)

The worker is **multi-repo / lane-profile aware** from Slice 1. A packet declares exactly one `repoProfile`; the worker resolves node-local clone paths, remotes, branch law, and allowed outputs from a **profile registry** — never by inference.

**Critical node nuance:** the listed Red paths are **authoring-node** paths. The worker runs on **Green**, which needs its own clones. The packet carries the canonical `repoProfile` + the authoring node's `repoPath`; the worker maps profile → **Green clone path** via a registry and asserts the resolved clone matches the profile's expected remotes before doing anything. If Green lacks a matching clone, it fails closed (no auto-clone in v1).

Profile registry (design constant, resolved per node):

| Profile | Red path (authoring) | Green clone (worker) | origin | upstream | Base branch law | IP posture |
|---|---|---|---|---|---|---|
| `lifepunch-private` | `C:\Users\jared\Projects\lifepunch` | `C:\Projects\lifepunch` | `mragerlp/lifepunch` | — | `main` default; `develop` only if packet says so | LIFEPUNCH™ private OK |
| `dxrp-official` | `C:\Users\jared\Projects\dxrp-public` | `C:\Projects\dxrp-public` (must exist on Green) | `mragerlp/dxrp-public` | `dxura/dxrp` | read `upstream/develop`; feature branches based on `upstream/develop`; explicit `reviewBranch` for existing PRs | **NO** LifePunch headers/paths/IP; no AI trailers |

**`dxrp-official` hard law (enforced by worker, not assumed):**
- Read only from `upstream/develop` (or an explicit `reviewBranch`). Never assume private LIFEPUNCH repo law applies.
- Allowed outputs only: issue summaries, PR review packets, file maps, DXRP style checks, no-IP-leak scans, PR body drafts, and (future GO only) candidate `.patch` files to outbox.
- Forbidden: commit, push, open PRs, modify upstream files directly, add LIFEPUNCH headers / `lifepunch/` paths / proprietary branding, portal/permission backend work unless explicitly scoped + maintainer-approved, runtime-proof claims, independent staff/permission decisions.
- `requiresMaintainerApproval` defaults **true** for any implementation-adjacent `dxrp-official` task.
- The worker may use LIFEPUNCH onboarding **only** for process separation (lane hygiene), never for DXRP code style or product decisions. **DXRP repo law + maintainer direction win inside `dxrp-public`.**

**Cross-contamination guard (mandatory):** before writing any `dxrp-official` output, the worker runs a **no-IP-leak scan** on its own generated text and on any cited input — reject/flag if it contains private LIFEPUNCH branding, private paths, proprietary header fragments, AI attribution trailers, or LIFEPUNCH addon paths. Valid public DXRP identifiers such as `mragerlp/dxrp-public`, `mragerlp-party-*` branches, and `mragerlp <mragerlp@gmail.com>` are explicitly allowed. A `dxrp-official` packet that points `readFiles` at `lifepunch/**` is rejected outright. Full allow/block rules are defined in **DXRP no-IP / trailer scan policy** below.

## DXRP no-IP / trailer scan policy

For `repoProfile: dxrp-official`, the worker must run a no-IP / trailer scan before writing any generated DXRP output.

The scan must distinguish public fork identity from private LIFEPUNCH™ IP.

**Allowed DXRP public identifiers:**

* `mragerlp/dxrp-public`
* GitHub URLs containing `github.com/mragerlp/dxrp-public`
* branch names matching `mragerlp-party-*`
* author identity `mragerlp <mragerlp@gmail.com>`
* ordinary references to `dxura/dxrp`, `upstream/develop`, and DXRP issue/PR numbers

**Blocked private identifiers / content:**

* `LIFEPUNCH™`
* `LIFEPUNCH`
* `LifePunch`
* `lifepunch.co`
* private repo paths:
  * `C:\Users\jared\Projects\lifepunch`
  * `C:\Projects\lifepunch`
* private repo/folder path leakage in DXRP artifacts:
  * `lifepunch/`
  * `lifepunchaddons/`
  * `lifepunchdxrp/`
* proprietary header fragments:
  * `PROPRIETARY`
  * `PRIVATE LIFEPUNCH`
  * `LIFEPUNCH PRIVATE`
* any private server assumption or LIFEPUNCH-branded addon path inside DXRP upstream output

**AI trailer blocking:**
The scan must block generated commit messages, patch metadata, PR text, or report text containing AI attribution trailers such as:

* `Co-authored-by: Cursor`
* `Co-authored-by: Claude`
* `Co-authored-by: Copilot`
* `Co-authored-by: AI`
* `Co-authored-by: agent`
* `cursoragent@cursor.com`
* `Generated-by:`
* `Assisted-by:`
* `AI-authored-by:`

**Important:** Do not block `mragerlp` by itself. It is the public fork owner / commit author identity. Only AI attribution trailers or private LIFEPUNCH identifiers are blocked.

**Failure behavior:** If a disallowed match is found in `dxrp-official` output:

* do not write the normal report
* write `error.md`
* write a failed `meta.json`
* append failed ack
* move packet to history as failed

## §9 TASK PACKET SCHEMA (revised — supersedes v1 §9)

```jsonc
{
  "schemaVersion": 2,
  "id": "task-20260706-041500-dxrp-116-scope",
  "type": "cornerman-distill",                 // distill | audit | summarize | pr-review | style-check | ip-scan | file-map | pr-body
  "createdBy": "vengeance",
  "createdTs": "2026-07-06T08:15:00Z",

  "repoProfile": "dxrp-official",              // REQUIRED: lifepunch-private | dxrp-official
  "repoPath": "C:\\Users\\jared\\Projects\\dxrp-public",   // REQUIRED (authoring node); worker maps to Green clone + verifies remotes
  "baseRemote": "upstream",                    // REQUIRED (lifepunch-private: origin; dxrp-official: upstream)
  "baseBranch": "develop",                     // REQUIRED (resolved as upstream/develop for dxrp-official)
  "reviewBranch": "mragerlp/party-phase2",     // OPTIONAL — required when reviewing an existing PR branch

  "focus": "DXRP",                             // REQUIRED: LifePunch | DXRP (must agree with repoProfile)
  "routeTag": "GREEN DEEP REQUIRED",
  "model": { "endpoint": "http://127.0.0.1:1234/v1/chat/completions", "name": "qwen-distill", "maxTokens": 4096, "temperature": 0.2 },

  "inputs": { "readFiles": ["game/..."], "readGlobs": [], "maxBytes": 400000 },  // repo-relative to the profile clone; traversal/absolute rejected
  "instruction": "Summarize scope + review checklist for issue #116; no implementation.",

  "allowedOutputTypes": ["pr-review", "file-map", "ip-scan", "pr-body"],  // REQUIRED — worker refuses to emit anything not listed
  "forbiddenScope": ["portal", "permissions-backend", "lifepunch-ip"],   // REQUIRED — explicit deny list
  "requiresMaintainerApproval": true,           // REQUIRED; default true for dxrp-official implementation-adjacent tasks

  "deliverable": { "outboxName": "DXRP_116_REVIEW", "format": "markdown" },
  "mode": "report"                              // report | candidate-patch (Slice 5, GO-gated, .patch to outbox only)
}
```

**Required fields (stop if missing):** all v1 required fields **plus** `repoProfile, repoPath, baseRemote, baseBranch, allowedOutputTypes, forbiddenScope, requiresMaintainerApproval`. `reviewBranch` required only when the task reviews an existing PR branch.

**Hard rejects (added):**
- `repoProfile` not in the registry.
- `focus`/`repoProfile` mismatch (e.g. `focus:LifePunch` + `dxrp-official`).
- Resolved Green clone's remotes don't match the profile (wrong `origin`/`upstream`) → fail closed.
- `dxrp-official` with any `readFiles`/`readGlobs` under `lifepunch/**`, or `baseRemote` = `origin` when law requires `upstream`.
- Output type produced that isn't in `allowedOutputTypes`.
- `candidate-patch` mode, or any implementation-adjacent `dxrp-official` task, when `requiresMaintainerApproval:true` and no maintainer-approval GO flag present.

## Schema completeness — full lifecycle contract

Task schema v2 models the **full lifecycle contract** — `idea → brief → agent → proof → review → commit/PR` — even though the Slice 1 worker only implements dry-run validation/report behavior. The schema is allowed to carry (and validate) future-reserved fields for lifecycle gates the worker does not yet execute. This keeps a single packet the durable contract across all slices; later slices light up behavior without a schema break.

Schema v2 must include fields — or explicit future-reserved fields — for:

**1. Idea / task identity**
* `id` · `title` · `type` · `createdBy` · `createdTs` · `owner`

**2. Repo / lane routing**
* `repoProfile` · `repoPath` · `baseRemote` · `baseBranch` · `reviewBranch` · `routeTag` · `focus`

**3. Scope control**
* `allowedOutputTypes` · `forbiddenScope` · `requiresMaintainerApproval` · `mode` · `slice` · `phase` · `doNotTouch`

**4. Grounding / inputs**
* `inputs.readFiles` · `inputs.readGlobs` · `inputs.maxBytes` · optional `requiredDocs` · optional `contextNotes`

**5. Deliverable contract**
* `deliverable.outboxName` · `deliverable.format` · optional `deliverable.expectedSections` · optional `deliverable.audience`

**6. Proof / verification expectations**
* optional `proof.required` · `proof.type` · `proof.mapHint` · `proof.evidenceExpected`
* **Note:** Cornerman never claims runtime proof; proof fields are for checklist generation only.

**7. Review gates**
* optional `review.codexRequired` · `review.architectRequired` · `review.ownerGoRequired`

**8. Commit / PR authority**
* optional `commit.allowed` · `commit.messageSuggestion` · `pr.allowed` · `pr.target`
* **Note:** worker never commits, pushes, or opens PRs; these fields only generate handoff/checklists for Red.

**9. Safety policy**
* `constraints.noCommit` · `constraints.noPush` · `constraints.noProof` · optional `constraints.noModelCall` · `constraints.noPatch` · `constraints.noScheduler` · `constraints.noSourceEdit`

**10. Output safety**
* no-IP / trailer scan (see policy above) · output-type gate · failure behavior (`error.md` + failed `meta.json` + failed ack + move to history)

> The schema is allowed to model future lifecycle gates before the worker executes them. Slice 1 validates and reports these fields, but does not perform model calls, scheduler installs, patch creation, commits, pushes, PRs, or proof.

**Schema-completeness test cases:**
* packet with `proof.required=true` produces checklist text only, not a proof claim
* packet with `commit.allowed=false` cannot produce commit instructions except "commit forbidden"
* packet with `pr.allowed=true` for `dxrp-official` can draft PR text only if `pr-body` is in `allowedOutputTypes`
* packet with `forbiddenScope` containing `permissions-backend` must reject staff/permission implementation output unless explicitly approved
* packet with `mode:candidate-patch` is rejected in Slice 1

## §8 PATHS (addendum to v1 §8)

Inbox/outbox/history/logs/lock unchanged (Green: `C:\lifepunch\cornerman\...`). Add a **profile registry file** consumed by the worker:

```
C:\lifepunch\cornerman\config\repo-profiles.json   # NEW — profile → {greenClonePath, expectedOrigin, expectedUpstream, branchLaw, ipPosture}
```

Outbox reports are written under the **shared** Cornerman outbox regardless of profile (Green artifact space is not upstream), but `dxrp-official` reports carry a DXRP-lane footer and pass the no-IP-leak scan before write.

## §10 WORKER RUN FLOW (revised — supersedes affected v1 §10 steps)

Insert after parse/validate (step 4), before branch guard:

- **4a. Resolve profile:** load `repo-profiles.json`, map `repoProfile` → Green clone path + expected remotes.
- **4b. Verify clone identity:** `git -C <greenClone> remote -v` must match expected `origin`/`upstream`. Mismatch/missing → failure, move to history.
- **4c. Focus/profile agreement + forbiddenScope sanity.**

Revise branch step (v1 steps 5–6):
- `lifepunch-private`: checkout `baseBranch` (main default / develop-if-specified) + `pull --rebase origin`.
- `dxrp-official`: `git fetch upstream`; read state from `upstream/<baseBranch>` (default `upstream/develop`); if `reviewBranch` set, `fetch origin <reviewBranch>` and read it read-only. **Never** checkout/modify; detached read is sufficient for audit.

Add before write (v1 step 11):
- **10a. Output-type gate:** every artifact's type ∈ `allowedOutputTypes`.
- **10b. No-IP-leak scan** for `dxrp-official` (generated text + citations). Fail → `error.md`, no report emitted.

## §12 DIRTY-TREE SAFETY (addendum to v1 §12)

Dirty gate applies per **resolved profile clone**. For `dxrp-official`, the worker performs **fetch + read-only inspection only** (no checkout of upstream into a working tree) — so it tolerates the clone being ahead/behind on its own `develop` (as it currently is: ahead 17/behind 2) **but still stops on uncommitted tracked changes** in that clone.

## §13 BRANCH BEHAVIOR (replaced — supersedes v1 §13)

Branch law is **profile-scoped and packet-driven; never inferred**:
- `lifepunch-private`: `main` default; `develop` only if the packet says so. `origin` remote.
- `dxrp-official`: base is always `upstream/develop`; feature branches (future modes) based on `upstream/develop`; existing-PR review requires explicit `reviewBranch` off `origin`. Worker never creates/moves/pushes branches on either profile.

## §17 FAILURE MODES (added rows to v1 §17)

| Condition | Action |
|---|---|
| Unknown `repoProfile` / registry miss | Failure report, history |
| Green clone remotes ≠ profile expected | Failure report (no git ops) |
| `focus`/`repoProfile` mismatch | Reject |
| `dxrp-official` reading `lifepunch/**` or wrong `baseRemote` | Reject |
| Output type ∉ `allowedOutputTypes` | Reject, no write |
| No-IP-leak scan hit (dxrp-official) | Failure, no report emitted |
| `requiresMaintainerApproval:true` + no approval GO | Reject implementation-adjacent work |

## §18 TEST PLAN (added cases to v1 §18)

- Profile resolution: valid `lifepunch-private` and `dxrp-official` packets resolve correct clones; wrong-remote clone fails closed.
- Contamination guards: `dxrp-official` packet citing `lifepunch/**` rejected; generated text containing `LIFEPUNCH`/header fragment → scan blocks write.
- Output-type gate: emitting a type not in `allowedOutputTypes` rejected.
- Branch law: `dxrp-official` reads `upstream/develop`; `reviewBranch` honored read-only; no checkout/push attempted.
- `requiresMaintainerApproval` default true for dxrp implementation-adjacent tasks; gate blocks without approval flag.
- All using scratch clones / read-only inspection — never mutating the live `dxrp-public` tree.

**No-IP scan allowlist tests (must PASS / be allowed):**
- `mragerlp/dxrp-public` is allowed
- `github.com/mragerlp/dxrp-public` is allowed
- `mragerlp-party-browse` is allowed
- `mragerlp <mragerlp@gmail.com>` is allowed

**No-IP scan block tests (must be BLOCKED):**
- `LIFEPUNCH™` is blocked
- `C:\Users\jared\Projects\lifepunch` is blocked
- `lifepunchaddons/` is blocked in dxrp-official output
- `PROPRIETARY` is blocked
- `Co-authored-by: Cursor <cursoragent@cursor.com>` is blocked
- `Generated-by:` is blocked
- `Assisted-by:` is blocked

## §19 IMPLEMENTATION SLICES (revised — supersedes v1 §19)

- **Slice 1 → `docs + task schema (v2, repoProfile) + dry-run worker with repoProfile support`.** Includes profile registry, clone-identity verification, focus/profile agreement, output-type gate, and the no-IP-leak scan — **still no model calls, no scheduler, no patch mode.**
- Slice 2: local model call.
- Slice 3: scheduler installer.
- Slice 4: Red drop helper emits both profiles (defaults `requiresMaintainerApproval:true` for dxrp implementation-adjacent).
- Slice 5 (separate GO): candidate-patch — **per-profile gated**; `dxrp-official` also requires maintainer-approval flag; `.patch` to outbox only, never applied.

## §20 RISKS (added to v1 §20)

- **Cross-lane IP bleed** (LIFEPUNCH text into DXRP output) → no-IP-leak scan + input-path rejection + lane footer.
- **Wrong-clone execution** (Green clone mismatch) → remote verification fail-closed.
- **Missing Green dxrp clone** → v1 fails closed (no auto-clone); owner provisions it (§23).
- **Assuming private branch law upstream** → profile-scoped branch law, `dxura/dxrp` maintainer direction wins.

## §21 CODEX CHECKLIST (added to v1 §21)

- [ ] `repoProfile` required; clone remotes verified before any git op.
- [ ] `dxrp-official`: no LifePunch headers/paths/IP/AI trailers in any output; no-IP-leak scan runs and can block write.
- [ ] Base = `upstream/develop` for dxrp; read-only; no checkout/push/PR.
- [ ] Output confined to `allowedOutputTypes`; `forbiddenScope` respected.
- [ ] `requiresMaintainerApproval` enforced (default true for dxrp implementation-adjacent).
- [ ] No private LIFEPUNCH assumptions applied to upstream code.

## §23 BLOODWAVE MUST RESOLVE (added to v1 §23)

8. **Provision a Green `dxrp-public` clone** at the registry path with `origin=mragerlp/dxrp-public` + `upstream=dxura/dxrp` (worker won't auto-clone in v1).
9. **Confirm profile registry paths** (Green `C:\Projects\lifepunch` and `C:\Projects\dxrp-public`).
10. **Confirm `requiresMaintainerApproval` default = true** for all `dxrp-official` implementation-adjacent tasks, and that Slice 5 patch mode for dxrp additionally needs a maintainer-approval GO flag.

---

_End of artifact. Opus v2 is authoritative. No implementation performed._
