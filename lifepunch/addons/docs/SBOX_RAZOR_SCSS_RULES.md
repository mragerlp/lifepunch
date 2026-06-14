# s&box Razor SCSS rules (LifePunch UI)

**One invalid property fails the entire `.razor.scss` file.** Symptom: panel title bar renders, body is empty/unstyled (e.g. GATEKEEPER with no numpad).

Log signal: `D:\Steam\steamapps\common\sbox\logs\sbox-dev.log` → `not valid with`.

**Engine context:** `SBOX_ENGINE_PATCHES.md` — patch log + regression gate when s&box updates.

---

## Forbidden

| Property | Bad values | Use instead |
|----------|------------|-------------|
| `display` | `block`, `none`, `inline`, `inline-block` | `flex` only; hide with Razor `@if`, not CSS |
| `box-sizing` | any | Remove — not supported |
| `max-height` | `none` | Omit or use `%` / `px` |
| `background` / `background-image` | `linear-gradient`, `repeating-linear-gradient`, `radial-gradient` | `background-color: rgba(...)` |
| `word-break` | `break-word` | `white-space: pre-wrap` on log lines only |

## Risky (avoid unless verified in editor)

- `transition`, `transform` — may fail parser; prefer static styles
- `position: absolute` stacks for PIN UI — prefer flex `pin-stage` centering (see `HackerServerRackMenu.razor.scss`)

## Required patterns

1. **Root selector:** class on `<root class="...">`, not uppercase component type selector (razor_lint).
2. **Layout:** `display: flex` + `flex-direction` + `flex-grow` / `flex-shrink` / `min-height: 0` on scroll regions.
3. **PIN gate:** single `.pin-stage` flex center — do not reintroduce `pin-ghost` / `pin-ghost-veil` overlay stack.
4. **Power row:** `.rail-actions { flex-direction: row }` + `.rail-btn.power-on/off { flex: 1; font-size: 8–9px }`.

## Reference UIs (known-good flex SCSS)

| Panel | Path |
|-------|------|
| LIFEPUNCH ULX (ships) | `adminmenu/StaffMenu.razor.scss` — `.lifepunchulx` root |
| Hacker rack PIN | `hackerjob/HackerServerRackMenu.razor.scss` — `.pin-stage` (⚠️ migrate type selector to class root) |
| Shared footer | `LifePunchUiFooter.razor.scss` |

## Validate before playtest

```powershell
powershell -File lifepunch\addons\scripts\Validate-SboxRazorScss.ps1
```

## After SCSS edits

1. `Sync-LifePunchAddonsToDxrp.ps1 -Addon <ident>`
2. **Stop play → Play** (close panel alone does not recompile SCSS)
3. Grep log: no `not valid with` for your file
