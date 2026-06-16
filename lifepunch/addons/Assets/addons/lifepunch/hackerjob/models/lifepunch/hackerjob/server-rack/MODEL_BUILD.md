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
| `ServerMaterial` | `server-rack.vmat` |
| `Glass` / `Glass.002` | `server-rack-glass.vmat` |

1. Import `source/server-rack.fbx` — **`import_scale` 0.399** (Fab cm mesh · height ~87u vs collider Z=87).
2. Material remaps: `Server_Trim` → trim vmat · `ServerMaterial` → **`server-rack.vmat`** · `Glass*` → glass vmat.
3. Compile trim + glass + body vmats (2K paths under `source/textures/`).
4. Door is parented mesh — wire rotation or Blender door clip after flatgrass verify.

**Compiled (Jun 2026):** trim/glass/body `vmat_c` + `server-rack.vmdl_c` + `prefab_c` in repo (recompile after scale pass).  
**Scale @ import_scale 0.399:** mesh height ~**87u** (collider Z) · XY mesh wider than tight 28×28 hitbox (intentional).

## Dev smoke

```text
lp_spawn_server_rack
lp_hacker_kit_preview
```
