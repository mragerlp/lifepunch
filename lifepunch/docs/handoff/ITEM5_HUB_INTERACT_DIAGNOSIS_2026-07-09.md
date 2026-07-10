# ITEM 5 — Hub Hands+E interact regression: diagnosis + fix design

**Read-only trace complete. Fix designed, NOT applied.** The a–f gate needs live player
use-interaction I can't drive deterministically via the bridge — flagged below. `develop` @ `8532aae`.

---

## The regression-history answer (goes in the doc PR as a regression-law entry)

**Item E's fix was NOT lost, never-applied, or overwritten by 3.5. It is present in current
code — and it is the fix that is insufficient.**

- `git log` on `LifePunchMenuInteractRange.cs`: last touched by **`30d4686`** (entity-detail-
  contract), whose message literally contains *"Item E — the holdable-hub law: … hub menu reach
  4.25m > 3.81m grab reach, and a grabbed hub never answers Press (rotation sacred)."*
- That commit expanded the hub reach: `HubOpenHorizontalMeters` 1.15 → **4.25 m**,
  `HubOpenVerticalMeters` 1.0 → **1.5 m**.
- The 3.5 restructure `a43d105` touched **none** of `LifePunchMenuInteractRange.cs`,
  `LifePunchMenuInteractGate.cs`, or `LpBitcoinHubEntity.cs` (`git show --stat`).

**Regression-law entry:** Item E fixed the HORIZONTAL reach (4.25 > 3.81 grab) but left the
VERTICAL slack a fixed **1.5 m** measured to the model PIVOT. A fixed constant is not a fix for
a "scales with model size" requirement — it is a fix that holds only for one model geometry and
silently fails when the pivot-to-eye vertical exceeds 1.5 m. The lesson: a reach that must
"exceed grab-reach for any model" cannot be a constant; it must derive from the model bounds.

---

## Root cause (code-derived)

`LpBitcoinHubEntity.CanPress` (`:226`):
```csharp
public bool CanPress( IPressable.Event e )
    => !GameObject.Tags.Has( LifePunchPropPhysics.GrabbedTag )
       && LifePunchMenuInteractGate.CanPressHubMenu( GameObject );
```
`CanPressHubMenu` → `LifePunchMenuInteractRange.IsHubInOpenRange(viewerPos, target.WorldPosition)`
→ `IsWithin(..., HubOpenHorizontalUnits, HubOpenVerticalUnits)`:
```csharp
var vertical = MathF.Abs( delta.z );                    // eye.z - hubPivot.z
return horizontalDistance <= horizontalUnits && vertical <= verticalUnits;  // vert cap = 1.5 m
```

The vertical delta is **eye-to-pivot**. The hub spawns ground-aligned ("feet on ground",
`DevSpawnAsWorldMachine` → `SetupWorldMachine(alignGround:true)`), so its pivot sits at z≈0. A
standing DXRP player's eye is ~64 u ≈ **1.63 m**. `1.63 m > 1.5 m` → the vertical check fails →
`CanPress` false → **Hands+E does nothing.**

Why the other paths behave as reported:
- **Build tool works** — it selects the entity through its own trace, bypassing `CanPress` and
  the range gate entirely. (Matches "Build tool does open it".)
- **Terminal works** — `CanPress` = `IsLinkedToHub() && CanPressMenu` → `IsInOpenRange` (0.85 m
  horiz / 0.75 m vert), and the terminal's pivot sits at console height, so eye-to-pivot vertical
  is small. Different geometry, so its tighter fixed slack happens to hold. (Matches "Terminal is
  the working reference".)
- **Carry-rotate correct** — when grabbed, `!GrabbedTag` makes `CanPress` false by design, so USE
  rotates instead of opening the menu. Untouched by the fix. (Matches "carry-rotate correct".)

> **Sensor gap, stated honestly:** the pivot-at-ground + 64u-eye numbers are derived from the
> code constants and the ground-align spawn path, NOT a live measurement — `lp_bitcoin_spawn_hub`
> refused ("no local viewer") in the preview scene, so I could not measure the live hub bounds +
> pawn eye this pass. The FIX below removes the fixed-constant assumption entirely, so it is
> correct regardless of the exact numbers; the live measurement is only needed to quote the gap.

---

## Fix design — reach scales with model size, always exceeds grab-reach

Adopt the Terminal's "measure to the thing" spirit but bound by the model, per the ruling:

1. In `IsHubInOpenRange` (or a new `IsModelInOpenRange`), measure the vertical delta to the
   model's **bounds**, not the pivot: pass the renderer bounds and test whether the aim/eye is
   within `max(HubOpenVerticalUnits, modelHeight/2 + slack)` of the model center — so a taller
   hub gets proportionally more vertical reach.
2. Horizontal reach = `max(HubOpenHorizontalUnits, modelRadius + grabReach + margin)` so it
   ALWAYS exceeds `Config.Current.Game.ReachDistance` (grab) for any model size — the ruling's
   "always exceeds grab-reach" made structural rather than a hand-tuned 4.25 constant.
3. Keep the grabbed-hub `!CanPress` guard (rotation sacred) untouched.
4. Assert the hub is **never pocketable** — the ruling wants the pocket path to refuse it. Trace
   `LifePunchPropPhysics` / the pocket/Reload+Hands path and confirm the hub's tags exclude it;
   add an explicit refusal + sensor log if not already enforced (30d4686 says "HOLDABLE NEVER
   POCKETABLE" — verify it still holds post-3.5).

The Hub already caches `_modelRenderer` (`:112`, `:1325`), so model bounds are in hand.

---

## Gate a–f — driveability assessment (why I stopped before applying)

| case | needs | bridge-driveable? |
|------|-------|-------------------|
| a. Hands+E opens Hub menu | player aims at hub + USE at range | **No** — `simulate_input` drives named actions, not "aim at entity X and use at distance D" |
| b. Build tool opens Hub menu | build-tool select | partial (console), not the real tool flow |
| c. carry → E rotates, menu suppressed | grab + USE-while-held | **No** — needs grab + aimed use |
| d. Hub never pocketable | pocket attempt on hub | **No** — needs the Reload+Hands pocket flow |
| e. reach scales w/ model | measure reach vs model bounds | **Yes** — a probe (like DevTrackRowProbe) can report reach vs bounds |
| f. reach > grab-reach | compare to Config ReachDistance | **Yes** — pure math, assertable in a probe |

Cases **e and f I can gate** with a reach-vs-bounds probe. Cases **a–d need a human at the
keyboard** (aim, use, grab, pocket) — the same class of limit as the two-client `[Sync]` gate.
Applying the fix and gating only e/f would leave the actual symptom (Hands+E) unproven, which is
the false-green this discipline forbids. So: fix designed and ready; **I need either a driver for
a–d, or a ruling that the reach probe (e/f) + the code-derived mechanism is sufficient proof.**

---

## What I need from Bloodwave

1. **Ruling on the gate:** either you drive a–d live at the keyboard (I prep the exact steps,
   minutes), or you accept reach-probe (e/f) + this diagnosis as the gate for a reach-math fix.
2. Confirm **"HOLDABLE NEVER POCKETABLE"** is the intended invariant to assert (case d) — I'll
   trace the pocket path and add the refusal + sensor if it regressed.

Nothing applied. Fix is one focused edit to `LifePunchMenuInteractRange` + a hub bounds hook.
