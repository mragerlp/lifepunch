# CVL full capacity — updates & maintenance runbook

**Status:** Locked June 2026 · **Probe:** `Get-CvlConnectivityStatus.ps1 -Pretty` · **Refresh:** `Invoke-CvlFullCapacityRefresh.ps1`  
**Pins:** `lifepunch/config/cvl-stack-pins.json` · **Tier-3 models:** `lifepunch/config/cornerman-tier3-models.json`

Use this when anything in the stack updates — s&box SDK, DXRP, Claude Bridge, chomnr, Cursor MCP limits, or Cornerman LLMs.

---

## Full capacity definition (do not drift)

| Node | Must pass |
|------|-----------|
| **VENGEANCE** | `vengeance.sboxBridge` + `vengeance.sboxEditor` + `vengeance.sboxJtc` + `vengeance.mcpStack` |
| **Cornerman Tier-3** | `cornerman.tier3Serve` + `cornerman.tier3Api` + `cornerman.lmWatchdog` |
| **Green dual-stack** (when Green runs Cursor) | `cornerman.mcpTriple` + SMB + editor tunnel |

**Editor pill:** green dot + `MCP · ≥1` (client count, not server count).  
**Cursor MCP:** 4 green on VENGEANCE — `sbox`, `sbox-editor`, `sbox-jtc`, `cornerman-lm`.

One command after updates:

```powershell
powershell -File lifepunch\scripts\Invoke-CvlFullCapacityRefresh.ps1
```

Then **Cursor → Reload Window** and **restart editor MCP server** (or restart s&box) if tool overrides changed.

---

## Component update matrix

| Component | What breaks if stale | Update path | Post-update verify |
|-----------|---------------------|-------------|-------------------|
| **LifePunch monorepo** | scripts/docs/addons drift | `git pull --rebase` | `validate-workspace.ps1` |
| **DXRP game** | compile/API mismatch | Steam + upstream DXRP | editor opens `rp.sbproj` |
| **s&box SDK** | compile/API changes | Steam → s&box | cold editor compile |
| **Claude Bridge** | MCP tools / IPC | Library Manager → `sboxskinsgg.claudebridge` | `get_bridge_status` · `versionsAligned` |
| **chomnr_mcp** | editor tools / ModelDoc | Library Manager → `notpointless.chomnr_mcp` | `:9090/sbox-mcp` initialize |
| **sbox-mcp-server** (npm) | bridge protocol | auto via `npx -y` on Cursor start | `run_self_test` 8/8 |
| **Imported MCP tools** | Cursor drops long names | `Fix-SboxEditorMcpCursorToolNames.ps1` | no "naming issues" in Cursor MCP |
| **Cornerman LLMs** | wrong distill/coder | see § Cornerman LLM below | `cornerman.tier3Serve` true |

Canonical version pins: `lifepunch/config/cvl-stack-pins.json` — bump `lastVerified` when you re-verify.

---

## s&box + DXRP update routine

0. **DXRP upstream gate (mandatory before work)** — `Ensure-DxrpUpstreamCurrent.ps1 -Sync -UpdatePin -SyncSteam`; commit `lifepunch/config/dxrp-upstream-pin.json` when the pin moves.
1. **Steam** — update s&box (engine + tools).
2. **DXRP** — update game project per owner/upstream policy.
3. **LifePunch sync** — `Sync-LifePunchAddonsToDxrp.ps1 -Addon bitcoinmining` (or active lane).
4. **Libraries** — s&box Library Manager:
   - `sboxskinsgg.claudebridge` (runtime)
   - `notpointless.chomnr_mcp` (editor compile)
   - `jtc.mcp-server` (editor automation + docs)
   - `xenthio.xmovement` (**required** — DXRP `rp.csproj` reference; see `TECH_DEBT.md` STACK-01)
   - optional: `notpointless.chomnr_humanoid_retargeter`
   - optional (client-local save hardening only): `quality.simpleantitamper` — see `TECH_DEBT.md` SEC-01
   - optional (dev utils only, not ship dep): `wizards.wackylib` — see `TECH_DEBT.md` STACK-02
   - **UI polish:** `tristan.tailwand` — Editor → tailw& → Generate Now (`TAILWAND.md`); `kikozl.sbox_ui_designer` — layout scratch (`SBOX_UI_DESIGNER.md`)
5. **Restart editor** — `Start-SboxDxrpEditor.ps1 -PreflightFix -BitcoinOnly`
6. **MCP guard** — `Fix-SboxEditorMcpCursorToolNames.ps1 -ProbeEditorMcp`
7. **Probe** — `Get-CvlConnectivityStatus.ps1 -Pretty`

After DXRP API changes: re-test `lp_authorize` in editor host play (`DxrpPortalDevAuth.cs`).

**Editor bot playtest** (staff menu, hacker scan, etc.): `game.scene` → Host Play → `lp_authorize` → `lifepunch_spawn_testbot` / `lifepunch_auto_spawn_testbots 1`. Test bots are **stationary** (controller disabled) — not XMovement-driven. XMovement only matters for **your** pawn via DXRP `PlayerController`.

---

## lifepunchnet dedicated server (Gate 0 — before any addon test)

**Canonical law:** `lifepunch/server/DEV_SERVER_GATES.md`

s&box **26.06.10+** and every future engine bump:

| Step | Who | Action |
|------|-----|--------|
| 1 | **RDP user** (jared or administrator — pick one) | `Test-LifepunchnetDevServerReady.ps1` |
| 2 | Elevated OK | `auto_update.bat` or `Update-LifepunchnetSboxServers.ps1` |
| 3 | **Same RDP user as step 1** | `fix_dev_server_now.bat` |
| 4 | All CVL | Portal **Last Pulsed** + console **Steam connected** + `[7/7]` |
| 5 | Only after 4 | Portal addon publish / gamemode pin / in-game smoke |

**VENGEANCE probe** (before advising server fixes):

```powershell
powershell -File lifepunch\scripts\Test-LifepunchnetStatus.ps1
```

Read `sessions[].user` on `:9101/status` — advice must match the **active RDP account**.

**Never:** publish addon revisions to fix Steam; never debug ULX compile until Gate 0 passes.

---

## Claude Bridge + chomnr MCP update routine

### Claude Bridge (runtime — `sbox` in Cursor)

- **Owns:** play mode, `console_run`, screenshots, scene hierarchy, `run_self_test`.
- **Update:** Library Manager → update `claudebridge` → restart s&box.
- **Verify:** `get_bridge_status` → `connected: true`, `versionsAligned: true`, `handlerCount` stable.
- **Do not:** use `execute_csharp` for game types — prefer dev ConCmds + `console_run` (see `SBOX_EDITOR_MCP.md`).

### chomnr (editor — `sbox-editor` in Cursor)

- **Owns:** ModelDoc, vmat/vmdl compile, prefab edits, **imported game tools** (`LpBitcoinDevSpawn.*`, etc.).
- **Update:** Library Manager → update `chomnr_mcp` → restart editor MCP server.
- **Verify:** HTTP `http://127.0.0.1:9090/sbox-mcp` responds; editor pill green.
- **Permissions:** MCP dock → **Approve writes** (not Full access) for production sessions.

### Cursor MCP tool-name limit (60 chars)

Cursor filters tools when `len("sbox-editor:" + toolName) > 60`. Common offenders: imported **moviemaker** motion-edit shortcuts.

**Guard (run after chomnr update or new Tool Import):**

```powershell
powershell -File lifepunch\scripts\Fix-SboxEditorMcpCursorToolNames.ps1 -ProbeEditorMcp
```

Disables offenders in `D:\Steam\steamapps\common\sbox\config\tools.json` → `SboxMcp.ToolOverrides`.  
**Requires:** editor MCP restart + Cursor Reload Window.

**Bitcoin import tools are short** — `PreviewHubUi`, `SpawnKit`, `MiningRatePerMinute` stay available.

---

## Cornerman LLM — adopt newer / better models

**Canonical catalog:** `lifepunch/config/cornerman-tier3-models.json`  
**Routing law:** `CORNERMAN_MODEL_ROUTING.md`

### Current lanes (June 2026)

| Lane | Model | VRAM policy |
|------|-------|-------------|
| **Daily serve** | `qwen/qwen3.6-35b-a3b` + `text-embedding-nomic-embed-text-v1.5` | Always loaded on boot |
| **On-demand** | `qwen2.5-coder-32b-instruct` | `WarmCoder` only — never with 35b |

Green has ~16 GB RAM — **never load distill + coder big models together**.

### When a better model releases

1. **Download on Green** — LM Studio GUI once, or `lms get <model-id>`.
2. **Edit** `cornerman-tier3-models.json`:
   - Add/update `catalog[]` entry (id, model, role, `dailyServe`, `vramGbEstimate`).
   - Adjust `warmProfiles` if the new model replaces distill or coder.
3. **Sync scripts** — `Sync-CornermanRebootScripts.ps1` (pushes `Start-CornermanLmStudio.ps1`).
4. **Update docs** — `CORNERMAN_MODEL_ROUTING.md` table + `cornerman-inbox-directive.json` do[] line.
5. **Warm + verify from VENGEANCE:**

```powershell
powershell -File lifepunch\scripts\Fix-CornermanLmServe.ps1
powershell -File lifepunch\scripts\Get-CvlConnectivityStatus.ps1 -Pretty
```

6. **Push directive** — `Push-CornermanWorkflowDirective.ps1` so Green inbox reflects new default.

### Evaluating a candidate model

| Question | Pass criteria |
|----------|---------------|
| Fits VRAM? | Daily pair must load together; coder stays on-demand |
| Beats incumbent on distill? | Shorter, accurate repo summaries — spot-check 3 briefs |
| Beats incumbent on coder? | Compiles-looking C# still **requires Red/Opus review** |
| MCP unchanged? | `cornerman-lm` still hits `:1234` — no Cursor config change |

**LM Link** (preview): optional remote loader — see `CORNERMAN_MODEL_ROUTING.md` § LM Link. Does not replace bridge or inbox flow.

---

## Green dual-stack (Cornerman Cursor)

When Green runs Cursor with triple MCP:

```powershell
powershell -File lifepunch\scripts\Restore-CornermanDualStack.ps1
```

One-time on Green desktop (password): `Map-CornermanBridgeShare.ps1` for SMB `\\VENGEANCE\SboxBridgeIpc`.

Tunnel watchdog keeps `localhost:9090` → VENGEANCE chomnr.

---

## Agent routing after updates (unchanged law)

| Task | MCP |
|------|-----|
| Playtest, spawn, in-game UI | `sbox` |
| ModelDoc, prefab, imported `LpBitcoinDevSpawn.*` | `sbox-editor` |
| Bulk distill / draft prep | `cornerman-lm` |
| Ship-tier C# / economy | Opus on Red |

Detail: `MCP_AGENT_ROUTING.md` · install: `SBOX_EDITOR_MCP.md`

---

## Session checklist (every work block)

```powershell
powershell -File lifepunch\scripts\Test-PreLaunchCheckup.ps1 -Fix
powershell -File lifepunch\scripts\Start-SboxDxrpEditor.ps1 -PreflightFix -BitcoinOnly -SyncAddon bitcoinmining
powershell -File lifepunch\scripts\Get-CvlConnectivityStatus.ps1 -Pretty
```

If `allOk: false` on VENGEANCE-only work: Tier-3 + dual MCP on Red is enough; Green SMB/tunnel only matters for Green Cursor.

---

## Related

- `SBOX_EDITOR_MCP.md` — dual MCP install
- `CORNERMAN_MODEL_ROUTING.md` — distill vs coder
- `MCP_AGENT_ROUTING.md` — task → MCP → tier
- `LOCAL_AI_WORKSTATION.md` — CVL topology
