# LifePunch Weapon Build Spec — Classes, Views, and the Repeatable Recipe

This is the canonical reference for building **any** LifePunch weapon for DXRP without
re-deriving it each time. Read this before starting a new weapon.

It is grounded in the real DXRP files (`vm_m4a1.prefab`, `w_m4a1.prefab`, etc.) and the
official s&box first-person-weapons docs, verified 2026-06-04.

---

## 0. The core distinction: weapon vs. CLASS

A LifePunch weapon is always an **instance of one of DXRP's weapon classes**. The "class"
is the existing DXRP weapon whose **rig, hold behavior, and animation set** we inherit/mirror.
You do **not** invent weapon behavior — you pick the class and reskin it.

> **The AK-47 is NOT its own thing. It is an _Assault Rifle_, and the Assault Rifle class
> reference is the M4A1.** Everything the AK does in-hand it does *because* it rides the
> M4A1 class. The same logic applies to every other weapon → it maps to one of the 5 classes.

### The 5 LifePunch weapon classes

| Class | DXRP reference weapon | Viewmodel (`v_*`) | World (`w_*`) | `HoldType` |
|-------|----------------------|-------------------|---------------|------------|
| Handgun / Pistol | **USP** | `v_usp` | `w_usp` | `Pistol` |
| Sub Machine Gun | **MP5** | `v_mp5` | `w_mp5` | `Rifle`* |
| Sniper Rifle | **M700** | `v_m700` | `w_m700` | `Rifle`* |
| Semi-Auto Shotgun | **Spaghelli** | `v_spaghellim4` | `w_spaghelli` | `Rifle`* |
| **Assault Rifle** | **M4A1** | `v_m4a1` | `w_m4a1` | `Rifle` |

\*Confirm the exact `HoldType` from each class's `w_*.prefab` before building — they are the
source of truth, not this table.

> **AK-47 → Assault Rifle → M4A1 class.** When this doc says "the class reference," for the
> AK that means the M4A1 files specifically.

(DXRP also ships `knife`, `rocket_launcher`, and `grenade`. Those are outside our 5 target
classes and have their own patterns — ignore them unless we deliberately add those classes.)

---

## 1. First and third person are TWO SEPARATE SYSTEMS

This is the thing that, once understood, stops the spaghetti. They use different models and
different attachment mechanisms.

### Third person — what *other players* see (the world model)

Persists with the **player model's body**, via the equipment system:

- The `w_*` prefab has an **`Equipment`** component (`Dxura.RP.Game.Equipment`) with:
  - **`HoldType`** (e.g. `Rifle`) → tells the **player model's animgraph** how to pose the
    arms/hands. *The body poses; the gun does not.*
  - **`Handedness`** (`Right`).
- The weapon mesh is the **`Model` child** (a `SkinnedModelRenderer`). Its **local
  Position/Rotation** seats the gun into the already-posed hands.
  - **This offset is the only "minor geometry adjustment" knob for 3rd person.**
- **A static mesh is completely fine for the world model.** No rig required.

> So 3rd-person persistence = `Equipment.HoldType` drives the hands + `Model` child offset
> seats the gun. Every weapon: set the class's HoldType, tune the offset. Done.

### First person — what *you* see (the viewmodel)

Persists with the **camera**, not the body. Completely independent of the world model:

- Holding a weapon spawns its **`ViewModelPrefab` (`vm_*`)** — its own mini-scene anchored
  to the camera.
- The **`v_*` model must be a real rig** with three bone hierarchies:
  **weapon bones, arm bones, and a `camera` bone**, plus an animgraph.
  - `ViewModel.cs` reads the **`camera` bone every frame** to drive the view.
  - **`weapon_root` + baked hand-IK** keep the hands glued to the gun; most animations move
    only `weapon_root`, which is why **animations can be shared across a class**.
- The **arms bonemerge ONTO the weapon** (`v_first_person_arms_human.vmdl`,
  `BoneMergeTarget` = the weapon renderer). This is s&box-specific (opposite of Source 1).
- **A static mesh can NOT be a viewmodel.** No camera bone, no rig, nothing to drive →
  empty hands. This was the AK's entire first-person problem.

---

## 2. File anatomy (per weapon)

```
equipment/
  w_<name>.prefab      world model + Equipment (HoldType, Handedness, Muzzle, EjectionPort) + Functions (ammo/shoot/reload/recoil)
  vm_<name>.prefab     viewmodel: ViewModel comp + weapon SkinnedModelRenderer + arms (bonemerged)
models/.../w_<name>/
  w_<name>.vmdl        world model — STATIC MESH OK
models/.../v_<name>/
  v_<name>.vmdl        viewmodel — MUST BE RIGGED (camera bone + arm bones + animgraph)
```

- `w_*.prefab` → `Equipment.ViewModelPrefab` points at `vm_*.prefab`.
- Muzzle / EjectionPort live on **bone objects**, not hand-typed world-space numbers.
  (Match the class reference's values; the M4A1 muzzle is `20.07571,0,7.212921`.)

---

## 3. The repeatable build recipe (per weapon)

1. **Pick the class** (e.g. AK-47 → Assault Rifle → M4A1).
2. **World model (3rd person):**
   - `w_*.vmdl` = your static mesh.
   - `w_*.prefab`: `Equipment.HoldType` = the class's hold type, `Handedness` = Right.
   - Tune the `Model` child Position/Rotation to seat the gun in the hands; copy
     Muzzle/EjectionPort from the class reference.
3. **Viewmodel (1st person):**
   - `v_*.vmdl` = your mesh **rigged to the class skeleton** (camera bone + arm bones +
     shared animgraph). *(See the constraint in §4.)*
   - `vm_*.prefab` mirrors the class's `vm_*` 1:1: `ViewModel.ModelRenderer` = your weapon
     renderer, `Arms` bonemerged to it. **No invisible master, no passenger renderers.**
4. **Functions:** copy ammo/shoot/reload/recoil components from the class reference's
   `w_*.prefab` Functions group; tune values (damage, fire rate, recoil pattern, sounds).
5. **Test:** prefab editor (design gate) → editor play (`lp_give_*`) → publish revision
   (deployment gate). See `PUBLISHING.md`.

Once step 3's rig exists for a class, weapon #2 in that class is a copy-paste + model swap.

---

## 4. The first-person rig constraint (IMPORTANT, current)

Step 3 requires the **class rig source (FBX/skeleton/animgraph)** to skin a custom mesh onto.
Per Facepunch's own first-person-weapons docs, that **source is currently NOT shipped** while
they re-implement the system (cloud `v_*` models exist, but their editable source does not).

**Implication — this is general, not AK-specific:** first person for **any custom weapon** is
gated until Facepunch re-releases the weapon source. Third person has **no** such gate.

Things we already proved do **not** work (do not retry):
- **Passenger renderer:** DXRP's `ViewModel` draws only 2 renderers (weapon + arms). A 3rd
  "passenger" mesh does not render even with `RenderType: On`. → empty hands.
- **Raw `base_model_name` edit** pointing a static `v_*.vmdl` at the cloud `v_m4a1.vmdl`
  (+ `parent_bone = "weapon_root"`): **crashes ModelDoc (heap corruption).** Reverted.

### Interim strategy until source ships
- **Now:** finish **third person** to the ideal (correct world model + tuned grip), and use a
  **clean class-matched placeholder** for first person (e.g. AK shows the M4A1 viewmodel in
  your own hands — stable, shippable). The placeholder must be a *clean* class viewmodel, NOT
  the empty-hands invisible-master setup.
- **When source ships:** do the one-time `v_*` rig per class → first person snaps into the
  same clean template, **no wipe**, no asset rework.

---

## 5. Anti-spaghetti rules

- **Do** mirror the class reference prefab structure exactly. If it doesn't look like the
  M4A1's `vm_m4a1`, it's wrong.
- **Do** keep static meshes for world models and rigged models for viewmodels — never blur them.
- **Don't** stack workarounds (invisible masters, hidden materials, passenger renderers,
  manual world-space offsets) to fake a rig. If first person needs faking, it's blocked —
  use the clean placeholder and wait for source.
- **Don't** publish a revision to *iterate* on content. Iterate in the editor; publish to
  *confirm* deployment. (See `WEAPON_INTAKE.md` / `PUBLISHING.md`.)

---

## 6. Worked example — AK-47 (Assault Rifle, M4A1 class)

| Piece | Status |
|-------|--------|
| Class | Assault Rifle → **M4A1** |
| World model (3rd person) | ✅ Correct AK; works on Dev server. Grip offset = remaining tune. |
| Muzzle / EjectionPort (`w_ak47`) | ✅ Corrected to M4A1 values. |
| Sounds / recoil / spray / fire modes | ✅ Done, matched to class. |
| Viewmodel (1st person) | ⛔ Blocked — `v_ak47` is a static mesh; needs class rig, source not shipped. Use clean M4A1 placeholder until then. |

**AK first-person endgame (when source ships):** skin `v_ak47` to the M4A1 viewmodel
skeleton → `vm_ak47` becomes a 1:1 mirror of `vm_m4a1` → "AK in place of the M4 with minor
geometry adjustments," exactly the target.
