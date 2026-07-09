# Engine update record — s&box SDK events

Status: LIVING RECORD — one entry per engine update that touches CVL machines.
Companion: `SBOX_LIBRARY_PLAYBOOK.md` (stack law) · `lifepunch/config/cvl-stack-pins.json`
(pins) · `DISCORD_CHANGELOG_ROUTINE.md` (player-facing comms).

Entry discipline: date · build · what Facepunch shipped (triage verdict, not the full
changelog) · what CVL did (fleet sequence, holds, re-verification) · flags for future passes.

---

## 2026-07-08 — Update 26.07.08(b)

**SDK:** editor bumped to Steam build `24117881` (Red). **Fleet:** both Blue instances
bumped to 26.07.08b — canary sequence used, hold mechanism exercised. Library tools
updated same night (one library version delta: `fish.shrimple_ragdolls`
1.0.306729→1.0.308028; 26/27 unchanged — re-pinned in the manifest).

**Triage verdict (changelog vs our ground):** NO serialization/persistence impact —
nothing in the update touches GameObject serialization, snapshots, `[Property]`/`[Sync]`,
or FileSystem. Slice-1 code compiled clean on the new SDK first boot (clean-pull test,
engine edition). Post-update battery: bridge v1.20.0 aligned, 27/27 libraries, harness
live-fired.

**Flagged for future passes (note-only, no work started):**
- **Parent-game addon targeting** ("Target/Parent Game" in Project Settings) — first-class
  engine support for addons targeting DXRP; potential reshape of the publish lane
  (`DXRP_ADDON_PUBLISH_DOCTRINE`, sync scripts, portal listing). Future design pass.
- **Official editor MCP server** — first-party sibling to the curated stack; audit queued
  (playbook OPEN ITEMS). No stack change without owner GO.
- **Native inventory + weapon system** — flag for the parked weapons track; watch for DXRP
  upstream adoption (would ripple into the vanilla base).

**Operational learning:** first editor boot after an engine update blocks the frame loop
for minutes (asset/shader recompile) — the bridge heartbeat goes stale while `sbox-dev`
burns CPU. Check process CPU/RAM before declaring a crash; the heartbeat recovers when
the recompile finishes.
