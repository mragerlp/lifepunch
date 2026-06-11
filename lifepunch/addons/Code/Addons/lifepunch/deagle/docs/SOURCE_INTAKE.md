# Desert Eagle — Source Intake

## CS2 reference intake (study only)

| Item | Value |
|------|-------|
| VPK path | `weapons/models/deagle/` |
| Mesh | `weapon_pist_deagle` |
| Intake folder | `C:/lifepunch/reference-intake/cs2-weapons/deagle/` |
| glTF (Red) | `viewmodel/`, `world/`, `sounds/` under intake folder |
| Animation catalog | `MANIFEST.txt` § `animations_seen` — Red S2V fill |
| Texture channels | Note glTF slot names vs planned `deagle_body.vmat` (study only) |

Classify all CS2 exports: **reference-only** — never ship in LifePunch addons.  
**Ship FP:** USP class kit (`vm_usp` / shared animgraph) until own rig — see `VIEWMODEL_RIG_PIPELINE.md`.

## DXRP class kit

| Field | Value |
|-------|-------|
| Class | handgun |
| Reference weapon | usp |
| World placeholder | `gameplay/equipment/weapons/usp/w_usp.prefab` |
| Viewmodel placeholder | `gameplay/equipment/weapons/usp/vm_usp.prefab` |

## LifePunch paths

See `Deagle.cs` constants and `Assets/addons/lifepunch/deagle/README.md`.  
Stats reference: `addons/docs/reference/USP_CLASS_STATS.md` · Model build: `w_deagle/MODEL_BUILD.md`.
