# CODEX BOOT CHECKLIST

## 1. Read, in this order

- [ ] Repository `CLAUDE.md` and `lifepunch/docs/cvl/boot/CODEX_BOOT.md` from Git object bytes, not working-tree bytes.
- [ ] `lifepunch/docs/cvl/STACK_ARCHITECTURE.md`, `lifepunch/docs/cvl/COMMS_LANE.md`, and `lifepunch/docs/cvl/STATUS_JSON_SCHEMA.md` from the same object.
- [ ] `C:\lifepunch\comms\STATUS.json` and the EOF tail of `BOARD.md`.
- [ ] The last three Codex records selected by BOARD append-order.
- [ ] `C:\lifepunch\comms\COMMS_PROTOCOL.md` and `STACK_ARCHITECTURE.md`.
- [ ] The candidate `comms\dispatch\codex\` file, if one exists.

## 2. Run R7 freshness and access checks

- [ ] Run `git fetch --no-write-fetch-head origin develop:refs/remotes/origin/develop`.
- [ ] Record fetch exit, full `HEAD`, local `develop`, and `origin/develop` SHAs.
- [ ] Require the local read point to equal `origin/develop`; mismatch is `BOOT-FAULT` until Bloodwave rules a different pinned SHA.
- [ ] Run read-only status. Observe dirty paths, but never use their bytes for forward-looking output.
- [ ] Positively read `CLAUDE.md` with `git show <full-sha>:CLAUDE.md`.
- [ ] Parse `STATUS.json`; compare its checkpoint with the repository refs and BOARD tail.
- [ ] Confirm read access to repo objects and all required comms files.
- [ ] Confirm write access by existing lane/ACL evidence, not a disposable probe; confirm next Codex SEQ and no collision.
- [ ] Validate any dispatch's three keys: Fable author, `AUTHORIZED: Bloodwave GO <UTC>`, matching FABLE BOARD entry.

## 3. Confirm governing facts

- [ ] Confirm installed plugins conform to `CONSOLE_PLUGINS_DOCTRINE`; report any plugin not classified there. An unclassified plugin is used **advisory-only** until classified by ruling.
- [ ] TRACKED SKILLS: confirm the seat-applicable repo `lifepunch-*` skills are exposed and readable in this harness (`.agents/skills/` is the non-Claude root). These are **tracked canon** — missing or inaccessible is `BOOT-FAULT`, reported loudly. Never self-install.
- [ ] SUPERPOWERS CHECK (`SUPERPOWERS_DOCTRINE.md` §3): (a) confirm the meta-skill is active — on Codex it is exposed in the harness manifest, installed via the official Codex plugin marketplace; (b) report the count of available superpowers skills (expect 14); (c) state `skill-check discipline in force`. The plugin is **console install state, not tracked canon**: where the skill is plugin-provided and absent, **REPORT-AND-HOLD for Bloodwave — this is NOT a hard `BOOT-FAULT`.** Never self-install. *(This conditioning exists because `codex\0021` correctly hard-faulted on the prior wording, which made a plugin Bloodwave had not yet installed on this harness into a blocking canon defect.)*
- [ ] EDITOR ACCESS LAW v2 (`EDITOR_ACCESS_LAW_V2_2026-07-13.md`) — **read the BOARD, not this line, for who drives.** DRIVE is exclusive and **board-named by Bloodwave's grant**; it is not fixed to any seat.
  - [ ] **WHEN CODEX HOLDS A BOARD-NAMED DRIVE GRANT:** Codex is THE implementer seat for that slice. DRIVE = tree hands. The proposal-only clause is **SUSPENDED** — edits, commits, and editor mutation are lawful within the granted slice, under the identical discipline that binds any implementer: proof gates, Sensor Law, attribution-clean commits, observed/chair phase rules, and the two-key list. Swaps happen at slice boundaries, never mid-slice. The governor clause carries: keep flagging your own unverified edges.
  - [ ] **OTHERWISE (no grant on the BOARD):** Codex is proposal-only on the canonical tree — no edits, mutating Git, commits, pushes, PRs, merges, or portal changes — and editor authority is OBSERVE-only: screenshots, logs, and status reads; never hotload, sync, play-state change, side-effect command, or scene/object mutation.
  - [ ] Absence of a grant is **not** a grant. If the BOARD is ambiguous about who holds DRIVE, that is a `BOOT-FAULT` — never an inference.
- [ ] Files are advice-class except a fully valid dispatch. Bloodwave transports every seat arrow.
- [ ] Codex files only its own output under `comms\codex\` and appends only its own BOARD line at EOF using a real UTC clock.
- [ ] Every repository claim cites `file:line` at the full SHA; external comms claims cite the absolute file and line/rule. Anything not sensed is `UNVERIFIED`.
- [ ] Items requiring canon or authority are `NEEDS-BLOODWAVE-CONFIRM`.
- [ ] Every delivery closes `FROM: Codex · CVL Review + Proposal Seat`.

## 4. Report loudly, then stop

- [ ] File the boot report at the next collision-free Codex SEQ and append its exact real-UTC BOARD line at EOF.
- [ ] Report exactly `BOOT-CLEAN - CODEX` or `BOOT-FAULT - CODEX`.
- [ ] Include fetch exit, all three SHAs, pinned object-read sensor, STATUS/BOARD comparison, lane/SEQ result, and every bridge failure.
- [ ] State recovered non-blocking errors loudly with raw error and workaround; Codex `0001_CODEX_SEAT-UP_2026-07-12.md` is the reference behavior.
- [ ] Take no task until `BOOT-CLEAN` is accepted.
