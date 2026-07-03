# LifePunch — First-Person Viewmodel Rig Pipeline

The authoritative, no-spaghetti recipe for giving a custom weapon a **real first-person
viewmodel** (model in your hands, working ADS) in DXRP. Read this before opening Blender.

**Full platform checklist:** `LIFEPUNCH_WEAPON_IMPLEMENTATION_LAW.md` (attachments, P1 anims, state
machine, required report). **This doc** = FP rig bind + DXRP class integration path only.

Grounded in the real on-disk DXRP/s&box files and the official s&box first-person-weapons +
Model Editor docs, verified **2026-06-04**.

---

## 0. The principle (scope)

> **We only bring the MODEL, MATERIALS, and SOUNDS.** The rig, skeleton, IK, animgraph,
> animations, and the shipment/dealer plumbing are **DXRP/Facepunch's, reused as-is.**
> Reusing them is *encouraged* — it is the engine working as designed, the opposite of
> spaghetti. Our job is integration + parity: make our custom asset ride the standard plumbing
> so it behaves exactly like a native DXRP weapon.

So a "first-person rig" is **not** something we author from scratch. It's the **shared
first-person arms rig** that every s&box weapon uses. We bind our mesh to it. That's it.

---

## 1. Why this is NOT blocked (correcting the old assumption)

The shared rig source **is available**:

- s&box Model Editor docs: *"When downloading cloud assets from the editor, some authors
  include their source files; **this is the case for our first-person weapons.**"*
- Model Editor docs: *"open the VMDL in ModelDoc and use **Export As…** — it can export any
  meshes (including skinned ones) as **FBX or OBJ**."*
- On disk right now: `D:\Steam\steamapps\common\sbox\download\assets\models\weapons\sbox_sniper_m700\v_m700.vmdl`
  **and** `v_m700.vanmgrph`. The M700 is a two-handed long gun — the closest analog to an
  Assault Rifle — so it is our **template and rig source**.

The earlier "Facepunch source isn't shipped → first person blocked" note was **wrong** and has
been retracted in `WEAPON_CLASS_SPEC.md §4` and `TECH_DEBT.md` (FP-AK-01).

---

## 2. The rig, in one picture

The shared first-person skeleton (from the arms model + every weapon `v_*`):

```
root
├── camera                  ← ViewModel.cs reads this every frame to drive the view
├── weapon_root             ← the gun hangs here; MOST animations move only this bone
│   └── weapon_root_children
│       └── (per-weapon moving parts: bolt, magazine, trigger, charging handle…)
└── arm_upper_L/R → arm_lower_L/R (+ twist) → hand_L/R → fingers…
    + hand IK rules (hand_*_to_weapon_ikrule) keep hands glued to the gun
```

Key consequence (from the docs): *"most of the time only `weapon_root` needs to move… so a lot
of animations can be shared between guns."* That's why a model swap is enough once one weapon in
a class is bound — idle/deploy/reload/fire/ironsights come along for free.

The arms **bonemerge ONTO the weapon** (`v_first_person_arms_human.vmdl`, `BoneMergeTarget` =
the weapon renderer). This is s&box-specific — the opposite of the old Source 1 setup.

---

## 3. The pipeline (one-time per class; then model-swap per weapon)

### Step A — Extract the rig (ModelDoc, no Blender yet)
1. In the editor, **Tools → ModelDoc**, open `v_m700.vmdl`
   (`models/weapons/sbox_sniper_m700/v_m700.vmdl`).
2. **File → Export As… → FBX.** This regenerates:
   - the **full skeleton** (`weapon_root`, `weapon_root_children`, arm bones, `camera`),
   - the M700 mesh skinned to it (reference for how a weapon binds),
   - the materials' maps.
3. Keep this FBX as `reference/rig/` — it is the canonical bind target for **all** classes.

### Step B — Bind your model (Blender) — THE custom work
1. Import the exported FBX (gives you the exact skeleton + a reference weapon).
2. Import your AK mesh. Scale/orient it to sit where the M700 mesh sat (same origin/forward).
3. **Bind the AK body rigidly to `weapon_root`.** For fidelity, weight the moving parts to
   their `weapon_root_children` bones (bolt, magazine, trigger) so reload/fire anims animate
   them. Minimum viable = whole gun on `weapon_root`.
4. **Align the iron sights** so the shared `Ironsights_Pose_Normal` lands the AK's sights on
   the camera line. (This is what makes ADS correct — the pose is shared; the sight geometry is
   yours, so it's positioned here.)
5. Export `v_ak47.fbx` (mesh + skeleton). Do **not** re-author animations — they're shared.

### Step C — Author the viewmodel (ModelDoc) — mirror the M700 recipe
Create `v_ak47.vmdl` modeled on `v_m700.vmdl` (it's on disk — copy its structure):
- `RenderMeshFile` → your `v_ak47.fbx`.
- Reference the **same shared first-person prefabs** the M700 uses
  (`models/first_person/prefabs/first_person_arms_*.vmdl_prefab`: AnimConstraintList, IKData,
  BoneMarkupList, WeightListList).
- **Reuse the M700's animations** to start (long gun → AK shares them): IdlePose,
  Ironsights_Pose_Normal, Deploy, Reload_Pull, Trigger_Fire, Sprint_Pose, plus the shared
  `first_person_arms_animationlist_*` prefabs.
- `anim_graph_name` → an animgraph (start by reusing the M700's pattern).
- Materials → **your** AK `.vmat`s (this is a custom layer).

### Step D — Wire the prefab (mirror `vm_m4a1.prefab` 1:1)
- `vm_ak47.prefab`: `ViewModel.ModelRenderer` = the `v_ak47` `SkinnedModelRenderer`;
  `Arms` = `v_first_person_arms_human.vmdl` with `BoneMergeTarget` = the weapon renderer.
- **No invisible master. No passenger renderer. No hidden materials.** If it doesn't look like
  `vm_m4a1`, it's wrong.
- `w_ak47.prefab` → `Equipment.ViewModelPrefab` = `vm_ak47.prefab`.

### Step E — Test, then publish
Prefab editor (design gate) → editor play (`lp_give_ak`) → publish revision (deployment gate).

---

## 4. What is custom vs. reused (the parity checklist)

| Piece | Source | Custom? |
|-------|--------|---------|
| Skeleton (`weapon_root`, arms, `camera`) | Facepunch shared rig (Export As… FBX) | ❌ reused |
| Arms model + bonemerge | `v_first_person_arms_human.vmdl` | ❌ reused |
| IK / constraints / bone markup / weight lists | shared `first_person_arms_*` prefabs | ❌ reused |
| Animations (idle/deploy/reload/fire/ADS) | shared + M700 (long-gun) | ❌ reused (swap later if desired) |
| Animgraph | M700 pattern | ❌ reused |
| **Weapon mesh** | **you** | ✅ custom |
| **Materials / textures** | **you** | ✅ custom |
| **Sounds** | **you** | ✅ custom |
| Mesh→`weapon_root` bind + sight alignment | the one-time Blender job | ⚙️ integration |

If a piece in the "reused" rows ends up custom or faked, stop — that's the spaghetti the
quality bar forbids.

---

## 5. Known dead ends (do not retry)

- **Passenger renderer** (3rd mesh in `vm_*`): DXRP's `ViewModel` draws only weapon + arms.
  A passenger doesn't render even with `RenderType: On`. → empty hands.
- **Raw `base_model_name` → cloud `v_m4a1.vmdl`** on a static mesh: crashed ModelDoc (heap
  corruption). The supported path is **Export As… FBX → author a fresh `v_*.vmdl`**, not
  base-model-referencing a cloud asset with no local source.

---

## 6. Reuse across the 5 classes

The skeleton from Step A is the **same rig all 5 classes use**. Once the AK (Assault Rifle) is
bound, the other four are: pick the class's reference long/short gun, Export As… FBX if you want
its specific animations, bind your mesh, swap materials/sounds. The pipeline is the reusable,
reference-grade foundation — author it once, here, correctly.
