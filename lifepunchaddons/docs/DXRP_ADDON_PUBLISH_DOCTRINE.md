# LIFEPUNCH — DXRP addon publish & staging doctrine

**Status:** HARD LAW for agent onboarding (June 2026).  
**Read with:** `PACKAGE_STAGING_LAYOUT.md` · `config/package-staging.json` · `AGENT_PROMPT.md` Block 0.

---

## What DXRP is (context)

**DXRP** is a roleplay gamemode/platform built by **Dxura** for **s&box** (Facepunch). Community servers host DXRP and add **custom content** to differentiate from other hosts.

**LIFEPUNCH** is our brand and proprietary addon portfolio — we are **not** Dxura and do **not** claim ownership of DXRP. We ship **LIFEPUNCH-branded content for DXRP servers** so LifePunch can spotlight unique machines, jobs, and tools vs. every other DXRP community.

**Strategic goal:** LifePunch already has strong community footing and the largest addon roadmap in the space. Execution = working models, organized packages, flatgrass proof, then upload-ready drops — not perfect portal copy during dev.

---

## Two layers (do not conflate)

| Layer | Who owns it | What it is |
|-------|-------------|------------|
| **Stable — files & folders** | Agents + repo | `lp*` package tree, working meshes/prefabs/code, compiled `_c`, audit manifests |
| **Flexible — presentation** | Owner in **dxrp.net/addons portal** | Display names, market labels, content row titles, grouping, in-game wording |

**Law:** Portal presentation can change **after** upload without renaming folders or moving paths. Agents optimize for **working + organized** packages; Bloodwave tunes how things **appear** in the portal.

---

## Package parent path (locked 2026-06-30)

All addon packages:

```text
lifepunchaddons/lp{product}/     # e.g. lpbitcoin, lphacker, lpbanker
  Code/Addons/lifepunch/lp{product}/{entitySlug}/…
  Assets/addons/lifepunch/lp{product}/{entitySlug}/…
  docs/
  {product}.sbproj                 # Phase 6 per package
```

Canonical detail: **`PACKAGE_STAGING_LAYOUT.md`**. Legacy `repoIdent` folders are transitional until Phase 4 migration.

---

## Package & entity naming (final names)

**Folder name = entity slug = identity in the tree.** Not a staging alias for a different ship name.

```text
lpbitcoin/                          # parent package (portal packageSlug: lifepunchbitcoin)
  bitcoinhub/                       # entity slug: bitcoinhub
  hashdterminal/                    # entity slug: hashdterminal
  gpurack/                          # entity slug: gpurack
  advancedgpurack/                  # entity slug: advancedgpurack
```

Each entity folder uses the standard layout:

```text
{entity}/
  assets/source/fbx|blend|obj/
  assets/textures/
  assets/models/          # vmdl, vmat, MODEL_BUILD.md
  assets/entities/        # prefabs
  assets/sounds/
  assets/ui/
  code/components|ui|docs/
  audit/manifest.json
  docs/                   # optional
```

Same shape in:

- **Target (law):** `lifepunchaddons/lpbitcoin/{entity}/assets|code/…`
- **Transitional (today):** `lifepunchaddons/Assets/addons/lifepunch/lpbitcoin/{entity}/` + `Code/Addons/lifepunch/…`
- **Upload-ready Desktop (when owner fills it):**  
  `C:\Users\jared\OneDrive\Desktop\UPLOAD READY ADDONS PLACEHOLDER\addons\lifepunch\lpbitcoin\{entity}/`

---

## UPLOAD READY ADDONS PLACEHOLDER (agents — hands off)

```text
C:\Users\jared\OneDrive\Desktop\UPLOAD READY ADDONS PLACEHOLDER\addons\lifepunch\
```

**Purpose:** Owner staging area for **fully working, publish-ready** addon packages — ready to prepare for portal upload.

**Agent law:**

- **Do NOT** read, write, sync, scaffold, or run `Initialize-UploadReadyAddons.ps1` against PLACEHOLDER unless the owner **explicitly** asks in that session.
- **Do NOT** treat PLACEHOLDER as the active dev drop zone or "source of truth" during mesh/code work.
- **Do** work in the **repo** (`lpbitcoin/` staging + legacy `bitcoinmining/` playtest tree until promotion).
- **When** an entity is signed off (flatgrass proof, owner OK): owner (or explicit agent task) copies the finished package into PLACEHOLDER for upload prep.

**Sibling folder (other packages, same law when owner uses it):**

```text
C:\Users\jared\OneDrive\Desktop\UPLOAD READY ADDONS\addons\lifepunch\
```

---

## Dev vs upload-ready (bitcoin hub example)

| Stage | Where work lives | Notes |
|-------|------------------|-------|
| **Active dev / playtest** | `bitcoinmining/` repo ident (legacy paths, e.g. `bitcoin-miner.vmdl`, `LpBitcoinDevSpawn`) | OK during Phase A polish; portal display names can differ |
| **Publish-aligned staging** | `lpbitcoin/bitcoinhub/` | Folder name `bitcoinhub`; promote signed-off assets here |
| **Upload prep** | Desktop **PLACEHOLDER** | Owner fills when addon is **done** — not during iteration |

**Phase A hub mesh (June 2026):** **Steam Machine** (`steam-machine.fbx` → hub vmdl), static assembled chassis. **Not** the parked Sketchfab Generic PC (`bitcoin-hub.vmdl`) unless owner reopens that lane.

**Legacy names** (`bitcoin-miner`, `bitcoinmining`, old spawn ConCmds) are **interim dev wiring** — not the long-term slug law. Align prefabs/models to `bitcoinhub` inside `lpbitcoin/bitcoinhub/` at promotion time.

---

## Publish flow (when owner says ship)

**Compile truth:** the DXRP editor game tree — not the monorepo alone.

| Layer | DXRP editor path (ship source with `-FromDxrpGame`) |
|-------|-----------------------------------------------------|
| **Assets** | `D:\Steam\steamapps\common\sbox\dxrp\game\Assets\addons\lifepunch\lpbitcoin\` |
| **Code** | `D:\Steam\steamapps\common\sbox\dxrp\game\Code\Addons\lifepunch\bitcoinmining\` |
| **Hub code** | `...\Code\Addons\lifepunch\lpbitcoin\bitcoinhub\code\` (merged into portal Code bundle) |

**Repo** remains git source of truth for edits; **sync → compile in editor → publish from DXRP game** for Rev 3+ portal upload.

1. Entity **done** — flatgrass proof, owner sign-off (e.g. H10 for hub).
2. `Sync-LifePunchAddonsToDxrp.ps1 -Addon lpbitcoin` → editor game Assets + Code.
3. ModelDoc compile all four entities (`bitcoinhub`, `hashdterminal`, `gpurack`, `advancedgpurack` prefabs + vmdls).
4. Stop → Play — green compile on DXRP game Code.
5. **`Prepare-LpBitcoinPublish.ps1`** (or `prepare-publish.ps1 -Addon bitcoinmining -FromDxrpGame`) → `.dxrp-publish/upload/lifepunch/lpbitcoin/{Assets,Code}/`.
6. Owner uploads to **dxrp.net/addons** — portal picks **`lifepunch/lpbitcoin/Assets`** and **`lifepunch/lpbitcoin/Code`** (≤ 300 MB combined).

**Repo ident today:** `bitcoinmining` (code mount) · **Package slug:** `lifepunchbitcoin` · **Asset folder:** `lpbitcoin`.

---

## Scripts (reference — do not run PLACEHOLDER init unprompted)

| Script | Role |
|--------|------|
| `Prepare-LpBitcoinModelDoc.ps1` | Repo `lpbitcoin/` → DXRP editor greenfield lane |
| `Sync-LifepunchDesktopToStaging.ps1` | Desktop → repo (owner-driven) |
| `Initialize-UploadReadyAddons.ps1` | Scaffold Desktop upload tree from repo — **owner-only unless explicit** |
| `Prepare-LpBitcoinPublish.ps1` | **Bitcoin ship** — stage from DXRP game → `upload/lifepunch/lpbitcoin/{Assets,Code}/` |
| `prepare-publish.ps1` | Portal staging; use `-FromDxrpGame` for ship-tier Assets + Code from editor game |
| `Pull-DxrpCompiledAssetsToRepo.ps1` | Backport ModelDoc `*_c` from DXRP Assets → repo (before publish git backup) |

---

## Shared UI at `Code/Addons/lifepunch/` (no cross-lane bleed)

Files at the **lifepunch code root** (`LifePunchUiScale.cs`, `LifePunchScrollLayout.cs`, `LifePunchUiScrollPolicy.cs`, …) are **primitives only**. They compile into whichever addon folder DXRP mounts — each published package is its **own assembly**.

**Hard law:**

| Allowed in shared root | Forbidden in shared root |
|------------------------|---------------------------|
| Generic conventions (`lp-ui-scroll-region`, scale steps S/M/L/XL, wheel-only scroll policy) | CSS class names from another addon's Razor/SCSS (`racks-scroll`, `player-scroll`, …) |
| Addon-neutral helpers (stacked content height, scroll clamp math) | `if (panel.HasClass("…"))` chains listing multiple packages' UI |
| Short proprietary header (`lifepunch.*` / generic addon ident) | References to Bitcoin, ULX, or weapon lane behavior |

**Per-addon ownership:**

- **Markup** owns slot ids: `class="lp-ui-scroll-region audit-scroll"` lives in `StaffMenu.razor`, not in shared C#.
- **Publish bundle** copies shared primitives **into** the package folder (`lifepunchulx/`, future `lifepunchbitcoin/`, …). What ships on the portal must not contain another lane's class names or comments.
- **Editor monorepo** may mount several lanes at once for local playtest; that does **not** justify hardcoding Lane B's classes into shared files Lane A ships.

**Violation example (fixed r6):** `LifePunchUiScrollPolicy` listed Bitcoin hub scroll classes inside the lifepunchulx portal bundle — ULX never used those panels, but dedicated servers still compiled the strings.

**Bitcoin / hub scroll:** separate track (`TECH_DEBT.md` UI-03). Shared scroll primitives do not guarantee hub panels work; hub must own its markup + bootstrap + SCSS in the bitcoin lane.

---

## Agent checklist (new session)

1. Read `ACTIVE_WORKSTREAM.md` + this doc.
2. **Never touch PLACEHOLDER** without explicit owner ask.
3. Use **`lpbitcoin/{entity}/`** names as the ship identity (folder = slug).
4. Know portal names are **owner's job in dxrp.net** — not a dev blocker.
5. Bitcoin Phase A = **Steam Machine hub** working in dev tree; promote to `bitcoinhub` when signed off.

---

## Related

- `PACKAGE_STAGING_LAYOUT.md` — folder skeleton + scripts
- `CYBER_REFERENCE_LAWS.md` — flatgrass truth, one lane, Law 10 exit
- `LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md` — machines not props
- `lifepunch/docs/BUSINESS_CONTEXT.md` — LIFEPUNCH vs DXRP business framing
- `lifepunch-trademark-ip` rule — nominative DXRP use only
