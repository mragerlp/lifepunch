# CS2 AK-47 study (reference only)

**Status:** Green distill complete (2026-06-11) · Red verifies durations in S2V  
**Ship boundary:** Nothing from this doc ships. LifePunch owns `w_ak47` / `v_ak47` meshes and sounds. FP animations reuse **M4A1 class kit**.

**Intake root:** `C:/lifepunch/reference-intake/cs2-weapons/ak47/`  
**CS2 mesh:** `weapon_rif_ak47` · **S2V path:** `weapons/models/ak47/`

---

## Mesh inventory

| File (vmdl_c name) | Role | Notes |
|--------------------|------|-------|
| `weapon_rif_ak47` | **Viewmodel (primary)** | Arms + gun FP mesh; animation dropdown lives here |
| `weapon_rif_ak47_ag2` | Viewmodel variant | Often duplicate skeleton — open both in S2V, export **one** canonical VM |
| `weapon_rif_ak47_mag` | Magazine only | Optional — detachable mag choreography study |
| `weapon_rif_ak47_dropped` / world variant | **World / dropped** | Separate from VM — use for `w_ak47` proportion pass (`CS2_WORLD_MODEL_PIPELINE.md`) |

**Red action:** List exact filenames from S2V folder tree; append to `MANIFEST.txt` § `animations_seen`.

---

## Animation catalog

Expected CS2 sequences on `weapon_rif_ak47` (verify in S2V — mark **Red** if names differ):

| Sequence (CS2) | ~Duration | Moving parts | M4 class reuse |
|----------------|-----------|--------------|----------------|
| `deploy` / `draw` | ~1.0s | whole rig | M4 deploy — tune `ak47_draw.sound` |
| `idle` | loop | subtle sway | M4 idle |
| `fire` | ~0.08s | bolt, muzzle | M4 fire — `ak47_shot.sound` |
| `reload` | ~2.45s | mag out/in, bolt | M4 reload — clipout + clipin |
| `reload_empty` | ~3.10s | mag, bolt hold-open | M4 empty reload + `ak47_cock.sound` |
| `inspect` | ~3.5s | mag tap, bolt | optional — skip Phase 1 |
| `zoom_in` / `zoom_out` | ~0.2s | slight ADS | M4 ADS (if enabled) |
| `lookat01` | loop | cosmetic | skip |

**Rule:** CS2 skeleton does **not** port. Ship column names **DXRP M4** animgraph events only. Durations inform editor tuning on `vm_m4a1` placeholder.

---

## Material channels (CS2 glTF study)

| CS2 / glTF slot | LifePunch `ak47_body.vmat` | Action |
|-----------------|------------------------------|--------|
| `baseColor` / albedo | `textures/ak47_BaseColor.tga.png` | Match value range; CS2 often darker |
| `normal` | `textures/ak47_Normal.tga.png` | OpenGL normal — flip green if import wrong |
| `roughness` | `textures/ak47_Roughness.tga.png` | PBR roughness channel |
| `metalness` | `textures/ak47_Metalness.tga.png` | PBR metalness channel |
| AO packed ORM | CS2 may pack R=AO G=Rough B=Metal | Split if CS2 export uses ORM |

**Red:** Export glTF from S2V → note actual slot names in `MANIFEST.txt`.

---

## Proportion delta (CS2 vs shipped `w_ak47`)

| Feature | CS2 reference | LifePunch `w_ak47` (Sketchfab) | Delta / action |
|---------|---------------|--------------------------------|----------------|
| Barrel length | Longer vs M4; curved mag well | Cleaned FBX | TBD — Red Blender measure vs CS2 world glTF |
| Magazine angle | ~15° curve, prominent | Sketchfab mag | Align mag well depth for 3P hold |
| Stock profile | Fixed wood/metal AK stock | Shipped mesh | Match silhouette for killfeed readability |
| Grip vs trigger guard | Compact pistol grip | Shipped | Verify hand clearance on `HoldType` rifle |
| Sight height | Tall iron sights | Shipped | Muzzle line vs `Muzzle` child on prefab |
| Overall length (3P) | ~87 cm class | TBD mm in Blender | Scale to M4 crate relationship per `M4A1_REFERENCE.md` |

Mark precise mm after Red exports **world** glTF — Green uses qualitative checklist until then.

---

## CS2 sound index

| CS2 path (study) | Typical event | LifePunch owned sound | Status |
|------------------|---------------|----------------------|--------|
| `sounds/weapons/ak47/ak47-1.wav` | fire close | `ak47_shot.sound` | shipped |
| `sounds/weapons/ak47/ak47_distant.wav` | fire far | `ak47_shot_distant.sound` | shipped |
| `sounds/weapons/ak47/ak47_clipout.wav` | reload start | `ak47_reload_clipout.sound` | shipped |
| `sounds/weapons/ak47/ak47_clipin.wav` | reload end | `ak47_reload_clipin.sound` | shipped |
| `sounds/weapons/ak47/ak47_boltpull.wav` | empty tail | `ak47_cock.sound` | shipped |
| `sounds/weapons/ak47/ak47_draw.wav` | deploy | `ak47_draw.sound` | shipped |
| `soundevents/weapon.ak47.vsndevts` | event names | map on prefab | TBD — Red decompile |

Search VPK: `ak47`, `rif_ak47`, `weapon_rif_ak47`. Export reference WAV to `reference-intake/cs2-weapons/ak47/sounds/`.

---

## Red S2V checklist

1. `Intake-Cs2WeaponReference.ps1 -Ident ak47` (full export on VENGEANCE).
2. Fill `MANIFEST.txt` animation list + sound event names.
3. Replace `TBD` durations in this doc with S2V timeline readouts.
4. ModelDoc export `v_m4a1` FBX for bone cross-check (`M4A1_CLASS_ANIM_MAP.md`).

---

## Related

- `briefs/AK47_CS2_STUDY_BRIEF.md` · `M4A1_CLASS_ANIM_MAP.md`
- `CS2_WEAPON_HARVEST.md` · `VIEWMODEL_RIG_PIPELINE.md` · `AK47_FIX_CHECKLIST.md`
