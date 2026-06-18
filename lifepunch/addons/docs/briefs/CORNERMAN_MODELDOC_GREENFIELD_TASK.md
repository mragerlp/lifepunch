# Cornerman — Full LifePunch addons ModelDoc prep (all lp* packages)

**Issued:** 2026-06-17 (overnight, expanded) · **Lane:** Green distill · **Warm:** `WarmDistill`  
**Red (VENGEANCE):** ModelDoc + bridge compile + git commits · **Owner:** Desktop is asset source of truth

---

## Canonical Desktop root (owner confirmed)

```text
C:\Users\jared\OneDrive\Desktop\UPLOAD READY ADDONS\addons
  lifepunch\
    lpbitcoin\      bitcoinhub | hashdterminal | gpurack | advancedgpurack
    lphacker\       hackerhub | hackerterminal | advancedhackerhub | advancedhackerterminal
    lppolice\       policehackerhub | policehackerterminal
    lpgovernment\   governmenthub | governmentterminal
    lpblackmarket\  blackmarkethub | blackmarketterminal | blackmarketregister | blackmarketlocker
    lpbanker\       bankerhub | bankerterminal | bankeratm
    lpflashdrive\   usbflashdrive | electronicstable | bitcoinusb | hackerusb
    lpweapons\      ak47military | ar15military | weaponlocker
    lpchemist\      druglab | drugtable | laboven | chemicalprocessor | chemicaljar | barrels | coca*
    lpdrugdrops\    meth* | cocaine* | traindrop | truckdrop
```

**Red pushed to your inbox (use these — you cannot read Red OneDrive live):**

| File | Contents |
|------|----------|
| `DESKTOP_ADDONS_INVENTORY_2026-06-17.json` | **42 entity slots** — FBX/tex/vmdl counts + status |
| `DESKTOP_ADDONS_INVENTORY_2026-06-17.md` | Same, markdown table |
| `REPO_ADDONS_SNAPSHOT_2026-06-17.json` | Repo Assets + Code tree file counts |
| `package-staging.json` | Entity manifest, repoIdent, publish mounts |
| `PACKAGE_STAGING_LAYOUT.md` | Folder law |
| `MODEL_FOUNDATION_PASS.md` | P0 gate |
| `LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md` | Machine vs prop doctrine |

**Snapshot summary (Desktop, Jun 17):** 24 × MODELDOC_PENDING · 5 × FBX_ONLY · 13 × AUDIT_OR_EMPTY · 1 × MODELDOC_DONE (bitcoinhub vmdl on Desktop — **since superseded:** hub = `bitcoin-hub.vmdl`, not cpu-gamer).

---

## Scope — entire portfolio, not weapons-only

Every `lp*` entity needs the same treatment:

1. Asset inventory (done — extend with notes)
2. FBX material slot extraction (where `.fbx` exists)
3. Draft `material-map.json` + vmat channel law (ORM `@channels=G/B`)
4. ModelDoc readiness bucket (A/B/C)
5. Gap vs repo staging + legacy ship tree (`bitcoinmining`, `hackerjob`, etc.)
6. **Future:** DXRP portal upload checklist per package (P2 — no publish tonight)

**Do not** polish legacy `bitcoinmining/models/` for mesh work — use staging `lp*` only. Legacy ship paths are **reference/gap** only.

---

## Universal material / texture law (all packages)

| Rule | Action |
|------|--------|
| ORM packed maps | `TextureRoughness "...ORM@channels=G"` · `TextureMetalness "...ORM@channels=B"` |
| `.jpeg` | s&box rejects — flag for `.jpg` duplicate |
| Multi-slot FBX | One `DefaultMaterialGroup` + remaps array (not separate top-level groups) |
| Scale | Document `import_scale` target vs citizen or class reference in MODEL_BUILD draft |
| Physics P0 | SingleHull max 16 verts on dense Fab meshes (weapons proved this) |

Reference vmat: `bitcoinmining/.../gpu-rack/materials/gpu-rack-psu.vmat` (split rough/metal) or miner body `@channels=G/B`.

---

## Work order (full night — do in sequence)

### 1 — Sync Green clone

```powershell
cd C:\Projects\lifepunch
git fetch origin
git reset --hard origin/main
```

### 2 — Start from inbox Desktop inventory (P0)

Open `DESKTOP_ADDONS_INVENTORY_2026-06-17.md` — **this is Desktop truth**.

Extend with a **Priority column** (P0 bitcoin hub/terminal/rack · P1 hacker/banker · P2 chemist/drugdrops · P0 weapons).

**Deliverable:** `outbox/DESKTOP_LP_PRIORITY_2026-06-17.md`

### 3 — Repo staging gap (all packages) (P0)

For **every row** in Desktop inventory, compare:

- Desktop: `...\UPLOAD READY ADDONS\addons\lifepunch\{pkg}\{entity}\`
- Repo: `lifepunch/addons/Assets/addons/lifepunch/{pkg}/{entity}/`

Flag: Desktop ahead · repo ahead · sync hazard · placeholder-only.

Cross-check `REPO_ADDONS_SNAPSHOT_2026-06-17.json`.

**Deliverable:** `outbox/REPO_STAGING_GAP_FULL_2026-06-17.md`

### 4 — Per-package entity dossiers (P0 — bulk of the night)

For **each** of the 10 packages, write one section in a master doc:

```text
outbox/PACKAGE_DOSSIERS_2026-06-17.md
```

Per entity include:

| Field | Source |
|-------|--------|
| Display name | `package-staging.json` |
| Desktop status | inventory JSON |
| FBX filenames | inventory / repo |
| Texture count + jpeg flags | inventory |
| Material slot names | python FBX string extract (see §5) |
| Proposed vmdl name | `{entity-slug}.vmdl` or package convention |
| Proposed vmats | list from slot names |
| Scale reference | citizen / terminal / M4 / none documented |
| Blockers | missing tex, rigged spin, etc. |
| Red tomorrow | one-line first action |

**Packages (all required):** lpbitcoin · lphacker · lppolice · lpgovernment · lpblackmarket · lpbanker · lpflashdrive · lpweapons · lpchemist · lpdrugdrops

### 5 — FBX material slot sweep (P0)

For every entity with `FbxCount > 0` on Desktop inventory, run string extract on repo clone FBX (or note Desktop-only if missing from repo):

```powershell
python -c "
import re, sys, json
p = sys.argv[1]
data = open(p,'rb').read()
hits = sorted(set(x.decode('ascii','ignore') for x in re.findall(rb'[\x20-\x7e]{3,}', data)
    if not x.startswith(('Animation','Layer','Mapping','Reference')) and
    (b'MI' in x or b'mat' in x.lower() or b'Material' in x or b'tex' in x.lower() or b'_' in x)))
print('\n'.join(hits[:40]))
" "PATH\TO\mesh.fbx"
```

**Deliverable:** `outbox/FBX_MATERIAL_SLOTS_2026-06-17.json` — keyed by entity path

### 6 — Draft material-map.json catalog (P0)

One JSON file keyed by `lifepunch/{pkg}/{entity}` — gpu-rack pattern.

Include `ormChannels`, proposed vmats, texture filenames, remap list.

**Deliverable:** `outbox/MATERIAL_MAP_DRAFTS_FULL_2026-06-17.json`

### 7 — ModelDoc readiness rollup (P0)

| Bucket | Meaning |
|--------|---------|
| **A — Red ModelDoc first session** | fbx + textures complete; vmdl/vmat missing |
| **B — Owner/asset gap** | audit-only or FBX-only |
| **C — Blocked / defer** | no Fab drop yet |

Sort **all 42 entities**. Top 10 ordered list for Red's first ModelDoc day.

**Deliverable:** `outbox/MODELDOC_READINESS_ROLLUP_FULL_2026-06-17.md`

### 8 — Legacy ship tree gap (P1)

Compare staging entities to legacy publish paths in `package-staging.json` → `publishAssetsMount` + `repoIdent`:

- What exists in legacy `bitcoinmining/`, `hackerjob/`, `ak47/` vs new `lp*`
- What code `code/manifest.json` maps (deleted manifests = promotion in progress)

**Deliverable:** `outbox/LEGACY_VS_STAGING_GAP_2026-06-17.md`

### 9 — Sync + workflow law (P0)

Document MIR hazard (Desktop placeholder wiped uncommitted vmdl on Red).

Morning order on VENGEANCE:

```powershell
powershell -File lifepunch\addons\scripts\Sync-LifepunchDesktopToStaging.ps1
# Red ModelDoc in repo → commit when owner asks
powershell -File lifepunch\scripts\Set-DxrpLifepunchModelDocLane.ps1
# bridge recompile
```

**Deliverable:** `outbox/SYNC_WORKFLOW_LAW_2026-06-17.md`

### 10 — DXRP upload barrier map (P2 — document only)

Per package from `package-staging.json`, draft future ship checklist:

```text
[ ] All entity vmdl/vmat compile to _c
[ ] prepare-publish.ps1 -Addon <repoIdent>
[ ] Upload Assets + Code from .dxrp-publish/upload
[ ] Portal content row + gamemode pin
```

Owner said **biggest future barrier is upload to DXRP** — capture per-package blockers (missing _c, dev spawn in tree, quarantined idents).

**Deliverable:** `outbox/DXRP_PUBLISH_READINESS_2026-06-17.md`

### 11 — Protection grep (P1)

```powershell
rg -l "reference/" lifepunch/addons/Assets/addons/lifepunch/lp* --glob "*.{vmdl,vmat,prefab}"
```

Append to rollup § Protection.

---

## Red queue tomorrow (uses your outbox)

| Priority | Package | First entities |
|----------|---------|----------------|
| P0 | lpbitcoin | bitcoinhub · hashdterminal · gpurack |
| P0 | lpweapons | ak47military · ar15military |
| P1 | lphacker | hackerterminal · hackerhub |
| P1 | lpbanker | bankeratm · bankerhub |
| P2 | lpblackmarket · lpgovernment · lppolice · lpflashdrive · lpchemist · lpdrugdrops | per rollup order |

---

## Ping Red (one line when done)

```text
OK cornerman full-addons @<sha> — 42 entities inventoried · dossiers 10pkg · material slots JSON · rollup A/B/C · DXRP publish map
```

All files → `C:\Projects\cornerman-rag\outbox\`

---

## Model routing

| Work | Model |
|------|-------|
| Inventory, dossiers, rollups, publish map | **distill** |
| material-map JSON bulk | **distill** |
| C# draft scripts | **coder** only if Red sends WarmCoder |

---

## Out of scope tonight

- ModelDoc / s&box / bridge
- Git commits on Green
- Actual portal upload
- Play test / flatgrass
