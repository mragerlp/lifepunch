# DECISION-0001 — Single authoritative owner

> **Status:** Active  
> **Date:** 2026-06-25  
> **Owner:** Architect · **Approved by:** Bloodwave (design canon)  
> **Supersedes:** —  
> **Law:** `LIFEPUNCH_GAMEPLAY_LAWS.md` G0

## Decision

Every gameplay system has **exactly one authoritative owner**. Hub = mining state; Terminal = presentation; GPU Rack = computation.

## Reason

Prevents duplicate ledgers, split-brain upgrades, and integrator spaghetti. Future cyber lanes inherit the same rule.

## Alternatives considered

- Shared mutable state on both hub and terminal — **rejected**
- Per-feature ad hoc ownership — **rejected**

## Systems affected

All cyber lanes · `LIFEPUNCH_CYBER_SYSTEM_PATTERN.md` · `KNOWLEDGE/architecture/ownership-pattern.md`
