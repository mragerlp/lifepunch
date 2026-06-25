# DECISION-0006 — Hub controller upgrades

> **Status:** Active  
> **Date:** 2026-06-25  
> **Owner:** Architect  
> **Supersedes:** Legacy per-rack CPU upgrades (code migration pending)  
> **RFC:** [RFC-0005](../RFC/RFC-0005-Hub-Upgrades.md) (implementation slice)

## Decision

Clock path, core count, intelligence, and economy-facing controller tiers live on **Hub**. GPU racks own compute, cooling, power, efficiency, reliability.

## Reason

Controller upgrades affect the mining operation globally. Per-rack CPU upgrades duplicated ownership and broke player mental model.

## Alternatives considered

- CPU upgrades per rack — **rejected** (legacy code to migrate)
- Terminal upgrade shop — **rejected**

## Systems affected

`BITCOIN_UPGRADE_TAXONOMY.md` · `LpBitcoinRackEntity` · Hub Upgrades tab (target)
