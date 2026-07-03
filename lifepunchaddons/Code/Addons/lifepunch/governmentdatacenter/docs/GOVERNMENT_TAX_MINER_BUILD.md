# Government Tax Miner — Build Checklist

City-owned BTC rig — **blue console** (lifepunchnet cyan `#00D4FF`), always mining, hourly tax drip to city funds.

## Economy (mirrors player BitcoinMiningAddon)

| Constant | Value | Source |
|----------|-------|--------|
| `BitcoinUsdRate` | $1,500 / BTC | `GpuRackEntity.BitcoinValue` |
| `BtcBalanceUsdCap` | **$30,000** | Owner rule |
| `BtcBalanceCap` | **20 BTC** | 30000 / 1500 |
| `MiningIntervalSeconds` | 60s accrual tick | Same as BitcoinMiningAddon |
| `TaxPayoutIntervalSeconds` | **3600s (60 min)** | Owner rule |
| `TaxRate` | **0%–30%** of BTC balance → cash | Map/server configurable |
| Player withdraw | **DISABLED** | Treasury only |

**Hourly payout formula:** `floor(btcBalance × 1500 × taxRate)` → city funds (not player wallet).

**Always on:** `IsMining = true` permanently — no start/stop, no `bitcoin sell`.

## Red lane (Opus)

- [ ] Port `GpuRackEntity` → `GovernmentTaxMinerEntity` (strip upgrades/sell, add tax RPC)
- [ ] Blue terminal chrome on in-world `TextRenderer` (not green hashd)
- [ ] Wire city funds API (DXRP mayor/treasury hook — confirm on `dxura/dxrp @develop`)
- [ ] Datacenter mesh from owner (`government-tax-miner.vmdl`) — **ask owner if models not intaked yet**
- [ ] Map-place miners near `police-terminal` prefabs

## Models needed?

Owner: confirm when datacenter GPU-rack / blue-console meshes are ready. Can fork `gpu-rack` layout with cyan materials until bespoke datacenter art ships.
