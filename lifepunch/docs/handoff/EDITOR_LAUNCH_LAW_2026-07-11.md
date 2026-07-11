# EDITOR LAUNCH LAW — ratified 2026-07-11

> **Class: LIVING DOCTRINE** (ruled 2026-07-11). LAWS are living doctrine —
> amendable in place at a stable filename, like `CLAUDE.md` / `README.md`;
> RECORDS (STOP-GO, gate verdicts) freeze write-once.

## Law
Editor launch is an OBSERVED PHASE, not an attested precondition.
Red drives the launch and holds the sensors. Human attestations of
"editor up" are claims; Red's process + heartbeat sensors govern.
Ratified after the 2026-07-11 triple-dark-bridge loop (three chair
re-entries against a dead editor; sensor contradicted attestation
each time).

## Authority
Red launches or restarts the editor AUTONOMOUSLY whenever an
editor-gated task is live and the sensor shows no healthy editor —
no per-launch authorization needed. Launch command of record:
  Start-SboxDxrpEditor.ps1 -SkipPreflight -SyncAddon lpbitcoin,adminmenu
Restart = confirm old process fully exited before relaunch.
LAUNCH-SET RULE: sync the full launch set (lpbitcoin,adminmenu),
never a lone addon — a lone-addon sync purges siblings and orphans
their static hooks (2026-07-12 flood precedent). Recovery is a
full-set re-sync PLUS a fresh boot (an orphaned static hook does
not clear on hotload).
Bloodwave retains IN-SCENE setup only: pawn spawn/possession,
entity placement, powering (e.g. hub placed and powered) remain
manual and human unless a task relay states otherwise. Scene
LOADING is Red's, via bridge.

## The Launch Report (required, every launch)
1. PROCESS — sbox-dev present, pid noted.
2. FRESH STATUS — status.json startedAt postdates the launch;
   never trust a corpse file from a prior instance.
3. HEARTBEAT — bridge heartbeat age → 0 and beating;
   bridgeVersion NON-NULL.
4. COMPILE — editor log read: clean compile or full error capture.
   Compilation errors/blocks are reported verbatim, never summarized
   away.
5. WORK FRESHNESS — confirm the session compiled the CURRENT
   working tree (positive code-string ID where loggable; at minimum,
   held/modified files present in the compiled set). Stale work =
   red flag, report before proceeding.
6. VERSIONS — s&box build/version as the editor reports it;
   bridge/addon version + handler count; note any library tool or
   MCP bridge that failed to come up.
7. STABILITY — watch across several heartbeats before declaring
   GREEN. Unexplained exit (ref: 2026-07-10 ~6-minute death) =
   capture log tail, report, debug BEFORE any gated instrument runs.
8. SCENE — after GREEN on 1-7, Red DRIVES scene load via the
   bridge: blank.scene for fast proofs (canon proof environment)
   or the task's stated scene (e.g. game/map). Attest the loaded
   scene by name from the editor sensor, not assumption. A launch
   without a driven scene is INCOMPLETE.

GREEN = all seven attested. Only then may an editor-gated
instrument (chair, drive, probe, sync gate) begin.

## Compile gotchas (s&box razor) — augments Launch Report item 4
Ratified 2026-07-11 after a full-class-collapse debug on
LpHashdPanel.razor (batch 4).
- ADJACENT `@(...)` LAW: never place two `@(...)` expressions
  back-to-back in ONE razor attribute
  (`class="x @(A)@(B)"`). s&box's transpiler concatenates them
  as `(A)(B)` with NO `+`, emitting invalid C# — one syntax
  error that orphans downstream `else` blocks and collapses the
  WHOLE generated class to top-level statements. Merge into a
  single expression: `@( (A) + (B) )`. (Sensor: the true first
  error was `) expected` at the gen-file line, buried under the
  cascade.)
- CASCADE-DEBUG LAW: on a "declared in a top-level statement" /
  "X does not exist in the current context" cascade, the class
  wrapper broke — hunt the FIRST error in the `_gen_*.razor.cs`
  file, not the tail. `get_compile_errors` windows the LAST N
  lines, which masks the true root; grep the gen-file line
  numbers ascending and read the earliest error's MESSAGE (it
  names the real syntax fault). The tail is all downstream noise.
- `@code` STAYS ASCII: non-ASCII in a `@code` block is a
  documented transpiler crasher (sensor: `razor_lint`). Escape
  display glyphs as `\uXXXX` (identical runtime), keep comments
  ASCII.

## Manual-launch fallback
If Red cannot launch (tool failure, permission, environment), Red
provides Bloodwave a FRESH copy-pasteable command or shortcut spec
in the same message — never a bare request to "launch the editor."
A request without a runnable artifact is malformed.

## Scope
Applies to LIFEPUNCH monorepo work and DXRP upstream work alike —
any s&box editor session in the CVL.

## Freshness Rule (per-instrument, two axes)
Item 5 attests freshness at LAUNCH only. Before ANY editor-gated
instrument runs, and before acting on any new "fix X / add Y"
instruction against a running editor, Red re-asserts BOTH:

AXIS 1 — COPY: the loaded assembly reflects the current working
tree (member probe, hotload log postdating the last edit, or
compile-hash match). Stale/unprovable = report, never drive
against an unverified copy.

AXIS 2 — BASELINE: the working tree sits on the correct base
for the task's lane, sensor-verified (git merge-base/ancestry +
status):
  · DXRP UPSTREAM (Dimmer) lane: clean tree on dxura/dxrp at
    the latest fetched upstream tip — ZERO lifepunch additions;
    framework only. Any LP-layer file present = STOP, report.
  · LIFEPUNCH lane: tree based on the current OPERATIONAL PIN
    (per the standing re-pin ruling), LP layer on top. Base
    behind the pin, or pin stale vs. ruling = report before work.
Wrong-lane or drifted base = the wrong-copy trap; one cheap
sensor read replaces the expensive failure of building on it.

Lane declaration is Bloodwave's alone: DXRP UPSTREAM lane
activates only on an explicit "Dimmer work" declaration in the
task relay; absent that, the lane is LIFEPUNCH. Seats verify
the declared lane's base; they never infer the lane.

## Session Start Rule (seat-driven sync)
At every session bootstrap, BEFORE filing the arrival report,
each Code seat runs and reports:
  · lifepunch: git fetch origin; pull current branch if
    fast-forward clean. Diverged or dirty-tree conflict = report,
    do not force.
  · dxrp-public: git fetch origin AND git fetch upstream
    (dxura/dxrp). Report both tips + behind-counts. FETCH ONLY
    on the upstream remote — merging upstream is exclusively
    the gated re-pin lane; never auto-merge, never advise the
    GitHub web "Sync fork" button.
Arrival reports carry the resulting heads as sensors. Bloodwave
performs NO manual fetch/pull as a session precondition; any
human git action via GitHub Desktop or web UI is optional
convenience on origin only, and NEVER upstream-facing on
dxrp-public.
Odysseus mirrors this rule on Green's clones.
