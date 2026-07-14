# AGENTS.md — LIFEPUNCH grounding entry for non-Claude harnesses (Codex and any future seat)

> **`CLAUDE.md` IS THE CANON OF RECORD. READ IT IN FULL, NOW, BEFORE ANYTHING ELSE.**
> Its name is historical, not jurisdictional: the roles, seat charters, model routing, Transport
> Law, Sync Law, Sensor Law, Corner Loop, MIRROR duty, Hard rules, and the SEAT BOOT chain in that
> file govern **every** seat on **every** harness, verbatim, regardless of which file your harness
> opened first. This file exists because some harnesses read `AGENTS.md` and not `CLAUDE.md`.

**This file is a pointer, deliberately.** It does not restate CLAUDE.md and it never will. A second
copy of the law is a second law: it drifts, and the drift is silent. One source of truth, one canon,
one set of rulings. Only harness-specific notes live here — and only where the harness genuinely
differs.

**A find-replace of `CLAUDE.md` is NOT a valid AGENTS.md.** (Recorded because it was attempted: the
2026-07-13 untracked candidate had swapped every "Claude" for "Codex", inverting the seat model —
it named Codex the primary implementer, renamed Red to "Red (Codex Opus)", renamed the s&box
**Claude Bridge** to a "Codex Bridge", and pointed repo skills at a `.Codex/skills/` path that does
not exist. The seat names in CLAUDE.md are proper nouns. **Red is Claude Code. Codex is Codex.**
Preserved uncorrected at `handoff/AGENTS_MD_CORRUPT_CANDIDATE_890d402_2026-07-13.md`.)

## Grounding order (identical to CLAUDE.md's, entered from here)

```
AGENTS.md → CLAUDE.md (canon of record — read in full)
          → lifepunch/docs/cvl/boot/<SEAT>_BOOT.md
          → lifepunch/docs/START_HERE_AGENTS.md → lifepunch/docs/CVL_AGENT_ONBOARDING.md
          → lifepunch/docs/handoff/README.md → the active brief in lifepunch/docs/handoff/
```

Your seat's charter, its read order, its freshness and access checks, and the report it owes are in
your boot file. **A booting seat reports `BOOT-CLEAN` or `BOOT-FAULT`, then STOPS.**

## SKILLS-FIRST (task-start gate)

Before any task response or action, every seat consults the current applicable skills exposed by its
harness: Superpowers process skills first, then the repo's applicable `lifepunch-*` / task-domain
skills. Read the current skill body; memory is not a substitute. A missing, inaccessible, or skipped
applicable skill is reported loudly, and a skill-miss is a gradeable defect. Seat-local plugin
installation and settings remain untracked; Bloodwave performs per-harness installs.
Engine-surface work also reads **`lifepunch/docs/engine/SBOX_CONTEXT.md`** — the tracked engine
ground truth the `sbox-engine-truth` skill points at.

SUPERPOWERS PRECEDENCE (ratified 2026-07-13): Superpowers skills
are ADOPTED AS DEFAULT METHOD across seats: every seat checks for
applicable skills at task start, and a skill-miss on applicable
work is a gradeable defect. PRECEDENCE IS FIXED: CVL law >
Bloodwave two-key list > seat charter > superpowers skill. Where a
skill's workflow assumes authority a seat does not hold, the skill
applies ONLY WITHIN the seat's charter: brainstorming /
writing-plans grammar serves Fable's slice briefs and Bloodwave's
design sessions; TDD / systematic-debugging /
verification-before-completion / executing-plans /
subagent-driven-development serve Red INSIDE an authorized task
(subagents inherit Red's constraints and gain no tree authority);
requesting/receiving-code-review serve the Codex lane;
using-git-worktrees yields to the repo's branch/lane laws;
finishing-a-development-branch NEVER decides — merge, push, ship,
and destructive options remain Bloodwave's word exclusively. No
skill may weaken a proof gate, a sensor requirement, or the
Transport Law. Skills are capability, not authority.

## Harness-specific notes (the only content that belongs in this file)

- **Skill root.** Claude seats load `.claude/skills/`; non-Claude harnesses load `.agents/skills/`.
  Both are **tracked canon**, updated in the same PR — **paired surfaces, not assumed byte mirrors.**
  The bodies point at `CLAUDE.md` because that is where the law is; follow the pointer.
- **Seat-local settings stay untracked.** `.codex/`, `.claude/settings.local.json`, plugin caches,
  and install state are never committed. Per-harness plugin installs are Bloodwave console acts.
- **The Codex seat is proposal-only on the canonical tree** (CLAUDE.md → CODEX SEAT CHARTER). No
  skill, plugin, or harness affordance changes that. The relief clause is the only door, and it
  needs an explicit Bloodwave handoff.
- **OpenCode** loads this file then `CLAUDE.md`; skills from `.agents/skills/`. Authority follows
  the model (cloud frontier = implementer-eligible under relief; CORNERMAN = advisory) per
  `lifepunch/docs/cvl/OPENCODE_HARNESS_ADOPTION_2026-07-14.md`.
