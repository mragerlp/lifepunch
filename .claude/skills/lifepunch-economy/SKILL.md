---
name: lifepunch-economy
description: "LIFEPUNCH value-flow law as a priority-ranked rule table. Use for wallets, cash-out, purchases, market items, payouts, ledgers, faucets, tier costs, balance mutations, $LP spend, or any does-this-create-or-leak-money question. Priority-ranked must-have checks, the two-restores rule, and machine-verified anti-pattern scars. Points at canon; does not restate it."
---

# LIFEPUNCH economy — value-flow intelligence

Rule table for the money rails. **Priority decides review order.** This skill **points at canon** — read
the cited file before building or ruling.

> **EVERY file:line HERE WAS MACHINE-VERIFIED AGAINST THE TREE ON 2026-07-14** (record: `comms\red\0034`).
> **A cite is a claim and it needs a sensor.** Cites drift — **re-grep before you trust one.** If you find
> a scar has been fixed, **move it to the exemplar column; never leave a seat hunting a bug that no longer
> exists.**

## When to apply

Any task that **holds, moves, prices, mints, or destroys value** — including UI that displays or triggers
spend. Skip pure cosmetics with the Cosmetic Firewall intact (no economy refs).

## ⚠ TWO TREES. KNOW WHICH ONE YOU ARE IN.

| Tree | Path | Ours? |
|---|---|---|
| **LIFEPUNCH addon** | `lifepunchaddons/Code/Addons/lifepunch/` | **YES** — edit under gate |
| **DXRP upstream fork** | `lifepunchdxrp/game/Code/` | **NO** — upstream. A "fix" here is an **upstream-touching decision** (`DXRP_CONTRIBUTOR_LANE.md`), not an addon edit. |

**Half the known money scars live UPSTREAM.** Marked **`[UPSTREAM]`**. Do not silently patch them.

---

## Rule table by priority

| P | Category | Impact | Must have | Anti-pattern |
|---|---|---|---|---|
| 1 | **Debit ordering / TOCTOU** | CRITICAL | **Debit BEFORE await.** No await between funds check and debit. If an await must follow the debit, restore **additively** on failure. | `check-then-await-then-debit`. **Both known scars are now FIXED — see Exemplars.** Record: `STOPGO_CASHOUT_TOCTOU_2026-07-09.md`. |
| 2 | **Price must debit** | CRITICAL | Every computed price path calls a debit (`ChargeHost` / wallet / bank) **before** the grant. | `price-computed-never-debited` — **3 live sites, ONE pattern.** |
| 3 | **Ledger terminus** | CRITICAL | Gauntlet always-safe terminus; bank-rail mutations write portal evidence; reason `"LIFEPUNCH <verb>"`. | `off-ledger-wallet-credit` — the wallet branch is memory + Audit **only**. |
| 4 | **Authority / oracle** | CRITICAL | Host-resolved identity via `Rpc.Caller` / `Rpc.CallerId`. Outcomes from **house** systems, never client DTOs. | `caller-supplied-settlement-outcome` (VoteBet, ruling E/F). **Never trust a client SteamId or a client price.** |
| 5 | **Persistence mint** | CRITICAL | Crash-gated restore; repeated-restore proof. | `snapshot-mints-money` — restore has **no crash gate**. `[UPSTREAM]` |
| 6 | **Quantity clamp** | HIGH | Upper clamp on spawn/admin grants; balance floor ≥ 0 after debit. | `no-upper-quantity-clamp` `[UPSTREAM]` |
| 7 | **Config parse safety** | HIGH | Reject malformed Store JSON **loudly**. Never let `default(T)` become a priced zero. | `silent-swallow-to-default` `[UPSTREAM]` |
| 8 | **Law A / Law B** | HIGH | Currency-of-the-act purchase test; *"does it exist after I die?"* persistence test. | Wrong currency for the act; persistent value with no Law B pass. (`ECONOMY_DOCTRINE.md`, `UPGRADE_ECONOMY_DOCTRINE.md`) |
| 9 | **$LP / Donor ceilings** | HIGH | $LP Currency Law combat ban. Donor Law = **narrow VIP/EVIP payout-rate exception only**. | $LP combat perk; silent expansion of donor economic power. (`DXRP_PLATFORM_DOCTRINE.md` §9b) |
| 10 | **Audit / idempotency** | MEDIUM | Structured `Audit` on the bank rail; idempotent request/operation IDs; **additive** restore on failure. | Missing audit on a mutation; **recomputed** restore; replay with no idempotency key. |

---

## THE RULE PEOPLE GET WRONG — there are TWO restores, and they are not interchangeable

| Restore | Shape | Valid ONLY when | Why |
|---|---|---|---|
| **Snapshot** | `hub.HubWalletBtc = walletBefore;` | the money segment has **NO await in it** | It clobbers anything that changed meanwhile — safe only if nothing *could* have. |
| **Additive** | `hub.HubWalletBtc += amount;` | the restore **straddles an await** | A concurrent deposit may have landed during the await. A snapshot restore would **erase it**. |

**Verified exemplars:**
- **Snapshot** (await-free segment): `LpBitcoinPurchaseFlow.cs:104-117` — the code says so itself,
  *"No awaits in here"* (`:104`); capture `:105`, restore `= walletBefore` at `:112`.
- **Additive** (straddles await): `LpBitcoinHubEntity.cs:1192` (`HubWalletBtc += amount;`) and
  `LpBitcoinRackEntity.cs:363` (`BitcoinAmount += soldBtc;`). **`LpBitcoinHubEntity.cs:1091-1093` spells
  out why:** a snapshot restore there would clobber a concurrent deposit.

> **If you take one line from this skill: A SNAPSHOT RESTORE ACROSS AN AWAIT *IS* THE BUG.**
> *(Caught 2026-07-14 — an L3 draft fused the two idioms and mislabeled the snapshot as "additive." Taken
> literally it would have re-created the exact TOCTOU the rails were repaired to close.)*

---

## Exemplars — the FIXED cash-out rails. Copy these shapes.

| Rail | Where | Shape |
|---|---|---|
| **`CashOutHubHost`** | `LpBitcoinHubEntity.cs:1163-1199` | `HubWalletBtc -= amount;` (`:1183`) **precedes** `await LpBitcoinWallet.TryPayBank(...)` (`:1187`); additive restore (`:1192`). |
| **`SellForCallerHost`** | `LpBitcoinRackEntity.cs:340-370` | `BitcoinAmount = 0f;` (`:357`) **precedes** the `await` (`:358`); additive restore (`:363`). Its comment names it *"the same debit-before-await fix as CashOutHubHost."* |

> **HISTORY, NOT A LIVE SCAR:** the old TOCTOU cite `LpBitcoinHubEntity.cs:1124-1139` is **DEAD.** That
> range is now **`DepositRackHost` — unrelated, correct, await-free code. DO NOT "FIX" IT.**

---

## Live anti-pattern scars (machine-verified 2026-07-14)

### `price-computed-never-debited` — ONE pattern, three sites. Sweep it as a family, not three patches.

| # | Site | What breaks |
|---|---|---|
| 1 | **`HackerServerRackEntity.cs:412-421`** *(ADDON — ours)* | Cost computed (`:412`), balance **checked** (`:417`), tier **granted** (`:420`) — **no debit call.** Free tier upgrades. **And `:413-414` `#if LIFEPUNCH_LOCAL` grants the tier with NO check at all.** |
| 2 | **`GameManager.cs:294`** `[UPSTREAM]` | `marketItem?.Cost ?? 0` → an unlisted item spawns at **$0**. |
| 3 | **`GameManager.cs:271-333`** `[UPSTREAM]` | `PurchaseEntityHost`: `basePrice` (`:294`) and `taxAmount` (`:295`) are **dead locals, never read again.** Entity spawns free at `:331`. |

### The rest

| Scar | Site | What breaks |
|---|---|---|
| `off-ledger-wallet-credit` | **`Player.Roleplay.cs:213`** `[UPSTREAM]` | `WalletBalance += amount;` — portal blind. The `Audit(...)` at `:216` is a **log line, not a ledger write.** |
| **`inBank`-omission** *(the sharp one)* | **`Atm.cs:71`** `[UPSTREAM]` | `await player.PayHost( amount, "ATM Deposit Fail" );` — **omits `inBank`, which defaults false** → wallet branch → **no ledger call.** The *refund* path launders. **`Atm.cs:67` is the LEDGERED path (`inBank: true`) and is CORRECT — do not "fix" it.** |
| `snapshot-mints-money` | **`SnapshotSystem.cs:30, 38-42`** `[UPSTREAM]` | Restore gated **only by `Time.Now > 5f`** — a wall-clock delay, **no crash predicate.** Worse: the restore sits **above** the `SnapshotEnabled` check (`:45`), so **it runs even when snapshots are disabled.** |
| `no-upper-quantity-clamp` | **`SpawnItemCommand.cs:27-47`** `[UPSTREAM]` | Lower bound only (`:35`). Its sibling `SpawnEntityCommand.cs:8,41` **has `MaxQuantity = 100`.** Unbounded admin mint. |
| `silent-swallow-to-default` | **`ServerApiClient.Store.cs:141-142`** `[UPSTREAM]` | `catch { return default; }` → broken Store JSON becomes a **silent $0 economy.** |

---

## Safe purchase shape

1. Resolve the caller from **`Rpc.CallerId`** — never a client-supplied SteamId.
2. Resolve the price **on the host** — never a client-submitted price.
3. Funds check → **debit** → ledger append. **No await inside the money segment.**
4. If an await is unavoidable after the debit: **additive restore** on failure. Never a partial grant.
5. Emit a structured `Audit` + the `"LIFEPUNCH <verb>"` reason string.
6. **Idempotent `operationId`** — a replay returns the prior result; it does **not** mint again.

## Donor multiplier — Seam C

- **Hook:** `LpBitcoinEconomy.BtcToCashPayout` — **`LpBitcoinEconomy.cs:80`**.
- **Quote math:** `LpBitcoinPayoutMath.CreateQuote` — **⚠ that class lives at `LpBitcoinDonorPayout.cs:141`,
  NOT in a file of its own name. There is no `LpBitcoinPayoutMath.cs`.**
- **Composition (ruled 2026-07-14, `copilot\0006`):** event × donor, **multiplicative, ONE floor at the
  end** (2× event + 2× EVIP = **4×**). The **caller's** rank multiplies, not the hub owner's.
  **Audit base AND multiplied** — see `BITCOINMINING_DONOR_PERKS.md`'s 2026-07-14 supersession.

## FLAGS

**`LpBitcoinHubEntity.PayoutTarget` DOES NOT EXIST.** Repo-wide grep: **zero hits in code** — every hit is
markdown. It is **planned and unbuilt** (`UPGRADE_ARC_DESIGN.md:68` queues it;
`RECON_WALLET_TRANSFERS_2026-07-09.md:199` places it **after** the `[Sync]` slice). **A previous version of
this very skill asserted it as present-tense fact.** Payout routing does not go through it today.
**Do not build against it — and do not let a document convince you a symbol exists. Grep first.**

**`marketItem?.Cost ?? 0` is an upstream INTENTIONAL contract** (unlisted = unpriced) per
`STOPGO_MARKET_LISTING_DISCIPLINE_2026-07-10.md`. **Not "fix DXRP"** — but a LIFEPUNCH entity shipping a
purchase path **must assert market listing at gate time, or it spawns free.**

## Canon

`ECONOMY_DOCTRINE.md` · `UPGRADE_ECONOMY_DOCTRINE.md` · `DXRP_PLATFORM_DOCTRINE.md` §7, §9b ·
`STOPGO_CASHOUT_TOCTOU_2026-07-09.md` · `STOPGO_MARKET_LISTING_DISCIPLINE_2026-07-10.md` ·
`BITCOINMINING_DONOR_PERKS.md` · `DXRP_CONTRIBUTOR_LANE.md`
