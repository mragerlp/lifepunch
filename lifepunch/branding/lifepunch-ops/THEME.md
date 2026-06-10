# LifePunch Ops console (per-node HUD)

Two visual families, one apply script:

| Machine | Look | Terminal scheme | Prompt |
|---------|------|-----------------|--------|
| **VENGEANCE** | Red tactical HUD | `VENGEANCE Ops` | `vengeance@vengeance:~$` |
| **Cornerman** | Cyan LIFEPUNCH.NET HUD | `LifePunch Ops` | `user@cornerman:path$` |
| **lifepunchnet** | Cyan LIFEPUNCH.NET HUD | `LifePunch Ops` | `user@lifepunchnet:path$` |

Canonical cyan assets live on **lifepunchnet** at `C:\lifepunch\branding\lifepunch-ops\`. VENGEANCE red assets live in this repo under `wallpapers/lifepunch-ops-wallpaper-vengeance.png`.

## Palettes

**VENGEANCE (red)** — `windows-terminal-vengeance.json`, accent `#E4002B`

| Token | Hex | Use |
|-------|-----|-----|
| Background | `#0A0A0A` | Terminal + HUD base |
| Foreground | `#FF4D4D` | Body text |
| Red (primary) | `#FF3333` | Accent, cursor, prompt |
| Light red | `#FFE0E0` | Prompt `$` suffix |

**Cornerman / lifepunchnet (cyan)** — `windows-terminal-lifepunch-ops.json`, accent `#00D4FF`

| Token | Hex | Use |
|-------|-----|-----|
| Background | `#050A12` | Terminal + HUD base |
| Foreground | `#C5EEFF` | Body text |
| Cyan (primary) | `#00D4FF` | Accent, cursor, HUD lines, prompt |
| Blue (secondary) | `#0099CC` | Paths, secondary emphasis |
| Alert red | `#FF3B5C` | Errors only |

## NODE lines

| Machine | Banner | Prompt |
|---------|--------|--------|
| VENGEANCE | `V E N G E A N C E` + `PLAN. EXECUTE. DESTROY.` | `vengeance@vengeance:~$` (fixed in omp) |
| Cornerman | `LIFEPUNCH OPS // NODE: CORNERMAN` | oh-my-posh session@host |
| lifepunchnet | `LIFEPUNCH OPS // NODE: LIFEPUNCH.NET` | oh-my-posh session@host |

## Apply

```powershell
cd <repo>\lifepunch\branding\lifepunch-ops
powershell -ExecutionPolicy Bypass -File .\Apply-LifePunchOpsConsole.ps1 -Machine vengeance -NodeIp <LAN-IP>
```

Open a **new** Windows Terminal tab to preview. Restart Explorer if title-bar accent did not repaint.

## Retiring legacy green branding

`lifepunch/branding/cornerman/` (Spring Green ops) is **legacy**. Do not apply `Apply-CornermanTerminal.ps1` on new setups — use this pack instead. Remove the old folder when no machine depends on it.

## Assets

| File | Purpose |
|------|---------|
| `Apply-LifePunchOpsConsole.ps1` | One-shot applier |
| `windows-terminal-vengeance.json` | WT scheme `VENGEANCE Ops` (red) |
| `windows-terminal-lifepunch-ops.json` | WT scheme `LifePunch Ops` (cyan) |
| `vengeance.omp.json` | oh-my-posh `vengeance@vengeance:path$` |
| `lifepunch-ops.omp.json` | oh-my-posh cyan theme |
| `LifePunch-OpsProfile.ps1` | Session HUD banner |
| `nodes.json` | Per-machine NODE + wallpaper map |
| `wallpapers/` | Per-node HUD backgrounds |

See `SYNC_FROM_LIFEPUNCHNET.md` to refresh cyan wallpapers from the hosted box.
