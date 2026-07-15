# PLAYER HUB = BTC STORE RULING — the hub absorbs the tablet's player-facing commerce

**RATIFIED 2026-07-15, Bloodwave** (chat-carried; verbatim intent: *"this player hub can be a store
for player bitcoin so there's no need for all these tablets"*). `dispatch\red\0002` Rider 6.
Companion to `DUAL_CURRENCY_IDENTITY_RULING_2026-07-15.md`, `TABLET_DOCTRINE.md`, and
`LIFEPUNCH_UI_STANDARD.md` (MENU SHELL LAW).

> **CLASS: RULED. Write-once.** Supersede with a new record citing this one by filename.

---

## 1. THE RULING

**The Player Hub absorbs the tablet's player-facing commerce functions — BTC store/exchange, upgrade
purchases, cash-out — as HUB TABS.** These are hub-shell surfaces (`LIFEPUNCH_UI_STANDARD` MENU SHELL
LAW), not a separate device.

**`TABLET_DOCTRINE.md` gets a supersession note:** the player-facing commerce functions **migrate to
the hub**; **tablets remain deferred and shrink further in scope** (what's left of the tablet after
the hub takes commerce is a later, narrower question).

## 2. THIS ROUTES AROUND THE CONFIRMED PORTAL BLOCK

**For the record:** the blocked **locked-transaction verb** was a **world-entity interaction** — a
platform limitation on that specific portal verb. **A hub-tab store is our own UI + server logic and
never needed that verb.** Moving commerce into the hub is not a workaround bolted onto a broken path;
it is a path that never touched the broken verb. The block stops being a blocker.

## 3. THE MECHANISM ALREADY EXISTS

**Slice 6's store-purchase atomicity design (`kepler\0002`, graded STRONG) is the mechanism spec for
this rail.** The hub store is what Slice 6 was **unknowingly designing for** — the atomicity/
idempotency guarantee a store-purchase needs is exactly the guarantee Slice 6 specced. The rail has
its mechanism; it was written before the surface it belongs to was named.

**Open composition question (flag, don't build past):** `$LP` Store tab vs `$BTC` store tab
composition is a **design question**. The `$LP` **identity** is now RULED
(`DUAL_CURRENCY_IDENTITY_RULING`: `$LP` portal-persistent, `$BTC` session-based), which unblocks the
Store-tab *shape* — but the **two-tab composition itself** is still design work. Flag it; do not build
past it.

## 4. WHY THIS WORKS (Bloodwave rationale, on the record)

In-game `$BTC` is currently **SESSION-BASED, not persistent** — the wallet is zeroed on death /
job-change / disconnect (Packet O). **But `$BTC` and `$LP` EXIST ON THE PORTAL as native Legendary
Currency items** (DXRP platform canon). So **the hub store can settle against portal-backed
currency**, and `$BTC`/`$LP` gain becomes **REAL and PERSISTENT across sessions.**

**The hub is the bridge** from session-volatile mining to portal-persistent wealth — **the Gauntlet's
final rail, player-facing.** Session grind → hub store → portal-backed persistence.

## 5. FUTURE-PERSISTENCE LANE — GATED

**The portal-settlement hookup is GATED behind lpbitcoin ledger discipline.** The guards land FIRST,
the rail SECOND:

- The **`GetStoreJson` swallow-wrap** (LKG cache + loud log on swallow-default + host assert) and the
  **off-ledger repairs** (`dispatch\codex\0002` LANE-BITCOIN spec) must land before any persistence
  settlement is wired.
- **Rationale:** a persistence rail built on a **swallowing API silently pays `$0`.** A hub cashout
  that settles against a swallowed-default store value is the exact failure the guards catch. **Guards
  first, then the rail** — never the reverse.

FROM: Red
