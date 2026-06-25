# DECISION-0001 — Single authoritative owner

> **Status:** Active  
> **Date:** 2026-06-25  
> **Proposed by:** Design Architect  
> **Approved by:** Bloodwave  
> **Supersedes:** —  
> **Law:** `LIFEPUNCH_GAMEPLAY_LAWS.md` G0

## Decision

Every gameplay field has **exactly one authoritative owner**: the **Hub** owns operation policy and ledger state; the **HASHD Terminal** owns presentation and command-session state; **GPU Racks** own worker execution, rack-local buffers, and telemetry.

## Reason

Prevents duplicate ledgers, split-brain upgrades, and integration spaghetti. Future cyber lanes inherit the same rule.

## Alternatives considered

- Shared mutable state on both hub and terminal — **rejected**
- Per-feature ad hoc ownership — **rejected**

## Systems affected

All cyber lanes · `LIFEPUNCH_CYBER_SYSTEM_PATTERN.md` · `KNOWLEDGE/architecture/ownership-pattern.md`
