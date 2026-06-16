# Bitcoin Miner terminal doctrine (v2)

**Owner canon (2026-06).** Parent: `addons/docs/PHYSICAL_TERMINAL_DOCTRINE.md`. Production laws: `addons/docs/CYBER_REFERENCE_LAWS.md`.

## Two surfaces (hub body vs HASHD monitor)

| Surface | Entity | Opens | Typing? |
|---------|--------|-------|---------|
| **Hub management** | `bitcoin-miner` (Ophion) | `LpHashdPanel` — Overview / Racks / Wallet / Settings | **No** — clickable dashboard + PIN gate |
| **Ops console** | `bitcoin-terminal` CRT only | `LpBitcoinTerminalPanel` — `rig0>` | **Yes** — mining, deposit, status |

| Entity | Role | Player USE? |
|--------|------|-------------|
| **Bitcoin Miner** (`bitcoin-miner`) | Hub — power, PIN, wallet, rack upgrades | **Yes** → admin panel |
| **HASHD monitor** (`bitcoin-terminal`) | rig0 ops console | **Yes** → CRT (nearest hub in range) |
| **GPU Rack** (`gpu-rack` / large) | Linked compute — accrues BTC on rack | **No** — racks do not open the CRT |

**Terminal access is only through the bitcoin terminal entity.** GPU Rack and Advanced GPU Rack never open the CRT. Mine/stop/deposit commands are typed at the terminal; rack USE is disabled.

Terminal finds nearest hub within `LinkRange` (default 512u). A linked terminal is required to **deposit** rack BTC into the hub wallet. Racks link via `LinkedHubId` (kit spawn or placement flow).

## Hub wallet flow (PIN-gated)

The hub is the operator's **wallet and control plane**:

1. Racks mine → BTC accrues on each rack (`LpBitcoinRackEntity.BitcoinAmount`).
2. Operator USEs **bitcoin terminal** → CRT → `deposit` / `deposit all` / `deposit <index>` moves rack BTC into **`HubWalletBtc`** on the linked hub.
3. Operator USEs **hub** → PIN unlock → **Wallet** tab → cash out a specific amount or **Cash out all** to in-game bank (DXRP wallet pay path).

**Non-persistence:** Hub wallet BTC does **not** survive hub entity destruction or DXRP client disconnect cleanup — cash out before teardown. Rack pending BTC on destroyed racks is likewise lost. Future: hub-to-hub transfer, black market purchases from hub wallet.

## Surfaces (do not conflate)

| Surface | What it is | Mining / economy? |
|---------|------------|-------------------|
| **Developer console** | s&box `>` — `lp_bitcoin_*` dev spawn / preview only | **Never** for players |
| **Hub panel** | `LpHashdPanel` | Power, metrics, upgrades, **wallet cashout** — no typed commands |
| **CRT** | `LpBitcoinTerminalPanel` | **Yes** — `mining start/stop`, `deposit`, `status` — **not** direct bank sell |
| **Rack LCD** | World telemetry (when wired) | Display only |

## Economy model (v2 code)

- **BTC balance per linked rack** — mining ticks on host while hub powered + rack mining.
- **Hub wallet** — `LpBitcoinHubEntity.HubWalletBtc`; filled by terminal deposit RPCs.
- **Cash out** — hub admin Wallet tab or `RequestCashOutHub` / `RequestCashOutAllHub`; credits player bank via `LpBitcoinWallet.TryPay`.
- **No rack USE → sell** — `sell` at CRT returns an error directing operators to hub wallet cashout.
- **Hardware upgrades** — hub RPCs (`RequestUpgradeCpu` / `RequestUpgradeCores`); cash from player wallet.
- **Hub authority** — `IsPowered`, `CanOperateTerminal`, owner/PIN (`LpBitcoinHubEntity`).

Populate exact payout constants in `BITCOIN_REFERENCE_IMPLEMENTATION.md` on sign-off.

## Login / open flow

1. **USE hub** → `LpHashdPanel` (PIN gate when configured).
2. **USE bitcoin terminal** (not rack) → CRT boot splash → `rig0>` (blocked if hub off or no hub in range).
3. **No player job verbs** in dev ConCmds in shipped builds — `LpBitcoinDevSpawn` removed before portal publish.

## Code seams (v2)

| File | Role |
|------|------|
| `LpBitcoinHubEntity.cs` | Hub `IPressable`; power; owner/PIN; `HubWalletBtc`; deposit/cashout RPCs |
| `LpBitcoinTerminalEntity.cs` | CRT prop; hub range link; sole player path to CRT |
| `LpBitcoinRackEntity.cs` | Mining tick; `Press` returns false (no CRT) |
| `LpBitcoinTerminalPanel.razor` | Gray CRT + boot graphic |
| `LpHashdPanel.razor` | Amber hub admin — wallet cashout UI |
| `LpBitcoinTerminalCommands.cs` | rig0 command dispatch (`deposit`, not `sell`) |
