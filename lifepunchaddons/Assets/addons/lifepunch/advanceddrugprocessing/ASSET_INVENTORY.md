# Advanced Drug Processing — asset inventory

**Source pack:** `C:\Users\jared\OneDrive\Desktop\bloat\serverstuff\advanceddrugprocessing\`  
**Archive:** `C:\lifepunch\reference-intake\advanceddrugprocessing\full-export\`  
**Intake script:** `addons/scripts/Intake-AdvancedDrugProcessingAssets.ps1`

## Built in s&box (promoted to repo)

| Slug | Role | vmdl | prefab |
|------|------|------|--------|
| `coca_seed` | Plantable seed | yes | `entities/coca_seed/` |
| `coca_leaf` | Harvest / leaf stage | yes | `entities/coca_leaf/` |
| `processing_station` | Process leaf → product | yes | `entities/processing_station/` |
| `packing_station` | Pack into sellable unit | yes | `entities/packing_station/` |
| `meth_lab` | Meth line station (separate) | yes | `entities/meth_lab/` |

Mounted model paths (from prefabs): `models/lifepunch/advanceddrugprocessing/<slug>/<slug>.vmdl`

## Raw intake (ModelDoc TODO)

| Folder | Contents | Target |
|--------|----------|--------|
| `coke-bag/intake-raw/` | `DrugBaggieLP.fbx` + PBR textures | `coke-bag.vmdl` |
| `coke-brick/intake-raw/` | `Coke Brick.zip` (FBX + textures) | `coke-brick.vmdl` |

## Raw in archive only (not yet promoted)

`chemical_jar`, `chemical-barrel`, `chemical-tank`, `meth_bag`, `meth_brick`, `meth_raw` — unzip + ModelDoc when meth/chem line is scoped.

## Weed engine (DXRP class — study in editor)

Weed uses pots, strains, drying rack, packaging station, bags — see `entities/weed/` in s&box download cache.  
**Coke enhanced line** is a **processing pipeline** (seed → leaf → stations), not a 1:1 pot-grow reskin. Map portal content rows after editor spawn test.

Spec: `addons/docs/COKE_DRUG_RESKIN_SPEC.md` · Map: `COKE_LINE_MAP.md`

## DXRP sync (editor test)

```powershell
lifepunch/scripts/Sync-LifePunchAddonsToDxrp.ps1 -Addon advanceddrugprocessing
lifepunch/scripts/Start-SboxDxrpEditor.ps1 -SyncAddon advanceddrugprocessing
```
