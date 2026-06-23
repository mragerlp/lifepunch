# lpbitcoin - issues

**Priority:** P0 | **Health score:** 85/100 | **Size:** 799 MB

See ASSET_CLASSIFICATION_LAW.md - do not merge this package with visually similar folders.

## Slot status

### advancedgpurack
- **Prefab slot** — stacked farm tier (`AdvancedRack=true`, ×2 yield).
- Mesh + vmats shared from `gpurack/` (`gpu-rack-stacked.vmdl`).
- Prefab: `advancedgpurack/assets/entities/advanced-gpu-rack.prefab`

### gpurack
- Role: GPU Rack (standard open-frame)
- Primary: `assets/source/fbx/gpu-rack-anim.fbx` → `assets/models/gpu-rack.vmdl`
- Stacked mesh (shared): `gpu-rack-stacked-anim.fbx` → `gpu-rack-stacked.vmdl`
- Prefab: `assets/entities/gpu-rack.prefab`

### bitcoinhub
- Role: Bitcoin HUB (admin capstone)
- Primary: assets/source/fbx/generic-pc-desktop.fbx
- Texture: assets/textures/generic-pc-desktop_basecolor.png
- vmdl: assets/models/bitcoin-hub.vmdl
- FBX/OBJ/Blend/Tex: 1/0/0/1 | ~2.3k verts (Sketchfab CC BY Bryan)
- Retired: cpu_gamer.fbx (Fab CPU GAMER — do not use for hub)
- Note: Fan spin = child GO Phase 2

### hashdterminal
- Role: HASHD Terminal
- Primary: assets/source/fbx/PC.fbx
- FBX/OBJ/Blend/Tex: 1/0/1/22 | 585.64 MB
- Issues: none flagged

## Pending ModelDoc metrics
- Triangle counts: run after vmdl compile (not available from filesystem scan)
- Scale consistency: compare spawned bounds in lifepunch-modeldoc.scene

