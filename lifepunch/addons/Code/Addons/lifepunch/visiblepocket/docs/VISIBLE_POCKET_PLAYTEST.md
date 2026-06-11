# Visible Pocket — play-test (P1)

**Addon:** `lifepunch.visiblepocket` · **Host:** VENGEANCE DXRP editor  
**Prereq:** `main` at `a5e4461+`, bitcoinmining synced, DXRP pocket enabled.

---

## 1. Sync addon to DXRP

```powershell
cd C:\Users\jared\Projects\lifepunchaddons
git pull --rebase
powershell -File lifepunch\scripts\Sync-LifePunchAddonsToDxrp.ps1
```

Mount `lifepunch.visiblepocket` on the LifePunch DXRP project (code-only — no assets).

---

## 2. Policy check (no host required)

In console:

```text
lp_pocket_policy
```

Expect log line: `rank`, `wallet`, `policyMax`, `dxrpGlobalMax` (6), `pocketCount`.

Alias: `lp_pocket_slots`.

---

## 3. Tier pickup test (host)

1. Host a local session.
2. `lp_pocket_apply_dev` — sets **global** `MaxPocketItems` to your policy max (dev bridge only).
3. Spawn or find props with DXRP `pocket_item` tag.
4. Hands **attack2** until pocket full — should stop at your tier, not stock 6 if you unlocked more.
5. Aim at bitminer rack — **forbidden** (no `pocket_item`; `lifepunch_nopocket` documented).

---

## 4. RGB bitminer (P0 parallel)

```text
lp_spawn_bitminer_full_kit
hashd
```

START → rainbow fan LEDs ~8s → STOP off. See `BITMINER_FINISH_RUNBOOK.md`.

---

## 5. Known gaps (POCKET-01)

| Gap | Notes |
|-----|--------|
| Global max | `lp_pocket_apply_dev` is **not** production per-player enforcement |
| Use/Drop UI | P2 Razor hotbar |
| Bank phase 3 | Not in this scaffold |

Discovery: `addons/docs/reference/DXRP_POCKET_DISCOVERY.md`.
