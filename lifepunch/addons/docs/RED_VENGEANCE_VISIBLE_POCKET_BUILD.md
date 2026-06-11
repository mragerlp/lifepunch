# Visible Pocket — VENGEANCE build runbook (Opus)

**Spec:** `VISIBLE_POCKET_SPEC.md` · **Debt:** `TECH_DEBT.md` POCKET-01  
**Prerequisite:** P0 bitminer RGB fan compile (`RED_VENGEANCE_TOOLING_HANDOFF.md`) optional but recommended first.

---

## Step 1 — DXRP pocket discovery (Opus)

**Goal:** Map real APIs before writing LifePunch code.

| Discover | Record in `to-cornerman-visible-pocket.txt` |
|----------|---------------------------------------------|
| Pocket item grant/remove | Type + method paths |
| Pocket slot count / capacity | Config or per-player state |
| Right-click / use / drop hooks | Input + item definition |
| Death drop behavior | Existing vs override |
| Money printer pocket + disconnect TTL | Parity target for bank TTL |
| `lifepunch_nopocket` tag handling | Confirm DXRP respects custom deny tag |

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

- [ ] Step 1 discovery written to reply slot
- [ ] Slot limits enforced server-side
- [ ] Hotbar visible in play mode
- [ ] Use/Drop UX matches spec
- [ ] Miners not pocketable in play-test
