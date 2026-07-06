# Cornerman drop worker — Slice 2 test evidence (model call)

**Date:** 2026-07-06
**Scope:** Slice 2 — opt-in local model call + real report generation for the headless drop worker
**Code under test:**
- `lifepunch/scripts/cornerman/CornermanDropWorker.Lib.ps1`
- `lifepunch/scripts/cornerman/Invoke-CornermanDropWorker.ps1`

**Plan under test:** `lifepunch/docs/handoff/CORNERMAN_DROP_WORKER_SLICE2_MODEL_CALL_PLAN_2026-07-06.md` (Codex PASS)
**Related:** Slice 1 evidence — `CORNERMAN_DROP_WORKER_SLICE1_TEST_REPORT_2026-07-06.md`

---

## 1. Test environment

- **Node:** VENGEANCE (Windows PowerShell 5.1) — scratch dirs only, real repos never touched.
- **Harness:** `%TEMP%\cdw-slice2\Run-CdwSlice2Tests.ps1` (not committed; test scaffolding).
- **Mock endpoint:** `System.Net.HttpListener` on `http://127.0.0.1:18321/` running in a
  runspace thread inside the harness process. It implements `/v1/models` and
  `/v1/chat/completions` (OpenAI-compatible shapes) and **counts every incoming HTTP
  request**. Behavior per test case is switched via a mode file (happy markdown, partial
  sections, no sections, valid JSON, fenced JSON, non-JSON, plain text, whitespace,
  IP-blocked output, 8-second delay, garbage HTTP body, missing model).
- **Zero-HTTP assertion:** each case records the mock's request counter before/after the
  worker run and asserts the exact delta (`0` for every fail-closed/dry-run case, `1` for
  probe-only failures, `2` for probe + chat on full model runs).
- **Fixtures:** scratch git repos with correct/wrong remotes, a dirty clone, committed
  input docs (including a nested `docs/sub/gamma.md` glob target and a glob-reachable
  dxrp file containing `LIFEPUNCH™`), plus four model configs (mock, dead port,
  non-localhost `192.168.1.50`, 3-second timeout).

**Result: 49 / 49 PASS** (33 total HTTP requests observed across the entire run, all
from the intended model-run cases).

---

## 2. Group A — policy + zero-HTTP hard gates (17 cases)

| # | Case | Expected | HTTP | Result |
|---|---|---|---|---|
| A1 | Legacy Slice 1 packet (no `modelCall`), no switch | dry-run-ok | 0 | PASS |
| A2 | Legacy packet **with** `-EnableModelCall` | dry-run-ok (packet choice noted in report) | 0 | PASS |
| A3 | `constraints.noModelCall: true` alone, switch on | dry-run-ok | 0 | PASS |
| A4 | `modelCall.enabled: true` **without** switch | failed, stage `model-call-requested-but-worker-not-enabled` | 0 | PASS |
| A5 | `enabled: true` + `noModelCall: true` + switch | failed, stage `packet-self-contradiction` | 0 | PASS |
| A6 | Invalid packet JSON (switch on) | failed | 0 | PASS |
| A7 | Unknown `repoProfile` (opted in + switch) | failed | 0 | PASS |
| A8 | Wrong git remotes (opted in + switch) | failed | 0 | PASS |
| A9 | Dirty clone (opted in + switch) | failed | 0 | PASS |
| A10 | dxrp packet reading `lifepunch/**` (opted in) | failed (forbidden prefix) | 0 | PASS |
| A11 | Unsupported `deliverable.format: html` | failed at schema | 0 | PASS |
| A12 | `requiredModel` disagrees with routed model | failed, stage `model-route-conflict` | 0 | PASS |
| A13 | `routeTag: AUTO OK` on a model run | failed (not routed on Green) | 0 | PASS |
| A14 | Non-localhost endpoint config (`192.168.1.50`) | failed, stage `endpoint-not-localhost` | 0 | PASS |
| A15 | Combined readFiles + expanded globs over `maxBytes` | failed pre-call | 0 | PASS |
| A16 | `-StaleLockMinutes 1` below 60s call timeout | failed pre-call (lock guard) | 0 | PASS |
| A17 | dxrp glob-expanded cited input contains `LIFEPUNCH™` | failed (cited input scan, glob-expanded file named) | 0 | PASS |

Every hard gate fails closed **before any HTTP request, including the `/v1/models`
probe** — verified by the mock's request counter, not by log inspection.

---

## 3. Group B — model call + format-aware output validation (18 checks)

| # | Case | Expected | HTTP | Result |
|---|---|---|---|---|
| B1 | Happy markdown run (`expectedSections: Scope, Findings`) | ok, `report.md` with both sections | 2 | PASS |
| B1meta | `meta.json` model block: `modelId`, `finishReason=stop`, opt-in flags, `dryRun=false` | — | — | PASS |
| B2 | `GREEN CODE REQUIRED` route | ok | 2 | PASS |
| B2meta | routed to coder model (`qwen2.5-coder-32b-instruct`) | — | — | PASS |
| B3 | `requiredModel` agreeing with route | ok | 2 | PASS |
| B4 | `allowFallback: true` (model present) | ok | 2 | PASS |
| B4meta | fallback-ignored warning recorded in meta | — | — | PASS |
| B5 | Routed model missing from `/v1/models` (fallback still ignored) | failed, stage `model-unavailable`, **probe only** | 1 | PASS |
| B6 | Endpoint down (dead port) | failed, stage `endpoint-down` | 0 (mock) | PASS |
| B7 | **JSON deliverable: valid JSON with zero markdown headings passes** | ok, `report.json` | 2 | PASS |
| B8 | JSON deliverable: output wrapped in one code fence passes, fence stripped | ok, `report.json` without fences | 2 | PASS |
| B9 | **JSON deliverable: prose output fails** | failed, stage `model-invalid` | 2 | PASS |
| B10 | Text deliverable: plain paragraph passes | ok, `report.txt` | 2 | PASS |
| B11 | **Whitespace-only output fails** | failed, stage `model-empty` | 2 | PASS |
| B12 | Markdown with 1 of 2 expected sections | ok + warning | 2 | PASS |
| B12meta | `missingExpectedSections: [Findings]` in meta | — | — | PASS |
| B13 | Markdown with **all** expected sections missing | failed, stage `model-invalid` | 2 | PASS |
| B14 | dxrp output containing `LifePunch` | failed, stage `output-scan-blocked` | 2 | PASS |
| B14b | Blocked generated text **not persisted** in `error.md` (token names only) | — | — | PASS |
| B15 | dxrp clean model run | ok | 2 | PASS |
| B15meta | `outputScan=pass` + `inputContentScan=pass` in meta | — | — | PASS |
| B16 | Mock delays 8s vs 3s `callTimeoutSec` | failed, stage `model-timeout` | 2 | PASS |
| B17 | Endpoint returns garbage (non-JSON HTTP body) | failed, stage `model-invalid` | 2 | PASS |
| B18 | `readGlobs: docs/**/*.md` on a model run | ok | 2 | PASS |
| B18meta | nested `docs/sub/gamma.md` in `globExpandedFiles` **and** `inputFilesPacked` | — | — | PASS |

---

## 4. Group C — Slice 1 regression on the updated worker (7 cases)

| # | Case | Result |
|---|---|---|
| C1 | `mode: candidate-patch` still rejected | PASS |
| C2 | `proof.required` → checklist only, "NOT a proof claim" / "eyes are covered", no proof-passed wording | PASS |
| C3 | `commit.allowed: false` → "Commit: FORBIDDEN", suggestion suppressed | PASS |
| C4 | dxrp dry-run cited-input scan (now labeled "readFiles + expanded globs") | PASS |
| C5 | Absolute input path rejected | PASS |
| C6 | `..` traversal rejected | PASS |
| C7 | dxrp `contextNotes` containing `LIFEPUNCH™` fails dry-run scan | PASS |

All dry-run C-group cases observed **0** HTTP requests.

---

## 5. Sample evidence

**B1 `meta.json` model block (mock endpoint):**

```json
"model": {
  "endpoint": "http://127.0.0.1:18321/v1/chat/completions",
  "requestedRoute": "GREEN DEEP REQUIRED",
  "modelId": "qwen/qwen3.6-35b-a3b",
  "probeOk": true,
  "callStartedUtc": "2026-07-06T08:39:09.1057727Z",
  "callFinishedUtc": "2026-07-06T08:39:09.1268400Z",
  "promptChars": 287,
  "inputFilesPacked": ["docs/alpha.md"],
  "finishReason": "stop",
  "outputChars": 86
}
```

**B14 `error.md` (blocked output — note only token names, never the generated text):**

```
# TASK FAILED - task-20260706-000030-dxrp-blocked-out

failureStage: output-scan-blocked

- output scan blocked generated text: blocked (private brand): LifePunch
- output scan blocked generated text: blocked (private identifier/path/header): LIFEPUNCH PRIVATE
```

**B8 `report.json` (fence stripped, valid JSON persisted):**

```json
{"result":"ok","fenced":true}
```

---

## 6. Live LM Studio smoke — PASS (Green, 2026-07-06)

Green came back online later the same day and the live smoke was run per the Codex-B
temporary-deployment path: the six changed Slice 2 files were packaged from Red,
transferred to Green (SHA256-verified), overlaid onto a **temp clone** at
`C:\lifepunch\cornerman\smoke\s2-20260706-045954\lp` (`git diff --name-only` on the temp
clone showed exactly the four modified + two new Slice 2 files, nothing else), and one
smoke was run from a scratch `BaseDir` — no scheduler, no loop, one packet.

**Setup:**

- Endpoint probe `http://127.0.0.1:1234/v1/models` → OK; loaded models:
  `qwen/qwen3.6-27b`, `qwen/qwen3.6-35b-a3b`, `qwen2.5-coder-32b-instruct`,
  `text-embedding-nomic-embed-text-v1.5`
- Packet: `task-20260706-051500-slice2-live-smoke` — `repoProfile: lifepunch-private`,
  `routeTag: GREEN DEEP REQUIRED`, `"modelCall": { "enabled": true }`, format `markdown`,
  one cited input (`lifepunch/docs/CORNERMAN_HEADLESS_DROP_WORKER.md`)
- Worker: temp-repo `Invoke-CornermanDropWorker.ps1` with `-EnableModelCall` and
  `-ModelConfigPath` pointed at the temp-repo `cornerman-model-endpoints.example.json`;
  live registry `C:\lifepunch\cornerman\config\repo-profiles.json`; real Green clone clean

**Result: PASS.**

| Check | Result |
| --- | --- |
| Probe `/v1/models` | OK (`probeOk: true`) |
| Routed model | `qwen/qwen3.6-35b-a3b` (exact match, no substitution) |
| Chat call | OK, `finishReason: stop`, 193.9 s |
| Prompt / output size | 9,735 prompt chars / 2,652 output chars |
| Report | `report.md` written; both expected sections (`Scope`, `Findings`) present, `missingExpectedSections: []` |
| meta.json | `status: ok`, `dryRun: false`, `slice: 2`, full `model` block recorded |
| Ack | `workflow-ack.ndjson` → `ok: true`, "model report generated (qwen/qwen3.6-35b-a3b)" |
| History | `task-20260706-051500-slice2-live-smoke.ok.json` |
| Lock | released (no `worker.lock` left behind) |
| Worker exit code | 0 |

The generated report was a faithful distill of the runbook (it described the worker as
offline/dry-run because cited inputs are read from the registered `lifepunch-private`
clone `C:\Projects\lifepunch`, whose HEAD still predated the Slice 2 doc update —
expected and correct source-of-truth behavior).
The temp Green copy was discarded after evidence capture. No Green commit, no Green push.

## 7. Honesty notes

- All Group A/B/C results are from the **mock endpoint** on VENGEANCE. Real model
  inference was exercised once in the §6 live Green smoke (`qwen/qwen3.6-35b-a3b`,
  markdown deliverable, happy path only); all failure-path behavior is proven via
  mocks only.
- The harness asserts HTTP counts via the mock's own request counter, which cannot see
  requests to *other* hosts. The localhost-only code gate (A14) plus endpoint config
  under test being pointed exclusively at the mock/dead ports is the containment
  argument for "zero egress".
- `durationSeconds` shows `0` in mock evidence because the mock responds in
  milliseconds; the rounding is to 0.1s.
- Cornerman eyes are covered: nothing here claims runtime/editor/game proof.
