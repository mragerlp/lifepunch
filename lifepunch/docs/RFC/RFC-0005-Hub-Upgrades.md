# RFC-0005 — Hub upgrade overhaul

> **Status:** Draft  
> **Date:** 2026-06-25  
> **Owner:** Architect  
> **Not law** — under discussion until owner says **GO** and slice ships.

## Why does this exist?

Migrate legacy per-rack CPU upgrades to hub controller tiers and GPU-focused rack hardware — without replacing `LpHashdPanel` shell.

## Scope (when approved)

| Area | Change |
|------|--------|
| Hub | New **Hub Upgrades** tab — Intelligence / Controller / Economy |
| Servers tab | GPU hashing status + rack hardware upgrades only |
| Rack code | Remove `CpuUpgradeLevel` / `CoreUpgradeLevel` authority from rack |
| Yield | Advanced rack **2.0×** base; standard **1.0×** |
| Buffer | `max($10k USD, 1 BTC)` standard · `max($20k USD, 2 BTC)` advanced |

## Decisions already settled

- [DECISION-0006](../DECISIONS/DECISION-0006-Hub-Controller-Upgrades.md) — hub owns controller upgrades
- [DECISION-0007](../DECISIONS/DECISION-0007-Preserve-Hub-UI-Shell.md) — preserve hub chrome
- [DECISION-0004](../DECISIONS/DECISION-0004-Three-Rack-Limit.md) — rack count cap

## Open questions (implementation slices)

1. Migration path for existing saves with rack CPU levels?
2. Hub Upgrades tab — first slice: relocate UI only or economy wiring?
3. Deposit/cashout unchanged — confirm no RFC scope creep?

## Promotion criteria

- Owner **GO** on Integrator slice plan
- Flatgrass proof per slice
- Fantasy Check pass
- No new DECISION required unless scope changes

## Related canon

`BITCOIN_UPGRADE_TAXONOMY.md` · `BITCOIN_PLAYER_DESIGN.md` · `KNOWLEDGE/bitcoin/balancing-notes.md`

---

*Draft — do not implement until promoted.*
