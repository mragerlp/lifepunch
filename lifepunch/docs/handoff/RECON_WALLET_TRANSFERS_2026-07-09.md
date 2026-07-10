# RECON BRIEF — Wallet / Transfers

**Read-only.** No edits, no commits. Every claim carries its sensor.
Line numbers are `develop` @ `5177b98`.

---

## 0. Verdict first

Two defects that a restyle would inherit and hide, one of them an economy-integrity
risk. Both are in the **free-tier-leak class**: an invariant asserted in one place and
not enforced in another.

1. **`CashOutHubHost` checks the balance, awaits, then debits — without re-checking.**
   Suspected TOCTOU. Highest-value item in this brief.
2. **Display precision exceeds the refresh sensor's resolution in four places.** The
   wallet is rendered at 6 and 8 decimals; the hash that triggers redraw only moves at
   4. Sub-0.0001 ₿ movement is invisible until something else moves the hash. This is
   exactly the bug fixed for the rack buffer in Slice 3.5, still present for the wallet.

---

## 1. Surface map

### Renders wallet / balances / transfers / cash-out

| File | Role |
|---|---|
| `lpbitcoin/bitcoinhub/code/ui/LpHashdPanel.razor` | `pane wallet` (693–770), `pane transfers` (771–875), header wallet chip (140), overview snapshot (256), Hub-detail wallet vital (311) |
| `lpbitcoin/bitcoinhub/code/ui/LpHashdPanel.razor.scss` | `.wallet-*`, `.transfer-*`, `.transfers-rate-*` blocks |
| `bitcoinmining/LpBitcoinTerminalScreen.cs` | terminal-side balance readout |
| `bitcoinmining/LpBitcoinTerminalCommands.cs` | `deposit` / `cash out` / `send` command surface |
| `hackerjob/HackerTerminal.razor` | reads balances (cross-addon) |

### Mutates `HubWalletBtc` — the complete set (9 sites)

| Site | Meaning |
|---|---|
| `LpBitcoinHubEntity.cs:1009` | `DepositRackToHubHost` — one rack → hub |
| `LpBitcoinHubEntity.cs:1028` | `DepositRacksToHubHost` — all racks → hub |
| `LpBitcoinHubEntity.cs:1051` | `CashOutHubHost` — hub → player bank |
| `LpBitcoinHubEntity.cs:1075` | `SendHubWalletHost` — debit sender |
| `LpBitcoinHubEntity.cs:1076` | `SendHubWalletHost` — credit recipient hub |
| `LpBitcoinHubEntity.cs:192` | reset to 0 on unclaim/destroy |
| `LpBitcoinPurchaseFlow.cs:106` | debit for an upgrade |
| `LpBitcoinPurchaseFlow.cs:112` | `// restore the debit exactly` — compensating write |
| `LpBitcoinLedgerDevSpawn.cs:73` | dev grant |

`HubWalletBtc` is `[Property, ReadOnly] [Sync(SyncFlags.FromHost)]` (`LpBitcoinHubEntity.cs:44`).
All mutation is `[Rpc.Host]`-gated. Good.

---

## 2. Data flow and sensors

- **Where the balance lives:** `LpBitcoinHubEntity.HubWalletBtc`, host-authoritative, synced
  from host.
- **What refreshes the UI:** `LpHashdPanel.RecomputeTelemetryHash()`, throttled to
  `TelemetryRefreshInterval = 0.5f`. The wallet's contribution is a single line:

  ```csharp
  hash.Add( (int)(HubWalletBtc() * 10000f) );   // LpHashdPanel.razor:2937
  ```

  **That is the sensor. Its resolution is 4 decimal places.**

- **What the UI displays** — five renderers, three precisions, for one quantity:

  | Where | Line | Format | Precision |
  |---|---|---|---|
  | header chip | 1649 `HeaderWalletBtc()` | `F4` | 4 dp |
  | overview snapshot | 256 | `F4` | 4 dp |
  | **Hub detail vital** | 1901 `HubWalletVital()` | `0.########` | **8 dp** |
  | **wallet pane** | 707, 711 | `F6` | **6 dp** |
  | **transfers pane** | 800 | `F6` | **6 dp** |
  | transfers rate cell | 861 | `F2` | 2 dp |

**Finding 2 (confirmed by construction):** the 6 dp and 8 dp renders claim more precision
than the sensor can see. A wallet change smaller than 0.0001 ₿ does not move the hash and
therefore does not repaint. Reachable via `SendHubWalletHost` (arbitrary player-entered
`amount`) and, in principle, any sat-granular debit.

Fix shape is already proven: hash at the displayed resolution, as the rack buffer now does
(`hash.Add( (long)( rack.BitcoinAmount * 100_000_000f ) )`). Recompute is already throttled,
so the cost is bounded at one redraw per 0.5 s.

---

## 3. Invariant risk — read this before restyling

### 3a. Cash-out is check → await → mutate, with no re-check (SUSPECTED)

```csharp
[Rpc.Host]
private async void CashOutHubHost( float amount, bool soldAll )
{
    if ( amount <= 0f || amount > HubWalletBtc ) return;          // 1041  CHECK
    var payout = LpBitcoinEconomy.BtcToCashPayout( amount );
    if ( !await LpBitcoinWallet.TryPayBank( ... ) ) return;       // 1048  AWAIT
    HubWalletBtc -= amount;                                       // 1051  MUTATE
}
```

The balance is validated **before** the await and debited **after** it, with no re-validation
and no lock. It is `async void`, so nothing serialises two in-flight calls. Two cash-outs
that both pass line 1041 before either reaches 1051 would both pay the bank and both debit —
driving `HubWalletBtc` negative, or paying out twice for one balance.

*Status: not proven.* I have not exercised it. The code shape is unambiguous but the
reachability depends on whether the client can issue two `CashOutHub` RPCs before the first
await resumes, and on `TryPayBank`'s latency. **Proving it needs a sensor: log
`HubWalletBtc` immediately before and after the debit, then fire two cash-outs in the same
tick.** Do not restyle this pane before this is settled — a redesign that adds a second
cash-out affordance widens the window.

`SendHubWalletHost` (1057) is synchronous and does not have this shape. `PurchaseFlow`
debits then explicitly restores on failure (`:112`) — the compensating write is the pattern
cash-out lacks.

### 3b. Do not touch these while restyling

- `LpBitcoinPurchaseFlow.cs:106/112` — debit + exact restore is the atomic purchase flow.
- `AssignedSlotToken` reconcile — the free-tier-leak fix. Wallet work should not touch it,
  but any change to deposit ordering interacts with `ClearBalanceHost()`.

---

## 4. Law conformance

Sensor: `grep -c 'lp-money-btc\|lp-money-cash'` over each pane's line range.

| Pane | Law 13 colour spans | Verdict |
|---|---|---|
| `pane racks` (Servers) | present | conforms |
| **`pane wallet` (693–770)** | **0** | **violates** |
| **`pane transfers` (771–875)** | **0** | **violates** |

Both money panes render every ₿ and every `$` with **no value-colour grammar at all** —
confirmed in the screenshot: `HUB WALLET` is amber only because `.lp-ui-info-value.accent`
paints it, while `STILL ON RACKS`, `USD VALUE (HUB)` and `YOUR CASH` are plain text. Law 13
(₿ gold, `$` green) is unimplemented on the two surfaces that exist to show money.

**Separator Law:** clean. No bare separator between `@`-expressions in either pane.

**Chip grammar:** neither pane uses `entity-chip`. `TERMINAL LINKED → "No — link on Overview"`
is a stat row where Servers would use a `LINKED`/`UNLINKED` chip.

**Card-must-not-contradict-its-page:** no aggregate cards in these panes; not applicable yet.
It *becomes* applicable the moment the wallet gets a summary tile.

---

## 5. If the wallet becomes an Entity Detail Contract tenant

**Free** (already built, tenant supplies an adapter):
- Toolbar + click-to-copy ident, back-link behaviour.
- `entity-chip-row` + Law-13 chip colours.
- `server-stat-plate` stat rows, the buffer bar.
- `entity-tier-progress` track rows, incl. PLANNED-grey as a true state.
- The anchor-aware confirm chip and the stepper purchase flow.

**Genuinely new surface** (no contract equivalent):
- The three input tiles (BTC amount / bank deposit / cash-out amount) — the contract has no
  text-entry primitive; `TextEntry` bind values are deliberately excluded from `BuildHash`.
- The transfers recipient picker and rate table.
- The `CASH OUT ALL` destructive-confirm affordance.

**Judgement:** the *readout* half of the wallet maps cleanly onto the contract; the
*transact* half does not. A wallet tenant would be the first tenant with free-text input,
which is the real design question — not the styling.

---

## 6. PayoutTarget touchpoints (feeds that slice directly)

PayoutTarget = `PlayerBank | FundPile | CityFunds` decides **where mined BTC lands**. Every
site below is where that decision is currently hard-wired to "the hub wallet":

| Site | What PayoutTarget changes |
|---|---|
| `LpBitcoinHubEntity.cs:1009` | single-rack deposit destination |
| `LpBitcoinHubEntity.cs:1028` | all-racks deposit destination |
| `LpBitcoinHubEntity.cs:1051` | cash-out destination (already `TryPayBank`) |
| `LpBitcoinHubEntity.cs:1075/1076` | hub→hub transfer; a FundPile target changes both legs |
| `LpBitcoinTerminalCommands.cs` | `deposit` command copy must name the target |
| `LpHashdPanel.razor` wallet pane | "STILL ON RACKS" and deposit copy assume the hub |

Refuse-paths must name the missing **INSTITUTION**, never the config — so `FundPile` and
`CityFunds` need a reachable institution check at the deposit sites (1009/1028), not at the
UI. The UI should render the refusal, not decide it.

---

## 7. Recommended order (not a proposal — a sequencing note)

1. Settle 3a (cash-out TOCTOU). It is an economy-integrity question, not a UI one.
2. Fix the sensor resolution (Finding 2). One line, same shape as the rack-buffer fix.
3. Only then restyle — Law 13 across both panes, chip grammar for TERMINAL LINKED.
4. PayoutTarget lands at the deposit sites, after the `[Sync]` slice proves replication.

---

## 8. Gaps in this brief

- **Transfers has no dev entry point.** There is `DevOpenWalletTab()` but no
  `DevOpenTransfersTab()`, so the transfers pane has no proof surface and I could not
  screenshot it. Building one is a prerequisite for gating any transfers work.
- The terminal-side wallet surface (`LpBitcoinTerminalScreen.cs`,
  `LpBitcoinTerminalCommands.cs`) is mapped but not read line-by-line.
- `hackerjob/HackerEconomySecurity.cs` reads balances; the coupling is noted, not traced.
