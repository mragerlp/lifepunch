# LifePunch shortcut icons (tier → destination)

Icons tell you **which machine or scope** a shortcut targets at a glance.

| Tier | Color | File | Paired shortcuts |
|------|-------|------|------------------|
| **Universal** | All three (tri-stack) | `lifepunch-universal.png` | **LifePunch — Start Day**, **LifePunch Voice Preflight** |
| **VENGEANCE** | Red | `lifepunch-vengeance.png` | **LifePunch Voice Comms**, **Talk to Vengeance** (voice → VENGEANCE / Cursor) |
| **Cornerman** | Green | `lifepunch-cornerman.png` | **Cornerman (RDP)** |
| **lifepunchnet** | Blue / cyan | `lifepunch-lifepunchnet.png` | **lifepunchnet (RDP)** |

Art source: Hacker Job outfit app icons (`lifepunch-ops/outfits/*/appicon.png` family).

## Refresh shortcuts on VENGEANCE

```powershell
cd <repo>\lifepunch\scripts
powershell -ExecutionPolicy Bypass -File .\Install-LifePunchShortcutIcons.ps1
```

Re-runs all shortcut installers so every `.lnk` picks up the latest PNG from `shortcut-icons/`.
