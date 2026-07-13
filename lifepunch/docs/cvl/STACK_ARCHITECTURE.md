# CVL STACK ARCHITECTURE — canon

> Landed by Red at the r3 close, 2026-07-12, from `C:\lifepunch\comms\STACK_ARCHITECTURE.md` v1.

# LIFEPUNCH AI STACK ARCHITECTURE v1
Ratified: 2026-07-12 · Authority: Bloodwave (full delegation) · Author: Fable
Lands in-repo via canon package (fable\0013 + 0014). This file is the master copy until then.

## 1. SEAT ROSTER

| Seat   | Surface                | Model class            | Cost | Role |
|--------|------------------------|------------------------|------|------|
| FABLE  | Claude chat (this)     | Most expensive         | $$$$ | Conductor: plans, rulings prep, gate reviews, brainstorms with Bloodwave |
| RED    | Claude Code terminal   | Opus                   | $$$  | SOLE implementer: repo hands, editor DRIVE, runtime truth, machine-verify |
| CODEX  | Codex chat window      | SOL 5.6 high           | $    | Frontline: study, draft, diffs, review, pre-grade. Proposal-only. ~2x speed |
| GREEN  | LM Studio / CORNERMAN  | Local qwen (watts)     | ~0   | Overnight bulk audit, recon packets, census. Static-only |

BLOODWAVE is not a seat. He is the key: GO words, two-key gates
(merge / ship / canon / destructive / DXRP sync), and the only human.

## 2. EDITOR ACCESS LAW (new — ratified with dual-bridge capability)
Both Red and Codex may hold MCP bridges into the s&box editor.
Authority split, non-negotiable:
- RED = DRIVE authority: play state, hotload, sync, spawns, ConCmds,
  scene mutation. One driver at a time, always Red.
- CODEX = OBSERVE authority: screenshots, log reads, status polls,
  get_tags-class reads. NEVER play-state mutation, NEVER hotload/sync,
  NEVER a command with side effects.
Rationale: two models, two eyes, zero contention. The "two hands on
the editor" hazard is real (observed this arc). If Codex needs a
runtime state changed to observe it, it requests through the loop;
Red changes it.
DEBUG PAIR PATTERN: during deep editor work, Red drives while Codex
watches logs/screenshots in parallel and files observations. This is
the acceleration Bloodwave wants, with the contention law intact.

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
- Anything touching tree or editor-drive -> RED
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
Runtime truth / tree mutation / editor drive -> RED
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
