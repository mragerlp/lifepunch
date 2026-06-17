# lppolicehacker - issues

**Priority:** P1 | **Health score:** 85/100 | **Size:** 1034.91 MB

See ASSET_CLASSIFICATION_LAW.md - do not merge this package with visually similar folders.

## Slot status

### policehackerhub
- Role: Police HUB
- Primary: game/source/obj/Sci_fi_server_rack.obj
- FBX/OBJ/Blend/Tex: 0/1/0/5 | 12.78 MB
- Fab nested pack = OBJ only, no FBX â€” OK for ModelDoc OBJ import or re-export FBX from Fab
- WARN: primary_mesh is OBJ â€” OK for ModelDoc OBJ import; prefer FBX if Fab provides one

### policehackerterminal
- Role: Police Terminal
- Primary: game/source/fbx/Terminal_TH.fbx
- FBX/OBJ/Blend/Tex: 1/0/1/29 | 1022.13 MB
- Issues: none flagged

## Pending ModelDoc metrics
- Triangle counts: run after vmdl compile (not available from filesystem scan)
- Scale consistency: compare spawned bounds in lifepunch-modeldoc.scene

