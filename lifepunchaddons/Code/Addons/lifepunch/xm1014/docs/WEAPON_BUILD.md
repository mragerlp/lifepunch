# XM1014 — Build Checklist

Queue **#5** · Class **shotgun** · Clone **Spaghelli** · Editor test: **`lp_give_xm1014`**

## Code (Green — done)

| Item | Location |
|------|----------|
| Stats + paths | `Xm1014.cs` |
| Equipment helper | `Xm1014Weapon.cs` |
| Class placeholders | `w_spaghelli.prefab` / `vm_spaghelli.prefab` |
| Prefab tune sheet | `addons/docs/WEAPON_PREFAB_TUNE.md` |

## Stats (mirror to prefab)

| Field | Value |
|-------|-------|
| Damage | 7 × 8 pellets |
| RPM | 200 (auto) |
| Mag / reserve | 7 / 28 |
| Reload | 2.0s |
| Range | 45m |
| Spread | 6.0° |
| Recoil | 16 pitch / 3.5 yaw |

Set **`PelletCount = 8`** on prefab (`ShootWeaponComponent` bullets-per-shot).

## Red lane

- [ ] CS2 `weapon_shot_xm1014` → Blender study → own `w_xm1014.fbx`
- [ ] `w_xm1014.vmdl` + materials under `models/lifepunch/xm1014/`
- [ ] `w_xm1014.prefab` cloned from `gameplay/equipment/weapons/spaghelli/w_spaghelli.prefab`
- [ ] `ViewModelPrefab` → class `vm_spaghelli.prefab` until FP rig batch
- [ ] Tune prefab from stats table; verify pellet spread + pump/auto anim
- [ ] Sounds under `sounds/`
- [ ] Killfeed icon `ui/xm1014_killfeed.png`
- [ ] `prepare-publish.ps1 -Addon xm1014`

**Pass criteria:** 8-pellet spread; 7-shell tube; auto fire; XM1014 mesh 3P; class Spaghelli arms 1P until custom VM.

## Portal

Create DXRP addon package → set `dxrpAddonId` in `addons.json` → Equipment row + Gun Dealer shipment (Qty 5).
