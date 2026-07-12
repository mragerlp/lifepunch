# LIFEPUNCH Addon Architecture — canon rules

Status: CANON — ratified 2026-07-08 (queued from the lpbitcoin Phase C pass).
Owner of the *addon architecture law* layer. The mission doc owns the why
(`LIFEPUNCH_MISSION.md`); this page owns cross-addon structural rules that every
LIFEPUNCH addon must satisfy. Amend this page before shipping a violation.

## ADDON BUILD LADDER (ratified 2026-07-12, Bloodwave)
1. **lpbitcoin** — pathfinder; finish first. Solves on-ledger/off-ledger discipline, faucet audit, and the config-read path (BLOCK-0) that every later addon inherits.
2. **Chemist lane** — via the EXISTING Drug Dealer job as stepping-stone/test vehicle (layer + production steps + assets exist; cocaine = model swap on the same grow system). Fast on content/UI; its economy hookup is GATED behind lpbitcoin's ledger discipline — the drug lane is a net faucet that launders (costs on-ledger, revenue off-ledger wallet) and gets fixed as part of this pass. Chemist may later spin off as its own higher-risk-higher-reward job; Drug Dealer stays the lower-risk stepping stone.
3. **Tablet** — last. Its marquee locked-transaction exchange is CONFIRMED BLOCKED at the base engine (portal interaction verb renders a do-nothing prompt; addon cannot add one without a gamemode edit). Ships scoped to non-blocked functions (remote cash-out, upgrade purchase, attack alerts) or waits on an upstream path.

## Rule 1 — Event-stream architecture

> Every LIFEPUNCH addon emits player events for its notable actions from v1
> (the stat-ledger pattern). Progression/XP is a future consumer of the event
> stream — never a retrofit into addon code.

Events are raised via **s&box's native decentralized event system**
(interface-based, per mechanism) — one idiom for all sources, no custom
dispatcher, no central bus file. The stat ledger consumes events through the
same interface pattern, so later sources plug into the identical listener.

**Design implication (binding):** the stat ledger namespaces events by source
(LIFEPUNCH addon events now; observed/upstream vanilla events later) — never
assume a single origin.

**First tenant:** lpbitcoin's purchase flow ships with its `OnPurchase`
stat-ledger event hook from its first commit — lpbitcoin's first emitted event.
Mining ticks, deposits, and intrusion outcomes join the stream as those paths
get touched in later passes. Purchase-event canon: `UPGRADE_ARC_DESIGN.md`
(decision 8, commit-then-raise); economy home: `ECONOMY_DOCTRINE.md`
(House Pattern).

## Rule 2 — Vanilla-lane addendum

> For vanilla DXRP systems, LIFEPUNCH never hooks upstream code directly —
> progression observes from the addon side (economy/entity/interaction seams),
> or the hooks are contributed upstream as a generic vanilla event bus (a
> dxrp-official-lane proposal: engine-level job/action events any community
> could consume). The lane test governs: would the XP system survive a clean
> vanilla pull? Observation and upstreamed vanilla hooks pass; injected hooks
> fail.

## Upstream contribution path (record — dxrp-official lane when filed)

Informally greenlit by Dimmer on Discord, 2026-07-08 (quote BOTH messages in
the eventual GitHub issue):

1. "hooks are generally okay as long as they're modular, not all clumped
   together."
2. (6:21 AM) "s&box has decentralized event system with interfaces, so base
   mechanisms could expose their own (per system)."

The eventual contribution = per-mechanism event interfaces raised via the
engine's NATIVE event system — NOT a new bus. File the issue when the XP arc
nears: motivation (communities build progression/achievements/analytics without
forking core), shape (per Dimmer's two messages), non-goals (zero gameplay
changes, pure emission), close with an offer to implement. Issue-first is
Dimmer's preferred channel. This is the precondition for the cross-job XP
arc's clean-lane path. Lane bible: `DXRP_CONTRIBUTOR_LANE.md`.
