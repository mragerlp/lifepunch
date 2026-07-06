# Cornerman Drop Worker — Slice 3 operator workflow test report (2026-07-06)

**Slice:** 3 — manual operator workflow polish (helpers only; worker unchanged)
**Baseline:** `4009f7c feat(cornerman): add local model report generation`
**Node:** Red (VENGEANCE), scratch dirs under `%TEMP%`; one cheap live SSH transport
check against Green (scratch inbox only — real inbox untouched)
**Harness:** `%TEMP%\cdw-slice3\Run-CdwSlice3Tests.ps1` (not committed; scratch-only)
**Result:** **61 / 61 PASS** (local matrix) + **live Green transport PASS**

---

## 1. What Slice 3 shipped

Five operator helpers in `lifepunch/scripts/cornerman/` plus a runbook section.
The worker (`Invoke-CornermanDropWorker.ps1`) and library were **not modified**.

| Helper | Node | Role |
|---|---|---|
| `New-CornermanTaskPacket.ps1` | Red | Build a schema-valid v2 packet from parameters (safe defaults) |
| `Send-CornermanTaskPacket.ps1` | Red | Drop ONE packet into the Green inbox (ssh base64-chunk transport, SHA256-verified) or a local inbox |
| `Invoke-CornermanWorkerOnce.ps1` | Green | Run the worker exactly once; print where ack/report/meta/history landed |
| `Get-CornermanLatestReport.ps1` | Green | Read-only status: latest (or specific) task's ack, meta summary, artifacts |
| `Test-CornermanWorkerConfig.ps1` | Green | Offline deployment validation (files, folders, registry, model config) — zero HTTP |

---

## 2. Test matrix (61 cases, all PASS)

### Group A — `New-CornermanTaskPacket` (16)

| Case | Expectation | Result |
|---|---|---|
| A1 | Default packet: helper exits 0, file written | PASS |
| A1 | Packet independently passes worker `Test-CdwPacketSchema` | PASS |
| A1 | **No `modelCall` object** on default packets | PASS |
| A1 | Default packets carry `constraints.noModelCall=true` | PASS |
| A1 | `mode=report`; **no `commit` / `pr` authority fields ever** | PASS (3 checks) |
| A1 | `noCommit/noPush/noPatch/noScheduler` all true | PASS |
| A1 | Profile-derived routing (`LifePunch`/`origin`/`main`) | PASS |
| A2 | `-RequestModelCall` -> `modelCall.enabled=true`, no contradicting constraint, schema-valid | PASS (3 checks) |
| A3 | `-NoModelCall` -> `constraints.noModelCall=true` preserved | PASS |
| A4 | `-RequestModelCall` + `-NoModelCall` contradiction refused (exit != 0) | PASS |
| A5 | Unknown `repoProfile` rejected (ValidateSet) | PASS |
| A6 | Unknown `routeTag` rejected (ValidateSet) | PASS |
| A7 | `AUTO OK` + model call refused (never routable to Green) | PASS |
| A8 | Absolute input path refused | PASS |
| A9 | dxrp-official + `lifepunch/**` input refused | PASS |
| A10 | No `readFiles`/`readGlobs` refused | PASS |
| A11 | dxrp-official law defaults (`upstream`/`develop`/`DXRP`/maintainer approval) + schema-valid | PASS (2 checks) |

### Group B — `Send-CornermanTaskPacket` local mode (8)

| Case | Expectation | Result |
|---|---|---|
| B1 | Missing packet file refused | PASS |
| B2 | Non `task-*.json` filename refused | PASS |
| B3 | Packet id / filename mismatch refused | PASS |
| B4 | Schema-invalid packet refused (never forwards a fail-closed packet) | PASS |
| B5 | Happy path: lands in inbox, SHA256 printed | PASS |
| B6 | Duplicate inbox name refused without `-Force` | PASS |
| B7 | `-Force` overwrite allowed | PASS |
| B8 | Send created **no outbox** (never runs the worker) | PASS |

### Group D — `Invoke-CornermanWorkerOnce` (12)

Scratch git clone (clean, `origin` = `mragerlp/lifepunch` slug) + scratch registry + BaseDir.

| Case | Expectation | Result |
|---|---|---|
| D0 | Static scan: wrapper source has **no scheduler commands** (`schtasks`, `Register-ScheduledTask`) and **no while loop** | PASS (2 checks) |
| D1 | Two packets waiting; one run consumes **exactly one** (no loop) | PASS (3 checks) |
| D1 | Wrapper prints ack line, meta path, history path, lock release | PASS (4 checks) |
| D1 | `modelCallEnabled=False` by default (switch is explicit passthrough only) | PASS |
| D2 | Second run consumes the remaining packet; third reports `IDLE`, nothing landed | PASS (2 checks) |
| D3 | Both dry-runs acked ok; meta `dryRun=true` (zero HTTP in the whole matrix) | PASS (3 checks) |

### Group E — `Get-CornermanLatestReport` (5)

| Case | Expectation | Result |
|---|---|---|
| E1 | Empty BaseDir -> "No runs recorded", exit 0 | PASS |
| E2 | Latest run summarized (`status: dry-run-ok`) | PASS (2 checks) |
| E3 | Specific `-TaskId` + `-ShowContent` body preview | PASS |
| E4 | Byte-identical outbox before/after — **mutates nothing** | PASS |

### Group F — `Test-CornermanWorkerConfig` (6)

| Case | Expectation | Result |
|---|---|---|
| F1 | Good scratch deployment -> `RESULT: PASS`, exit 0 | PASS |
| F2 | Missing registry -> FAIL | PASS |
| F3 | Non-localhost chat endpoint -> FAIL | PASS |
| F4 | `AUTO OK` present in routes -> FAIL | PASS |
| F5 | Empty `GREEN CODE REQUIRED` route -> FAIL | PASS |
| F6 | Offline: no probe attempted (config check performs zero HTTP) | PASS |

### Group G — repo scope guard (2)

| Case | Expectation | Result |
|---|---|---|
| G1 | `git status --porcelain` shows only the 7 allowed Slice 3 paths | PASS |
| G1 | No `lifepunchaddons/**`, `lifepunchdxrp/**`, `.cs`, `.razor`, `.scss` touched | PASS |

---

## 3. Live Green transport check — PASS (2026-07-06)

Cheap SSH-only check of the send helper's remote path, against a **scratch** inbox
(`C:\lifepunch\cornerman\smoke\s3-inbox`) so the real inbox was never touched:

1. Green reachable (`ssh cornerman hostname` -> `Cornerman`).
2. `Send-CornermanTaskPacket.ps1` dropped the A1 test packet via base64-chunked ssh
   exec — remote SHA256 `D7D9D527…` matched local, `OK … (verified)`, exit 0.
3. Duplicate send refused with `packet already in Green inbox (use -Force …)`, exit 1.
4. Scratch inbox removed; real inbox confirmed empty afterwards
   (`REAL-INBOX-COUNT=0`). No worker run was triggered on Green.

No LM Studio call was made (Slice 3 is operator workflow, not model quality).

---

## 4. Honesty notes

- The harness lives in `%TEMP%` and is scratch-only; the numbers above are from run
  `cdw-slice3-run-055220` (61 passed, 0 failed, exit 0).
- One harness-side expectation was corrected during testing (E2 asserted meta status
  `ok`; the worker writes `dry-run-ok`). Helper behavior was correct; only the test
  expectation changed.
- The one-shot runner's "no loop" claim is proven both statically (source scan) and
  behaviorally (two queued packets, one consumed per invocation).
- `Get-CornermanLatestReport` / `Test-CornermanWorkerConfig` read-only claims are
  proven by before/after file snapshots and by design (no write calls); the config
  checker deliberately performs no HTTP, so endpoint **liveness** is only proven by
  an actual worker run.
- The remote send path was live-proven against Green; the `-LocalInboxPath` mode
  covers nodes without SSH. Worker/lib code was not modified in this slice, so all
  Slice 1/2 worker guarantees stand on their existing evidence
  (`CORNERMAN_DROP_WORKER_SLICE2_TEST_REPORT_2026-07-06.md`).

---

## 5. Files changed in this slice

```text
lifepunch/scripts/cornerman/New-CornermanTaskPacket.ps1        (new)
lifepunch/scripts/cornerman/Send-CornermanTaskPacket.ps1       (new)
lifepunch/scripts/cornerman/Invoke-CornermanWorkerOnce.ps1     (new)
lifepunch/scripts/cornerman/Get-CornermanLatestReport.ps1      (new)
lifepunch/scripts/cornerman/Test-CornermanWorkerConfig.ps1     (new)
lifepunch/docs/CORNERMAN_HEADLESS_DROP_WORKER.md               (Slice 3 operator section)
lifepunch/docs/handoff/CORNERMAN_DROP_WORKER_SLICE3_OPERATOR_WORKFLOW_TEST_REPORT_2026-07-06.md (this file)
```

No commit or push performed. Recommended commit message:
`feat(cornerman): add manual worker operator helpers`
