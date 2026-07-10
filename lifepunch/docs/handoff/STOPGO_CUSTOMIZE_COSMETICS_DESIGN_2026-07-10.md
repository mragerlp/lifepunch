# Customize / Cosmetics — ratified design record (lpbitcoin v1)

**Status:** RECORD — design ratified across the 2026-07-09/10 predecessor
session; this file is its durable canon form. Write-once. Code-truth gaps are
listed as TO-VERIFY and resolve into a separate `RECON_` record — they do not
reopen the design.
**Authority:** Bloodwave-ratified · Fable-drafted · builds only after the
[Sync] gate lands and Bloodwave GOs a slice proposal.
**Sequencing:** queues BEHIND the two-client [Sync] gate
(`GATE_ADVANCEDRACK_SYNC_TWO_CLIENT.md`) — that gate proves the exact
replication pattern equipped cosmetics require.

## 1. Cosmetics are a COLLECTION, not tracks

Cosmetics leave the tiered-ladder model entirely. They are removed from the
TIER PROGRESS block on every entity:
- **Terminal** drops to **five real tracks** + one Customize entry.
  (This AMENDS the prior "Terminal has six tracks" language wherever it
  appears — five real, one Customize.)
- **Hub** drops **Sound Pack** from its track list.
Progression tracks buy capability; the Customize collection holds identity.

## 2. Topology — the Customize tab

Mirrors the Servers-page topology: **HUB → TERMINAL → GPU RACKS**, racks one
level deeper. Implemented as a **Cosmetic Detail Contract** — a sibling of the
Entity Detail Contract: one component, entity-supplied cosmetic model.

## 3. Slot taxonomy (ruled)

| Entity | Slots |
|---|---|
| Hub | **Sound** (5 tier-flavored loops) |
| Terminal | **UI Style** + **Keyboard Sound** |
| GPU Racks (all three) | **one shared Color slot** (hue) |

## 4. SIGNAL / STYLE LAW — load-bearing

Every audiovisual surface has two channels:
- **SIGNAL — code-owned, never customizable:** power-on ramp, consistent
  flow, wind-down envelope, the emissive **intensity ladder**, rack fan
  sounds. Signal is honest telemetry.
- **STYLE — player-owned:** hue, sound flavor, UI skin.
Cosmetics touch STYLE only. This is what preserves recognition: a rack's
**brightness = live tier** (signal); its **color = badge** (style). A raider
reads brightness for tier; gold fans just mean someone donated.

## 5. COSMETIC FIREWALL

Cosmetic code carries **no reference** to `YieldMultiplier`, `ComputeTier`,
or any economy value. No-P2W is an **architectural fact enforced in code**,
not a policy statement.

## 6. Badge, not telemetry (ruled)

Unlocked cosmetics are **chosen displays of achievement**, not live readouts.
A Tier-V player may equip the Tier-II sound loop. Choice stays meaningful;
the grind stays visible only where the player elects to show it.

## 7. Four acquisition doors

1. **₿ purchase** — Law B: cosmetics persist after death → BTC-side. This
   makes Customize the first **mass-market BTC sink** in the economy.
2. **Progression unlock** — the grind made visible.
3. **Donor perk** — VIP/EVIP = perks only, never power; this page is where
   that law becomes **visible to players**.
4. **EARNED-ONLY** — the fourth door, mandatory for anything carrying
   reputation information. Never sold, never donor-granted.

## 8. SIGNATURE — victim-surface cosmetic (PLANNED)

A "Skilled Hacker" earns an electronic **signature** rendered on the
**victim's** terminal after a robbery — a new cosmetic category whose display
surface is another player's screen. Interlocks with Terminal Intrusion
Detection ("silent theft becomes a BREACH alert and a traced attacker"):
- **Signal (code-owned, unfalsifiable):** that a breach occurred, when, what
  was taken.
- **Style:** the flourish attached.
- The **right to sign is EARNED-ONLY**; donors may get hue variants **of a
  signature they earned**.
Depends on systems that don't exist yet (heist loop, per-player attack
counter, delivery-to-victim-terminal). Renders in v1 as a **PLANNED slot
with its unlock condition visible** — a teaser for the heist system.

## 9. Interlocks

- **[Sync]:** equipped cosmetic state must replicate — the value of a donor
  skin is that OTHERS see it. Hence the queue position behind the two-client
  gate.
- **Gate 3 (rack lights):** intensity ramp = live tier telemetry (signal,
  gate 3 builds it); hue = badge (style, Customize adds it later). Same
  fixture, both channels, built in that order.

## 10. Scope

v1 = **lpbitcoin's five entities only.** The LIFEPUNCH-wide progression
spine is a later lane; lpbitcoin Customize is its **reference
implementation**, the way the Servers page became the acceptance bar.

## TO-VERIFY — code truth (one-shot recon; RECON_ record to follow)

Doctrine is settled; these are implementation seams, resolved by grep once
the Filesystem connector revives (or by Red directly):
- **T1.** Does vanilla DXRP have a skin/material-swap system (per-entity
  material/tint parameter vs. model skin variants)? Governs the shared
  rack Color slot.
- **T2.** Per-player **persistent unlock storage** — where does DXRP persist
  player-owned state across sessions? Governs the collection itself.
- **T3.** A per-player **action counter** (e.g. "X successful attacks") or
  the nearest seam for one — governs the Signature unlock condition.
- **T4.** Sound-asset slotting: how entity sound events are assigned —
  governs Hub Sound / Keyboard Sound swap mechanics.
- **T5.** Confirmed by the [Sync] gate itself: the replication pattern for
  per-entity, host-authoritative cosmetic state (C3/C4 outcomes feed this
  directly).

## Cross-references

`GATE_ADVANCEDRACK_SYNC_TWO_CLIENT.md` · `NONOWNER_CLIENT_READ_SURFACE_2026-07-10.md`
(the raider-read framing the Signal channel serves) · `UPGRADE_ECONOMY_DOCTRINE.md`
(Law B) · `LIFEPUNCH_UI_STANDARD.md` (Entity Detail Contract).
