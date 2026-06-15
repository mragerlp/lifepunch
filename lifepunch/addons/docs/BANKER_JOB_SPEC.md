# LIFEPUNCH Banker Job for DXRP — Design Spec (DRAFT)

> **Status: spec-only / not greenlit for build.** Manifest: `addons.json` → **`bankerjob`**
> (`status: foundation-draft`). **Blocked on:** bitcoinmining + hackerjob core ship, DXRP bank/wallet
> API clarity, owner sign-off. Economy + interest = **Tier-1 Opus** — no transfer logic until Phase 2.
>
> Owner intent (Jun 2026): a **banker job** with a **vault** (invest cash → earn interest), **bank-owned
> crypto mining** (ties to civilian bitcoin mining fiction), and **bank security** that creates RP tension
> with the **hacker job** — without breaking the rule that hackers steal **wallet only, never bank**.

---

## 1. Concept (owner vision)

| Pillar | Player fantasy | LifePunch hook |
|--------|----------------|----------------|
| **Vault** | Deposit wallet cash → earn interest over time | Server-authoritative ledger; hackers cannot drain vault (complements `HackerJob.BankUntouchable`) |
| **Bank crypto** | The branch runs its own miners — "banks adopt BTC" | Reuse **bitcoinmining** hub/rack patterns under **bank ownership** (separate wallet from civilian hashd) |
| **Security** | Guards / security staff monitor terminals, counter intrusions | Terminal skills overlap hacker **defense** UI (alerts, trace, lockdown) — not a clone of `cornerman.exe` theft loop |
| **RP triangle** | Civilians bank · hackers hit wallets · bank/security responds | Hacker scan/hack stays wallet-only; vault breaches (if any) are a **future signed** escalation, not Phase 1 |

**Confidence note:** Interest rates, miner ROI, and security-vs-hacker balance are easy to get wrong
(inflation, afk farming, griefing). This spec exists so we **design once** and build **after** core addons ship.

---

## 2. Job roles (first pass)

| DXRP job (TBD names) | Uses | Terminal / entity |
|----------------------|------|-------------------|
| **Banker / Teller** | Open accounts, accept deposits, view vault summary | `bank-teller-terminal` (placeable) |
| **Bank Manager** | Set rates (capped), approve large withdrawals, miner power | `bank-vault-hub` (vault + optional hashd-style panel) |
| **Bank Security** | Intrusion monitors, trace alerts, temporary lockouts | `bank-security-terminal` (defensive ops console) |

Exact job names and DXRP `Job` registration are **open** — map at sign-off with `admin-panel` / portal jobs.

---

## 3. Architecture sketch (modular — no spaghetti)

Aligned with `REUSABLE_ADDON_FRAMEWORK.md`, `PHYSICAL_TERMINAL_DOCTRINE.md`, `TERMINAL_BRAND_MATRIX.md`.

### 3.1 Vault ledger (interest)

- **Host-only** account store: `steamId → { balance, lastAccrualUtc, tier }`.
- **Deposit:** `[Rpc.Host]` moves cash **wallet → vault** via DXRP wallet API (amount validated server-side).
- **Withdraw:** vault → wallet (cooldown / manager approval for large sums — TBD).
- **Interest:** periodic host tick (e.g. every N minutes) applies `rate * balance` with caps and minimum activity rules.
- **Single swap point (future):** `BankVaultLedgerService.cs` — all vault money movement.

### 3.2 Bank crypto mining

- **Do not fork** `BitcoinMinerHubEntity` logic — **compose** or share a thin `IBankOwnedMiner` policy:
  - Bank hub credits **city/bank treasury** or **branch pool**, not player civilian wallets.
  - Prefabs: `bank-miner-hub`, `bank-gpu-rack` (reskin or child prefab of bitcoinmining assets).
- Civilian `lifepunch.bitcoinmining` stays separate; bank miners are **job-gated** placement or map-fixed branch props.

### 3.3 Security vs hacker

- Hacker canon: **wallet theft only** (`hackerjob/docs/HACKER_PHASE2_ECONOMY_PREP.md`).
- Bank security **Phase 1:** read-only — alert when `HackerScanService` flags activity in branch radius (hook TBD).
- Bank security **Phase 2+:** `lockdown`, `trace`, `freeze-withdrawal` — host RPCs; never client-trusted.
- Optional: security staff get **limited** puzzle/defense minigame on `bank-security-terminal` (mirror hacker UI patterns, different fiction).

### 3.4 UI / brand (draft)

| Surface | Fiction program | Accent (draft) | Layout family |
|---------|-----------------|----------------|---------------|
| Teller terminal | `vaultd` (deposit / balance) | Navy + gold `#C9A227` | Ops console (teller rail) |
| Vault hub | `vaultd / branch` (manager) | Same + amber BTC rail for bank miners | HASHD-like rail **or** ops console |
| Security desk | `sentinel.exe` | Steel blue `#4A6FA5` | Ops console (alert + trace) |

Add rows to `TERMINAL_BRAND_MATRIX.md` when art direction locks.

---

## 4. Dependencies (build order)

| Prerequisite | Why |
|--------------|-----|
| **bitcoinmining** hub wallet + PIN gate shipped | Proven host ledger + terminal mount pattern |
| **hackerjob** Phase 1 terminal + rack stable | RP triangle needs working hacker USE path |
| **Hacker Phase 2 economy** sign-off | Defines what bank is *protecting* vs what stays wallet-only |
| **DXRP wallet/bank APIs** documented | Vault must use same authority as DXRP economy (no parallel fake bank) |
| **Map / branch art** | Vault room, teller line, miner closet — Hammer or imported branch kit |

---

## 5. Anti-abuse (must-haves at sign-off)

- Server validates job, distance, deposit/withdraw amounts, interest accrual caps.
- No negative vault; no client-initiated interest claims.
- AFK interest farming: minimum playtime / branch proximity / daily accrual cap — TBD.
- Audit every vault mutation (`AUDIT_LOG_REFERENCE.md`).
- Bank miner payouts capped; cannot out-earn civilian mining without explicit balance pass.

---

## 6. Folder layout (scaffold only)

```
lifepunch/addons/
  docs/BANKER_JOB_SPEC.md          ← this file (manifest spec)
  Code/Addons/lifepunch/bankerjob/
    docs/INTEGRATION_MAP.md        ← links to hacker / bitcoin / pocket
    .gitkeep                       ← no gameplay code until greenlit
  Assets/addons/lifepunch/bankerjob/
    ASSET_INVENTORY.md             ← vault door, teller desk, terminals (TBD art)
    entities/                      ← empty until ModelDoc pass
```

---

## 7. Open questions (owner decisions)

1. **Interest model:** flat % vs tiered by balance vs server-wide prime rate?
2. **Vault vs DXRP native bank:** extend DXRP bank account or LifePunch-only side ledger?
3. **Bank crypto:** branch profit sink vs player-investable crypto fund?
4. **Security job:** separate DXRP job or sub-role of Police?
5. **Heist fantasy:** ever allow vault breach event (heist addon) or permanently hacker-wallet-only?

---

## 8. Related docs

- `addons/docs/CYBER_JOBS_POLISH_CHECKLIST.md` — polish phases G-A through G-D (when greenlit)
- `hackerjob/docs/HACKER_PHASE2_ECONOMY_PREP.md` — wallet-only theft
- `bitcoinmining/docs/BITCOINMINING_TERMINAL_DOCTRINE.md` — hub wallet pattern
- `VISIBLE_POCKET_SPEC.md` — P3 bank prop (deposit box) may overlap teller UX
- `TERMINAL_BRAND_MATRIX.md` — terminal naming
- `TECH_DEBT.md` → **BANKER-01**
