# Cyber economy rails — DXRP money doctrine

**Status:** HARD LAW — every cyber lane (Bitcoin, Hacker, Banker, Government, …)  
**Parent:** `CYBER_REFERENCE_LAWS.md` (Law 11)  
**DXRP primitives:** `Player.WalletBalance` (on-hand) · `Player.BankBalance` (bank) · `ChargeHost` / `PayHost(amount, reason, inBank)`

> **BTC is always a bank cashout.** Hacker player attacks are always wallet cash. Advanced hacker and government police **task rewards** use bank cashout.

---

## Three rails (never mix without explicit design)

| Rail | What moves | DXRP path | Bitcoin lane | Hacker lane | Gov / advanced |
|------|------------|-----------|--------------|-------------|------------------|
| **Hub BTC** | Mined / deposited float BTC → USD | `PayHost(..., inBank: true)` | Hub Wallet tab cashout | — | — |
| **P2P hub BTC** | BTC between hubs by owner Steam ID | No USD until recipient cashes out | `send <steamid> <amount>` at terminal | — | — |
| **Portal $BTC stack** | Inventory consumable → USD | `PayHost(..., inBank: true)` | `LpBitcoinCashRedeemEntity` | — | — |
| **Wallet attacks** | Steal/spend on-hand cash | `WalletBalance` only | Upgrades debit wallet | Puzzle/scan steals | — |
| **Task / breach payout** | Job reward for completed hack task | `PayHost(..., inBank: true)` | — | Advanced `GovDbBypass` rewards | Police hacker task rewards |

---

## Rail 1 — Hub BTC (bank always)

1. Racks accrue BTC on linked racks.
2. Operator deposits at **bitcoin terminal** → `HubWalletBtc` on the hub.
3. Operator **cash out** on hub **Wallet** tab (or `RequestCashOutHub`) → USD credited to **bank**, not on-hand wallet.
4. Rate: `LpBitcoinEconomy.CashUsdPerBtc` (portal-backed hub rate).

**Code:** `LpBitcoinHubEntity.CashOutHubHost` → `LpBitcoinWallet.TryPayBank`

P2P transfers move **BTC only** between hub wallets (`SendHubWalletHost`). Recipient must cash out to bank themselves — no direct USD on send.

---

## Rail 2 — Portal inventory $BTC (bank always)

Separate from mined hub BTC:

- Portal item grant **`BTC Cash Redeem`** → spawns `btccashredeem.prefab`.
- One stack Use → `LpBitcoinCashRedeemEntity` → **bank** deposit at `PortalRedeemCashUsdPerStack` (default $5000 for testing).
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

**Code (Phase 2):** `HackerEconomySecurity.ProcessWalletTransferHost` — clamp to `target.WalletBalance`; credit hacker wallet; never `BankBalance`.

---

## Rail 4 — Advanced hacker + government police tasks (bank cashout)

**Exception to wallet-only:** completed **job tasks** and **gov DB breach rewards** pay to **bank**, not wallet.

| Actor | Trigger | Payout |
|-------|---------|--------|
| Advanced hacker | `GovDbBypass` puzzle / govdb infil success | Bank via `PayHost(..., inBank: true)` |
| Government police hacker | Authorized task/hack completion (future lane) | Bank via `PayHost(..., inBank: true)` |

This is **not** a player-wallet steal — it is a server-authoritative **task reward** after validated host session.

**Code (Phase 2 prep):** `HackerEconomySecurity.ProcessGovdbTaskPayoutHost` (skeleton name in prep docs).

---

## Implementation map

| Helper | Use |
|--------|-----|
| `LpBitcoinWallet.TryPayBank` | All BTC → USD cashouts (hub, portal redeem, legacy rack sell) |
| `LpBitcoinWallet.TryPayWallet` | Non-BTC wallet credits only (rare) |
| `LpBitcoinWallet.TryCharge` | Hub upgrades, hacker installs — debit wallet |
| `player.PayHost(amount, reason, inBank: true)` | Advanced/gov task rewards (Phase 2+) |

---

## Agent checklist (before economy code)

1. Is this **BTC**? → Must end in **bank** cashout (`TryPayBank`).
2. Is this a **hacker attack on a player**? → **Wallet only**; bank untouchable.
3. Is this an **advanced/gov task reward**? → **Bank** cashout; not a wallet steal.
4. Law 1 — document what Hacker / Banker / Government reuse from this file.

**Last updated:** 2026-06-22 (owner doctrine — hub bank cashout, P2P hub BTC, hacker wallet-only, advanced/gov bank tasks)
