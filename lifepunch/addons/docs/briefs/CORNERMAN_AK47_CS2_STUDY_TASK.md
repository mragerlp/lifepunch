# Cornerman task — AK-47 CS2 study (parallel while Red tests Bitminer)

**Lane:** Tier-3 prep · **Priority:** **#0** (run in parallel with coke/deagle — do not block on Red)  
**Issued:** 2026-06-11

---

## Goal

Catalog everything useful in CS2 for the **AK-47 golden kit** — models, animations, textures, sounds — so Red can finish `v_ak47` on the **M4A1 class rig** without guessing.

**You do NOT:** export CS2 into the monorepo, edit `Ak47.cs`, open s&box, or `git push`.

---

## Read first (30 min)

| Doc | Why |
|-----|-----|
| `addons/docs/CS2_WEAPON_HARVEST.md` | Two-source rule, S2V paths, CLI |
| `addons/docs/briefs/AK47_CS2_STUDY_BRIEF.md` | Deliverables + identity table |
| `addons/docs/VIEWMODEL_RIG_PIPELINE.md` | FP = class rig, not CS2 skeleton |
| `addons/docs/AK47_FIX_CHECKLIST.md` | Current `camera` bone WIP state |
| `Code/Addons/lifepunch/ak47/docs/SOURCE_INTAKE.md` | Existing Sketchfab intake |

---

## Task 1 — Intake scaffold

On Green (no VPK required):

```powershell
cd C:\Projects\lifepunch\lifepunch\addons\scripts
powershell -File .\Intake-Cs2WeaponReference.ps1 -Ident ak47 -ManifestOnly
```

Confirm `C:\lifepunch\reference-intake\cs2-weapons\ak47\MANIFEST.txt` exists.

If Red already exported glTF on VENGEANCE, list files in `viewmodel/`, `world/`, `sounds/` and append paths to MANIFEST.

---

## Task 2 — CS2 mesh inventory

Produce section **## Mesh inventory** in `addons/docs/reference/CS2_AK47_STUDY.md`:

| File (vmdl_c name) | Role | Notes |
|--------------------|------|-------|
| `weapon_rif_ak47` | primary VM? | confirm in S2V or Valve wiki |
| … | mag / world / legacy | skip mag-only unless detachable mag study needed |

Sources (pick what works on Green):

- `CS2_WEAPON_HARVEST.md` browse hints
- [CS2 weapon models wiki](https://developer.valvesoftware.com/wiki/Counter-Strike_2_Workshop_Tools/Weapons) (nominative)
- Red screenshot from S2V folder tree (ask in ack if needed)

---

## Task 3 — Animation catalog

In `CS2_AK47_STUDY.md` section **## Animation catalog**:

| Sequence (CS2 name) | ~Duration | Moving parts | Maps to M4 class anim |
|---------------------|-----------|--------------|------------------------|
| deploy / draw | | | M4 deploy |
| idle | | | M4 idle |
| fire | | bolt | M4 fire |
| reload | | mag + bolt | M4 reload |
| reload_empty | | | M4 empty reload |
| inspect | | | optional |
| … | | | |

**Rule:** CS2 anims are **timing + choreography study** only. Ship column must name **DXRP M4** reuse (`vm_m4a1` / shared animgraph), not CS2 bone names.

If you cannot open VPK, mark cells `TBD — Red S2V export` and list **expected** rifle sequences from Valve CS2 docs.

---

## Task 4 — Material + proportion notes

**Materials** — compare CS2 glTF material slots (when present) to LifePunch `ak47_body.vmat` channels in `w_ak47/materials/`.

**Proportions** — side-by-side checklist:

- Barrel length vs M4 reference photo
- Magazine curvature / angle
- Stock shape (folding vs fixed — CS2 AK is fixed)
- Grip vs trigger guard distance
- Iron sight height

Mark actionable deltas for Red Blender pass on `v_ak47/source/ak47_vm.fbx`.

---

## Task 5 — M4 class anim map

Create `addons/docs/reference/M4A1_CLASS_ANIM_MAP.md`:

- List M4 prefab anim events / sound hooks from `M4A1_REFERENCE.md` + `DXRP_CLASS_WEAPON_REFERENCES.md`
- For each, note CS2 AK **timing target** (e.g. full mag reload ~2.5s study value — verify in S2V)
- Call out IK / muzzle / ejection port bones on M4 that AK mesh must align to

---

## Task 6 — Sound index

Section **## CS2 sound index** in `CS2_AK47_STUDY.md`:

- Search terms: `ak47`, `ak_47`, `weapon_rif_ak47`
- Typical paths under `sounds/weapons/...`
- Map to LifePunch owned sounds already in `Assets/.../ak47/sounds/` (shot, reload, draw, distant)

---

## Task 7 — SOURCE_INTAKE append

Append to `Code/Addons/lifepunch/ak47/docs/SOURCE_INTAKE.md`:

```markdown
## CS2 reference intake (study only)

- Mesh: weapon_rif_ak47
- Intake: C:/lifepunch/reference-intake/cs2-weapons/ak47/
- Animation catalog: see addons/docs/reference/CS2_AK47_STUDY.md
- Ship boundary: no CS2 assets in publish tree; FP via M4A1 class kit
```

---

## Commit + ping

```text
docs(ak47): CS2 study distill + M4 class anim map
```

Copy `CS2_AK47_STUDY.md` + `AK47_CS2_STUDY_BRIEF.md` to `C:\lifepunch\cornerman\outbox\` for RAG.

Ping Red: `AK47 CS2 study commit on Green — subjects: ...`

---

## References on box

| Path | Role |
|------|------|
| `C:\lifepunch\cornerman\inbox\` | This brief + `AK47_CS2_STUDY_BRIEF.md` |
| `C:\lifepunch\reference-intake\cs2-weapons\ak47\` | glTF + MANIFEST (Red may fill) |
| `C:\lifepunch\cornerman\outbox\` | Your distill for RAG |
