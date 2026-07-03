# DXRP Class Weapon References

Extracted from [mragerlp/dxrp-public `develop`](https://github.com/mragerlp/dxrp-public/tree/develop) prefabs for LifePunch mass-production tuning. **Do not copy Facepunch library meshes into LifePunch packages.**

LifePunch CS2 skins map to these classes per `config/weapon-production.json`.

| LifePunch ident | DXRP class | Prefab |
|-----------------|------------|--------|
| `deagle` | `usp` | [`w_usp.prefab`](https://github.com/mragerlp/dxrp-public/blob/develop/game/Assets/gameplay/equipment/weapons/usp/w_usp.prefab) |
| `mp9` | `mp5` | [`w_mp5.prefab`](https://github.com/mragerlp/dxrp-public/blob/develop/game/Assets/gameplay/equipment/weapons/mp5/w_mp5.prefab) |
| `ssg08` | `m700` | [`w_m700.prefab`](https://github.com/mragerlp/dxrp-public/blob/develop/game/Assets/gameplay/equipment/weapons/m700/w_m700.prefab) |
| `xm1014` | `spaghelli` | [`w_spaghelli.prefab`](https://github.com/mragerlp/dxrp-public/blob/develop/game/Assets/gameplay/equipment/weapons/spaghelli/w_spaghelli.prefab) |
| `ak47` | `m4a1` | [`M4A1_REFERENCE.md`](M4A1_REFERENCE.md) |

## USP (Handgun — Deagle class)

| Field | Value |
|-------|-------|
| HoldType | `Pistol` |
| Model child position | `3.20348, 0.622, -3.676` |
| Library world model | `models/weapons/sbox_pistol_usp/w_usp.vmdl` |
| MaxAmmo / MaxReserve | 13 / 52 |
| BaseDamage | 25 |
| FireRate | 600 (Delay 0.2 semi) |
| ReloadTime / EmptyReload | 1.5 / 2.0 |
| Recoil vertical / horizontal | 2 / ±1.4 |
| Muzzle (Model child) | `4.32, 0, 4.76` |

**Deagle bias:** higher damage, smaller mag, heavier recoil — see `Deagle.cs` Stats.

## MP5 (SMG — MP9 class)

| Field | Value |
|-------|-------|
| HoldType | `Rifle` |
| Model child position | `3.273, 1.145, -7.111` |
| Library world model | `models/weapons/sbox_smg_mp5/w_mp5.vmdl` |
| MaxAmmo / MaxReserve | 30 / 120 |
| BaseDamage | 12 |
| FireRate | 740 (Automatic) |
| ReloadTime / EmptyReload | 1.5 / 2.0 |
| Recoil vertical / horizontal | 3.5 / ±2 |
| Muzzle (Model child) | `13.30, 0, 8.15` (scale ~0.77) |

**MP9 bias:** similar ROF, slightly lower per-shot damage — see `Mp9.cs` Stats.

## M700 (Sniper — SSG 08 class)

| Field | Value |
|-------|-------|
| HoldType | `Rifle` |
| Model child position | `2.888, 1.646, -6.576` |
| Library world model | `models/weapons/sbox_sniper_m700/w_m700.vmdl` |
| MaxAmmo / MaxReserve | 6 / 24 |
| BaseDamage | 80 |
| FireRate | ~28 (semi bolt) |
| ReloadTime | 1.9 |
| Recoil vertical / horizontal | 20 / ±3 |
| Muzzle (Model child) | `20.08, 0, 7.21` |
| Extra components | Scope, BoltPusher, ScreenShake |

**SSG 08 bias:** scout rifle — larger mag, faster follow-up, lower body damage — see `Ssg08.cs` Stats.

## Spaghelli (Shotgun — XM1014 class)

| Field | Value |
|-------|-------|
| HoldType | `Shotgun` |
| Model child position | `2.659, 2.052, -9.009` |
| Library world model | `models/weapons/sbox_shotgun_spaghellim4/w_spaghellim4.vmdl` |
| MaxAmmo / MaxReserve | 6 / 24 |
| BaseDamage (per pellet) | 8 |
| BulletCount | 10 |
| BulletSpread | 0.13 |
| FireRate | 175 (Automatic) |
| ReloadTime | 1.0 (SingleReload) |
| Recoil vertical / horizontal | 20 / ±3 |

**XM1014 bias:** 7-round mag, 8 pellets, semi-auto feel — see `Xm1014.cs` Stats.

## Editor clone checklist (Red / VENGEANCE)

1. Open class `w_*` prefab from DXRP install side-by-side with LifePunch `w_<ident>.prefab`.
2. Copy **Functions** child components (Ammo, Shoot, Reload, Recoil, ViewPunch, class-specific).
3. Swap `Model` child to LifePunch `w_<ident>.vmdl`; retune grip using class offsets above.
4. Point `ViewModelPrefab` at class `vm_*` placeholder until FP rig batch.
5. Tune prefab values against `<Pascal>.cs` Stats — code constants are the tuning sheet until portal ship.
