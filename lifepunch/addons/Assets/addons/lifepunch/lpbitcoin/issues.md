# lpbitcoin - issues

**Priority:** P0 | **Health score:** 85/100 | **Size:** 799 MB

See ASSET_CLASSIFICATION_LAW.md - do not merge this package with visually similar folders.

## Slot status

### advancedgpurack
- **Retired slot** — merged into `gpurack/` (single stacked farm tier).
- Do not add assets under `_archive/advancedgpurack-intake/` except docs/source.
- Canonical: `gpurack/assets/models/gpu-rack-stacked.vmdl` + `gpurack/assets/entities/gpu-rack.prefab`

### bitcoinhub
- Role: Bitcoin HUB (admin capstone)
- Primary: assets/source/fbx/generic-pc-desktop.fbx
- Texture: assets/textures/generic-pc-desktop_basecolor.png
- vmdl: assets/models/bitcoin-hub.vmdl
- FBX/OBJ/Blend/Tex: 1/0/0/1 | ~2.3k verts (Sketchfab CC BY Bryan)
- Retired: cpu_gamer.fbx (Fab CPU GAMER — do not use for hub)
- Note: Fan spin = child GO Phase 2

### gpurack
- Role: GPU Rack (standard)
- Primary: assets/source/obj/GPU_Farm_Static.obj
- FBX/OBJ/Blend/Tex: 0/1/1/32 | 34.61 MB
- Confirm static OBJ vs blend export for ModelDoc body
- WARN: primary_mesh is OBJ â€” OK for ModelDoc OBJ import; prefer FBX if Fab provides one
- Note: No static FBX in Fab pack â€” static OBJ + blend are source of truth
- Note: Anim FBX archived under assets/source/fbx/_reference_anim for fan study only

### hashdterminal
- Role: HASHD Terminal
- Primary: assets/source/fbx/PC.fbx
- FBX/OBJ/Blend/Tex: 1/0/1/22 | 585.64 MB
- Issues: none flagged

## Pending ModelDoc metrics
- Triangle counts: run after vmdl compile (not available from filesystem scan)
- Scale consistency: compare spawned bounds in lifepunch-modeldoc.scene

