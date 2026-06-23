# LIFEPUNCH — package staging layout (publish-aligned)

**June 2026** — Staging tree under `Assets/addons/lifepunch/{lpPackage}/{entitySlot}/`. Canonical manifest: `config/package-staging.json`.  
**Publish law (agents):** `DXRP_ADDON_PUBLISH_DOCTRINE.md` — folder name = entity slug; PLACEHOLDER hands-off.

---

## Pattern

```text
lpbitcoin/                          # package (maps to lifepunchbitcoin / repoIdent bitcoinmining)
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
  advancedgpurack/                    # slug: advancedgpurack
```

**Law:** `lpbitcoin` is the package folder. `{entity}` folder name **is** the ship entity slug. Never flatten to `lpbitcoinmining/bitcoinhub/game/`.

**Portal vs files:** Display names, market labels, and content row titles are set by the owner in **dxrp.net/addons** after upload — they do not require renaming folders or paths. See `DXRP_ADDON_PUBLISH_DOCTRINE.md`.

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
| Terminal / rack / economy | `Code/.../bitcoinmining/` | promotes per entity slot |

Hub entity code lives in **`Code/Addons/lifepunch/lpbitcoin/bitcoinhub/code/`**. Package-wide code (terminal, rack, wallet, shared UI SCSS) remains in **`bitcoinmining/`** until each entity promotes. Each slot’s `code/manifest.json` lists its files.

---

## Package folders (8)

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

- `DXRP_ADDON_PUBLISH_DOCTRINE.md` — DXRP context, PLACEHOLDER law, folder=slug, portal vs files
- `LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md` — entity stack P0–P4 after intake
- `LIFEPUNCH_WEAPON_IMPLEMENTATION_LAW.md` — weapon platform (`lpweapons`)
- `ASSET_CLASSIFICATION_LAW.md`
- `MODEL_FOUNDATION_PASS.md`
- `MODELDOC_STUDIO_LANE.md`
- `DXRP_MODELDOC_GREENFIELD_LANE.md`
