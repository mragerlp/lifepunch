# Weapon prefab tuning — stats → DXRP components

Green owns **numeric truth** in `Code/Addons/lifepunch/<ident>/<Pascal>.cs` (`*.Stats`).
Red mirrors those values onto the cloned class prefab in the s&box editor before playtest.

## Field map

| `*.Stats` property | Prefab target | Notes |
|------------------|---------------|-------|
| `Damage` | `ShootWeaponComponent` → Damage | Per pellet for shotguns; total per shot otherwise |
| `PelletCount` | `ShootWeaponComponent` → Bullets per shot (or equivalent) | XM1014 only |
| `RoundsPerMinute` | `ShootWeaponComponent` → Fire rate | Or set `SecondsBetweenShots` = `60 / RPM` from code |
| `MagazineSize` | `AmmoComponent` → Clip size | |
| `ReserveAmmo` | `AmmoComponent` → Reserve | Starting reserve on spawn |
| `ReloadSeconds` | Reload function / anim timing | Match reload sound + anim length |
| `RangeMeters` | `ShootWeaponComponent` → Range | |
| `SpreadDegrees` | `ShootWeaponComponent` → Spread | Hip; ADS may use separate field on class |
| `RecoilPitch` | Recoil function / weapon sway | Vertical kick |
| `RecoilYaw` | Recoil function / weapon sway | Horizontal kick |
| `Automatic` | Fire mode on `ShootWeaponComponent` | `false` = semi |

Sound paths: copy from `<Pascal>.cs` (`FireSoundPath`, `ReloadSoundPath`, etc.) onto the prefab's sound slots when LifePunch assets exist.

## Workflow (Red)

1. `lp_give_<ident>` — class placeholder smoke test (hold, fire, reload).
2. Clone class `w_*` prefab → swap world model to `w_<ident>.vmdl`.
3. Open `<Pascal>.cs` side-by-side; paste stats per table above.
4. Re-test with `lp_give_<ident>` (LifePunch prefab path when shipped).
5. Opus sign-off → portal Equipment row → `prepare-publish.ps1 -Addon <ident>`.

Canon: `FAST_WEAPON_TEST.md` · `DXRP_CLASS_WEAPON_REFERENCES.md` · `RED_WEAPON_MASS_PRODUCTION_PLAN.md`
