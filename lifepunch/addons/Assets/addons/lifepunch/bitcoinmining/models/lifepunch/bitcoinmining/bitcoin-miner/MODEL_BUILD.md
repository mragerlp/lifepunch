# Bitcoin Miner hub — Ophion world model

**Entity slug:** `bitcoin-miner` · **Disk folder:** `entities/bitcoinminer/`  
**Source:** owner `Ophion.fbx` + textures (intake via `Intake-BitcoinMinerHub.ps1`)

## Ship tree

```text
models/lifepunch/bitcoinmining/bitcoin-miner/
  source/
    Ophion.fbx
    textures/           ← copied from entities/bitcoinminer/textures on intake
  bitcoin-miner.vmdl    ← Ophion.fbx (`import_scale` 0.52 @ prefab 1,1,1)
  materials/            ← chassis + plate vmats (remap in vmdl MaterialGroupList)
  MODEL_BUILD.md

entities/bitcoinminer/
  source/Ophion.fbx     ← owner drop (archive)
  textures/             ← owner PBR sets
  bitcoin-miner.prefab  ← TODO: ModelDoc compile + BitcoinMinerHubEntity + Health 250
```

## ModelDoc checklist

1. Open `bitcoin-miner.vmdl` in ModelDoc — compile `_c`.
2. Map Ophion material slots → vmat (`MaterialGroupList` remaps FBX names: `Aluminium`, `Aluminium.001`, `GraphicCard`, …). **`Metal036_2K_Color.jpg`** is a placeholder copy of `internal_ground_ao_texture.jpeg` until the real ambientCG color map is intaked.
3. **AnimationList** → **Add Simple Animations** from `Ophion.fbx`; rename hub boot clips to `power_on` (loop) + `power_off` (idle). `BitcoinMinerHubEntity` + `GpuRackPowerAnim` already call `DirectPlayback.Play` on power toggle.
4. Prefab: `ModelRenderer` → `bitcoin-miner.vmdl`, `BitcoinMinerHubEntity`, `HealthComponent.MaxHealth = 250`.

## Sounds (owner drop → `sounds/bitcoinminer/`)

| Event | File |
|-------|------|
| Hub startup | `hub-startup.wav` |
| Fan loop | `hub-fan-loop.wav` |
| Fan down | `hub-fan-down.wav` |

## Code

| File | Role |
|------|------|
| `BitcoinMinerHubEntity.cs` | Power, encryption tiers, opens hashd |
| `BitcoinMinerHubRegistry.cs` | Links hub ↔ racks (8m / 4m) |
| `BitcoinMinerEncryptionCatalog.cs` | Defense upgrade math |
| `BitcoinMiningCombatStats.cs` | HP + placement caps |

Spec: `addons/docs/BITCOINMINING_HUB_ARCH.md`
