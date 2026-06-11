# llad.modularinventorysystem (STUDY ONLY — DO NOT SHIP AS LIFEPUNCH IP)

Third-party s&box package by **llad**. Git-friendly vendored text source (~20 files) for
architecture study and a possible **bridge** into LifePunch drug / loot flows — not a cloud
dependency on published LIFEPUNCH addons unless explicitly accepted.

## Status

| Stage | State |
|-------|--------|
| Intake scaffold | ✅ This folder + `INTAKE_MANIFEST.txt` |
| Package files copied | ⏳ Owner mounts in editor → paste tree here |
| License reviewed | ⏳ Paste `LICENSE.txt` + update manifest |
| Ship / bridge | ❌ Blocked until Opus sign-off |

**Do not** add to `addons.json` as LIFEPUNCH-owned until license + bridge design pass the ship bar in `INTAKE_MANIFEST.txt`.

## VENGEANCE copy steps (after mount)

1. Open **DXRP** editor (`lifepunch/scripts/Start-SboxDxrpEditor.ps1`).
2. Install / mount **Modular Inventory System** (`llad.modularinventorysystem`) from s&box.
3. In Asset Browser, note the on-disk folder (often under `game/addons/llad/modularinventorysystem/`).
4. Copy the **entire package tree** into this directory:
   ```text
   reference/intake/llad-modularinventorysystem/
     Code/
     Assets/
     LICENSE.txt          ← from package or s&box listing page
     INTAKE_MANIFEST.txt  ← update dates, paths, file count
   ```
5. Update `INTAKE_MANIFEST.txt` (`intake_date`, `copy_from_editor`, `license_*`).
6. Read `lifepunch/addons/docs/reference/LLAD_MODULAR_INVENTORY_STUDY.md` before any `addons/lifepunch/` work.

## Why study it

| LifePunch area | llad MIS fit |
|----------------|--------------|
| Coke / meth line (`advanceddrugprocessing`) | Bag, chests, crafting grids — natural consumer |
| Hacker job loot | Optional tool / loot containers |
| Staff menu (`adminmenu`) | **No** — radial moderation wheel does not need MIS |
| SGE header chrome | Optional item icon glow / rarity borders only |
| Bitcoin mining | **No** — server-authoritative BTC stays in `BitminerEntity` |

## DXRP conflict

DXRP **pocket + Drug Dealer market** is already canonical (`METH-02`, bitminer `pocket_item` tags).
llad MIS is a **full parallel inventory** — it does not drop into pockets automatically.

**OK (with bridge):** lab `StorageContainer`, hacker/bitminer loot chests, crafting bench UI for drug processing.  
**Not OK without Opus:** replace pocket; run pocket + grid with no sync.

See `lifepunch/addons/docs/reference/LLAD_MODULAR_INVENTORY_STUDY.md` § DXRP conflict.

## Ship path (if approved)

Prefer **vendored source + owned bridge** over requiring players to mount llad cloud-side.

| Step | Action |
|------|--------|
| 1 | Confirm license allows vendoring / server redistribution |
| 2 | Opus: **ancillary** adapter only — stash/chest/bench UI ↔ Drug Dealer pocket rows |
| 3 | New addon e.g. `lifepunch.inventory` — re-namespace globals (`InventoryItem`, `InventoryComponent`) |
| 4 | Proprietary headers on **LifePunch-authored bridge** code only |
| 5 | Pocket stays source of truth — no parallel item economy |

## Reference only until gates pass

Same bar as `reference/evo-bitminer/` and CS2 `reference-intake/`: study patterns, never
list third-party work as LIFEPUNCH Class 9 goods without ownership or a documented license chain.
