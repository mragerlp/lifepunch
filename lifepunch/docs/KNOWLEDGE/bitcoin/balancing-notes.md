# Bitcoin — balancing notes (knowledge)

> **Status:** Active  
> **Type:** Knowledge  
> **Decisions:** DECISION-0004 · DECISION-0006 · **Spec:** `BITCOIN_UPGRADE_TAXONOMY.md`

Tuning targets — adjust in playtest; changing caps may need new DECISION.

---

## Rack caps (locked)

| Slot | Count | Base yield | Local buffer (before deposit) |
|------|-------|------------|-------------------------------|
| Standard GPU Rack | 2 max | 1.0× | max($10,000 USD, 1 BTC) |
| Advanced GPU Rack | 1 max | 2.0× | max($20,000 USD, 2 BTC) |

---

## Complexity budget

| Surface | Stars |
|---------|-------|
| Hub | ★★★★★ |
| HASHD Terminal | ★★★ |
| GPU Rack | ★★ |

---

## Legacy code drift (integrator)

| Topic | Today | Target |
|-------|-------|--------|
| CPU on rack | `CpuUpgradeLevel` on rack entity | Hub (DECISION-0006) |
| Advanced yield | `YieldMultiplier` = 1f | 2.0× on advanced slot |
| Capacity | Flat 0.15 BTC | USD+BTC dual cap |

---

## Notes

- Premium over quantity — do not raise rack **count** to simulate progression.
- Buffer full → rack stops or alerts (target behavior — RFC-0005 slice).

---

*Knowledge — 2026-06-25*
