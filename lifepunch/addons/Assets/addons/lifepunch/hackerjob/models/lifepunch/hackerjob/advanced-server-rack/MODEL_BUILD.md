# advanced-server-rack — vengeance-tier hacker power unit

**Slug:** `advanced-server-rack`  
**Source:** `source/advanced-server-rack.obj` + MTL (`Intake-AdvancedServerRack.ps1`)  
**Target:** `advanced-server-rack.vmdl`  
**Prefab:** `entities/advanced-server-rack/advanced-server-rack.prefab`  
**Entity:** `HackerAdvancedServerRackEntity` — upgrade caps per `HackerUpgradeCatalog` advanced max tiers  
**UI:** `HackerServerRackMenu.razor` (shared with basic rack)

## Intake

```powershell
powershell -File lifepunch/addons/scripts/Intake-AdvancedServerRack.ps1
```

Archive: `C:\lifepunch\reference-intake\hackerjob\advanced-server-rack`

## ModelDoc

1. Open `advanced-server-rack.vmdl` — import `source/advanced-server-rack.obj`.
2. Start `import_scale` at **39.37**; tune height vs basic `server-rack` (advanced mesh is taller).
3. Map MTL slots → vmats per `material-map.json`.
4. Compile → `Pull-DxrpCompiledAssetsToRepo.ps1`.

## Gameplay link

| Rack tier | Terminal preference | Max detection / puzzle tiers |
|-----------|---------------------|------------------------------|
| Basic (`server-rack`) | cornerman.exe | 4 / 4 / 3 / 3 |
| Advanced (`advanced-server-rack`) | vengeance.exe | 5 / 5 / 3 / 3 |

Registry prefers tier-matched rack within 8m horizontal / 4m vertical.

## Dev smoke

```text
lp_spawn_advanced_server_rack
lp_hacker_kit_preview
```
