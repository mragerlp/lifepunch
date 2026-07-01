---
applyTo: "**"
description: "LifePunch s&box triple MCP stack — ports, routing, verification loop"
sourceRule: ".cursor/rules/lifepunch-sbox-mcp-stack.mdc"
---

> **Synced from** `.cursor/rules/lifepunch-sbox-mcp-stack.mdc` â€” edit source there, then re-run `Sync-CursorRulesToCopilotInstructions.ps1`.

# LifePunch — s&box MCP stack (July 2026)

**Canon:** `lifepunch/docs/SBOX_EDITOR_MCP.md` · `lifepunch/docs/MCP_AGENT_ROUTING.md` · ports: `lifepunch/config/sbox-mcp-ports.json`
**Config:** `.vscode/mcp.json` (all 4 servers — replaces Cursor `~/.cursor/mcp.json` for Copilot primary)

## Four MCP servers (do not collapse)

| MCP server | Transport | Role |
|------------|-----------|------|
| **`sbox`** | File IPC (`%TEMP%\sbox-bridge-ipc`) via `npx sbox-mcp-server` | **Runtime / play proof** — spawn, USE, HUD, bridge screenshots, `console_run` |
| **`sbox-editor`** | HTTP `127.0.0.1:9090/sbox-mcp` (chomnr) | **Authoring compile** — ModelDoc, vmats, prefabs, compile errors, LifePunch dev tools |
| **`sbox-jtc`** | HTTP `localhost:29015/mcp` (jtc) | **Editor automation + docs** — scene graph, components, `sbox_search_docs` / `sbox_search_api`, console |
| **`cornerman-lm`** | LAN `:1234` | Distill prep only — never ship C# from Tier-3 alone |

**Port law:** jtc owns `:29015/mcp`. chomnr owns `:9090/sbox-mcp`. No swap without updating `sbox-mcp-ports.json`.
**Never demote chomnr** for ModelDoc/vmat/prefab compile or imported LifePunch dev tools.

## Task routing

- Playtest, scale in scene, USE, runtime UI → **`sbox`**
- Compile vmdl/vmat, prefab graph, shader graph, chomnr imports → **`sbox-editor`**
- Docs/API lookup, scene/component automation, project/file inspect → **`sbox-jtc`**
- Multi-file C# economy/permissions → **Opus in Copilot**, then verify with **`sbox`**
- Bounded Razor/SCSS, planning, ModelDoc maps → **`GROK REQUIRED`** = open Cursor, select Grok Build 1

## Mandatory loop (every s&box task)

1. **Probe** — `get_bridge_status` (play) and/or editor MCP HTTP (authoring). Never assume from code alone.
2. **Portal auth (owner)** — After Host Play, **owner manually** runs `lp_authorize <token>`. Agents wait.
3. **One focused change** — no unrelated batching.
4. **Compile** — chomnr compile errors or jtc console; fix before play.
5. **Play proof** — `lp_map_flatgrass` + fresh spawn; not saved test scenes.
6. **Screenshot / notes** — Bridge or jtc screenshot; report pass/fail.
7. **Commit** — propose scope; **owner approves** before git commit.

## Bitcoinmining lane (`bitcoinmining` ident)

Priority: **Ophion hub → terminal → GPU rack**. Verify scale vs citizen, collider vs mesh, materials, USE prompts.
Dev shortcuts: `lp_bitcoin_use_hub`, `lp_bitcoin_sui_hub_preview`.

## Full capacity (VENGEANCE)

```powershell
powershell -File lifepunch\scripts\Test-PreLaunchCheckup.ps1 -Fix
powershell -File lifepunch\scripts\Get-CvlConnectivityStatus.ps1 -Pretty
```

Copilot MCP **4/4 green** (`.vscode/mcp.json`): `sbox`, `sbox-editor`, `sbox-jtc`, `cornerman-lm`.
Editor chomnr pill: **MCP · ≥1**. jtc: open **MCP Server** dock each session (no autostart).

Refresh wiring: `Install-VengeanceSboxEditorMcp.ps1` or `Install-VengeanceMcpStack.ps1`.
