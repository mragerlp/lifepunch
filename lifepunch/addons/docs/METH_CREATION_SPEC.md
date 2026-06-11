# LIFEPUNCH — Meth creation (GMod-informed design)

**Addon:** `advanceddrugprocessing` · **Entity:** `meth_lab` · **Status:** Phase 1 scaffold (2026-06-11)  
**Study only (never ship):** GMod DarkRP addons — Enhanced Meth Lab, STDrugs, vanilla stove/jar guides.

---

## What GMod creators do (patterns to borrow)

| Pattern | Examples | LifePunch takeaway |
|---------|----------|-------------------|
| **Multi-entity kit** | Stove, pot, special pot, jar, gas tank | Phase 2 — start with **one `meth_lab`** rig that runs stages internally |
| **Ingredient entities** | Caustic soda, muriatic acid, iodine, water (spawn/buy) | Pocket/market items — hook DXRP Drug Dealer market in Phase 2 |
| **Timed stages** | 60–120s per step (config Lua) | `[Sync]` stage + progress; host tick |
| **Minigames** | Shake jar to 100%; vent pressure on heat | `Vent` stage = press **Use** within window or **fail** |
| **Fuel / heat** | Gas tank → stove fuel meter | `FuelLevel` drains while heating; refuel item TBD |
| **Failure** | Wrong mix → explosion / waste batch | `Failed` stage + smoke; optional Health damage |
| **Payout** | Meth bag → buyer NPC / drop-off | DXRP `drug_drop` / weed buyer pattern — Opus before economy live |

### Reference recipes (not shipped verbatim)

- **STDrugs:** Meth = caustic soda + hydrogen chloride + muriatic acid (lab UI).
- **Vanilla guide:** Jar (iodine + water + acid, shake) → pot (acid + sulfur) → special pot combine → sell to buyer.
- **Enhanced Meth Lab:** Pots + jars + chemicals on stove; shake jar; multi-heat passes; fuel system.

LifePunch uses a **simplified three-chemical recipe** in code (`MethCookingRecipe`) — names are fictional in-universe, not real-world instructions.

---

## LifePunch meth line (Phase 1)

### Flow

```text
Drug Dealer buys chemicals (Phase 2) ──► Meth Lab (placeable)
                                         │
    Idle ──► PrepMix ──► Heat ──► Vent* ──► Crystalize ──► Ready ──► Harvest (bags)
                              │      │
                              └── Fuel drains on Heat/Crystalize
    * Vent = player must press Use within 8s or batch fails
```

### Recipe (config in `MethCookingRecipe.cs`)

| Ingredient | Role |
|------------|------|
| Red Phosphorus | Powder reagent |
| Muriatic Acid | Acid reagent |
| Lithium Scrap | Metal reagent |

| Stage | Duration | Notes |
|-------|----------|-------|
| PrepMix | 20s | All three ingredients consumed at start |
| Heat | 45s | Fuel −2/tick; needs Fuel ≥ 10 |
| Vent | 8s window | `IPressable` — vent or fail |
| Crystalize | 40s | Fuel −1/tick |
| Ready | — | Press Use to harvest |
| Harvest | — | +N meth bags (wallet/item TBD) |

**Output:** `MethBagsPerBatch = 4` (tune on Opus economy review).

### Job gate

- **Drug Dealer** job only (match weed/coke rules) — enforce in `TryStartCook` on DXRP build.
- Police raid / NLR — existing server rules; no new code Phase 1.

### Assets (repo)

| Piece | Path |
|-------|------|
| Prefab | `entities/meth_lab/meth_lab.prefab` |
| Model | `models/lifepunch/advanceddrugprocessing/meth_lab/meth_lab.vmdl` |
| Code | `Code/Addons/lifepunch/advanceddrugprocessing/MethLabEntity.cs` |

Coke line (`processing_station`, `coca_*`) stays **parallel** — meth does not reuse weed grow pots.

---

## DXRP integration (Phase 2 — Red/Opus)

1. Portal **content row** for meth lab entity + meth bag product.
2. Market items for three chemicals (Drug Dealer whitelist).
3. Sell meth at existing **drug drop-off** or dedicated buyer NPC.
4. Wire pocket inventory checks instead of dev `lp_meth_fill`.

---

## Phase 2 — GMod parity (optional)

Separate placeables if owner wants full realism:

```text
meth_stove, meth_jar, meth_pot, meth_gas_tank  →  networked ingredient transfer
```

Track in `TECH_DEBT.md` — swap point is `MethLabEntity` stage machine vs multi-entity orchestrator.

---

## Playtest (VENGEANCE)

```text
lp_spawn_methlab
lp_meth_fill
lp_meth_status
```

Stand at lab → **Use** to start → wait stages → **Use** on Vent → **Use** to harvest.

See `Code/Addons/lifepunch/advanceddrugprocessing/docs/METH_BUILD.md`.

---

## Related

- `COKE_DRUG_RESKIN_SPEC.md` — coke/weed reskin lane
- `reference/WEED_ENGINE_ENTITY_INDEX.md` — DXRP weed engine index
- `bitcoinmining/docs/RUNTIME_PATTERN.md` — dual-build entity pattern
