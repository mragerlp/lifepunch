# Packet E — Chemist-lane grounding (drug-economy implementation map)

**Node:** Green (Cornerman) · READ + DISTILL only · unattended · 2026-07-09
**Mandate:** GROUNDING PASS for the Chemist lane design session. Read vanilla
DXRP drug/economy code; report how it actually works. **Nobody builds.**
Findings feed the Chemist design pass when its lane opens.
**Measure:** ≤120k. **Transport:** git-pin payload + `.sha256` sidecar to the
shared inbox; Bloodwave fires the trigger on Green (never SSH).

## FORBIDDEN-SCOPE SCRUB (read before starting)

- **READ-ONLY.** Do not edit, build, compile, or run anything. This packet
  produces a findings document, nothing else.
- **VANILLA DXRP ONLY.** All source paths below are under
  `dxrp/game/Code/…` (the parent game). Do NOT read, quote, or exfiltrate
  `Code/Addons/lifepunch/**` — LIFEPUNCH proprietary code is out of scope for
  this grounding and must not appear in the findings.
- **No secrets.** No tokens, keys, LAN IPs, or real paths in the outbox report
  (branding-sweep discipline applies to all outbox docs).
- Confirm receipt in the outbox header (packet id + git pin SHA you read from).

## The questions

### E1 — Weed pipeline, end-to-end

Source anchors (all `dxrp/game/Code/`):
`Entity/Entities/PlanterEntity.cs` · `Entity/Entities/Drug/DryRackEntity.cs` ·
`Entity/Entities/Drug/RollingTableEntity.cs` ·
`Entity/Entities/Drug/WeedHarvestEntity.cs` ·
`Entity/Entities/Resources/PlantResource.cs` ·
`UI/Gameplay/Entities/RollingTable/WeedPluckingGame.razor` ·
`UI/HUD/ContextualOverlay/ContextTypes/PlanterContextPanel.razor`

Report: the full stage graph (Planter → DryRack → RollingTable → WeedHarvest —
confirm the real order and any I missed). For each stage: the **state machine**
(states + transitions), the **timers** (grow/dry/cure durations, where
configured), what **player action** advances it (the plucking minigame, USE,
wiremod), and the **wiremod / MetaWire hooks** exposed (inputs/outputs). Name
the field that holds yield/quality and how it carries stage to stage.

### E2 — DrugDrop internals

Source: `World/DrugDrop.cs` (+ `Chat/Commands/DropCommand.cs`,
`DropMoneyCommand.cs` for the drop family if relevant).

Report: the **price-fluctuation MECHANISM** (D established the band + cycle;
E needs the implementation — the formula, the tick/interval, the RNG source,
the clamp). The **sell flow** (what the player does at a drop, how payout is
computed and paid). **Cooldowns** (per-drop, per-player, global). And the
**config-vs-hardcoded split** — which numbers live in a GameConfig/`Governance`
partial vs baked into the entity.

**Anchor (Red pre-read):** the per-drop price label Dimmer's clip shows
(~$300–320/drop) is the EXISTING `DrugDrop.PaymentPerDrop`, randomized between
`Config.Current.Game.DrugDropMinPrice`/`DrugDropMaxPrice` at spawn, surfaced
via `DisplayText` → `drugdrop.context.per_drop`. Confirm that read and report
whether the price is fixed-at-spawn or re-rolls over the drop's life.

### E2b — PALLETS (upstream, GATED on the pull)

Dimmer shipped **pallets** to DXRP — multiple bricks stack per pallet.
**This code is NOT in the pinned tree** (our local head `0ee91dd` predates it).
**IF a pallet entity exists in your tree, read it and report:** is it a
**generic brick container** (any drug brick stacks) or weed-specific? capacity,
per-pallet vs per-brick pricing, and how it feeds the drop payout. **IF it is
NOT present at your pin, say so in one line and skip** — do not hunt a
non-existent entity. This target answers E3's inherit-vs-fork question early:
generic containers mean coke/meth bricks stack free.

### E3 — Coke/meth extension map

Report the **inherit-vs-fork** decision surface: does `DrugDrop` (and the
pipeline entities) subclass cleanly, or would coke/meth need a fork? Enumerate
what a **WINDOW-GATED drop** needs that vanilla `DrugDrop` LACKS (timed open
windows, scheduled spawn, a moving vehicle host). NOTE for context (do not
build): traindrop/truckdrop MODELS are staged in Bloodwave's warehouse (Fable
manifesting) — the question is purely what code seam a window-gated variant
plugs into. **If E2b finds a generic pallet container, note it here** — it may
pre-answer the stacking half of inherit-vs-fork (coke/meth bricks ride the same
container free).

### E4 — Hack-immunity ground truth

Verify **ECONOMY_DOCTRINE Law 2 in code**: "drug entities are explicitly
hack-immune." Grep the drug entities (E1 set + DrugDrop) for the actual
**theft / interaction / damage surface** — can any of them be robbed, cracked,
skimmed, or damage-looted? Is immunity explicit (a tag/flag/guard) or merely
the absence of a hook? Report the exact mechanism so the doctrine claim is
either confirmed or flagged as unenforced.

### E5 — Riders (close D's capital leg)

- **Printer spawn cost:** grep the money-printer entity for its spawn/purchase
  cost (D validated the $5,000/BTC RATE leg; this closes the CAPITAL leg of the
  comparables). Report the number and where it's set.
- **Salary table:** `System/RP/SalaryPaymentSystem.cs` — the per-job salary
  values, the pay interval, and where the table is configured.

## Outbox

Write findings to `cornerman-outbox/PACKET_E_FINDINGS_2026-07-09.md`. One
section per E-item, source `file:line` for every claim, and a top-line
**confirmed / flagged** verdict for E4 (the doctrine check). SHA the outbox
doc back to the shared inbox on completion.
