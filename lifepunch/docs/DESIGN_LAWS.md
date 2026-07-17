# LIFEPUNCH DESIGN LAWS — the cross-lane rules every job must obey

> **Canon home:** `lifepunch/docs/DESIGN_LAWS.md`. These are **universal design laws** — they bind
> every job/economy lane (bitcoin, chemist, banker, blackmarket, hacker) and every future one. Read them
> before proposing or building any job, payout path, or currency surface. Ratified by Bloodwave
> (2026-07-16); this record graduates the three laws from the design sitting into the tree so builders
> find them in the grounding chain, not in a comms record. `CLAUDE.md` remains the canon of record; on
> any conflict, `CLAUDE.md` wins.

---

## 1. JOB-DEPTH LAW

LIFEPUNCH does not sprawl jobs. The roster stays tight; slots go to jobs with **quality systems** —
**depth over breadth.** Every proposed job lane faces this bar: does it bring a **real system**
(production, risk, counterplay), or is it a reskin? The existing lanes (bitcoin, chemist, banker,
blackmarket, hacker) each justify their slot with a system.

**Binds builders:** a new-job proposal must name its system (what is produced, what is at risk, how it is
countered) before it earns a slot. "Another way to make money" is not a system.

## 2. PHYSICAL-PAYOUT LAW (universal — generalizes the A6/A7 rider)

Payouts do not change: **the dealer has to drop his product.** Job product is **physical** — pocketed,
carried, delivered to a **drop entity**; payment happens **only at delivery.** No sell-from-menu, no UI
payout, anywhere, any job. The transport-risk loop (robbable, interceptable, policeable) **is** the
roleplay and is **load-bearing** — no future convenience feature may bypass it.

**Binds builders:** there is **no payout UI surface** in any job. A job's sale path terminates at a
physical drop entity, and the money segment fires on delivery. A design that pays from a menu, a tablet,
or a terminal is off-law on sight. (This law generalizes the chemist A6/A7 rider to every lane.)

## 3. BITCOIN SESSION-POWER DOCTRINE

Bitcoin is a **serverwide currency with potential portal backing** — like `$LP` in reach, **unlike `$LP`
in persistence: BITCOIN IS SESSION-BASED.** Holding bitcoin is deliberately a **session power**: players
who build, run, and heavily guard mining operations **are owed** an in-session advantage. Consequences
that bind builds:

- **Balance passes must not erode the defended-wealth advantage in the name of fairness — the advantage
  is the design.**
- The **hacker lane is the sanctioned counterplay** to that advantage (E-R4 wallet theft): session
  wealth is raidable; defense-vs-raid is the intended game.
- **No job payout mints bitcoin;** bitcoin enters through the **mining operation loop only.**

**Binds builders:** never add a bitcoin faucet to a non-mining job, and never "rebalance" the
mining-wealth advantage away. The raid/defend tension is the intended endgame, not an imbalance to fix.

---

## D-R6 — CLOSED: FENCE-MACHINE (delegation ruling, rides these laws)

Under the Physical-Payout Law and Bloodwave's delegation, **D-R6 is ruled FENCE-MACHINE:** the
BlackMarket **dead-drop stays** — it is the **identical physical-carry loop** (bring goods to the box,
paid on delivery), **not an NPC merchant** (No-NPC Law intact). **Collar binds:**

- server-authoritative rate and cap;
- **pays `$0` until Bloodwave configures it;**
- SOURCE and SINK ops live in **distinct subclass symbols** (D-R7 rider — no base method carries both
  money directions).

Bloodwave override stands open by one word. BM S4 (#149) ruling-gate is **CLEARED** (the head-dev
double-gate on the build itself still applies; W4 census corroborates on landing).

---

*Source: the 2026-07-16 design sitting (Bloodwave's word, recorded by Fable). Landed in-tree under the
Canon Persistence Law. Lane-specific application of these laws lives in each lane's doctrine
(`COCAINE_PROCESSING_DOCTRINE.md`, `CHEMIST_RULINGS_A1-A15_2026-07-16.md`, the banker/blackmarket/hacker
design packets).*
