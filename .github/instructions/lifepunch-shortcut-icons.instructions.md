---
applyTo: "**"
description: "LifePunch desktop shortcut icon tiers (tri-stack universal vs per-node red/green/blue)"
sourceRule: ".cursor/rules/lifepunch-shortcut-icons.mdc"
---

> **Synced from** `.cursor/rules/lifepunch-shortcut-icons.mdc` â€” edit source there, then re-run `Sync-CursorRulesToCopilotInstructions.ps1`.

# LifePunch shortcut icon tiers

Canonical pairing: `lifepunch/branding/shortcut-icons/SHORTCUT_ICONS.md`.

## Universal = tri-stack (all three nodes)

Use **`lifepunch-universal.png`** (`Get-LifePunchShortcutIconLocation -Tier universal`) when the shortcut spans the **full voice stack** across lifepunchnet + Cornerman + VENGEANCE — not a single machine.

**Start Day** is the reference shortcut: gate on lifepunchnet Whisper `:9000`, VENGEANCE watchers (paste / session sync / host watch), and SSH-start Cornerman PTT relay.

Also universal: **cross-node preflight** that exercises the whole path (e.g. Voice Preflight).

## Per-destination tiers

| Tier | Icon | Rule |
|------|------|------|
| **VENGEANCE** (red) | `lifepunch-vengeance.png` | VENGEANCE desk scope or voice **to** VENGEANCE/Cursor (Voice Comms, Talk to Vengeance) |
| **Cornerman** (green) | `lifepunch-cornerman.png` | RDP into Cornerman |
| **lifepunchnet** (blue) | `lifepunch-lifepunchnet.png` | RDP into lifepunchnet |

Icon = **destination/scope**, not always the host where the `.lnk` file sits.

Refresh all shortcuts: `lifepunch/scripts/Install-LifePunchShortcutIcons.ps1`.
