# LifePunch Government Database & Datacenter

> **Status:** GREENLIT concept + economy constants (Green). Entity implementation = **Opus on Red**.  
> Addon ident: **`governmentdatacenter`** · Terminal matrix: **`TERMINAL_BRAND_MATRIX.md`**

---

## 1. Owner vision (2026-06-11)

The **government database** is represented in-world by **automatic government Bitcoin miners** in a datacenter:

- **Blue console** aesthetic (lifepunchnet cyan `#00D4FF`) — player hashd stays **green** Cornerman chrome
- **Always mining** — no player start/stop
- **Every 60 minutes:** deposit **0%–30%** of accumulated BTC balance as **cash into city funds** (tax rate)
- **No player withdraw** — treasury only; mirrors Bitminer accrual math
- **$30,000 cap** on accumulated BTC value (= **20 BTC** at $1,500/BTC — same rate as player Bitminer)
- **Police terminals** placed near tax miners — lifepunchnet ops UI, counter-intrusion / audit (like Hacker flow)
- **Advanced Hacking Terminal** (Vengeance red) is how Hackers breach govdb nodes

**Cybersecurity Officer** — owner builds separately.  
**SWAT job** — future; CS2 models (`SWAT_JOB_SPEC.md`).

---

## 2. Economy (reuse Bitminer)

Player Bitminer already defines:

| Field | Value |
|-------|-------|
| `BitcoinValue` | $1,500 / BTC |
| `BaseSpeed` | 0.005 |
| `MiningInterval` | 60 seconds |
| Accrual | `clock × 0.005 × cores` BTC per tick |

Government tax miner copies accrual, **removes** upgrades/sell/player RPCs, **adds**:

```text
hourlyCash = floor(btcBalance × 1500 × taxRate)   → city funds
btcBalance = min(btcBalance, 20)                   → $30K cap
taxRate ∈ [0.00, 0.30]
```

Code constants: `governmentdatacenter/GovernmentTaxMiner.cs`

---

## 3. Entities

| Entity | Job access | Terminal program |
|--------|------------|------------------|
| `government-tax-miner` | Server/map placed | LCD summary (blue) |
| `police-terminal` | Police / gov jobs | `lifepunch-ops.exe` |
| `advanced-hacker-terminal` | Hacker (hackerjob addon) | `vengeance.exe` |

Hacker **standard** terminal = wallet hacks. **Advanced** = `govdb` / `infil` on treasury nodes.

---

## 4. Police terminal (Phase 2)

Mirror Hacker terminal architecture:

- Boot lifepunchnet cyan chrome
- Commands TBD at Opus sign-off: `trace`, `audit`, `alert`, `warrant` stubs
- Placed adjacent to tax miners on map

Dev commands (constants only for now): `lp_spawn_police_terminal`, `lp_lifepunch_ops_ui`

---

## 5. Models — do we need them?

**Yes, for shipping** — but Phase 1 code/docs can proceed without meshes.

| Asset | Owner action |
|-------|----------------|
| Datacenter GPU rack / blue-console miner | Provide or approve fork of `gpu-rack` with cyan materials |
| Police CRT terminal | Can share hacker CRT study mesh with recolored materials |
| Map layout | Place miner clusters + police kiosks |

Green does **not** block on models — Red ModelDoc when art lands.

---

## 6. Phased rollout

| Phase | Lane | Deliverable |
|-------|------|-------------|
| 1 | Green | Spec, `GovernmentTaxMiner` constants, addons.json row, brand matrix |
| 2 | Red Opus | `GovernmentTaxMinerEntity` port from Bitminer, city funds RPC |
| 3 | Red | Blue-console prefab + datacenter models |
| 4 | Red | `PoliceTerminal` Razor shell (lifepunchnet cyan) |
| 5 | Opus | Advanced hacker ↔ police counterplay + audit log |

---

## 7. Anti-abuse

- Tax payouts **host-only**
- BTC cap enforced server-side
- Hacker govdb breaches server-validated (never client-trusted)
- All treasury events auditable (`AUDIT_LOG_REFERENCE.md`)
