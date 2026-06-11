# LIFEPUNCH Visible Pocket — canonical spec

**Addon (planned):** `lifepunch.visiblepocket` · **Status:** P1 design locked — implementation on VENGEANCE  
**Not a shop.** Players carry goods in a **visible hotbar pocket** at their own risk.

---

## Slots

| Tier | Slots | Unlock |
|------|-------|--------|
| Default | 6 | — |
| Tier 1 | 8 | $100,000 |
| Tier 2 | 10 | $250,000 |
| Tier 3 | 12 | $500,000 |
| Tier 4 | 15 | $1,000,000 |
| **VIP** | 8 | Rank floor (instant) |
| **EVIP** | 12 | Rank floor (instant) |

Rank floors apply immediately when granted; cash unlocks stack with rank minimum (take the higher slot count).

---

## Interaction (right-click)

| Action | When |
|--------|------|
| **Use** | Usable items (guns, consumables, etc.) |
| **Drop** | Always available |
| Weed brick | **Drop only** (no Use) |

---

## Death and raid

| Rule | Behavior |
|------|----------|
| **Death** | Pocket contents drop |
| **Raid — printers** | Money printers are pocketable |
| **Raid — bitminer** | GPU racks + terminals **not** pocketable (`lifepunch_nopocket`) |
| **Raid — hacker** | Hacker terminals **not** pocketable (`lifepunch_nopocket` when prefab ships) |

DXRP pocket remains the underlying carry model; Visible Pocket is the **owned UX + rules layer** on top.

---

## Inventory Bank (phase 3)

| Field | Value |
|-------|--------|
| Unlock cost | $1,500,000 |
| Protected slots | 5 (survive death) |
| World prop | Inventory Bank placeable |
| Disconnect TTL | Same grace window as money printer rules |

---

## Third-party inventory

| Package | Posture |
|---------|---------|
| **llad MIS** | Study only (`reference/intake/llad-modularinventorysystem/`) |
| **Ship** | LifePunch-owned `visiblepocket` addon — no parallel grid economy |

See `reference/LLAD_MODULAR_INVENTORY_STUDY.md` § DXRP conflict.

---

## Build runbooks

- `RED_VENGEANCE_VISIBLE_POCKET_BUILD.md` — Opus implementation steps
- `RED_VENGEANCE_TOOLING_HANDOFF.md` — lane order + RGB P0
- `TECH_DEBT.md` — **POCKET-01**

**VENGEANCE reply slot:** `lifepunch/docs/handoff/cornerman-outbox/to-cornerman-visible-pocket.txt` (DXRP hook paths after Step 1 discovery).
