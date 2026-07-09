# Parent-Game Targeting — banked design pass (opened 2026-07-09)

Status: DESIGN PASS, not scheduled. Opened by a live collision during slice-2
gate-2. The 26.07.08 engine feature ("Target/Parent Game" in Project Settings)
is real and worth adopting — but our project isn't structured for it yet.
Reverted mid-gate; adoption is this deliberate pass, never mid-slice.

## Opening finding — the duplicate-assembly collision (empirical, 2026-07-09)

Setting Parent Game = DXRP on our project (`lifepunch.rp`) produced **765 log
errors that are all ONE error**, repeated per component per scene-load:

```
[A] Dxura.RP.Game.Player  from  package.dxura.rp     v0.0.157  (the PARENT)
[B] Dxura.RP.Game.Player  from  package.lifepunch.rp v0.0.140  (OUR project)
    "cannot be cast to" — Player, HealthComponent, AnimationHelper, nameplate, …
```

Two isolated assembly contexts each define the full `Dxura.RP.Game.*` type set;
the scene deserializer can't cast one context's `Player` to the other's, so the
game scene fails to load. **Runtime load errors, not CS compile errors** — no
product code is wrong; the project simply can't boot.

Root cause: the parent package serves its OWN copy of DXRP (`package.dxura.rp`),
but our project ALSO contains the full DXRP source (the `lifepunchdxrp` fork our
sync scripts mirror in). Parent-game targeting = every DXRP type defined twice.

## The requirement it exposes — child carries ONLY the addon layer

Parent-game targeting expects the child project to contain **only** its addon
code (lpbitcoin, lifepunchulx, the `lifepunch/` shared root), with the PARENT
providing all of DXRP. Our current project is the opposite: it IS a full DXRP
fork with our addons synced on top. Adopting parent-game means:

- **Strip the duplicated DXRP source** from the targeting project — the child
  references DXRP types from the parent package, never re-defines them.
- **The integrity test gets native enforcement:** "would this survive a clean
  vanilla DXRP pull?" stops being discipline and becomes structural — a child
  that only holds the addon layer literally cannot contaminate core.

## The sync-script inversion question (design decision, not yet answered)

Today `Sync-LifePunchAddonsToDxrp.ps1` mirrors our addon trees INTO the DXRP
game project (repo → `D:\Steam\...\dxrp\game`). Parent-game targeting likely
INVERTS this: the addon project stands alone and *targets* DXRP as a package,
so there may be nothing to sync into — the editor resolves the parent from the
portal/package cache. Open questions for the pass:
- Does the targeting child live in its own project dir (not inside `dxrp/game`)?
- What replaces the sync step — a package reference to a pinned DXRP version?
- How does the pinned parent version relate to `dxrp-upstream-pin.json` and the
  `Ensure-DxrpUpstreamCurrent` gate? (Parent version 0.0.157 vs our fork's — a
  new pin surface.)
- Ripple into `DXRP_ADDON_PUBLISH_DOCTRINE`, `PACKAGE_STAGING_LAYOUT`, and the
  editor-launch workbench line.

## Ledger data-root org-keying (discovered same session)

`FileSystem.Data` resolves per-org: `data\<org>\<ident>#local`. With org
`dxura` the ledger store is `data\dxura\rp#local\lifepunch-upgrade-ledger.json`.
Changing Organization Ident (parent-game re-parenting flipped org to `lifepunch`)
**re-points the data root** — a fresh session under a new org loads ZERO records
unless the store is migrated. Implication for the pass: the ledger store path is
org-bound; any org/ident change is a store migration, and the addon must either
pin its data root explicitly or the migration must be a documented adoption step.
(Tonight: reverted to `dxura`, store reconciled from the `handoff/` backups.)

## Working identity — `lifepunch.rp` (owner ruling 2026-07-09)

Reverting Parent Game to none did NOT revert Organization Ident — the project
now runs as org `lifepunch`, ident `rp`. Owner ruling: **`lifepunch` stays** —
intended identity, deliberately set, exonerated of the collision (which was the
duplicate-DXRP-source problem, not the org). Costs are already paid: the ledger
store was migrated to `data\lifepunch\rp#local`; portal snapshots start fresh
under `lifepunch.rp` (dev-only, no production loss).

**This design pass owns the full identity-mapping question** — fork identity vs
standalone addon-project identity vs the parent-child endgame identities, and
which one the ledger data root / portal snapshot namespace / publish lane each
bind to. `lifepunch` is the working identity until this pass rules formally.

## Motivating observation — the middle state has a felt cost (owner, 2026-07-09)

Since the gate-2 revert, the editor presents the project as **standalone** — no
parented-DXRP presentation in the header/session. Functionally identical
(fork-embedded DXRP runs; the gates prove it), but the owner flags the
ambiguity as a felt cost of the middle state: the project reads as if DXRP
weren't underneath it, when DXRP is the entire foundation.

**Reaffirmed:** DXRP remains the foundation — this pass is **PRO-parent, never
removal**. Its end state restores TRUE DXRP parentage at the engine level, so
the presentation matches the architecture again.

## Adoption gate (when scheduled)

A clean parent-game project must: boot the game scene with ZERO duplicate-type
errors · contain no `Dxura.RP.Game.*` definitions of its own · resolve DXRP from
the pinned parent package · pass the addon's own gates (lpbitcoin gate-1/2)
unchanged · keep the ledger store reachable across the org identity. Prove on a
throwaway copy before touching the working project.
