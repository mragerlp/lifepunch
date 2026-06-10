# LifePunch Ops — machine uniforms

Each machine wears a **Hacker Job outfit**. OneDrive is the artist source; `outfits/` in this
pack is the repo copy. See **`OUTFITS.md`** for web-node uniforms, paths, and taglines.
**`UNIFORM_STANDARDS.md`** (repo + `OneDrive\Desktop\uniforms\`) is the web-wide uniform law.

| Tier | Machine | Scheme | Prompt |
|------|---------|--------|--------|
| Enhanced Hacker Terminal | **VENGEANCE** | `VENGEANCE Ops` (red) | `vengeance@vengeance:~$` |
| Hacker Terminal | **Cornerman** | `Cornerman Ops` (green) | `cornerman@cornerman:~$` |
| Government Terminal | **lifepunchnet** | `LifePunch Ops` (cyan) | `lifepunch@lifepunch.net:~$` (`lifepunch-government.omp.json`) |

## Palettes

**VENGEANCE** — `windows-terminal-vengeance.json`, accent `#E4002B`, tagline *PLAN. EXECUTE. DESTROY.*

**Cornerman** — `windows-terminal-cornerman.json`, accent `#00FF7F`, tagline *BUILD. AUTOMATE. ELEVATE.*

**lifepunchnet** — `windows-terminal-lifepunch-ops.json`, accent `#00D4FF`, taglines *SECURE. CONTROL. SERVE.* / *PROTECTING. MANAGING. GOVERNING.*

## Workflow

```powershell
# 1. Refresh art from OneDrive outfit folders
powershell -ExecutionPolicy Bypass -File .\Sync-OutfitsFromOneDrive.ps1

# 2. Dress each machine
powershell -ExecutionPolicy Bypass -File .\Apply-LifePunchOpsConsole.ps1 -Machine vengeance -NodeIp <LAN-IP>
powershell -ExecutionPolicy Bypass -File .\Apply-LifePunchOpsConsole.ps1 -Machine cornerman -NodeIp <LAN-IP>
powershell -ExecutionPolicy Bypass -File .\Apply-LifePunchOpsConsole.ps1 -Machine lifepunchnet
```

Open a **new** Windows Terminal tab after apply.

## Assets

| File | Purpose |
|------|---------|
| `OUTFITS.md` | Cast, OneDrive paths, asset parity |
| `Sync-OutfitsFromOneDrive.ps1` | Pull uniforms from OneDrive → `outfits/` + `wallpapers/` |
| `Apply-LifePunchOpsConsole.ps1` | WT scheme, accent, wallpaper, oh-my-posh `print primary`, banner |
| `lifepunch-government.omp.json` | Government Terminal prompt (lifepunchnet) |
| `Build-OpsDeployZip.ps1` | `lifepunch-ops-deploy.zip` for RDP / lane handoff |
| `VENGEANCE-HANDOFF.txt` | Primary PC sync + apply quick reference |
| `nodes.json` | Per-machine tier, brand, wallpaper map |
| `outfits/<machine>/` | Full outfit (icons, banners, console refs) |
| `wallpapers/` | Desktop images applied by the script |

Legacy `lifepunch/branding/cornerman/` is superseded. `SYNC_FROM_LIFEPUNCHNET.md` covers RDP handoff when SSH to the hosted box is down.
