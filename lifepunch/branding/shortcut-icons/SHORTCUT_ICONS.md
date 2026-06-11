# LifePunch shortcut icons (tier → destination)

Icons tell you **which node receives the ping** (destination tier), not which desk the `.lnk` sits on.
Canon: `lifepunch/docs/CVL_RGB_DOCTRINE.md` § Directed pings.

## Tier rules

**Universal (tri-stack)** — `lifepunch-universal.png`. Target **white-light** integration (R+G+B primaries lit). Not "rainbow" yet — see `lifepunch/docs/CVL_RGB_DOCTRINE.md`.

Canonical examples: **LifePunch — Start Day** (full stack); **LifePunch - CVL Same Page** (checkpoint + hub).

Also universal: cross-node **preflight/diagnostic** actions that touch the whole voice path (e.g. **LifePunch Voice Preflight**).

**Single-destination tiers** — icon color = **which node you signal or where voice lands**, not which machine the `.lnk` file sits on.

**Red → Green voice (Yellow path):** On **VENGEANCE (Red)** the shortcut is **green** — you are commanding **Cornerman**. On **Cornerman (Green)** the relay shortcut is **red** — voice lands on **VENGEANCE / Cursor**.

| Tier | Color | File | Shortcuts |
|------|-------|------|-----------|
| **Universal** | All three (tri-stack) | `lifepunch-universal.png` | **LifePunch — Start Day**, **LifePunch - CVL Same Page**, **LifePunch Voice Preflight** |
| **VENGEANCE** | Red | `lifepunch-vengeance.png` | **LifePunch Voice Comms** (Red-side watch windows), **DXRP Editor - VENGEANCE** (local s&box + API token) |
| **Cornerman** | Green | `lifepunch-cornerman.png` | **Cornerman (RDP)**, **Cornerman — Talk to Vengeance** *(on VENGEANCE desktop — signals Green)* |
| **VENGEANCE** | Red | `lifepunch-vengeance.png` | **Talk to Vengeance** *(on Cornerman desktop only — voice to Red)* |
| **Cornerman** | Green | `lifepunch-cornerman.png` | **Cornerman (Sync from Red)** *(on Cornerman desktop only — git reset to origin/main)* |
| **lifepunchnet** | Blue / cyan | `lifepunch-lifepunchnet.png` | **lifepunchnet (RDP)** |

Art source: Hacker Job outfit app icons (`lifepunch-ops/outfits/*/appicon.png` family).

## Refresh shortcuts on VENGEANCE

```powershell
cd <repo>\lifepunch\scripts
powershell -ExecutionPolicy Bypass -File .\Install-LifePunchShortcutIcons.ps1
```

Builds `.ico` from tier PNGs (Windows ignores PNG in `IconLocation`), then re-runs all shortcut installers.

```powershell
powershell -ExecutionPolicy Bypass -File .\Build-LifePunchShortcutIcons.ps1
```
