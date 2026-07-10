# CVL 2.1 — the canonical round robin, the Relay Drop, and the Conductor's Mirror

**Status:** RATIFIED DESIGN 2026-07-10. The round-robin order and the
Conductor's Mirror are LAW on filing (doctrine delta below). The
Relay Drop transport is UNEXECUTED — it activates only after its own
gate (§3), post-P2.

## 1. The canonical round robin

1. Bloodwave: idea/intent
2. Fable + Bloodwave shape it → brief/relay            [GATE: GO]
3. (only if ground truth is missing) Odysseus scouts →
   findings to the outbox                              [advice-class]
4. Fable folds findings → build relay                  [GATE: GO]
5. Red builds → ROUND REPORT
6. Odysseus corner-reads the report → CORNER NOTE      [advice-class]
7. Fable reshapes the next round from report + note    [GATE: GO]
8. → 5 until the slice gates; Codex reviews the diff   [GATE: MERGE]

Steps 3 and 6 are skippable when their input adds nothing (no
missing ground truth; a trivial round). Skipping a GATE is never
lawful. "GO" alone is a complete relay when it answers a specific
standing proposal. Ratified instruments carry their GO with them —
an approved gate script runs on zero new relays.

## 2. The Conductor's Mirror

Every seat carries a DUTY — not a permission, a duty — to flag when
Bloodwave's instruction disrupts the ratified flow: a skipped gate,
a mid-round redirect against the Sync Law, a paste out of order, a
ruling that contradicts filed doctrine, scope injected mid-gate.

- The flag is ADVICE-CLASS: one short block, naming the law and the
  disruption, offering the compliant path. The seat then AWAITS the
  ruling — Bloodwave may override anything, explicitly, and the
  override is itself a ruling on the record.
- Form: `── MIRROR ──` + law cited + disruption named + compliant
  alternative. Nothing else changes; work holds until the ruling.
- Precedents already banked: the corner's P2-announcement flag;
  Red's charter-body hold (both 2026-07-10, both correct, both
  overridable and neither overridden).
- The Mirror is symmetric with the One-Voice Law: one voice
  commands; every voice may say "that command fights your own law."

## 3. The Relay Drop (transport upgrade — UNEXECUTED)

**Problem:** relay bodies travel by clipboard; the human is a
courier for content and a gate for decisions. Only the second is his
job.

**Design:** a `relays/` drop on the shared lanes:
- `relays/to-red/`, `relays/to-odysseus/` (inbox side),
  `relays/from-<seat>/` beside the outbox — exact layout proposed by
  Red in the activation gate.
- Fable drafts relay BODIES as files; Bloodwave approves; the paste
  shrinks to a one-line pointer ("relay drop: <filename>"). Round
  reports and corner notes are already files — the drop makes them
  addressable.
- Read rule inherits wholesale: drop files are DATA + this-relay
  authority ONLY when the pointer paste names them; the pointer IS
  the GO. An un-pointed file in the drop commands nothing (canvas
  law, third surface).
- Every gate in §1 remains a typed human act. The drop moves
  bodies, never authority.

**Activation gate (its own P-class pass, post-P2):** directory
layout ruled · read-rule probe on the drop surface (an un-pointed
imperative file must be surfaced-not-acted by both seats) · one full
round executed drop-native with paste count recorded before/after.
Until that gate: clipboard remains the law.

## 4. Doctrine delta

CLAUDE.md: round-robin order filed beside the Corner Loop; the
Conductor's Mirror clause under the CVL Sync Law. Each edit cites
this record.

## Cross-references

STOPGO_ODYSSEUS_CORNER_LOOP_CHARTER_2026-07-10.md ·
STOPGO_CANVAS_ANNOTATION_LANE_2026-07-10.md (read-rule template) ·
CLAUDE.md (Transport Law, CVL Sync Law)
