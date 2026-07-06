# Cornerman drop worker — Slice 1 test evidence report

**Date:** 2026-07-06 (post-Codex-revise re-run)
**Scope:** Slice 1 dry-run worker only — docs + schema v2 + dry-run validation/report
**Design law:** `handoff/CORNERMAN_HEADLESS_DROP_WORKER_OPUS_V2_PLAN_2026-07-06.md` (Part B authoritative)
**Runbook:** `lifepunch/docs/CORNERMAN_HEADLESS_DROP_WORKER.md`

---

## 1. Summary

- **28/28 dry-run checks passed** (original 24 + 4 new cited-input-content-scan checks
  added after Codex REVISE; every original check was re-run in the same suite, none skipped).
- PowerShell parser validation: **both scripts parse clean** (`CornermanDropWorker.Lib.ps1`,
  `Invoke-CornermanDropWorker.ps1`) via `[System.Management.Automation.Language.Parser]::ParseFile`.
- All three JSON files parse clean (`cornerman-task-packet.schema.json`,
  `cornerman-task-packet.example.json`, `cornerman-repo-profiles.example.json`).
- **No live repo mutation.** All tests ran against scratch temp dirs and fixture git repos.
- Lock behavior (live-lock skip, stale-lock reclaim, `finally` release) verified live
  against the revised worker.

## 2. Test environment

| Item | Value |
|---|---|
| Repo path | `C:\Users\jared\Projects\lifepunch` |
| Branch | `develop` |
| Scratch temp root | `%TEMP%\cdw-slice1\` (`run\base` = worker BaseDir; `run\repos` = fixture git repos; `run\packets` = generated test packets) |
| Fixture repos | Fresh `git init` scratch repos with fabricated remotes (`mragerlp/lifepunch`, `mragerlp/dxrp-public` + `dxura/dxrp`, wrong-remote, dirty-with-untracked). Fixture input files were committed **inside the scratch dxrp repo only**. |
| Live repos untouched | `lifepunch` (this worktree — only Slice 1 files changed by implementation, none by tests), `lifepunchaddons/**`, `lifepunchdxrp/**`, and `C:\Users\jared\Projects\dxrp-public` were **not read from or written to** by any test. Worker performs no git mutation by design (read-only `git remote get-url` / `status --porcelain` / `rev-parse --verify` on fixture repos only). |

**Commands used:**

```powershell
# Parser validation (per script)
[System.Management.Automation.Language.Parser]::ParseFile(<script>, [ref]$tokens, [ref]$errors)

# JSON validation (per file)
Get-Content <file> -Raw | ConvertFrom-Json

# Full harness (creates scratch dirs, fixture repos, packets; runs worker per packet)
powershell -NoProfile -File "$env:TEMP\cdw-slice1\Run-CdwSlice1Tests.ps1"

# Lock behavior (manual, against revised worker)
# 1) live lock file with current pid  -> expect SKIP
# 2) stale lock file with dead pid    -> expect reclaim + IDLE
# 3) confirm lock absent after run    -> expect True
```

## 3. Test matrix (28 checks — all re-run 2026-07-06, all PASS)

| # | Check | Result |
|---|---|---|
| T1 | Valid `lifepunch-private` packet passes dry-run validation | PASS |
| T2 | Valid `dxrp-official` packet passes dry-run validation | PASS |
| T3 | Unknown `repoProfile` fails | PASS |
| T4 | Missing Green clone fails closed | PASS |
| T5 | Wrong remotes fail closed | PASS |
| T6 | Dirty resolved clone fails closed (untracked = dirty) | PASS |
| T7 | Absolute input path fails | PASS |
| T8 | `..` path traversal fails | PASS |
| T9 | `dxrp-official` reading `lifepunch/**` fails | PASS |
| T10a | Allowlist: `mragerlp/dxrp-public` allowed | PASS |
| T10b | Allowlist: `github.com/mragerlp/dxrp-public` allowed | PASS |
| T10c | Allowlist: `mragerlp-party-browse` allowed | PASS |
| T10d | Allowlist: `mragerlp <mragerlp@gmail.com>` allowed | PASS |
| T11a | Blocklist: `LIFEPUNCH™` blocked | PASS |
| T11b | Blocklist: `C:\Users\jared\Projects\lifepunch` blocked | PASS |
| T11c | Blocklist: `lifepunchaddons/` blocked | PASS |
| T11d | Blocklist: `PROPRIETARY` blocked | PASS |
| T12a | Trailer: `Co-authored-by: Cursor <cursoragent@cursor.com>` blocked | PASS |
| T12b | Trailer: `Generated-by:` blocked | PASS |
| T12c | Trailer: `Assisted-by:` blocked | PASS |
| T12e | End-to-end: dxrp-official packet with LIFEPUNCH™ in task text fails scan | PASS |
| T16a | **Cited input scan:** clean dxrp input file passes (report shows `PASS (1 file(s) scanned)` + file listed) | PASS |
| T16b | **Cited input scan:** dxrp input file containing `LIFEPUNCH™` fails (error.md names file + blocked token) | PASS |
| T16c | **Cited input scan:** dxrp input file containing `Co-authored-by: Cursor <cursoragent@cursor.com>` fails | PASS |
| T16d | **Cited input scan:** `meta.json` carries `inputContentScan: pass` + `scannedInputFiles` list | PASS |
| T13 | `mode: candidate-patch` rejected in Slice 1 | PASS |
| T14 | `proof.required=true` produces checklist-only behavior, not a proof claim | PASS |
| T15 | `commit.allowed=false` prevents commit instructions (report states commit forbidden; suggestion suppressed) | PASS |

**Lock behavior (verified live, outside the numbered matrix):**

| Check | Result |
|---|---|
| Live lock held by running pid → worker exits `SKIP` | PASS |
| Stale lock (dead pid / old timestamp) → reclaimed, run proceeds (`IDLE` on empty inbox) | PASS |
| Lock file absent after run (`finally` release) | PASS |

**Sample failure evidence (T16b `error.md` + `meta.json` excerpts):**

```text
# TASK FAILED (dry-run) - task-20260706-000012-dxrp-input-ip
- no-IP/trailer scan: cited input 'Code/notes-ip.md': blocked (private brand): LIFEPUNCH
```

```json
"scannedInputFiles": ["Code/notes-ip.md"],
"inputContentScan": "fail",
"status": "failed"
```

## 4. Honesty notes

- `readGlobs` are shape-validated only in Slice 1 (no glob expansion). Their content is
  **not** scanned, and the worker says so explicitly — a warning is written to the report
  and `meta.json` whenever a dxrp-official packet carries `readGlobs`. Glob expansion +
  content scan over expanded results lands with the model-call slice.
- Only cited files (`inputs.readFiles`) are loaded and scanned — the worker never scans
  the whole repo.
- Test totals: the original suite was 24 checks; the Codex revise added T16a–T16d,
  bringing the suite to **28**. All 28 ran in a single fresh harness execution; nothing
  was carried forward from the earlier run.

---

Cornerman's eyes are covered — these are validation-harness results on fixture repos;
no runtime, editor, or playtest claim is made.
