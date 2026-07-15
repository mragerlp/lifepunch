# OPENCODE SEAT IDENTITY + HARNESS OPERATIONS RULING — 2026-07-15

**STATUS: RATIFIED — Bloodwave.** Source: `dispatch\red\0002` Rider 4(e), carried into
GitHub Issue #117 and re-authorized for the issue-centric lane on 2026-07-15.

> **CLASS: RULED. Write-once.** Supersede with a new record citing this filename; do not edit this
> record in place.

This record packages the Rider 4(e) substance that was only partially represented by the OpenCode
adoption, permission, editor-MCP, and boot records. Those records remain history. Where their older
wording conflicts with this ruling, this companion record governs.

## 1. Harness defines the seat; model defines its authority

- **An OpenCode session is the OPENCODE seat regardless of the model or provider behind it.** That
  includes Anthropic-family frontier models served through OpenCode. Switching models does not turn
  the session into Red, Codex, Green, or another seat.
- **Red is Claude Code, exclusively.** A Claude-family model running inside OpenCode is still the
  OPENCODE seat.
- **Authority still follows the model.** A frontier cloud model is L2 implementer-eligible under an
  explicit Bloodwave grant; a CORNERMAN local model is advisory-only. Harness identity and model
  authority are separate facts and both belong in the boot report.
- One seat per tree and one board-named editor DRIVE holder remain absolute. A cable, model switch,
  subscription, or dispatch folder grants neither a second seat nor DRIVE.

This narrows the phrase *“authority follows the model, not the harness”* in
`OPENCODE_HARNESS_ADOPTION_2026-07-14.md`: it describes **authority only**, never seat identity.

## 2. Upstream, version, billing, and config canon

- **Upstream:** `anomalyco/opencode` is the canonical OpenCode upstream. The former `sst` ownership
  is historical, not the current pin.
- **Trial version:** the editor trial was frozen on installed OpenCode `1.17.20`; no mid-trial update
  was allowed. Any later upgrade is its own Bloodwave console slice: read the changelog, update
  VENGEANCE, re-verify that the MCP and permission config survived, then update CORNERMAN.
- **Billing identity:** the OPENCODE seat uses the OpenCode subscription/Zen billing lane for models
  served by that plan, including Anthropic-family models. Billing never changes seat identity or
  authority.
- **Config of record:** repo-root `opencode.json`. OpenCode loads it at process startup; a config
  edit requires a Bloodwave-keyed harness restart. No boot or dispatch may ask the seat to hot-reload
  this file.

Sensors: lane record `fable\0083` (OpenCode upstream/version canon, 2026-07-15) records the
machine-read upstream and version facts; `comms\opencode\0001` and `0005` record the startup-only
config behavior across the trial restart.

## 3. Boot, dispatch, permission, and tree packaging

- OpenCode enters through `AGENTS.md`, then reads `CLAUDE.md` and
  `lifepunch/docs/cvl/boot/OPENCODE_BOOT.md`.
- `COMMS_PROTOCOL.md` Rules 22–23 govern the OPENCODE lane and Pull-Dispatch Flow v2. A file in
  `dispatch\opencode\` is only a work order when all three keys are present: Fable authorship,
  `AUTHORIZED: Bloodwave GO`, and a matching FABLE BOARD line. The seat rechecks the BOARD for a
  revoke before acting.
- Rule 25 governs tree placement: while any editor DRIVE is open, a non-DRIVE implementer uses an
  isolated worktree and never checks out the primary tree.
- `OPENCODE_PERMISSION_V4_SUPERSESSION_2026-07-15.md` governs the v4.2 config: edit, commit, work-
  branch push, and skills are allowed; merge/tag/reset/clean/stash/checkout/switch remain denied;
  external-directory access remains ask-gated. Protected-branch merge remains Bloodwave's PR button.

The authorized dispatch named an `AGENTS.delta` file in the opencode lane as an input. That file was absent at
packaging time. No missing prose is inferred: the four named effects above are carried literally by
`dispatch\red\0002` and are independently present in tracked `COMMS_PROTOCOL.md` Rules 22–25.

## 4. Native `editor_status` compatibility flag

The native s&box HTTP MCP endpoint is live, but its `editor_status` response can return
`ActiveScene: null` and `ActiveScenePath: null` while the advertised output schema requires strings.
OpenCode therefore rejects that result during null-scene states. This is a **tool output-schema
compatibility defect**, not proof of a dead endpoint and not permission to infer editor state.

Sensors: lane record `opencode\0002` (T0 live editor probe, 2026-07-15) records the rejected null
payload and a clean `list_toolsets` call on the same endpoint; `opencode\0005` records the anomaly
persisting after restart.

## 5. Related canon

- `OPENCODE_HARNESS_ADOPTION_2026-07-14.md` — original model-tier adoption.
- `OPENCODE_EDITOR_MCP_SUPERSESSION_2026-07-15.md` — native + chomnr wiring; cable is not DRIVE.
- `OPENCODE_PERMISSION_V4_SUPERSESSION_2026-07-15.md` — v4.2 permission ruling.
- `COMMS_PROTOCOL.md` Rules 22–26 — lane, dispatch, worktree, and issue-centric workflow.

FROM: Bloodwave ruling, packaged by the Issue #117 authorized implementer lane
