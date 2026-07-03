# CORNERMAN — <LANE> RESTART PACKET (read-only prep)

- **Route tag:** GREEN DEEP REQUIRED
- **FOCUS:** LifePunch `<package>` — NOT DXRP upstream / NOT other lanes
- **Owner:** Bloodwave
- **Mode:** Read-only prep / no code / no commits / no push / eyes covered

## Context

<One paragraph: what parallel work just closed, what active lane resumes, monorepo HEAD if known.>

## Your job

Produce one report:

`C:\lifepunch\cornerman\outbox\RESTART_PACKET_<lane>_<YYYY-MM-DD>_<HHmm>.md`

## Step 1 — Sync / ground

```powershell
cd C:\Projects\lifepunch   # Green monorepo clone
git fetch
git pull --rebase
git status -short
git log -1 --oneline
```

If dirty or cannot fast-forward: **stop and report**. Do not clean/reset/stash unless Bloodwave says.

## Step 2 — Read canon (current repo versions)

- `lifepunchaddons/docs/ACTIVE_WORKSTREAM.md`
- `lifepunchaddons/docs/<LANE>_SHIP_ROADMAP.md` (or equivalent)
- `lifepunch/docs/handoff/ARCHITECT_CURRENT_STATE.md`
- Relevant `lifepunch/docs/DECISIONS/DECISION-####*.md`
- Lane-specific pattern/taxonomy docs

Report contradictions between canon and code.

## Step 3 — Inspect code (read-only)

List paths for this lane (UI, entities, economy, staging). For each finding label:

- VERIFIED FROM REPO
- VERIFIED FROM CANON
- INFERRED FROM EXISTING PATTERNS
- NEEDS SBOX RUNTIME PROOF
- OWNER DECISION REQUIRED

## Step 4 — Packet sections (required)

1. Current repo state
2. Current lane state (canon + code)
3. **ONE** recommended next Red slice (from approved list — do not invent direction)
4. File map for next slice / milestone
5. Model route table
6. Paste-ready VENGEANCE resume block

## DO NOT

- Touch parallel/upstream implementation repos
- Modify code, commit, push
- Claim compile, editor, or flatgrass proof
- Start blocked lanes (`BACKLOG_PARKING_LOT.md`)
- Make ship decisions

## Output rules

- Write **only** to `C:\lifepunch\cornerman\outbox\`
- Do not edit repo docs unless Bloodwave explicitly asks
- Short, paste-ready, action-oriented — not an essay

## Completion signal

```text
OK cornerman <lane>-restart-packet complete @<time>
head=<commit>
outputs=1
eyes=covered
no-code
no-commit
```

Then idle.
