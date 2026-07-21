# CVLX — the LIFEPUNCH child layer of the Cavelux MCP

> First real child content. Built under `dispatch/red/0015` (Bloodwave GO 2026-07-21T02:33-04:00).
> **CORE LAW: MCP expands capability, NOT authority.** Bloodwave gates authorize / merge / deploy.

## What this is

The Cavelux **parent** (`github.com/mragerlp/cavelux`) is the universal, domain-blind method
layer: a mount engine, generic project-air, governance, lanes. It knows **nothing** about
s&box. This directory is the **child**: the s&box/LIFEPUNCH domain layer that the parent
consumes as configuration.

The whole build is one idea: **mount the s&box native MCP endpoint as ONE upstream child
endpoint through the parent's mount engine.**

## Why the gateway (the cap argument)

The native endpoint at `http://127.0.0.1:7269/mcp` is a **7-tool gateway** over a live
registry of **290 tools across 36 toolsets** — including the full **28-toolset `bridge_*`
family** (the sboxclaude bridge, incl. the lpbitcoin-UI subset), published by the
`sboxskinsgg.claudebridge` editor lib.

Mounting the gateway costs the tool cap **7 tools** and delivers the whole registry, because
the rest is reached *by name* through `search_tools` → `describe_toolset` → `call_tool`.
Mounting the family directly would blow every provider cap on its own.

| | tools on the cap |
|---|---|
| native gateway (what we mount) | **7** |
| live registry behind it | 290 |

**Guess-free rule:** `search_tools` first, `describe_toolset` to read the real signature,
*then* `call_tool`. Never invent a registry tool name.

## The boundary (hard)

Every s&box name in this build lives **here**, in the child repo. The parent holds only the
generic mechanism. This is machine-checked, not asserted — `prove_child.py` check (d) scans
the parent's shipped surface for child identifiers and fails on any hit.

| concern | lives in |
|---|---|
| upstream-mount mechanism, lanes, inventory, cap accounting | parent (`cavelux_mcp/upstream.py`) |
| the `7269` endpoint, the 7 entry-tool names, the canonical pin, the `lpbitcoin-ui` lane | child (`cvlx/upstreams.json`) |
| LIFEPUNCH doctrine/brand paths | child (`cvlx/project-air.json`) |

## The project-identity guard

The mount selects a **URL, not a tree** — what these tools operate on is whatever project the
`:7269` editor has **open**. So `upstreams.json` carries an identity guard: before every
proxied call the parent runs `call_tool → get_project_info` and requires `lifepunch` + `dxrp`
in the response. Wrong project (or no project) ⇒ **REFUSED**, never a silent edit of the wrong
tree.

Target is the **canonical** `dxrp\game` — goal-aligned *and* clean (`red/0014`: all compilers
Success, zero errors; the two broken libs that cascade-fail *vanilla* are absent here).

**Warm-up caveat (observed live):** for a few seconds after the editor launches, the bridge
lib is not yet loaded and `get_project_info` returns `Unknown bridge command`. The guard
fails **closed** (refuses) during that window. That is the safe direction — retry once the
editor is warm.

## Lanes

| lane | mounts | tool cost |
|---|---|---|
| `lpbitcoin-ui` | gateway + parent UI intelligence, project-air, prompts, context | **7** |
| `sbox-native` | gateway only | **7** |

`lpbitcoin-ui` is deliberately lean: it carries **zero** parent eye tools, so the entire lane
costs exactly the 7 gateway tools while still giving the guess-free UI surface.

## Running it

The parent server, with this child config injected:

```powershell
$env:CAVELUX_UPSTREAM_CONFIG    = "C:/Users/jared/Projects/lifepunch/cvlx/upstreams.json"
$env:CAVELUX_PROJECT_AIR_CONFIG = "C:/Users/jared/Projects/lifepunch/cvlx/project-air.json"
$env:CAVELUX_LANE               = "lpbitcoin-ui"
python -m cavelux_mcp
```

Proof (editor open on canonical `dxrp\game` for the live checks):

```powershell
python cvlx/prove_child.py --parent C:/Users/jared/Projects/cavelux/mcp
```

Checks (a) 7 entry tools surface · (b) cap survives vs the live registry · (c)
`get_project_info` = `org=lifepunch` on canonical · (d) the parent stays s&box-blind. With the
editor down, (b)/(c) report **SKIPPED-UNPROVEN** rather than passing on an assumption.

## Not mounted (ruled out)

**chomnr** (`9090`, ~180 WIRE — the broken one) · **sboxclaude-stdio** (redundant with native)
· **Ozmium** (convar debris, not a cable) · **vanilla** (dirty tree). Native-only, per the GO.

## Known upstream defect

`editor_status` declares `ActiveScenePath` as a required string and returns `null`, so a
strict MCP client rejects the endpoint's own response. The parent's upstream organ retries
with that tool's schema suppressed and **labels** the result rather than dropping the tool —
the upstream's bug does not become the mount's outage.
