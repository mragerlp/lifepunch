# DXRP Party + Staff Menu — STANDBY (await Bloodwave return)

> **Owner gate:** No push to `dxura/dxrp`, no commit on `dxrp-public` party slice until flatgrass proof passes.
> **Lane:** Vanilla DXRP editor (`dxrp-vanilla`) — **not** LifePunch `dxrp` / `lpbitcoin` mount.

---

## STAND BY — all CVL agents

Bloodwave is away. **Do not ship, push, or open PRs.** Warm-up only:

| Node | Posture |
|------|---------|
| **Red (VENGEANCE)** | Hold Host Play prep; sync overlays to `dxrp-vanilla`; no upstream commits |
| **Green (Cornerman)** | Eyes covered; MCP distill only; **no playtest claims** |
| **Mac (Design Architect)** | Advisory only; Dimmer sign-off prep for #126 |

On return we run **one vanilla session** proving **both** surfaces below.

---

## Test matrix (owner return)

### A — Party (`/party`) — dxrp-public `party-browse`

- **Branch:** `party-browse` (merged with `origin/develop` locally; **uncommitted** Browse slice)
- **Proof:** Host Play flatgrass → `/party` → **Browse** tab (read-only parties + online players) + **Party** tab `current/max` roster header
- **2P (optional):** Splash God join via Steam Friends → `/party invite Splash God`
- **Auth:** `authorize <token>` — **not** `lp_authorize` (vanilla has no LifePunch overlay)

### B — Staff menu (`/menu`, `/adminmenu`, `/staffmenu`) — LifePunch `adminmenu`

- **Issue:** [dxura/dxrp#126](https://github.com/dxura/dxrp/issues/126) (Dimmer visual sign-off; LifePunch-local styling)
- **Commands (locked for this pass):** `/menu`, `/adminmenu`, `/staffmenu` only — **no** `/ulx`, **no** `/lifepunchulx`
- **Sync:** `Sync-LifePunchAddonsToDxrp.ps1 -Addon adminmenu -ConfigPath dxrp-vanilla-editor.local.json`
- **Proof:** flatgrass Host Play → each command opens menu → screenshot for Dimmer checklist
- **Window:** keep **1160×700** ops console (do not shrink to Party 680×460)

---

## Launch recipe (Red)

```powershell
cd C:\Users\jared\Projects\lifepunch
# Party overlay from dxrp-public working tree:
Copy-Item C:\Users\jared\Projects\dxrp-public\game\Code\UI\HUD\Components\PartyMenu.* `
  D:\Steam\steamapps\common\sbox\dxrp-vanilla\game\Code\UI\HUD\Components\ -Force
Copy-Item C:\Users\jared\Projects\dxrp-public\game\Localization\en\dxrp.json `
  D:\Steam\steamapps\common\sbox\dxrp-vanilla\game\Localization\en\ -Force

# Staff menu addon into vanilla workbench:
powershell -File lifepunch\scripts\Sync-LifePunchAddonsToDxrp.ps1 `
  -Addon adminmenu -ConfigPath lifepunch\scripts\dxrp-vanilla-editor.local.json -AllowVanillaSync

powershell -File lifepunch\scripts\Start-SboxDxrpEditor.ps1 `
  -ConfigPath lifepunch\scripts\dxrp-vanilla-editor.local.json `
  -ReplaceExisting -NoSync -FullCapacity -PreflightFix -SkipPreflight -SkipOverlays
```

---

## Protected work (do not lose)

| Work | Location | Status |
|------|----------|--------|
| lpbitcoin hub UI | `lifepunch` commit `ff02374` on `checkpoint-lpbitcoin-pre-sleep-20260701` | **Committed** |
| Party Browse P1 | `dxrp-public` working tree (3 files) | **Uncommitted** — stash name `party-browse-p1-pre-develop-merge` if needed |
| Staff menu P0 tokens + commands | `lifepunch` `adminmenu/*` | **Committed** on owner return batch |
| MCP editor libraries | `dxrp-public/game/Libraries/*` | **Untracked** — local editor only; never commit to upstream |

---

## dxrp-public sync state (2026-07-02)

- `party-browse` merged **`origin/develop`** (includes `a132116` screenshot fixes + Discord CI)
- Browse slice still **local-only** until proof + owner GO
- Upstream party canon: **#73 merged**, **#115** checkpoint PR open

---

## Cornerman join reminder

Splash God must join from **`dxrp-vanilla`** client (no `Code/Addons/lifepunch` mount). Steam Friends → Join Game. Network profile **Private** on both boxes.
