# Red (VENGEANCE) — CS2 Weapon Mass Production Plan

**Issued:** 2026-06-11 · **Green delivered:** code-draft stats + class references (commit on `main`)  
**Canon:** `WEAPON_MASS_PRODUCTION.md` · `WEAPON_CLASS_SPEC.md` · `DXRP_CLASS_WEAPON_REFERENCES.md`

---

## The plan in one sentence

Ship **four CS2-skinned Gun Dealer weapons** by cloning each DXRP **class kit** (not building shipments/pickups), authoring **own meshes** from CS2 study exports, and tuning prefab Functions to the **`<Pascal>.cs` Stats** Green already filled.

```
CS2 glTF (study) → Blender own FBX → w_<ident>.vmdl → clone class w_* prefab → portal publish → Gun Dealer qty 5
```

AK-47 (#1) stays the golden reference. Work queue **#2 → #5** in order.

---

## Queue

| # | ident | Class | DXRP clone | CS2 study mesh | Code status |
|---|-------|-------|------------|----------------|-------------|
| 1 | `ak47` | Assault Rifle | `m4a1` | `weapon_rif_ak47` | **active kit** |
| 2 | `deagle` | Handgun | `usp` | `weapon_pist_deagle` | **code-draft** ← start here |
| 3 | `mp9` | SMG | `mp5` | `weapon_smg_mp9` | code-draft |
| 4 | `ssg08` | Sniper | `m700` | `weapon_snip_ssg08` | code-draft |
| 5 | `xm1014` | Shotgun | `spaghelli` | `weapon_shot_xm1014` | code-draft |

Machine-readable: `config/weapon-production.json`.

---

## Per-weapon lane (repeat ×4)

| Step | Where | Done when |
|------|-------|-----------|
| 1. CS2 intake | Source 2 Viewer → `C:/lifepunch/reference-intake/cs2-weapons/<ident>/` | glTF on disk (**never commit**) |
| 2. Own FBX | Blender study → `Assets/.../w_<ident>/source/w_<ident>.fbx` | LifePunch-owned mesh |
| 3. World model | ModelDoc → `w_<ident>.vmdl` + materials | Compile green; grip vs class ref (`DXRP_CLASS_WEAPON_REFERENCES.md`) |
| 4. World prefab | Clone class `gameplay/equipment/weapons/<class>/w_<class>.prefab` | Save as `equipment/w_<ident>/`; swap model; wire Muzzle/EjectionPort |
| 5. Viewmodel | Class placeholder `vm_<class>.prefab` on `ViewModelPrefab` | FP rig batch later (AK doctrine) |
| 6. Functions tune | Ammo / Shoot / Reload / Recoil on prefab | Match `<Pascal>.cs` Stats (see below) |
| 7. Sounds | `sounds/` paths already in `<Pascal>.cs` | Record or license; `.sound` resources |
| 8. Manifest | Portal package + `addons.json` content row | Set `dxrpAddonId` |
| 9. Publish | `prepare-publish.ps1 -Addon <ident>` | Portal upload |
| 10. Gun Dealer | Portal market item | `Quantity=5`, whitelist Gun Dealer job |

Per-weapon checklist: `Code/Addons/lifepunch/<ident>/docs/WEAPON_BUILD.md`.

---

## Stats sheet (Green first pass — tune in editor)

Values live in `Code/Addons/lifepunch/<ident>/<Pascal>.cs`. Mirror onto prefab ShootWeaponComponent / AmmoComponent — field-by-field map in **`WEAPON_PREFAB_TUNE.md`**.

| ident | Damage | RPM | Mag / Reserve | Reload | Fire mode | Recoil pitch / yaw | Notes |
|-------|--------|-----|---------------|--------|-----------|-------------------|-------|
| `deagle` | 55 | 267 | 7 / 35 | 2.0s | semi | 4.5 / 1.8 | USP class; high dmg pistol |
| `mp9` | 11 | 857 | 30 / 90 | 1.4s | auto | 3.0 / 2.0 | MP5 class |
| `ssg08` | 65 | 60 | 10 / 30 | 2.2s | semi | 12 / 3.0 | M700 class; scout (lighter than AWP-line) |
| `xm1014` | 7 × 8 pellets | 200 | 7 / 28 | 2.0s | auto | 16 / 3.5 | Spaghelli class; `PelletCount` on stats |

DXRP class prefab extraction (offsets, library paths, component lists): **`DXRP_CLASS_WEAPON_REFERENCES.md`**.

---

## Deagle kickoff (#2)

Detailed brief (Cornerman inbox mirror): `cornerman/inbox/DEAGLE_WEAPON_BRIEF.md` on Green; repo copy in queue docs.

**Red next action:** DXRP editor on VENGEANCE → confirm AK golden → **deagle step 1** (CS2 glTF or FBX if intake already on VENGEANCE).

Class clone targets:

```text
gameplay/equipment/weapons/usp/w_usp.prefab   → equipment/w_deagle/w_deagle.prefab
gameplay/equipment/weapons/usp/vm_usp.prefab  → ViewModel placeholder
```

---

## Green vs Red boundary

| Green (Cornerman) | Red (VENGEANCE) |
|-------------------|-----------------|
| Stats constants, `*Weapon.cs`, docs | ModelDoc, prefabs, sounds |
| DXRP class reference tables | Editor clone + playtest |
| `validate-layout.ps1` | `prepare-publish.ps1`, portal |
| Patch handoff / inbox notes | Opus review before Gun Dealer ship |

---

## Review gate

**Opus on VENGEANCE** before any Gun Dealer shipment goes live — prefab Functions touch combat economy.

**Validate after pull:**

```powershell
powershell -File lifepunchaddons/scripts/validate-layout.ps1
```
