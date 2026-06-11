# Fast weapon test (editor, no portal Equipment row)

Use these **dev-only** console commands while the LifePunch addon is mounted in the DXRP editor project.
They clone prefabs directly — excluded from publish (`_dev/WeaponDevGive.cs`).

Generic fallback: `lp_give_weapon <ident>` (e.g. `lp_give_weapon deagle`).

Prefab tuning after clone: **`WEAPON_PREFAB_TUNE.md`** (stats → ShootWeaponComponent fields).

---

## #1 AK-47 (class baseline — gate before full kit)

**Rebuild order (Red lane):** CS2 export → Blender `w_ak47.fbx` → ModelDoc physics on `w_ak47.vmdl` → clone `w_m4a1` prefab wiring with `vm_m4a1` → drop/hold smoke → then restore `lp_give_ak` (vm_ak47 kit). **Do not pin more AK gamemode revisions until drop + hold passes.**

```text
lp_give_ak_class
```

| Asset | Path |
|-------|------|
| World | `addons/lifepunch/ak47/equipment/w_ak47/w_ak47.prefab` (LifePunch `w_ak47.vmdl`) |
| First person | `gameplay/equipment/weapons/m4a1/vm_m4a1.prefab` (class until FP rig) |
| Third person | Hold offsets synced from M4 class (2026-06-11) |

**Pass:** textured AK in world + third person; M4 arms 1P; **drop** lands with collision; **pickup** restores hold; no gamemode pin until this passes.

`lp_give_ak` is **gated** until the above passes (full `vm_ak47` kit).

---

## #2–5 Queue weapons (class placeholder until LifePunch prefabs ship)

Each command uses the **LifePunch prefab** when present; otherwise the **DXRP class** `w_*` prefab.

### Desert Eagle — `lp_give_deagle`

| | |
|-|-|
| Class clone | USP (`w_usp` / `vm_usp`) |
| Stats target | 55 dmg · 7/35 · 267 RPM semi · 2.0s reload |
| Red ships | `w_deagle.vmdl` + prefab |

**Pass:** heavy semi pistol; 7-round mag; USP arms 1P until custom VM.

### MP9 — `lp_give_mp9`

| | |
|-|-|
| Class clone | MP5 |
| Stats target | 11 dmg · 30/90 · 857 RPM auto · 1.4s reload |
| Red ships | `w_mp9.vmdl` + prefab |

**Pass:** high-RPM spray; 30-round mag; MP5 arms 1P until custom VM.

### SSG 08 — `lp_give_ssg08`

| | |
|-|-|
| Class clone | M700 |
| Stats target | 65 dmg · 10/30 · 60 RPM semi · 2.2s reload · 180m range |
| Red ships | `w_ssg08.vmdl` + prefab |

**Pass:** scout bolt feel; tight spread; M700 scope 1P until custom VM.

### XM1014 — `lp_give_xm1014`

| | |
|-|-|
| Class clone | Spaghelli |
| Stats target | 7×8 pellets · 7/28 · 200 RPM auto · 6° spread |
| Red ships | `w_xm1014.vmdl` + prefab |

**Pass:** 8-pellet spread; 7-shell tube; Spaghelli arms 1P until custom VM.

---

## Red lane (guns in faster)

1. **Batch CS2 export on VENGEANCE** — `Intake-Cs2WeaponReference.ps1` (`weapon_rif_ak47` first, then deagle/mp9/…)
2. **Blender** — LifePunch-owned `w_<ident>.fbx` from CS2 study (never raw CS2 in publish)
3. **ModelDoc** — physics/collision on `w_<ident>.vmdl`
4. **Clone class prefab wiring** — swap world model; class `vm_*` until FP rig batch (`lp_give_ak_class` for AK)
5. **Drop + hold smoke** — editor `lp_give_ak_class` before gamemode pins or `lp_give_ak` gate
6. **Mirror stats** — `WEAPON_PREFAB_TUNE.md` + per-weapon `docs/WEAPON_BUILD.md`
7. **`lp_give_<ident>`** — verify before `prepare-publish.ps1`
8. **Portal Equipment + Gun Dealer shipment** — after Opus sign-off

Canon: `RED_WEAPON_MASS_PRODUCTION_PLAN.md` · `WEAPON_MASS_PRODUCTION.md` · `weapon-production.json`
