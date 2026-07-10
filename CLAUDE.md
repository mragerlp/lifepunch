# CLAUDE.md — LIFEPUNCH agent grounding (Claude Code first read)

> **Workflow doctrine (2026-07-09):** `PLAN IN CHAT · BUILD IN CODE · REVIEW WITH CODEX · SHIP ONLY WITH BLOODWAVE GO`.
> Claude Code (Opus) is the primary implementation and editor surface. This file is the first grounding read.

## Roles

| Layer | Who | Does |
|-------|-----|------|
| **Plan** | Claude Chat — Fable (preferred) → Opus (heavier: architecture, canon, hard bugs) → Sonnet (budget: summaries, cheap docs) | Scope, edge cases, rulings, STOP-GO, handoff briefs. Does not implement unless asked. |
| **Build** | **Claude Code — Opus (primary)** | Reads the repo, edits files, runs tests, drives s&box editor work, gates with the Sensor Law, reports diff + proof. Commits only after a passing gate **and** Bloodwave GO. |
| **Review** | Codex | Reviews the DIFF, post-build, pre-merge. PASS / REVISE / HOLD on scope-match, proof quality, lane discipline. Never re-litigates rulings — a HOLD means "build ≠ ruling," not "I disagree." |
| **Green** | Cornerman (Tier-3 local worker, `qwen/qwen3.6-35b-a3b` Daily) | Distill / prep / audit / draft; feeds the planning layer (Packet E/F class). Flags, never decides. Never in the implement or review path. Never claims scale/materials/collider/animation verified from code alone — Cornerman's eyes are covered. |
| **Authority** | Bloodwave | Sole commit / push / merge authority. Final GO on every slice. |

Any task that CAN and SHOULD be done by Claude Code IS done by Claude Code. Grok/Cursor is an optional outside second opinion **on request only** — retired from the standard loop, originates no deliverables.

## Model routing (supersedes all prior tier language)

```
Fable (Chat)        planning, scope, edge cases, roadmap, briefs, rulings
Opus (Chat)         heavier planning fallback: architecture, canon, hard bugs
Sonnet (Chat)       budget fallback: summaries, cheap docs, low-risk briefs
Opus (Code)         PRIMARY implementer: repo edits, tests, s&box editor work
Codex               review only: PASS / REVISE / HOLD on diffs
Grok/Cursor         optional second opinion, outside the loop, on request only
Cornerman (Green)   Tier-3: distill/prep/audit/draft; feeds planning; never ships
```

## Transport Law

Long pasted handoffs between Chat and Code are a known hazard (empty-response bug). Do not rely on them.
- **PASTE** for state changes that fit ~one screen (CVL RELAY format — rulings, GOs, verdicts).
- **FILE** for anything longer or re-read later: a repo-tracked `lifepunch/docs/handoff/CLAUDE_CODE_BRIEF_<TASK>_<DATE>.md` (write-once). Screenshots and attachments remain valid transport.

**Write-once protects history, not intentions.** Test: *does this document describe something that already happened?* **Yes → record** (STOP-GO, diagnosis, recon brief, ruling): never edit, never annotate — supersede with a new record citing the old by filename. **No → instrument** (an unexecuted gate script): editable until its verdict lands. The moment a gate is executed and its verdict recorded, script and result **freeze together** as one record; a re-run needs a new script. When an instruction would annotate a record, **refuse and ask for a ruling** — do not assume an exception.

On receiving a handoff brief, before editing report: branch · HEAD · clean/dirty · intended files · forbidden files — then wait for GO.

## Grounding order

```
CLAUDE.md → lifepunch/docs/START_HERE_AGENTS.md → lifepunch/docs/CVL_AGENT_ONBOARDING.md
          → lifepunch/docs/handoff/README.md → the active brief in lifepunch/docs/handoff/
```

**Two folders are named `handoff`; only one is grounding material.**
- `lifepunch/docs/handoff/` — **CANON.** Tracked. STOP-GOs, rulings, recon briefs, diagnoses, gate scripts. Write-once. **This is the one you read.**
- `handoff/` (repo root) — **SCRATCH.** Untracked. Gate logs, screenshots, ledger backups. Proof, not canon. **Not grounding material; nothing reads it.**

Decision records go in canon. *Write-once canon that the grounding order does not read is canon nobody reads.* See `lifepunch/docs/handoff/README.md`.

## Hard rules

- **Author** `mragerlp <mragerlp@gmail.com>`. **No AI attribution** on any git surface, including PR bodies (no harness footer).
- **Lane:** `develop → main`, PRs only, Bloodwave merges. Protected branches.
- **Propose-and-STOP** for architecture/canon changes and any propose-gated brief: report the diff, wait for GO. Do not commit or push without a passing gate + GO.
- **Sensor Law:** every claim carries its sensor. A FRESH assertion needs the compile/parser log to POSTDATE the file write, plus a positive code-string ID proving the compiler read the new bytes. When no sensor reads the thing under test, build one. A behavioral change only the new code could produce is itself a positive ID.
- **CVL Sync Law:** *no actor issues instructions against a state it has not observed.*
  - Chat does not craft relays for Code while Code is mid-work — Code's response **is** the sensor; instructions authored before it arrive stale.
  - Code does not validate against its own tree what another machine executes — the **executing** machine's state is the sensor (Packet E: paths verified on Red, worker read Green).
  - Green's clones are asserted fresh before any run, never assumed (`expectedClones`).
  - One relay per state change; **no relay before the state is reported.**
  - *Live exception:* Bloodwave-keyboard debugging proceeds in real time — the human at the keyboard is the sensor.
- **Editor sync:** the s&box editor compiles a hand-synced copy under `D:\Steam\steamapps\common\sbox\dxrp\game\...`, not this repo. Sync via `lifepunch/scripts/Sync-LifePunchAddonsToDxrp.ps1` — `-WhatIf` first every time (the dry run is the authorization: only your session's files → run for real; anything else → STOP and report). Editing the repo and hotloading without syncing gives a FALSE all-clear.
- **Green fast-fail:** no retries, no detach, no polling loops, no CIM/WMI, no schtasks; any error/hang past ~20s → abort, report raw error, stop.
