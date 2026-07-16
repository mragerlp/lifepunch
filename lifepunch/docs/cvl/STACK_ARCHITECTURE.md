# CVL STACK ARCHITECTURE — canon

> Landed by Red at the r3 close, 2026-07-12, from `C:\lifepunch\comms\STACK_ARCHITECTURE.md` v1.

# LIFEPUNCH AI STACK ARCHITECTURE v1
Ratified: 2026-07-12 · Authority: Bloodwave (full delegation) · Author: Fable
Lands in-repo via canon package (fable\0013 + 0014). This file is the master copy until then.

## 1. SEAT ROSTER

| Seat   | Surface                | Model class            | Cost | Role |
|--------|------------------------|------------------------|------|------|
| FABLE  | Claude chat (this)     | Most expensive         | $$$$ | Conductor: plans, rulings prep, gate reviews, brainstorms with Bloodwave |
| RED    | Claude Code on VENGEANCE — canonical tree | Opus                   | $$$  | Implementer: repo hands, runtime truth, machine-verify. DRIVE when board-named (§2) |
| CODEX  | Codex chat window      | SOL 5.6 high           | $    | Implementer: study, draft, diffs, review, pre-grade. DRIVE when board-named (§2). ~2x speed |
| GREEN  | LM Studio / CORNERMAN  | Local qwen (watts)     | ~0   | Bulk audit, recon packets, census, consult duty. Static-only |

BLOODWAVE is not a seat. He is the key: GO words, two-key gates
(merge / ship / canon / destructive / DXRP sync), and the only human.

> **Seat = harness + HOST + TREE.** "Claude Code" alone does not name RED. A Claude Code session on
> **CORNERMAN** (Green's clone `C:\Projects\lifepunch`, read-only) is the **GREEN** seat, not RED. RED is
> Claude Code on **VENGEANCE** driving the canonical tree (`C:\Users\jared\Projects\lifepunch`). See
> `CLAUDE.md` § "SEAT IDENTITY FOLLOWS THE HARNESS" and
> `OPENCODE_SEAT_IDENTITY_AND_HARNESS_OPS_RULING_2026-07-15.md`.

## 2. EDITOR ACCESS LAW — **v2 GOVERNS. SEE `EDITOR_ACCESS_LAW_V2_2026-07-13.md`.**

**DRIVE is a named grant, not a Red monopoly.** Exactly one seat holds editor
DRIVE at any moment, declared on the BOARD by Bloodwave's grant; all other seats
are OBSERVE-only. DRIVE = tree hands, so a grant is a full implementer swap for
its duration, and Codex's "proposal-only on the canonical tree" clause is
suspended while Codex holds it. Swaps happen at slice boundaries, never mid-slice.
The full law, the reshaped circle, the governor clause, and the parallelism
clause live in the v2 record — read it, not this summary.

> **v1 (SUPERSEDED, kept as history):** *"Both Red and Codex may hold MCP bridges
> into the s&box editor. RED = DRIVE authority… One driver at a time, always Red.
> CODEX = OBSERVE authority… NEVER play-state mutation, NEVER hotload/sync."*
> The **one-driver-at-a-time** invariant survives v2 intact; **"always Red"** does
> not. The "two hands on the editor" hazard v1 named is real and observed — v2
> answers it with a board-named exclusive grant rather than a fixed seat.

DEBUG PAIR PATTERN (unchanged, now seat-agnostic): during deep editor work the
DRIVE holder drives while the other implementer watches logs/screenshots in
parallel and files observations. Two models, two eyes, zero contention.

## 3. FABLE USAGE LAW (protects the expensive window)
A Fable turn is earned by:
- Brainstorming / new-idea planning with Bloodwave
- Rulings that need judgment (not mechanical grading)
- Gate reviews (Canon Persistence, merge gates)
- Directions Bloodwave needs for his own hands
- Deep explanation / learning / articulation for others
Everything else routes down:
- Mechanical pre-grading of seat reports -> CODEX (files a pre-grade;
  Fable ratifies in one line)
- Drafting of specs/diffs/docs -> CODEX
- Bulk reads/census -> GREEN
- Anything touching tree or editor-drive -> **the board-named DRIVE holder** (§2 / `EDITOR_ACCESS_LAW_V2_2026-07-13.md`) — not a fixed seat
Fable replies stay terse; detail lives in lane files. Receipt
manifests, grades, and rulings are FILED, then summarized in chat.

## 4. THE LOOP (sync cycle, canonical)
1. Bloodwave + Fable set intent (the only expensive conversation)
2. Fable writes dispatches (comms\dispatch\<seat>\ with GO header,
   or paste blocks while windows lack polling)
3. Bloodwave fires: one GO word / paste per seat
4. Seats work; file to lane; one-liner back to Bloodwave
5. Bloodwave: "comms ready"
6. Fable: receipt manifest -> grades (or ratifies Codex pre-grades)
   -> rulings -> next dispatches. One turn.
7. Two-key gates stay in Bloodwave's window, always.

## 5. STATE LIVES IN FILES, NEVER IN HEADS
- Repo = truth for canon (CLAUDE.md, docs/cvl/, doctrine files)
- Lane = truth for in-flight work (BOARD.md + seat folders)
- FABLE_STATE.md (comms\fable\) = the conductor's living handoff:
  updated at every major cycle close. A new Fable session boots by
  reading it — no more wall-of-paste bootstraps. If this window dies
  mid-arc, the next one loses minutes, not the arc.
- Seat onboard files (docs/cvl/onboard/) = seat boot. A new window's
  entire bootstrap: "read your onboard file."

## 6. ESCALATION LADDER (cheapest capable seat wins)
Question about code-as-written -> GREEN (free) or CODEX (fast)
Draft/spec/diff/review -> CODEX
Runtime truth / tree mutation / editor drive -> the DRIVE holder named on the BOARD
Judgment call / plan / ruling -> FABLE
Approval -> BLOODWAVE
A job routed upward without exhausting the cheaper seat is a
routing defect; flag it.

## 7. FAILURE MODES + RECOVERY
- Seat window dies -> new window reads its onboard file + BOARD tail.
- Fable session dies -> new Fable reads FABLE_STATE.md + BOARD tail
  + last 3 fable\ records. Bloodwave pastes only: "boot from state."
- Lane unreadable -> loud degradation to paste (protocol rule).
- Mirror stale -> scheduled task CVL-LaneSync (10 min); manual /E
  pull as fallback.
- Conflicting records -> write-once: new record cites old by
  filename; never rewrite history.

## 8. WHAT IS NEVER AUTOMATED
Bloodwave's authorization arrows. Merge, ship, canon ratification,
destructive ops, DXRP sync, spending real money. Two-key, forever.
