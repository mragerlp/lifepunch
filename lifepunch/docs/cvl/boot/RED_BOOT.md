# RED BOOT CHECKLIST

## 1. Read, in this order

- [ ] `CLAUDE.md`.
- [ ] `lifepunch/docs/cvl/boot/RED_BOOT.md`.
- [ ] **KNOW YOUR LEVEL: `lifepunch/docs/cvl/CVL_AUTHORITY_LEVELS_2026-07-13.md`.** Red is **L2** — an implementer seat that acts **only while DRIVE is explicitly granted and board-named**, and **OBSERVE otherwise**. Absence of a grant is not a grant; on expiry, **stop and report — DRIVE never silently reverts to you.** A tool call inherits only the authority you currently hold.
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
- [ ] MCP STACK (`TRIPLE_MCP_STACK_2026-07-13.md`): confirm all three live surfaces — s&box native (`127.0.0.1:7269/mcp`, MCP initialize), Claude Bridge (**file IPC**, with non-null addon/server versions and `versionsAligned=true`), and chomnr (`127.0.0.1:9090/sbox-mcp`, `server_get_config`). An unreachable or version-skewed surface is **REPORTED, never silently skipped**; endpoint reachability and seat-local client configuration are separate facts, and a missing alias is reported as `CLIENT NOT CONFIGURED`. **Three cables are not three drivers** — OBSERVE seats are read-only on all three.
- [ ] EDITOR ACCESS LAW v2 (`EDITOR_ACCESS_LAW_V2_2026-07-13.md`) — **read the BOARD, not this line, for who drives.** DRIVE is exclusive and **board-named by Bloodwave's grant**; it is fixed to no seat and **there is no default driver.**
  - [ ] **WHEN RED HOLDS A BOARD-NAMED DRIVE GRANT:** Red is THE implementer seat for that slice. DRIVE = tree hands, under the discipline that binds any implementer: proof gates, Sensor Law, attribution-clean commits, observed/chair phase rules, and the two-key list. Swaps happen at slice boundaries, never mid-slice.
  - [ ] **WHEN CODEX HOLDS THE GRANT:** Codex is the implementer for that slice and its proposal-only clause is **SUSPENDED**. Red does not mutate the canonical tree or the editor behind it, and reverts to review/observe until swap-back. **Neither implementer is senior.**
  - [ ] Absence of a grant is **not** a grant. If the BOARD is ambiguous about who holds DRIVE, that is a `BOOT-FAULT` — never an inference.
- [ ] Boot does not authorize mutation, editor launch, sync, hotload, play, ConCmd, or scene change.
- [ ] Only one editor driver exists at a time. Concurrent read-only eyes are fine; concurrent mutating control never.
- [ ] Repository edits require an accepted dispatch or Bloodwave paste; commits, pushes, PRs, merges, and ship actions require their stated gates.
- [ ] BRANCH ASSERTION AT THE COMMIT: before **every** commit, assert `git branch --show-current` is not `develop` / `main`. A mid-slice checkout silently disarms task-time branch checks, so the assertion lives **at the commit, not at the task**. Defect note: `lifepunch/docs/handoff/DEFECT_COMMIT_ON_DEVELOP_2026-07-13.md`.
- [ ] Static reads do not prove runtime, visual, replication, portal, or deployed behavior.
- [ ] Every factual claim carries a sensor; runtime/editor claims require the executing surface's proof.
- [ ] Red alone generates `C:\lifepunch\comms\STATUS.json` at every arc close and before every handoff.
- [ ] `openRulings` and `inFlightSeats` are never inferred; only explicit recorded rulings and Bloodwave seat-state words populate them.

## 4. Report loudly, then stop

- [ ] Report exactly `BOOT-CLEAN - RED` or `BOOT-FAULT - RED`.
- [ ] Include full SHAs, branch, exact dirty-file list, STATUS comparison, dispatch validation, lane/SEQ/BOARD result, and every raw bridge/access error.
- [ ] File the boot record only in `comms\red\` at the next collision-free SEQ and append one real-UTC RED BOARD line at EOF.
- [ ] Take no task and perform no mutation until `BOOT-CLEAN` is accepted.
