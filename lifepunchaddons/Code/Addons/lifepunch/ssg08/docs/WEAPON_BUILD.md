# SSG 08 — Build Checklist

Queue **#4** · Class **sniper** · Clone **M700** · Editor test: **`lp_give_ssg08`**

## Code (Green — done)

| Item | Location |
|------|----------|
| Stats + paths | `Ssg08.cs` |
| Equipment helper | `Ssg08Weapon.cs` |
| Class placeholders | `w_m700.prefab` / `vm_m700.prefab` |
| Prefab tune sheet | `addons/docs/WEAPON_PREFAB_TUNE.md` |

## Stats (mirror to prefab)

| Field | Value |
|-------|-------|
| Damage | 65 |
| RPM | 60 (semi) |
| Mag / reserve | 10 / 30 |
| Reload | 2.2s |
| Range | 180m |
| Spread | 0.6° |
| Recoil | 12 pitch / 3.0 yaw |

## Red lane

- [ ] CS2 `weapon_snip_ssg08` → Blender study → own `w_ssg08.fbx`
- [ ] `w_ssg08.vmdl` + materials under `models/lifepunch/ssg08/`
- [ ] `w_ssg08.prefab` cloned from `gameplay/equipment/weapons/m700/w_m700.prefab`
- [ ] `ViewModelPrefab` → class `vm_m700.prefab` until FP rig batch
- [ ] Tune prefab from stats table; scope / ADS behavior from M700 class
- [ ] Sounds under `sounds/`
- [ ] Killfeed icon `ui/ssg08_killfeed.png`
- [ ] `prepare-publish.ps1 -Addon ssg08`

**Pass criteria:** scout rifle — lighter than AWP-line; bolt feel; 10-round mag; semi-only; SSG mesh 3P; class M700 scope 1P until custom VM.

## Portal

Create DXRP addon package → set `dxrpAddonId` in `addons.json` → Equipment row + Gun Dealer shipment (Qty 5).
