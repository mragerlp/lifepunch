# DECISION-0006 — Hub controller upgrades

> **Status:** Active  
> **Date:** 2026-06-25  
> **Proposed by:** Design Architect  
> **Approved by:** Bloodwave  
> **Supersedes:** Legacy per-rack CPU upgrades (code migration pending)  
> **RFC:** [RFC-0005](../RFC/RFC-0005-Hub-Upgrades.md) (implementation slice)

## Decision

Operation-wide **controller upgrades** live on the **Hub**. Per-rack **hardware** and rack-local capacity upgrades live on **GPU Racks**. The exact five Hub categories, five Rack categories, names, effects, and tiers remain **pending Bloodwave approval**.

## Reason

Controller upgrades affect the mining operation globally. Per-rack CPU upgrades duplicated ownership and broke player mental model.

## Alternatives considered

- CPU upgrades per rack — **rejected** (legacy code to migrate)
- Terminal upgrade shop directly on CRT — **rejected** (see DECISION-0010)

Terminal receives real defense and capability progression tracks, but purchases live in the **universal Hub Upgrades home** (HUB · TERMINAL · GPU RACK sub-tabs), not a shop on the operator CRT. Terminal never mines (DECISION-0005 remains in force).

## Systems affected

`BITCOIN_UPGRADE_TAXONOMY.md` · `LpBitcoinRackEntity` · Hub Upgrades tab (target)
