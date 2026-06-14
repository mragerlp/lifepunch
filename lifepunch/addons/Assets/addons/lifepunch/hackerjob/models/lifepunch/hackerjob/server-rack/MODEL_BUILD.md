# server-rack — hacker infrastructure power unit

**Slug:** `server-rack`  
**Source:** `source/server-rack.obj` (converted from DAE — ModelDoc does not load Collada) + `source/textures/*`  
**Target:** `server-rack.vmdl`  
**Prefab:** `entities/server-rack/server-rack.prefab`  
**UI:** `HackerServerRackMenu.razor` (POWER ON/OFF + upgrades)

## Intake

```powershell
powershell -File lifepunch/addons/scripts/Intake-HackerServerRack.ps1
```

Archive: `C:\lifepunch\reference-intake\hackerjob\server-rack`

## ModelDoc

1. Open `server-rack.vmdl` — imports `source/server-rack.obj` (regenerate from DAE via `addons/scripts/blender/convert_server_rack_dae_to_fbx.py` or `trimesh` if intake updates the DAE).
2. Start `import_scale` at **39.37**; tune height vs citizen + terminal desk.
3. Map `ServerMaterial` slot → PBR vmats per `material-map.json`.
4. Compile → `Pull-DxrpCompiledAssetsToRepo.ps1`.

## Gameplay link

| Rack state | Terminals within 8m horizontal / 4m vertical |
|------------|-----------------------------------------------|
| POWER ON   | Linked terminals within range can open sessions |
| POWER OFF  | CRT shows `[ OFFLINE ]` — interact denied |

**Basic rack** powers cornerman.exe (standard CRT). **Advanced rack** (`advanced-server-rack/`) powers vengeance.exe with higher upgrade caps — see `advanced-server-rack/MODEL_BUILD.md`.

Re-run intake if `source/textures/` is empty:

```powershell
powershell -File lifepunch/addons/scripts/Intake-HackerServerRack.ps1 -SourceRoot "$env:USERPROFILE\OneDrive\Desktop\serverrack"
```

## Dev smoke

```text
lp_spawn_server_rack
lp_hacker_kit_preview
```
