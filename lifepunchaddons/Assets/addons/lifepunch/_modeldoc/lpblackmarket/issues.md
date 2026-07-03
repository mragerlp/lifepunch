# lpblackmarket - issues

**Priority:** P2 | **Health score:** 72/100 | **Size:** 125.55 MB

See ASSET_CLASSIFICATION_LAW.md - do not merge this package with visually similar folders.

## Slot status

### blackmarkethub
- Role: Black Market Hub (Vault)
- Primary: game/source/fbx/Safe_Vault_TRIO.fbx
- FBX/OBJ/Blend/Tex: 1/0/1/12 | 31.41 MB
- Issues: none flagged

### blackmarketlocker
- Role: Black Market Locker
- Primary: game/source/fbx/SF_Locker_19.fbx
- FBX/OBJ/Blend/Tex: 1/0/0/14 | 10.23 MB
- Issues: none flagged

### blackmarketterminal
- Role: Black Market Terminal
- Primary: game/source/blend/CRT COMPUTER.blend
- FBX/OBJ/Blend/Tex: 0/0/1/6 | 83.91 MB
- No FBX in pack â€” export FBX from blend before ModelDoc OR import blend via pipeline
- BLOCKER: primary_mesh is blend-only â€” export FBX for ModelDoc or document blend import path

## Pending ModelDoc metrics
- Triangle counts: run after vmdl compile (not available from filesystem scan)
- Scale consistency: compare spawned bounds in lifepunch-modeldoc.scene

