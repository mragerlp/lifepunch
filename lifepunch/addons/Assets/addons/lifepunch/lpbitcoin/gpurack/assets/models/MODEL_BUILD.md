# GPU Rack (farm / stacked mesh) — ModelDoc

**Executive decision Jun 2026:** One ship tier — **GPU Rack** = stacked farm mesh. Small open-frame `gpu-rack.vmdl` in this folder is archived intent only (`_archive/small-open-frame/`).

**Canonical play vmdl:** `bitcoinmining/models/lifepunch/bitcoinmining/gpu-rack/gpu-rack-stacked.vmdl`  
**Canonical source FBX:** `assets/textures/GPU_Farm_Stacked_Anim.fbx` (also under `advancedgpurack/` staging copy)

## Blender / art — owner action

**No Blender work required** for the rename/consolidation. The stacked farm mesh is already the product.

Future **stacking upgrade visuals** (1→2→3 unit tiers in one entity) are tracked in `BITCOINMINING-07` — that is when you revisit Blender/bodygroups or alternate vmdls.

## ModelDoc settings (stacked — reference)

| Field | Value |
|-------|--------|
| import_scale | TBD on flatgrass sign-off |
| Materials | Cord, PSU, Rack, Motherboard, GPU (see `material-map.json`) |
| Physics | HullPerElement |

## Sign-off gate (Phase C)

- [ ] Stacked mesh compiles clean
- [ ] GPU emission readable when mining on
- [ ] Scale vs hub on flatgrass kit (max 3 racks)
- [ ] Prefab rename to `bitcoinmining/entities/gpurack/gpu-rack.prefab`
