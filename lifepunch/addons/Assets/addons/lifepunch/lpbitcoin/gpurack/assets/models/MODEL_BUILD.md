# GPU Rack (single open frame) — ModelDoc

**Phase C (Jun 2026):** Dual-rack economy — standard open-frame first, stacked farm as **Advanced GPU Rack** (`advancedgpurack/` prefab, shared vmats).

**Fab listing:** [Crypto Farm / Mining Rig](https://www.fab.com/listings/9c8621e4-43c6-4d42-8859-bf2fb9f3ff) (Michael Vest) — same asset family as Sketchfab crypto farm rig.

**Canonical play vmdl:** `lpbitcoin/gpurack/assets/models/gpu-rack.vmdl`  
**Canonical prefab:** `lpbitcoin/gpurack/assets/entities/gpu-rack.prefab`  
**Canonical source FBX:** `assets/source/fbx/gpu-rack-anim.fbx` (`GPU_Farm_Anim.fbx` in owner drop)

## Fresh start (owner drop → repo → DXRP)

**Owner canonical raw art** (nested textures, original FBX names — do not flatten here):

```text
OneDrive\Desktop\addon test\addons\lifepunch\lpbitcoin\gpurack\
  assets\source\GPU_Farm_Anim.fbx
  assets\source\GPU_Farm_Stacked_Anim.fbx
  assets\source\GPU_Farm_Static.obj
  assets\source\gpu_crypto_farm.blend
  assets\textures\{GPU_GraphicsCard, GPU_Rack, Motherboard, Power_Supply, Wires}\
```

**One command** when repo/DXRP drift:

```powershell
powershell -File lifepunch\addons\scripts\Reset-LpBitcoinGpuRackFromOwnerDrop.ps1 -SyncDxrp
```

Then **Stop → Play**, recompile vmats → `gpu-rack.vmdl` → `gpu-rack-stacked.vmdl` → both prefabs.

## How the Fab pack is structured

| Owner drop file | Repo alias | Role |
|-----------------|------------|------|
| `GPUFarmAnim.fbx` | `gpu-rack-anim.fbx` | **Ship mesh** — 21 named Blender objects, 5 material slots |
| `GPUFarmStatic.obj` | `gpu-farm-static.obj` | Static reference / collision study |
| `GPUFarmStackedAnim.fbx` | `gpu-rack-stacked-anim.fbx` | **Advanced tier** — `advanced-gpu-rack.prefab` + `gpu-rack-stacked.vmdl` |
| Texture folders | Flat `assets/textures/*.png` | Cord, PSU, Rack, Motherboard, GraphicsCard → GPU |

### Single rack FBX (what we ship now)

Five **material slots** on one assembled rig:

1. **Cord** — `Wires_Cord`
2. **PSU** — `PSU_Power`
3. **Rack** — `Rack_Frame`, `FanBox_1–5`, `FanBlades.005–009`
4. **Motherboard** — `Motherboard_Base`
5. **GPU** — `GPU_GraphicsCard`, `GPU_Fan_1–6`

ModelDoc maps those five slots to five vmats. Do **not** split fans into separate vmdls.

### Stacked FBX (parked)

`Mining_Rig_Stacked` merges the body into one mesh with submesh material slots — fan blades duplicate (.001, .002). Import filters written for the single rack **drop the stacked body** if reused blindly. Revisit only after single rack flatgrass sign-off.

## ModelDoc settings (single — reference)

| Field | Value |
|-------|--------|
| `import_scale` | **0.395** |
| `import_translation` | `[0, 0, 21.382]` — lifts bottom toward ground after Y90° |
| `import_rotation` | `[0, 90, 0]` |
| Materials | Cord, PSU, Rack, Motherboard, GPU → see `material-map.json` |
| `import_filter` | `exclude_by_default = true` + exception list matching FBX object names |
| FanBlades slots | `use_global_default` → rack vmat (no `FanBlades.*` dot remaps) |
| Physics | `HullPerElement` |

## Animations (Phase C+)

`gpu-rack-anim.fbx` ships mesh-only today (`bones=0`). Target sequences: `power_on` / `power_off` for fan spin at mining state (`BITCOINMINING-01`). Rig export: `Export-GpuRackAnimFbx.ps1` — see legacy `MODEL_BUILD` under `_archive/bitcoinmining-legacy-assets/.../gpu-rack/`.

## Prefab collider

Tune on flatgrass via `lp_bitcoin_scale_audit` → bake `Model.Bounds` into prefab JSON. Seed values in prefab are approximate for single rack (smaller than stacked).

## Sign-off gate (Phase C — single rack)

- [ ] Full body visible (not fans-only)
- [ ] All five vmats compile and mount
- [ ] GPU emission readable when mining
- [ ] Scale vs citizen on flatgrass
- [ ] Collider matches visible frame

**Stacking:** economy slots / stacked mesh upgrade → `BITCOINMINING-07` after this gate passes.
