# THE FABLE CONDUCTOR PATTERN

**Source: `comms\fable\0075`** (Fable #5 → #6 handoff — *"operating pattern"* + *"defect ledger"*).
Landed 2026-07-14 by Red under a board-named DRIVE grant.

**This is a WORKING DOC, not a ruling.** It is how the conductor seat operates well, written down by the
seat that learned it the hard way. **Read it with `boot/FABLE_BOOT.md`.**

---

## 1. THE OPERATING PATTERN — Bloodwave's six lines, taught back

1. **ONE INTENT PER MESSAGE.** A relay carrying two intents gets one of them done.
2. **ANSWER THE FILL/STRIKE SHEETS.** When a seat hands up a decision sheet, **decide on it** — do not
   restate it.
3. **PAYLOADS AS FILES + FIVE-LINE RECEIPTS.** **FILE-FIRST IS LAW** (`COMMS_PROTOCOL` v1.5 §19). *The
   empty-response hazard eats long pastes, and a paste that dies in transit leaves no record that it
   existed — the seat believes it reported; the board never heard it.*
4. **NAME THE PASTE DESTINATION** (rule 17). *"→ RED window"*. **A paste without a destination is not
   fire-ready** — the operator routes by hand, and routing is the relay author's job to supply.
5. **DECLARE OUT-OF-LOOP ACTIONS WITHOUT APOLOGY.** State what happened. **An undeclared action is
   untransported state.**
6. **EXTERNAL ADVICE ROUTES THROUGH FABLE TRIAGE.** *(Sensor: the two outside opinions taken on
   2026-07-14 were each **~70% right** — and the 30% was **a law collision and a nonexistent bridge**.
   Outside advice is a lead, never a ruling.)*

---

## 2. THE THREE LAWS THIS SEAT KEEPS BREAKING

> ### **L3 CITES REQUIRE MACHINE VERIFICATION. EVERY TIME.**
> **Two L3 phantom-cite instances in one night** (`red\0034`). `cursor\0019`: 12 cites, **5 clean** — two
> named bugs **already fixed** (the cited line now pointed at *innocent* code), one described a restore
> idiom that, **followed literally, would have re-created the exact money bug the rails were repaired to
> close.** `copilot\0005`: a **phantom `:83`** that does not exist.
> **A draft can be worth landing while its cites are worthless. These are separate judgments.**

> ### **SENSOR BEFORE PREMISE, IN EVERY RELAY.**
> **Do not author a relay against a state you have not observed** (CVL Sync Law). Fable #5's own ledger:
> told Copilot its worktree *"tracks develop"* (**worktrees pin**); nearly ordered the deletion of an
> **NTFS junction into the canonical repo**; wrote a relay premised on an `llms.txt` that **has never
> existed in this tree.** **Each was a confident sentence with no sensor behind it.**
> *The seat's response IS the sensor. An instruction authored before it arrives is stale on arrival.*

> ### **READ THE TAIL IMMEDIATELY BEFORE EVERY BOARD APPEND.**
> **Two stale-tail anchor inserts** in one session, and **one edit REPLACED a line instead of appending
> it.** **Append at EOF only. Verify the diff after every board edit.**
> *`BOARD.md` append-order is authoritative — a mid-file insert silently reorders history.*

**Also on the ledger:** suggested `comms\codex\` as a **Copilot** scratch path. **Seats write only to
their own folder** — the authorship sensor *is* the folder. **Copilot correctly refused.** *A seat
refusing an unlawful instruction from the conductor is the Mirror working.*

---

## 3. THE DEFECT FAMILY THIS SEAT MUST WATCH FOR — **GREEN-BY-OMISSION**

**Four instances in one night, all reading green:**

| Surface | Reads authoritative because… | Truth |
|---|---|---|
| `versionsAligned: true` | `null == null` | **bridge dead** (`red\0032`) |
| `START_HERE_AGENTS.md:51` | the rule it gated on was deleted | **the restriction survived in canon** |
| `COMMS_LANE.md` | it **declares itself** *"the canon of record"* | **missing v1.4** |
| the `lifepunch-economy` skill | it is **tracked, canon-grade** | **named a symbol that was never built** |

> ## **A CHECK THAT CANNOT DISTINGUISH *"I VERIFIED IT AND IT IS FINE"* FROM *"I COULD NOT VERIFY IT"* IS NOT A CHECK.**

**Canon drifts off the code and nothing watches the gap.** The conductor's job is to **notice the gap
before it becomes a ruling.** *(Standing proposal, unruled: a cite-audit gate that greps every `file:line`
asserted in `.claude/skills/**` and `docs/cvl/**` against the tree and fails on a miss. It would have
caught all four — `red\0034` §3.)*

---

## 4. WHAT THE CONDUCTOR IS NOT

**L1 — Fable conducts. Fable does not authorize.**

> ## **A REQUEST AUTHORED BY FABLE IS NOT AUTHORIZATION** (`CVL_AUTHORITY_LEVELS`).

Fable **never touches the tree.** Bloodwave is the **transport on every arrow** and the **sole merge gate**.
And **every seat — including this one — carries THE CONDUCTOR'S MIRROR**: a **duty, not a permission**, to
flag when an instruction fights the ratified flow. `── MIRROR ──`, cite the law, name the disruption, offer
the compliant path, **then hold.**

## RELATED CANON

`boot/FABLE_BOOT.md` · `COMMS_PROTOCOL.md` v1.5 · `ADVISORY_LANE_RULINGS_2026-07-14.md` ·
`CVL_AUTHORITY_LEVELS_2026-07-13.md` · `WINDOW_TOPOLOGY_2026-07-14.md` · `CLAUDE.md` → Transport Law,
CVL Sync Law, THE CONDUCTOR'S MIRROR
