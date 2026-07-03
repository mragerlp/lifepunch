# CS2-first weapon test lane (owner decision 2026-06-11)

**Verdict:** The Sketchfab AK kit is **not shippable** — bad 3P hold, broken FP bonemerge, **no drop physics** (falls through floor). Stop publishing AK revisions until rebuilt from **CS2 study meshes**.

**Play guns today** with **DXRP class kits** (`lp_give_ak_class`, `lp_give_deagle`, …). **Author meshes** from CS2 glTF → own FBX → ModelDoc.

---

## What broke on the current AK

| Issue | Cause |
|-------|--------|
| Frankenstein / floating FP mesh | `v_ak47` bonemerged onto M4 bones without matching weights |
| Bad 3P hold | Custom `w_ak47` mesh + offsets never matched class quality |
| **Drops fall through floor** | `w_ak47.vmdl` has **no physics/collision hull** — class `w_m4a1.vmdl` does |

Do not spend more portal revisions tuning this mesh.

---

## Test today (working gameplay)

Use **class placeholders** — full VM, hold, drop physics, fire/reload:

```text
lp_give_ak_class      # M4A1 kit — use instead of lp_give_ak until CS2 rebuild
lp_give_deagle
lp_give_mp9
lp_give_ssg08
lp_give_xm1014
lp_give_dbs
```

Drop test: equip → drop (default bind) → pickup. Class kits should rest on the floor.

---

## Rebuild lane (Red on VENGEANCE)

Per weapon in `weapon-production.json`:

```
CS2 glTF (reference-intake) → Blender own mesh → w_<ident>.fbx
  → ModelDoc w_<ident>.vmdl + **collision hull** + materials
  → clone class w_* prefab → swap model → class vm_* on ViewModelPrefab
  → lp_give_<ident> G7 smoke → publish
```

### AK-47 restart (queue #1)

1. Export `weapon_rif_ak47` from CS2 (`weapons/models/ak47/`) → `reference-intake/cs2-weapons/ak47/`
2. Blender: study proportions + moving parts; author **LifePunch-owned** `w_ak47.fbx` + `v_ak47.fbx` weighted to **M4 class skeleton** (export `v_m4a1` FBX from ModelDoc as rig reference)
3. ModelDoc: compile with **Physics** mesh (convex hull or simplified collision) — **required for drops**
4. Clone `w_m4a1.prefab` / `vm_m4a1.prefab` wiring; swap to new vmdls
5. `lp_give_ak` G1–G3 + drop test before any portal publish

**Ship boundary:** CS2 assets stay in `reference-intake/` — never in publish tree.

---

## Queue priority (CS2 harvest batch)

**Cornerman (manifest stubs):**

```powershell
cd lifepunchaddons\scripts
powershell -File .\Intake-Cs2WeaponReference.ps1 -ManifestOnly
```

**Red on VENGEANCE (glTF + sounds):**

```powershell
powershell -File .\Intake-Cs2WeaponReference.ps1 -CliPath 'C:\Tools\Source2Viewer-CLI.exe' -ExportGltf
```

Full catalog: `config/cs2-weapon-catalog.json` (12 weapons). Red runbook: `RED_CS2_WEAPON_BATCH.md`.

Rebuild **ak47 world mesh + physics first**; class kits handle gameplay until each `w_<ident>` ships.

---

Canon: `CS2_WEAPON_HARVEST.md` · `CS2_WORLD_MODEL_PIPELINE.md` · `WEAPON_CLASS_SPEC.md`
