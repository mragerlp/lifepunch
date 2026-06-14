# Cornerman handoff — Bitcoin + Hacker menu UI fix (2026-06-13)

**Owner leaving ~5h.** VENGEANCE session regressed on **in-game menus** (empty GATEKEEPER shell). Compiler spam in console is **not** the blocker.

---

## What the owner sees (P0)

1. **Bitcoin miner hub** — `USE` opens **GATEKEEPER — SET PIN** but body is **empty** (title bar + close only).
2. **Power buttons** — should be one row: `POWER ON | POWER OFF`, compact, centered in left rail.
3. **Settings cog** — top-right next to CLOSE (hub panel + hacker server rack).
4. **Hacker server rack** — PIN gate was **missing**; code added this session but not owner-verified.

---

## Root cause (confirmed)

**s&box UI SCSS is strict.** One invalid property **fails the entire `.razor.scss` file** → panel renders unstyled (empty shell, no numpad).

### Forbidden in LifePunch `.razor.scss` (log: `X is not valid with Y`)

| Property | Invalid value | Fix |
|----------|---------------|-----|
| `max-height` | `none` | Remove; use `height: 100%` or omit |
| `box-sizing` | `border-box` | Remove (not supported) |
| `display` | `block`, `none` | Use `flex` only; hide via Razor `@if`, not CSS |
| `background` / `background-image` | `linear-gradient`, `repeating-linear-gradient` | Solid `background-color` only |
| `word-break` | `break-word` | Remove or use `white-space: pre-wrap` only |

**Grep before ship:**

```powershell
rg -n "box-sizing|display:\s*(block|none)|max-height:\s*none|linear-gradient|word-break" lifepunch/addons/Code/Addons/lifepunch/bitcoinmining lifepunch/addons/Code/Addons/lifepunch/hackerjob --glob *.scss
```

**Known still-bad (hacker CRT, not hub menu):** `HackerTerminal.razor.scss` lines ~118–129 — gradients.

---

## Compiler log owner pasted — IGNORE for menu work

- `CS8669` / `CS8603` / `CS8618` = nullable reference **warnings** on DXRP + LifePunch addons. Not compile failures.
- `CS0612` / `CS0618` = obsolete API warnings (DXRP upstream).
- Razor auto-generated `CS8669` — needs `#nullable` in generated path or ignore; **not** why PIN UI is blank.

**Real menu signal:** Console lines like `not valid with box-sizing` or `not valid with display` on `hashdterminal.razor.scss` or `hackerserverrackmenu.razor.scss`.

---

## Files touched this session (VENGEANCE / Auto)

| Area | Files |
|------|-------|
| Bitcoin PIN simplify | `bitcoinmining/HashdTerminal.razor`, `HashdTerminal.razor.scss` |
| Bitcoin dev auth | `_dev/DxrpPortalDevAuth.cs` (playtime refresh after `lp_authorize`) |
| Hacker rack PIN + UI | `hackerjob/HackerServerRackEntity.cs`, `HackerServerRackAccessPin.cs`, `HackerServerRackMenu.razor`, `HackerServerRackMenu.razor.scss` |

Sync to DXRP after edits:

```powershell
powershell -File lifepunch\scripts\Sync-LifePunchAddonsToDxrp.ps1 -Addon bitcoinmining
powershell -File lifepunch\scripts\Sync-LifePunchAddonsToDxrp.ps1 -Addon hackerjob
```

---

## Cornerman task order (~5h)

### 1. SCSS audit + green compile (1h)

- Run grep above; fix **every** hit in `HashdTerminal.razor.scss`, `HackerServerRackMenu.razor.scss`, `HackerTerminal.razor.scss`, `LifePunchUiFooter.razor.scss`.
- After sync: **Stop play → Play** (full Razor recompile). Closing panel alone is not enough.
- Confirm **zero** `not valid with` lines in `D:\Steam\steamapps\common\sbox\logs\sbox-dev.log` after opening GATEKEEPER.

### 2. Bitcoin GATEKEEPER verify (1h)

**Playtest path:** `game.scene` (not prefab tab) → `lp_map_flatgrass` → `lp_spawn_bitcoin_miner_hub` → USE hub.

**Pass:**

- Center shows **SECURE BOOT — SET PIN** CTA (amber) or numpad after click.
- 4-digit set + confirm → opens **HASHD HUB CONTROL** with rail + MODULES.
- Rail: **POWER ON | POWER OFF** side-by-side, compact.
- Title bar: **settings cog** + CLOSE on hub panel.

**Reference:** simplified PIN markup in `HashdTerminal.razor` (`pin-stage` block) — mirrors working pattern in `HackerServerRackMenu.razor`.

### 3. Hacker server rack verify (1h)

`lp_spawn` rack (see `HackerDevSpawn.cs` ConCmds) → USE rack.

**Pass:** same PIN flow; green theme; power row + cog; ACCESS: SECURED/DORMANT in rail.

### 4. Document s&box SCSS rules (30m)

Add short section to `lifepunch/addons/docs/BITCOINMINING_PLAYTEST.md` § log triage — **forbidden SCSS** list (table above). Prevents repeat.

### 5. Optional — assets (only if menus green)

Console `server-rack.vmat` / `server-rack.vmdl` missing = **ModelDoc compile** on VENGEANCE, not Cornerman code. See `hackerjob` `MODEL_BUILD.md`.

---

## Do NOT

- Chase CS86xx nullable warnings unless build actually fails.
- Re-add ghost PIN overlay (`pin-ghost` / `pin-ghost-veil`) — removed intentionally; fragile in s&box SCSS.
- Use `execute_csharp` MCP without sweeping `Editor/__Exec_*.cs` after (poisoned compile).

---

## Definition of done

1. No `not valid with` SCSS errors in log when opening bitcoin hub or hacker rack menus.
2. GATEKEEPER SET PIN shows CTA + numpad; PIN unlock opens full control panel.
3. Power buttons one row; settings cog visible on hub + server rack panels.
4. Handoff note in this file § Progress log when finished.

---

## Progress log (Cornerman fills in)

| Time | Done |
|------|------|
| | |

---

## Tier 2 — if P0 menus green (~2h left)

| # | Task | Why |
|---|------|-----|
| T2-1 | Fix `HackerTerminal.razor.scss` gradients (lines ~118–129) | CRT terminal may break same way as hub |
| T2-2 | Run `lp_hashd_pin_preview` + `lp_hashd_preview` smoke | UI-only path without world spawn |
| T2-3 | `lp_bitcoinmining_scale_audit` on flatgrass | Log bounds for hub/rack scale |
| T2-4 | Update `BITCOINMINING_PLAYTEST.md` log triage with SCSS forbidden table | Link `SBOX_RAZOR_SCSS_RULES.md` |
| T2-5 | Hacker `server-rack` asset errors — ModelDoc checklist only | `hackerjob/models/.../server-rack/MODEL_BUILD.md`; **VENGEANCE ModelDoc**, not Green |
| T2-6 | Draft `CORNERMAN_MENU_UI_AUDIT.txt` in outbox | Validator output + log grep + pass/fail matrix |

---

## Green box workflow (no Cursor / no editor)

Cornerman **cannot** see the game. Lane:

1. `git reset --hard origin/main` on Green clone (after Red pushes handoff).
2. Run `Validate-SboxRazorScss.ps1` → save output to `C:\lifepunch\cornerman\outbox\MENU_SCSS_AUDIT.txt`.
3. **WarmCoder** (`Send-CornermanWorkflow.ps1 -Action WarmCoder`) → draft fixed SCSS for flagged lines; put in `outbox/MENU_SCSS_DRAFTS/` (one file per panel).
4. Red/VENGEANCE applies drafts, syncs DXRP, playtests.

---

## VENGEANCE workflow (Cursor + editor)

1. `Validate-SboxRazorScss.ps1` until exit 0.
2. Playtest matrix below.
3. Ask owner before commit.

### Playtest matrix (copy-paste)

```text
lp_map_flatgrass
lp_spawn_bitcoin_miner_hub
USE hub → GATEKEEPER CTA → numpad → hub panel
Check: POWER ON|OFF row, settings cog, MODULES tabs

lp_hashd_pin_preview
lp_hashd_pin_preview unlock

Hacker rack: lp_spawn from HackerDevSpawn ConCmds → USE → PIN → SERVER RACK CONTROL
```

### Log grep after each open

```powershell
Select-String -Path "D:\Steam\steamapps\common\sbox\logs\sbox-dev.log" -Pattern "not valid with" | Select-Object -Last 20
```

---

## Push handoff to Green inbox (Red runs on VENGEANCE)

```powershell
powershell -File lifepunch\scripts\Push-CornermanMenuUiFix.ps1
```

Also copies `SBOX_RAZOR_SCSS_RULES.md` + directive JSON.

---

## Canonical references (do not reinvent)

| Pattern | Copy from |
|---------|-----------|
| PIN numpad + `.pin-stage` | `hackerjob/HackerServerRackMenu.razor` + `.razor.scss` |
| Settings cog + panel sizes | `bitcoinmining/HashdTerminal.razor` (head + hub cog) |
| Shipped flex panel | `adminmenu/StaffMenu.razor.scss` (`.staffmenu` root) |
| SCSS law | `addons/docs/SBOX_RAZOR_SCSS_RULES.md` |
| Validator | `addons/scripts/Validate-SboxRazorScss.ps1` |
