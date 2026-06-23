# lpbitcoin — LIFEPUNCH Bitcoin package (editor + publish staging)

**Package slug:** `lifepunchbitcoin` · **Code mount (repo):** `Code/Addons/lifepunch/bitcoinmining/`  
**Editor Asset Browser:** `Assets/addons/lifepunch/lpbitcoin/` only — no `bitcoinmining` assets folder.

## Entity slots (folder name = slug)

| Folder | What you edit / spawn | ModelDoc vmdl | Prefab |
|--------|----------------------|---------------|--------|
| `bitcoinhub/` | Steam Machine hub | `assets/models/bitcoinhub.vmdl` | `assets/entities/bitcoinhub.prefab` |
| `hashdterminal/` | CRT terminal prop | `assets/models/hashd-terminal.vmdl` | `assets/entities/hashd-terminal.prefab` |
| `gpurack/` | **GPU Rack** (standard open-frame) | `assets/models/gpu-rack.vmdl` | `assets/entities/gpu-rack.prefab` |
| `advancedgpurack/` | **Advanced GPU Rack** (stacked farm) | `../gpurack/assets/models/gpu-rack-stacked.vmdl` | `assets/entities/advanced-gpu-rack.prefab` |

Shared sounds + HASHD UI mark: `bitcoinhub/assets/sounds/` · `bitcoinhub/assets/ui/hashd/`

## Dev spawn (flatgrass)

```text
lp_bitcoin_spawn_kit          # hub + terminal + standard + advanced rack
lp_spawn_gpu_rack             # standard only
lp_spawn_advanced_gpu_rack    # advanced only
lp_bitcoin_clear_spawns       # cleanup
```

Paths resolve via `LpBitcoinIdent.cs` — all under `lpbitcoin/…`.

## Archive (docs only — no compile artifacts)

s&box compiles **every** `.vmdl` / `.vmat` under `Assets/`. Archive folders must keep **MD/JSON/source FBX only** — never duplicate ModelDoc files.

- `_archive/advancedgpurack-intake/` — old intake docs; live prefab is `advancedgpurack/assets/entities/advanced-gpu-rack.prefab`
- `bitcoinhub/_archive/` — Sketchfab hub + phase2 fan experiments (retired)
- `gpurack/_archive/small-open-frame/` — parked single-unit mesh (not shipped)

Sync script strips any stray `_archive` compile artifacts from DXRP after mirror.

## Sync

```powershell
powershell -File lifepunch\scripts\Sync-LifePunchAddonsToDxrp.ps1 -Addon bitcoinmining
```

Purges legacy `Assets/bitcoinmining` from DXRP; mirrors `lpbitcoin` + `Code/bitcoinmining`.
