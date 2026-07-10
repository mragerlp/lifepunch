# lpbitcoin — Phase C parking lot (2026-07-08)

Items explicitly parked out of the A+B publish-blocker fix commit. These are redesign,
not repair — they join the Phase C de-layering/token pass (grounded by DECISION-0010 r4).

## Wallet page — de-intimidation redesign
- Hero the hub balance at the top of the page.
- Demote exchange-rate / USD estimate / rack rows to muted secondary rows.
- "Terminal linked" becomes a status chip, not a full row.
- Collapse the three input boxes into ONE action row:
  - single amount input (accepts a number or "all")
  - live "≈ $X to bank" preview as the amount changes
  - one Cash Out button.

## Transfers page — de-intimidation redesign
- Receive: operator ID + copy button + one sentence. Cut the duplicate hub-wallet row.
- Send: numbered-steps phrasing with the copy-example button — not COMMAND/EXAMPLE doc blocks.
- Delete the 4-cell rate table → one muted rate line.
- Racks note becomes a hint line.

## CANON RULES — queued for the next docs commit (do NOT improvise the home;
## propose placement with that commit: LIFEPUNCH_MISSION principles vs a new
## ADDON_ARCHITECTURE section, alongside the queued UI standard)

**GIT-SURFACES RULE (extend the git-identity canon line, same docs commit):**
the no-AI-attribution rule covers ALL git surfaces — commit messages, PR titles,
PR descriptions, merge-commit messages. No generated-with footers anywhere.

**CANON RULE 1 — event-stream architecture:**
"Every LIFEPUNCH addon emits player events for its notable actions from v1
(the stat-ledger pattern). Progression/XP is a future consumer of the event
stream — never a retrofit into addon code."

**CANON RULE 2 — lane addendum:**
"For vanilla DXRP systems, LIFEPUNCH never hooks upstream code directly —
progression observes from the addon side (economy/entity/interaction seams),
or the hooks are contributed upstream as a generic vanilla event bus (a
dxrp-official-lane proposal: engine-level job/action events any community
could consume). The lane test governs: would the XP system survive a clean
vanilla pull? Observation and upstreamed vanilla hooks pass; injected hooks
fail."

**Design implication to carry:** the stat ledger namespaces events by source
(lifepunch addon events now; observed/upstream vanilla events later) — never
assume a single origin.

**BINDING ON THE UPGRADE ARC (2026-07-08 session):** the purchase flow ships
with its OnPurchase event hook feeding the stat ledger from its first commit —
lpbitcoin's first emitted event. Mining ticks, deposits, and intrusion
outcomes join the stream as those paths get touched in later passes.

## PLAYER PROFILE feature (roadmap)
- Sidebar avatar becomes circular (ULX roster idiom), clickable, opens a profile
  page. The avatar is the ONLY entry point and stays put as its own sidebar item.
- Phase 1 stats (existing data): copyable Steam ID, hub wallet, bank balance,
  setup inventory (hub/terminal/racks counts).
- Phase 2 stats (needs the stat ledger): total setup value (everything spent on
  hub + terminal + racks + every upgrade, hooked at purchase time — accrues from
  the first real purchase ever made), session + all-time BTC earned,
  black-market spend, attacks prevented.
- Cross-job XP/progression is the far-arc consumer of the whole event stream,
  per the canon rules above.

## UPSTREAM-RELATIONS (roadmap — dxrp-official lane when filed, NOT now)
- **Status: informally greenlit.** Dimmer pre-approved on Discord (2026-07-08):
  "hooks are generally okay as long as they're modular, not all clumped
  together."
- **Architecture specified by Dimmer's follow-up (Discord, 6:21 AM 2026-07-08):**
  "s&box has decentralized event system with interfaces, so base mechanisms
  could expose their own (per system)." The eventual contribution = per-mechanism
  event interfaces raised via the engine's NATIVE event system — NOT a new bus.
- **Quote BOTH messages in the future issue.**
- File a DXRP GitHub issue when the XP arc nears.
  - Motivation: communities build progression/achievements/analytics without
    forking core.
  - Shape: per-mechanism event interfaces via s&box's native decentralized
    event system, raised at each system's notable actions (per Dimmer's two
    messages above).
  - Non-goals: zero gameplay changes, pure emission.
  - Close with an offer to implement.
- Issue-first is Dimmer's preferred channel for merge-potential additions.
- Precondition for the cross-job XP arc's clean-lane path.
- **BINDING ON THE UPGRADE-ARC SLICE (2026-07-08):** the stat ledger consumes
  events via the same s&box event-interface pattern — the OnPurchase hook is
  raised and consumed idiomatically (native interface, not a custom dispatcher)
  so vanilla events plug into the identical listener later. One idiom, all
  sources.

## Rack detail (state as of the A+B batch)
- "Upgrade this rack" primary button below the info list deep-links to
  Upgrades pre-selected on the rack's slot (OpenUpgradesForRackSlot).
- The space below it is deliberately clean: the inline upgrade stepper joins
  when the stepper component exists.

## Previously parked (still open)
- preview-ConCmd crossed wires (Phase C housekeeping).
- Token/spacing/casing pass across the hub UI (DECISION-0010 packet is the ground truth;
  Terminal stays gray CRT + amber per 0010 / OPS_CRT_TERMINAL_THEMES).
- Phase D Terminal→HUB alignment needs a 0010 amendment decision first.
- Phase E rack power lights.
