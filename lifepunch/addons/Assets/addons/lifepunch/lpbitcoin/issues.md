# lpbitcoin - issues

**Priority:** P0 | **Health score:** 85/100 | **Size:** 799 MB

See ASSET_CLASSIFICATION_LAW.md - do not merge this package with visually similar folders.

## Slot status

### advancedgpurack
- Role: Advanced GPU Rack (stacked)
- Primary: assets/source/fbx/GPU_Farm_Stacked_Anim.fbx
- FBX/OBJ/Blend/Tex: 1/0/1/32 | 33.41 MB
- Stacked anim FBX only â€” may need static stacked export from blend
- Note: Stacked variant split from gpurack slot
- Note: Use static body in ModelDoc â€” not anim rig as body

### bitcoinhub
- Role: Bitcoin HUB (CPU GAMER)
- Primary: assets/source/fbx/cpu_gamer.fbx
- FBX/OBJ/Blend/Tex: 1/0/1/0 | 145.34 MB
- Issues: none flagged
- Note: Solid colors in source — vmats in ModelDoc
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

