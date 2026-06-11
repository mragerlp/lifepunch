# Bitcoin Miner — asset inventory

**Intake scripts:** `Reorganize-BitcoinMinerGpuRack.ps1`, `Intake-BitcoinMinerHub.ps1`, `Intake-BitcoinTerminalAssets.ps1` (terminal deprecated)

## Ship tree (publish) — LPaddons oneliners

| Slug | Entity name | Role | Source | vmdl |
|------|-------------|------|--------|------|
| `bitcoin-miner` | **Bitcoin Miner hub** | hashd menu + encryption + rack control | `Ophion.fbx` | vmdl in repo — **compile _c + vmat pass** |
| `gpu-rack` | **GPU Rack** | 500 HP · mining hardware | `gpu-rack-static.obj` + anim FBX | Shipped |
| `large-gpu-rack` | **Large GPU Rack** | 2000 HP · 2× yield | stacked anim FBX | vmdl in repo |
| ~~`bitcoin-terminal`~~ | ~~CRT~~ | **Deprecated** — menu on hub | `computer.fbx` | legacy |

```text
entities/bitcoinminer/    ← hub source + Ophion (owner)
entities/gpurack/
entities/largegpurack/
models/lifepunch/bitcoinmining/
  bitcoin-miner/          ← hub vmdl target
  gpu-rack/
sounds/bitcoinminer/      ← owner WAV drop
```

**Architecture:** `docs/BITCOINMINING_HUB_ARCH.md` · `docs/LIFEPUNCH_CYBER_ECOSYSTEM.md`

## Archives (not published)

| Path | Contents |
|------|----------|
| `C:/lifepunch/reference-intake/bitcoinmining/gpu-rack-export/` | Raw Blender GPU farm export |
| `C:/lifepunch/reference-intake/bitcoinmining/bitcoin-terminal-export/` | `computer.blend` + `computer.fbx` mirror |

## Code (repo)

| File | Role |
|------|------|
| `BitcoinMinerHubEntity.cs` | Hub power, encryption tiers, hashd anchor |
| `BitcoinMinerHubRegistry.cs` | Hub ↔ rack linking (max 3+1 per hub) |
| `BitcoinMinerEncryptionCatalog.cs` | Defense upgrade costs + math |
| `GpuRackEntity.cs` | Economy, `IsMining`, terminal open |
| `HashdTerminal.razor` | Phase 1 CLI; owner tabbed UI from Downloads bitcointerminal lane |

Spec: `addons/docs/BITCOINMINING_UX_SPEC.md`
