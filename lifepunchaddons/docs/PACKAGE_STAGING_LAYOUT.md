# LIFEPUNCH — package staging layout (publish-aligned)

**June 2026** — Canonical manifest: `config/package-staging.json`.  
**Publish law (agents):** `DXRP_ADDON_PUBLISH_DOCTRINE.md` — folder name = entity slug; PLACEHOLDER hands-off.

---

## Package parent path (HARD LAW — locked 2026-06-30)

Every shippable addon package uses **one parent folder** under the addons workspace:

```text
lifepunchaddons/lp{product}/          # e.g. lpbitcoin, lphacker, lpbanker, lifepunchulx
├── Code/
│   └── Addons/lifepunch/lp{product}/
│       ├── _shared/                   # package-wide C# (when needed)
│       └── {entitySlug}/code/…        # per-entity components, ui, docs
├── Assets/
│   └── addons/lifepunch/lp{product}/
│       └── {entitySlug}/assets/…
├── docs/                              # package-level checklists, playtest notes
├── {product}.sbproj                   # Phase 6 — standalone s&box project per package
└── {product}.slnx                     # optional
```

| Rule | Detail |
|------|--------|
| **Parent path** | Always `lifepunchaddons/lp*/` (or `lifepunchulx/` for ULX) — **never** only `Code/.../repoIdent/` without the package parent |
| **Entity slots** | `{entitySlug}/` under Code + Assets — folder name = ship slug |
| **Shared code** | `Code/Addons/lifepunch/lp{product}/_shared/` — not a top-level `System/` unless we add a real game system type |
| **Registry** | `lifepunchaddons/config/` (`packages.json`, `portfolio.json`) — workspace-level; not duplicated per package |
| **Legacy `repoIdent`** | e.g. `bitcoinmining`, `hackerjob` — **transitional** until Phase 4 migration; do not create new work there |
| **Umbrella dev project** | `lifepunchaddons/addons.sbproj` — temporary until each package has its own `.sbproj` (Phase 6) |

**Today vs law:** Assets for most `lp*` packages already live under `Assets/.../lp*/`. Full package roots (`lifepunchaddons/lpbitcoin/` with Code + Assets + `.sbproj`) are **target** — see `RESTRUCTURE_TARGET_LAYOUT.md` and migration Phase 4–6.

**Examples:**

| packageFolder | packageSlug | s&box ident | Status |
|---------------|-------------|-------------|--------|
| `lpbitcoin` | `lifepunchbitcoin` | `lifepunch.bitcoin` | active — partial (legacy `bitcoinmining/` code) |
| `lphacker` | `lifepunchhacker` | `lifepunch.hacker` | quarantine — assets only; code in `hackerjob/` |
| `lpbanker` | `lifepunchbanker` | `lifepunch.banker` | quarantine — assets only; code in `bankerjob/` |
| `lifepunchulx` | `lifepunchulx` | `lifepunch.lifepunchulx` | publish-ready — still under monolithic `adminmenu/` until extract |

---

## Entity pattern (inside each package)

```text
lpbitcoin/                          # package (maps to lifepunchbitcoin)
  bitcoinhub/                         # entity slot — slug: bitcoinhub (same as folder name)
    assets/
      source/fbx|blend|obj/           # Fab exports (keep alternates)
      textures/                       # 2K game-ready maps
      models/                         # vmdl, vmat, material-map, MODEL_BUILD.md
      entities/                       # prefabs (after ModelDoc sign-off)
      sounds/                         # entity sounds (when wired)
      ui/                             # sui / icons (when wired)
    code/
      components/                     # entity C# (promoted from repoIdent folder)
      ui/                             # razor/scss for this entity
      docs/                           # entity notes
      manifest.json                   # maps legacy files until physical move
    audit/
      manifest.json
    docs/                             # optional slot notes
  hashdterminal/                      # slug: hashdterminal
  gpurack/                            # slug: gpurack
```

**Law:** `{entity}` folder name **is** the ship entity slug. Never flatten to `lpbitcoinmining/bitcoinhub/game/`.

**Portal vs files:** Display names, market labels, and content row titles are set by the owner in **dxrp.net/addons** after upload — they do not require renaming folders or paths. See `DXRP_ADDON_PUBLISH_DOCTRINE.md`.

---

## Transitional layout (until Phase 4–6)

Until each package is physically under `lifepunchaddons/lp*/`, dev paths may still be split:

| Layer | Transitional path (today) | Target path |
|-------|---------------------------|-------------|
| Code | `lifepunchaddons/Code/Addons/lifepunch/{lpPackage\|repoIdent}/` | `lifepunchaddons/lp{product}/Code/Addons/lifepunch/lp{product}/` |
| Assets | `lifepunchaddons/Assets/addons/lifepunch/lp{product}/` | `lifepunchaddons/lp{product}/Assets/addons/lifepunch/lp{product}/` |
| s&box project | `lifepunchaddons/addons.sbproj` | `lifepunchaddons/lp{product}/{product}.sbproj` |

New agent work: **author toward target paths** inside existing trees; bulk `git mv` is Phase 4+ with owner GO.

---

## UPLOAD READY ADDONS PLACEHOLDER (owner upload prep)

```text
C:\Users\jared\OneDrive\Desktop\UPLOAD READY ADDONS PLACEHOLDER\addons\lifepunch\
```

Finished, working addon packages land here when ready for portal upload prep. **Agents do not read/write/sync this path** unless the owner explicitly asks in session.

---

## Staging → ship (bitcoin example)

| Staging (slug = folder) | Dev playtest (legacy, until promotion) | Upload-ready target |
|---------|-------------------------------|---------------|
| `lpbitcoin/bitcoinhub/assets/models/` | `bitcoinmining/models/.../bitcoin-miner/` (Steam Machine) | `lpbitcoin/bitcoinhub/` → PLACEHOLDER when owner-ready |
| `lpbitcoin/bitcoinhub/code/components/` | `Code/.../lpbitcoin/bitcoinhub/code/components/` | promoted Jun 2026 |
| `lpbitcoin/bitcoinhub/code/ui/` | same | `LpHashdPanel.razor` |
| Terminal / rack / economy | `Code/.../bitcoinmining/` | → `lpbitcoin/_shared/` + entity slots (Phase 4a) |

Hub entity code lives in **`lpbitcoin/bitcoinhub/code/`** (target) or **`Code/Addons/lifepunch/lpbitcoin/bitcoinhub/code/`** (today). Package-wide code remains in **`bitcoinmining/`** until Phase 4a.

---

## Package folders (registered `lp*` staging)

| Folder | Was | ZIP |
|--------|-----|-----|
| `lpbitcoin` | `lpbitcoinmining` | `lpbitcoin.zip` |
| `lphacker` | `lphacker` | `lphacker.zip` |
| `lppolice` | `lppolicehacker` | `lppolice.zip` |
| `lpgovernment` | `lpgovernment` | `lpgovernment.zip` |
| `lpblackmarket` | `lpblackmarket` | `lpblackmarket.zip` |
| `lpbanker` | `lpbanker` | `lpbanker.zip` |
| `lpflashdrive` | `lpflashdrive` | `lpflashdrive.zip` |
| `lpchemist` | `lpchemist` | `lpchemist.zip` |
| `lpdrugdrops` | `lpdrugdrops` | `lpdrugdrops.zip` |
| `lpweapons` | `lpweapons` | `lpweapons.zip` |

ULX: target folder **`lifepunchulx/`** (packageSlug `lifepunchulx`; repoIdent `adminmenu` today).

---

## DXRP editor lane

Mounts **`lifepunchulx`** + all **`lp*`** staging packages + **`_dev/scenes`**. Does **not** mount legacy `bitcoinmining` assets/code until promotion.

```powershell
powershell -File lifepunch\scripts\Set-DxrpLifepunchModelDocLane.ps1
```

---

## Scripts

| Script | Role |
|--------|------|
| `Normalize-LifepunchDesktopPackages.ps1` | Desktop drop → `assets/` layout |
| `Sync-LifepunchDesktopToStaging.ps1` | Desktop → repo staging |
| `Initialize-UploadReadyAddons.ps1` | Scaffold Desktop upload tree from repo — **owner-only unless explicit ask** |
| `Invoke-LifepunchAssetClassificationAudit.ps1` | Inventory + health reports |

---

## Related

- `RESTRUCTURE_TARGET_LAYOUT.md` — end-state trees + Phase 4–6 migration
- `PACKAGE_NAMING_STANDARD.md` — packageSlug vs packageFolder vs repoIdent
- `DXRP_ADDON_PUBLISH_DOCTRINE.md` — DXRP context, PLACEHOLDER law, folder=slug, portal vs files
- `LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md` — entity stack P0–P4 after intake
- `LIFEPUNCH_WEAPON_IMPLEMENTATION_LAW.md` — weapon platform (`lpweapons`)
- `ASSET_CLASSIFICATION_LAW.md`
- `MODEL_FOUNDATION_PASS.md`
- `MODELDOC_STUDIO_LANE.md`
- `DXRP_MODELDOC_GREENFIELD_LANE.md`
