# GPU Rack (small) — ModelDoc foundation pass

**Source:** `assets/source/fbx/gpu-rack-anim.fbx` (canonical copy from Fab anim export)  
**vmdl:** `assets/models/gpu-rack.vmdl`  
**Phase:** C — GPU Rack (Model Foundation)

## ModelDoc settings (v1)

| Field | Value |
|-------|--------|
| import_scale | 0.395 |
| import_rotation | 0, 90, 0 |
| align | Center / Center / Bottom |
| Materials | Cord, PSU, Rack, Motherboard, GPU (see `material-map.json`) |
| Physics | HullPerElement, max 32 verts |

## Notes

- Textures live flat under `assets/textures/` (PNG).
- Legacy reference: `bitcoinmining/.../gpu-rack/` — patterns only, do not sync back.
- Fan animation is Phase 2 (child GO spin or anim graph after static mesh sign-off).

## Sign-off gate (Phase C — small rack)

- [ ] Compiles clean
- [ ] GPU emission readable when mining on
- [ ] Scale vs hub on flatgrass kit
- [ ] Owner OK before prefab wire
