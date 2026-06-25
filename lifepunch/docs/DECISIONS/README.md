# Decision register

> **Status:** Active  
> **Why does this exist?** Long-lived projects accumulate **why** faster than **what**. One file per decision — searchable, citable by ID.

**Distiller rule:** Reference `DECISION-####` by ID. Do not re-argue settled decisions in outbox distills.

**Supersedes:** Inline log in `DESIGN_DECISION_LOG.md` (index only).

---

## How to add

1. Architect drafts `DECISION-####-Short-Title.md` (next ID below).
2. Owner approves → **Status: Active** · **Proposed by:** Design Architect · **Approved by:** Bloodwave
3. If reversed → set **Status: Deprecated** · link successor · move copy to `deprecated/` if needed.
4. Promote from `RFC/` when RFC is approved (see `RFC/README.md`).

---

## Index

| ID | Title | Date | Status |
|----|-------|------|--------|
| [0001](DECISION-0001-Single-Authoritative-Owner.md) | Single authoritative owner | 2026-06-25 | **Active** |
| [0002](DECISION-0002-Hub-Owns-Mining.md) | Hub owns mining state | 2026-06-25 | **Active** |
| [0003](DECISION-0003-No-NPC-Core-Progression.md) | No LIFEPUNCH™ NPC dependency | 2026-06-25 | **Active** |
| [0004](DECISION-0004-Three-Rack-Limit.md) | Three rack limit (2+1) | 2026-06-25 | **Active** |
| [0005](DECISION-0005-Terminal-Never-Mines.md) | Terminal never mines | 2026-06-25 | **Active** |
| [0006](DECISION-0006-Hub-Controller-Upgrades.md) | Hub owns controller upgrades | 2026-06-25 | **Active** |
| [0007](DECISION-0007-Preserve-Hub-UI-Shell.md) | Preserve hub UI shell | 2026-06-25 | **Active** |
| [0008](DECISION-0008-Fantasy-Check-Gate.md) | Fantasy Check before sign-off | 2026-06-25 | **Active** |
| [0009](DECISION-0009-Gameplay-Laws-Document.md) | Gameplay laws as top doctrine | 2026-06-25 | **Active** |

---

## RFC pipeline (under discussion)

| RFC | Topic | Status |
|-----|-------|--------|
| [RFC-0005](../RFC/RFC-0005-Hub-Upgrades.md) | Hub upgrade overhaul implementation | **Draft** |

---

*v1.0 — 2026-06-25*
