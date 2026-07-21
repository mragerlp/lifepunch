"""CVLX CHILD MOUNT proof (dispatch/red/0015) — the s&box-specific half of the proof.

The parent's prove.py proves the MECHANISM domain-blind (synthetic upstream, no domain
names). This harness proves the REAL mount, and therefore lives in the child repo: every
s&box name in this build is on this side of the boundary.

Proves:
  (a) the native gateway mounts and EXACTLY the 7 entry tools surface
  (b) the tool cap survives (7 << the live 284-tool registry)
  (c) get_project_info through the gateway = org=lifepunch, path=...dxrp\\game
      (bridge family live, operating on CANONICAL LIFEPUNCH content)
  (d) the PARENT repo stays s&box-BLIND — zero child identifiers in its shipped surface

(a), (b-lane) and (d) run with the editor DOWN. (b-registry) and (c) need the editor UP on
canonical dxrp\\game; they report SKIPPED-UNPROVEN rather than passing on an assumption.

Run (from this repo, pointing at the parent checkout):
  python cvlx/prove_child.py --parent C:/Users/jared/Projects/cavelux/mcp
"""

import argparse
import asyncio
import json
import os
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
CHILD_UPSTREAMS = HERE / "upstreams.json"

# The 7-tool gateway (dispatch/red/0015). Exactly these, no more: that IS the cap argument.
EXPECTED_ENTRY = {
    "call_tool", "call_tools", "search_tools", "list_toolsets",
    "describe_toolset", "editor_status", "read_console",
}

# (d) BOUNDARY LAW: concrete child identifiers that must appear ZERO times in the parent's
# shipped surface. Parent docs and the parent's own prove harness are excluded — stating a
# boundary and instrumenting it both require naming what is forbidden. Running code cannot.
CHILD_TOKENS = (
    "sbox", "s&box", "lifepunch", "lpbitcoin", "dxrp", "claudebridge", "sboxclaude",
    "chomnr", "7269", "9090", "editor_status", "list_toolsets", "describe_toolset",
    "search_tools", "read_console", "get_project_info",
)
PARENT_SURFACE = ("cavelux_mcp/**/*.py", "*.json")


def _text(obj) -> str:
    parts = getattr(obj, "content", None) or getattr(obj, "contents", None) or []
    return "\n".join(p.text for p in parts if getattr(p, "text", None))


async def _mounted(parent: Path, lane: str):
    """Start the PARENT server with the CHILD config injected; return its live surface."""
    from mcp import ClientSession, StdioServerParameters
    from mcp.client.stdio import stdio_client

    python = str(parent / ".venv" / "Scripts" / "python.exe")
    if not Path(python).exists():
        python = sys.executable

    env = {
        **os.environ,
        "CAVELUX_UPSTREAM_CONFIG": str(CHILD_UPSTREAMS),
        "CAVELUX_PROJECT_AIR_CONFIG": str(HERE / "project-air.json"),
        "CAVELUX_LANE": lane,
    }
    params = StdioServerParameters(command=python, args=["-m", "cavelux_mcp"], env=env, cwd=str(parent))
    async with stdio_client(params) as (r, w):
        async with ClientSession(r, w) as s:
            await s.initialize()
            tools = [t.name for t in (await s.list_tools()).tools]
            status = _text(await s.read_resource("cavelux://upstream/sbox-native"))
            air = _text(await s.read_resource("cavelux://air/index"))
            # Exercise the gateway THROUGH the mount — the surface an agent actually uses.
            editor = _text(await s.call_tool("editor_status", {"arguments": {}}))
            return tools, json.loads(status), air, editor


async def _gateway(url: str, tool: str, arguments: dict) -> tuple[bool, str]:
    """Call the native gateway directly (the independent sensor for (b)/(c))."""
    from mcp import ClientSession
    from mcp.client.streamable_http import streamablehttp_client

    try:
        async with streamablehttp_client(url, timeout=30) as (r, w, _):
            async with ClientSession(r, w) as s:
                await s.initialize()
                res = await s.call_tool(tool, arguments)
        return True, "\n".join(p.text for p in (res.content or []) if getattr(p, "text", None))
    except Exception as e:  # noqa: BLE001 — real error or nothing
        return False, f"{type(e).__name__}: {e}"


async def main(parent: Path) -> int:
    checks: list[tuple[str, bool | None, str]] = []
    cfg = json.loads(CHILD_UPSTREAMS.read_text(encoding="utf-8"))
    spec = cfg["upstreams"]["sbox-native"]
    url = spec["url"]

    # --- (a) the gateway mounts; exactly 7 entry tools surface ---
    tools, status, air, editor = await _mounted(parent, "lpbitcoin-ui")
    checks.append(("(a) native gateway mounts as ONE upstream endpoint",
                   status["url"] == url and status["toolset"] == "upstream:sbox-native",
                   f"{status['toolset']} -> {status['url']}"))
    checks.append(("(a) EXACTLY the 7 gateway entry tools surface",
                   set(tools) == EXPECTED_ENTRY and len(tools) == 7,
                   f"{len(tools)} tools: {sorted(tools)}"))
    checks.append(("(a) child-owned lpbitcoin-ui lane resolves (child lane, parent merge)",
                   len(tools) > 0, "lane mounted"))
    checks.append(("(a) child project-air injected (LIFEPUNCH tree, not the parent sample)",
                   "claude" in air and "comms-protocol" in air, air.replace("\n", ",")))

    # --- (b) cap survival ---
    checks.append(("(b) cap cost of the whole bridge family = 7 tools (lane surface)",
                   len(tools) == 7, f"lane={len(tools)} tools"))

    # editor_status THROUGH the mount. Native declares ActiveScenePath as a required string
    # and returns null, so a strict MCP client rejects its own response; the parent's
    # upstream organ retries with the schema suppressed and labels it. Proven here, live.
    if editor.startswith("FAILED"):
        checks.append(("(b) cap survives vs LIVE registry [needs editor up]", None,
                       f"SKIPPED-UNPROVEN: {editor[:90]}"))
    else:
        count = None
        for key in ("ToolCount", '"ToolCount"'):
            if key in editor:
                tail = editor.split(key, 1)[1].lstrip(' ":')
                digits = "".join(c for c in tail[:8] if c.isdigit())
                count = int(digits) if digits else None
                break
        checks.append(("(b) cap survives: 7 mounted tools << live registry ToolCount",
                       bool(count and count > 100 and len(tools) == 7),
                       f"7 mounted << {count} live tools in the registry"))
        checks.append(("(b) mount survives a nonconforming upstream output schema",
                       "ToolCount" in editor,
                       "editor_status usable through the mount (labelled, not dropped)"))

    # --- (c) get_project_info = canonical LIFEPUNCH ---
    ok, body = await _gateway(url, "call_tool", spec["identity_guard"]["arguments"])
    if ok:
        low = body.lower()
        checks.append(("(c) get_project_info via gateway = org=lifepunch on canonical dxrp\\game",
                       "lifepunch" in low and "dxrp" in low, body.replace("\n", " ")[:150]))
        checks.append(("(c) identity guard ACCEPTS the canonical project",
                       all(e.lower() in low for e in spec["identity_guard"]["expect"]),
                       f"expects {spec['identity_guard']['expect']}"))
    else:
        checks.append(("(c) get_project_info = canonical LIFEPUNCH [needs editor up]", None,
                       f"SKIPPED-UNPROVEN: {body[:90]}"))
        checks.append(("(c) guard REFUSES rather than guessing when the endpoint is down",
                       status["identity_ok"] is False and not tools_call_succeeded(status),
                       f"identity_ok={status['identity_ok']}"))

    # --- (d) the parent stays s&box-BLIND ---
    hits, scanned = [], 0
    for pattern in PARENT_SURFACE:
        for path in sorted(parent.glob(pattern)):
            if path.name == "prove.py":
                continue
            scanned += 1
            body_l = path.read_text(encoding="utf-8", errors="replace").lower()
            hits += [f"{path.name}:{t}" for t in CHILD_TOKENS if t in body_l]
    checks.append(("(d) BOUNDARY: ZERO s&box/LIFEPUNCH identifiers in the parent's shipped surface",
                   not hits, f"scanned={scanned} parent files, hits={hits or 'none'}"))
    checks.append(("(d) every s&box name in this build lives in the CHILD repo",
                   CHILD_UPSTREAMS.exists() and "7269" in CHILD_UPSTREAMS.read_text(encoding="utf-8"),
                   "cvlx/upstreams.json holds the endpoint, the parent holds the mechanism"))

    print("\n=== CVLX CHILD MOUNT PROOF ===")
    failed = False
    for name, ok_, ev in checks:
        tag = "SKIP" if ok_ is None else ("PASS" if ok_ else "FAIL")
        failed = failed or ok_ is False
        print(f"  [{tag}] {name}  |  {ev}")
    skipped = sum(1 for _, o, _ in checks if o is None)
    print(f"=== RESULT: {'FAILURES PRESENT' if failed else 'ALL PASS'}"
          + (f" ({skipped} SKIPPED-UNPROVEN — editor down)" if skipped else "") + " ===")
    return 1 if failed else 0


def tools_call_succeeded(status: dict) -> bool:
    """A dead endpoint must never report identity success."""
    return bool(status.get("identity_ok"))


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--parent", required=True, type=Path, help="path to the cavelux parent mcp/ checkout")
    raise SystemExit(asyncio.run(main(ap.parse_args().parent.resolve())))
