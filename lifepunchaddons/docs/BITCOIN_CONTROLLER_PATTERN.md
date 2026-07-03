# Bitcoin — controller pattern (responsibilities only)

> **Status:** Active — canonical design roles; implementation proof tracked separately in `TECH_DEBT.md`  
> **Why does this exist?** So every contributor knows **who owns what** before touching code.  
> **How:** Implementation lives in `bitcoinmining` code; drift tracked in `TECH_DEBT.md`.  
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

## Terminal (operator interface + defense surface)

**Owns:**

- CRT boot sequence, command line UX, sidebar commands/status
- Sending commands **to** hub/rack logic (never authoritative ledger)
- Farm readout while open (mirror of hub + rack state)
- Player education copy (`help`, errors, link hints)
- Its endpoint defense/capability profile (one authoritative logical record — see DECISION-0010)

**Does NOT own:**

- Mining tick loop
- Wallet balance authority (displays hub truth)
- Direct upgrade purchase UI on the CRT (universal home in LpHashdPanel)
- Mining authority, the farm ledger, purchase billing, or Rack hardware state

**G0 single-authority note:** HASHD Terminal owns presentation, command-session state, and its endpoint defense/capability profile. It does not own mining authority, the farm ledger, purchase billing, or Rack hardware state.

If Hub persistence serializes the Terminal profile, the Hub acts as infrastructure only — there must not be two independently mutable copies.

**Never mines.** Closing the terminal does not stop mining — Hub permission and Rack execution continue. Defense tracks on Terminal make the operator surface harder to attack. The Terminal CRT is an operating console, not a second shop.

---

## GPU Rack (worker) — computation

**Owns:**

- Local hash work simulation while mining
- Undeposited BTC **buffer** (per-rack cap before deposit required)
- **Hardware upgrades** (target): thermals, OC, power, buffer expansion
- Local telemetry (temp, fan, power draw — gameplay-facing)
- Local reference to linked hub (for telemetry RPC) — **rack owns link state locally**; hub owns registry membership and link/unlink **validation**

**Does NOT own:**

- Hub wallet
- Global mining schedule policy
- Controller-tier upgrades
- Link/unlink **registry** (hub authoritative)

**Standard rack:** 1.0× base yield · buffer `max($10,000 USD, 1 BTC)` (target).  
**Advanced rack:** 2.0× base yield · buffer `max($20,000 USD, 2 BTC)` (target).

---

## Single-owner summary

```text
Every gameplay field has ONE authoritative owner.

Hub owns mining policy and operation authority.
GPU Racks own mining execution and local buffers.

Terminal owns presentation and command-session state.

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
