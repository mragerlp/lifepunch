# lpbitcoin — LIFEPUNCH Bitcoin package (editor + publish staging)

**Package slug:** `lifepunchbitcoin` · **Code mount (repo):** `Code/Addons/lifepunch/bitcoinmining/`  
**Editor Asset Browser:** `Assets/addons/lifepunch/lpbitcoin/` only — no `bitcoinmining` assets folder.

## Entity slots (folder name = slug)

| Folder | What you edit / spawn | ModelDoc vmdl | Prefab |
|--------|----------------------|---------------|--------|
| `bitcoinhub/` | Steam Machine hub | `assets/models/bitcoinhub.vmdl` | `assets/entities/bitcoinhub.prefab` |
| `hashdterminal/` | CRT terminal prop | `assets/models/hashd-terminal.vmdl` | `assets/entities/hashd-terminal.prefab` |
| `gpurack/` | **GPU Rack** (stacked farm — one ship tier) | `assets/models/gpu-rack-stacked.vmdl` | `assets/entities/gpu-rack.prefab` |

Shared sounds + HASHD UI mark: `bitcoinhub/assets/sounds/` · `bitcoinhub/assets/ui/hashd/`

## Dev spawn (flatgrass)

```text
lp_bitcoin_spawn_kit          # hub + terminal + 1× GPU rack
lp_bitcoin_clear_spawns       # cleanup
```

Paths resolve via `LpBitcoinIdent.cs` — all under `lpbitcoin/…`.

## Archive (ignore in Asset Browser)

- `_archive/advancedgpurack-intake/` — duplicate intake; merged into `gpurack/`
- `gpurack/_archive/small-open-frame/` — parked single-unit mesh (not shipped)

## Sync

```powershell
powershell -File lifepunch\scripts\Sync-LifePunchAddonsToDxrp.ps1 -Addon bitcoinmining
```

Purges legacy `Assets/bitcoinmining` from DXRP; mirrors `lpbitcoin` + `Code/bitcoinmining`.
