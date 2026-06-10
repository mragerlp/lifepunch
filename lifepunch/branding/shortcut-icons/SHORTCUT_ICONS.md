# LifePunch shortcut icons (tier → destination)

Icons tell you **which machine or scope** a shortcut targets at a glance.

| Tier | File | Use on shortcuts that… |
|------|------|-------------------------|
| **Universal** | `lifepunch-universal.png` | Orchestrate the full stack (all nodes). Example: **LifePunch — Start Day**, voice preflight. |
| **VENGEANCE** | `lifepunch-vengeance.png` | Run on the **desk PC** only (paste watcher, session sync, monorepo). |
| **Cornerman** | `lifepunch-cornerman.png` | Target **Cornerman** (RDP, relay, LAN AI box). |
| **lifepunchnet** | `lifepunch-lifepunchnet.png` | Target **hosted server** (RDP, boot install, Whisper/status/hub). |

Art source: Hacker Job outfit app icons (same family as `lifepunch-ops/outfits/`).

## Refresh shortcuts on VENGEANCE

```powershell
cd <repo>\lifepunch\scripts
powershell -ExecutionPolicy Bypass -File .\Install-LifePunchShortcutIcons.ps1
```

Wires icons into Start Day, Voice Comms, preflight, and RDP shortcuts.
