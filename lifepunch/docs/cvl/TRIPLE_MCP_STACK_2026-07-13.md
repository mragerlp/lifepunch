# TRIPLE MCP STACK — three cables, one driver
Canon home: `lifepunch/docs/cvl/TRIPLE_MCP_STACK_2026-07-13.md`
v1 · 2026-07-13 · **RULED by Bloodwave** · Landed by Red

> **PLACEMENT NOTE.** This is a **new `docs/cvl/` note, not an addendum to
> `EDITOR_ACCESS_LAW_V2_2026-07-13.md`** — that record is class RULED and its own header states
> *"Write-once. Supersede with a new record citing this one by filename; never edit in place."*
> This note **cites** v2 and **does not amend it**: the DRIVE law is untouched (§3 below).

## 1. THE THREE SURFACES

The s&box editor is reachable over **three independent MCP servers**. All three are wired on **both
implementer seats** (Red terminal + Codex) as a **boot law**.

| # | Surface | Endpoint | Origin |
|---|---|---|---|
| 1 | **s&box NATIVE MCP** | `http://127.0.0.1:7269/mcp` | **First-party — ships with the editor.** Dynamic tool discovery via `search_tools` / `call_tool`. |
| 2 | **Claude Bridge** | `http://127.0.0.1:9090/sbox-mcp` | Ours. The established gate/proof surface. |
| 3 | **chomnr bridge** | **PENDING — endpoint TBD** | Third-party package, installed by Bloodwave. |

**Project wiring:** `.mcp.json` at the repo root (project-scoped, loads on any Claude Code seat
opened at the root). Surfaces 1 and 2 are wired there now.

> **⚠️ SURFACE 3 IS NOT WIRED.** The chomnr endpoint was **not supplied** at ruling time, and **no
> URL was guessed into the config.** It is wired the moment Bloodwave reports the endpoint from the
> installed package. **Until then this stack is a DOUBLE stack in practice and a TRIPLE stack in
> law** — a seat that reports "all three reachable" before surface 3 exists is reporting a fiction.

> **CODEX WIRING IS A BLOODWAVE CONSOLE ACT.** If Codex's MCP config lives in `~/.codex/config.toml`
> rather than `.mcp.json`, the equivalent stanza is:
> ```toml
> [mcp_servers.sbox-native]
> url = "http://127.0.0.1:7269/mcp"
> ```
> **No seat edits another seat's local config.** Red wrote this stanza into canon for Bloodwave to
> apply; Red did not touch it.

## 2. TOOL-COUNT SENSOR (Bloodwave-reported, not Red-measured)

Bloodwave reports the Claude Bridge exposing **267 handlers** against the repo's advertised **232**.
**That figure is his, carried here for the record — Red did not measure it** and does not assert it.
Whoever next boots the bridge owns the count as a first-class sensor: **the advertised number is
documentation; the live handler count is the sensor, and they are allowed to disagree.**

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
> version-skewed surface is **REPORTED, never silently skipped.** A surface that is **not yet wired**
> (chomnr, pending its endpoint) is reported as **NOT WIRED** — never as reachable, and never as a
> pass by omission.

**Live wiring verification happens at each seat's next boot, not in the slice that lands this law.**
This document is **boot-law text**; it asserts nothing about the current reachability of any endpoint.
**No endpoint in this file has been probed by Red.**

FROM: Red (Claude Code Opus)
