# lpbitcoin — LIFEPUNCH Bitcoin package (editor + publish staging)

**Package slug:** `lifepunchbitcoin` · **Code mount (repo):** `Code/Addons/lifepunch/bitcoinmining/`  
**Editor Asset Browser:** `Assets/addons/lifepunch/lpbitcoin/` only — no `bitcoinmining` assets folder.

## Entity slots (folder name = slug)

| Folder | What you edit / spawn | ModelDoc vmdl | Prefab |
|--------|----------------------|---------------|--------|
| `bitcoinhub/` | Steam Machine hub | `assets/models/bitcoinhub.vmdl` | `assets/entities/bitcoinhub.prefab` |
| `hashdterminal/` | CRT terminal prop | **`assets/models/hashdterminal.vmdl`** | **`assets/entities/hashdterminal.prefab`** |
| `gpurack/` | **GPU Rack** (single + stacked) | **`gpurack.vmdl`** · **`advancedgpurack.vmdl`** | **`gpurack.prefab`** · **`advancedgpurack.prefab`** |

Shared sounds + HASHD UI mark: `bitcoinhub/assets/sounds/` · `bitcoinhub/assets/ui/hashd/`

## Dev spawn (flatgrass)

```text
lp_bitcoin_spawn_kit          # hub + terminal + 1× GPU rack
lp_bitcoin_clear_spawns       # cleanup
```

Paths resolve via `LpBitcoinIdent.cs` — all under `lpbitcoin/…`.

## Archive (docs only — no compile artifacts)

s&box compiles **every** `.vmdl` / `.vmat` under `Assets/`. Archive folders must keep **MD/JSON/source FBX only** — never duplicate ModelDoc files.

- `_archive/advancedgpurack-intake/` — retired intake; canonical stacked mesh is **`advancedgpurack.vmdl`**
- `bitcoinhub/_archive/` — Sketchfab hub + phase2 fan experiments (retired)
- `gpurack/_archive/small-open-frame/` — parked single-unit mesh experiments (not shipped)

**Retired Jun 2026:** hyphenated `gpu-rack*.vmdl` / `gpu-rack*.prefab` — use **`gpurack`** / **`advancedgpurack`** names only.

Sync script strips any stray `_archive` compile artifacts from DXRP after mirror.

## Sync

```powershell
powershell -File lifepunch\scripts\Sync-LifePunchAddonsToDxrp.ps1 -Addon bitcoinmining
```

Purges legacy `Assets/bitcoinmining` from DXRP; mirrors `lpbitcoin` + `Code/bitcoinmining`.

After ModelDoc compile:

```powershell
powershell -File lifepunch\scripts\Pull-DxrpCompiledAssetsToRepo.ps1 -Addon lpbitcoin
```
