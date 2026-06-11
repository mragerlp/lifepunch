# DXRP pocket — discovery (Step 1 complete)

**For:** `lifepunch.visiblepocket` (POCKET-01) · **Source:** `dxrp/game/Code` on VENGEANCE install  
**Canonical summary:** `VISIBLE_POCKET_SPEC.md` § DXRP integration (this file = detail reference)  
**Handoff:** `lifepunch/docs/handoff/cornerman-outbox/to-cornerman-visible-pocket.txt` · distill: `VISIBLE_POCKET_DXRP_SUMMARY.txt`

---

## Core types

| Symbol | Path |
|--------|------|
| `PocketSystem` | `Code/System/Player/PocketSystem.cs` |
| `Config.Current.Game.MaxPocketItems` | `Code/Config/GameConfig.Systems.cs` (default **6**) |
| `Constants.PocketTag` / `PocketItemTag` | `Dxura.RP.Shared` (used by entities + `PocketSystem`) |
| HUD hint | `Code/UI/HUD/InputHelper.razor` — `LocalPocketCount` / `MaxPocketItems` |
| Hands input | `Code/Equipment/Equipments/Default/HandsEquipment.cs` — attack2 → `PickupHost` / `DropHost` |

---

## Pickup flow (`PocketSystem.PickupHost`)

1. Ray trace with `Constants.EntityTag`, reach `Config.Current.Game.ReachDistance`.
2. Root must have **`Constants.PocketItemTag`** — deny otherwise (`#notify.pocket.forbidden`).
3. Count in host dict `Pockets[steamId]` must be **&lt; `Config.Current.Game.MaxPocketItems`** (global, not per-player today).
4. Adds `Constants.PocketTag`, disables GameObject, stores in list.
5. Audit: `PocketPickup`.

**Gap for Visible Pocket:** `MaxPocketItems` is **one server-wide int**. Per-player 6→15 tiers need either:
- upstream DXRP `GetMaxPocketForPlayer(Player)`, or
- LifePunch host wrapper that duplicates pickup gate (avoid spaghetti), or
- interim dev: sync global max to local player's policy (test only).

---

## Drop flow (`PocketSystem.DropHost`)

- Drops **last** item in pocket list (LIFO).
- Audit: `PocketDrop`.

**Visible Pocket P2:** right-click Use/Drop menu is **new UX** — not in stock DXRP pocket UI.

---

## Death / job change

| Event | Config flag | Behavior |
|-------|-------------|----------|
| Death | `DropPocketsOnDeath` | `DropPocket()` — enables all items at spawn position |
| Job change | `DropPocketsOnJobChange` | Same |
| Disconnect | — | **Destroys** pocketed entities (`OnPlayerDisconnectHost`) |

**Bank phase 3:** disconnect TTL for bank ≠ pocket — pocket items are destroyed on disconnect today.

---

## `lifepunch_nopocket`

**Not in DXRP core today.** `PickupHost` only checks `PocketItemTag`.  
LifePunch policy: entities **without** `pocket_item` cannot be picked up. Bitminer racks use `lifepunch_nopocket` and **no** `pocket_item` — sufficient for P0.

Optional hardening: deny if `lifepunch_nopocket` tag present (addon PR to Dxura or host patch).

---

## Money printer disconnect TTL

**Found:** `PrinterEntity` (`Code/Entity/Entities/PrinterEntity.cs`) — when owner disconnects and `PrinterDecayEnabled`, starts `TimeSinceOwnerDisconnect`; destroys at `Config.Current.Game.PrinterDestroyAfterDisconnectTime` (**3600f** default, `GameConfig.Systems.cs`). Pocketed printers (`PocketTag`) skip decay. **Bank phase 3** should align to this constant, not pocket `OnPlayerDisconnectHost` destroy.

---

## Dev / staff commands

| Command | Purpose |
|---------|---------|
| `dx_pocket_list` | Staff noclip — lists all pockets |

---

## LifePunch test commands (addon)

| Command | Purpose |
|---------|---------|
| `lp_pocket_policy` | Print your tier max vs global `MaxPocketItems` + current count |
| `lp_pocket_apply_dev` | Host: set global max to **your** policy max (dev play-test only) |

See `Code/Addons/lifepunch/visiblepocket/docs/VISIBLE_POCKET_PLAYTEST.md`.
