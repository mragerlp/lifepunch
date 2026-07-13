# CVL CANON AMENDMENT — 2026-07-12 (r3 arc)

> **Class: RULED RECORD.** Write-once. Ratified by Bloodwave across the r3 arc; landed by Red at
> the r3 close. Supersede with a new record citing this one by filename; never edit in place.
>
> **Every cite below was machine-verified against the live tree by Red before landing.** Where a
> proposal's cite did not survive verification, the verified fact is stated and the proposal's
> claim is marked SUPERSEDED — the bytes win.

## R1–R7 — the seat/loop amendments

**R1 — Terminal grab gate = linked hub's power.** The HASHD Terminal has **no power state of its
own**; the only power check in `LpBitcoinTerminalEntity.cs` reads the *linked hub's* `IsPowered`.
The grab gate therefore keys on the linked hub. Unlinked terminal = always grabbable.
*Verified:* `LpBitcoinHubEntity.cs:37` declares `IsPowered` (`[Sync(SyncFlags.FromHost)]`); the
terminal has no such property.

**R2 — Unpowered-only grab (final wording).** *Hands wins E only while the **governing power
source** is off.* Hub's governing source = its own `IsPowered`; Terminal's = its linked hub's
(R1). Settle conversion unchanged. **Rationale:** USE and the DXRP Hands grab both bind E, and on
a menu-bearing machine the menu wins — which is why the terminal kept `hands_interact` and still
could not be picked up. **Power-down-to-move is the intended flow.**
*Proven (r3, three live transitions, positive ID `LP_TERMINAL_GRAB_GATE`):* unlinked →
`hands_interact=True`; linked+powered → `False`; linked+unpowered → `True`.

**R3 — Outbox census at the relay author.** Owner = the relay author (Fable). Scope =
state-changing/build relays, not every message. Mechanized by the comms-lane read cycle.

**R4 — Every-boot snapshot restore is CRITICAL.** The restore is **not** crash-gated.
*Verified:* `lifepunchdxrp/game/Code/System/Recovery/SnapshotSystem.cs`, `OnSecondlyUpdate` —
`if ( _pendingSnapshot != null && Time.Now > 5f ) → LoadSnapshot( file )`. The condition is
**snapshot-exists + 5 s elapsed**. There is no crash gate. Restore fires on **every boot** where
`SnapshotSystem` runs with a snapshot present. Severity **CRITICAL** (supersedes the earlier
MEDIUM, which was graded against a crash-only premise the code disproves).

**R5 — Chair capsule, expanded formulation.** No arc closes without it; the implementer owns it;
chair capsules and merge capsules are **separate instruments** and one does not discharge the other.

**R6 — J6 citation set.** Packet J original (the `J3:7 SKIPPED` line) + the 2026-07-12 Green run
records (`RECON_J6_CAPSULE_RECONCILIATION`, `CORNER_NOTE_J6_RUN`, `INDEX_J6_RUN`) in the Cornerman
outbox, reachable via the green mirror.

**R7 — STEP-0 freshness.** Forward-looking packets assert clone freshness against `origin` at
STEP 0 via a **fast-forward-only fetch**. A pinned HEAD proves *what was read*, not that it is
*current*. Both facts must be stated.

## D–Q — the r3 rulings

**D — Terminal measurement.** Derive the collider from what a player actually collides with;
author it into the prefab from measured truth; never restore a runtime sync to paper over a bad
prefab.

**E / F — money-repair scope.** See `lifepunch/docs/slices/MONEY_REPAIR_SLICE.md`.

**G / H — (arc-internal, superseded by I).**

**I — Defect 2, corrected fix (INVERTS the earlier ruling B).** **BAKE** the measured mesh-AABB
into all four prefabs, **THEN** drop the runtime `SyncBoxColliderFromModel` from its three call
sites. **Both together:** bake-alone is behaviour-preserving; drop-alone is a regression.
*Why the inversion:* the runtime sync had been **silently correcting a broken authored collider**.
The prefab's authored box floated *above* the model (rack: authored `52,27,47` @ `z+23.5` vs mesh
`33.9,55.8,22.6`); the advanced rack's authored box **sliced the top tier off a 3-tier unit**; the
terminal's was an **identity stub** (`1,1,1`). The hub's alone was already correct and was left
untouched.
**MANDATORY GATE (carries forward):** a **non-stub authored box is not proof of a good box** — the
racks' boxes were non-stub *and* wrong. **Every prefab gets its own eye before its bake.**

**J — Defect 2 third-cause check. OPEN.** Which collider is *actually* live on Official is a
**live-server observation, not an editor one**. Confirm before defect 2 carries a "fixed" label on
Official. If neither candidate box matches the live complaint, a third cause exists.

**K — Stop-checks match by INTENT, not literal string.** A completed packet must not be re-runnable
because a filename segment mismatched.

**L — (arc-internal.)**

**M — r3 descope.** Defect 3 (BTC icon), defect 4 (PIN parity), and the LCD-prefab flatten move
**out of r3** into the Hub-reskin editor session — they are polish-class on the surface the reskin
reworks, and defect 3's SCSS-url probe belongs in that session anyway. Nothing unsafe ships; the
merge lands sooner.

**N — Config spec, micro-ruling 1.** Schema 1 **REJECTS** the reserved multipliers
(`miningRateMultiplier`, `upgradeCostMultiplier`) until consumers exist. *A portal value that does
nothing is a lie.*

**O — Config spec, micro-ruling 2.** T3 ladders **MUST be monotonic non-decreasing** in both effect
and cost. A non-monotonic candidate **REJECTS whole-object** with the loud sensor. Operator-authored
weird ladders require a future canon change, never silent acceptance.

**P — Green dispatch/BOARD proof.** Both halves: **(i)** every Green dispatch packet carries its own
`AUTHORIZED: Bloodwave GO <UTC>` line **and the matching FABLE BOARD line verbatim** as packaged
proof; **(ii)** the lane-sync push additionally delivers a **read-only `BOARD.md`** copy to Green's
inbox. **Green's OUTBOX record IS its filing** — Fable appends Green's BOARD line marked
`via mirror`; that is mechanical transport, not authority transfer.
*Red flag (machine-verified):* **no `sync-lanes` script exists in the repo at `6c9e86a`.** P-ii has
**no target yet** and is not operational until that push is authored. P-i alone carries the key
meanwhile. Stated, not assumed.

**Q — STATUS.json arrays are never inferred.** `openRulings` and `inFlightSeats` come **only** from
explicit recorded rulings and Bloodwave's explicit seat-state words. If either input is absent, Red
**FAULTS generation** rather than writing a false empty list. *Absence of a lane file is not status.*

## The ledger entry that outlives this arc

**A root-cause claim resting on measurement without visual or runtime confirmation is an
INFERENCE, not a root cause, and must be labelled so.**

Earned the hard way: the defect-2 root cause in `red\0002` was numbers-only. Every number was
correct; the *interpretation* of which box was "the good one" was an assumption inherited from the
premise, and it was labelled root-caused instead of inference-awaiting-eyes. The **mandatory-eyes
gate** attached to the fix GO is what forced the measurement that caught it — **before** a single
byte was mutated. Folds into the **Sensor Law** (`CLAUDE.md` → Hard rules).

## Path correction on the Codex boot-file proposal

Codex's `comms\codex\0004` targeted `docs/cvl/…` **at the repo root**. Machine-verified: **there is
no top-level `docs/`** (`git ls-tree -r 6c9e86a -- docs/cvl` → empty; the only doc roots are
`lifepunch/docs/` and `lifepunchaddons/docs/`). Landing there would have created a **second doc root
that nothing reads** — the two-`handoff`-folders failure with a new hat. All six bodies were landed
under **`lifepunch/docs/cvl/`** with their internal paths rewritten. The bodies themselves are
Codex's, verbatim but for that rewrite and the Ruling-P fold into `GREEN_BOOT.md`.
