# VENGEANCE — dual s&box MCP stack (Claude Bridge + chomnr)

**Status:** Wired on VENGEANCE (June 2026)  
**Libraries (DXRP `game/Libraries/`):**

| Package | Role |
|---------|------|
| `sboxskinsgg.claudebridge` | Runtime bridge — file IPC, play mode, in-game screenshots |
| `notpointless.chomnr_mcp` | Editor MCP — HTTP server inside editor |
| `notpointless.chomnr_humanoid_retargeter` | Optional — human anim retarget (import as chomnr tools) |

**Cursor MCP (`%USERPROFILE%\.cursor\mcp.json`):**

| Server key | Transport | Use for |
|------------|-----------|---------|
| `sbox` | `npx sbox-mcp-server` + `%TEMP%\sbox-bridge-ipc` | Play mode, runtime C#, logs, game screenshots |
| `sbox-editor` | `http://127.0.0.1:9090/sbox-mcp` | ModelDoc, ShaderGraph, scenes, prefabs, compile errors |

Install / refresh: `lifepunch/scripts/Install-VengeanceSboxEditorMcp.ps1`

---

## Full capacity bar (lock this — June 2026)

**Two different UIs — do not confuse them.**

| Where you look | What it means | Full capacity |
|----------------|---------------|---------------|
| **s&box editor bottom-right** `MCP · N` | **chomnr** editor HTTP server · **N = connected AI clients** (Cursor tabs/agents), not “number of MCP servers” | **Green dot** + **`MCP · 1` or higher** (N ≥ 1). **`MCP 6` is fine** — six clients hooked to `sbox-editor`. Click pill → MCP dock → **Overview** to see client names. |
| **Cursor → Settings → MCP** | Cursor-side MCP servers | **3 green** on VENGEANCE: `sbox`, `sbox-editor`, `cornerman-lm` |
| **Claude Bridge** (play mode) | Runtime IPC | `get_bridge_status` → `connected: true`, heartbeat &lt; 30s |

**You are NOT aiming for a magic number like “MCP 3” in the editor.** Zero clients (`MCP` with no number) = **not full** on editor MCP.

### VENGEANCE (Red) — minimum every session

```text
Cursor MCP:     3/3 green  (sbox + sbox-editor + cornerman-lm)
Editor pill:    green dot + MCP · ≥1
Bridge:         connected (play/screenshots/lp_spawn_*)
Tier-3 (Green): :1234 distill+embed loaded (via cornerman-lm from Red)
```

One-command probe:

```powershell
powershell -File lifepunch\scripts\Get-CvlConnectivityStatus.ps1 -Pretty
```

Pass when: `vengeance.sboxBridge`, `vengeance.sboxEditor`, `vengeance.mcpDual`, `cornerman.tier3Serve`, `cornerman.mcpTriple` = **true**.

### Cornerman (Green) — 360° dual-stack (required every session)

Green needs **triple** MCP (same two toolsets as Red, different transport):

| Server | Toolset | Transport |
|--------|---------|-----------|
| `sbox` | Claude Bridge (play/runtime) | SMB `\\VENGEANCE\SboxBridgeIpc` |
| `sbox-editor` | chomnr (ModelDoc/prefabs) | SSH tunnel `localhost:9090` → VENGEANCE |
| `cornerman-lm` | Tier-3 distill | Green `localhost:1234` |

Wire from VENGEANCE:

```powershell
powershell -File lifepunch\scripts\Restore-CornermanDualStack.ps1
```

On Green: restart Cursor → **3/3 green** when VENGEANCE editor is open.

**Tier-3 models run on Green only** — VENGEANCE uses `cornerman-lm` as a LAN client to `:1234`. Do **not** run LM Studio on Red (competes with editor RAM).

### Not full capacity → relaunch (no guilt, 2 minutes)

```powershell
powershell -File lifepunch\scripts\Test-PreLaunchCheckup.ps1 -Fix
powershell -File lifepunch\scripts\Start-SboxDxrpEditor.ps1 -PreflightFix -SyncAddon bitcoinmining
```

Then **Ctrl+Shift+P → Reload Window** in Cursor if MCP panel still red.

**Do not** use saved test scenes as proof — always `lp_map_flatgrass` + spawn prefabs fresh.

---

## Pre-launch checkup (run before every project session)

From **VENGEANCE**, before `Start-SboxDxrpEditor.ps1` or heavy addon work:

```powershell
cd lifepunch\scripts
powershell -File Test-PreLaunchCheckup.ps1 -Fix
```

| Check | Pass means |
|-------|------------|
| **VENGEANCE RAM / bloat** | No Discord/Spotify/LM Studio GUI on Red; one s&box instance; optional Xbox/telemetry services flagged |
| **Cornerman RAM / bloat** | No LM Studio **GUI** eating RAM; flag Discord/Chrome/Spotify on Green |
| **Tier-3 LM headless** | `lms server` on `:1234`, distill+embed **in VRAM**, watchdog task OK — **no GUI window** |
| **VENGEANCE dual MCP** | `sbox` bridge IPC fresh + `sbox-editor` in `mcp.json` (+ HTTP when editor open) |
| **Cornerman triple MCP** | SMB `sbox` + SSH tunnel `sbox-editor` + `cornerman-lm` in Green `mcp.json` |

`Start-SboxDxrpEditor.ps1` runs this automatically (use `-SkipPreflight` to bypass, `-PreflightFix` to heal first).

**During work — disconnect alerts (VENGEANCE only):**

```powershell
powershell -File lifepunch\scripts\Watch-CvlConnectivity.ps1
```

Polls every 30s on **VENGEANCE**; **Windows toast on Red only** when any MCP or Tier-3 link drops on either machine (bridge IPC, `sbox-editor`, `mcp.json` stacks, Tier-3 `:1234`, Green SMB/tunnel/watchdog). Cornerman does not run the watcher or receive toasts. `Start-SboxDxrpEditor.ps1` starts this in a minimized window on VENGEANCE unless `-SkipConnectivityWatch`. Optional auto-heal: `-FixOnDown`.

Status JSON only: `Get-CvlConnectivityStatus.ps1`

Heal only: `Invoke-VengeanceBloatCleanup.ps1` (Red) · `Fix-CornermanLmServe.ps1` (Green) · bridge: `Connect-CornermanBridge.ps1` · Green dual-stack: `Restore-CornermanDualStack.ps1`

**Agent routing table (task → MCP → tier):** `lifepunch/docs/MCP_AGENT_ROUTING.md`  
**ChatGPT advisory handoff:** `lifepunch/docs/handoff/to-chatgpt-mcp-topology-handoff.txt`

---

## Recommendation: pair both (do not replace)

They are **complementary**, not duplicates.

```text
Cursor
  ├─ sbox          → Claude Bridge addon → game / play mode
  └─ sbox-editor   → chomnr_mcp HttpListener → editor main thread
```

- **Claude Bridge** owns what happens **after Play** (pawn, mining playtest, bridge screenshots).
- **chomnr_mcp** owns **editor authoring** (compile `gpu-rack.vmdl`, shader `_c`, KV3 writes, undo/revert UI).

Cornerman **must dual-stack too** at full capacity — SMB for `sbox` + **SSH tunnel** for `sbox-editor` (chomnr is `127.0.0.1` on VENGEANCE only).

---

## Cornerman dual-stack (Green)

| Server | Green transport | Prerequisite |
|--------|-----------------|--------------|
| `sbox` | SMB `\\VENGEANCE\SboxBridgeIpc` | `Map-CornermanBridgeShare.ps1` (once) |
| `sbox-editor` | SSH `-L 9090:127.0.0.1:9090` → VENGEANCE | `Start-CornermanSboxEditorTunnel.ps1 -Background` |
| `cornerman-lm` | localhost `:1234` | LM Studio warm |

```text
Cornerman Cursor
  ├─ sbox          → UNC bridge IPC (runtime / play mode)
  ├─ sbox-editor   → localhost:9090 ──SSH tunnel──► VENGEANCE chomnr
  └─ cornerman-lm  → local distill
```

**From VENGEANCE (one shot):**

```powershell
powershell -File lifepunch\scripts\Connect-CornermanBridge.ps1
```

**On Cornerman desktop (after SMB map once):**

```powershell
powershell -File C:\lifepunch\cornerman\Start-CornermanSboxEditorTunnel.ps1 -Background
```

Restart Cursor on Green → all three MCP servers should go green when VENGEANCE editor is open.

**SSH key:** background tunnel needs passwordless `jared@192.168.1.236` from Cornerman (or run tunnel foreground and type password).

Refresh mcp only: `Install-CornermanSboxBridgeMcp.ps1`

---

## Pros

| Pro | Why it matters for LPDXRP |
|-----|---------------------------|
| **ModelDoc / ShaderGraph tools** | Directly attacks BITCOINMINING-01/03/04 and hub vmdl compile |
| **Editor-native undo + activity feed** | Revert bad AI writes from the MCP dock |
| **Permission modes** | Start `Approve writes`; read-only for audits |
| **Same machine, no SMB** | Simpler than Cornerman bridge for editor tasks on VENGEANCE |
| **Tool import** | Pull Humanoid Retargeter methods into MCP from Tools → Import |
| **Coexists with Claude Bridge** | Runtime playtest path unchanged |
| **Pure C# in editor** | No Blender/Rokoko dependency (unlike CARL) |

## Cons

| Con | Mitigation |
|-----|------------|
| **Brand new package** (no reviews) | Approve-writes mode; small smoke tests before bulk edits |
| **Two MCP servers in Cursor** | Name clearly: `sbox` vs `sbox-editor`; agents must pick the right one |
| **Editor must be open** | `sbox-editor` offline without `Start-SboxDxrpEditor.ps1` |
| **Port 9090 conflicts** | chomnr Settings → change port → re-run install script `-Port N` |
| **Cornerman tunnel extra step** | Run `Start-CornermanSboxEditorTunnel.ps1 -Background` when using Green for editor MCP |
| **Default Full access** | Switch to **Approve writes** in MCP dock Settings on first open |
| **Cloud install tools opt-in** | Leave disabled unless you want AI pulling packages |

---

## First session checklist

1. `powershell -File lifepunch\scripts\Install-VengeanceSboxEditorMcp.ps1`
2. `powershell -File lifepunch\scripts\Start-SboxDxrpEditor.ps1`
3. Editor → **MCP** menu / dock → **Approve writes**
4. Restart Cursor → MCP panel: `sbox` + `sbox-editor` green
5. Smoke: `sbox-editor` → list tools; `sbox` → `get_bridge_status`
6. Bitcoin P0: `modeldoc` / shader tools on `lifepunch_rgb_fan_led.shader` + `gpu-rack-gpu.vmat`

---

## Agent routing (law)

| Task | MCP |
|------|-----|
| Playtest, `lp_spawn_*`, in-game UI | `sbox` (Claude Bridge) |
| Compile vmdl/vmat, edit prefab in editor, shader graph | `sbox-editor` (chomnr) |
| Distill / cheap prep | Cornerman `cornerman-lm` (unchanged) |
| Runtime inspect / audit | Prefer **dev ConCmds** + `console_run`; `execute_csharp` OK when needed — **always** sweep `Editor/__Exec_*.cs` after (see § execute_csharp) |

Do not claim visual verification without the appropriate server connected.

---

## `execute_csharp` — temp exec files (`Editor/__Exec_*.cs`)

**Recorded:** 2026-06-13 (VENGEANCE DXRP) — agents must treat cleanup as law.

The `sbox` MCP tool `execute_csharp` is **experimental**. It writes a temp file `Editor/__Exec_<id>.cs`, hotloads the **editor** assembly, runs the snippet, then deletes the file. Bridge v1.13+ sweeps leftovers on startup (`SweepStaleExecFiles` in `sboxskinsgg.claudebridge`).

### Failure mode

If a snippet **fails to compile**, the bad `__Exec_*.cs` can **leak** and break **every** subsequent editor compile (`CS1026`, `Sandbox.Log` missing, etc.) until the files are removed.

### Agent rules

1. **Prefer** dev ConCmds in `Code/Addons/lifepunch/_dev/` + `console_run` / `get_compile_errors` / screenshots when that solves the task without editor exec temps.
2. **`execute_csharp` is fine** (including multi-line) when you actually need it — just treat it as hazardous tooling, not the default.
3. **Always clean up after exec sessions:**
   - If compile errors cite `Editor/__Exec_*.cs`, delete them **immediately** and recompile.
   - After any `execute_csharp` inspect/debug pass, sweep leftovers even when compile looked fine.

**Manual cleanup (VENGEANCE):**

```powershell
Remove-Item "D:\Steam\steamapps\common\sbox\dxrp\game\Editor\__Exec_*.cs" -Force -ErrorAction SilentlyContinue
```

Then recompile (or restart the editor so the bridge sweep runs on a clean assembly).

**Bitcoin/hacker inspect pattern:** add or reuse an `lp_*` ConCmd when you'll need the same probe twice; one-off editor probes via `execute_csharp` are OK if you run step 3.
