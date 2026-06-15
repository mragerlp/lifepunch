# Physical terminal doctrine

**Owner canon (2026-06).** All LifePunch job/economy UIs that feel like “typing commands” must run on **placeable world entities** — never through the s&box developer console.

Applies to **Bitcoin Miner**, **Hacker Job**, and future terminal families. Job-specific detail: `bitcoinmining/docs/BITCOINMINING_TERMINAL_DOCTRINE.md`, `hackerjob/docs/TERMINAL_SESSION_DOCTRINE.md`.

## The fiction

Players are not remote-operating the server from a hidden cheat line. They walk up to **their machine**, press **USE**, and work inside a **program** that looks and feels like a real terminal.

- Withdrawals, upgrades, progress, stats, scans, hacks — all happen **inside that program’s ops console** (the prompt rendered in the Razor UI).
- Under the hood, yes: host RPCs and server validation. That is implementation. **Player-facing “commands” are only what they type at the in-fiction prompt.**

## Hub + terminal pairing (v2 — Bitcoin + Hacker)

| Job | **Hub** (USE → admin / power / link / upgrades) | **Terminal** (USE → typed ops program) | **Satellite** |
|-----|---------------------------------------------------|----------------------------------------|---------------|
| **Bitcoin mining** | **Ophion** (`bitcoin-miner`) → `LpHashdPanel` | **HASHD CRT** (`bitcoin-terminal`) → `rig0>` | **GPU racks** — linked compute; mine/stop/sell via terminal |
| **Hacker** | **Server rack** — power + link range | **Hacker Terminal** / **Advanced** — `cornerman.exe` / `vengeance.exe` | Job-specific targets |

Hubs are **not** where players type mining/hack commands (Bitcoin: dashboard on hub body; commands on CRT). Racks are production units; Bitcoin v2 also allows **USE rack** → CRT focused on that rack.

## Two consoles — only one is gameplay

| Surface | What it is | Player gameplay? |
|---------|------------|------------------|
| **Developer console** | s&box `>` bar (editor / staff tooling) | **No** — not `scan`, `hack`, `mining start`, `bitcoin sell`, login shortcuts, or any economy action |
| **Ops console** | In-fiction prompt inside the entity UI (`rig0>`, `cornerman@terminal:~$`, etc.) | **Yes** — the only place job commands exist for players |

When anyone says **“console”** in design or playtest docs, they mean the **ops console** unless explicitly talking about **staff dev tooling**.

### Developer console — what it is for

- **Staff / editor:** spawn entities (`lp_spawn_*`), map utilities, admin menu actions that require elevated permission.
- **Not for:** standing in the world and running job loops from the `>` line. That breaks roleplay and overlaps the cheat surface (players who abuse the real dev console).

`lp_*` helpers exist to **place props** or **smoke-compile UI in the editor** — they are not a substitute for walking to the CRT or Bitcoin Miner hub in a real playtest.

## Immersion goal

A miner should **USE the Ophion hub** for power and upgrades, **USE the CRT** for `rig0>` mining/sell — not dev-console verbs.

## Code expectation (v2)

| Pattern | Bitcoin v2 | Hacker (quarantined reference) |
|---------|------------|--------------------------------|
| Hub USE | `LpBitcoinHubEntity.Press` → `LpHashdPanel` | Server rack menu |
| Terminal USE | `LpBitcoinTerminalEntity.Press` → `LpBitcoinTerminalPanel` | `HackerTerminal` |
| Rack USE | `LpBitcoinRackEntity.Press` → CRT (rack focus) | N/A |
| ConCmd job verbs | **Not player gameplay** — dev spawn only (`LpBitcoinDevSpawn`) | Same |
| Command dispatch | `LpBitcoinTerminalCommands` | `HackerTerminal.HandleCommand` |
