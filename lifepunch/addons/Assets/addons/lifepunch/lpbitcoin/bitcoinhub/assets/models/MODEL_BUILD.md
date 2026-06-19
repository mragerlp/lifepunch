# Bitcoin hub — ModelDoc foundation pass

**Phase A pivot (2026-06-19):** Ship hub = **Steam Machine** `bitcoin-miner.vmdl` (materials + prefab wired). Sketchfab `bitcoin-hub.vmdl` parked — custom texture mount unreliable in play.

**Retired for hub:** `generic-pc-desktop.fbx` / `bitcoin-hub.vmdl` — keep for reference only until texture pipeline fixed.

---

# Archived — Sketchfab generic PC (parked)

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
| import_scale | **75.4** (bridge verified 2026-06-18 @ blank.scene: bounds **59.95 × 29.52 × 57.93** — target ~55–65u) |
| import_rotation | 0,0,0 |
| vmdl | `bitcoin-hub.vmdl` (not cpu-gamer) |

**Retired:** Fab `cpu_gamer.fbx` / `cpu-gamer.vmdl` — do not use for hub Phase A.

Owner drop sync:

```text
UPLOAD READY ADDONS PLACEHOLDER\...\bitcoinhub\assets\source\*.fbx
UPLOAD READY ADDONS PLACEHOLDER\...\bitcoinhub\assets\textures\*.png
```

Then re-run Prepare-LpBitcoinModelDoc and compile.
