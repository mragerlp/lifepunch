# RECORD — Hub interact fix, cases e/f: PROVEN

- **Status:** RECORD. **Frozen** — its verdict has landed. Write-once.
- **Date:** 2026-07-10. `develop` @ `f1355cf` + working-tree changes to
  `LifePunchMenuInteractRange.cs` + `LifePunchMenuInteractGate.cs` (fix applied, uncommitted).
- **Instrument:** the un-run cases a–d live in `GATE_HUB_INTERACT_ADRIVE_2026-07-10.md`, which
  remains editable until Bloodwave drives it.
- **Provenance:** split from the original hybrid gate on 2026-07-10 under the write-once
  clarification (a document is one document only if the test returns one answer). The e/f content
  below is carried over **verbatim**; nothing was reworded on the way in.

---

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

## Sensor honesty

e/f are proven on synthetic bounds — the reach MATH is what the fix changes, and the probe drives
it directly, so this is a real sensor on the thing under test, not a proxy.

a–d are the live interaction proof that only a human at the keyboard can drive (aim/use/grab/
pocket); `simulate_input` drives named actions, not "aim at entity X and use." Those cases are
**not** proven by this record — see the instrument.

---

**Nothing commits on e/f alone.** The fix stays uncommitted until a–d pass with Bloodwave driving.
