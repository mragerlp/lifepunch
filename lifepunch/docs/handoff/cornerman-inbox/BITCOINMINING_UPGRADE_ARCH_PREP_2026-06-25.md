# Bitcoin upgrade architecture — Red prep snapshot (2026-06-25)

**For:** Cornerman distill · **Not canon until owner + Red sign off**

## Owner corrections captured

- Standard rack buffer: **max($10,000, 1 BTC)** — **1 BTC per standard GPU rack**
- Advanced rack buffer: **max($20,000, 2 BTC)**
- Standard base yield: **1.0×** · Advanced: **2.0×**
- CPU Clock / Core Count → **hub** upgrades (controller), not rack
- Servers tab → **GPU hashing** upgrades + status only
- New **Hub Upgrades** tab — do not destroy existing hub menu chrome

## Code snapshot (grep 2026-06-25, commit d9084a2)

### Economy (`LpBitcoinEconomy.cs`)

```
RackBtcCapacity = 0.15f  // flat all racks — WRONG vs owner
MiningRatePerMinute(clockGhz, cores, rackYield)
CpuUpgradeCosts[] / CoreUpgradeCosts[] — purchased per rack today
StartClockGhz = 2.44f, StartCores = 1
CpuGhzPerLevel = 1.5f, CoresPerLevel = 2
```

### Rack entity (`LpBitcoinRackEntity.cs`)

```
AdvancedRack bool
CpuUpgradeLevel, CoreUpgradeLevel — ON RACK (should migrate to hub)
YieldMultiplier => BaseRackYieldMultiplier (always 1f — advanced 2x NOT applied)
Mining ticks: TickPayout(ClockGhz, CoreCount, YieldMultiplier)
UpgradeCpuHost / UpgradeCoresHost on rack entity
```

### Ident (`LpBitcoinIdent.cs`)

```
BaseRackYieldMultiplier = 1f
PortalMaxStandardRacksPerHub = 2
PortalMaxAdvancedRacksPerHub = 1
```

### Hub UI (`LpHashdPanel.razor`)

```
OpsTab: Overview, Wallet, Transfers, Racks (Servers), Upgrades (sub-view), Logs, Settings
Servers: 3 fixed slot cards + Upgrade button → per-rack CPU Clock / CPU Cores buy UI
Displays TH/s derived from MiningRatePerMinute * 18.5
```

### Terminal (`LpBitcoinTerminalPanel.razor`)

```
Prompt: rig@hub>
Sidebar: COMMANDS + STATUS (power, racks linked, selected)
Commands include link gpurack-1/2, advancedgpurack, select 0, mining *, deposit *
```

## Doc drift hotspots

- `BITCOINMINING_HUB_ARCH.md` § Upgrades — CPU on rack
- `BITCOINMINING_OPERATOR_FLOW.md` — upgrades on Servers, yield from CPU/core not advanced tier
- `BITCOINMINING_PLAYTEST.md` — upgrade cpu/cores wording

## Recent terminal UI (d9084a2 — separate from upgrade arch)

Boot log top-align, click-to-clear selection, sidebar STATUS block, scroll bottom pad.

## Waiting on owner

Final ChatGPT architectural workflow plan → merge into `BITCOINMINING_CHATGPT_PROMPT_MERGE.md` before Red implementation slice.
