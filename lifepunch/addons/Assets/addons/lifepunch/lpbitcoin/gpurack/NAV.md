# gpurack — GPU Rack

Fresh art lives under `assets/textures/{Wires,GPU_Rack,Power_Supply,Motherboard,GPU_GraphicsCard}/`.

## Two prefabs (Jun 2026)

| Tier | Prefab | ModelDoc | FBX source | Role |
|------|--------|----------|------------|------|
| **Single rack** (baseline) | `assets/entities/gpu-rack.prefab` | `assets/models/gpu-rack.vmdl` | `assets/source/GPU_Farm_Anim.fbx` | One open-frame rack — perfect this first |
| **Stacked farm** (upgrade) | `assets/entities/gpu-rack-stacked.prefab` | `assets/models/gpu-rack-stacked.vmdl` | `assets/source/GPU_Farm_Stacked_Anim.fbx` | Four-tier farm mesh |

Shared: five `gpu-rack-*.vmat` · `material-map.json` · `LpBitcoinRackEntity` gameplay.

**Do not open:** `assets/source/gpu_crypto_farm.fbx` — Blender master export with artist scale-reference human; not used by ship vmdls.

**Spawn / ident:** `LpBitcoinIdent.RackPrefabPath` → **`gpu-rack.prefab`** (single). Stacked via `gpu-rack-stacked.prefab` when economy upgrade ships.
