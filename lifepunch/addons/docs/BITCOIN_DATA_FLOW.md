# Bitcoin — data flow (visual ownership)

> **Status:** Active  
> **Why does this exist?** Single diagram for **who owns data** — prevents terminal or rack from becoming a second wallet.  
> **How:** RPC names live in code; this doc is authority boundaries only.  
> **Parent:** `BITCOIN_CONTROLLER_PATTERN.md` · `LIFEPUNCH_GAMEPLAY_LAWS.md` G0

---

## Primary loop

```text
Player
  │
  ▼
Terminal (presentation — commands in, status out)
  │
  ▼
Hub (authoritative — config, wallet, dispatch, validation)
  │
  ▼
GPU Rack(s) (workers — hash, local buffer, telemetry)
  │
  ▼
Hub (accumulates deposited value, alerts, logs)
  │
  ▼
Wallet (hub ledger — cashout via Hub admin Wallet tab)
```

---

## Command path (player active)

```text
Player types at rig0>
  → Terminal validates boot / parses command string
  → Hub executes (or rack via hub delegate): link, mining start/stop, deposit, status
  → Hub updates authoritative state
  → Terminal mirrors new lines in CRT log
```

Terminal never writes wallet balance without hub confirmation.

Upgrade purchases (including Terminal defense tracks) are initiated from the universal Upgrades home in the Hub panel and executed by hub RPC. Terminal surface can display defense state and trigger commands, but authority lives on the hub.

---

## Mining path (player AFK)

```text
Hub powered + racks linked + mining started
  → Hub schedule allows rack tick
  → Each rack accrues undeposited BTC to local buffer
  → Buffer full → rack stops or alerts (target)
  → Player deposits via terminal `deposit` or hub UI (both → hub RPC)
  → Hub wallet increases
```

Terminal closed = **no change** to this loop.

---

## Upgrade path

```text
Player opens Hub admin (USE hub, powered, PIN)
  → Hub Upgrades tab: controller tiers (hub state)
  → Servers tab: per-rack hardware tiers (rack state, hub bills wallet)
```

```text
Terminal has NO upgrade purchase path.
```

---

## Ownership table

| Data | Authoritative owner | Mirrors |
|------|---------------------|---------|
| Hub powered / PIN | Hub | Terminal STATUS, LCD |
| Linked rack list | Hub (registry) | Terminal `racks`, hub Servers cards |
| Selected rack index | Terminal UI session (`LpBitcoinTerminalPanel._selectedIndex`) | Hub command targets via index at execute time |
| Mining permission (start/stop command) | Hub validates + delegates | Terminal log, hub cards |
| Mining execution state (`IsMining`, accrual tick) | Rack worker | Hub Servers telemetry, terminal STATUS |
| Undeposited BTC | Rack buffer | Hub Servers telemetry |
| Deposited BTC | Hub wallet | Hub Wallet tab |
| Controller upgrade levels | Hub (target) | Hub Upgrades tab |
| Hardware upgrade levels | Rack (target) | Servers upgrade sub-view |
| CRT scrollback | Terminal UI only | Not synced to hub |

---

## PvP / hacker (future)

```text
Hacker offense → targets Hub controller state (encryption spec)
Miner defense → Hub upgrade tracks
Racks keep hashing unless hub forces stop — hub is the prize
```

See `BITCOINMINING_ENCRYPTION_SPEC.md`.

---

*v1.0 — 2026-06-25 — Architect Review*
