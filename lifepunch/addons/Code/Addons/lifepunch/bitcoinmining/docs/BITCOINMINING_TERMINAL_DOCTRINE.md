# Bitcoin Miner terminal doctrine

**Owner canon (2026-06).** Agents and playtest docs must not drift from this. Parent: `addons/docs/PHYSICAL_TERMINAL_DOCTRINE.md`. Hacker parallel: `hackerjob/docs/TERMINAL_SESSION_DOCTRINE.md`.

## Two surfaces (hub body vs HASHD monitor)

| Surface | Entity | Opens | Typing? |
|---------|--------|-------|---------|
| **Hub management** | `bitcoin-miner` (Ophion body) | Rail + CONTROL / UPGRADES / LOG | **No** — same pattern as server rack menu |
| **Ops console** | `bitcoin-terminal` monitor (“head”) | rig0 command window | **Yes** — mining, bitcoin, status |

Layout mirrors **hacker job**: server rack / bitcoin hub = headless control rail; cornerman CRT / hashd monitor = command prompt window.

| Entity | Role | Player opens UI? |
|--------|------|------------------|
| **Bitcoin Miner** (`bitcoin-miner`) | Hub — power, link racks, upgrades, audit log, PIN gatekeeper | **Yes — USE hub body** |
| **HASHD monitor** (`bitcoin-terminal` prefab; DXRP folder may be `hackerterminal`) | rig0 ops console attached to hub | **Yes — USE monitor** |
| **GPU Rack** (`gpu-rack`) | Passive compute — mines when hub is on and linked | **No** |
| **Large GPU Rack** (`large-gpu-rack`) | Higher-yield passive compute | **No** |

## Surfaces (do not conflate)

| Surface | What it is | Mining / economy actions? |
|---------|------------|---------------------------|
| **Developer console** | s&box `>` — staff/editor spawn (`lp_*`) only | **Never** |
| **Hub panel** | `HashdTerminal` hub mode — rail, modules, read-only LOG | Power, link, upgrades only |
| **Head console** | `HashdTerminal` head mode — `rig0>` on monitor | **Yes** — withdraw, mining start/stop, stats |
| **Rack LCD** | `TextRenderer` on linked GPU rack | Telemetry only |

## Economy model

- **BTC wallet lives on the hub** (`BitcoinMinerHubEntity.BitcoinAmount`).
- Linked **GPU racks credit the hub** on each mining payout tick.
- Player **sells BTC from rig0** on the monitor — not per-rack balances.
- **Hardware upgrades** apply from hub UPGRADES module; cash from player wallet via DXRP pay RPCs.

## Login / open flow

1. **USE hub or monitor** — gatekeeper PIN shell (same session for both once unlocked).
2. **Dormant hub** — only spawner sets PIN via graphical numpad on first USE.
3. **After PIN** — hub USE opens management panel; monitor USE opens rig0 console.
4. **Hub LOG** — staff audit trail; command output from monitor appends here.
5. **No command executes** without PIN session once configured.

**No `hashd` / `mine` ConCmds in shipped builds.**

## Code seams

| File | Role |
|------|------|
| `BitcoinMinerHubEntity.cs` | Hub `IPressable`; wallet; operation log; PIN RPCs |
| `BitcoinTerminalProp.cs` | Monitor `IPressable` → head console |
| `HashdTerminal.razor` | Dual surface: `HubPanel` vs `HeadConsole` |
| `HashdSurface.cs` | Surface enum |
| `GpuRackEntity.cs` | Passive compute; credits linked hub |
