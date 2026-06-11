# Bitcoin Miner hub — Ophion world model

**Entity slug:** `bitcoin-miner` · **Disk folder:** `entities/bitcoinminer/`  
**Source:** owner `Ophion.fbx` + textures (intake via `Intake-BitcoinMinerHub.ps1`)

## Ship tree

```text
models/lifepunch/bitcoinmining/bitcoin-miner/
  source/
    Ophion.fbx
    textures/           ← copied from entities/bitcoinminer/textures on intake
  bitcoin-miner.vmdl    ← points at Ophion.fbx (import_scale 39.37, align Z Bottom)
  MODEL_BUILD.md

entities/bitcoinminer/
  source/Ophion.fbx     ← owner drop (archive)
  textures/             ← owner PBR sets
  bitcoin-miner.prefab  ← TODO: ModelDoc compile + BitminerHubEntity + Health 250
```

## ModelDoc checklist

1. Open `bitcoin-miner.vmdl` in ModelDoc — compile `_c`.
2. Map Ophion material slots → vmat (use texture folders under `entities/bitcoinminer/textures/`).
3. **AnimationList** → **Add Simple Animations** from `Ophion.fbx`; rename hub boot clips to `power_on` (loop) + `power_off` (idle). `BitminerHubEntity` + `BitminerPowerAnim` already call `DirectPlayback.Play` on power toggle.
4. Prefab: `ModelRenderer` → `bitcoin-miner.vmdl`, `BitminerHubEntity`, `HealthComponent.MaxHealth = 250`.

## Sounds (owner drop → `sounds/bitcoinminer/`)

| Event | File |
|-------|------|
| Hub startup | `hub-startup.wav` |
| Fan loop | `hub-fan-loop.wav` |
| Fan down | `hub-fan-down.wav` |

## Code

| File | Role |
|------|------|
| `BitminerHubEntity.cs` | Power, encryption tiers, opens hashd |
| `BitminerHubRegistry.cs` | Links hub ↔ racks (8m / 4m) |
| `BitminerEncryptionCatalog.cs` | Defense upgrade math |
| `BitminerCombatStats.cs` | HP + placement caps |

Spec: `addons/docs/BITMINER_HUB_ARCH.md`
