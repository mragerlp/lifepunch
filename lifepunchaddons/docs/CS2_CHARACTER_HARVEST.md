# CS2 character & job gear harvest — study for LifePunch jobs

**Purpose:** Study Counter-Strike 2 **agent models** and tactical props for job uniforms (SWAT, Police, Hacker, etc.).  
**Never commit** CS2 exports to the monorepo. Store under `C:/lifepunch/reference-intake/cs2-characters/`.  
**Canon queue:** `config/gear-production.json` · jobs: `SWAT_JOB_SPEC.md`, `HACKER_JOB_SPEC.md`, `GOVERNMENT_DATABASE_SPEC.md`

---

## The two-source rule (characters)

| Source | What you harvest | What you ship in DXRP |
|--------|------------------|------------------------|
| **CS2** (`characters/models/`) | Silhouette, vest/helmet proportions, material palette | **Nothing** — reference-only |
| **s&box citizen** + DXRP clothing | Skeleton, locomotion, multiplayer networking | **Reuse** rig; attach LifePunch-owned gear |
| **LifePunch** (Blender + ModelDoc) | Own vest, helmet, belt, props | Clothing / bodygroups on citizen |

CS2 agent skeletons **do not port** into DXRP player pawns. Study → model **your** gear → mount on citizen.

Weapons for jobs still use the **gun pipeline** (`CS2_WEAPON_HARVEST.md`) — class kits + LifePunch skins.

---

## Tooling

Same as weapons:

- **Source 2 Viewer:** [s2v.app](https://s2v.app/)
- **CS2 VPK:** `D:\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\pak01_dir.vpk`
- **Blender:** import glTF/GLB from S2V

### Repo helpers

```powershell
# Cornerman — MANIFEST stubs only (no CS2 install)
powershell -File lifepunchaddons/scripts/Intake-Cs2CharacterReference.ps1 -ManifestOnly

# Red — one role
powershell -File lifepunchaddons/scripts/Intake-Cs2CharacterReference.ps1 -Ident swat

# Red — batch + optional CLI export
powershell -File lifepunchaddons/scripts/Intake-Cs2CharacterReference.ps1 -Ident swat,police,hacker -CliPath 'C:\Tools\Source2Viewer-CLI.exe' -ExportGltf

# Props (riot shield study)
powershell -File lifepunchaddons/scripts/Intake-Cs2CharacterReference.ps1 -Prop riot_shield -ManifestOnly
```

---

## Where CS2 hides agents

Open `pak01_dir.vpk` → browse `characters/models/`:

| Prefix | Side | Example folders |
|--------|------|-----------------|
| `ctm_*` | Counter-Terrorist | `ctm_swat`, `ctm_fbi`, `ctm_sas`, `ctm_st6` |
| `tm_*` | Terrorist | `tm_professional`, `tm_phoenix`, `tm_leet` |

Inside each folder: multiple `*_variant*.vmdl_c` files — **open in S2V** to pick the correct variant; names change between CS2 updates.

### LifePunch role queue → starting browse paths

Machine-readable: `config/gear-production.json`.

| ident | Job | S2V browse hint | Terminal brand |
|-------|-----|-----------------|----------------|
| `swat` | SWAT | `characters/models/ctm_swat/` | lifepunchnet cyan |
| `police` | Police | `characters/models/ctm_fbi/` | lifepunchnet cyan |
| `hacker` | Hacker | `characters/models/tm_professional/` | Cornerman green |
| `mayor` | Mayor / Gov | `characters/models/ctm_sas/` | lifepunchnet cyan |
| `cybersecurity` | Cybersecurity Officer | `characters/models/ctm_st6/` | lifepunchnet cyan |

**After first S2V browse:** update `cs2PrimaryModel` in `gear-production.json` with the exact `.vmdl_c` basename you exported.

---

## Target intake folder layout

```text
C:/lifepunch/reference-intake/cs2-characters/
  <role-ident>/
    MANIFEST.txt
    agent/              ← full agent glTF/GLB (proportion study)
    gear/               ← split helmet/vest/gloves if exported separately
    notes/
      blender-notes.md  ← scale, bone names, what to attach on citizen
  _props/
    riot_shield/
      MANIFEST.txt
      mesh/
```

---

## GUI harvest (one role)

1. S2V → Open `pak01_dir.vpk`.
2. Navigate `characters/models/<agent>/`.
3. Double-click the main agent `.vmdl_c`.
4. Preview **idle**, **walk**, **run** in animation dropdown.
5. Export glTF/GLB → `agent/`.
6. If helmet/vest are separate models in the tree, export those → `gear/`.
7. Record exact filenames in `notes/blender-notes.md`.

---

## From CS2 study → LifePunch ship (per job)

1. **CS2 glTF** → Blender: measure shoulder width, vest thickness, helmet scale vs citizen reference.
2. **Author own gear meshes** → helmet.fbx, vest.fbx (static or skinned to citizen bones).
3. **ModelDoc** → `.vmdl` + LifePunch materials (match terminal brand accent where relevant).
4. **DXRP:** attach as clothing / bodygroup / prop on **citizen** — confirm hook against `dxura/dxrp @develop`.
5. **Job loadout:** portal job definition + permissions (Opus sign-off).
6. **Terminal props** (Hacker CRT, Police kiosk) are **separate entities** — not the body mesh.

---

## Props queue

| ident | CS2 path | For roles |
|-------|----------|-----------|
| `riot_shield` | `weapons/models/weapon_shield/` | SWAT, Police |

Complex weapon-adjacent props — study after base uniforms.

---

## Legal / ship boundary

- CS2 agents are **Valve** — LifePunch ships **original** gear we model.
- Intake stays **outside git** (`reference-intake/`).
- Cornerman: manifests + `gear-production.json`; Red: S2V export + Blender + citizen attach.

---

## Related docs

- `GUN_TEST_AND_CS2_INTAKE_PLAN.md` — guns + characters roadmap
- `TERMINAL_BRAND_MATRIX.md` — job terminal colors
- `CS2_WEAPON_HARVEST.md` — weapon lane (parallel)
