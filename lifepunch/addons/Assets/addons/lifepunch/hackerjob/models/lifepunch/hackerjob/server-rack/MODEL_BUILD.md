# server-rack — hacker infrastructure power unit

**Slug:** `server-rack`  
**Source:** `source/server-rack.dae` + `source/textures/*` (owner pack — `Intake-HackerServerRack.ps1`)  
**Target:** `server-rack.vmdl`  
**Prefab:** `entities/server-rack/server-rack.prefab`  
**UI:** `HackerServerRackMenu.razor` (POWER ON/OFF + upgrades)

## Intake

```powershell
powershell -File lifepunch/addons/scripts/Intake-HackerServerRack.ps1
```

Archive: `C:\lifepunch\reference-intake\hackerjob\server-rack`

## ModelDoc

1. Open `server-rack.vmdl` — import `source/server-rack.dae`.
2. Start `import_scale` at **39.37**; tune height vs citizen + terminal desk.
3. Map `ServerMaterial` slot → PBR vmats per `material-map.json`.
4. Compile → `Pull-DxrpCompiledAssetsToRepo.ps1`.

## Gameplay link

| Rack state | Terminals within 8m horizontal / 4m vertical |
|------------|-----------------------------------------------|
| POWER ON   | cornerman.exe + vengeance.exe sessions allowed |
| POWER OFF  | CRT shows `[ OFFLINE ]` — interact denied |

Upgrades on rack apply to all linked terminals (puzzle TTL, reward, cooldown, detection).

## Dev smoke

```text
lp_spawn_server_rack
lp_hacker_kit_preview
```
