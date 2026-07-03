# Government datacenter — roleplay pillar

**Addon:** `governmentdatacenter` · **Skin:** lifepunchnet cyan `#00D4FF`

---

## What it is

- **Landmark** on map — visible city infrastructure (**Government Data Center**)
- **Passive BTC treasury** — always mining (no player start/stop); mayor tax **0–30%** every 30m → city funds
- **$50,000 cap** at $1,500/BTC
- **Government Server Rack** — hub for lawful cyber kit (powers Government Terminal)
- **Not player hashd** — gov/LE jobs **cannot** spawn lifepunchbitcoin miner entities

Players cannot withdraw treasury BTC directly — lawful jobs earn via **puzzles + lifepunchnet terminal**.

**Build order:** finish **Hacker Job** (red tier as breach antagonist) before deep-diving FBI counter-intrusion features.

---

## Who uses it

| Job | Hub | Terminal | Role |
|-----|-----|----------|------|
| **FBI / gov cyber** | `government-server-rack` | Government Terminal (cyan lifepunchnet) | Counter-hack, trace, audit — intercept breaches on **miners, bank, city funds** |
| **Cybersecurity** | Same hub | Same terminal | Hardening, incident response |
| **Mayor** | — | Sets tax rate on data center | Affects treasury drip % |
| **Hacker (purchased red)** | `advanced-server-rack` | Vengeance terminal | Criminal breach — hard puzzles, high risk |

---

## Lawful pay loop

1. Open `lifepunch-ops.exe` on government terminal.
2. Type auth command → solve **puzzle** (harder than wallet hack, easier than max-tier gov breach).
3. Host pays **$1,000–$2,500** band (pre-upgrade) from treasury drip budget — not unlimited.

Pay must feel **good but not broken** — action-job tiers hit harder per point than miner CPU tiers.

---

## Criminal breach loop

- **Advanced only** — standard cornerman cannot target datacenter or player bitcoin miners.
- Puzzles hard; success payout capped; failure triggers police counterplay.
- Police terminal nearby enables **trace/audit** response RP.

---

## Assets needed (owner)

See `ASSET_INTAKE_CYBER_ECOSYSTEM.md` § governmentdatacenter.

---

## Related

- `GOVERNMENT_DATABASE_SPEC.md`
- `reference/GOVERNMENT_DATABASE_TERMINAL_SPEC.md`
