# FINDING — the VIP/EVIP mined-BTC payout multiplier does not exist in the tree

**Class:** FINDING (write-once record) · **Date:** 2026-07-13 · **Author:** Red (Claude Code Opus)
**Task basis:** `comms\fable\0028_FABLE3_DONOR-LAW-AMENDMENT-RULING_2026-07-13.md`, authorized by
Bloodwave as a work order.
**Sensor basis:** read-only grep of the worktree at `develop` @ `ab98eebd4d95513597f67b7e0a75bef0162f44ed`,
plus a read-only scan of the untracked `lifepunchdxrp/` in the main checkout.
**Mandate:** *observation only — do not modify game code.* No game code was modified.

---

## 1. WHAT WAS ASKED

The ruling stated that VIP/EVIP grant a live **1.5× / 2×** payout-rate multiplier on mined-BTC
cashout — *"shipped reality,"* *"live and monetizing"* — and that the Donor Law's "zero power" line
therefore contradicts the code. It asked Red to determine **which mechanism** implements it:

- **(a)** the global `CashRateMultiplier` in `LpBitcoinEconomy.cs`, or
- **(b)** a separate per-player mechanism.

If **(a)**, that is a possible live economy bug (one VIP would boost the *entire server*) and gets
its own ruling. If **(b)**, the ruling's doctrine text is accurate as written.

## 2. THE FINDING — IT IS NEITHER (a) NOR (b)

**No VIP/EVIP payout-rate multiplier exists anywhere I can reach. Not global. Not per-player. It is
not implemented.**

### 2.1 `CashRateMultiplier` is a server-wide event knob with no rank awareness

```
lifepunchaddons/Code/Addons/lifepunch/bitcoinmining/LpBitcoinEconomy.cs:42
    public static float CashRateMultiplier { get; set; } = 1f;
    /// <summary>Live server/event multiplier on cash rate (1 = normal).</summary>

lifepunchaddons/Code/Addons/lifepunch/bitcoinmining/LpBitcoinEconomy.cs:45
    public static float CashUsdPerBtc => PortalBaseCashUsdPerBtc * MathF.Max( 0f, CashRateMultiplier );

lifepunchaddons/Code/Addons/lifepunch/bitcoinmining/LpBitcoinEconomy.cs:48-53
    public static void ApplyPortalBacking( int cashUsdPerBtc, float eventMultiplier = 1f )
        → CashRateMultiplier = MathF.Max( 0f, eventMultiplier );
```

Its **only** writer is `ApplyPortalBacking`, called exclusively from
`LpBitcoinPortalEconomySync.cs:196, 402, 442`, fed by the portal store key
`lifepunch:bitcoin:cash_rate_multiplier` (`LpBitcoinPortalEconomySync.cs:36`). **It is a portal-driven,
server-wide event multiplier.** There is **no rank check anywhere on this path** — no VIP, no EVIP, no
player scope of any kind.

### 2.2 No VIP/EVIP code touches any payout path

Every VIP/EVIP reference in addon C#:

| File:line | What it is |
|---|---|
| `visiblepocket/PocketSlotPolicy.cs:22-27, 49-55` | Inventory **slot counts** (VIP 8, EVIP 12). Not payout. |
| `adminmenu/StaffMenuHost.cs:299, 457, 599` | **Mock UI sample data** for the staff menu. |
| `_dev/StaffMenuTestBots.cs:39, 213-218` | **Dev test bots**, one per rank. |

**That is the complete set.** A repo-wide search for any line containing both a VIP/EVIP token and a
multiplier/payout-rate token returns **zero hits.**

### 2.3 The DXRP gamemode does not have it either

`lifepunchdxrp/` (untracked, `.gitignore:2`) — **975 `.cs` files scanned** for
`CashRateMultiplier` / `EVIP` / `cash_rate_multiplier`: **zero hits.**

### 2.4 The portal rank baselines grant no economic power

`lifepunch/players/ranks/vip-rank.json` and `evip-rank.json` (sourced from the DXRP portal itself):
both are `"category": "supporter"`, `"administrative": false`, `economy.manage` = **none**, and their
`granted` sets are exactly `command.rpname`, `command.title` (inherited), `command.minigame.*`, and
`ability.bypass.maxplayers`. **No multiplier field exists in either.** Both carry the note:
*"VIP must remain non-wildcard."*

### 2.5 The store advertises no such perk

`lifepunch/website/config/store-page.json` — VIP ($10/mo) and EVIP ($25/mo) are
`supporter-rank-subscription`. Observed perks: *Builder Status, Prop Limit +500, Queue Skip, Minigame
Starts, Exclusive Jobs.* **No bitcoin/payout/yield multiplier is offered.** The file's own
fulfillment note reads: *"Do not grant portal/moderation/server/economy/admin tools from donation
fulfillment."*

### 2.6 The donor-perks design doc forbids exactly this

`lifepunch/docs/BITCOINMINING_DONOR_PERKS.md` — **"Not shipped in code yet."**
> *"Pattern: rank grants **identity/QoL**, not earn multipliers."*
> *"**Never gate:** `BaseSpeed`, tick interval, `BitcoinValue`, CPU/core costs, or mining payout math
> behind donor rank."*
> *"**Do not gate in:** `MineBitcoin()`, `CreditMiningPayout()`, `PurchaseUpgradeHost()`, sell RPCs."*

---

## 3. WHY THE DONOR LAW AMENDMENT WAS HELD

The ruling's amended text asserts the multiplier is *"applied via the same global
`CashRateMultiplier` mechanism (`LpBitcoinEconomy.ApplyPortalBacking`)."* **Against the tree, that
sentence is false.** Landing it would write a mechanism into permanent canon that no code implements.

The ruling exists to fix doctrine that contradicts shipped reality. **My sensors say the opposite of
its premise: the doctrine is correct and the premise is unverified.** The existing Donor Law §9 —
*"donor ranks grant ONLY social/QoL … ZERO economy/combat advantage"* — is **corroborated** by the
portal rank JSONs, the store config, the addon code, and the donor-perks design doc. Its perk list
(*RP Name, Use Title, Minigame Participate/Manage, Bypass Max Players*) **matches `vip-rank.json`'s
granted permissions exactly.**

Amending a correct law to describe a mechanism that does not exist would be the very disease the
ruling was written to cure, inverted. **So the amendment is HELD and this finding is filed instead.**

## 4. WHAT I CANNOT SEE (honest bounds)

My sensors cover the **repo**, the **vendored DXRP fork**, and the **portal rank/store baselines
captured in-repo**. They do **not** cover:

- **The live DXRP portal's current store/rank configuration** — the `cash_rate_multiplier` store key
  is portal-driven, so a **server-wide** rate could be set there right now. That would still be
  **global, not per-rank** — it cannot produce a VIP-only 1.5×.
- **The live server's runtime state or any manual ops practice.**
- **Any fulfillment automation outside this repo** (e.g. a Stripe webhook granting something the
  rank baselines don't describe).

**If the 1.5×/2× is real and monetizing, it lives somewhere none of these sensors reach — and that
itself would be the finding worth ruling on.** The alternative is that it was **designed and sold in
intent but never implemented**, which is what every artifact in this repo indicates.

## 5. WHAT IS OWED (Bloodwave rules; Red does not decide)

1. **Does the VIP/EVIP payout multiplier exist anywhere off-repo?** (Portal? Live server? Nowhere?)
2. If **it does not exist**: is the Donor Law amendment **withdrawn** (doctrine already correct), or
   does it become a **forward-looking design ruling** that the multiplier *will* be built — in which
   case the doctrine must say so in the future tense, and `CashRateMultiplier`'s global shape is a
   **known blocker** for it (a per-player multiplier does not exist and would have to be built).
3. If **it does exist off-repo**: where, and does it route through anything global?

**No fix is proposed and none was made.** This record observes; it does not decide.

FROM: Red (Claude Code Opus)
