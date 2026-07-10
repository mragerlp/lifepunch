# Hub interact fix — gate: e/f PROVEN, a–d driver for Bloodwave

**Fix APPLIED (uncommitted), e/f proven. a–d need you at the keyboard in a game scene with a
pawn. Nothing commits until a–d pass with you driving.** `develop` @ `f1355cf` + working-tree
changes to `LifePunchMenuInteractRange.cs` + `LifePunchMenuInteractGate.cs`.

## The fix
Hub menu reach now measures to the model's world **bounding box** (`ModelRenderer.Bounds`,
`BBox.ClosestPoint`), not the pivot. The old fixed 1.5 m vertical slack was measured from the
pivot; a ground-aligned hub puts its pivot at z≈0, so a standing player (~1.63 m eye) failed the
vertical check and Hands+E opened nothing — while the Build tool (which bypasses this gate)
worked. All three hub gate call sites (`CanPressHubMenu`, `IsCallerAllowedHub` ×2) now route
through `IsHubTargetInOpenRange`, which resolves the hub's renderer bounds (pivot fallback if no
renderer).

## Cases e/f — PROVEN NOW (no live hub needed)
`LifePunchMenuInteractRange.HubReachProbe()` runs the reach math on synthetic bounds reproducing
the failing geometry (ground hub, pivot z=0, standing-eye viewer 1u in front). Via the editor
`code_run_static_method`, FRESH (compile 00:14:35 > write 00:14:29):

```
tall-hub  h=80  r=20  oldPivotPass=False newBoundsPass=True effHReach=187u grab=150u exceedsGrab=True
short-hub h=40  r=16  oldPivotPass=False newBoundsPass=True effHReach=183u grab=150u exceedsGrab=True
big-hub   h=160 r=48  oldPivotPass=False newBoundsPass=True effHReach=215u grab=150u exceedsGrab=True
```
- **e (scales with model):** effective horizontal reach grows with model radius (187 → 183 → 215u);
  the vertical span the player can stand within is the model's own height, not a constant.
- **f (exceeds grab):** effHReach > 150u (DXRP `Config.Current.Game.ReachDistance`) at every size.
- **the bug, reproduced:** `oldPivotPass=False` everywhere — the old pivot check denied a standing
  viewer at handling range across all sizes. `newBoundsPass=True` everywhere — the fix.

## Cases a–d — YOU DRIVE (game scene with a real pawn, not blank.scene preview)

Preconditions: a game/map scene, your pawn spawned, a Bitcoin Hub placed and powered
(`lp_bitcoin_spawn_hub` needs a local viewer — hence a pawn scene, not the editor preview).

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

Report a–d pass/fail. On all-pass I sync via the script (standing gate), commit
`fix(lpbitcoin): hub menu reach scales with model bounds`, and PR. Nothing commits before that.

## Sensor honesty
e/f are proven on synthetic bounds — the reach MATH is what the fix changes, and the probe drives
it directly, so this is a real sensor on the thing under test, not a proxy. a–d are the live
interaction proof that only a human at the keyboard can drive (aim/use/grab/pocket); `simulate_input`
drives named actions, not "aim at entity X and use." The bridge addon republish (1.20.0 → 2.0.0)
can ride this same sitting.
