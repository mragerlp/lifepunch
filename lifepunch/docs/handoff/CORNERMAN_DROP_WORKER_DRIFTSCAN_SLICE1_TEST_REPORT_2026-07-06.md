# Cornerman drop worker — Drift-scanner Slice 1 (Part A) test evidence

**Date:** 2026-07-06
**Scope:** Part A — activate `inputs.requiredDocs` as a canon/reference loader, packed separately from the `readFiles`/`readGlobs` drift targets. Reopens the Drop-Worker roadmap (closed at Slice 3) under explicit Bloodwave GO. Narrow scope: the canon-loading path only.
**Code under test:**
- `lifepunch/scripts/cornerman/CornermanDropWorker.Lib.ps1` (`Get-CdwPackedInputs`, `Build-CdwModelRequest`, `Test-CdwInputPaths`, `Invoke-CdwInputContentScan`)
- `lifepunch/scripts/cornerman/Invoke-CornermanDropWorker.ps1` (orchestrator pass-through)
- `lifepunch/scripts/cornerman/New-CornermanTaskPacket.ps1` (`-RequiredDocs`)
**Harness:** `lifepunch/scripts/cornerman/Test-CdwRequiredDocs.ps1` (fixture-based, no live model — mirrors the Slice 1–3 dry-run style).

---

## Result: 28 / 28 PASS (C10 deferred)

All 10 A9 cases green. The 4 safety-critical cases (3, 4, 7, 8) all pass.

| Case | What it proves | Result |
|---|---|---|
| C1 | Canon and drift packed with distinct delimiters (`=== CANON/REFERENCE:` vs `=== FILE:`); canon precedes drift in the prompt; canon system line present | PASS (6 asserts) |
| C2 | `requiredDocs` bytes count toward `inputs.maxBytes`; over-cap fails closed naming requiredDocs | PASS (2) |
| **C3 (safety)** | Combined canon + drift over `maxPromptChars` (120k) **fails closed, content not truncated** | PASS (3) |
| **C4 (safety)** | `requiredDocs` path safety identical to `readFiles`: absolute / `..` / **dxrp-official forbid-prefix rejected** — closes the private-canon smuggle hole | PASS (3) |
| C5 | Missing canon file fails closed (`required canon doc not found in clone`) | PASS (2) |
| **C7 (safety)** | No `requiredDocs` ⇒ **prompt tail byte-identical** to pre-change (plain `INPUT FILES:` + packed; no canon header/system line) | PASS (5) |
| **C8 (safety)** | dxrp-official `requiredDocs` **contents scanned** by the no-IP scan; blocked token in canon flagged | PASS (3) |
| C6 | `requiredDocs` alone (no `readFiles`/`readGlobs`) rejected — `anyOf` invariant preserved | PASS (1) |
| C9 | `New-CornermanTaskPacket -RequiredDocs` emits `inputs.requiredDocs`, passes schema, stays `mode:report` / `noPatch` | PASS (3) |
| C10 | Live `qwen/qwen3.6-27b` audit run | **SKIP — deferred to Part B (separate GO)** |

Reproduce: `powershell -NoProfile -ExecutionPolicy Bypass -File lifepunch\scripts\cornerman\Test-CdwRequiredDocs.ps1`

---

## Safety envelope — unchanged

The change touches only input path-validation, input packing, and prompt assembly. `requiredDocs` receive **byte-identical treatment to `readFiles`** for both path-safety (`Test-CdwInputPaths`) and content-scan (`Invoke-CdwInputContentScan`). No edits to:
- git read-only enforcement (`git remote get-url` / `status --porcelain` / `rev-parse --verify` only)
- localhost-only enforcement (`Test-CdwModelEndpointLocal`)
- double opt-in (`Test-CdwModelCallPolicy`: `-EnableModelCall` + `modelCall.enabled`)
- no-patch / no-mutation (`mode:candidate-patch` still rejected; no diff/patch code)
- pre-HTTP gate order (canon packs in gate 10, before any HTTP) and fail-closed-over-cap

Schema unchanged: `inputs.requiredDocs` was already declared; the `anyOf` still requires `readFiles` OR `readGlobs`.

**Cornerman's eyes are covered** — these are validation-harness results on temp fixture files. No runtime, editor, or playtest claim is made. Part B (the first live `27b` audit) is a separate GO.
