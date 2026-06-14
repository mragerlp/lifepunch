# LifePunch hub pattern — one hub per job line

> **Canon (Jun 2026).** Every computer-heavy job uses the same shape: a **hub entity** (infrastructure +
> ledger + power) and **satellite entities** (terminals, miners, security desks) that link to it.
> New content = new prefabs that plug into the hub — not new economy spaghetti.

Applies to: **bitcoinmining** (shipped pattern), **hackerjob** (shipped pattern), **bankerjob** (draft),
**FBI / cybersecurity** (future), **governmentdatacenter** (treasury miner).

---

## The pattern

```text
                    ┌─────────────────┐
                    │   HUB ENTITY    │
                    │  PIN · power    │
                    │  ledger/wallet  │
                    │  link registry  │
                    └────────┬────────┘
           ┌─────────────────┼─────────────────┐
           ▼                 ▼                 ▼
    TERMINAL (USE)     SATELLITE A        SATELLITE B
    ops program UI     (compute / CRT)    (security / ATM)
```

| Role | Responsibility | Player types here? |
|------|----------------|--------------------|
| **Hub** | Owner stamp, optional PIN gate, power state, linked children, host ledger | **No** — USE opens hub **management** panel (rail) or PIN setup |
| **Terminal** | In-fiction program (`cornerman.exe`, `vaultd`, `sentinel.exe`) | **Yes** — ops console commands |
| **Satellite** | Passive link (GPU rack, server rack, bank miner, alarm panel) | **Rarely** — usually configured from hub rail |

---

## Shipped references

| Job | Hub entity | Terminal (USE → UI) | Satellites |
|-----|------------|----------------------|------------|
| **Bitcoin mining** | `BitcoinMinerHubEntity` | *(hub panel is the terminal)* · head CRT optional | `GpuRackEntity` |
| **Hacker** | `HackerServerRackEntity` | `HackerTerminalEntity` | — (rack powers CRT) |
| **Banker** *(draft)* | `BankVaultHubEntity` *(future)* | `BankTellerTerminalEntity` · `BankSecurityTerminalEntity` | `BankGpuRackEntity` *(reskin)* |
| **FBI / cyber** *(future)* | `CyberOpsHubEntity` *(TBD)* | `CyberOpsTerminalEntity` | ties to bank + hacker alerts |

---

## Hub responsibilities (checklist for new jobs)

1. **Spawn owner** — `Owner` SteamId from network owner / first USE caller (`TryBindSpawnOwnerHost` pattern).
2. **PIN gate** — optional 4-digit gatekeeper; session map per caller (reuse `*AccessPin` helpers).
3. **Power** — hub offline disables satellites (mining, terminal link, vault accrual).
4. **Link registry** — host-authoritative list of children in range (reuse `*Registry` static client cache pattern).
5. **Ledger** — all money movement host-only (`[Rpc.Host]`); one service class per hub.
6. **Open paths** — `Press` → PIN → power gate → management panel OR delegate to linked terminal.

---

## Banker hub proposal (`bank-vault-hub`)

**Entity:** `BankVaultHubEntity` — the **branch vault** (like server rack + bitcoin hub combined).

| Subsystem | Behavior |
|-----------|----------|
| **Vault ledger** | Deposits / withdrawals / interest accrual (host) |
| **Bank miners** | Linked `BankGpuRackEntity` credits **branch pool**, not player wallets |
| **Teller terminals** | Linked CRTs within 4m — `vaultd` deposit UI |
| **Security desks** | Linked `sentinel.exe` panels — alerts on hacker scan in branch radius |
| **Self-defense** | Manager can trigger lockdown / freeze withdrawals from hub rail (host RPC) |

**FBI / cybersecurity** does not replace bank security — it **responds** to hub-published alerts
(`CyberOpsHubEntity` subscribes to branch incident feed). Bank protects itself first; law enforcement
is escalation.

---

## RP triangle (bank + hacker + FBI)

```text
Civilian wallet ──deposit──► BankVaultHub (safe)
        │                         │
        │                         ├── bank miners → branch BTC pool
        ▼                         └── sentinel desks → lockdown / trace
Hacker terminal ──hack──► wallet ONLY
        │
        └── scan in branch ──alert──► Bank security + FBI cyber terminal
```

---

## Adding content later (why this matters)

| Want to add… | You add… | Hub change |
|--------------|----------|------------|
| New GPU tier | `bank-gpu-rack-tier2.prefab` | Register in link table |
| ATM prop | `bank-atm-terminal.prefab` | Link to vault hub; `vaultd` withdraw surface |
| Heist event *(if ever signed)* | map trigger | Host RPC on hub — not hacker wallet path |

---

## Related

- `PHYSICAL_TERMINAL_DOCTRINE.md` — hub + terminal pairing
- `BANKER_JOB_SPEC.md` — banker draft
- `bankerjob/docs/BANK_VAULT_HUB.md` — banker hub detail
- `TERMINAL_PLAYTEST_NOW.md` — live playtest commands
