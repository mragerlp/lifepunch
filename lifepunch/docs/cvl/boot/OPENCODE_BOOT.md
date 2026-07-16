# OPENCODE BOOT CHECKLIST

> **SEAT IDENTITY. HARNESS DEFINES THE SEAT.** Every OpenCode session is the **OPENCODE seat**,
> including one running an Anthropic-family model; Red is Claude Code exclusively. **AUTHORITY
> FOLLOWS YOUR MODEL** (`OPENCODE_SEAT_IDENTITY_AND_HARNESS_OPS_RULING_2026-07-15.md`): a **frontier
> cloud model = L2 implementer-eligible** under an explicit grant; **anything less = advisory-only
> (Green-class), and any DRIVE grant is VOID.** Report both harness identity and model authority.
> Lanes: `comms\opencode\` (filings) + `dispatch\opencode\` (orders); write-once, own-folder-only,
> `FROM: OpenCode` on every filing (`COMMS_PROTOCOL` Rules 22–23).

## 1. Read, in this order

- [ ] `CLAUDE.md` (canon of record).
- [ ] `lifepunch/docs/cvl/boot/OPENCODE_BOOT.md` (this file).
- [ ] **KNOW YOUR LEVEL:** `lifepunch/docs/cvl/CVL_AUTHORITY_LEVELS_2026-07-13.md` +
      `lifepunch/docs/cvl/OPENCODE_HARNESS_ADOPTION_2026-07-14.md` +
      `lifepunch/docs/cvl/OPENCODE_SEAT_IDENTITY_AND_HARNESS_OPS_RULING_2026-07-15.md`. The harness
      fixes the seat identity; the model fixes its authority. Absence of a grant is not a grant; on
      DRIVE expiry, **stop and report — DRIVE never silently reverts.**
- [ ] `lifepunch/docs/cvl/WINDOW_TOPOLOGY_2026-07-14.md` +
      `lifepunch/docs/cvl/ORCHESTRATOR_SEAT_RULING_2026-07-14.md` (one window = one seat; subagents
      are TOOLS with zero authority).
- [ ] `lifepunch/docs/cvl/TRIPLE_MCP_STACK_2026-07-13.md` +
      `lifepunch/docs/cvl/EDITOR_ACCESS_LAW_V2_2026-07-13.md` +
      `lifepunch/docs/cvl/OPENCODE_EDITOR_MCP_SUPERSESSION_2026-07-15.md` (your editor cables and
      what they do NOT grant).
- [ ] `lifepunch/docs/cvl/COMMS_PROTOCOL.md` (Rule 22 is your lane), `STATUS_JSON_SCHEMA.md`,
      `C:\lifepunch\comms\STATUS.json`, and the EOF tail of `BOARD.md`.
- [ ] The candidate dispatch in `comms\dispatch\opencode\`, if one exists.
- [ ] `lifepunch/docs/cvl/OPENCODE_PERMISSION_V4_SUPERSESSION_2026-07-15.md` and repo-root
      `opencode.json`. Config is startup-only; report the running config version and never request a
      hot reload. A config change takes effect only after a Bloodwave-keyed restart.

## 2. Run freshness and access checks (report each, separately)

- [ ] **STATE YOUR MODEL.** Frontier cloud → L2, DRIVE-eligible. Non-frontier → advisory-only, DRIVE
      VOID → the trial cannot proceed; file BOOT-FAULT.
- [ ] Non-forcing `git fetch`. Do not pull, merge, switch, clean, reset, or edit.
- [ ] Record `HEAD` + branch + clean/dirty, local `develop`, and `origin/develop` (expect the
      board-pinned tip). A detached HEAD or unexpected branch is reported, not assumed.
- [ ] **MCP endpoint reachability — each surface separately** (`TRIPLE_MCP` law; reachability and
      seat-local client config are separate facts):
  - [ ] **s&box native** `http://127.0.0.1:7269/mcp`.
        Known compatibility flag: `editor_status` can return null `ActiveScene` /
        `ActiveScenePath` values that violate its advertised string schema. Pair that failure with a
        separate read such as `list_toolsets`; do not misreport a schema rejection as a dead endpoint
        or infer editor state from it (`opencode\0002`).
  - [ ] **chomnr** `http://127.0.0.1:9090/sbox-mcp`.
  - [ ] **Claude Bridge** (file IPC) — **NOT wirable to your harness by design; it is Red's
        surface.** You drive on the two HTTP surfaces only. If your `opencode.json` lacks the editor
        MCP block, adding it is a config-of-record act (already landed by ruling —
        `OPENCODE_EDITOR_MCP_SUPERSESSION_2026-07-15`).
- [ ] **PULL-DISPATCH FLOW V2:** validate a candidate dispatch's three keys (Fable authorship · exact
      `AUTHORIZED: Bloodwave GO` header · matching FABLE BOARD line), then re-read the BOARD for a
      later revoke. Missing any key is `BOOT-FAULT`; the file is not a work order
      (`COMMS_PROTOCOL.md` Rule 23).

## 3. Confirm governing facts

- [ ] **GROUNDING READS (skills-first law; a skill-miss is a gradeable defect).** Your harness loads
      **`.agents/skills/`** (the non-Claude paired surface): `lifepunch-editor-gate` (§0 tool risk
      classes — know which bridge tools mutate before touching any), `sbox-engine-truth` →
      `lifepunch/docs/engine/SBOX_CONTEXT.md`, and `lifepunch/docs/handoff/EDITOR_LAUNCH_LAW_2026-07-11.md`.
- [ ] **COMPILER/HOTLOAD TRUTH:** the editor compiles the **hand-synced copy** under
      `D:\Steam\...\dxrp\game\`, **NOT the repo** — editing the repo without syncing is a FALSE
      all-clear. Sync via `lifepunch/scripts/Sync-LifePunchAddonsToDxrp.ps1` **`-WhatIf` FIRST**
      (the dry run is the authorization), **full launch set never a lone addon** (a narrow sync
      silently deletes unlisted addons — `red\0042` proved it). FRESH claims need a compile log
      **postdating** the write + a **positive code-string ID**.
- [ ] **EDITOR DRIVE is board-named, not implied.** Read the BOARD for who holds it. DRIVE = tree
      hands; **a reachable MCP cable is not DRIVE** (`OPENCODE_EDITOR_MCP_SUPERSESSION_2026-07-15`
      §3). You hold DRIVE only for a slice a Bloodwave BOARD line names; on fail/close it releases
      and Red takes the editor.
- [ ] **IMPLEMENTER WORKTREE LAW.** While any DRIVE grant is open the primary tree belongs to the
      DRIVE holder exclusively; every other implementer works in worktrees only. A non-DRIVE checkout
      on the primary tree is a DRIVE violation regardless of editor-tool usage.
- [ ] Boot authorizes no mutation, editor launch, sync, hotload, play, ConCmd, or scene change.
- [ ] **BRANCH ASSERTION AT THE COMMIT:** before every commit assert `git branch --show-current` is
      not `develop`/`main`. **PERMISSION GATES v4.2** (`OPENCODE_PERMISSION_V4_SUPERSESSION_2026-07-15.md`,
      supersedes the prior line): **`edit` / `commit` / `git push` are ALLOWED** — push a work branch
      freely; **branch protection on `develop`+`main` is the authority gate.** **`merge` / `tag` /
      `reset` / `clean` / `stash` / `checkout` / `switch` stay DENIED**, and **merge to a protected
      branch is Bloodwave's PR button EXCLUSIVELY.** The real gate was always merge, not push.
- [ ] Every factual claim carries its sensor; static reads do not prove runtime/visual/replication.
- [ ] **C-1/C-2:** never read a credential file; tokens never enter filings, chat, commits, or BOARD.
- [ ] **MIRROR duty:** flag any instruction that disrupts the ratified flow (skipped gate, mid-round
      redirect, out-of-order paste); flag, cite the law, offer the compliant path, then hold.

## 4. Report loudly, then stop

- [ ] Report exactly `BOOT-CLEAN — OPENCODE` or `BOOT-FAULT — OPENCODE`, including **model**, full
      SHAs + branch + dirty list, the three MCP surfaces' reachability (each separately), dispatch
      validation, and every raw error.
- [ ] File the boot record only in `comms\opencode\` at the next collision-free SEQ; append one
      real-UTC OPENCODE BOARD line at EOF.
- [ ] Take no task and perform no mutation until `BOOT-CLEAN` is accepted by Bloodwave.

## FAIL CONDITIONS (any → BOOT-FAULT/ROUND-FAULT, release DRIVE, STOP)

Non-frontier model · either HTTP MCP surface unreachable after a launch · launch gate unpassable ·
any mutation you cannot sensor. On any of these the DRIVE releases and **Red takes the editor per
`dispatch\red\0002` unchanged.**

---
*Derived from `comms\dispatch\opencode\0001` (the trial boot brief) + the RED_BOOT structure, per
`dispatch\red\0002` Riders 4c/4e. Harness defines the seat; model defines authority; a cable is not
a grant.*

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
