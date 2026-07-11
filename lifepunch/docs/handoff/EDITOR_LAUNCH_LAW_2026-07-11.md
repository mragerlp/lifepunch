# EDITOR LAUNCH LAW — ratified 2026-07-11

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
Bloodwave retains the scene: pawn, map, hub placement/power are
manual and human. Red never claims scene state — only editor state.

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

GREEN = all seven attested. Only then may an editor-gated
instrument (chair, drive, probe, sync gate) begin.

## Manual-launch fallback
If Red cannot launch (tool failure, permission, environment), Red
provides Bloodwave a FRESH copy-pasteable command or shortcut spec
in the same message — never a bare request to "launch the editor."
A request without a runnable artifact is malformed.

## Scope
Applies to LIFEPUNCH monorepo work and DXRP upstream work alike —
any s&box editor session in the CVL.
