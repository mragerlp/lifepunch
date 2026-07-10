# GATE SCRIPT — Hub interact fix, cases a–d: Bloodwave drives

- **Status:** INSTRUMENT. **Unexecuted** — no verdict recorded here yet. Editable until it runs.
- **Record:** cases e/f already landed. Their verdict is frozen in
  `GATE_HUB_INTERACT_EF_VERDICT_2026-07-10.md`. Do not restate it here; cite it.
- **Provenance:** split from the original hybrid gate on 2026-07-10 under the write-once
  clarification. This file is the un-run half.

**Fix APPLIED (uncommitted). a–d need you at the keyboard in a game scene with a pawn. Nothing
commits until a–d pass with you driving.** Base: the `develop` **tip at drive time**, plus
working-tree changes to `LifePunchMenuInteractRange.cs` + `LifePunchMenuInteractGate.cs`.

> **No base commit is written here, deliberately.** A literal tip goes stale the moment the next
> commit lands, and this instrument has already outlived three of them (`f1355cf` → `600bebb` →
> and on). A stale literal invites a false abort over a number that was never the sensor.
>
> **The rule instead:** the two held files are **byte-identical across every commit since
> `f1355cf`** — every one of them is docs or config — so the held patch applies to the same base
> code whatever the tip reads. Verify it at drive time, in one line:
>
> ```bash
> git diff --quiet f1355cf HEAD -- \
>   lifepunchaddons/Code/Addons/lifepunch/LifePunchMenuInteractRange.cs \
>   lifepunchaddons/Code/Addons/lifepunch/LifePunchMenuInteractGate.cs \
>   && echo "base unchanged" || echo "BASE MOVED — re-check the premise"
> ```
>
> **And the base commit is not the sensor anyway. P0 is.** The editor compiles a hand-synced
> copy; what matters is whether *that tree* carries the fix, not which commit the repo sits on.
> A green P0 with a "stale" base is a pass; a red P0 with a fresh base is an abort.
>
> *This is the `expectedClones` lesson, applied before it costs a sitting: a document that
> records a moving tip records a value that is wrong by the time anyone reads it.*

`GATE HEADER: SCENE: game/map (NOT blank.scene preview) · IDENTITY: one, with a real pawn`

---

## Preconditions

A game/map scene, your pawn spawned, a Bitcoin Hub placed and powered (`lp_bitcoin_spawn_hub`
needs a local viewer — hence a pawn scene, not the editor preview).

### P0 — the editor tree carries the fix. ASSERT BEFORE DRIVING.

**The editor compiles `D:\Steam\steamapps\common\sbox\dxrp\game`, not this repo.** An unsynced
editor tree makes case (a) fail on **old bytes**, and that false red is indistinguishable from
"the fix is wrong." Sync used to sit at the *end* of this gate, on all-pass. That is backwards:
syncing after the drive proves nothing about the bytes that were driven.

Assert byte-identity for BOTH files, **EOL-aware** — the repo is LF, the editor tree is CRLF,
so a raw hash reports every file as drift and is wrong:

```bash
for f in LifePunchMenuInteractRange.cs LifePunchMenuInteractGate.cs; do
  diff <(tr -d '\r' < "lifepunchaddons/Code/Addons/lifepunch/$f") \
       <(tr -d '\r' < "/d/Steam/steamapps/common/sbox/dxrp/game/Code/Addons/lifepunch/$f") \
    >/dev/null && echo "$f MATCHES" || echo "$f DIFFERS — ABORT"
done
```

**A mismatch ABORTS the sitting.** Do not sync mid-gate — a tree that changes under a running
gate invalidates every case already driven, because the assembly under test is no longer the
assembly the earlier cases passed on. Sync, then restart from P0.

*Measured 2026-07-10: both files MATCH the editor tree. No sync is needed today. The assertion
is what this gate needs, not the script.*

## Cases a–d — YOU DRIVE

**a. Hands+E opens the Hub menu** — the symptom.
  1. Equip Hands. Stand at normal facing distance (where you'd read the hub), NOT nose-to-glass.
  2. Aim at the hub, press **E**.
  3. PASS = the HASHD/Bitcoin Ops menu opens. (Before the fix: nothing happened here.)

  **Case (a) is itself the positive code-string ID.** `GATE_HUB_INTERACT_EF_VERDICT_2026-07-10.md`
  recorded `oldPivotPass=False` — the old code could not open this menu from reading distance.
  A menu that opens is a behavior only the new code can produce, and per the Sensor Law a
  behavioral change only the new code could produce **is** a positive ID. No `Log.Info` needs
  planting for a–d. This holds **only once P0 is asserted**; without P0, (a) is ambiguous
  rather than evidential — a red could mean stale bytes, and a green could mean you are driving
  a build nobody identified.

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

Report a–d pass/fail. On all-pass Red commits
`fix(lpbitcoin): hub menu reach scales with model bounds`, and PRs. **Nothing commits before that.**

*(The sync step that used to live here moved to **P0**, before the drive. A sync performed after
the drive says nothing about the bytes that were actually driven.)*

## Fail-branch — any case red

**Freeze. Capture. Report. Do not patch live.**

1. **Stop driving.** Change nothing in the repo and nothing in the editor tree.
2. **Capture** — which case, what was observed, and an `sbox` bridge screenshot from Red.
3. **Re-assert P0 before concluding anything.** A red with an unverified editor tree is not a
   result; it is an unknown wearing a result's clothes.
4. **Report.** A fix authored mid-gate invalidates every case already driven, because the
   assembly under test is no longer the assembly the earlier cases passed on. A re-run needs a
   new gate script citing this one.

When the a–d verdict lands, this instrument and its result freeze together as one record — a
re-run needs a new gate script citing this one.

## Sensor honesty

a–d are the live interaction proof that only a human at the keyboard can drive (aim/use/grab/
pocket); `simulate_input` drives named actions, not "aim at entity X and use." That is why this
half could never be closed from Red's side, and why it is still an instrument.

The bridge addon republish (1.20.0 → 2.0.0) can ride this same sitting.
