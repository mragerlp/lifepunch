# AK-47 — CS2 study brief (golden kit upgrade)

**Issued:** 2026-06-11 · **Lane:** Green distill · **Red:** tests BitcoinMiningAddon + runs S2V exports on VENGEANCE  
**Canon:** `config/weapon-production.json` · `CS2_WEAPON_HARVEST.md` · `VIEWMODEL_RIG_PIPELINE.md` · `AK47_FIX_CHECKLIST.md`

---

## Why now

AK-47 is the **golden kit** — other four guns copy its lane. First-person still uses baseline tricks (`vm_ak47` → M4 placeholder / world mesh bind). CS2 `weapon_rif_ak47` is **study-only** but is the best proportion, attachment, reload **timing**, and moving-parts reference for finishing `v_ak47` on the **M4A1 class rig**.

**Ship rule:** LifePunch owns meshes/materials/sounds. CS2 glTF never commits. FP animations come from **s&box `v_m4a1` class kit**, not CS2 skeleton.

---

## Identity

| Field | Value |
|-------|--------|
| ident | `ak47` |
| DXRP class | **Assault Rifle** → clone **`m4a1`** kit |
| CS2 study mesh | `weapon_rif_ak47` |
| S2V browse | `weapons/models/ak47/` inside `pak01_dir.vpk` |
| Intake root | `C:/lifepunch/reference-intake/cs2-weapons/ak47/` |
| LifePunch world | `.../w_ak47/w_ak47.vmdl` (Sketchfab FBX — shipped) |
| LifePunch viewmodel | `.../v_ak47/v_ak47.vmdl` (`ak47_vm.fbx` + `camera` bone — WIP) |

---

## What Green studies (no s&box required)

1. **CS2 mesh inventory** — list every `.vmdl_c` under `weapons/models/ak47/` (main gun, mag, variants).
2. **Animation catalog** — every sequence name visible in S2V dropdown on the **main** viewmodel file; note duration hints for reload / deploy / fire.
3. **Moving parts** — bolt, mag, charging handle, safety — which bones/mesh groups animate on reload vs fire.
4. **Material channels** — glTF export channel names (baseColor, normal, roughness, metalness) vs our `ak47_body.vmat`.
5. **Proportion delta** — CS2 vs shipped `w_ak47` (barrel length, mag angle, stock profile) — table with mm-ish Blender units if measurable from reference screenshots.
6. **M4 class anim map** — which CS2 timing notes inform tuning on DXRP M4 deploy/reload/ADS (we **reuse** M4 anims; CS2 informs **feel targets** only).
7. **Sound index** — CS2 `sounds/` paths for `ak47` / `weapon_rif_ak47` (reference WAV names for Red to replace with owned sounds).

---

## What Red does on VENGEANCE (parallel)

- Install [Source 2 Viewer](https://s2v.app/) if missing.
- Run: `addons/scripts/Intake-Cs2WeaponReference.ps1 -Ident ak47` (VPK on box).
- GUI export glTF/GLB → `reference-intake/cs2-weapons/ak47/viewmodel/` (+ `world/` if separate).
- Optional: ModelDoc **Export As FBX** on `v_m4a1.vmdl` from download cache for rig bone list cross-check.

---

## Deliverables (Green → `outbox/` + repo docs)

| File | Purpose |
|------|---------|
| `addons/docs/reference/CS2_AK47_STUDY.md` | Master distill (mesh list, anim catalog, proportion table, ship boundary) |
| `addons/docs/reference/M4A1_CLASS_ANIM_MAP.md` | CS2 timing → M4 class anim reuse map |
| `Code/Addons/lifepunch/ak47/docs/SOURCE_INTAKE.md` | Append § CS2 reference intake |
| `reference-intake/cs2-weapons/ak47/MANIFEST.txt` | Update after Red exports (or `ManifestOnly` stub now) |

---

## Related

- `M4A1_REFERENCE.md` · `DXRP_CLASS_WEAPON_REFERENCES.md`
- `RED_WEAPON_MASS_PRODUCTION_PLAN.md` — AK stays #1 golden
- `CORNERMAN_AK47_CS2_STUDY_TASK.md` — step-by-step Cornerman task
