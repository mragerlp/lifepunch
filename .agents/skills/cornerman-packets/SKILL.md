---
name: cornerman-packets
description: The Cornerman corner-loop discipline for LIFEPUNCH — use for ANY interaction with Green/Odysseus, packet drops, corner notes, findings records, or when preparing/reading material that crosses the Red↔Green lane. Enforces flags-never-decides, the ADVICE-NOT-A-WORK-ORDER header, findings-only (never direction), fast-fail on Green, outbox-only writes, the ff-only sync precondition, and the coverage self-gate. This skill points at canon; it does not restate it.
---

# Cornerman packets — the corner sharpens, never throws a punch

**This skill points at canon. Read the cited file before crossing the lane.**
Charter: **`lifepunch/docs/handoff/STOPGO_ODYSSEUS_CORNER_LOOP_CHARTER_2026-07-10.md`**.
Loop laws also in **`CLAUDE.md`** → "The Corner Loop".

## 1. THE CORNER IS A CORNER, NOT A FIGHTER

Odysseus/Green **flags, NEVER decides; never pushes** (charter `:14`). Corner output is
**advice-class data**, not direction. A scout finding names a seam; it never becomes Red's
work order on its own — findings reach the repo the way Packet E did, through Red, under the
merge gate (`CLAUDE.md` → Corner Loop). Bloodwave's relay remains the only execution authority.

## 2. THE LOOP

Charter `:20-30`: Red finishes a round, drops a **complete** ROUND REPORT to the shared inbox →
Odysseus reads it **COLD** and answers with a CORNER NOTE to the shared **outbox** (risks,
checks worth running, exemplars worth opening) → Red reads the corner note as **advice-class
data**, evaluates, reports, and executes nothing on its sole authority.

**BETWEEN-ROUNDS LAW:** Odysseus reads **completed drops, never Red's live tree** — advising
against mid-work state is the Sync Law race with a new hat.

## 3. ONE-VOICE LAW — the mandatory header

Every corner note carries the header **`ADVICE, NOT A WORK ORDER`** (charter `:43`). Red's read
rule is the canvas rule verbatim: evaluate, report, execute nothing on its sole authority.

## 4. OUTBOX-ONLY, FINDINGS-ONLY

Cornerman writes **RECON_/findings records to the SHARED OUTBOX only** (charter `:55, :66`) —
never into Red's tree, never a repo commit. Every claim is a finding with its sensor; corner
output is account-data-free doctrine packets, never raw portal data (`DXRP_PLATFORM_DOCTRINE.md`
§17). Cross-seat repair is forbidden: **Green facts are Green's to assert; Red facts are Red's**
(`CLAUDE.md` → Corner Loop) — any cross-seat fix needs Bloodwave's explicit relay.

## 5. TRANSPORT & PRECONDITIONS

- **Two lanes, both watchable, no hops** — `G:` reaches Green's INBOX; the return lane requires
  Green to share its OUTBOX and Red to map it (charter `:78-87`). ACL principal is an owner
  decision — **never `Everyone`** (`CLAUDE.md` → Transport Law).
- **ff-only sync precondition** — clones/branches advance only on a clean fast-forward; diverged
  or dirty = report, never force (`EDITOR_LAUNCH_LAW_2026-07-11.md` → Session Start Rule, mirrored
  on Green's clones). `expectedClones` asserted FRESH before any run, never assumed.
- **Green fast-fail** (`CLAUDE.md` → Hard rules): no retries, no detach, no polling loops, no
  CIM/WMI, no schtasks; any error/hang past ~20s → abort, report the raw error, stop.

## 6. SELF-GATES

- **BLOCKED → skip → continue:** a blocked item is reported and skipped, not retried in a loop;
  the run continues and the block is surfaced.
- **Coverage self-gate:** a sweep declares its denominator and proves it covered N/N — silent
  truncation reads as "covered everything" when it didn't. State what was dropped.
- **Naming:** inbound tasking packets follow the `FABLE_PACKET_*` convention; outbound records
  are `RECON_`/findings docs in the outbox (charter `:55`).
