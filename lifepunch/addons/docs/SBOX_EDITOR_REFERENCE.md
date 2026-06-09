# s&box Editor + Cloud — Working Reference

The structured map of the s&box editor, its cloud, and **how the AI studies it**, so we stop
being "all over the place." This is the anti-spaghetti index: when in doubt, check here first.

Sourced from the official s&box docs + the live DXRP install, verified **2026-06-04**.
Status legend: ✅ verified · 🔎 needs a closer look · ⚠️ constraint/gotcha.

---

## 0. How the AI "gets on" the editor (the access model)

There is **no integration to remote-control the s&box desktop app** — the AI cannot click in
it. Instead, three channels cover the work:

| Tier | Channel | Who acts | Covers |
|------|---------|----------|--------|
| 1 | **Web** — `sbox.game` docs, package pages, **code search** (`sbox.game/codesearch`), and the per-package **source viewer** (`sbox.game/<org>/<pkg>/source?file=…`) | AI alone, no clicks | docs, APIs, real reference source code, asset metadata |
| 2 | **Download-cache bridge** — anything referenced/downloaded in the editor lands in `D:\Steam\steamapps\common\sbox\download\assets\` | You click download → AI reads files | real `.vmdl`/`.vanmgrph`/cached source of cloud assets |
| 3 | **Screenshots** | You snap | live editor UI state, panel layout, menu labels |

> **The bridge is proven:** the entire shared-rig architecture was reverse-engineered by reading
> `download/assets/models/weapons/sbox_sniper_m700/v_m700.vmdl` after it cached. ✅

**Local sources the AI can already read without any clicks:**
- DXRP project: `D:\Steam\steamapps\common\sbox\dxrp\game\` (Assets + Code).
- Engine addons (shipped source): `…\sbox\addons\citizen\`, `…\sbox\addons\base\`.
- Cloud cache: `…\sbox\download\assets\` (whatever has been downloaded).

---

## 1. Editor surface (top-level)

| Area | What it's for | Where |
|------|---------------|-------|
| **Scene / Hierarchy / Inspector** | GameObjects + components (the Unity/Godot-style scene) | main window |
| **Asset Browser** | find/import/manage assets (local + cloud) | docked panel; `View → Asset Browser` |
| **ModelDoc (Model Editor)** | create/edit `.vmdl` models | `Tools → Model Editor` |
| **Hammer (Mapping)** | brushwork maps, props, lights | `Tools` / Mapping |
| **ActionGraph** | visual scripting | `Tools` |
| **Console** | commands (`lp_give_ak`, etc.), logs | tab next to Asset Browser |
| **Library Manager / Mixer** | package mounts, audio | tabs |

Engine = **Source 2** under a **C#** layer with millisecond **hotload**. Scene-based.

---

## 2. Asset Browser — local vs cloud (this was a real bottleneck)

The left rail has **two scopes**, and which one you're in decides what you see:

- **Project scope (e.g. "DXRP")** — only assets *in the loaded project*. Searching `v_m700`
  here shows DXRP's wrappers (`vm_m700.prefab`, `w_m700.prefab`) but **NOT** the model — the
  model is a cloud asset.
- **Cloud scope (the ☁️ icon on the far-left vertical strip)** — the whole s&box cloud:
  **Models, Materials, Maps, Sound, Prefabs, Sprites, Decals, Referenced.** This is the
  "goldmine." Searching `m700` here surfaces `ViewModel M700` (the rig), `M700` (world model),
  `M700 Magazine`, plus community weapons (Beryl M762, EFT guns, etc.).

**Naming convention in the cloud (Facepunch weapons collection):**
- `ViewModel <X>` = **first-person** model — *has rig + animations.*
- `<X>` (no prefix) = **third-person/world** model — *has LODs + collisions.*
- Magazines / bullets / attachments are separate packages.

Thumbnails often don't render — go by **Name + Type + Path** columns.

---

## 3. The cloud / mount system — STUDY vs SHIP (the key rule)

> **You can STUDY anything in the cloud. You can only SHIP/MOUNT `facepunch.*`.**

- **DXRP server policy:** `RestrictCloudOrg = "facepunch"`. Non-Facepunch cloud packages
  (any non-Facepunch community org, EFT, etc.) **will not mount** on the DXRP dev server. ⚠️ This is
  the exact wall that blocks third-party cloud assets from non-Facepunch orgs.
- **Therefore:** learn structure from *any* cloud weapon, but **ship our own
  model/material/sound** packaged in the addon's `Assets/` + `Code/` folders (published via the
  DXRP portal), riding **Facepunch's** rig/animgraph. Owned assets + real attached code = not
  spaghetti.
- **Self-contained rule:** custom models must bundle their own textures/materials (don't depend
  on a non-Facepunch cloud package at runtime).

---

## 4. ModelDoc essentials (the model pipeline)

- **`.vmdl` = node graph** (modern `.qc`). `Tools → Model Editor`.
- **Imports:** FBX, OBJ, VOX, DMX (v22), SMD (deprecated). **No** Source1/GoldSrc MDL.
- ⚠️ **Skinning: max 4 weight influences per vertex** — extra weights get culled/normalized.
  Plan AK skinning around this.
- **Export As… → FBX/OBJ** = the supported way to get source back out of a `.vmdl` (incl.
  skinned meshes + material maps). This is our rig-extraction path. ⚠️ Decompiled output "may
  need lots of clean-up" — quality TBD until we test on M700.
- **Base Model** = inheritance (your new `.vmdl` references a base for *animations only*).
  ⚠️ Pointing Base Model at a **cloud model with no local source** crashed ModelDoc — don't.
- **Missing bones?** They're culled if they skin nothing. Use a `BoneMarkup` + "Do Not Discard",
  or set `BoneMarkupList → Bone Cull Type = Leaf Only / None`.
- **Best practice:** every non-static model needs ≥1 animation (even just `AnimBindPose`), or
  IK/morphs silently break.
- Export FBX as **binary** (Blender can't import ASCII FBX). No periods in material names.

---

## 5. First-person weapon system (the integration map for ALL 5 classes)

Doc: `sbox.game/dev/doc/assets/ready-to-use-assets/first-person-weapons/`. Collection:
`sbox.game/facepunch/sboxweapons`.

**Architecture:** each viewmodel has its own animgraph + 3 bone hierarchies — **weapon bones,
arm bones, camera**. Under `weapon_root` → `weapon_root_children` → per-weapon moving parts; two
hand IK bones under `weapon_root`. Hand positions are **baked into the weapon's animation**, then
corrected via IK. *"Most of the time only `weapon_root` needs to move → a lot of animations are
shared between guns."* **Arms bonemerge ONTO the weapon** (opposite of Source 1).

⚠️ **Source status:** Facepunch's first-person weapon **FBX source is NOT currently shipped**
(being re-implemented). The `.vmdl` + `.vanmgrph` do cache locally (readable for study), but to
get an editable mesh/skeleton FBX we use **Export As…** (decompile), quality TBD.

### Drive the viewmodel via animgraph parameters (this is the "code" side of parity)
| Param | Meaning |
|-------|---------|
| `ironsights` (enum, **1 = ADS**) | aim-down-sights stance. *Animation aligns the gun; attachment offsets are code's job.* **← this is the ADS mechanism.** |
| `b_attack` / `b_attack_dry` | fire / fire-while-empty |
| `b_reload`, `b_empty` | reload; empty-state visuals/reload variant |
| `firing_mode` (enum) | 0 safety, 1 single, 2 burst, 3 auto |
| `deploy_type`, `reload_type` | per-weapon faster/alt variants |
| `b_sprint`, `move_bob`, `b_jump`, `b_grounded` | movement sway/stance |
| `speed_reload/deploy/ironsights` | live speed scaling |
| `FingerAdjustment_{L\|R}{1-5}_{Bend\|Curl\|Roll\|Spread}` (−60..60) | per-finger grip correction |

**Event tags** (code listens via `OnAnimTagEvent`): `reload_bodygroup`, `reload_increment`,
`attack_discouraged`, `holster_finished`, `melee_*`. Used e.g. to swap empty→full mag mid-reload.

**Camera bone:** the `camera` bone's animated pos/rot **adds onto** the in-game camera
(+X fwd, +Y left, +Z up). Auto-weakened 50% while moving (via `move_bob`).

### "Replace weapons with your own" — Facepunch's OFFICIAL custom-mesh method
> *"You can hide [the original weapon mesh], then bonemerge (or simply parent) yours on top"* +
> use finger-adjustment params to fix grip.

This means a custom weapon does **not** strictly require Blender rigging for a first pass: take a
class viewmodel (e.g. `ViewModel M4A1`), hide its mesh, parent the AK mesh on `weapon_root`,
finger-adjust. ⚠️ Our earlier attempt of this failed only because **DXRP's `ViewModel` draws
exactly 2 renderers (weapon + arms)** — a 3rd "passenger" mesh didn't render. That's a
DXRP-code limit we own and can fix, not a dead end. (See `VIEWMODEL_RIG_PIPELINE.md` for the
two resulting AK paths.)

### The 5 LifePunch classes ↔ Facepunch viewmodels (+ notable params)
| Class | World (`<X>`) | ViewModel | Class-specific params |
|-------|---------------|-----------|-----------------------|
| Handgun | `usp` | `v_usp` | `b_twohanded`, `deploy_type` |
| SMG | `mp5` | `v_mp5` | `deploy_type` |
| Sniper | `m700` | `v_m700` | `b_reload_bolt` (self-reset), `deploy_type` |
| Shotgun (auto) | `spaghelli` | `v_spaghellim4` | `b_reload` (toggle, NOT self-reset), `b_reloading`, `b_reloading_shell`, `b_reloading_first_shell` |
| **Assault Rifle** | `m4a1` | `v_m4a1` | `weapon_pose` (1 = handguard cover), `reload_type` (1 = pull), `deploy_type` |

(Also in the collection, outside our 5: crowbar, knives, physgun, toolgun, rocket launcher,
grenades/throwables — each with documented params if we ever add those classes.)

---

## 6. Open items to ingest next (study backlog)
- [ ] Mapping/Hammer + Scene system docs (for any map/entity work).
- [ ] `sbox.game/codesearch` — search real games' weapon code for integration patterns.
- [ ] Package **source viewer** on `ViewModel M4A1` / `v_first_person_arms_human` for exact
      animgraph wiring.
- [ ] Editor Shortcuts page (speed up the click-driven steps).
- [ ] Confirm Export As… FBX quality on M700 (decides AK path A vs B).

---

## 7. Quick "where do I…" index
- *Find a cloud model* → Asset Browser → ☁️ cloud icon → search → Type=Model.
- *Edit a model* → double-click `.vmdl` (or right-click → Open) → ModelDoc.
- *Get FBX out of a model* → ModelDoc → File → Export As… → FBX.
- *Recompile after an external edit* → right-click asset → **Recompile**.
- *Test a weapon in-editor* → Console → `lp_give_ak`.
- *Know if an asset can ship on DXRP* → is its org `facepunch`? If not → study-only.
