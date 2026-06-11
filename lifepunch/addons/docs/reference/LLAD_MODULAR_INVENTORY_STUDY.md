# llad Modular Inventory System — study & bridge notes

**Package:** `llad.modularinventorysystem`  
**Intake folder:** `reference/intake/llad-modularinventorysystem/`  
**Manifest:** `INTAKE_MANIFEST.txt`  
**Status:** Study only — no `addons/lifepunch/` ship tree yet

---

## DXRP conflict (read first)

LifePunch already runs on **DXRP’s pocket model**:

- `PocketTag` / `pocket_item` on placeables (e.g. bitcoinmining prefabs)
- Pocket carry rules in entity code (`GpuRackEntity`, etc.)
- **Drug Dealer** market rows + job gates for meth/coke economy (`METH-02`, `METH_CREATION_SPEC.md`)

**llad MIS is a parallel stack** — bag grid, hotbar, equipment, crafting, world chests. It does **not** plug into DXRP pockets automatically. Treating it as a pocket replacement would fork the economy.

### Reasonable uses (with Opus bridge design)

| Use | Mechanism | Consumer |
|-----|-----------|----------|
| **Stash / lab storage** | `StorageContainer` — chemicals, coke precursors off-person | `advanceddrugprocessing` |
| **Job loot crates** | World chests, one-off rewards | `hackerjob`, optional bitcoinmining |
| **Crafting bench UI** | Grid UI at meth/coke stations — inputs/outputs **sync to** Drug Dealer pocket rows | `advanceddrugprocessing` |

### Risky without Opus pass

| Anti-pattern | Why |
|--------------|-----|
| **Replace DXRP pocket entirely** | Breaks market, job gates, existing placeable rules |
| **Two inventories, no bridge** | Pocket + grid drift — duped items, desync, exploit surface |

**Bridge invariant:** DXRP pocket remains **source of truth** for carry + market; MIS (if used) is **station/storage/crafting UI** that reads/writes pocket via an explicit adapter — not a second silent inventory.

---

## Git-friendly intake

| Question | Answer |
|----------|--------|
| Commit vendored source? | Yes — ~20 text files, monorepo-friendly under `reference/intake/` |
| Cloud mount on published LIFEPUNCH addons? | Avoid — prefer vendored + owned bridge if license allows |
| `addons.json` now? | **No** — not LIFEPUNCH IP until license + bridge signed off |

---

## Fit with LifePunch tools

| Tool | Staff / UI | Inventory |
|------|------------|-----------|
| **Hit Shapes** | Radial moderation wheel | — |
| **SGE** | Header chrome | Optional item icon glow / rarity borders |
| **llad MIS** | — | Bag, chests, crafting for drug line / loot |
| **lifepunch.ulx** | Staff menu | Does not need MIS |

**Natural consumers:** `advanceddrugprocessing`, optional `hackerjob` loot, world loot experiments.  
**Not consumers:** `adminmenu`, `bitcoinmining` economy.

---

## Collision risk (must fix before ship)

Today the package exposes **global** type names (e.g. `InventoryItem`, `InventoryComponent`) — high collision risk with DXRP / other addons. Any ship path requires:

1. Re-namespace under `LifePunch.DXRP.Addons.Inventory` (or similar)
2. Proprietary headers on **LifePunch-owned bridge** files only
3. No claim of LIFEPUNCH ownership over llad's original source without license proof

---

## Opus decision queue (before `lifepunch.inventory`)

| # | Question | Options |
|---|----------|---------|
| 1 | **Role** | **Ancillary only** (stash / chest / bench UI) — not pocket replacement |
| 2 | **Bridge** | Adapter: grid/chest mutations ↔ DXRP pocket + Drug Dealer item ids |
| 3 | **First vertical** | Meth lab stash vs coke precursors vs hacker loot crate (pick one slice) |
| 4 | **Distribution** | Vendored in repo vs require server mount of `llad.*` |
| 5 | **License** | Redistribution / server use / modification — record in manifest |

**Rejected by default:** pocket-only MIS wrapper; parallel item DB with no Drug Dealer hook; dual inventory without sync.

**Definition of done (study phase):** package copied, `LICENSE.txt` filled, manifest updated, this doc amended with file inventory + API surface notes.

**Definition of done (ship phase):** bridge spec approved, renamed types, `addons.json` row only if IP posture is documented.

---

## VENGEANCE checklist

```text
[ ] Mount llad.modularinventorysystem in DXRP editor
[ ] Copy tree → reference/intake/llad-modularinventorysystem/
[ ] Paste LICENSE → LICENSE.txt
[ ] Update INTAKE_MANIFEST.txt
[ ] Skim Code/ for public API (items, UI, networking)
[ ] Opus bridge pass — ancillary storage/crafting only; pocket stays canonical
[ ] Only then: lifepunch/addons/Code/... bridge scaffold
```

---

## Related

- `reference/intake/llad-modularinventorysystem/README.md`
- `lifepunch-operating-context` — third-party study vs ship
- `advanceddrugprocessing` — primary consumer if MIS ships
