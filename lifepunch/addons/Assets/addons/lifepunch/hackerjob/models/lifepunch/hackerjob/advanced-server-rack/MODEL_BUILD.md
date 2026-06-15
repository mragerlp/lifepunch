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
powershell -File lifepunch/addons/scripts/Intake-AdvancedServerRack.ps1
```

Runs basic rack intake first (shared trim/glass textures), then copies `Servers_Rows.fbx` → `advanced-server-rack.fbx`.

Archive: `C:\lifepunch\reference-intake\hackerjob\advanced-server-rack-fab`

## ModelDoc

Reuses `server-rack-trim.vmat` + `server-rack-glass.vmat` remaps. Import `source/advanced-server-rack.fbx` — scale vs basic single cabinet on flatgrass.

**Compiled (Jun 2026):** `advanced-server-rack.vmdl_c` + `prefab_c` in repo.  
**Scale audit @ import_scale 1.0:** bounds ~232×410×218 vs collider 24×24×56 — **ModelDoc scale pass TODO**.

## Dev smoke

```text
lp_spawn_advanced_server_rack
lp_hacker_kit_preview
```
