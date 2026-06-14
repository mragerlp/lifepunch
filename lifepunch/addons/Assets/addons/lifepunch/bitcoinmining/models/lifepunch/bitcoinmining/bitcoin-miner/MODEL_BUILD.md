# Bitcoin Miner hub — Ophion world model

**Entity slug:** `bitcoin-miner` · **Disk folder:** `entities/bitcoinminer/`  
**Source:** owner `Ophion.fbx` + textures (intake via `Intake-BitcoinMinerHub.ps1`)

## Ship tree

```text
models/lifepunch/bitcoinmining/bitcoin-miner/
  source/
    Ophion.fbx
    textures/           ← copied from entities/bitcoinminer/textures on intake
  bitcoin-miner.vmdl    ← Ophion.fbx — **owner-verified ModelDoc import (Jun 2026)**
  materials/            ← chassis + plate vmats (remap in vmdl MaterialGroupList)
  MODEL_BUILD.md

entities/bitcoinminer/
  source/Ophion.fbx     ← owner drop (archive)
  textures/             ← owner PBR sets
  bitcoin-miner.prefab  ← ModelRenderer + BitcoinMinerHubEntity + Health 250 + Rigidbody
```

## ModelDoc import (owner-verified — do not drift)

| Field | Value | Why |
|-------|-------|-----|
| **Import scale** | `0.385` (Custom) | Human-scale Ophion tower @ prefab `1,1,1` |
| **Import translation** | `0, 0, **13.3**` | Lifts mesh so origin/ground contact reads correctly (was `0` — visual culprit) |
| **Import rotation** | `0, 0, 0` | FBX export is already upright — **do not** pitch 90° |
| **Align origin** | None / None / None | Match ModelDoc screenshot; re-verify bounds after compile |
| **Source meshes** | `Vert_005`, `Circle_002` (if ModelDoc lists extras, disable junk LODs) | |

Prefab root stays **`1,1,1`**. Recompile `bitcoin-miner.vmdl` → pull `_c` to repo → flatgrass verify mesh bounds vs `BoxCollider` `10×8×15` (center Z `7.5`).

## Texture chain (3-hop — must all link)

```text
Ophion.fbx material slot  →  bitcoin-miner.vmdl remap  →  *.vmat  →  entities/bitcoinminer/textures/*  →  *_c
```

Canonical texture root for vmats: **`entities/bitcoinminer/textures/`** (has `vtex_c` in repo).  
Mirror at `models/.../source/textures/` is intake copy only — **not** what vmats reference.

Full slot map: `material-map.json` in this folder.

### Jun 2026 audit — gaps that were breaking the look

| FBX slot (in mesh) | Was remapped? | Fix |
|--------------------|---------------|-----|
| `AsusRog` | **No** → default chassis | → `bitcoin-miner-gpu.vmat` |
| `Wire weave` | **No** → default chassis | → `bitcoin-miner-wire.vmat` |
| `white-metal` | **No** → default chassis | → `bitcoin-miner-plate.vmat` |
| `Metal036` / `Metal009` | **No** (only filename variants) | → chassis / metal009 |
| `LD000548` | **No** | → plate |
| `Side Panels` | chassis (opaque) | → **acrylic** (glass) |
| `Metal036_2K_NormalGL.jpg` | missing (only NormalDX) | → chassis |
| `hexabg` | only `hexabg.png` | both → acrylic |

Unmapped slots hit **`global_default_material` = chassis** — entire GPU/cables/glass can render as flat Metal036.

### Textures shipped but not on any vmat

`Raijintek-Logo.png`, `LD0005480336_2_(1).png`, `depositphotos_…backgro.png`, `internal_ground_ao_texture.jpeg` — Blender/env leftovers; safe to ignore unless a new slot appears in ModelDoc.

## ModelDoc checklist

1. Open `bitcoin-miner.vmdl` in ModelDoc — compile `_c`.
2. Map Ophion material slots → vmat (`MaterialGroupList` remaps). Textures from owner `gaming-pc\textures` + ambientCG **Metal036/Metal009 color** maps.
3. **AnimationList:** `Ophion.fbx` is a **static mesh** (no FBX clips). `bindPose` only until owner ships a rigged fan/LED anim FBX. `GpuRackPowerAnim.ApplyHubPower` no-ops until `power_on` / `power_off` sequences exist in the compiled vmdl.
4. Prefab: `ModelRenderer` → `bitcoin-miner.vmdl`, `BitcoinMinerHubEntity`, `HealthComponent.MaxHealth = 250`, `Rigidbody` motion on + unlocked axes (match `gpu-rack` / `hacker-terminal`).

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
