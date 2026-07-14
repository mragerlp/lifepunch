# TRIP WORKFLOW ADOPTION - 2026-07-14

**STATUS: PROPOSED (full adopt), pending Bloodwave merge.**
**Authored by the Fable seat (Copilot harness, orchestrator grant per comms `copilot\0007`).**
**Source evaluation: comms `copilot\0008_COPILOT_TRIP-WORKFLOW-EVALUATION_2026-07-14.md`.**

## What was adopted

The full TRIP-workflow skill set (github.com/PiLastDigit/TRIP-workflow, MIT, v2.1.0) -
14 skills - installed into both tracked skill surfaces (`.claude/skills/` and
`.agents/skills/`, same PR, per the paired-surfaces law in `CLAUDE.md`):

TRIP-1-plan · TRIP-2-implement · TRIP-3-release · TRIP-init · TRIP-compact ·
TRIP-hotfix · TRIP-research · TRIP-review · TRIP-test · TRIP-upgrade ·
codex-implement · codex-code-review · codex-plan-review · codex-ask

Plus `ARCHI.md` at repo root - TRIP's persistent architecture memory, generated for
LIFEPUNCH and explicitly subordinated to `CLAUDE.md`.

## The subordination banner

Every adopted SKILL.md carries a **CVL SUBORDINATION BANNER** immediately after its
frontmatter. It fixes precedence (CVL law > two-key list > seat charter > skill) and
overrides six clauses wherever upstream TRIP assumes authority no seat holds:

1. Merge/push/tag/ship/destructive-git steps become **propose-and-HOLD for Bloodwave GO**.
2. Author `mragerlp` only; zero AI attribution on any git surface.
3. Sensor Law applies; TRIP's testing gates are floors, not substitutes.
4. Transport Law applies; Bloodwave carries every seat-to-seat arrow.
5. "Codex" in skill bodies = the board-named implementer lane (`EDITOR_ACCESS_LAW_V2`);
   the planning agent = Fable.
6. `ARCHI.md` is subordinate to `CLAUDE.md`.

This is the same subordination pattern `SUPERPOWERS_DOCTRINE.md` ratified for the
superpowers skill set (clauses S-1..S-6); TRIP inherits that precedent.

## Seat mapping

| TRIP role | CVL seat |
|-----------|----------|
| Main agent plans (TRIP-1) | Fable |
| Plan review loop (codex-plan-review) | Codex review lane (or Sol) |
| Implementation (TRIP-2 / codex-implement) | Board-named DRIVE holder (Red or Codex) |
| Code review loop (codex-code-review) | The non-DRIVE implementer |
| Release (TRIP-3) | Prepared by implementer; **merge/tag/push = Bloodwave only** |
| TRIP-research | Green recon lane (advice-class) |

## Upstream deltas

- `[PROJECT_NAME]` placeholders replaced with `LIFEPUNCH`.
- Em-dashes in banners normalized to ASCII (comms-lane encoding incident precedent).
- Upstream shell scripts (`scripts/*.sh`, POSIX) retained as-is; they are capability,
  unused until a seat invokes them under its charter. Windows seats invoke the flow
  manually until a ratified PowerShell port lands (follow-up work, not this record).
- Skill `state/` directories keep their upstream `.gitignore` - thread state is scratch,
  never canon.

## Supersession

This record supersedes nothing; it is additive. Skill bodies may be updated by later
PRs under the normal gates. This record itself is write-once.
