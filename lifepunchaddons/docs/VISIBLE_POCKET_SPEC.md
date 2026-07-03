# LIFEPUNCH Visible Pocket — canonical spec

**Addon:** `lifepunch.visiblepocket` · **Status:** P1 scaffold on `main` (`PocketSlotPolicy` + dev cmds) — Opus per-player gate pending  
**Not a shop.** Players carry goods in a **visible hotbar pocket** at their own risk.

---

## DXRP integration (Step 1 — folded)

LifePunch **does not** fork a second item database. Visible Pocket is policy + UX on DXRP `PocketSystem`.

| Surface | DXRP path | Visible Pocket role |
|---------|-----------|---------------------|
| Pickup / drop | `PocketSystem.PickupHost` / `DropHost` (`Code/System/Player/PocketSystem.cs`) | Intercept capacity + future Use/Drop UX |
| Storage | `Dictionary<long, List<GameObject>>` per SteamId | Read-only adapter; no parallel pocket list |
| Capacity | `Config.Current.Game.MaxPocketItems` (default **6**, **server-global**) | `PocketSlotPolicy.ResolveMaxSlots` — per-player target |
| Pickup allow | `Constants.PocketItemTag` on root | Raid deny: omit `pocket_item`; tag `lifepunch_nopocket` on miners/terminals |
| Pocketed state | `Constants.PocketTag`; GO disabled | Unchanged |
| HUD hint | `PocketSystem.LocalPocketCount` + `InputHelper.razor` | P2 replace/extend with visible hotbar |
| Input | `HandsEquipment` attack2 → world pickup/drop; **Reload + Hands** → pocket inventory UI | LifePunch `VisiblePocketInputBridge` |
| Death / job | `DropPocketsOnDeath` / `DropPocketsOnJobChange` | Align with spec (pocket drops; bank phase 3 exempt) |
| Disconnect | `OnPlayerDisconnectHost` **destroys** pocketed entities | Bank TTL must **not** reuse pocket destroy path |
| Staff | `dx_pocket_list` | Unchanged |

**Pickup gate (stock DXRP):** ray → `EntityTag` → root has `PocketItemTag` → count &lt; `MaxPocketItems` → add `PocketTag`, disable GO, audit `PocketPickup`. Drop is LIFO via `DropHost`.

**Money printer disconnect TTL (bank parity target):** `PrinterEntity` uses `Config.Current.Game.PrinterDestroyAfterDisconnectTime` (**3600s** default) when owner disconnects and `PrinterDecayEnabled` is on. Pocketed printers reset the timer (`PocketTag` clears disconnect decay). Inventory Bank phase 3 should align to this constant, not pocket disconnect destroy.

**P1 dev bridge (not production):** `lp_pocket_policy` / `lp_pocket_apply_dev` in `lifepunch.visiblepocket` — host sets **global** `MaxPocketItems` to local player's policy max for play-test only.

**Production swap (POCKET-01):** replace dev global sync with per-player capacity check at pickup — see `TECH_DEBT.md` POCKET-01. Detail reference: `reference/DXRP_POCKET_DISCOVERY.md`.

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

## Interaction (inventory UI — Reload + Hands)

| Action | When |
|--------|------|
| **Open pocket UI** | **Reload** while **Hands** equipped (toggle) |
| **World pickup/drop** | **attack2** while Hands equipped (mirrors stock `HandsEquipment` pocket path) |
| **Use** (P2) | Usable items from open pocket UI |
| **Drop** (P2) | Always available from open pocket UI |
| Weed brick | **Drop only** (no Use) |

---

## Death and raid

| Rule | Behavior |
|------|----------|
| **Death** | Pocket contents drop |
| **Raid — printers** | Money printers are pocketable |
| **Raid — bitcoin mining** | GPU racks + terminals **not** pocketable (`lifepunch_nopocket`) |
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

- `RED_VENGEANCE_VISIBLE_POCKET_BUILD.md` — Opus implementation steps (Step 1 ✅)
- `RED_VENGEANCE_TOOLING_HANDOFF.md` — lane order + RGB P0
- `TECH_DEBT.md` — **POCKET-01** swap point
- `reference/DXRP_POCKET_DISCOVERY.md` — full Step 1 notes (detail; spec § DXRP integration is canonical summary)

**Handoff reply (merged):** `lifepunch/docs/handoff/cornerman-outbox/to-cornerman-visible-pocket.txt`  
**Cornerman distill:** `lifepunch/docs/handoff/cornerman-outbox/VISIBLE_POCKET_DXRP_SUMMARY.txt`
