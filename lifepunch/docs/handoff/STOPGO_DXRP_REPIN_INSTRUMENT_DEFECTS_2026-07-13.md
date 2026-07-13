# STOP-GO — DXRP re-pin instruments: three defects, found and repaired

**Status:** **DEFECTS CONFIRMED AND REPAIRED 2026-07-13.** This is a RECORD (write-once).
The gate script and its verdict freeze together as one record; a re-run needs a new script.

**Basis:** Red machine-verified on `develop @ 2c0de17`; fork `C:\Users\jared\Projects\dxrp-public`.
**Lineage:** `red\0014` (defects found, re-pin STOPPED) → Bloodwave RULING A → `red\0015`
(supersession found) → `red\0016` (merge M landed) → this record (instruments repaired).
**Leads:** `codex\0009` (leads-grade diffs, advice-class). Every cite below is Red-machine-verified;
where Red departed from the leads, it is named.

---

## Why this record exists

The 2026-07-11 ruling (`STOPGO_DXRP_REPIN_2026-07-11.md`) said MERGE, not rebase, because
`b9d6068` is a **load-bearing sensor pin**: Packet E, Packet G and the P1 verdict all cite
"measured at `b9d6068`" **by hash**.

The sanctioned instrument did the opposite. Told to execute that ruling, it would have executed
its negation — and reported success.

## Defect 1 — the FF that silently orphans the load-bearing pin (CRITICAL)

`sync-dxrp-fork.ps1:47-48` (pre-repair) ran:

    git switch develop
    git pull --ff-only upstream develop

Measured on the live fork:

    merge-base --is-ancestor b9d6068 56875a9   -> FALSE   b9d6068 NOT in upstream's ancestry
    merge-base --is-ancestor 0ee91dd 56875a9   -> TRUE    local develop IS an upstream ancestor

So the pull **succeeds as a clean fast-forward**, lands `develop` on pure-upstream lineage, and
drops the fork's commits from the operational line. `-UpdatePin` would then stamp a pin that
cannot reach `b9d6068`, and every packet citing it by hash loses its footing.

**THE GUARDRAIL COULD NOT FIRE.** The standing rail is "every merge is `--ff-only`, any non-FF =
STOP." That rail watches for a failure this defect does not produce: **the wrong operation here IS
a clean fast-forward.** It exits 0. No error, no warning. The damage travels precisely where
nothing is looking.

**REPAIR — the guard asks the right question.** Not *"is this a fast-forward?"* but *"does the
prospective result still contain the floor?"* Both instruments now assert, **before any branch
mutation**, that `ancestryGuard.requiredAncestorSha` is reachable from the proposed result, and
refuse loudly if not. The check is repeated against the actual fork HEAD before any pin write, and
again before any push.

## Defect 2 — sync and re-pin drift apart silently

`-Sync` alone never rewrote the pin: the write is gated separately at
`Ensure-DxrpUpstreamCurrent.ps1:139` on `-UpdatePin`. A relay saying "re-pin via `-Sync`" would
mutate the fork and leave the pin stale — manufacturing a fresh three-way split, the exact
condition the 2026-07-11 ruling set out to end.

Worse, the writer stamped `$upstreamSha` (`:151`) — the **upstream tip** — not the fork HEAD. After
an authored merge that is simply the wrong commit: upstream is an *ancestor* of `M`, not equal to it.

**REPAIR.** Explicit modes. `-Repin` = guarded `-Sync` + `-UpdatePin`. `-Sync` alone now says
**`DID NOT RE-PIN`** out loud. `-UpdatePin` alone is supported and is the authored-merge
reconciliation path. The pin records the **verified fork develop HEAD**, and refuses to write at all
unless the fork actually contains upstream.

## Defect 3 — the ruling's `-WhatIf` safety did not exist

The ruling prescribed `-WhatIf`-first. Neither script implemented it:
`Ensure-DxrpUpstreamCurrent.ps1:32` was `[CmdletBinding()]` **without** `SupportsShouldProcess`, and
`sync-dxrp-fork.ps1:8` was a plain `param()`. There were no `ShouldProcess` calls at all. A dry run
was impossible. **Red did not test this by invoking the script:** had the static read been wrong in
the unsafe direction, the "test" would have been the mutation.

**REPAIR.** Both scripts are `[CmdletBinding(SupportsShouldProcess)]`; every fetch, switch, merge,
child-sync, Steam sync, pin write and push sits behind `ShouldProcess`. `-WhatIf` performs reads
only and says plainly that refs were not refreshed.

## Two more, found by Red while verifying — neither was in the leads

**A. Check mode was mutating the fork.** `Ensure-DxrpUpstreamCurrent.ps1:80` called
`git switch develop` **unconditionally** — outside `-Sync`, outside any gate. `-FailIfBehind` is
called on **every editor launch** (`Start-SboxDxrpEditor.ps1:113`), so every editor-launch preflight
has been silently switching the fork's checked-out branch. Check mode now reads
`rev-parse refs/heads/develop` and touches nothing.

**B. The leads would have weakened the editor gate.** `codex\0009` proposed `$behind = $forkBehind`,
replacing `max($pinBehind, $forkBehind)`. That fixes the pin write but silently changes
`-FailIfBehind`, whose two callers are `Start-SboxDxrpEditor.ps1` (**blocks launch**) and
`Setup-ModelDocGreenfieldEditor.ps1` (warns): a **stale pin record with a current fork would no
longer block an editor launch.** Codex flagged this as NEEDS-RED-MACHINE-VERIFY and was right to.

**Red's departure from the leads:** split the variable instead of redefining it.
`syncBehind = forkBehind` drives sync and pin gating; `gateBehind = max(pinBehind, forkBehind)`
drives `-FailIfBehind`. The pin write is fixed **and** the preflight contract is preserved.

## Defect 4 (schema) — a stamp that read like a pointer

`localPaths.forkCheckout` recorded whichever machine last ran the sync. Nothing reads it — the gate
script derives its own path — but a reader on another machine trusts it and goes to the wrong
directory, which is exactly what happened to Green during the divergence recon. Renamed
**`lastSyncedFrom`**: it now reads as the stamp it always was.

---

## THE GATE — executed, verdict frozen with the script

Script: `lifepunch/scripts/gates/Gate-DxrpAncestryGuard.ps1` (disposable fixture; the live fork is
never touched). The fixture reproduces the exact defect shape: fork tip `F` is **not** an ancestor of
upstream tip `U`, while `develop` sits on an upstream ancestor `P` — so an FF to `U` is *clean* and
orphans `F`.

| # | Assertion | Result |
|---|---|---|
| 1 | Guard REFUSES the orphaning FF (`ANCESTRY GUARD FAILED`); `develop` unmoved; all refs unchanged | **PASS** |
| 2 | **Non-vacuity:** same fixture, valid floor → `ANCESTRY GUARD PASS` (the guard discriminates, it does not always-throw) | **PASS** |
| 3 | `-WhatIf` mutates nothing: refs byte-identical, branch unmoved, worktree clean | **PASS** |
| 4 | `-Sync` alone announces `SYNC ONLY` + `DID NOT RE-PIN`; pin file SHA-256 unchanged | **PASS** |
| 5 | Check mode does **not** switch branches (defect A) | **PASS** |

**GATE: PASS (5/5).** Parser: 0 errors on both scripts. Mutator census: 4 `ShouldProcess` sites in
each; no `reset` / `clean` / `stash` / force-push introduced.

Test 2 is the one that matters most. A guard that always throws would pass Test 1 and be useless.

## Honest bounds

- **The real-run FF and push paths are NOT exercised.** The fixture asserts the remote URLs the
  scripts require but performs no network; every test runs under `-WhatIf` or stops at the guard.
  The mutating path is proven *gated*, not proven *correct end-to-end*. The next real `-Repin` is
  its first live exercise and should be run `-WhatIf` first — which is now actually possible.
- **`Sync-DxrpSteamCheckout.ps1` is unchanged** and has its own dry-run behaviour, unverified here.
  The outer `ShouldProcess` prevents invocation under `-WhatIf`; direct invocation is out of scope.
- **Nothing here is compile- or runtime-proven** in the s&box sense. No editor ran.

## Cross-references

- `STOPGO_DXRP_REPIN_2026-07-11.md` — the ruling these instruments now enforce. **UNTOUCHED.**
- `lifepunch/config/dxrp-upstream-pin.json` — schema v2, `ancestryGuard`.
- `lifepunch/scripts/Ensure-DxrpUpstreamCurrent.ps1`, `lifepunch/scripts/sync-dxrp-fork.ps1`.
- `CLAUDE.md` — Sensor Law, Conductor's Mirror.
