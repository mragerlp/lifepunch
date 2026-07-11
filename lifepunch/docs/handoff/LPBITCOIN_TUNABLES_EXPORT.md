# LPBITCOIN TUNABLES EXPORT — 2026-07-11

> **EXPORT, NOT DOCTRINE.** A grep-harvest of hardcoded tunables in the
> `lpbitcoin` / `bitcoinmining` source — rates, intervals, caps, costs,
> percents, limits, health. Feeds **Odysseus Packet H** (the config-extraction
> pass that turns these into T3 addon-config keys per DXRP doctrine §4, the
> Monnow ~48-key pattern). Values are the sensor as of `develop` at capture;
> **re-grep at extraction time** — line numbers drift.

## Economy core — `bitcoinmining/LpBitcoinEconomy.cs`

| file:line | constant | value | role |
|---|---|---|---|
| LpBitcoinEconomy.cs:17 | `BaseSpeed` | `0.005f` | BTC per tick per GHz·core — the mining-rate coefficient |
| LpBitcoinEconomy.cs:18 | `PayoutIntervalSeconds` | `90f` | seconds per payout tick |
| LpBitcoinEconomy.cs:21 | `DefaultBitcoinCashUsd` | `5000` | offline/dev fallback $ per mined BTC (hub cashout) |
| LpBitcoinEconomy.cs:24 | `DefaultPortalRedeemCashUsd` | `5000` | default $ per portal `$BTC` stack on Use |
| LpBitcoinEconomy.cs:97 | `StartClockGhz` | `2.44f` | stock rack clock (tier-0 rate base) |
| LpBitcoinEconomy.cs:98 | `StartCores` | `1` | stock rack core count |
| LpBitcoinEconomy.cs:102 | `AdvancedRackYieldMultiplier` | `2f` | advanced-rack throughput (2× for 2× capital) |
| LpBitcoinEconomy.cs:116 | `BufferCapTicks` | `4` | undeposited buffer cap = tick payout × 4 (~6 min headroom) |
| LpBitcoinEconomy.cs:104-108 | `MiningRatePerMinute()` | `clockGhz·BaseSpeed·cores·rackYield · (60/PayoutIntervalSeconds)` | derived BTC/min (formula) |
| LpBitcoinEconomy.cs:110-111 | `TickPayout()` | `clockGhz·BaseSpeed·cores·rackYield` | derived BTC per tick (formula) |
| LpBitcoinEconomy.cs:118-119 | `RackBtcCapacityFor()` | `TickPayout × BufferCapTicks` | derived undeposited cap (formula) |

## Upgrade ladder (Compute Profile) — `bitcoinmining/LpBitcoinComputeTrack.cs`

| file:line | constant | value | role |
|---|---|---|---|
| LpBitcoinComputeTrack.cs:39 | `MaxTier` | `5` | tiers I–V above stock |
| LpBitcoinComputeTrack.cs:40-47 | `PriceLadderSats` | `[25_000_000, 75_000_000, 200_000_000, 600_000_000, 1_600_000_000]` sats = 0.25 / 0.75 / 2 / 6 / 16 BTC | tier upgrade costs I–V |
| LpBitcoinComputeTrack.cs:56-57 | `EffectMultiplierFor()` | `1 << clamp(tier,0,5)` → ×1/2/4/8/16/32 | rate multiplier per tier |
| LpBitcoinComputeTrack.cs:71-78 | `QuoteSats()` | `PriceLadderSats[tier] × rack.YieldMultiplier` | advanced rack pays 2× the ladder |
| LpBitcoinComputeTrack.cs:22 | `TrackId` | `"rack_compute"` | upgrade-track id |
| LpBitcoinComputeTrack.cs:25-26 | `ClassStandard` / `ClassAdvanced` | `"gpurack"` / `"advancedgpurack"` | rack model idents |

## Limits & caps — `bitcoinmining/LpBitcoinIdent.cs`

| file:line | constant | value | role |
|---|---|---|---|
| LpBitcoinIdent.cs:45 | `PortalMaxHubsPerOperator` | `1` | hubs per operator |
| LpBitcoinIdent.cs:46 | `PortalMaxTerminalsPerOperator` | `1` | terminals per operator |
| LpBitcoinIdent.cs:52 | `PortalMaxStandardRacksPerHub` | `2` | standard racks per hub |
| LpBitcoinIdent.cs:55 | `PortalMaxAdvancedRacksPerHub` | `1` | advanced racks per hub |
| LpBitcoinIdent.cs:58 | `PortalMaxRacksPerHub` | `3` | derived (2 + 1) total racks per hub |
| LpBitcoinIdent.cs:42 | `BaseRackYieldMultiplier` | `1f` | standard-rack yield baseline |

## Health — `bitcoinmining/LpBitcoinIdent.cs`

| file:line | constant | value | role |
|---|---|---|---|
| LpBitcoinIdent.cs:36 | `HubMaxHealth` | `250f` | hub entity HP |
| LpBitcoinIdent.cs:39 | `RackMaxHealth` | `500f` | rack entity HP |
| LpBitcoinIdent.cs:418 | `TerminalMaxHealth` | `100f` | terminal entity HP |
| LpBitcoinIdent.cs:442 | `AdvancedRackMaxHealth` | `= RackMaxHealth` (500f) | advanced-rack HP |

## Timing / sync

| file:line | constant | value | role |
|---|---|---|---|
| LpBitcoinPortalEconomySync.cs:41 | `RefreshIntervalSeconds` | `300f` | portal economy pull interval |
| LpBitcoinRackEntity.cs:122 · LpBitcoinTerminalEntity.cs:87,111 · LpBitcoinHubEntity.cs:105,139 | `_spawnDropGraceTicks` | `45` | ticks before a fresh-spawned entity can drop/decay |

## Secondary (non-economy — low Packet-H priority)

| file:line | constant | value | role |
|---|---|---|---|
| LpBitcoinHubPin.cs:14-15 | `MinDigits` / `MaxDigits` | `4` / `4` | hub PIN length |
| LpBitcoinHubAlert.cs:32-33 | `MaxAlerts` / `MaxMessageLength` | `20` / `160` | hub alert ring buffer |
| LpBitcoinHubVisuals.cs:22-28 | `FanMaxSpeed` / `FanRampSeconds` / `SoundFadeSeconds` / `MaxFanLoopVolume` | `900` / `6` / `0.25` / `0.3` | hub fan + sound (cosmetic) |
| LpBitcoinRackVisuals.cs:27-31 | `FanMaxSpeed` / `FanRampSeconds` / `VisualTickSeconds` / `FanMeshTiltDegrees` / `FanHideSpeedThreshold` | `1200` / `4` / `0.05` / `10` / `1` | rack fan visuals (cosmetic) |
| LpBitcoinPowerLeds.cs:21-23 | `HubStatusOnScale` / `HubStatusOffScale` / `RackGpuLedOn` | `2.5` / `1.75` / `1.5` | LED scale (cosmetic) |
| LpBitcoinTerminalEntity.cs:28 | `ScreenRefreshSeconds` | `0.25f` | terminal screen refresh (cosmetic) |

## Notes for Packet H

- The **Economy core** and **Upgrade ladder** rows are the extraction targets:
  they become T3 addon-config keys so the whole mining economy is portal-tuned
  (DXRP doctrine §4). Everything else is HP/limits/cosmetic — extract if a knob
  is wanted, but they are not the roadblock.
- `PortalBaseCashUsdPerBtc` and `PortalRedeemCashUsdPerStack`
  (`LpBitcoinEconomy.cs:30,36`) are **already runtime-portal-backed** via
  `ApplyPortalBacking()` / `ApplyPortalRedeemBacking()`; the `$5000` consts are
  only offline/dev fallbacks. `CashRateMultiplier` (`:42`) is a live event knob.
- Values captured from `develop`; re-grep before Packet H acts (line drift).
