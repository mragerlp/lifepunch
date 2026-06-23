# GPU Rack — ModelDoc

**Two ship tiers** — single rack first, stacked farm as upgrade mesh.

| Tier | vmdl | prefab | FBX |
|------|------|--------|-----|
| Single (baseline) | `gpu-rack.vmdl` | `gpu-rack.prefab` | `GPU_Farm_Anim.fbx` |
| Stacked farm | `gpu-rack-stacked.vmdl` | `gpu-rack-stacked.prefab` | `GPU_Farm_Stacked_Anim.fbx` |

**Texture roots:** `assets/textures/{Wires,GPU_Rack,Power_Supply,Motherboard,GPU_GraphicsCard}/`

## ModelDoc P0 (fresh pass)

| Step | Action |
|------|--------|
| 1 | Single: open `gpu-rack.vmdl` — FBX = `GPU_Farm_Anim.fbx`. Stacked: open `gpu-rack-stacked.vmdl` — FBX = `GPU_Farm_Stacked_Anim.fbx` (not `gpu_crypto_farm.fbx`) |
| 2 | Stacked import filter must include **`Mining_Rig_Stacked`**. Single-rack names (`FanBox_*`, `Rack_Frame`, …) do not exist in the stacked FBX. |
| 3 | Confirm remaps + five vmats compile clean (subfolder texture paths) |
## ModelDoc settings

| Field | Value |
|-------|--------|
| import_scale | **0.72** baseline — tune on flatgrass |
| import_rotation | `[0, 90, 0]` |
| Materials | See `material-map.json` + five `gpu-rack-*.vmat` |
| **use_global_default** | **`true` in KV3 for compile** (full body). Per-slot remaps bind the five ship vmats. Unchecking in ModelDoc (`false`) without 100% slot coverage → fans-only `_c` (292466 bytes). Verify branding in viewport after vmat compile. |
| Physics | HullPerElement (ModelDoc) + BoxCollider on prefab (gameplay baseline) |

## Sign-off gate (Phase C)

- [ ] Stacked mesh compiles clean (full body, not floating fans)
- [ ] PSU / GPU branding readable (EV3X, RAZX-A9, orange wires)
- [ ] Scale vs hub on flatgrass kit
- [ ] Collider matches visible mesh
