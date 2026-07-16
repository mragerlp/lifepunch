# CODEX BOOT CHECKLIST

## 1. Read, in this order

- [ ] Repository `CLAUDE.md` and `lifepunch/docs/cvl/boot/CODEX_BOOT.md` from Git object bytes, not working-tree bytes.
- [ ] **KNOW YOUR LEVEL: `lifepunch/docs/cvl/CVL_AUTHORITY_LEVELS_2026-07-13.md`.** Codex is **L2** — an implementer seat that acts **only while DRIVE is explicitly granted and board-named**, and **OBSERVE otherwise** (proposal-only on the canonical tree). Absence of a grant is not a grant; on expiry, **stop and report — DRIVE never silently reverts to you.** A tool call inherits only the authority you currently hold.
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
- [ ] MCP STACK (`TRIPLE_MCP_STACK_2026-07-13.md`): confirm all three live surfaces — s&box native (`127.0.0.1:7269/mcp`, MCP initialize), Claude Bridge (**file IPC**, with non-null addon/server versions and `versionsAligned=true`), and chomnr (`127.0.0.1:9090/sbox-mcp`, `server_get_config`). An unreachable or version-skewed surface is **REPORTED, never silently skipped**; endpoint reachability and seat-local client configuration are separate facts, and a missing alias is reported as `CLIENT NOT CONFIGURED`. **Three cables are not three drivers** — without a grant Codex is OBSERVE-only on all three. *(Codex's MCP client wiring lives in `~/.codex/config.toml` and is a Bloodwave console act; no seat edits another seat's local config.)*
- [ ] EDITOR ACCESS LAW v2 (`EDITOR_ACCESS_LAW_V2_2026-07-13.md`) — **read the BOARD, not this line, for who drives.** DRIVE is exclusive and **board-named by Bloodwave's grant**; it is not fixed to any seat.
  - [ ] **WHEN CODEX HOLDS A BOARD-NAMED DRIVE GRANT:** Codex is THE implementer seat for that slice. DRIVE = tree hands. The proposal-only clause is **SUSPENDED** — edits, commits, and editor mutation are lawful within the granted slice, under the identical discipline that binds any implementer: proof gates, Sensor Law, attribution-clean commits, observed/chair phase rules, and the two-key list. Swaps happen at slice boundaries, never mid-slice. The governor clause carries: keep flagging your own unverified edges.
  - [ ] **OTHERWISE (no grant on the BOARD):** Codex is proposal-only on the canonical tree — no edits, mutating Git, commits, pushes, PRs, merges, or portal changes — and editor authority is OBSERVE-only: screenshots, logs, and status reads; never hotload, sync, play-state change, side-effect command, or scene/object mutation.
  - [ ] Absence of a grant is **not** a grant. If the BOARD is ambiguous about who holds DRIVE, that is a `BOOT-FAULT` — never an inference.
- [ ] BRANCH ASSERTION AT THE COMMIT (binds Codex whenever it holds DRIVE): before **every** commit, assert `git branch --show-current` is not `develop` / `main`. A mid-slice checkout silently disarms task-time branch checks, so the assertion lives **at the commit, not at the task**. Defect note: `lifepunch/docs/handoff/DEFECT_COMMIT_ON_DEVELOP_2026-07-13.md`.
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

## BRIDGE VERSION GATE (amended 2026-07-14 — `red\0032` closed at the only place we own it)

**Run `lifepunch/scripts/Assert-BridgeVersion.ps1` on the bridge status. Exit 0 is the pass. Nothing else is.**

### ## ABSENCE OF A VERSION IS A **FAILURE**, NOT A PASS.

`versionsAligned` is computed as `bridgeVersion == mcpServerVersion`. **When the editor is dead, BOTH are
`null`, and `null == null` is TRUE.** The boolean reads **GREEN over a corpse.** It fired falsely **twice
on 2026-07-14**, and on the second occasion it would have carried a seat into an editor-gated task
believing it held proof.

**WE DO NOT OWN THE BRIDGE.** `versionsAligned` lives in a third-party plugin and has **zero hits in this
repo** — *it cannot be patched from here.* **So the fix lives at the only place the lie can reach us: the
seat that reads it.** The gate asserts **positive presence** of both versions, then equality, then
liveness — **in that order, because comparing two absences is how the original defect passed.**

> ## **ASSERT THE NON-NULL `bridgeVersion`. NEVER READ THE BOOLEAN.**
> A `versionsAligned: true` accompanied by a gate FAIL is **the defect firing**, and the gate says so out
> loud rather than shrugging.

**This is the GREEN-BY-OMISSION family stated as a gate:** *a check that cannot distinguish "I verified it
and it is fine" from "I could not verify it" **is not a check.***

---

## EDITOR BOOT COMPILE-CLEAN LAW v1.1 (ratified Bloodwave 2026-07-16 — `fable\0099` + `fable\0100`; landed via `dispatch\red\0008` Slice F)

Binds every implementing seat under EDITOR DRIVE — **Red, OpenCode, Codex, and Cursor/Cursor-CLI juniors.**

1. Any implementing seat launching the editor must reach a CLEAN launch (**0 compile errors**) before deep
   work proceeds. A blocked launch is part of YOUR round — never a stall condition. **Never idle-wait on a
   compile error:** fix it or STOP-and-file, within the round.
2. Triage on errors:
   - **a. Caused by your own branch** → fix in-slice, normal diff.
   - **b. Pre-existing at tip** → fix real-time in a minimal, separately-labeled COMPILE-UNBLOCK commit on
     your branch; cite every error fixed (file:line + message) in the round filing.
   - **c. Fix would touch a fenced or gated surface** (lpbitcoin do-not-touch set, gated S4 surfaces,
     another seat's open branch) → **STOP + MIRROR** with the exact error text. No seat pushes through a
     fence to get a green editor.
   - **d. Errors in third-party editor libraries** (any path under `game\Libraries\`, not repo-synced code):
     1. **UPDATE first** — if the library manager offers a fixed version, take it.
     2. **Else QUARANTINE** — move the broken package folder out of `game\Libraries\` to a dated
        `_quarantine\` sibling (or disable via config). Expendable-by-default for LIFEPUNCH sessions:
        `supershot`, `shader_graph_extras`, `humanoid_retargeter`, and any lib not on the agent-tooling list.
     3. **Agent-tooling libs** (currently: `notpointless.chomnr_mcp` = sbox-editor MCP) — attempt a MINIMAL
        local shim first (e.g. a single removed enum member swapped for a live one); local Steam-path state
        only, never repo-committed. If the shim is not trivial, quarantine it too and fall back to the
        Claude Bridge file-IPC MCP; state the capability loss in the filing.
     4. **FILE what was touched:** package names, versions, action taken (updated/quarantined/shimmed), so
        the editor state is reproducible and reversible.
     No PR, no fence question — this class is **local editor state.**
3. Any round filing claiming editor proof must state the **compile sensor (0 errors + editor PID).** No
   clean-launch claim without it.
4. Applies to every implementing seat under EDITOR DRIVE — Red, OpenCode, Codex, and Cursor/Cursor-CLI
   juniors.

> **GREEN-BY-OMISSION corollary:** "the editor is up" is not "the editor compiled clean." Only the compile
> sensor (0 errors + PID) distinguishes them.
