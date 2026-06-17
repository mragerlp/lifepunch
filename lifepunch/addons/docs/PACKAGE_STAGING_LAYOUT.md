# LIFEPUNCH — package staging layout (publish-aligned)

**June 2026** — Staging tree under `Assets/addons/lifepunch/{lpPackage}/{entitySlot}/`. Canonical manifest: `config/package-staging.json`.

---

## Pattern

```text
lpbitcoin/                          # package (maps to lifepunchbitcoin / repoIdent bitcoinmining)
  bitcoinhub/                         # entity slot
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
  hashdterminal/
    assets/ ...
    code/ ...
```

**Law:** `lpbitcoin` is the package folder. `bitcoinhub` is the entity folder. Never flatten to `lpbitcoinmining/bitcoinhub/game/`.

---

## Staging → ship (bitcoin example)

| Staging | Today’s ship path (repoIdent) | Future target |
|---------|-------------------------------|---------------|
| `lpbitcoin/bitcoinhub/assets/models/cpu-gamer.vmdl` | `bitcoinmining/models/.../bitcoin-miner/` | `bitcoin/bitcoinhub/assets/models/` |
| `lpbitcoin/bitcoinhub/code/components/LpBitcoinHubEntity.cs` | `Code/.../bitcoinmining/` | `Code/.../bitcoin/bitcoinhub/` |
| `lpbitcoin/bitcoinhub/assets/entities/*.prefab` | `bitcoinmining/entities/bitcoinminer/` | same pattern under `bitcoin/bitcoinhub/` |

Entity code still lives in **`Code/Addons/lifepunch/bitcoinmining/`** until owner promotes a physical split. Each entity’s `code/manifest.json` lists the files that belong there.

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
| `Initialize-UploadReadyAddons.ps1` | Desktop **UPLOAD READY ADDONS** → skeleton + ModelDoc files |
| `Invoke-LifepunchAssetClassificationAudit.ps1` | Inventory + health reports |

---

## Related

- `LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md` — entity stack P0–P4 after intake
- `LIFEPUNCH_WEAPON_IMPLEMENTATION_LAW.md` — weapon platform (`lpweapons`)
- `ASSET_CLASSIFICATION_LAW.md`
- `MODEL_FOUNDATION_PASS.md`
- `MODELDOC_STUDIO_LANE.md`
- `DXRP_MODELDOC_GREENFIELD_LANE.md`
