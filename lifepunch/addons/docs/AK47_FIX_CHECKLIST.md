# AK-47 Fix Checklist (Start Here)

One page. Do the steps **in order**. Check each box before moving on.

**Open project once:**

```text
C:\Users\jared\Projects\LIFEPUNCH\lifepunch\addons\addons.sbproj
```

**M4A1 pictures to keep open:** shipment crate (world height) + first person (gun lower-right with hands).

**Deep reference (only if stuck):** [`M4A1_REFERENCE.md`](M4A1_REFERENCE.md)

---

## Part A — First person (fix “stock in your face”)

### A1. Blender — fix the `camera` bone (15–20 min)

- [ ] Open Blender → delete default cube
- [ ] **File → Import → FBX** →  
  `...\ak47\models\lifepunch\ak47\w_ak47\source\ak47.fbx`
- [ ] Rotate gun: barrel forward, magazine down (like M4A1 first-person photo)
- [ ] **Object → Apply → Rotation** (rotation should read 0,0,0)
- [ ] **Shift+A → Armature → Single Bone**
- [ ] **Tab** (Edit Mode) → rename bone to **`camera`** (exact spelling)
- [ ] Select **`camera`** bone → **R** → rotate bone so it **points down the barrel** (stock → muzzle)  
  **Not pointing up** — that causes the broken view
- [ ] Move bone head near **rear sight** (**G**)
- [ ] **Tab** (Object Mode)
- [ ] Delete **Camera** and **Light** in Outliner (not your `camera` bone)
- [ ] Select **mesh**, **Shift+select Armature** (Armature clicked **last**)
- [ ] **Ctrl+P → Armature Deform → With Automatic Weights** (or **Armature**)
- [ ] **File → Export → FBX** → save as:  
  `...\v_ak47\source\ak47_vm.fbx`  
  Turn on **Selected Objects**

### A2. S&box — compile viewmodel (5 min)

- [ ] Asset Browser → `addons/lifepunch/ak47/models/lifepunch/ak47/v_ak47/`
- [ ] Double-click **`v_ak47.vmdl`**
- [ ] Mesh = `source/ak47_vm.fbx` · Material = `../w_ak47/materials/ak47_body.vmat`
- [ ] **Import Scale** ~`0.03` (tune until rifle-sized in preview)
- [ ] **Import Rotation** try **`0, 180, 0`** only if gun faces backward in preview
- [ ] **Compile** → **Save**
- [ ] Bone list shows **`camera`**

### A3. S&box — fix viewmodel prefab (10 min)

Open **`equipment/vm_ak47/vm_ak47.prefab`**. Match M4A1 — do **not** guess paths.

| Setting | Set to |
|---------|--------|
| Root **Rotation** | `0, 0, 0` |
| Root **Scale** | `1, 1, 1` |
| Tags | `player`, `viewmodel` |
| **Model** | `addons/lifepunch/ak47/models/lifepunch/ak47/v_ak47/v_ak47.vmdl` |
| **Use Animation Graph** | Off |
| **Create Bone Objects** | On |
| **Render Type** | Off · **Overlay** On |

- [ ] **View Model** component: Model Renderer + Muzzle + Ejection Port wired
- [ ] Expand Hierarchy → find **`camera`** child (from bones)
- [ ] Later: move **Muzzle** / **EjectionPort** onto barrel bones (small numbers like ~20, not -459)
- [ ] **Ctrl+S**

**Optional (like M4A1):** second **Skinned Model Renderer** on root →  
`models/first_person/v_first_person_arms_human.vmdl` · **Bone Merge** → weapon renderer

### A4. Quick test (before publish)

- [ ] In editor: prefab shows gun at scale 1, press **F**
- [ ] **Play** from `addons.sbproj` **or** publish + dev server (Part C)
- [ ] Console: **`lp_give_ak`** (LifePunch `vm_ak47`) — not `lp_give_ak_class` (that keeps M4 vm for comparison)
- [ ] First person looks like **M4A1 photo** (lower-right, not blocking screen)

**Part A done when:** first person matches M4A1 reference.

---

## Part B — Shipment height (crate)

**Only touch world model** — not the viewmodel prefab.

- [ ] Open **`w_ak47.vmdl`** (not `v_ak47`)
- [ ] Click **`ak47.fbx`** node → **Import Translation** → adjust **Z**  
  Start: **`8`** (repo default). Increase if AK sits too low vs M4A1 crate; decrease if too high.
- [ ] **Compile** → **Save**
- [ ] Compare AK crate vs M4A1 crate in-game (same float above wood is OK)

**Part B done when:** AK shipment looks like M4A1 shipment photo.

---

## Part C — Publish to dev server (when A + B pass)

Copy-paste in PowerShell:

```powershell
cd C:\Users\jared\Projects\LIFEPUNCH\lifepunch\addons
.\scripts\validate-layout.ps1
.\scripts\prepare-publish.ps1 -Addon ak47
```

Portal:

- [ ] Upload from `.dxrp-publish\upload` (Assets + Code)
- [ ] New revision + short changelog
- [ ] **LifePunch gamemode** → AK-47 → pin **new revision** → Save
- [ ] **Sync development server only** → **restart** server
- [ ] Rejoin → test AK-47 equip + shipment crate

**Do not sync** main/production server for tests.

---

## What NOT to do

| Don’t | Why |
|-------|-----|
| Change portal JSON for rotation | Doesn’t fix bones |
| Set prefab rotation to 180° | M4A1 uses 0,0,0 |
| Use `w_ak47` on `vm_ak47` | World model breaks first person |
| Use `models/weapons/...` paths | Wrong package |
| Publish after every tiny tweak | Test locally or one dev rev |

---

## If something fails

| Problem | Fix |
|---------|-----|
| Stock fills screen | Blender: rotate **`camera`** bone along barrel → re-export FBX |
| Gun backwards | `v_ak47` import rotation Y `180`, prefab rotation stays `0` |
| Ctrl+P no Armature option | Select mesh + Armature; Armature selected **last** |
| Shipment too low/high | Only `w_ak47.vmdl` Z translation |
| Dev server unchanged | Pin new revision + restart server |

---

## File map (only these matter)

```text
v_ak47/source/ak47_vm.fbx     ← Blender export (camera bone)
v_ak47/v_ak47.vmdl            ← viewmodel compile
equipment/vm_ak47.prefab      ← first person
w_ak47/w_ak47.vmdl            ← shipment height
config/addons.json            ← already correct (no path edits needed)
```

---

## Changelog template (portal)

```text
AK-47: fix viewmodel camera bone and vm_ak47 prefab; tune w_ak47 shipment height.
```
