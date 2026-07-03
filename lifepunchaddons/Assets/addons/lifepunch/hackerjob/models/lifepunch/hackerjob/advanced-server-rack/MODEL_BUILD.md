# advanced-server-rack — vengeance-tier hacker power unit (Fab rows)

**Slug:** `advanced-server-rack`  
**Source:** Same Fab pack as basic rack — `Servers/Model/Servers_Rows.fbx` (multi-cabinet row); **reuses** trim + glass from basic intake  
**Target:** `advanced-server-rack.vmdl`  
**Prefab:** `entities/advanced-server-rack/advanced-server-rack.prefab`

| Fab path | Repo |
|----------|------|
| `Servers/Model/Servers_Rows.fbx` | `source/advanced-server-rack.fbx` |
| `Servers/Texture/2K/*` | shared → `source/textures/trim/` |
| `Glass_Cover_Material/2K/*` | shared → `source/textures/glass/` |

## Intake

```powershell
powershell -File lifepunchaddons/scripts/Intake-AdvancedServerRack.ps1
```

Runs basic rack intake first (shared trim/glass textures), then copies `Servers_Rows.fbx` → `advanced-server-rack.fbx`.

Archive: `C:\lifepunch\reference-intake\hackerjob\advanced-server-rack-fab`

## ModelDoc

Reuses `server-rack-trim.vmat` + `server-rack-glass.vmat` + **`server-rack.vmat`** (`ServerMaterial`). Import `source/advanced-server-rack.fbx` — **`import_scale` 0.399** (same cabinet height as basic row unit).

**Compiled (Jun 2026):** `advanced-server-rack.vmdl_c` + `prefab_c` in repo (recompile after scale pass).  
**Scale @ import_scale 0.399:** mesh ~**164×94×87** · prefab collider **164×94×87** center `0,0,43.5`.

## Dev smoke

```text
lp_spawn_advanced_server_rack
lp_hacker_kit_preview
```
