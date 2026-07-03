# Banker job — integration map (draft)

> **No code yet.** Use this when greenlit to avoid duplicating hacker/bitcoin systems.

## RP triangle

```text
Civilian ──deposit──► Bank vault (interest)
   │                      │
   │ wallet cash          │ bank-owned miners (BTC → branch pool)
   ▼                      ▼
Hacker terminal ──scan/hack──► wallet ONLY (never vault)
   │
   └──triggers alert──► Bank security terminal (sentinel.exe)
```

## Reuse (compose, don't fork)

| Existing addon | Reuse | Bank-specific |
|----------------|-------|---------------|
| `bitcoinmining` | `BitcoinMinerHubEntity` hub wallet, rack link, `HashdTerminal` layout patterns | Bank treasury credit target; job-gated USE; `vaultd` skin |
| `hackerjob` | `HackerTerminal` ops console shell, PIN/session host patterns | **Defense** commands only on security terminal; no wallet theft |
| `visiblepocket` | Pocket cash is what hackers steal; vault is separate store | Teller deposit = wallet → vault RPC |
| `governmentdatacenter` | Gov tax miner → city cash (reference for treasury sinks) | Bank branch pool vs city treasury — keep ledgers separate |

## Explicit non-goals (Phase 1)

- No vault drain via hacker `hack` command.
- No duplicate civilian hashd hubs for bankers (bank miners are institution-owned).
- No economy transfers in C# until owner + Opus sign-off.

## First code file (when greenlit)

`BankVaultLedgerService.cs` — host singleton; deposit/withdraw/accrual; audit hooks.
