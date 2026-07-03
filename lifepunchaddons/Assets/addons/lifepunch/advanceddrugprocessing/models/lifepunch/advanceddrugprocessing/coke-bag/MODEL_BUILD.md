# coke-bag — ModelDoc

**Slug:** `coke-bag`  
**Source:** `intake-raw/source/DrugBaggieLP.fbx`  
**Textures:** `intake-raw/textures/` (see `material-map.json`)  
**Target:** `coke-bag.vmdl` in this folder

## DXRP editor (required)

```powershell
lifepunch/scripts/Start-SboxDxrpEditor.ps1 -SyncAddon advanceddrugprocessing
```

Use **DXRP `rp.sbproj` + API** — not standalone `addons.sbproj`.

## Steps

1. Import FBX; assign PBR channels from `material-map.json`.
2. Compile `coke-bag.vmdl`; verify spawn in editor.
3. Wire product prefab after weed bag mapping (`COKE_LINE_MAP.md`).
