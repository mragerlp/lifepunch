# Desert Eagle — Build Checklist

Queue **#2** · Class **handgun** · Clone **USP** · Editor test: **`lp_give_deagle`**

## Code (Green — done)

| Item | Location |
|------|----------|
| Stats + paths | `Deagle.cs` |
| Equipment helper | `DeagleWeapon.cs` |
| Class placeholders | `w_usp.prefab` / `vm_usp.prefab` |
| Prefab tune sheet | `addons/docs/WEAPON_PREFAB_TUNE.md` |

## Stats (mirror to prefab)

| Field | Value |
|-------|-------|
| Damage | 55 |
| RPM | 267 (semi) |
| Mag / reserve | 7 / 35 |
| Reload | 2.0s |
| Range | 75m |
| Spread | 2.5° |
| Recoil | 4.5 pitch / 1.8 yaw |

## Red lane

- [ ] CS2 `weapon_pist_deagle` → Blender study → own `w_deagle.fbx`
- [ ] `w_deagle.vmdl` + materials under `models/lifepunch/deagle/`
- [ ] `w_deagle.prefab` cloned from `gameplay/equipment/weapons/usp/w_usp.prefab`
- [ ] `ViewModelPrefab` → class `vm_usp.prefab` until FP rig batch
- [ ] Tune prefab from stats table; verify muzzle / ejection offsets
- [ ] Sounds under `sounds/` (fire, reload, draw, distant)
- [ ] Killfeed icon `ui/deagle_killfeed.png`
- [ ] `prepare-publish.ps1 -Addon deagle`

**Pass criteria:** heavy pistol feel vs USP; 7-round mag; semi-only; visible Deagle mesh 3P; class USP arms 1P until custom VM.

## Portal

Create DXRP addon package → set `dxrpAddonId` in `addons.json` → Equipment row + Gun Dealer shipment (Qty 5).
