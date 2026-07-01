# Visible Pocket — play-test (P2)

**Addon:** `lifepunch.visiblepocket` · **Host:** VENGEANCE DXRP editor  
**Prereq:** `main` at `a5e4461+`, bitcoinmining synced, DXRP pocket enabled.

---

## 1. Sync addon to DXRP

```powershell
cd C:\Users\jared\Projects\LIFEPUNCH
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

## 3. Hotbar + tier pickup (host)

1. Host play on `game.scene`.
2. Bottom-center **LIFEPUNCH™ POCKET** hotbar should appear automatically.
3. `lp_pocket_policy` — confirm `policyMax` from wallet/rank.
4. Pick up `pocket_item` props with hands **attack2** until full — stops at **your** tier max (not global 6).
5. Drop with attack2 while not aiming at a pocketable prop (LIFO).
6. BitcoinMiningAddon / hacker terminals — **forbidden** (`lifepunch_nopocket`).

```text
lp_pocket_refresh    # re-sync HUD labels from host
```

---

## 4. RGB GPU rack (P0 parallel)

```text
lp_spawn_bitcoinmining_full_kit
hashd
```

START → rainbow fan LEDs ~8s → STOP off. See `BITCOINMINING_FINISH_RUNBOOK.md`.

---

## 5. Known gaps

| Gap | Notes |
|-----|--------|
| Use menu | Right-click Use/Drop per-item menu — P2b |
| Bank phase 3 | Inventory Bank prop + protected slots |
| DXRP API | `PocketSystem.VisiblePocket.Api.cs` partial on `PocketSystem` (requires `partial` in DXRP core) |

Discovery: `addons/docs/reference/DXRP_POCKET_DISCOVERY.md`.
