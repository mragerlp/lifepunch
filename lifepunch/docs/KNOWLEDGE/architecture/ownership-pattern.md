# Ownership pattern (knowledge)

> **Status:** Active  
> **Type:** Knowledge  
> **Law:** DECISION-0001 · G0 · **Pattern:** `LIFEPUNCH_CYBER_SYSTEM_PATTERN.md`

Quick reference — not a substitute for decisions or canon specs.

---

## One sentence

Every gameplay system has **one authoritative owner**. Mirrors present; workers compute; controller decides.

---

## Bitcoin mapping

| Role | Entity | Owns |
|------|--------|------|
| Controller | Hub | Mining state, wallet, dispatch, hub upgrades |
| Operator | HASHD Terminal | Commands, CRT status (never mines) |
| Worker | GPU Rack | Hash work, buffer, hardware upgrades |

```text
Hub owns mining.
Terminal owns presentation.
GPU Rack owns computation.
```

---

## Cyber stack (all lanes)

```text
Controller → Operator Interface → Worker Nodes → Shared Economy → Persistent State
```

---

## When designing a new lane

1. Name controller, operator, workers.
2. Write DECISION or RFC before code.
3. Check `PATTERN_LIBRARY.md` for clone targets.

---

*Knowledge — 2026-06-25*
