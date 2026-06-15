# server-rack — hacker infrastructure power unit (Fab DataCenter)

**Slug:** `server-rack`  
**Source:** Fab [Servers (DataCenter)](https://www.fab.com/listings/ab865a8b-c6c8-4362-8998-50bc8239277d)

| Fab path | Repo |
|----------|------|
| `Servers\Model/Servers.fbx` | `source/server-rack.fbx` |
| `Servers/Texture/2K/*` | `source/textures/trim/` |
| `Glass_Cover_Material/2K/*` | `source/textures/glass/` |

**Target:** `server-rack.vmdl`  
**Prefab:** `entities/server-rack/server-rack.prefab`

## Intake

```powershell
powershell -File lifepunch/addons/scripts/Intake-HackerServerRack.ps1
```

Drop: `OneDrive\Desktop\LIFEPUNCH*\addons\lifepunchhacker\hacker\serverrack` (glass in `Materials\materials\` or `serverglassmaterial\materials\`)

Archive: `C:\lifepunch\reference-intake\hackerjob\server-rack-fab`

## ModelDoc

| Slot | vmat |
|------|------|
| `Server_Trim` | `server-rack-trim.vmat` |
| `Glass` / `Glass.002` | `server-rack-glass.vmat` |

1. Import `source/server-rack.fbx` — start `import_scale` **1.0**; tune vs citizen + terminal.
2. Compile trim + glass vmats (2K paths under `source/textures/`).
3. Door is parented mesh — wire rotation or Blender door clip after flatgrass verify.

**Compiled (Jun 2026):** trim/glass `vmat_c` + `server-rack.vmdl_c` + `prefab_c` in repo.  
**Scale audit @ import_scale 1.0:** bounds ~124×203×218 vs collider 28×28×87 — **ModelDoc scale pass TODO** on flatgrass.

## Dev smoke

```text
lp_spawn_server_rack
lp_hacker_kit_preview
```
