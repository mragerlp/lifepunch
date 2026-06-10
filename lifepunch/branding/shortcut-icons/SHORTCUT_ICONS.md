# LifePunch shortcut icons (tier → destination)

Icons tell you **which machine or scope** a shortcut targets at a glance.

## Tier rules

**Universal (tri-stack)** — `lifepunch-universal.png`. Target **white-light** integration (R+G+B primaries lit). Not "rainbow" yet — see `lifepunch/docs/CVL_RGB_DOCTRINE.md`.

Canonical examples: **LifePunch — Start Day** (full stack); **LifePunch - CVL Same Page** (checkpoint + hub).

Also universal: cross-node **preflight/diagnostic** actions that touch the whole voice path (e.g. **LifePunch Voice Preflight**).

**Single-destination tiers** — red/green/blue = **where voice goes or which box you RDP into**, even if the `.lnk` lives on another machine (e.g. **Talk to Vengeance** is red on Cornerman because voice targets VENGEANCE).

| Tier | Color | File | Paired shortcuts |
|------|-------|------|------------------|
| **Universal** | All three (tri-stack) | `lifepunch-universal.png` | **LifePunch — Start Day**, **LifePunch - CVL Same Page**, **LifePunch Voice Preflight** |
| **VENGEANCE** | Red | `lifepunch-vengeance.png` | **LifePunch Voice Comms**, **Talk to Vengeance** (voice → VENGEANCE / Cursor) |
| **Cornerman** | Green | `lifepunch-cornerman.png` | **Cornerman (RDP)** |
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
