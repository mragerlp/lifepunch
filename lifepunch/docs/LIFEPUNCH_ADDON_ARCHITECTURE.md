# LIFEPUNCH Addon Architecture — canon rules

Status: CANON — ratified 2026-07-08 (queued from the lpbitcoin Phase C pass).
Owner of the *addon architecture law* layer. The mission doc owns the why
(`LIFEPUNCH_MISSION.md`); this page owns cross-addon structural rules that every
LIFEPUNCH addon must satisfy. Amend this page before shipping a violation.

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
