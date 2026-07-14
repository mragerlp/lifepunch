---
name: codex-implement
description: Delegate implementation of a TRIP plan (or a scoped part of it) to Codex CLI
argument-hint: "<plan-path> [instructions] | reset <plan-path> | show <plan-path>"
---

> **CVL SUBORDINATION BANNER (LIFEPUNCH adoption, 2026-07-14).** This skill is ADOPTED
> UNDER CVL LAW per `lifepunch/docs/cvl/TRIP_ADOPTION_2026-07-14.md`. Precedence is fixed:
> CVL law > Bloodwave two-key list > seat charter > this skill. Overrides, non-negotiable:
> (1) **Merge, push, tag, ship, and destructive git are Bloodwave's word EXCLUSIVELY**  - 
> any step below that merges/pushes/tags becomes "propose and HOLD for Bloodwave GO".
> (2) **Author `mragerlp <mragerlp@gmail.com>` only; ZERO AI attribution** on any git surface.
> (3) **Sensor Law applies**  -  every behavioral claim carries its sensor; testing gates in
> this skill are floors, not substitutes. (4) **Transport Law applies**  -  seats do not
> message each other directly; Bloodwave carries every arrow. (5) "Codex" below means the
> board-named implementer lane per `EDITOR_ACCESS_LAW_V2`; the plan seat is Fable.
> (6) `ARCHI.md` is subordinate to `CLAUDE.md`; on conflict, CLAUDE.md wins and ARCHI.md
> is the defect. Skills are capability, not authority.

# Codex Implement

Non-interactive implementation via Codex CLI in a **workspace-write** sandbox: Codex reads the plan, edits the working tree directly, runs the project's lint/build on its own work, and reports back. One persistent thread per target, so multi-phase plans can be delegated phase by phase with full context retained.

State persisted under `.claude/skills/codex-implement/state/<sanitized-target>.{thread,review.txt,events.ndjson}` (the `.review.txt` file holds Codex's implementation **report**  -  the naming comes from the shared helpers). `resume`/`reset`/`show` reuse the shared scripts from `codex-plan-review`; always export before invoking them:

```bash
export STATE_DIR=".claude/skills/codex-implement/state"
```

## Arguments

- `<target>`  -  auto: start if no thread, resume if one exists. Usually a plan path (`docs/1-plans/F_*.plan.md`); a free-form label for unplanned work.
- Optional trailing instructions  -  scope control appended to the prompt, e.g. `"Implement Phase 1 only"` or `"Now implement Phase 2"`.
- `reset <target>`  -  drop state, next call starts fresh.
- `show <target>`  -  display the latest report without calling Codex.

## Execution

1. **Parse `$ARGUMENTS`**: extract action (`reset`/`show`/auto) and target.

2. **Auto**  -  try `start.sh` first (exit code 2 = thread exists → use `resume.sh`):
   - **Start**: `bash .claude/skills/codex-implement/scripts/start.sh --prompt-file .claude/skills/codex-implement/prompts/implement.tpl <target> [instructions]`
   - **Resume** (next phase / additional scope): `bash .claude/skills/codex-plan-review/scripts/resume.sh --prompt-file .claude/skills/codex-implement/prompts/continue.tpl <target> [instructions]`

3. **Reset**: `bash .claude/skills/codex-plan-review/scripts/reset.sh <target>`

4. **Show**: `bash .claude/skills/codex-plan-review/scripts/show.sh <target>`

5. **Parse trailing tag** of the report:
   - `IMPLEMENTATION_COMPLETE`  -  hand control back to the requester's self-review (TRIP-2).
   - `IMPLEMENTATION_PARTIAL`  -  read the report; resume with instructions for the remainder, or let the requester finish small leftovers directly.

## Notes

- `--sandbox workspace-write` on start; `codex exec resume` inherits it. Codex edits files and runs repo commands (lint/build); no network, no commits.
- **Fixes are the requester's job.** After Codex reports, the requester (TRIP-2 self-review) fixes problems directly in the tree  -  do NOT ping-pong fixes back to Codex. Resume only for genuinely new scope (next phase, large remainder).
- Separate `STATE_DIR` from the review skills  -  the same plan path can hold an implementation thread and a review thread without collision.
- Codex is instructed not to write tests (testing gate owns that) and not to touch release ceremony.
- Network is blocked in the sandbox: if the plan requires installing a new dependency, Codex will report it as a leftover  -  install it yourself during self-review.
- Model/effort defaults live in `codex-plan-review/scripts/_common.sh` (implementation → gpt-5.6-luna, reviews → gpt-5.6-sol, effort xhigh; derived from `STATE_DIR`). Adjust that one file to your preferred models, or override per run via `CODEX_MODEL` / `CODEX_EFFORT` env vars; the scripts echo the effective values.
