# Bitcoin Miner terminal doctrine (v2)

**Owner canon (2026-06).** Parent: `addons/docs/PHYSICAL_TERMINAL_DOCTRINE.md`. Production laws: `addons/docs/CYBER_REFERENCE_LAWS.md`.

## Two surfaces (hub body vs HASHD monitor)

| Surface | Entity | Opens | Typing? |
|---------|--------|-------|---------|
| **Hub management** | `bitcoin-miner` (Ophion) | `LpHashdPanel` — Overview / Racks / Settings | **No** — clickable dashboard |
| **Ops console** | `bitcoin-terminal` CRT | `LpBitcoinTerminalPanel` — `rig0>` | **Yes** — mining, sell, status |

| Entity | Role | Player USE? |
|--------|------|-------------|
| **Bitcoin Miner** (`bitcoin-miner`) | Hub — power, link racks, upgrades, PIN | **Yes** → admin panel |
| **HASHD monitor** (`bitcoin-terminal`) | rig0 ops console | **Yes** → CRT |
| **GPU Rack** (`gpu-rack` / large) | Linked compute | **Yes** → CRT (focused rack); mine/stop/sell still typed |

Terminal finds nearest hub within `LinkRange` (default 512u). Racks link via `LinkedHubId` (kit spawn or placement flow).

## Surfaces (do not conflate)

| Surface | What it is | Mining / economy? |
|---------|------------|-------------------|
| **Developer console** | s&box `>` — `lp_bitcoin_*` dev spawn / preview only | **Never** for players |
| **Hub panel** | `LpHashdPanel` | Power, metrics, upgrades — **no** mine/stop/sell |
| **CRT** | `LpBitcoinTerminalPanel` | **Yes** — `mining start/stop`, `sell`, `status` |
| **Rack LCD** | World telemetry (when wired) | Display only |

## Economy model (v2 code)

- **BTC balance per linked rack** — `LpBitcoinRackEntity.BitcoinAmount` (mining ticks on host).
- Player **sells from terminal** — `sell` / `sell all` credits player wallet via DXRP pay path.
- **Hardware upgrades** — hub RPCs (`RequestUpgradeCpu` / `RequestUpgradeCores`); cash from player wallet.
- **Hub authority** — `IsPowered`, `CanOperateTerminal`, owner/PIN (`LpBitcoinHubEntity`).

Populate exact payout constants in `BITCOIN_REFERENCE_IMPLEMENTATION.md` on sign-off.

## Login / open flow

1. **USE hub** → `LpHashdPanel` (PIN gate H9 when wired).
2. **USE terminal or rack** → CRT boot splash → `rig0>` (blocked if hub off).
3. **No player job verbs** in dev ConCmds in shipped builds — `LpBitcoinDevSpawn` removed before portal publish.

## Code seams (v2)

| File | Role |
|------|------|
| `LpBitcoinHubEntity.cs` | Hub `IPressable`; power; owner/PIN; upgrades |
| `LpBitcoinTerminalEntity.cs` | CRT prop; hub range link |
| `LpBitcoinRackEntity.cs` | Mining tick; rack USE → CRT |
| `LpBitcoinTerminalPanel.razor` | Gray CRT + boot graphic |
| `LpHashdPanel.razor` | Amber hub admin |
| `LpBitcoinTerminalCommands.cs` | rig0 command dispatch |
