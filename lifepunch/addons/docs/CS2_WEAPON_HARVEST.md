# CS2 weapon harvest — study assets for LifePunch remakes

**Purpose:** Grab Counter-Strike 2 meshes, animations, textures, and sounds for **reference only** while we author **LifePunch-owned** ship assets.  
**Never commit** CS2 exports to the monorepo. Store under `C:/lifepunch/reference-intake/cs2-weapons/`.  
**Canon queue:** `config/weapon-production.json` · build lane: `WEAPON_MASS_PRODUCTION.md`

---

## The two-source rule (read this first)

| Source | What you harvest | What you ship in DXRP |
|--------|------------------|------------------------|
| **CS2** (`pak01_dir.vpk`) | Mesh proportions, materials, moving parts, reload **timing** study, sound **reference** | **Nothing** — reference-only |
| **s&box Facepunch** (cloud + download cache) | **First-person rig**, shared **animations**, **animgraph**, class **prefab wiring**, hold types | **Reuse** via class kit clone (M4A1, USP, MP5, M700, Spaghelli) |
| **LifePunch** (Blender + ModelDoc) | Own `w_*.fbx`, `v_*.fbx` bind, own `.vmat`, own `.sound` | Everything in portal publish |

CS2 animations **do not port 1:1** into s&box. Use CS2 to **model** the gun; use the **DXRP class viewmodel** for deploy / reload / fire / ADS / IK.

See `WEAPON_CLASS_SPEC.md`, `VIEWMODEL_RIG_PIPELINE.md`, `SBOX_EDITOR_REFERENCE.md` §5.

---

## Tooling

### Source 2 Viewer (VRF) — primary

- Download: [s2v.app](https://s2v.app/) (GUI + optional `Source2Viewer-CLI.exe`)
- **VENGEANCE GUI:** `C:\Tools\Source2Viewer\Source2Viewer.exe` (Desktop shortcut)
- CS2 VPK on VENGEANCE: `D:\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\pak01_dir.vpk`

### Blender

- Import **glTF/GLB** from S2V (not raw `.vmdl_c` — glTF is the supported path post-CS2 updates).

### s&box editor (parallel lane)

- Cloud scope → download **ViewModel &lt;Class&gt;** + world model for each DXRP reference weapon.
- ModelDoc → **Export As… FBX** on `v_m700` / class `v_*` for rig study (`VIEWMODEL_RIG_PIPELINE.md`).

---

## Where CS2 hides weapon assets

Open `pak01_dir.vpk` → browse:

| Asset type | Typical VPK path | Export format |
|------------|------------------|---------------|
| Weapon models (mesh + skeleton) | `weapons/models/<weapon>/` | glTF / GLB |
| Animations | Bundled on model; preview in S2V animation dropdown | glTF with `--gltf_export_animations` |
| Compiled textures | Embedded in glTF export; also `*.vtex_c` nearby | PNG via S2V |
| Sound events | `soundevents/` + weapon-specific `*.vsndevts` | Decompile → inspect |
| Raw sounds | `sounds/` (filter `weapons` in S2V search) | WAV via S2V |
| Weapon metadata | `scripts/items/items_game.txt`, `scripts/weapons.vdata` | Text — timing/stats study only |

### LifePunch queue → CS2 mesh names

| ident | `cs2Mesh` | S2V browse hint |
|-------|-----------|-----------------|
| `ak47` | `weapon_rif_ak47` | `weapons/models/ak47/` |
| `deagle` | `weapon_pist_deagle` | `weapons/models/deagle/` |
| `mp9` | `weapon_smg_mp9` | `weapons/models/mp9/` |
| `ssg08` | `weapon_snip_ssg08` | `weapons/models/ssg08/` |
| `xm1014` | `weapon_shot_xm1014` | `weapons/models/xm1014/` |

Inside each folder you usually get **multiple** `.vmdl_c` files:

- **Viewmodel / arms gun** — first-person mesh (often `*_ag2` or primary weapon model — **not** the magazine-only file).
- **World / dropped** — third-person or ground model (if separate).
- **Magazine / attachments** — separate files; grab if your remake has detachable mag animation.

**Rule:** Open each `.vmdl_c` in S2V, check the animation dropdown, then export.

---

## GUI harvest (one weapon)

1. S2V → Open `pak01_dir.vpk`.
2. Navigate `weapons/models/<weapon>/`.
3. Double-click the **main** weapon `.vmdl_c` (skip mag-only unless needed).
4. Toolbar → **animation dropdown** → preview reload, fire, idle, inspect.
5. Right-click tab → **Decompile & Export** → format **glTF** (or **GLB** for single file).
6. Save to `C:/lifepunch/reference-intake/cs2-weapons/<ident>/viewmodel/` (or `world/` if that's what you opened).
7. Repeat for world/dropped variant if it exists.
8. Search VPK `sounds/` for weapon name → export key WAVs to `.../<ident>/sounds/`.
9. Write `MANIFEST.txt` (weapon name, files exported, animation names seen in S2V).

---

## CLI batch (all animations on one model)

Install CLI next to GUI or add to PATH, then:

```powershell
$cli = 'C:\Path\To\Source2Viewer-CLI.exe'
$vpk = 'D:\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\pak01_dir.vpk'
$out = 'C:\lifepunch\reference-intake\cs2-weapons\deagle'
# Extract specific vmdl_c from VPK first, or point -i at exported path after VPK extract:
& $cli -i "$vpk\weapons\models\deagle\weapon_pist_deagle.vmdl_c" `
  -o "$out\viewmodel\weapon_pist_deagle.glb" -d `
  --gltf_export_format glb `
  --gltf_export_materials `
  --gltf_export_animations
```

List-only pass (discover animation names before export):

```powershell
& $cli -i "model.vmdl_c" -o "out.glb" -d --gltf_export_animations --gltf_animation_list "idle,reload,fire"
```

Repo helper (after CLI installed): `addons/scripts/Intake-Cs2WeaponReference.ps1`

---

## Target intake folder layout

```text
C:/lifepunch/reference-intake/cs2-weapons/
  <ident>/
    MANIFEST.txt
    viewmodel/          ← glTF/GLB + textures (FP study)
    world/              ← 3rd-person / dropped study
    attachments/        ← mag, silencer, etc. (optional)
    sounds/             ← WAV reference (do not ship)
    notes.md            ← Blender cleanup notes, mag bone names
```

---

## From CS2 study → LifePunch ship (per weapon)

1. **CS2 glTF** → Blender: measure scale, note moving parts (bolt, mag, slide).
2. **Author own mesh** → `w_<ident>.fbx` (static world model is fine).
3. **ModelDoc** → `w_<ident>.vmdl` + LifePunch materials.
4. **Clone class prefab** (`w_usp`, `w_m4a1`, …) → save as `equipment/w_<ident>/`.
5. **First person:** bind mesh to Facepunch rig OR class placeholder `vm_<class>` until rig batch (`VIEWMODEL_RIG_PIPELINE.md`).
6. **Sounds:** own WAVs (AK pattern in `ak47/docs/SOURCE_INTAKE.md`) — use CS2 only as **reference mix**, not ship.
7. **Functions:** copy reload/fire/recoil from class prefab; tune stats in `<Pascal>.cs`.

---

## s&box harvest checklist (do in parallel — not CS2)

For each DXRP class reference, in editor with API connected:

| Class | Download from cloud | Cache path (after download) |
|-------|---------------------|-----------------------------|
| Assault Rifle | ViewModel M4A1, M4A1 | `download/assets/models/weapons/sbox_assault_m4a1/` |
| Handgun | ViewModel USP, USP | `sbox_pistol_usp` |
| SMG | ViewModel MP5 | `sbox_smg_mp5` |
| Sniper | ViewModel M700 | `sbox_sniper_m700` |
| Shotgun | ViewModel Spaghelli M4 | `sbox_shotgun_spaghelli` |

From each cached `v_*.vmdl`:

- Read animgraph / animation list (companion `.vanmgrph` if present).
- ModelDoc **Export As… FBX** once per class for rig template.
- Open `vm_<class>.prefab` in DXRP — copy Functions, sound event refs, muzzle bones.

---

## AK-47 note

Golden kit shipped from cleaned Sketchfab FBX + own WAV sounds (`ak47/docs/SOURCE_INTAKE.md`). CS2 `weapon_rif_ak47` is now an **active study target** for finishing `v_ak47` on the M4A1 class rig (animation timing, moving parts, proportions). Cornerman brief: `briefs/CORNERMAN_AK47_CS2_STUDY_TASK.md` · distill: `reference/CS2_AK47_STUDY.md`.

---

## Legal / ship boundary

- CS2 assets are **Valve** — LifePunch ships **original** meshes/materials/sounds we author.
- CS2 folder stays **outside git** (`reference-intake/`).
- Cornerman may catalog manifests; Red owns Blender + ModelDoc + publish.

---

## Related docs

- `WEAPON_INTAKE.md` — classify `reference-only` vs `use`
- `WEAPON_MASS_PRODUCTION.md` — queue + publish gates
- `briefs/DEAGLE_WEAPON_BRIEF.md` — next gun step 1
