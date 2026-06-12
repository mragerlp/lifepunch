# Bitcoin Miner terminal doctrine

**Owner canon (2026-06).** Agents and playtest docs must not drift from this. Parent: `addons/docs/PHYSICAL_TERMINAL_DOCTRINE.md`. Hacker parallel: `hackerjob/docs/TERMINAL_SESSION_DOCTRINE.md`.

## What “terminal” means here

**Bitcoin Miner** (`bitcoin-miner` hub / Ophion) **is** the terminal. One placeable entity with the hashd program UI attached.

| Entity | Role | Player opens UI? |
|--------|------|------------------|
| **Bitcoin Miner** (`bitcoin-miner`) | Hub — wallet, power, start/stop, upgrades, encryption | **Yes — USE** |
| **GPU Rack** (`gpu-rack`) | Passive compute — mines when hub is on and linked | **No** |
| **Large GPU Rack** (`large-gpu-rack`) | Higher-yield passive compute | **No** |

`bitcoin-terminal` (CRT kit) is **deprecated** for player flow — do not document it as an interaction point.

## Surfaces (do not conflate)

| Surface | What it is | Mining / economy actions? |
|---------|------------|---------------------------|
| **Developer console** | s&box `>` — staff/editor spawn (`lp_*`) only | **Never** — no `mining start`, `bitcoin sell`, or UI shortcuts for players |
| **Hashd ops console** | In-fiction prompt inside `HashdTerminal.razor` (`rig0>`) | **Yes** — withdraw, upgrade, start/stop, stats |
| **Rack LCD** | `TextRenderer` on linked GPU rack — hash / cores / rate | Telemetry only |

**“Console” in design docs = ops console on the Bitcoin Miner entity**, not the developer `>` bar. See `PHYSICAL_TERMINAL_DOCTRINE.md`.

## Economy model

- **BTC wallet lives on the hub** (`BitcoinMinerHubEntity.BitcoinAmount`).
- Linked **GPU racks credit the hub** on each mining payout tick.
- Player **sells BTC from the hub** UI — not per-rack balances.
- **Hardware upgrades** (CPU clock / cores) still apply to a **selected linked rack**; cash comes from the player wallet via existing DXRP pay RPCs.

## Login / open flow (required before any mining ops)

1. Player **USE** the hub — everyone sees the **gatekeeper** shell; nobody passes it without the right Steam ID or PIN.
2. **Dormant hub** (`AccessPinIsSet == false`) — entity checks spawner Steam ID (`BaseEntity.Owner`). **Only the spawner** sees **SET PIN**; everyone else stays on **GATEKEEPER LOCKED** (no power, mining, or sell).
3. **Wake** — spawner clicks **SECURE BOOT → SET PIN**, enters 4 digits twice on the graphical numpad; hub is **awakened**. No `auth>` typing on first boot.
4. **Return visits** — click **ENCRYPTED — PIN REQUIRED**, enter 4 digits on numpad (~15 min session) → power gate (if offline) → `rig0>` console.
5. **4-digit baseline** — host stores hash only. Future: **Wallet Cipher** upgrades lengthen PIN (4 → 6 → 8 → 10) for hacker crack roleplay.
6. **No command executes** without PIN session once configured — sell, power, mining RPCs, upgrades all host-gated.
7. Player types `mining start`, `upgrade`, `bitcoin sell`, etc. at **`rig0>`** after unlock.

**No `hashd` / `mine` ConCmds in shipped builds** — players never open mining from the developer console.

## Editor / staff helpers (not player gameplay)

| Command | Purpose |
|---------|---------|
| `lp_spawn_bitcoin_miner_hub` | Place hub in map |
| `lp_spawn_gpu_rack` / `lp_spawn_bitcoinmining_full_kit` | Place linked racks |
| `lp_hashd_preview` | Editor smoke — prefer **USE hub** for real playtests |

Strip `BitcoinMiningDevSpawn.cs` before portal publish. Do not document ConCmds as a playtest path.

## Code seams

| File | Role |
|------|------|
| `BitcoinMinerHubEntity.cs` | **Only** `IPressable` open path; hub wallet + sell |
| `GpuRackEntity.cs` | Passive compute; credits linked hub on tick |
| `HashdTerminal.razor` | Ops command dispatch; reads hub balance |
| `HashdCommandHost.cs` | **Dev-only** ConCmd shim (local build) |
| `GpuRackRegistry.cs` | Linked racks for active hub session |
