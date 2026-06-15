# Asset intake — LIFEPUNCH Cyber Ecosystem

**Owner drop root (canonical):** `%USERPROFILE%\OneDrive\Desktop\LIFEPUNCH*\addons\`

Resolver: `addons/scripts/LifePunch-AddonDropPaths.ps1` (scans Desktop for any folder containing `addons\`). Falls back to `Downloads\<folder>` for legacy drops.

Tell Red the folder path after drop; scripts mirror into repo `Assets/addons/lifepunch/…`.

---

## Package layout (Jun 2026)

| Package folder | Addon ident | Entity drops |
|----------------|-------------|--------------|
| `lifepunchhacker\hacker\serverrack` | `hackerjob` | Basic `Servers.fbx` + advanced `Servers_Rows.fbx` + shared trim/glass |
| `lifepunchhacker\hacker\hackerterminal` | `hackerjob` | Criminal hacker terminal |
| `lifepunchhacker\fbi\governmentserverrack` | `governmentdatacenter` | FBI / government server rack |
| `lifepunchhacker\fbi\governmentterminal` | `governmentdatacenter` | Government terminal (lifepunchnet) |
| `lifepunchbitcoin\bitcoinminer` | `bitcoinmining` | Steam Machine hub |
| `lifepunchbitcoin\gpurack` | `bitcoinmining` | GPU racks |
| `lifepunchbitcoin\bitcointerminal` | `bitcoinmining` | Hashd terminals |
| `lifepunchblackmarketdealer\blackmarkethub` | `blackmarketdealer` (prep) | Vault dealer hub |

**Parked (not in active scope):** `advanced-hacker-terminal` / Vengeance terminal only.

---

## Already in repo

| Pack | Path | Notes |
|------|------|-------|
| GPU racks | `models/.../gpu-rack/` | Anim FBX — wire `power_on`/`power_off` |
| Bitcoin hub | `models/.../bitcoin-miner/` | Steam Machine FBX + power anims |
| Hacker server rack | `hackerjob/.../server-rack/` | Fab `Servers.fbx` + trim/glass 2K |
| Advanced server rack | `hackerjob/.../advanced-server-rack/` | Fab `Servers_Rows.fbx`; reuses trim/glass |
| Government server rack | `governmentdatacenter/.../government-server-rack/` | Same Fab family; FBI lane drop |
| Hacker terminal | `hackerjob/.../hacker-terminal/` | cornerman.exe CRT |
| Gov terminal | `governmentdatacenter/.../police-terminal/` | lifepunchnet PNGs + Stol2.obj |
| Cornerman UI | `ui/cornerman/*.png` | Optional CRT chrome beyond green SCSS |
| Black market hub | `blackmarketdealer/.../black-market-hub/` | Phase H prep |

---

## After drop — Red runs

```powershell
Intake-HackerServerRack.ps1
Intake-AdvancedServerRack.ps1
Intake-GovernmentServerRack.ps1
Intake-HackerTerminalModel.ps1
Intake-GovernmentTerminal.ps1
Intake-BitcoinMinerHub.ps1 -ExportFbx
Reorganize-BitcoinMinerGpuRack.ps1
Intake-BlackMarketHub.ps1
Intake-HackerCornermanUi.ps1
```

**Parked scripts (exit 0, no-op):** `Intake-AdvancedHackerTerminal.ps1`

---

## ModelDoc compile queue

| vmdl | Addon |
|------|-------|
| `server-rack.vmdl` | hackerjob |
| `advanced-server-rack.vmdl` | hackerjob |
| `government-server-rack.vmdl` | governmentdatacenter |
| `hacker-terminal.vmdl` | hackerjob |
| `police-terminal.vmdl` | governmentdatacenter |
| `bitcoin-miner.vmdl` | bitcoinmining |
| `gpu-rack/*.vmdl` | bitcoinmining |

Pull `_c` after compile; dedicated server does not compile.
