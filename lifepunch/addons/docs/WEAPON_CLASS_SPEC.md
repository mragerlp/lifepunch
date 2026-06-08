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
   - `v_*.vmdl` = your mesh **bound to the shared first-person rig** (`weapon_root` + arm bones
     + `camera` + shared animgraph). Extract the rig via ModelDoc **Export As… FBX** from
     `v_m700` and author from the `v_m700.vmdl` template. *(See §4 and `VIEWMODEL_RIG_PIPELINE.md`.)*
   - `vm_*.prefab` mirrors the class's `vm_*` 1:1: `ViewModel.ModelRenderer` = your weapon
     renderer, `Arms` bonemerged to it. **No invisible master, no passenger renderers.**
4. **Functions:** copy ammo/shoot/reload/recoil components from the class reference's
   `w_*.prefab` Functions group; tune values (damage, fire rate, recoil pattern, sounds).
5. **Test:** prefab editor (design gate) → editor play (`lp_give_*`) → publish revision
   (deployment gate). See `PUBLISHING.md`.

Once step 3's rig exists for a class, weapon #2 in that class is a copy-paste + model swap.

---

## 4. The first-person rig — how to get it (CORRECTED 2026-06-04)

> ⚠️ **Correction.** An earlier version of this doc said the weapon rig source "isn't shipped"
> and that first person was **blocked**. That was wrong and is retracted. The rig **is**
> available and first person is **doable now**. See `VIEWMODEL_RIG_PIPELINE.md` for full steps.

Step 3's viewmodel rides the **shared first-person arms rig** — *not* a per-weapon rig you
invent. That shared rig (skeleton: `weapon_root` + `weapon_root_children`, arm bones, `camera`;
plus IK, constraints, and shareable animations) is Facepunch's.

**Accurate source status (don't overclaim either way):**
- Facepunch's weapon **FBX source is currently NOT shipped** (per the first-person-weapons doc;
  being re-implemented). So we can't just grab a ready FBX.
- **But the `.vmdl` + `.vanmgrph` DO cache locally** — you have `v_m700`'s on disk — so the
  structure is fully readable, and ModelDoc's **Export As… FBX** can *regenerate* a mesh +
  skeleton from the compiled model (decompile, may need cleanup; quality TBD until tested).
- There's also Facepunch's **official "hide the original weapon mesh + bonemerge/parent yours
  on top"** method (no FBX export needed) — see `SBOX_EDITOR_REFERENCE.md §5`.

So there are **two** candidate paths to a real first person (see `VIEWMODEL_RIG_PIPELINE.md`);
neither is blocked. `v_m700` (a two-handed long gun) is the on-disk study template; the
class-correct animations for the AK come from `v_m4a1` (Assault Rifle).

**The only custom layer is MODEL / MATERIAL / SOUND.** The rig, IK, animgraph, and animations
are reused from DXRP/Facepunch as-is. The one-time per-weapon work is: bind your weapon mesh to
`weapon_root` (+ moving parts to `weapon_root_children`) and align its iron sights. That's a
contained Blender bind job, **not** a rig-from-scratch.

Things we already proved do **not** work (do not retry):
- **Passenger renderer:** DXRP's `ViewModel` draws only 2 renderers (weapon + arms). A 3rd
  "passenger" mesh does not render even with `RenderType: On`. → empty hands.
- **Raw `base_model_name` edit** pointing a static `v_*.vmdl` at the cloud `v_m4a1.vmdl`
  (+ `parent_bone = "weapon_root"`): **crashes ModelDoc (heap corruption).** Reverted.
  *(This failed because it referenced a cloud model with no local source — not because the
  rig is unavailable. The supported path is Export As… FBX, then author a fresh `v_*.vmdl`.)*

### Strategy
- **Placeholder (optional, only if you want to ship before the bind):** a **clean
  class-matched** viewmodel (AK shows the M4A1 viewmodel in your hands — stable, shippable).
  Must be a *clean* class viewmodel, NOT the empty-hands invisible-master setup.
- **Real first person (the actual plan):** do the one-time bind per class → first person snaps
  into the same clean template, **no wipe**, no asset rework. Because most animations move only
  `weapon_root`, weapon #2+ in a class is a model swap.

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
| Viewmodel (1st person) | 🔜 Doable now — `v_ak47` is still a static mesh; needs the one-time bind to the shared rig (Export As… FBX from `v_m700` → Blender bind → author `v_ak47.vmdl`). M4A1 placeholder is optional in the meantime. |

**AK first-person endgame (the plan):** extract the shared rig via ModelDoc **Export As… FBX**
from `v_m700`, bind the AK mesh to `weapon_root` (+ moving parts) and align sights in Blender,
author `v_ak47.vmdl` from the `v_m700.vmdl` template (reuse shared/long-gun anims) →
`vm_ak47` becomes a 1:1 mirror of `vm_m4a1` → real AK in your hands, real ADS on its own sights.
See `VIEWMODEL_RIG_PIPELINE.md`.
