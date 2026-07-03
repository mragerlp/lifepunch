# LifePunch Government Database & Datacenter

> **Status:** GREENLIT concept + economy constants (Green). Entity implementation = **Opus on Red**.  
> Addon ident: **`governmentdatacenter`** · Terminal matrix: **`TERMINAL_BRAND_MATRIX.md`**

---

## 1. Owner vision (2026-06-11, updated 2026-06-15)

The **government cyber** stack is the **protagonist** counterpart to the **Hacker** criminal lane (`TERMINAL_BRAND_MATRIX.md` criminal vs protagonist split):

| Piece | Entity | Role |
|-------|--------|------|
| **Hub** | `government-server-rack` | Powers and links the Government Terminal; upgrade surface for lawful cyber |
| **Terminal** | `police-terminal` (Government Terminal) | **lifepunchnet** cyan CRT · `lifepunch-ops.exe` — trace, audit, counter-intrusion |
| **Treasury miner** | `government-data-center` | Autonomous BTC miner on map — **always mining**, no player start/stop |

**Government Data Center** behavior:

- **Blue console** aesthetic (lifepunchnet cyan `#00D4FF`) — player hashd stays **green** Cornerman chrome
- **Always mining** — no player start/stop
- **Every 30 minutes:** deposit **0%–30%** of accumulated BTC balance as **cash into city funds** (tax rate set by mayor)
- **No player withdraw** — treasury only; mirrors BitcoinMiningAddon accrual math
- **$50,000 cap** on accumulated BTC value (= **~33.33 BTC** at $1,500/BTC — same rate as player BitcoinMiningAddon)
- **Government / Law Enforcement jobs cannot spawn or USE player lifepunchbitcoin entities** — treasury is this datacenter only
- **FBI protagonist loop:** counter **advanced hacker (red)** breaches on **bitcoin miners**, **bank**, and **city funds** via lifepunchnet terminal
- **Phase F gate:** deep-dive FBI features **after Hacker Job** (advanced terminal + target policy) ships

Legacy code name `government-tax-miner` may remain until entity rename migration.

**Cybersecurity Officer** — owner builds separately.  
**SWAT job** — future; CS2 models (`SWAT_JOB_SPEC.md`).

---

## 2. Economy (reuse BitcoinMiningAddon)

Player BitcoinMiningAddon already defines:

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

| Entity | Job access | Role |
|--------|------------|------|
| `government-data-center` | Map/server placed | Autonomous tax miner → city cash drip |
| `government-server-rack` | Police / FBI / gov jobs | Hub — powers Government Terminal |
| `police-terminal` | Police / FBI / gov jobs | `lifepunch-ops.exe` — protagonist cyber desk |
| `advanced-hacker-terminal` | Hacker (purchased upgrade) | `vengeance.exe` — **opposing** breach tool |

Hacker **starter** terminal = wallet hacks only. **Purchased advanced** = `govdb` / `infil` on treasury nodes + large-scale targets.

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
| 2 | Red Opus | `GovernmentTaxMinerEntity` port from BitcoinMiningAddon, city funds RPC |
| 3 | Red | Blue-console prefab + datacenter models |
| 4 | Red | `PoliceTerminal` Razor shell (lifepunchnet cyan) |
| 5 | Opus | Advanced hacker ↔ police counterplay + audit log |

---

## 7. Anti-abuse

- Tax payouts **host-only**
- BTC cap enforced server-side
- Hacker govdb breaches server-validated (never client-trusted)
- All treasury events auditable (`AUDIT_LOG_REFERENCE.md`)
