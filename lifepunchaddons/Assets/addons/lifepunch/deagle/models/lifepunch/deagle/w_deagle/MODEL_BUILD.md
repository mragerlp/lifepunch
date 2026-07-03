# Desert Eagle — world model build

**Folder:** LifePunch `w_deagle` world model (handgun class / USP kit)  
**CS2 study mesh:** `weapon_pist_deagle` (reference only)  
**Class placeholder:** `gameplay/equipment/weapons/usp/w_usp.prefab`

---

## Active source (target)

Cleaned FBX (not yet in repo):

```text
source/w_deagle.fbx
```

Author from CS2 **world** glTF proportions (`reference-intake/cs2-weapons/deagle/world/`) or owner pistol mesh. Never ship CS2 glTF.

---

## Texture inputs (planned)

```text
textures/deagle_BaseColor.tga.png
textures/deagle_Normal.tga.png
textures/deagle_Metalness.tga.png
textures/deagle_Roughness.tga.png
```

Mirror `ak47_body.vmat` channel layout. CS2 glTF slot names → record in `SOURCE_INTAKE.md`.

---

## Target outputs

```text
w_deagle.vmdl
materials/deagle_body.vmat
```

Mounted path: `addons/lifepunch/deagle/models/lifepunch/deagle/w_deagle/w_deagle.vmdl`

---

## Prefab targets

```text
equipment/w_deagle/w_deagle.prefab
equipment/vm_deagle/vm_deagle.prefab   # FP: class vm_usp until own rig
```

Constants: `Deagle.cs` → `WorldPrefabPath`, `ViewModelPrefabPath`, `WorldModelPath`.

---

## DXRP wiring checklist (clone USP)

1. Duplicate `w_usp.prefab` component tree (`Equipment`, `TagBinder`, `Muzzle`, `EjectionPort`, `Functions`).
2. Swap **Model** child to `w_deagle.vmdl` only — keep HoldType `Pistol`.
3. Apply `DeagleWeaponStats` via shoot/reload/recoil components (Red tunes from `USP_CLASS_STATS.md`).
4. **Physics hull** on vmdl — required for drop/collision (AK lesson).
5. Assign LifePunch sounds from `Deagle.cs` sound paths.
6. Killfeed icon: `ui/deagle_killfeed.png`.

---

## Current status

- [ ] FBX source imported
- [ ] `w_deagle.vmdl` + `deagle_body.vmat`
- [ ] `w_deagle.prefab` wired
- [ ] `vm_deagle.prefab` — USP class placeholder
- [ ] `prepare-publish.ps1 -Addon deagle`

---

## Related

- `USP_CLASS_STATS.md` · `deagle/docs/SOURCE_INTAKE.md` · `WEAPON_MASS_PRODUCTION.md`
