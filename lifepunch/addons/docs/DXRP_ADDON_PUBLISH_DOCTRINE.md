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

- **Repo staging:** `lifepunch/addons/Assets/addons/lifepunch/lpbitcoin/{entity}/`
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

1. Entity **done** — flatgrass proof, owner sign-off (e.g. H10 for hub).
2. Promote assets + code into **`lpbitcoin/{entity}/`** in repo (folder name = slug).
3. Owner copies finished package(s) into **UPLOAD READY ADDONS PLACEHOLDER** (agents do not do this unless asked).
4. `prepare-publish.ps1 -Addon <repoIdent>` → `.dxrp-publish/upload/` with compiled `_c`.
5. Owner uploads to **dxrp.net/addons** and sets display names / content rows / market copy in the portal.

**Repo ident today:** `bitcoinmining` (code mount) · **Package slug:** `lifepunchbitcoin` · **Staging package folder:** `lpbitcoin`.

---

## Scripts (reference — do not run PLACEHOLDER init unprompted)

| Script | Role |
|--------|------|
| `Prepare-LpBitcoinModelDoc.ps1` | Repo `lpbitcoin/` → DXRP editor greenfield lane |
| `Sync-LifepunchDesktopToStaging.ps1` | Desktop → repo (owner-driven) |
| `Initialize-UploadReadyAddons.ps1` | Scaffold Desktop upload tree from repo — **owner-only unless explicit** |
| `prepare-publish.ps1` | Portal staging folder from repo ident |

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
