# Hacker Server Rack — power + upgrades

**Entity:** `server-rack` (`HackerServerRackEntity`) — **starter hub** (job kit; low cost)  
**Advanced entity:** `advanced-server-rack` — **purchased upgrade** (expensive; pairs with Vengeance red terminal)  
**Menu:** `HackerServerRackMenu.razor` (hashd-style green ops console)  
**Powers:** `hacker-terminal` (cornerman.exe) + `advanced-hacker-terminal` (vengeance.exe) within **8m horizontal / 4m vertical**

## Power

| State | Behavior |
|-------|----------|
| **POWER ON** | Linked terminals accept interact / `cornerman` command; CRT shows `[ STANDBY ]` |
| **POWER OFF** | Terminal open denied; CRT shows `[ OFFLINE ]` |

## Target tier gating (terminals — not rack)

| Target | Standard (cornerman) | Advanced (vengeance) |
|--------|----------------------|----------------------|
| Player wallets | Yes | Yes |
| Bitcoin Miners (GPU racks) | No | Yes |
| Government Data Center | No | Yes |

Policy: `HackerHackTargetPolicy.cs`

## Upgrades (installed on rack, apply to all linked terminals)

### Detection (4 tiers)

Reduces chance that a **failed hack** triggers police counterplay.

| Tier | Alert chance |
|------|--------------|
| L0 | 100% |
| L1 | 75% |
| L2 | 50% |
| L3 | 25% |
| L4 | 10% |

Counterplay uses DXRP **`/panic`** (`GameManager.BroadcastPanic`) — red position beacon for police/medics. **Wanted** status is a separate governance hook (Phase 2: `Governance.WantedHost`).

Costs: $2,500 / $6,000 / $12,000 / $22,000

### Puzzle Time (4 tiers)

Base **45s** + **8s per tier** → L4 = **77s** puzzle window.

Costs: $2,000 / $5,000 / $10,000 / $18,000

### Reward Yield (3 tiers)

Multipliers on successful hack payout (Phase 2 economy): **1.00× / 1.25× / 1.55× / 2.00×**

Costs: $3,500 / $9,000 / $18,000

### Cooldown (3 tiers)

Base **120s** − **25s per tier** (floor **30s**).

Costs: $3,000 / $8,000 / $15,000

## Suggested future upgrades (not implemented)

| Idea | Why |
|------|-----|
| **Ghost Trace** | Shorter police marker duration on fail (pairs with Detection) |
| **Scan Range** | Wallet probe radius tiers for cornerman scan |
| **Signal Scrambler** | Delay before Wanted status applies |
| **Parallel Socket** | Second concurrent puzzle slot (high risk/reward — Opus review) |

**Not recommended:** Firewall Bypass on standard tier to hack miners — breaks the vengeance tier identity.

## Dev commands

```text
lp_spawn_server_rack          # rack only (power OFF)
lp_hacker_kit_preview         # powered rack + cornerman + vengeance
lp_spawn_hacker_terminal
lp_spawn_advanced_hacker_terminal
```

## Phase 2 (Opus)

- Charge wallet on upgrade install (`ChargeHost` + audit)
- Apply reward multiplier on successful wallet theft
- Enforce hack cooldown server-side
- Wanted status roll separate from 911 panic
- Job gate: Hacker job only
