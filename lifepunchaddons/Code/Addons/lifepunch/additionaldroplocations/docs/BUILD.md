# Additional Drop Locations — Build checklist

## Phase 1 — Code (Cornerman / Green)

- [x] `AdditionalDropLocations.cs` — site constants (`Enabled: false` until coords set)
- [x] `AdditionalDropLocationsService.cs` — spawn `prefabs/world/drug_drop.prefab` on `OnMapFitted`
- [x] `config/drop-sites.json` — config mirror
- [x] Reference intake script + subway/truck archive on disk

## Phase 2 — VENGEANCE (Red)

1. Pull Green commits; open DXRP editor on target map.
2. Place subway + truck props (or markers) at intended sell locations; record `Vector3` + `Rotation`.
3. Update `AdditionalDropLocations.Sites` in `AdditionalDropLocations.cs` (+ `drop-sites.json`).
4. Set `Enabled: true` for validated sites.
5. **Opus review** (economy-touching).
6. Blender → own FBX → ModelDoc for cosmetic props (optional polish).
7. Portal package → set `dxrpAddonId` in `addons.json`.
8. `prepare-publish.ps1 -Addon additionaldroplocations`

## Reference intake

```powershell
powershell -File lifepunchaddons/scripts/Intake-AdditionalDropLocations.ps1
```

Subway logo: replace `London_Underground_logo_PNG3.png` before any public ship.
