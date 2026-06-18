# Bitcoin hub — ModelDoc foundation pass

**Mesh:** `assets/source/fbx/generic-pc-desktop.fbx` (Sketchfab generic office PC, ~2.3k verts)  
**Texture:** `assets/textures/generic-pc-desktop_basecolor.png` (single atlas from download)  
**vmdl:** `bitcoin-hub.vmdl`  
**Attribution:** Generic PC/Desktop by Bryan (Sketchfab) — CC BY

## Compile order

1. `generic-pc-desktop_basecolor.png`
2. `generic-pc-desktop.vmat`
3. `bitcoin-hub.vmdl`

```powershell
powershell -File lifepunch\scripts\Prepare-LpBitcoinModelDoc.ps1 -Entity bitcoinhub
```

ModelDoc: Asset Browser → `addons/lifepunch/lpbitcoin/bitcoinhub/assets/models/bitcoin-hub.vmdl` → F5

Play: `blank.scene` → `lp_spawn_staging_hub`

## ModelDoc settings

| Field | Value |
|-------|--------|
| import_scale | **2.4** (tune via `lp_staging_hub_scale_audit` — target ~55–65u) |
| import_rotation | 0,0,0 |
| vmdl | `bitcoin-hub.vmdl` (not cpu-gamer) |

**Retired:** Fab `cpu_gamer.fbx` / `cpu-gamer.vmdl` — do not use for hub Phase A.

Owner drop sync:

```text
UPLOAD READY ADDONS PLACEHOLDER\...\bitcoinhub\assets\source\*.fbx
UPLOAD READY ADDONS PLACEHOLDER\...\bitcoinhub\assets\textures\*.png
```

Then re-run Prepare-LpBitcoinModelDoc and compile.
