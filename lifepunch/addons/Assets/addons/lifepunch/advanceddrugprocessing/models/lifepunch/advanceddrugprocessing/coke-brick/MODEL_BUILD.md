# coke-brick — ModelDoc

**Slug:** `coke-brick`  
**Source:** `intake-raw/source/Coke Brick.fbx` (extracted from zip)  
**Textures:** `intake-raw/textures/cokebrick.png`, `cokebrick_n.png`  
**Target:** `coke-brick.vmdl` in this folder

## DXRP editor (required)

```powershell
lifepunch/scripts/Start-SboxDxrpEditor.ps1 -SyncAddon advanceddrugprocessing
```

## Steps

1. Import `Coke Brick.fbx`; normal + albedo from `material-map.json`.
2. Compile `coke-brick.vmdl`; verify scale vs weed bulk product if any.
3. Portal content row TBD (`COKE_LINE_MAP.md`).
