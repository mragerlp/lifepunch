# STOP-GO — `CashOutHubHost` TOCTOU

**Read-only.** No fix applied. Evidence for a queue-position ruling.
`develop` @ `5177b98`. Verdict: **player-reachable money duplication. Recommend it JUMPS.**

---

## The window (exact lines)

`LpBitcoinHubEntity.cs:1035-1054`

```csharp
[Rpc.Host]
private async void CashOutHubHost( float amount, bool soldAll )
{
    if ( !CanManageHub( Rpc.CallerId ) ) return;
    if ( amount <= 0f || amount > HubWalletBtc ) return;             // 1041  CHECK
    var payout = LpBitcoinEconomy.BtcToCashPayout( amount );
    if ( payout == 0 ) return;
    if ( !await LpBitcoinWallet.TryPayBank( ... payout ... ) ) return; // 1048  AWAIT (yields)
    HubWalletBtc -= amount;                                          // 1051  MUTATE
    NotifyCashOutSuccess( ... );
}
```

The check-to-mutate window is lines **1041 → 1051**, spanning an `await` that yields the host
thread. `HubWalletBtc` is read at 1041 and written at 1051 with **no re-read, no lock, no
in-flight flag**. The method is `async void`, so the RPC dispatcher does not serialise a second
call against the first — call B can enter and pass 1041 while call A is parked at 1048.

## Who can race it

**Player-facing, no exploit tooling required.**

- Client → host RPC path: `RequestCashOutHub` / `RequestCashOutAllHub`
  (`LpBitcoinHubEntity.cs:383/385`) → `CashOutHubHost`.
- UI trigger: `LpHashdPanel.CashOutPartial()` (razor:2731) and `CashOutAll()` (razor:2745),
  wired to the `CASH OUT` / `Cash out all` buttons.
- **Neither handler disables itself while a cash-out is in flight.** `CashOutPartial` checks
  `amount > HubWalletBtc()` on the *client* (razor:2736) — a client-side read of a synced value,
  which the host does not treat as authoritative and which is stale the instant it is read.
- **The host never clamps.** No `HubWalletBtc = Max(0, …)` anywhere
  (`grep` for clamp/Max on the property: none). So a double-debit drives the balance negative
  rather than flooring.

Two clicks inside one `TryPayBank` latency — or two clients on the same co-owned hub
(`CanManageHub` admits co-owners) — is the whole exploit.

## Worst case: DUPLICATION, not loss

`TryPayBank` (`LpBitcoinWallet.cs:42-50`) credits the bank via `player.PayHost(..., inBank:true)`
and returns before the debit at 1051.

Timeline for `HubWalletBtc = 1.0`, two `cash out 1.0` calls A and B:
```
A:1041  1.0 >= 1.0  pass
B:1041  1.0 >= 1.0  pass      (A has not yet reached 1051)
A:1048  TryPayBank -> bank +$X, returns true
B:1048  TryPayBank -> bank +$X, returns true    <- SECOND payout, same balance
A:1051  HubWalletBtc = 1.0 - 1.0 = 0.0
B:1051  HubWalletBtc = 0.0 - 1.0 = -1.0         <- negative wallet
```

**Player is paid twice for one balance; the hub wallet goes negative.** Real cash minted from
nothing. This is the free-tier-leak class, on the money rail.

`soldAll=true` (`RequestCashOutAllHub`) makes it worse: both calls capture `amount =
HubWalletBtc` at dispatch, so both pass with the *full* balance and the second is a full second
payout.

## Same shape, second site

`LpBitcoinRackEntity.SellForCallerHost` (`LpBitcoinRackEntity.cs:334-348`): checks
`BitcoinAmount`, awaits `TryPayBank`, then `BitcoinAmount = 0f`. Same check→await→mutate, no
guard. Two `SellHost` calls race the same way. Any fix pattern should cover both.

`SendHubWalletHost` (`:1057`) is **synchronous** — no await between check and mutate — so it is
**not** vulnerable. `PurchaseFlow` (`:106/112`) debits then restores-on-failure, which is the
compensating-write pattern cash-out lacks.

## What I did NOT do

I did not exercise it. Confirming reachability empirically needs two cash-out RPCs dispatched
inside one `TryPayBank` latency window, which mutates the bank — outside read-only. The static
path is unambiguous: shared mutable state, an await between its check and its write, no
serialisation, no clamp, a player-facing trigger with no in-flight guard.

**To prove it on your GO:** sensor = `Log.Info($"CASHOUT pre={HubWalletBtc}")` before 1041 and
`Log.Info($"CASHOUT post={HubWalletBtc}")` after 1051; fire `CashOutAll` twice in one tick;
assert `post` never goes negative and the bank credit equals a single payout. That is the gate
for the fix, too.

## Recommendation

**It jumps the queue.** Your own condition: *"if it is player-reachable money duplication it
JUMPS the queue and becomes PayoutTarget's true opening move."* It is exactly that. PayoutTarget
routes cash-out to `PlayerBank | FundPile | CityFunds`; routing multiplies the affordances that
open this window. Building routing on a racy debit is building on the leak.

Fix shape (for the eventual GO, not now): re-validate `amount <= HubWalletBtc` **after** the
await and immediately before the debit, or debit-then-restore-on-failure like `PurchaseFlow`, or
serialise per-hub with an in-flight guard. Whichever — the check and the mutate must not straddle
a yield without a re-check. Cover `SellForCallerHost` in the same pass.

**Read-only until you rule.**
