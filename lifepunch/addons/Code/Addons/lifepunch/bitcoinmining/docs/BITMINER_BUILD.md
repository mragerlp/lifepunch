# Bitcoin Miner — Build status

| Piece | Status |
|-------|--------|
| gpu-rack publish tree (34 files) | **In repo** under `models/.../gpu-rack/` |
| Raw export archive | **Local** `C:/lifepunch/reference-intake/bitcoinmining/gpu-rack-export/` |
| `Bitminer.cs` identity | **Scaffold** — entity `bitcoin-miner`, mesh `gpu-rack` |
| `BitminerEntity.cs` | **Done (Phase 1)** — entity + economy + `RequestOpenTerminal()` |
| `BitminerTerminalHost.cs` | **Done (Phase 1)** — dual-build mount/close |
| `BitminerCommandHost.cs` | **Done (Phase 1)** — `hashd` / `mine` opens terminal on nearest rig |
| `BitminerTerminal.razor` + `.scss` | **Done (Phase 1)** — CLI + Cornerman theme; `menu` stubs Phase 2 |
| `gpu-rack.vmdl` | **TODO** — ModelDoc on VENGEANCE |
| `bitcoin-miner.prefab` | **TODO** — editor on VENGEANCE |
| Sounds | **TODO** — own/licensed under `sounds/bitcoin-miner/` |
| `addons.json` content row | **TODO** after prefab path confirmed |

Canon brief: `addons/docs/briefs/BITMINER_ENTITY_BRIEF.md`  
Grouping: `models/.../gpu-rack/MODEL_BUILD.md` + `material-map.json`
