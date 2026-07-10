# GATE SCRIPT — Hub interact fix, cases a–d: Bloodwave drives

- **Status:** INSTRUMENT. **Unexecuted** — no verdict recorded here yet. Editable until it runs.
- **Record:** cases e/f already landed. Their verdict is frozen in
  `GATE_HUB_INTERACT_EF_VERDICT_2026-07-10.md`. Do not restate it here; cite it.
- **Provenance:** split from the original hybrid gate on 2026-07-10 under the write-once
  clarification. This file is the un-run half.

**Fix APPLIED (uncommitted). a–d need you at the keyboard in a game scene with a pawn. Nothing
commits until a–d pass with you driving.** `develop` @ `f1355cf` + working-tree changes to
`LifePunchMenuInteractRange.cs` + `LifePunchMenuInteractGate.cs`.

`GATE HEADER: SCENE: game/map (NOT blank.scene preview) · IDENTITY: one, with a real pawn`

---

## Preconditions

A game/map scene, your pawn spawned, a Bitcoin Hub placed and powered (`lp_bitcoin_spawn_hub`
needs a local viewer — hence a pawn scene, not the editor preview).

## Cases a–d — YOU DRIVE

**a. Hands+E opens the Hub menu** — the symptom.
  1. Equip Hands. Stand at normal facing distance (where you'd read the hub), NOT nose-to-glass.
  2. Aim at the hub, press **E**.
  3. PASS = the HASHD/Bitcoin Ops menu opens. (Before the fix: nothing happened here.)

**b. Build tool still opens the Hub menu** — regression guard.
  1. Switch to the Build tool. Aim at the hub, activate.
  2. PASS = the menu opens (this path never went through the reach gate; it must still work).

**c. Carry → E rotates, menu suppressed** — rotation sacred.
  1. Grab/hold the hub with Hands. While holding, press **E** (or attack1).
  2. PASS = the hub ROTATES and the menu does NOT open. `CanPress` returns false while the
     `GrabbedTag` is set — untouched by this fix, confirm it still holds.

**d. Hub is never pocketable** — assert the pocket path refuses it.
  1. Aim at the hub, attempt the pocket pickup (Reload + Hands, per DXRP pocket bind).
  2. PASS = the hub is NOT pocketed. (Item E: "HOLDABLE NEVER POCKETABLE." If it DOES pocket,
     that's a separate regression in the hub's pocket-exclusion tags — flag it; the reach fix
     doesn't touch pocketing, but d is on the acceptance list so we verify it here.)

## On all-pass

Report a–d pass/fail. On all-pass Red syncs via the script (standing gate), commits
`fix(lpbitcoin): hub menu reach scales with model bounds`, and PRs. **Nothing commits before that.**

When the a–d verdict lands, this instrument and its result freeze together as one record — a
re-run needs a new gate script citing this one.

## Sensor honesty

a–d are the live interaction proof that only a human at the keyboard can drive (aim/use/grab/
pocket); `simulate_input` drives named actions, not "aim at entity X and use." That is why this
half could never be closed from Red's side, and why it is still an instrument.

The bridge addon republish (1.20.0 → 2.0.0) can ride this same sitting.
