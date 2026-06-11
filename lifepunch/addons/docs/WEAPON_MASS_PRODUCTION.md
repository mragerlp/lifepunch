# Weapon Mass Production

Operational queue for the **5 Gun Dealer classes**. Canon strategy: `WEAPON_PROGRAM.md`. Per-class build steps: `WEAPON_CLASS_SPEC.md`.

## Queue

| # | LifePunch ident | Gun Dealer class | DXRP kit clone | CS2 reference mesh | Status |
|---|-----------------|------------------|----------------|--------------------|--------|
| 1 | `ak47` | Assault Rifle | `m4a1` | `weapon_rif_ak47` | **Active kit** (golden reference) |
| 2 | `deagle` | Handgun | `usp` | `weapon_pist_deagle` | `foundation-scaffold` |
| 3 | `mp9` | SMG | `mp5` | `weapon_smg_mp9` | `foundation-scaffold` |
| 4 | `ssg08` | Sniper | `m700` | `weapon_snip_ssg08` | `foundation-scaffold` |
| 5 | `xm1014` | Semi-auto shotgun | `spaghelli` | `weapon_shot_xm1014` | `foundation-scaffold` |

Machine-readable copy: `config/weapon-production.json`.

## Commands

```powershell
# Scaffold all four new kits (skips AK golden kit)
powershell -NoProfile -ExecutionPolicy Bypass -File lifepunch/addons/scripts/Start-WeaponMassProduction.ps1

# One weapon
powershell -NoProfile -ExecutionPolicy Bypass -File lifepunch/addons/scripts/New-LifePunchWeapon.ps1 -Ident deagle

# Refresh code/docs after script changes
powershell -NoProfile -ExecutionPolicy Bypass -File lifepunch/addons/scripts/New-LifePunchWeapon.ps1 -Ident mp9 -Force
```

## Per-weapon lane (repeat for #2–5)

1. **CS2 reference** — Source 2 Viewer → glTF into `C:/lifepunch/reference-intake/cs2-weapons/<ident>/` (never commit).
2. **Own FBX** — Blender study → `Assets/.../w_<ident>/source/`.
3. **World model** — `w_<ident>.vmdl` + materials (`MODEL_BUILD.md`, `material-map.json`).
4. **Prefabs** — Clone DXRP class `w_*` / `vm_*` in editor; save under `equipment/`.
5. **Stats** — Tune `<Pascal>.cs` from class reference; wire Functions on prefab.
6. **Manifest** — Fill `addons.json` content row; create portal package → set `dxrpAddonId`.
7. **Publish** — `prepare-publish.ps1 -Addon <ident>` → portal upload → Gun Dealer shipment (`Quantity=5`).

## What each scaffold ships

- Asset folder tree (`equipment/`, `models/`, `sounds/`, `ui/`)
- Code stubs (`<Pascal>.cs`, `<Pascal>Weapon.cs`) with path constants + zeroed stats
- `docs/SOURCE_INTAKE.md`, `docs/WEAPON_BUILD.md`
- Empty `addons.json` content row (portal + publish TBD)

Viewmodel: use **class placeholder** (`vm_<classRef>`) until FP rig batch (same as AK baseline).
