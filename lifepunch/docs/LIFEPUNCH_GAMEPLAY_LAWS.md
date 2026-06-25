# LIFEPUNCH™ — Gameplay laws (v1.1)

> **Status:** Active  
> **Why does this exist?** Technical law says how we ship; gameplay law says what players should feel and what we refuse to build.  
> **Does not replace:** `.cursor/rules`, `CYBER_REFERENCE_LAWS.md`, `LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md`.  
> **Vocabulary:** `TERMINOLOGY.md` · **Feel bar:** `LIFEPUNCH_FEEL.md` · **Decisions:** `DESIGN_DECISION_LOG.md`

---

## Law G0 — Single authoritative owner

**Every gameplay system has ONE authoritative owner.**

Never duplicate ownership across entities. If two surfaces can change the same state, one must be canonical and the other must **present or command** it — not re-implement it.

| Entity role | Owns (authoritative) | Does NOT own |
|-------------|----------------------|--------------|
| **Hub** | Mining operation state, work dispatch, wallet, hub upgrades, linked rack registry | Typed command parsing, per-rack hash math display copy |
| **Terminal** | Player presentation, command input, farm status readout | Mining ticks, payout ledger, upgrade ledger |
| **GPU Rack** | Local hash work, thermals, undeposited buffer, rack-side upgrades | Hub wallet, pool connection, global job schedule |

```text
If you cannot name the single owner in one sentence, stop and redesign.
```

Future cyber lanes (Banker, Hacker, Government, …) inherit this law. See `addons/docs/LIFEPUNCH_CYBER_SYSTEM_PATTERN.md`.

---

## Law G1 — Every upgrade has an in-world explanation

Players must understand **what they bought** without reading a wiki.

- Hub upgrade → controller got smarter (firmware, scheduler, security module).
- Rack upgrade → hardware got stronger (cooling, OC profile, buffer tank).
- No stat named after a engine artifact ("SyncFlags", "BuildHash") in player-facing copy.

If Architect cannot write one plain-language sentence for an upgrade, it is not ready to ship.

---

## Law G2 — Extend proven UX before redesigning

**Preserve shell, evolve content.**

- Add tabs, relabel panels, deepen status — do not replace working chrome because a mockup looks cleaner.
- Bitcoin hub (`LpHashdPanel`) and CRT terminal (`LpBitcoinTerminalPanel`) are reference surfaces for all cyber jobs.
- Redesign requires owner + Architect brief + explicit "UX break" flag in `TECH_DEBT.md`.

---

## Law G3 — Complexity is earned

Phase A = readable machine + honest baseline. Phase B = loop. Phase C = depth.

- Do not ship fan sequences, encryption trees, or multi-currency paths before the player completes the core loop once without help.
- One new mechanic per slice until flatgrass proof.

---

## Law G4 — Premium over quantity

Fewer interactions, higher clarity. Fewer props, higher recognition.

- Max racks, jobs, and menus are **design constraints**, not stretch goals to bypass.
- A polished 3-rack farm beats a cluttered 10-rack spreadsheet.

---

## Law G5 — Industrial over arcade

LIFEPUNCH cyber machines feel like **equipment**, not mobile-game buttons.

- States: OFF → BOOTING → ONLINE → WORKING → WARNING → ERROR (Law 6 in `CYBER_REFERENCE_LAWS.md`).
- Feedback from lights, sound, and attachment origins — not texture-only fakery.
- Tone: serious operator fantasy — Bloodwave / DarkRP lineage — not cartoon idle clicker.

---

## Law G6 — Technical realism supports gameplay

Real mining vocabulary (pool, share, hashrate, deposit, wallet) **when it helps fantasy**.

- Realism never blocks fun: simplify where DXRP roleplay needs it; label simplifications honestly in docs.
- Never fake realism with wrong entity ownership (CPU upgrades on GPU rack — see `BITCOIN_UPGRADE_TAXONOMY.md` target).

---

## Law G7 — Every machine follows the Digital Machine standard

Entities are **machines**, not props. Stack: Model → Collision → Physics → Attachments → Lights → Animation → Sound → State → Gameplay.

Canon: `LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md` · P0 gate: `MODEL_FOUNDATION_PASS.md`.

Gameplay law does not waive P0 mesh/collision proof.

---

## Law G8 — Reusable patterns over one-off mechanics

Before inventing a new flow, check `PATTERN_LIBRARY.md` and `LIFEPUNCH_CYBER_SYSTEM_PATTERN.md`.

| Answer | Action |
|--------|--------|
| Existing pattern fits | Extend it |
| Pattern almost fits | Generalize pattern once, then use |
| Nothing fits | Architect drafts new pattern → owner sign-off → add to library |

Aligns with CYBER Law 1 (reference first) and Law 3 (pattern library).

---

## Law G9 — Player-driven systems (no NPC dependency)

Core progression must not depend on NPCs.

- Loops come from **player-owned machines**, **player interaction**, **economy**, **businesses**, **crime**, and **server systems**.
- NPCs may appear later as **optional flavor or convenience** — never required infrastructure or quest givers for cyber professions.
- Bitcoin → Hub / HASHD Terminal / GPU Racks. Banking → player-operated. Crime → PvP.

Players operate **real infrastructure**, not scripted vendors.

---

## Fantasy Check (mandatory gate)

After playtest, **before owner sign-off**, answer exactly one question:

> **Does the implementation still deliver the intended player fantasy?**  
> Equivalently: **Does this still feel like LIFEPUNCH™?**

This is **not** compile status, performance, or bug count alone.

| Scope | Also run |
|-------|----------|
| Any slice | **Fantasy Check** |
| Major feature / economy / UX overhaul | **Fantasy Check** + full **Architect Review** checklist below |

See `LIFEPUNCH_FEEL.md` · lane fantasy: `BITCOIN_PLAYER_DESIGN.md`

---

## Architect Review (full drift checklist)

| # | Question |
|---|----------|
| 1 | Does this still match the **player fantasy** in the CURSOR BRIEF? |
| 2 | Does this **preserve existing UX** (extend, not accidental redesign)? |
| 3 | Is this introducing **unnecessary complexity**? |
| 4 | Does this **reuse existing patterns** (`PATTERN_LIBRARY.md`)? |
| 5 | Does this **improve roleplay** on a DXRP server? |
| 6 | Can we name the **single authoritative owner** for every new state field? |
| 7 | Does every upgrade have an **in-world explanation**? |

Failure on any row → fix or park in `BACKLOG_PARKING_LOT.md` — do not "ship and fix later."

---

## Document stack (read order)

| Order | Doc | Layer |
|-------|-----|-------|
| 1 | **This file** | Gameplay philosophy |
| 2 | `LIFEPUNCH_FEEL.md` | Product identity / subjective bar |
| 3 | `TERMINOLOGY.md` | Shared vocabulary |
| 4 | `ARCHITECT.md` | Design brain / workflow |
| 5 | `OWNERSHIP_MATRIX.md` | Who decides what |
| 6 | `DECISIONS/` | Settled design (cite by ID) |
| 7 | `KNOWLEDGE/` | Accumulated learning (not law) |
| 8 | `addons/docs/CYBER_REFERENCE_LAWS.md` | Cyber production gate |
| 7 | `addons/docs/LIFEPUNCH_CYBER_SYSTEM_PATTERN.md` | Reusable machine pattern |
| 8 | `PATTERN_LIBRARY.md` | Index of concrete patterns |
| 9 | `RFC/` | Under discussion (Draft only) |
| 10 | Lane docs (`BITCOIN_*`, …) | Per-addon canon |

---

## Long-term pattern order (post-bitcoin)

After `lifepunchbitcoin` Law 10 exit:

```text
LIFEPUNCH_GAMEPLAY_LAWS.md (this file)
  → LIFEPUNCH_CYBER_SYSTEM_PATTERN.md
  → BANKING_PATTERN.md (future)
  → HACKING_PATTERN.md (future)
  → BUSINESS_PATTERN.md (future)
```

Populate each pattern doc only when that lane unlocks — do not pre-write empty law.

---

*v1.1 — 2026-06-25 — Architect Phase 2 (G9, Fantasy Check)*
