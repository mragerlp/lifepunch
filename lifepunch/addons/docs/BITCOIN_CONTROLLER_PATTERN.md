# Bitcoin — controller pattern (responsibilities only)

> **Status:** Active  
> **Why does this exist?** So every contributor knows **who owns what** before touching code.  
> **How:** Implementation lives in `bitcoinmining` code; drift tracked in `TECH_DEBT.md`.  
> **Status:** Canonical design — **no implementation** in this doc.  
> **Parent:** `LIFEPUNCH_CYBER_SYSTEM_PATTERN.md` · `LIFEPUNCH_GAMEPLAY_LAWS.md` G0  
> **Player fantasy:** `BITCOIN_PLAYER_DESIGN.md`


---

## Entities

| Entity | Slug | Role |
|--------|------|------|
| **Hub** | `bitcoinhub` | **Controller** — mining operation brain |
| **Terminal** | `hashdterminal` | **Operator interface** — CRT commands + status |
| **GPU Rack** (standard) | `gpurack` ×2 max | **Worker** — hash computation |
| **Advanced GPU Rack** | `gpurack` (advanced slot) ×1 max | **Worker** — stronger default hardware tier |

Portal cap: **2 standard + 1 advanced** per operator/hub — locked.

---

## Hub (controller) — authoritative owner

**Owns:**

- Power state, PIN gate, hub registration of terminal and racks
- Mining operation config (which linked racks may run)
- Work dispatch metaphor (job schedule / pool connection — gameplay-facing)
- Hub wallet (deposited BTC, cashout to DXRP bank)
- **Controller upgrades** (target): clock path / core count / security / encryption
- Alerts, logs, telemetry aggregation
- Validation of shares / payouts (gameplay-simplified)

**Does NOT own:**

- Typed command parsing (terminal input layer)
- Per-rack mesh animation-only state without hub sync
- Player-facing CRT scrollback implementation detail

---

## Terminal (operator interface) — presentation only

**Owns:**

- CRT boot sequence, command line UX, sidebar commands/status
- Sending commands **to** hub/rack logic (never authoritative ledger)
- Farm readout while open (mirror of hub + rack state)
- Player education copy (`help`, errors, link hints)

**Does NOT own:**

- Mining tick loop
- Upgrade purchases (hub panel or hub RPC — not terminal shop)
- Wallet balance authority (displays hub truth)

**Never mines.** Closing the terminal does not stop mining — hub + racks continue.

---

## GPU Rack (worker) — computation

**Owns:**

- Local hash work simulation while mining
- Undeposited BTC **buffer** (per-rack cap before deposit required)
- **Hardware upgrades** (target): thermals, OC, power, buffer expansion
- Local telemetry (temp, fan, power draw — gameplay-facing)
- Link/unlink registration at hub (via terminal `link` command → hub validates)

**Does NOT own:**

- Hub wallet
- Global mining schedule policy
- Controller-tier upgrades

**Standard rack:** 1.0× base yield · buffer `max($10,000 USD, 1 BTC)` (target).  
**Advanced rack:** 2.0× base yield · buffer `max($20,000 USD, 2 BTC)` (target).

---

## Single-owner summary

```text
Every gameplay system has ONE authoritative owner.

Hub owns mining.

Terminal owns presentation.

GPU Racks own computation.

Never duplicate ownership across entities.
```

---

## Related

| Doc | Role |
|-----|------|
| `BITCOIN_UPGRADE_TAXONOMY.md` | Who sells which upgrade |
| `BITCOIN_DATA_FLOW.md` | Player → terminal → hub → rack → wallet |
| `BITCOINMINING_TERMINAL_DOCTRINE.md` | CRT command law |
| `reference/BITCOINMINING_THREE_ENTITY_ARCH.md` | Historical note — hub-centric model supersedes "terminal owns all" where they conflict |

---

*v1.0 — 2026-06-25 — Architect Review*
