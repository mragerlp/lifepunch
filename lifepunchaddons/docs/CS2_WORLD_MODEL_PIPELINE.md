# CS2 world model pipeline — fix broken 3P / drops

**Owner decision (2026-06-11):** Sketchfab / guesswork world meshes failed. **CS2 is the proportion source** for every `w_<ident>.vmdl`. LifePunch still ships **own** FBX + materials + sounds (AK WAV pattern is the gold standard).

---

## Why world models broke

| Failure | Fix from CS2 study |
|---------|-------------------|
| Gun falls through floor on drop | ModelDoc **physics / collision hull** (class `w_m4a1` has one; our `w_ak47` did not) |
| Wrong hold angle / scale | Export CS2 **world/dropped** mesh; match grip in Blender to class prefab offsets |
| Frankenstein FP bonemerge | **Do not** bonemerge static mesh onto M4 bones — class `vm_*` until rig pass |
| Iridescent / broken materials | Rebuild vmats from CS2 **channel study** (baseColor/normal/roughness), own textures |

---

## Harvest TWO meshes per weapon (CS2)

In Source 2 Viewer, `weapons/models/<folder>/` usually has **multiple** `.vmdl_c` files:

| File type | Export to | LifePunch use |
|-----------|-----------|---------------|
| **Viewmodel** (arms gun, often largest anim list) | `reference-intake/.../<ident>/viewmodel/` | Proportions, moving parts, reload **timing** study |
| **World / dropped** (ground model, may be separate file) | `reference-intake/.../<ident>/world/` | **Author `w_<ident>.fbx` from this** — 3P hand + drop pickup |
| Mag / attachments | `attachments/` | Optional |

**Rule:** If you only export the viewmodel glTF, your world gun will keep looking wrong. Always hunt for the dropped/world variant in S2V.

---

## Blender → ship (per weapon)

```
CS2 world glTF  →  retopo/clean  →  w_<ident>.fbx (LifePunch-owned)
                                      ↓
                              ModelDoc w_<ident>.vmdl
                              + convex PHYSICS mesh  ← mandatory
                              + ak47_body-style vmats (own PNGs)
                                      ↓
                              Clone class w_* prefab → swap Model child
                              Keep class vm_* on ViewModelPrefab
```

### ModelDoc checklist (every weapon)

1. **Render mesh** from `source/w_<ident>.fbx`
2. **Physics** tab → generate simplified convex hull (or manual low-poly collision mesh)
3. **import_scale** — compare CS2 world glTF beside class `w_m4a1` in editor; tune until hand grip matches `DXRP_CLASS_WEAPON_REFERENCES.md`
4. **import_translation Z** — shipment crate height only (see `M4A1_REFERENCE.md`)
5. Compile → `_c` present before publish

### Prefab checklist

Clone **class** `w_<dxrpClass>.prefab` from DXRP — do not fork from broken LifePunch AK prefab.

- Copy all **Functions** (Ammo, Shoot, Reload, Recoil, …)
- Swap `Model` → `w_<ident>.vmdl`
- **Muzzle / EjectionPort** — retune using class offsets as starting point
- `ViewModelPrefab` → class `vm_<class>` until FP rig ships

---

## Sounds — keep LifePunch-owned (AK pattern)

CS2 sounds are **reference mix only** — never ship Valve WAVs in publish tree.

| Step | Action |
|------|--------|
| 1 | S2V search `sounds/` for weapon name → export reference WAV to `reference-intake/.../sounds/` |
| 2 | Re-record or edit **own** WAVs under `Assets/.../sounds/` (see `ak47/sounds/` — these work in-game) |
| 3 | Wire `.sound` resources on prefab (fire, reload, distant, draw) |

See `CS2_SOUND_REFERENCE.md` for search terms per weapon.

---

## Red batch session (VENGEANCE)

```powershell
cd lifepunchaddons\scripts
$vpk = 'D:\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\pak01_dir.vpk'
$cli = 'C:\Tools\Source2Viewer-CLI.exe'
powershell -File .\Intake-Cs2WeaponReference.ps1 -Cs2Vpk $vpk -CliPath $cli -ExportGltf
```

Then per weapon: Blender world mesh → ModelDoc with physics → `lp_give_<ident>` → drop test.

**Play while rebuilding:** `lp_give_ak_class`, `lp_give_deagle`, etc. (class kits).

---

Canon: `CS2_WEAPON_HARVEST.md` · `CS2_FIRST_WEAPON_TEST.md` · `config/weapon-production.json`
