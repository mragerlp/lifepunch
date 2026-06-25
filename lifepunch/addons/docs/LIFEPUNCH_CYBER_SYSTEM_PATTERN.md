# LIFEPUNCH™ — Cyber system pattern (reusable)

> **Why does this exist?** Every cyber profession (Bitcoin, Banker, Hacker, …) shares one stack — clone the pattern, not reinvent entities.  
> **How:** Map lane entities to the five layers before Phase A code.  
> **Parent:** `lifepunch/docs/LIFEPUNCH_GAMEPLAY_LAWS.md` (Law G0, G8, G9)  
> **Machine stack:** `LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md`  
> **Bitcoin instance:** `BITCOIN_CONTROLLER_PATTERN.md` · `BITCOIN_DATA_FLOW.md`

Every LIFEPUNCH cyber addon should map to this stack **before** new mechanics are invented.

---

## The five layers

```text
Controller          — authoritative brain; persistent state; economy hooks
        ↓
Operator Interface  — how the player sees and commands (terminal, panel, USE)
        ↓
Worker Nodes        — world entities that do the work (compute racks, worker devices, …)
        ↓
Shared Economy      — DXRP wallet, portal items, job payouts (gamemode integration)
        ↓
Persistent State    — host-synced; survives UI close; single owner per field
```

---

## Layer responsibilities

| Layer | Owns | Must NOT own |
|-------|------|--------------|
| **Controller** | Job logic, scheduling, validation, upgrades (controller tier), alerts, ledger | Per-node animation-only fakery without state |
| **Operator Interface** | Presentation, commands, status readout, copy | Duplicate ledger or tick loops |
| **Worker Nodes** | Local work simulation, buffers, node upgrades, telemetry | Global wallet, cross-job permissions |
| **Shared Economy** | Cash/BTC grants via DXRP APIs | Custom parallel currency without owner approval |
| **Persistent State** | Save/load shape, RPC authority | Client-only truth |

**Law G0:** One authoritative owner per state field. See `LIFEPUNCH_GAMEPLAY_LAWS.md`.

---

## Standard entity mapping

| Pattern slot | Bitcoin (lpbitcoin) | Future examples |
|--------------|---------------------|-----------------|
| Controller | **Hub** (`bitcoinhub`) | Bank vault server, hack C2, factory PLC |
| Operator Interface | **Hub admin panel** + **HASHD Terminal** (CRT) | Teller UI, exploit console |
| Worker Nodes | **GPU Racks** (2 standard + 1 advanced) | Bank processing nodes, compromised compute devices, assembly machines |
| Shared Economy | Hub wallet cashout, portal BTC redeem | Wire transfers, fence payouts |
| Persistent State | Hub entity + linked rack registry | Account records, heat maps |

---

## Upgrade split (controller vs hardware)

> Does this make the **controller smarter**, or the **hardware stronger**?  
> Nothing else.

| Tier | Buyer surface | Examples |
|------|---------------|----------|
| **Controller** | Hub upgrades tab | Scheduler, security, dispatch efficiency, yield policy |
| **Hardware** | Servers / per-rack panel | Hashrate, cooling, buffer capacity, thermals |

Terminal carries **no upgrade shop** — it commands and displays only.

Canon detail: `BITCOIN_UPGRADE_TAXONOMY.md`.

---

## Interaction loop (generic)

```text
Player approaches Operator Interface
        ↓
Command or USE → Controller validates
        ↓
Controller updates config / state
        ↓
Worker Nodes execute (may continue while UI closed)
        ↓
Results accumulate in the authoritative worker buffer or controller ledger defined by the lane
        ↓
Validated deposit/transfer moves value into the controller ledger
        ↓
Operator Interface reflects state on next open
```

**Bitcoin:** rack-local undeposited BTC until `deposit`; hub wallet after deposit.

Mining continues when the terminal closes — the Controller keeps running.

---

## Inheritance checklist (new cyber lane)

Before Phase A code:

| # | Gate |
|---|------|
| 1 | Name Controller, Operator Interface, Worker Nodes for this job |
| 2 | Map each to a placeable entity slug |
| 3 | List what Hacker / Banker / … will reuse from Bitcoin (Law 1) |
| 4 | Confirm upgrade split (controller vs hardware) |
| 5 | Add row to `PATTERN_LIBRARY.md` |
| 6 | Architect CURSOR BRIEF approved by owner |

---

## Related docs

| Doc | Role |
|-----|------|
| `CYBER_REFERENCE_LAWS.md` | Production gate Laws 1–11 |
| `PATTERN_LIBRARY.md` | Pattern index |
| `BITCOIN_CONTROLLER_PATTERN.md` | Bitcoin slot fill-in |
| `BITCOIN_DATA_FLOW.md` | Bitcoin data ownership diagram |
| `BITCOIN_UPGRADE_TAXONOMY.md` | Bitcoin upgrade ownership |
| `ACTIVE_WORKSTREAM.md` | Single lane gate |

---

*v1.0 — 2026-06-25 — Architect Review*
