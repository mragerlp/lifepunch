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

### E3 — Coke/meth extension map

Report the **inherit-vs-fork** decision surface: does `DrugDrop` (and the
pipeline entities) subclass cleanly, or would coke/meth need a fork? Enumerate
what a **WINDOW-GATED drop** needs that vanilla `DrugDrop` LACKS (timed open
windows, scheduled spawn, a moving vehicle host). NOTE for context (do not
build): traindrop/truckdrop MODELS are staged in Bloodwave's warehouse (Fable
manifesting) — the question is purely what code seam a window-gated variant
plugs into.

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
