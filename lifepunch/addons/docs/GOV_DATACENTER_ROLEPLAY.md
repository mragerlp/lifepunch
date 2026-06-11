# Government datacenter — roleplay pillar

**Addon:** `governmentdatacenter` · **Skin:** lifepunchnet cyan `#00D4FF`

---

## What it is

- **Landmark** on map — visible city infrastructure
- **Passive BTC treasury** — always mining (no player start/stop)
- **$50,000 cap** at $1,500/BTC
- **Every 30 minutes:** `floor(btc × 1500 × mayorTaxRate)` → **city funds** (tax 0–30%)

Players cannot withdraw treasury BTC directly — lawful jobs earn via **puzzles + terminal**.

---

## Who uses it

| Job | Terminal | Role |
|-----|----------|------|
| **FBI** | Government terminal (cyan) | Counter-hack, trace, audit |
| **Cybersecurity** | Same terminal | Hardening, incident response |
| **Mayor** | Sets tax rate | Affects drip % |
| **Hacker (vengeance)** | Criminal breach | Hard puzzles, high risk |

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
