# Visible Pocket — VENGEANCE build runbook (Opus)

**Spec:** `VISIBLE_POCKET_SPEC.md` · **Debt:** `TECH_DEBT.md` POCKET-01  
**Prerequisite:** P0 GPU rack RGB fan compile (`RED_VENGEANCE_TOOLING_HANDOFF.md`) optional but recommended first.

---

## Step 1 — DXRP pocket discovery (Opus) ✅

**Done** — folded into `VISIBLE_POCKET_SPEC.md` § DXRP integration; detail in `reference/DXRP_POCKET_DISCOVERY.md`; merged reply `to-cornerman-visible-pocket.txt`; distill `VISIBLE_POCKET_DXRP_SUMMARY.txt`.

| Discover | Result |
|----------|--------|
| Pocket grant/remove | `PocketSystem.PickupHost` / `DropHost`; `Pockets[steamId]` |
| Slot capacity | `Config.Current.Game.MaxPocketItems` (global 6) — **POCKET-01** per-player gate |
| Use/drop hooks | Stock: LIFO drop only; P2 LifePunch Use/Drop Razor |
| Death drop | `DropPocketsOnDeath` / `DropPocketsOnJobChange` |
| Printer disconnect TTL | `PrinterDestroyAfterDisconnectTime` = 3600s |
| `lifepunch_nopocket` | Not in core; deny via no `pocket_item` |

**Do not** fork a second item database. Adapter reads/writes DXRP pocket.

---

## Step 2 — P1 slot limits

- Enforce slot table from spec (6 default + cash tiers + VIP/EVIP floors).
- Server-authoritative capacity on join + on rank/balance change.
- Dev convars for testing tiers without grinding cash.

---

## Step 3 — P2 HUD

- Visible hotbar (Razor or DXRP-native if exposed).
- Right-click menu: **Use** (if usable) / **Drop** (always).
- Weed brick: drop-only path.

Study **Hit Shapes** / **SGE** for chrome only — ship LifePunch-owned UI.

---

## Step 4 — P3 Inventory Bank

- $1.5M unlock → 5 death-safe slots.
- Placeable **Inventory Bank** prop.
- Disconnect TTL aligned with money printer grace.

---

## Step 5 — Prefab tags (ongoing)

| Prefab | Tag |
|--------|-----|
| `bitcoin-miner` | `lifepunch_nopocket` ✅ |
| `advanced-bitcoin-miner` | `lifepunch_nopocket` ✅ |
| `bitcoin-terminal` | `lifepunch_nopocket` (when raidable rules apply) |
| Hacker terminals | `lifepunch_nopocket` at ship |

---

## Definition of done (P1)

- [x] Step 1 discovery written to reply slot + spec § DXRP integration
- [ ] Slot limits enforced server-side (per-player — POCKET-01; dev bridge only today)
- [ ] Hotbar visible in play mode
- [ ] Use/Drop UX matches spec
- [ ] Miners not pocketable in play-test
