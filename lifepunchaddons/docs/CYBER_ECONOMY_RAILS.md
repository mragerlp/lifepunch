# Cyber economy rails — DXRP money doctrine

**Status:** HARD LAW — every cyber lane (Bitcoin, Hacker, Banker, Government, …)  
**Parent:** `CYBER_REFERENCE_LAWS.md` (Law 11)  
**DXRP primitives:** `Player.WalletBalance` (on-hand) · `Player.BankBalance` (bank) · `ChargeHost` / `PayHost(amount, reason, inBank)`

> **BTC is always a bank cashout.** Hacker player attacks are always wallet cash. Advanced hacker and government police **task rewards** use bank cashout.

---

## Four rail families (five money paths)

| Rail / path | What moves | DXRP path | Bitcoin lane | Hacker lane | Gov / advanced |
|-------------|------------|-----------|--------------|-------------|------------------|
| **Rail 1 — Hub BTC** | Mined / deposited float BTC → USD | `PayHost(..., inBank: true)` | Hub Wallet tab **cashout** | — | — |
| **Rail 1A — P2P hub BTC** | BTC between hubs by owner Steam ID | No USD until recipient cashes out | `send <steamid> <amount>` at HASHD Terminal | — | — |
| **Rail 2 — Portal BTC redeem** | Inventory consumable → USD | `PayHost(..., inBank: true)` | `LpBitcoinCashRedeemEntity` | — | — |
| **Rail 3 — Hacker wallet attacks** | Steal/spend on-hand cash | `WalletBalance` only | Upgrades debit wallet | Puzzle/scan steals | — |
| **Rail 4 — Task / breach payout** | Job reward for completed hack task | `PayHost(..., inBank: true)` | — | Advanced `GovDbBypass` rewards | Police hacker task rewards |

---

## Rail 1 — Hub BTC (bank always)

Canonical Bitcoin deposit/cashout flow:

1. GPU Racks accrue BTC in **rack-local buffers**.
2. Player initiates **deposit** from HASHD Terminal `deposit` or approved Hub rack UI (same Hub RPC).
3. Hub validates the deposit → `HubWalletBtc` increases.
4. Player **cashout** from Hub Wallet tab → USD credited to **DXRP `BankBalance`** (not on-hand wallet).
5. Rate: `LpBitcoinEconomy.CashUsdPerBtc` (portal-backed hub rate).

**Terminology:** `sell` is **legacy compatibility only** in code/comments. New player-facing copy uses **`deposit`** and **`cashout`**. Legacy rack sell paths must be labeled legacy in implementation maps.

**Code:** `LpBitcoinHubEntity.CashOutHubHost` → `LpBitcoinWallet.TryPayBank`

P2P transfers move **BTC only** between hub wallets (`SendHubWalletHost`). Recipient must cash out to bank themselves.

---

## Rail 2 — Portal inventory $BTC (bank always)

Separate from mined hub BTC:

- Portal item grant **`BTC Cash Redeem`** → spawns `btccashredeem.prefab`.
- One stack Use → `LpBitcoinCashRedeemEntity` → **bank** deposit at `PortalRedeemCashUsdPerStack`.
- Rate is **independent** of hub `cashUsdPerBtc`.

---

## Rail 3 — Hacker wallet-only attacks

**Hard rule:** `HackerJob.BankUntouchable = true`

| Action | Money touched |
|--------|----------------|
| Player scan + puzzle steal | Target **wallet** only |
| Failed hack counterplay | No bank drain |
| Rack INSTALL upgrades | Installer **wallet** debit |

Bank savings are **never** at risk from standard hacker puzzles or attacks.

---

## Rail 4 — Advanced hacker + government police tasks (bank cashout)

Completed **job tasks** and **gov DB breach rewards** pay to **bank**, not wallet.

| Actor | Trigger | Payout |
|-------|---------|--------|
| Advanced hacker | `GovDbBypass` puzzle / govdb infil success | Bank via `PayHost(..., inBank: true)` |
| Government police hacker | Authorized task/hack completion (future lane) | Bank via `PayHost(..., inBank: true)` |

---

## Implementation map

| Helper | Use |
|--------|-----|
| `LpBitcoinWallet.TryPayBank` | All BTC → USD cashouts (hub cashout, portal redeem, **legacy rack sell**) |
| `LpBitcoinWallet.TryPayWallet` | Non-BTC wallet credits only (rare) |
| `LpBitcoinWallet.TryCharge` | Hub upgrades, hacker installs — debit wallet |
| `player.PayHost(amount, reason, inBank: true)` | Advanced/gov task rewards (Phase 2+) |

---

## Agent checklist (before economy code)

1. Is this **BTC**? → Must end in **bank** cashout (`TryPayBank`).
2. Is this a **hacker attack on a player**? → **Wallet only**; bank untouchable.
3. Is this an **advanced/gov task reward**? → **Bank** cashout; not a wallet steal.
4. Law 1 — document what Hacker / Banker / Government reuse from this file.

**Last updated:** 2026-06-25 (rail naming + HASHD Terminal deposit/cashout flow)
