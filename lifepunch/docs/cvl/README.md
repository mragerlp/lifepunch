# CVL canon — seats, comms lane, boot

> **PATH NOTE (Red, machine-verified 2026-07-12):** Codex's proposal (`comms\codex\0004`)
> targeted `docs/cvl/…` at the repo root. **There is no top-level `docs/` in this repo** —
> `git ls-tree -r 6c9e86a -- docs/cvl` returns nothing, and the only doc roots are
> `lifepunch/docs/` and `lifepunchaddons/docs/`. Canon that the grounding order reads lives
> under `lifepunch/docs/`. Landing at `docs/cvl/` would have created a second doc root that
> **nothing reads** — the same failure mode as the two `handoff` folders. Every `docs/cvl/…`
> path in the Codex bodies is therefore rewritten to `lifepunch/docs/cvl/…`.

| File | What it is |
|------|------------|
| `STACK_ARCHITECTURE.md` | The machine/seat/tool topology. |
| `COMMS_LANE.md` | The comms-lane protocol (lane root, laws, dispatch validity, BOARD, mirror). |
| `STATUS_JSON_SCHEMA.md` | The `comms/STATUS.json` checkpoint contract. Red is the sole producer. |
| `boot/<SEAT>_BOOT.md` | Per-seat boot checklist. A fresh window's whole bootstrap is "read your boot file." |
| `CVL_AMENDMENT_2026-07-12.md` | Ratified rulings R1–R7 and D–Q. |

**Boot a seat:** tell it *"Read `lifepunch/docs/cvl/boot/<SEAT>_BOOT.md` and execute its
checklist."* The seat reports `BOOT-CLEAN` or `BOOT-FAULT` and then **stops** until Bloodwave
accepts it.
