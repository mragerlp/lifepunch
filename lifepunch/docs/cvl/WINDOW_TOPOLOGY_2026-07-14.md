# WINDOW TOPOLOGY + ORCHESTRATOR CONFIG OF RECORD

**RATIFIED 2026-07-14, Bloodwave.** Source records: **`comms\fable\0074`** (config v2), **`fable\0075`**
(topology at the #5→#6 handoff), building on **`fable\0072`** / **`fable\0073`**.

> **COMPANION RECORD — NOT AN EDIT.** `ORCHESTRATOR_SEAT_RULING_2026-07-14.md` is **class RULED and
> write-once**; its own header forbids editing it in place. This record **extends** it and **cites it by
> filename**, exactly as the write-once law requires. **Nothing in the orchestrator ruling is amended or
> weakened here.** *(Same reasoning that kept `TRIPLE_MCP_STACK` a separate note rather than an
> `EDITOR_ACCESS_LAW_V2` addendum — `red\0028`.)*

---

## 1. EXACTLY TWO WORKING WINDOWS

| Window | Seat | Authority |
|---|---|---|
| **FABLE** | conductor, **L1** | **Never touches the tree.** *A request authored by Fable is not authorization.* |
| **KEPLER ORCHESTRATOR** | one **OpenCode** session, repo root, VENGEANCE | Per `ORCHESTRATOR_SEAT_RULING` — **one window = one seat.** |

> ## **NO SECOND `opencode.exe`.**
> One window = one seat. **A second OpenCode process does not create a second seat — it creates a race for
> the same chair**, exactly as a second harness on the Codex API does (`CLAUDE.md` → *THERE IS EXACTLY ONE
> CODEX*). **Absence of a grant is not a grant, and neither is a spare window.**

**Also live, and unchanged:**
- **RED** (Claude Code, VENGEANCE) — **editor bridges + runtime truth** + heavy git/docs slices.
  **The editor surface does NOT move to OpenCode** (`fable\0072` cl. 5, `fable\0073`).
- **GREEN-CONSOLE** (Odysseus, CORNERMAN) — **L3.** Files to `CornermanOutbox`. **`comms\` is
  VENGEANCE-LOCAL and unreachable from CORNERMAN** — Fable proxy-appends its BOARD lines.
- **COPILOT · CURSOR · KEPLER** — **L3 lanes** (`ADVISORY_LANE_RULINGS_2026-07-14.md`).
  **Cursor is the independent merge reviewer of choice** (`fable\0072` cl. 6 — *a seat reviewing its own
  subagent's work is not independent review*).

## 2. SUBAGENTS ARE TOOLS — permission-capped, zero authority

| Subagent | Model | Status |
|---|---|---|
| `corner-review` | qwen coder 32b | **LIVE** |
| `deep-scan` | qwen 27b | **LIVE** |
| `codex-review` | ChatGPT Pro | **PENDING** — Bloodwave supplies the exact provider id from `opencode models`. **Do not guess one.** |

**Both live subagents are hard-walled:** `edit: deny` · `external_directory: deny` · `bash: *: deny` with a
read-only git allowlist · `skill: *: deny` with a named allowlist.

**Their output is LEADS-GRADE to their own orchestrator** — the orchestrating model **machine-verifies
every cite before it enters any filing**, exactly as Odysseus verifies qwen. *This is not ceremony:* two L3
seats filed bad cites in one night, and one of them would have re-created a fixed money bug (`red\0034`).

## 3. THE CONFIG OF RECORD

**`opencode.json` per `comms\fable\0074` is the config of record.** Key constraints, and **why**:

| Setting | Value | Why |
|---|---|---|
| **NO `mcp` / editor block** | absent **by ruling** | `fable\0072`/`0073`: **Red keeps the editor bridges.** An editor MCP entry here would hand the orchestrator a cable the board never granted it. |
| `lifepunch-editor-gate` | **`skill: deny`** | Editor launches are **Red's surface**. |
| `cornerman-packets` | **`skill: deny`** | Packet authoring is the **Fable/Bloodwave** lane. |
| `skill: "*"` | **`ask`** *(not `deny`)* | An unknown or new skill **prompts Bloodwave** rather than **silently hiding**. **A silent deny is a green-by-omission failure** — the seat would never learn the skill existed. *Subagents get hard deny-walls; the seat gets a prompt.* |
| `external_directory` | **`ask`** | `fable\0071` — `comms\` filings approved; **every out-of-repo access prompts and Bloodwave clicks the gate.** |
| `git push/merge/tag/reset/checkout` | **`deny`** · `commit` **`ask`** | **Bloodwave holds both keys. Forever.** |

## 4. EDITOR EYES FOR THE ORCHESTRATOR — **BANKED, NOT GRANTED**

**This is a FUTURE ruling. It is not in force.** If it is ever granted it is **READ-ONLY AT MOST**
(chomnr / native), and **DRIVE remains board-named and exclusive** — *three cables are not three drivers*
(`TRIPLE_MCP_STACK_2026-07-13.md`).

> **NEVER Ozmium / port 8098 — IT DOES NOT EXIST ON THIS STACK.** It appeared in outside advice and is a
> **phantom endpoint**. **Do not wire it, do not probe it, do not let a config reference it.**

*Recorded because a nonexistent bridge in a config is worse than a missing one: it fails in a way that
looks like a connection problem rather than a fiction.*

## RELATED CANON

`ORCHESTRATOR_SEAT_RULING_2026-07-14.md` (**the record this extends**) ·
`ADVISORY_LANE_RULINGS_2026-07-14.md` · `PLAYERHUB_GATES_RULING_2026-07-14.md` ·
`EDITOR_ACCESS_LAW_V2_2026-07-13.md` · `TRIPLE_MCP_STACK_2026-07-13.md` ·
`CVL_AUTHORITY_LEVELS_2026-07-13.md` · `CLAUDE.md` → *AUTHORITY FOLLOWS THE MODEL, NOT THE HARNESS*
