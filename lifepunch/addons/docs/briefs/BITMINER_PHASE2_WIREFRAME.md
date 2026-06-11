# BITMINER Phase 2 — HASHD module wireframe

**Lane:** Cornerman draft · **Red implements** in `BitminerTerminal.razor`  
**Palette:** Amber `#f0a500` on `#12100c` — **not** hacker green (`#00FF7F`)  
**Platform:** Reuse **Ops Console rail + module panes** from `HACKER_OPS_CONSOLE_SPEC.md`; keep Phase 1 telemetry rail semantics.

---

## Layout (960×640, bottom-left)

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│ ◆ HASHD RIG CONTROL  v2          mine.exe          [ IDLE | MINING ]  CLOSE │
├──────────────┬──────────────────────────────────────────────────────────────┤
│ LIVE TELEM   │  MODULE: DASHBOARD — RIG STATUS                              │
│ STATUS  IDLE │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐            │
│ BTC  0.00000 │  │ ₿ BALANCE   │ │ USD VALUE   │ │ HASH RATE   │            │
│ VALUE $0     │  │ 0.00000000  │ │ $0          │ │ 2.44 GHz    │            │
│ HASH 2.44GHz │  └─────────────┘ └─────────────┘ └─────────────┘            │
│ CORES 1      │  TICK ████████░░░░░░░░░░  42% / 60s                         │
│ TICK ████░░  │  ┌──────────────────┐ ┌──────────────────┐                   │
│              │  │    START MINING   │ │    STOP MINING    │  ← big actions  │
│ MODULES      │  └──────────────────┘ └──────────────────┘                   │
│ [DASHBOARD]* │                                                              │
│  WALLET      │                                                              │
│  UPGRADES    │                                                              │
│  LOG         │                                                              │
│  ABOUT       │                                                              │
│              │                                                              │
│ rig0> _      │  (command line always visible — bottom of main pane)         │
└──────────────┴──────────────────────────────────────────────────────────────┘
```

Phase 1 today: telemetry rail + LOG only + full-screen upgrade overlay. Phase 2 **replaces upgrade overlay** with **UPGRADES module** and adds **WALLET / ABOUT** modules; LOG keeps `rig0>` scrollback.

---

## Module map → existing RPCs (no new economy code)

| Module | UI control | Calls (client → host) | CLI equivalent |
|--------|------------|-------------------------|----------------|
| **Dashboard** | START | `Miner.SetMiningState(true)` | `mining start` |
| **Dashboard** | STOP | `Miner.SetMiningState(false)` | `mining stop` |
| **Dashboard** | Cards | Read `[Sync]` only | `status` |
| **Wallet** | SELL ALL (confirm) | `Miner.RequestSellBitcoin()` | `bitcoin sell` |
| **Wallet** | Balance display | Read `Miner.BitcoinAmount` × `BitcoinValue` | `bitcoin` |
| **Upgrades** | INSTALL CPU | `Miner.RequestUpgrade(BitminerUpgradeType.Cpu)` | `upgrade cpu` |
| **Upgrades** | INSTALL CORES | `Miner.RequestUpgrade(BitminerUpgradeType.Cores)` | `upgrade cores` |
| **Upgrades** | INSTALL RACK *(dual rack — Phase 2b)* | `Miner.RequestUpgrade(BitminerUpgradeType.Rack)` *TBD on Red* | `upgrade rack` |
| **Log** | Command input | `HandleCommand` (unchanged) | `rig0>` |
| **About** | Static copy | None | `about` |

Wallet cash for affordance: `BitminerTerminalHost.GetLocalWalletCash()` (already used in upgrade panel).

---

## Module wireframes

### Dashboard

```text
MODULE: DASHBOARD — RIG STATUS

[₿ BALANCE]     [USD VALUE]     [HASH / CORES]
 0.00000000 BTC    $0              2.44 GHz · 1 core

TICK  [████████░░░░░░░░░░]  42% / 60s

[ START MINING ]    [ STOP MINING ]     (mirror rail buttons; disabled if !Miner.IsValid())

Rate: 0.01220 BTC/min  (display: ClockSpeed × 0.005 × CoreCount)
```

Auto-refresh: same `_smoothProgress` + `[Sync]` polling as Phase 1 rail.

### Wallet

```text
MODULE: WALLET — PAYOUT

Stored balance
  0.00000000 BTC
  Estimated cash-out: $0

[ SELL ALL BTC ]

Modal (on SELL ALL):
  Title: CONFIRM CASH-OUT
  Body:  Sell all {balance} BTC for ${usd}? Balance resets to zero.
  [ CANCEL ]  [ CONFIRM SELL ]
  → Miner.RequestSellBitcoin()
  Disable CONFIRM if balance <= 0
```

### Upgrades

```text
MODULE: UPGRADES — HARDWARE

Wallet: $12,450

┌ CPU CLOCK ────────────────────────────────────────┐
│ Lv 2/7 — next $8,000                    [INSTALL] │
└───────────────────────────────────────────────────┘
┌ CPU CORES ────────────────────────────────────────┐
│ Lv 1/3 — next $100,000                  [INSTALL] │
└───────────────────────────────────────────────────┘
┌ RACK EXPANSION ───────────────────────────────────┐  ← dual rack Phase 2b
│ Locked — purchase to mount large gpu-rack         │
│ [INSTALL] disabled until RackExpansionLevel TBD   │
└───────────────────────────────────────────────────┘

INSTALL disabled when unaffordable / maxed (same rules as Phase 1 `OnBuyCpu` / `OnBuyCores`).
```

### Log

Phase 1 console pane unchanged: scrollback + `rig0>` prompt. Module nav **LOG** focuses input.

### About

```text
MODULE: ABOUT — LIFEPUNCH™

HASHD RIG CONTROL — LIFEPUNCH™ Bitcoin Miner
Published by LIFEPUNCH — lifepunch.co
Proprietary software. All rights reserved.

(LIFEPUNCH™ proprietary notice only — no third-party credits.)
```

**Red action:** verify `about` matches `BITMINER_PROTECTION_CHECKLIST.md`.

---

## `menu` / view mode (Red implementation note)

| State | Trigger | UI |
|-------|---------|-----|
| `_viewMode = Rig` (default) | Boot, `menu`, `upgrade` without arg | Module panes + rail; default module **Dashboard** after boot |
| `_viewMode = Log` | User selects LOG module or types CLI-heavy flow | LOG module full height; rail stays |
| `_showUpgradeMenu` | **Remove** in Phase 2 | Replaced by **UPGRADES** module (delete full-screen overlay) |

Boot sequence (2–4s, skippable): keep `>> hashd init` lines in LOG, then `SwitchModule(Dashboard)`.

`menu` command → `SwitchModule(Dashboard)` (not legacy upgrade overlay).

Mirror hacker pattern: `_activeModule` enum — `Dashboard | Wallet | Upgrades | Log | About`.

---

## Confirm modals (StaffMenu pattern)

| Action | Title | Confirm handler |
|--------|-------|-----------------|
| SELL ALL | CONFIRM CASH-OUT | `RequestSellBitcoin()` |
| INSTALL CPU | CONFIRM UPGRADE | `RequestUpgrade(Cpu)` |
| INSTALL CORES | CONFIRM UPGRADE | `RequestUpgrade(Cores)` |
| INSTALL RACK | CONFIRM RACK EXPANSION | `RequestUpgrade(Rack)` *when enum exists* |

Show cost + wallet balance in modal body. Fail closed — host already validates `ChargeHost`.

---

## Files Red touches

| File | Change |
|------|--------|
| `BitminerTerminal.razor` | Module enum, nav, panes, modals; remove `_showUpgradeMenu` overlay |
| `BitminerTerminal.razor.scss` | Import tokens from `BITMINER_PHASE2_TOKENS.scss` |
| `BITMINER_UX_SPEC.md` | §3b marked shipped when Red merges |

**Do not edit** `BitminerEntity.cs` for Phase 2 menu-only pass (rack enum = dual-rack lane).
