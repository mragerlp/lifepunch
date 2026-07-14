# TRIPLE MCP STACK — three cables, one driver
Canon home: `lifepunch/docs/cvl/TRIPLE_MCP_STACK_2026-07-13.md`
v1.1 · 2026-07-13 · **RULED by Bloodwave** · Landed by Red · topology corrected pre-merge by Codex under Bloodwave's sustained-mirror word

> **PLACEMENT NOTE.** This is a **new `docs/cvl/` note, not an addendum to
> `EDITOR_ACCESS_LAW_V2_2026-07-13.md`** — that record is class RULED and its own header states
> *"Write-once. Supersede with a new record citing this one by filename; never edit in place."*
> This note **cites** v2 and **does not amend it**: the DRIVE law is untouched (§3 below).

## 1. THE THREE SURFACES

The s&box editor exposes **three independent MCP surfaces**. All three were live and reachable in the
2026-07-13 editor session; implementer boots probe each surface and report seat-local client wiring
separately. **Reachable endpoint** and **configured client alias** are two facts, never one inference.

| # | Surface | Endpoint | Origin |
|---|---|---|---|
| 1 | **s&box NATIVE MCP** | `http://127.0.0.1:7269/mcp` | **First-party — ships with the editor.** Live server identified itself as `sbox-editor` v26.07.08e. Dynamic tool discovery via `search_tools` / `call_tool`. |
| 2 | **Claude Bridge** | **File IPC** at `%TEMP%\sbox-bridge-ipc` — **no HTTP endpoint** | `sboxskinsgg.claudebridge` addon + standalone `sbox-mcp-server`; the established gate/proof surface. |
| 3 | **chomnr** | `http://127.0.0.1:9090/sbox-mcp` | Pre-existing `notpointless.chomnr_mcp` editor library; authoring/compile surface. |

**Project wiring:** `.mcp.json` at the repo root wires Claude Bridge as `sbox`, chomnr as
`sbox-editor`, and native MCP as `sbox-native`. Codex's seat-local config independently wires Claude
Bridge 2.1.0 and chomnr. At the correcting boot, native MCP was endpoint-reachable by a direct MCP
initialize probe but no `sbox-native` client alias appeared in the Codex harness manifest; adding that
seat-local stanza remains a Bloodwave console act. That client gap does not rename or erase the live
native surface.

> **CODEX WIRING IS A BLOODWAVE CONSOLE ACT.** If Codex's MCP config lives in `~/.codex/config.toml`
> rather than `.mcp.json`, the equivalent stanza is:
> ```toml
> [mcp_servers.sbox-native]
> url = "http://127.0.0.1:7269/mcp"
> ```
> **No seat edits another seat's local config.** Red wrote this stanza into canon for Bloodwave to
> apply; Red did not touch it.

## 2. LIVE TOPOLOGY SENSORS — Codex correction, 2026-07-13

Bloodwave sustained Codex 0031's topology MIRROR and authorized this pre-merge correction. The live
sensors are:

- **Native 7269:** a direct MCP `initialize` POST returned HTTP 200, protocol `2025-03-26`, and
  `serverInfo.name=sbox-editor`, `serverInfo.version=26.07.08e`.
- **Claude Bridge file IPC:** `get_bridge_status` returned `connected=true`, `roundTripOk=true`,
  `bridgeVersion=2.1.0`, `mcpServerVersion=2.1.0`, `versionsAligned=true`, and `handlerCount=267`.
- **chomnr 9090:** live `server_get_config` returned `running=true`,
  `url=http://127.0.0.1:9090/sbox-mcp`, `enabledTools=654`, and `connectedClients=2` during the 0031
  boot. Later verification reads returned 3 and then 0 clients; client count is volatile session
  state, not a topology invariant.
- **Merged canon:** `lifepunch/docs/SBOX_EDITOR_MCP.md:21-22,32,40-41 @
  ab98eebd4d95513597f67b7e0a75bef0162f44ed` identifies Claude Bridge as file IPC and
  `notpointless.chomnr_mcp` / `sbox-editor` as HTTP `:9090/sbox-mcp`.

### 2.1 9090 identity — pre-existing chomnr, not a library installed tonight

The named unknown is closed by independent sensors:

- `D:\Steam\steamapps\common\sbox\dxrp\game\Libraries\notpointless.chomnr_mcp` was created
  `2026-06-23T01:40:04Z`; its current `.version` (`1.0.308753`) was written
  `2026-07-10T23:23:25Z`.
- Installed source owns the endpoint shape:
  `Editor/Integration/McpSettings.cs:21` sets default port 9090,
  `Editor/Server/McpServer.cs:27` sets `/sbox-mcp`, and `README.md:12` names the full URL.
- Archived editor logs on **2026-07-12** already show `notpointless.chomnr_mcp#local` mounted and the
  MCP server listening at `127.0.0.1:9090/sbox-mcp`; the surface therefore predates tonight.
- Fresh HTTP.sys request-queue state attaches the registered 9090 URL to editor PID 22384
  (`sbox-dev.exe`). The socket table's kernel PID 4 is HTTP.sys transport, not contrary ownership.

Therefore 9090 is the pre-existing `notpointless.chomnr_mcp` surface. There is no remaining process-
ownership ambiguity and no basis to call it a newly installed Pointless-AI surface tonight.

## 3. DRIVE LAW — **UNCHANGED**. THREE CABLES ARE NOT THREE DRIVERS.

**`EDITOR_ACCESS_LAW_V2_2026-07-13.md` governs, in full, unamended.**

- **Exactly ONE seat holds editor DRIVE at any moment**, board-named by Bloodwave's grant.
  **Which cable carries the command is irrelevant** — a mutation issued over the native server is the
  same mutation as one issued over the Claude Bridge, and it needs the same grant.
- **OBSERVE seats are read-only on ALL THREE surfaces.** A second cable is not a second door. A seat
  without DRIVE that mutates via the native or chomnr server has broken the law exactly as if it had
  used the Bridge.
- **DRIVE = tree hands** (v2 §1.2). Unchanged.
- **Absence of a grant is not a grant** (v2 §1.1). Unchanged.

**The hazard this clause exists to kill:** three mutation paths to the same operation make it *easier*
to drive without noticing you are driving. The count of cables changes nothing about who may pull them.

## 4. OVERLAPPING TOOLS — WHICH SURFACE, AND SAY SO

Multiple surfaces expose **overlapping mutation paths to the same operation**. Routing:

- **Claude Bridge — for established gate workflows.** The proof rituals, launch reports, and sensor
  discipline are written against it. **Do not re-plumb a working gate onto a new surface for novelty.**
- **Native / chomnr — for coverage gaps**, i.e. an operation the Bridge does not expose.
- **RECORD WHICH SURFACE PERFORMED ANY MUTATION.** This is a **Sensor Law obligation**, not
  bookkeeping: "the scene was saved" is an incomplete claim. **"The scene was saved via the Claude
  Bridge"** is the claim, because when two cables can perform one act, *which cable acted* is part of
  what makes the record reproducible — and part of what makes a defect attributable.

## 5. BOOT CHECK — amends `RED_BOOT.md` and `CODEX_BOOT.md`

Both implementer boot checklists gain one line:

> **MCP STACK:** confirm **all three MCP surfaces reachable and versions aligned.** An unreachable or
> version-skewed surface is **REPORTED, never silently skipped.** Assert native at 7269, Claude Bridge
> over file IPC (including non-null 2.1.0/2.1.0 alignment), and chomnr at 9090. A missing seat-local
> client alias is reported separately as `CLIENT NOT CONFIGURED`; it never changes endpoint identity.

**Live wiring verification repeats at every boot.** The measurements above are the correction sensors,
not a standing promise that future sessions remain reachable.

FROM: Red (Claude Code Opus)
TOPOLOGY CORRECTION: Codex · CVL Review + Proposal Seat
