# Physical terminal doctrine

**Owner canon (2026-06).** All LifePunch job/economy UIs that feel like “typing commands” must run on **placeable world entities** — never through the s&box developer console.

Applies to **Bitcoin Miner**, **Hacker Job**, and future terminal families. Job-specific detail: `bitcoinmining/docs/BITCOINMINING_TERMINAL_DOCTRINE.md`, `hackerjob/docs/TERMINAL_SESSION_DOCTRINE.md`.

## The fiction

Players are not remote-operating the server from a hidden cheat line. They walk up to **their machine**, press **USE**, and work inside a **program** that looks and feels like a real terminal.

- Withdrawals, upgrades, progress, stats, scans, hacks — all happen **inside that program’s ops console** (the prompt rendered in the Razor UI).
- Under the hood, yes: host RPCs and server validation. That is implementation. **Player-facing “commands” are only what they type at the in-fiction prompt.**

## Hub + terminal pairing (both jobs)

| Job | **Terminal** (USE → program UI) | **Hub** (passive infrastructure) |
|-----|----------------------------------|----------------------------------|
| **Bitcoin mining** | **Bitcoin Miner** (`bitcoin-miner`) — wallet, power, start/stop, upgrades, sell | **GPU Rack** — linked compute; credits hub wallet while mining |
| **Hacker** | **Hacker Terminal** / **Advanced Hacking Terminal** — `cornerman.exe` / `vengeance.exe` ops console | **Server Rack** — power + link range; terminal offline until rack is on |

Same shape: **one entity you interact with**, one or more **hub props** that enable it. Hubs are not where players type commands.

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

A Hacker should feel like a hacker **at their terminal**, not like someone flagged for typing magic words into an invisible engine console. A miner should **USE their rig’s hub**, see telemetry, upgrade hardware, and cash out — from the amber hashd program, not from `mine` in the log.

Differentiate **physical entity session** (legitimate gameplay) from **developer console** (staff tooling / cheat territory). Do not document alternate player paths through ConCmds.

## Code expectation

| Pattern | Bitcoin | Hacker |
|---------|---------|--------|
| Open UI | `BitcoinMinerHubEntity.Press` → `HashdTerminal` | `HackerTerminalEntity.Press` → `HackerTerminal` |
| Hub enables terminal | GPU racks link + mine → hub wallet | Server rack powers CRT + link range |
| ConCmd job verbs | **Not compiled** in DXRP builds (`hashd`, `mine`) | **Not compiled** in DXRP builds (`cornerman`, `vengeance`) |
| Command dispatch | `HashdTerminal.HandleCommand` | `HackerTerminal.HandleCommand` |
