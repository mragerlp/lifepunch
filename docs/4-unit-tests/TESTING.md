# Testing Guidelines - LIFEPUNCH

> Adapted from the calibrated TRIP testing gate in [`ARCHI.md`](../../ARCHI.md)
> §"TRIP testing gate (calibrated 2026-07-14)". Subordinate to `CLAUDE.md`; on any
> conflict, `CLAUDE.md` and `lifepunch/docs/cvl/` win and this file is the defect.
> **Sensor Law applies** - a green gate is a floor, not a substitute for the sensor a
> claim requires.

## Test Framework

LIFEPUNCH is an s&box (Source 2) monorepo; there is no single classic unit-test
runner. Verification is **gate-based** across four surfaces:

- **UI lint** - PowerShell validator over Razor/SCSS.
- **Typecheck** - s&box editor compile via the Claude Bridge MCP (`get_compile_errors`).
- **Focused test harness** - the specific harness named in the active plan's Test
  Impact / round report.
- **Play proof** - in-editor playtest on flatgrass when gameplay or UI changed.

## Running Tests (the gate floors)

From repo root (PowerShell):

| Gate | Command / sensor |
|------|------------------|
| Lint (UI) | `powershell -NoProfile -File lifepunchaddons\scripts\Validate-SboxRazorScss.ps1` |
| Lint (layout) | `validate-layout.ps1` - only when package layout touched; scope failures to the active slice |
| Typecheck | Editor MCP `get_compile_errors` / `code_get_compile_errors` = 0 CS/RZ/failed (or n/a if docs-only) |
| Test | Focused harness named in the plan's Test Impact / round report (pass count is the sensor) |
| Play proof | Flatgrass / `lp_map_flatgrass` when Hub/Terminal/Rack gameplay or UI changed |

## Test Organization

- No fixed `tests/` tree. Verification assets attach to the slice that needs them; the
  plan's Test Impact section names the harness for that slice.
- Editor-side truth compiles from a **hand-synced copy** under `D:\Steam\...\dxrp\game`,
  **NOT** this repo. Sync via `lifepunch/scripts/Sync-LifePunchAddonsToDxrp.ps1`
  (`-WhatIf` first). Editing the repo and hotloading without syncing gives a FALSE
  all-clear.

## Writing Tests / Verification

- Every behavioral claim carries its sensor. A **FRESH** assertion needs the
  compile/parser log to POSTDATE the file write, plus a positive code-string ID proving
  the compiler read the new bytes.
- When no sensor reads the thing under test, **build one**. A behavioral change only the
  new code could produce is itself a positive ID.
- Prefer editor MCP `get_compile_errors` + a targeted `Log`/TailBox string over "it
  should compile."

## Coverage Requirements

Not defined as a numeric threshold. The bar is: the gate floors above are green for the
touched surface, and each claim in the round report carries a verifiable sensor.
