# AK-47 S&box Beginner Guide (First Person Fix)

**Want the shortest path?** Use **[`AK47_FIX_CHECKLIST.md`](AK47_FIX_CHECKLIST.md)** — one page, checkboxes, in order.

This guide assumes you are new to S&box and DXRP. Follow the phases **in order**. Do not publish to the DXRP portal until **Phase 5** passes.

## Big picture (read this first)

You are building a **weapon addon** for a roleplay game (DXRP). A weapon is not one file — it is several pieces that work together:

| Piece | File example | What the player sees |
|-------|----------------|----------------------|
| **World model** | `w_ak47.vmdl` + `w_ak47.prefab` | Gun on a crate, on the ground, in third person |
| **View model** | `v_ak47.vmdl` + `vm_ak47.prefab` | Gun in **first person** (your hands) |
| **Code** | `AK47Weapon.cs` | Damage, ammo, sounds (already mostly done) |
| **Portal config** | content JSON | Tells the server which prefab paths to load |

**What you have today:** a working **world** gun (`w_ak47`) and a **viewmodel prefab** (`vm_ak47`) that still points at the world mesh. That is why the crate can look okay but first person looks broken.

**What “good” looks like:** same idea as the official **M4A1** in DXRP — separate world + view files, viewmodel has a **`camera` bone**, prefab has **arms** merged to the gun.

### Words you will see

- **S&box** — the editor and game engine (like a workshop tool for 3D games).
- **Prefab** — a saved “blueprint” for a weapon in the world or in first person (`w_ak47.prefab`, `vm_ak47.prefab`).
- **`.vmdl`** — compiled 3D model the engine loads.
- **`.vmat`** — material (textures/shader).
- **Hierarchy** — list of objects in a prefab (left panel).
- **Inspector** — settings for the selected object (right panel).
- **Asset Browser** — file list for your project (bottom panel).
- **DXRP portal** — website where you upload revisions and pin them to your server gamemode.
- **M4A1 reference** — [`M4A1_REFERENCE.md`](M4A1_REFERENCE.md) (official prefab/model patterns from dxrp-public).

### Two different “configs” (do not mix them up)

1. **Addon publish** — uploads new `.prefab` / `.vmdl` files (what you fix in S&box).
2. **Gamemode pin** — LifePunch gamemode → Addons tab → pick **Revision 33** (or newer).  
   Publishing alone does nothing in-game until the gamemode uses that revision and you **sync the dev server**.

You already pinned a revision correctly. The remaining work is **S&box assets**, not more portal JSON.

### How long this takes (roughly)

| Phase | Time (estimate) | Skill |
|-------|-----------------|--------|
| 0–1 S&box cleanup | 30–60 min | Clicking in editor |
| 2 Blender `camera` bone | 1–3 hours first time | Blender basics |
| 3–4 `v_ak47` + prefab | 1–2 hours | S&box model + prefab |
| 5 Test | 30 min | In-game |
| 6 Publish | 15 min | Portal upload |

---

## What you are fixing

| Problem | Cause |
|---------|--------|
| Giant gun blocking the screen | Viewmodel uses the **world** model (`w_ak47`) with no `camera` bone |
| Blank kill-feed icon | Separate fix: `iconPath` must start with `/` (portal JSON) |
| Shipment gun too big | World model scale in `w_ak47.vmdl` (`import_scale`) |

First-person needs a **viewmodel** file (`v_ak47.vmdl`) and a prefab wired like the official **M4A1**.

---

## Phase 0 — Open the correct project

1. Launch **S&box** (the game/editor).
2. On the home screen, choose **Open Project** (or File → Open).
3. Navigate to this file and open it:

```text
C:\Users\jared\Projects\LIFEPUNCH\lifepunch\addons\addons.sbproj
```

4. Wait until the editor finishes loading (bottom status bar stops saying “compiling” for a long time).
5. Confirm the window title or project name says something like **LifePunch Addons** (not a random empty project).

**Wrong folder warning:** If your path bar shows `lifepunchaddons\lifepunchaddons\...` (doubled name), close that project and open the path above.

---

## Phase 1 — Fix `vm_ak47.prefab` broken paths (do this first)

Your screenshot showed wrong paths like `models/weapons/w_ak47.vmdl`. Those are **not** in the LifePunch addon.

### 1.1 Open the prefab

1. Open the **Asset Browser** panel (usually bottom of the screen).
2. In the left tree, expand:
   - `Assets`
   - `addons`
   - `lifepunch`
   - `ak47`
   - `equipment`
   - `vm_ak47`
3. **Double-click** `vm_ak47.prefab`.
4. You should see a tab like **Prefab: Vm Ak 47** and a 3D view.

### 1.2 Find the object with the model

1. Open the **Hierarchy** panel (top left).
2. Click the child named **Model** (if it exists). If there is only `vm_ak47` on root with a renderer, click **vm_ak47**.
3. Look at the **Inspector** panel (right side) for **Model Renderer (Skinned)**.

### 1.3 Set the correct model

1. Find the **Model** field in the Inspector.
2. Click the **small folder / browse** button next to it (not the dropdown with wrong old paths).
3. In the picker, navigate to:

```text
addons/lifepunch/ak47/models/lifepunch/ak47/w_ak47/w_ak47
```

4. Select **w_ak47.vmdl** and confirm.

The Model field should now show a path starting with **`addons/lifepunch/ak47/`**, never `models/weapons/`.

### 1.4 Set the correct material (if used)

1. If **Material Override** is set to `materials/weapons/...`, clear it or browse to:

```text
addons/lifepunch/ak47/models/lifepunch/ak47/w_ak47/materials/ak47_body.vmat
```

### 1.5 Turn off animation graph (important)

1. In the same **Model Renderer** section, find **Use Animation Graph**.
2. **Uncheck** it.
3. Clear **Animation Graph** (should be empty / None).

We do not have `ak47.vanmgrph` in this addon. Leaving it on causes errors and broken view.

### 1.6 ViewModel component links

1. Click the root object **vm_ak47** in Hierarchy.
2. In Inspector, find **View Model** (DXRP component).
3. Set:
   - **Model Renderer** → drag the **Skinned Model Renderer** from the Model child (or root weapon renderer).
   - **Muzzle** → drag the **Muzzle** child object from Hierarchy.
   - **Ejection Port** → drag the **EjectionPort** child object.
4. Leave **Arms** empty for now (we add arms in Phase 4).

### 1.7 Save

1. Press **Ctrl+S** or File → Save.
2. Check the bottom-right error count — it should drop after fixing paths and anim graph.

This phase only stops errors and uses the **world** model temporarily. First person will still look wrong until Phase 2–4.

---

## Phase 2 — Prepare viewmodel FBX (Blender)

You need a `camera` bone for DXRP. The world FBX may not have one.

### 2.1 Install / open Blender

Use Blender 3.x or 4.x (free).

### 2.2 Import world mesh

1. File → Import → FBX.
2. Open:

```text
C:\Users\jared\Projects\LIFEPUNCH\lifepunch\addons\Assets\addons\lifepunch\ak47\models\lifepunch\ak47\w_ak47\source\ak47.fbx
```

### 2.3 Orient for first person

1. Rotate the rifle so it points **forward** along the axis S&box expects (compare to M4A1: barrel forward, grip down).
2. Scale in Blender is optional; final size is tuned in S&box **import_scale**.

Tip: Export a version that looks like a gun held in the lower-right of the screen, not flat like on a crate.

### 2.4 Add a `camera` bone

1. In Blender, add an **Armature** (skeleton) if the mesh has no bones.
2. Add one bone named exactly: **`camera`** (lowercase).
3. Place the bone tip where the player’s eye should be when aiming (near rear sight).
4. Parent or weight the mesh to the armature if required by your export settings.

### 2.5 Export viewmodel FBX

1. File → Export → FBX.
2. Save as:

```text
C:\Users\jared\Projects\LIFEPUNCH\lifepunch\addons\Assets\addons\lifepunch\ak47\models\lifepunch\ak47\v_ak47\source\ak47_vm.fbx
```

3. In export options, include **Armature** / bones if offered.

---

## Phase 3 — Create `v_ak47.vmdl` in S&box

### 3.1 Create folder (already in repo)

```text
Assets/addons/lifepunch/ak47/models/lifepunch/ak47/v_ak47/
```

### 3.2 Create the model asset

1. In Asset Browser, go to `addons/lifepunch/ak47/models/lifepunch/ak47/v_ak47/`.
2. Right-click → **Create** → **Model** (or equivalent “New Model”).
3. Name it: **v_ak47**.

### 3.3 Import mesh

1. Double-click **v_ak47.vmdl** to open the **Model Editor**.
2. Add / import mesh from `source/ak47_vm.fbx`.
3. Assign material **ak47_body.vmat** (browse to the same material under `w_ak47/materials/`).

### 3.4 Tune import scale

1. Find **Import Scale** (world model uses `0.039` in `w_ak47.vmdl`; viewmodel will need its own value).
2. Start around **0.05–0.1** and adjust until the preview rifle is **hand-sized**, not room-sized.
3. **Compile** / save the model until there are no red errors in the model editor.

### 3.5 Confirm `camera` bone

1. In the model editor, open the **skeleton / bones** list.
2. You must see a bone named **`camera`**.
3. If missing, go back to Blender and re-export with the bone named correctly.

---

## Phase 4 — Rebuild `vm_ak47.prefab` like M4A1

Open official reference in another window (GitHub or local `dxrp-public` clone):

- `game/Assets/gameplay/equipment/weapons/m4a1/vm_m4a1.prefab`

### 4.1 Clean old workaround

1. Open `vm_ak47.prefab` again.
2. **Delete** the child object named **Model** that only existed for manual position/scale offsets.
3. We will put the renderer on the **root** instead.

### 4.2 Weapon renderer on root

1. Select root **vm_ak47**.
2. Add Component → **Skinned Model Renderer** (if not already on root).
3. Set:
   - **Model** → `addons/lifepunch/ak47/models/lifepunch/ak47/v_ak47/v_ak47.vmdl`
   - **Create Bone Objects** → **ON** (checked)
   - **Use Animation Graph** → off (until you have AK animations)
   - **Render Options** → Overlay Layer **on**, Game Layer **off**
   - **Render Type** → **Off** (same as M4A1 viewmodel)

### 4.3 Arms (like M4A1)

1. On the same root **vm_ak47**, add a **second** Skinned Model Renderer.
2. Set:
   - **Model** → `models/first_person/v_first_person_arms_human.vmdl`
   - **Bone Merge Target** → the weapon Skinned Model Renderer you just added
   - Same overlay render settings as the weapon renderer

### 4.4 ViewModel component

1. On root, configure **View Model**:
   - **Model Renderer** → weapon renderer
   - **Arms** → arms renderer
   - **Muzzle** / **Ejection Port** → pick from **bone children** under the weapon (expand Hierarchy after Create Bone Objects creates bones)

### 4.5 Place muzzle and ejection

1. After **Create Bone Objects**, Hierarchy may show many bones.
2. Move **Muzzle** to the barrel tip bone (or parent it under the correct bone).
3. Move **EjectionPort** near the ejection port on the receiver.
4. Values should be **small** (like M4A1: ~20 units), not hundreds like the old world-model offsets.

### 4.6 Tags

Root object tags must include: **`player`** and **`viewmodel`** (already on repo prefab).

### 4.7 Save prefab

Ctrl+S. Reopen the prefab once to confirm paths saved correctly.

---

## Phase 5 — Test before publishing

### Option A — S&box local play (if your setup supports mounting this addon)

1. Use the addons project play mode or your DXRP dev workflow.
2. Equip AK-47 in first person.

### Option B — DXRP dev server (after publish)

Use only after local prefab looks sane in editor preview.

**Pass criteria:**

- [ ] Gun sits lower-right, not blocking the whole screen
- [ ] You can see the environment past the weapon
- [ ] Firing: muzzle flash at barrel, not in the air
- [ ] Shipment/world model still looks OK on crate

---

## Phase 6 — Publish to DXRP (only after Phase 5)

In PowerShell:

```powershell
cd C:\Users\jared\Projects\LIFEPUNCH\lifepunch\addons
.\scripts\validate-layout.ps1
.\scripts\prepare-publish.ps1 -Addon ak47
```

Portal:

1. Publish revision — upload **Code** and **Assets** from `.dxrp-publish/upload`.
2. Content JSON — keep `iconPath` as:

```json
"iconPath": "/addons/lifepunch/ak47/ui/ak47_killfeed.png"
```

3. **Game Modes → LifePunch → Addons** → AK-47 → pick **newest** revision.
4. **Save** → **Sync Servers** → **development server only** → **restart** server.

---

## Common mistakes

| Mistake | Fix |
|---------|-----|
| Model path `models/weapons/...` | Browse under `addons/lifepunch/ak47/...` |
| Animation graph on | Turn off until you have AK anim files |
| Publishing before S&box test | Finish Phase 5 first |
| Only changing gamemode JSON | Prefab/model must change in S&box |
| Editing wrong `.sbproj` | Open `lifepunch/addons/addons.sbproj` |

---

## When you are stuck

Send screenshots of:

1. Inspector → Model Renderer (full Model path visible)
2. Model editor → bone list for `v_ak47`
3. Hierarchy of `vm_ak47` after Create Bone Objects
4. In-game first person after local or dev test

Also say which **phase number** you are on.
