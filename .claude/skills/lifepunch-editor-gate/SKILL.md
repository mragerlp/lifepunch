---
name: lifepunch-editor-gate
description: The s&box editor and Claude Bridge session ritual for this repo. Use for ANY editor work, bridge/MCP interaction, hotload, playtest, screenshot, gate drive, sync to the Steam editor tree, or before claiming anything visual, runtime, or replicated is proven. Covers boot order (editor first, agent second), the bridgeVersion NON-NULL assertion, P0 editor-tree byte-identity before any drive, blank.scene vs map+pawn scene law, Sync-LifePunchAddonsToDxrp -WhatIf-first, the hotload sensor ritual (log postdates write + positive code-string ID), screenshots as assertions, and the fail-branch. The editor compiles a hand-synced copy, NOT this repo — editing here and hotloading gives a FALSE all-clear.
---

# The editor gate — the ritual before any claim

## 1. BOOT ORDER — editor first, agent second

The HTTP editor MCP servers live **in the editor** and do not retry like the file-IPC
bridge. Boot the editor, **then** the agent session (or `/mcp` reconnect).

```
Start-SboxDxrpEditor.ps1 -FullCapacity -PreflightFix -BitcoinOnly -SyncAddon lpbitcoin,adminmenu
```

## 2. ASSERT THE BRIDGE BEFORE BELIEVING ANY CHECK

`get_bridge_status` must report `connected: true`, `roundTripOk: true`, and
**`bridgeVersion` NON-NULL**.

> **`versionsAligned: true` with `bridgeVersion: null` is VACUOUS.**
> A comparison with one side missing reports agreement, not truth.

Heartbeat can be fresh while the editor's request loop is stalled — **trust `roundTripOk`**,
not the heartbeat. A version mismatch means restart Claude Code or republish the addon.

## 3. THE EDITOR COMPILES A HAND-SYNCED COPY — NOT THIS REPO

Source of truth for the running assembly is
`D:\Steam\steamapps\common\sbox\dxrp\game\Code\Addons\lifepunch\…`

**Editing the repo and hotloading without syncing gives a FALSE all-clear.**

### P0 — assert byte-identity BEFORE any drive

EOL-aware, because the repo is LF and the editor tree is CRLF — a raw hash reports every
file as drift and is wrong:

```bash
diff <(tr -d '\r' < "lifepunchaddons/Code/Addons/lifepunch/$f") \
     <(tr -d '\r' < "/d/Steam/steamapps/common/sbox/dxrp/game/Code/Addons/lifepunch/$f")
```

**A mismatch ABORTS the sitting.** Do **not** sync mid-gate — a tree that changes under a
running gate invalidates every case already driven, because the assembly under test is no
longer the assembly the earlier cases passed on. Sync, then restart from P0.

### Syncing — `-WhatIf` first, every time; the FULL launch set, never a lone addon

```
lifepunch/scripts/Sync-LifePunchAddonsToDxrp.ps1 -Addon lpbitcoin,adminmenu -WhatIf
```

**The dry run is the authorization.** Only your session's files listed → run for real.
Anything else appears → **STOP and report.**

**LAUNCH-SET RULE (`EDITOR_LAUNCH_LAW_2026-07-11.md`):** sync the full launch set
(`lpbitcoin,adminmenu`), **never a lone addon.** A lone-addon sync purges the siblings and
orphans their static hooks — the 2026-07-12 flood precedent: syncing `lpbitcoin` alone purged
`adminmenu`, orphaning `StaffMenuTestBotsAutoSpawn`'s static hook into a per-frame
`NotImplementedException` / `Chat.TickCommands` NRE flood. Recovery is a full-set re-sync **plus
a fresh editor boot** (a modified-but-orphaned static hook does not clear on hotload).
The artifact-lock IOException on `bitcoinhub-fan.vmdl` is benign (editor holds it) — one retry
clears it; `Sync OK` in the body with a trailing exit-1 is a completed sync.

## 4. SCENE LAW

| Scene | Use |
|---|---|
| `scenes/blank.scene` (fast) | the default for **all map-independent proof** — ledgers, money paths, tier effects, persistence, entity contracts, UI panels, replication gates |
| game/map + a real pawn | claims whose behavior **IS** the world — hub/terminal placement, interact-vs-grab distance, sightlines, landmark drops. Also anything needing a local viewer (`lp_bitcoin_spawn_hub`) |

**Build and prove in the fast scene; SHIP into the world scene.** A system that only works in
the world scene has a map dependency, and that dependency must be named in its design doc.

Identity: one portal identity proves claims about *a* player. **Two identities are mandatory**
for any claim about two players — non-owner reads, replication, hacking, adversarial cases.
Bots have no SteamID and never prove economic behavior.

Canon: `lifepunch/docs/PROOF_ENVIRONMENT_DOCTRINE.md`.

## 5. THE HOTLOAD SENSOR RITUAL

A clean-looking compile proves only that **recent** bytes compiled. FRESH is two facts:

1. the compile/parser log timestamp **POSTDATES** the file write, **and**
2. a **positive code-string ID** — a string existing nowhere except your edit appears in the
   log or tool result.

**When no sensor reads the thing under test, BUILD one.** Plant a `Log.Info` whose text is
unique to this version. A `.razor.scss` change has no code string — but a parser error's line
number shifting by exactly the lines you added is itself a sensor.

**A behavioral change only the new code could produce is itself a positive ID.** If the old
code provably could not do X, observing X identifies the new assembly.

After `execute_csharp`, always sweep `Editor/__Exec_*.cs`.

### Hotload limits — what hotload CANNOT refresh

Hotload is not a full boot. It reliably swaps method bodies, but it does **not** reliably re-run:

- **NEW razor event handlers / `@ref` bindings** — a newly-added `onclick`/`@ref` may not bind
  until a fresh boot; the old handler table lingers.
- **MODIFIED existing SCSS rules** — a NEW selector hotloads, but editing an EXISTING rule can
  stay stale (the old computed value caches) until a fresh-boot recompile. A power toggle that
  reads the "wrong" color after a correct SCSS edit is usually this, not a code bug.
- **Static hooks / static ctors** — an orphaned or changed `static` hook does not re-arm on
  hotload (see the launch-set flood). Fresh boot re-arms.
- **During play, code hotload can be deferred entirely** — `trigger_hotload` is blocked while
  playing; the file-watcher may not fire on a synced change. When it won't, Bloodwave fires the
  hotload from the keyboard, or stop play. A successful reload shows a snapshot-restore + fresh
  spawns in the log.

### The fresh-boot-before-commit gate

Any claim about a MODIFIED-existing-rule (toggle colors, restyled selectors) or a new handler
binding (button clicks) gets its **definitive** proof at a **fresh editor boot**, not a
hotload — do the boot before the commit that ships it. Batch-4 `✓/✗` click + power-toggle color
are exactly this class.

## 6. SCREENSHOTS ARE ASSERTIONS

**Eyes-covered law: no visual, playtest, or scale claim without an `sbox` bridge screenshot
from Red.** Take the screenshot, then **read the PNG yourself** — you are multimodal.
Guessing visual outcomes from code produces long iteration loops.

`take_screenshot` captures the Main Camera only; use `screenshot_from` / `capture_view` to
frame a target. Scene-mutating tools refuse during play mode — stop play first.

**A screenshot proves what is on screen, not what is on the other client's screen.** Nothing
replicated is proven until a second client has seen it.

## 7. FAIL-BRANCH — any case red

**Freeze. Capture. Report. Never live-patch a gate.**

1. **Stop driving.** Change nothing in the repo, nothing in the editor tree.
2. **Capture** — which case, what was observed, a bridge screenshot from Red.
3. **Re-assert P0** before concluding anything. A red with an unverified editor tree is not a
   result; it is an unknown wearing a result's clothes.
4. **Report.** A fix authored mid-gate invalidates every case already driven. A re-run needs a
   new gate script citing the old one.

## 8. Gate scripts are INSTRUMENTS until their verdict lands

Editable before they run; frozen with their result the moment a verdict is recorded. A re-run
needs a new script. Live gate instruments:
`lifepunch/docs/handoff/GATE_HUB_INTERACT_ADRIVE_2026-07-10.md` ·
`lifepunch/docs/handoff/GATE_ADVANCEDRACK_SYNC_TWO_CLIENT.md`

## 9. Known bridge behaviors

- Objects are referenced **by GUID** from `get_scene_hierarchy` / `find_objects`, never by name.
- Vectors and rotations take `"x,y,z"` / `"pitch,yaw,roll"` strings; colors take `"r, g, b, a"`.
- There is **no auto-undo** for bridge mutations — `save_scene` early and often.
- `is_playing.sessionPlaying` reads stale after a restart; trust the `gameFlag` field.
- `execute_csharp` briefly recompiles the editor assembly — experimental, expect hotload latency.
- Cloud assets are not persistent. Citizen bone names are case-sensitive.

*These are BRIDGE-tool conventions, not engine C# rules. For C# discipline use the
`sbox-engine-truth` skill.*
