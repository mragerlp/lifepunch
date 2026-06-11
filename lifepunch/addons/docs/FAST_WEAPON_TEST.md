# Fast weapon test (editor, no portal Equipment row)

Use these **dev-only** console commands while the LifePunch addon is mounted in the DXRP editor project.
They clone prefabs directly — excluded from publish (`_dev/WeaponDevGive.cs`).

## AK-47 (LifePunch kit + custom viewmodel)

```text
lp_give_ak
```

- World: `addons/lifepunch/ak47/equipment/w_ak47/w_ak47.prefab`
- First person: `vm_ak47.prefab` (M4 rig driver + bonemerged `v_ak47.vmdl` + invisible M4 master)
- Third person: `w_ak47` hold offsets synced from M4 class reference (2026-06-11)

**Pass criteria:** arms + textured AK in lower-right; no visible M4 mesh; muzzle flash at barrel; reload anim plays.

## Queue weapons #2–5 (class placeholder until LifePunch prefabs ship)

| Console | Class VM | Until Red ships |
|---------|----------|-----------------|
| `lp_give_deagle` | USP | `w_deagle` + CS2 mesh |
| `lp_give_mp9` | MP5 | `w_mp9` |
| `lp_give_ssg08` | M700 | `w_ssg08` |
| `lp_give_xm1014` | Spaghelli | `w_xm1014` |

Generic: `lp_give_weapon deagle`

Each command uses the **LifePunch prefab** when it exists on disk; otherwise falls back to the **DXRP class** `w_*` prefab so you can test hold type, shoot, and class viewmodel immediately.

## Red lane (guns in faster)

1. **CS2 export on VENGEANCE** — `Intake-Cs2WeaponReference.ps1` → Blender FBX → `w_<ident>.vmdl`
2. **Clone class prefab** in editor — swap world model; keep class `vm_*` on `ViewModelPrefab` until FP rig batch
3. **`lp_give_<ident>`** — verify before `prepare-publish.ps1`
4. **Portal Equipment + Gun Dealer shipment** — after Opus sign-off

Canon: `RED_WEAPON_MASS_PRODUCTION_PLAN.md` · `WEAPON_MASS_PRODUCTION.md`
