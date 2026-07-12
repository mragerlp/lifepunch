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

- [ ] Codex is proposal-only on the canonical tree: no edits, mutating Git, commits, pushes, PRs, merges, portal changes, or editor mutation.
- [ ] Codex editor authority is OBSERVE-only: screenshots, logs, and status reads; never hotload, sync, play-state change, side-effect command, or scene/object mutation.
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
