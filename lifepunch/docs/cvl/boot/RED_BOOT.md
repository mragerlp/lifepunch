# RED BOOT CHECKLIST

## 1. Read, in this order

- [ ] `CLAUDE.md`.
- [ ] `lifepunch/docs/cvl/boot/RED_BOOT.md`.
- [ ] `lifepunch/docs/cvl/STACK_ARCHITECTURE.md`.
- [ ] `lifepunch/docs/cvl/COMMS_LANE.md`.
- [ ] `lifepunch/docs/cvl/STATUS_JSON_SCHEMA.md`.
- [ ] `C:\lifepunch\comms\STATUS.json` and the EOF tail of `BOARD.md`.
- [ ] The last three Red records selected by BOARD append-order.
- [ ] `C:\lifepunch\comms\COMMS_PROTOCOL.md` and `STACK_ARCHITECTURE.md`.
- [ ] The candidate dispatch in `comms\dispatch\red\`, if one exists.

## 2. Run freshness and access checks

- [ ] Run a non-forcing fetch. Do not pull, merge, switch, clean, reset, or edit.
- [ ] Record full `HEAD`, local branch, local `develop`, and `origin/develop` SHAs.
- [ ] Run `git status --porcelain=v1 --untracked-files=all`; compare exact entries with `STATUS.json.dirtyFiles`.
- [ ] Confirm `STATUS.json` parses and its checkpoint matches the declared handoff state.
- [ ] Confirm any dirty state is completely declared, including intended and forbidden files. Any unexplained delta is `BOOT-FAULT`.
- [ ] Confirm Red lane read/write access, BOARD EOF access, next Red SEQ, and no SEQ collision. Do not create a probe file.
- [ ] Validate a candidate dispatch's Fable authorship, exact authorization header, and matching FABLE BOARD entry. Missing any key is `BOOT-FAULT`; the file is not a work order.

## 3. Confirm governing facts

- [ ] Confirm installed plugins conform to `CONSOLE_PLUGINS_DOCTRINE`; report any plugin not classified there. An unclassified plugin is used **advisory-only** until classified by ruling.
- [ ] TRACKED SKILLS: confirm the seat-applicable repo `lifepunch-*` skills are exposed and readable in this harness. These are **tracked canon** — missing or inaccessible is `BOOT-FAULT`, reported loudly. Never self-install.
- [ ] SUPERPOWERS CHECK (`SUPERPOWERS_DOCTRINE.md` §3): (a) confirm the meta-skill is active — hook-injected on a Claude harness, exposed in the manifest on Codex; (b) report the count of available superpowers skills (expect 14); (c) state `skill-check discipline in force`. The plugin is **console install state, not tracked canon**: inactive on a Claude harness is `BOOT-FAULT`; where the skill is plugin-provided and absent, REPORT-AND-HOLD for Bloodwave. A boot never hard-faults a harness for a plugin Bloodwave has not installed there, and never self-installs.
- [ ] At every accepted task start, consult applicable Superpowers process skills first and applicable repo skills second, under `SUPERPOWERS PRECEDENCE` and the `SUPERPOWERS_DOCTRINE` skill map; a skill-miss is a gradeable defect.
- [ ] HOOK HEALTH: run one no-op tool call and report whether any `PreToolUse` / `PostToolUse` hook errored. Report a failing hook by `file:line` and owning plugin; **never patch a plugin's files** — hooks are Class C standing rules and repair needs a Bloodwave GO naming the hook.
- [ ] Red is the sole canonical-tree implementer and default editor DRIVE authority.
- [ ] Boot does not authorize mutation, editor launch, sync, hotload, play, ConCmd, or scene change.
- [ ] Only one editor driver exists; Codex observation never grants Codex mutation authority.
- [ ] Repository edits require an accepted dispatch or Bloodwave paste; commits, pushes, PRs, merges, and ship actions require their stated gates.
- [ ] Static reads do not prove runtime, visual, replication, portal, or deployed behavior.
- [ ] Every factual claim carries a sensor; runtime/editor claims require the executing surface's proof.
- [ ] Red alone generates `C:\lifepunch\comms\STATUS.json` at every arc close and before every handoff.
- [ ] `openRulings` and `inFlightSeats` are never inferred; only explicit recorded rulings and Bloodwave seat-state words populate them.

## 4. Report loudly, then stop

- [ ] Report exactly `BOOT-CLEAN - RED` or `BOOT-FAULT - RED`.
- [ ] Include full SHAs, branch, exact dirty-file list, STATUS comparison, dispatch validation, lane/SEQ/BOARD result, and every raw bridge/access error.
- [ ] File the boot record only in `comms\red\` at the next collision-free SEQ and append one real-UTC RED BOARD line at EOF.
- [ ] Take no task and perform no mutation until `BOOT-CLEAN` is accepted.
