# Bitcoin Miner — Build status

| Piece | Status |
|-------|--------|
| gpu-rack publish tree (34 files) | **In repo** under `models/.../gpu-rack/` |
| Raw export archive | **Local** `C:/lifepunch/reference-intake/bitcoinmining/gpu-rack-export/` |
| `Bitminer.cs` identity | **Scaffold** — entity `bitcoin-miner`, mesh `gpu-rack` |
| `BitminerEntity.cs` | **Done (Phase 1)** — entity + economy + `RequestOpenTerminal()` |
| `BitminerTerminalHost.cs` | **Done (Phase 1)** — dual-build mount/close |
| `BitminerCommandHost.cs` | **Done (Phase 1)** — `hashd` / `mine` opens terminal on nearest rig |
| `BitminerTerminal.razor` + `.scss` | **Phase 1 done** (HASHD amber rail); **Phase 2 modules** → `RED_BITMINER_PHASE2_BUILD.md` + `briefs/BITMINER_PHASE2_WIREFRAME.md` |
| `bitcoin-terminal` (`computer.fbx`) | **Intaked** — `models/.../bitcoin-terminal/`; ModelDoc TBD |
| `gpu-rack.vmdl` + 5 vmats | **Done** — compiled `_c` in repo; power anim still **TODO** |
| `bitcoin-miner.prefab` | **Done** — scaffold on root; tune collider/LCD in editor |
| Sounds | **TODO** — own/licensed under `sounds/bitcoin-miner/` |
| `addons.json` content row | **TODO** after prefab path confirmed |

Canon brief: `addons/docs/briefs/BITMINER_ENTITY_BRIEF.md`  
Grouping: `models/.../gpu-rack/MODEL_BUILD.md` + `material-map.json`
