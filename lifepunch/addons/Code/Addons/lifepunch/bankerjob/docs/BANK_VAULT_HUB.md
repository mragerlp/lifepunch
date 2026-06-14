# Bank vault hub — entity design (draft)

> **Status:** design only · no `BankVaultHubEntity.cs` until bitcoin + hacker terminals verify in play.
> Parent pattern: `LIFEPUNCH_HUB_PATTERN.md`.

## One sentence

**`bank-vault-hub`** is the banker job's **server rack + bitcoin miner hub** — vault ledger, branch
power, linked teller terminals, bank-owned miners, and sentinel security desks.

## USE flow (mirror bitcoin hub)

```text
USE hub
  → PIN setup / unlock (manager)
  → power gate (branch offline until ON)
  → vault management panel (rail)
       · deposits summary
       · interest rate (read; manager edits elsewhere)
       · linked teller terminals
       · linked bank miners (hashd-style telemetry, credits branch)
       · security status (sentinel link health)
       · LOCKDOWN / FREEZE (self-defense host RPCs)
```

## Satellites

| Prefab | Links to hub | Program |
|--------|--------------|---------|
| `bank-teller-terminal` | 4m horizontal | `vaultd` — deposit / balance |
| `bank-security-terminal` | same branch | `sentinel.exe` — alerts, trace |
| `bank-gpu-rack` | mining link | credits hub branch pool |

## FBI / cyber hook (future)

Hub publishes `BranchAlert` events (host):

- `HackerScanInRange`
- `FailedPinBurst`
- `WithdrawalAnomaly`

`CyberOpsHubEntity` *(FBI job)* consumes feed for warrant/trace UI — does not replace `sentinel.exe`.

## Implementation order (when greenlit)

1. `BankVaultHubEntity.cs` — shell + PIN + power (clone bitcoin hub, swap ledger)
2. `BankVaultLedgerService.cs` — deposit/withdraw/accrual
3. `BankTellerTerminalEntity.cs` — `vaultd` UI (clone hacker terminal shell, navy/gold SCSS)
4. Reskin `bitcoin-miner` → `bank-vault-hub` art pass
5. `BankSecurityTerminalEntity.cs` — read-only alerts Phase 1

## Cornerman prep (no C#)

See `briefs/CORNERMAN_BANKER_HUB_RESEARCH.md` — terminology + DXRP wallet API notes for Red/Opus.
