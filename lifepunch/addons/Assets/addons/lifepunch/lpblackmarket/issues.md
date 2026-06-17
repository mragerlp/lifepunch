# lpblackmarket - issues

**Priority:** P2 | **Health score:** (re-audit after register intake) | **Size:** see audit/manifest.json

See ASSET_CLASSIFICATION_LAW.md - do not merge this package with visually similar folders.

## Entity roles (Jun 2026 owner law)

| Slot | Role |
|------|------|
| `blackmarkethub` | Vault / infrastructure hub |
| `blackmarketterminal` | BM ops CRT (when wired) |
| `blackmarketregister` | **BTC checkout** → customer receives spawnable entities through **DXRP market** |
| `blackmarketlocker` | **Weapon storage / customization** — regular prop; not payment |

## Slot status

### blackmarkethub
- Role: Black Market Hub (Vault)
- Primary: assets/source/fbx/Safe_Vault_TRIO.fbx
- FBX/OBJ/Blend/Tex: 1/0/1/12 | 31.41 MB
- Issues: none flagged

### blackmarketregister
- Role: Black Market Register (BTC → market grant)
- Primary: assets/source/blend/CashRegister-00.blend
- Owner drop: `UPLOAD READY ADDONS\lpblackmarket\blackmarketregister`
- No FBX in pack — export FBX from blend before ModelDoc OR import blend via pipeline

### blackmarketlocker
- Role: Black Market Locker (weapon storage / customization)
- Primary: assets/source/fbx/SF_Locker_19.fbx
- FBX/OBJ/Blend/Tex: 1/0/0/14 | 10.23 MB
- Issues: none flagged

### blackmarketterminal
- Role: Black Market Terminal
- Primary: assets/source/blend/CRT COMPUTER.blend
- FBX/OBJ/Blend/Tex: 0/0/1/6 | 83.92 MB
- No FBX in pack — export FBX from blend before ModelDoc OR import blend via pipeline
- BLOCKER: primary_mesh is blend-only — export FBX for ModelDoc or document blend import path

## Pending ModelDoc metrics
- Triangle counts: run after vmdl compile (not available from filesystem scan)
- Scale consistency: compare spawned bounds in lifepunch-modeldoc.scene
