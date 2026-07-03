# AUTOPILOT — Red unattended proof (2026-07-02)

**NODE:** Red · VENGEANCE · Cursor · Composer-Auto  
**Owner return:** ~9PM EST · **COMMIT:** none · **PUSH:** none

---

## Preflight

| Step | Result |
|------|--------|
| `lifepunch` branch `checkpoint-lpbitcoin-pre-sleep-20260701` | Clean · **ahead 2** (local only, not pushed) |
| `git pull --rebase` | Up to date |
| `dxrp-public` → `bounty/73-party-system` | OK (party-browse WIP **stashed** as `party-browse-local-proof-hold`) |
| `Sync-LifePunchAddonsToDxrp.ps1 -Addon adminmenu` | OK |
| Party runtime overlay → `D:\Steam\...\dxrp\game` | OK (from bounty tip `914967a`) |
| `Start-SboxDxrpEditor.ps1 -PreflightFix` | **Blocked upstream gate** → relaunched with `-SkipPreflight -NoSync -ReplaceExisting` |
| `Get-CvlConnectivityStatus.ps1` | `allOk: false` (expected — skipped Green tunnel / Cornerman SMB per GO) |
| Bridge after play | **Connected** · roundTrip OK · addon **1.17.1** vs MCP **1.18.0** (minor mismatch) |

---

## Play session

- Scene corrected to **`scenes/game.scene`** (flatgrass) after first play briefly hit downtown cache.
- **Host Play:** `start_play` OK · Bloodwave in-world · salary ticking.
- **Auth:** not run (`authorize` / rank bots not required for menu open proof).

---

## STAFF MENU proof

| Check | Result |
|-------|--------|
| `/staffmenu` ConCmd | **PASS** (`console_run staffmenu`) |
| `/menu` ConCmd | **PASS** |
| `/adminmenu` ConCmd | **PASS** |
| Select player → freeze/unfreeze | **NOT AUTOMATED** — freeze is chat-command path; MCP `console_run` cannot invoke `freeze` / chat grammar |
| Settings tab → back → close | **NOT AUTOMATED** — requires UI click (no bridge UI tool used) |
| Gradient warnings while menu open | **PASS — EMPTY** (`read_log -filter gradient` → no lines) |

---

## PARTY (#73) proof

| Check | Result |
|-------|--------|
| `/party` or `/p` | **BLOCKED for MCP** — chat-local `ExecuteLocal` only; `console_run party` / `p` fails |
| Party HUD drag + chevron | **NEEDS MANUAL** — menu never opened via automation |
| Screenshot menu + HUD | **PARTIAL** — staff menu shots only (see below) |

**Bloodwave ~9PM manual gap:** in chat type `/party` or `/p` once; Alt-drag HUD; screenshot HUD collapsed/expanded.

---

## Screenshots

Folder: `lifepunch/docs/handoff/proof/2026-07-02-red-unattended/`

| File | Notes |
|------|-------|
| `01-staffmenu-open.png` | First open (pre-flatgrass correction) |
| `02-staffmenu-menu-cmd.png` | After `menu` ConCmd |
| `03-flatgrass-staffmenu.png` | **Primary proof** — flatgrass Host Play + staff menu |

Engine also wrote: `D:\Steam\steamapps\common\sbox\dxrp\game\screenshots\sbox.2026.07.02.*.png`

---

## Stashes / do not lose

- `dxrp-public` stash **`party-browse-local-proof-hold`** — Browse tab WIP (3 files)
- `lifepunch` lpbitcoin hub UI — committed at `ff02374` on checkpoint branch

---

## BLOCKED items for full PROVEN

1. Party menu/HUD — needs in-game chat `/party` (or future bridge chat helper).
2. Staff freeze + Settings tab — needs UI interaction or portal rank + target player.
3. Optional: align Bridge addon **1.17.1** ↔ MCP **1.18.0** before next unattended run.

---

## Commands locked (unchanged)

Staff: **`/menu` · `/adminmenu` · `/staffmenu`** only (no `/ulx` / `/lifepunchulx`).
