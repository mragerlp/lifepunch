# Proof Environment Doctrine — the Two-Scene Law

Status: CANON — ratified 2026-07-09. Process law: where a claim gets proven.
Companions: `OPS_LOG.md` (the pattern in practice) · `UPGRADE_ARC_DESIGN.md`
(gate design) · `ECONOMY_DOCTRINE.md` (what the identities mean).

---

## THE TWO-SCENE LAW

**Development and proof run in the cheapest scene that can host the claim.**

### Fast scene (the default) — `scenes/blank.scene`

**The canonical fast scene is `scenes/blank.scene`** (ruled 2026-07-09):
DXRP core prefab + a dev plane (`models/dev/plane.vmdl`, 100×100), **no hammer
map, no `MapInstance`.** It is the default for **all map-independent proof.**
Flatgrass is demoted to the **"needs hammer terrain" case only.**

**Editor performance is a first-class working condition:** a wedged or grinding
editor has cost this project hours, and blank.scene is the cheapest boot that
still runs the gamemode — no map load at all.

**No `MapInstance` = the clean bypass of the portal's default-map override.**
The server/portal default flows through a scene's `MapInstance.MapName` and the
Fitter; blank.scene carries no `MapInstance`, so there is nothing to override
and no api-key wrangling. `LifePunchDevPlaytest.cs` already recommended this
scene (`lp_dev_scene`) — **the pattern predated its naming**, same as the
flatgrass note in `OPS_LOG.md`.

Everything the map **cannot influence** is proven here:

- ledgers, money paths, tier effects
- persistence / rehydrate / restart legs
- entity contracts, UI panels, purchase flows
- `PayoutTarget` routing

### World scene (on purpose)

The **real server map** — Bank, PD, Hospital, drop landmarks, real geometry.
Reserved for claims whose behavior **IS** the map:

- window-drop landmarks and their 15/45 train cycle
- bank-raid sightlines and the visible money pile
- PD / Hospital proximity and the Hierarchy of Protection
- hub / terminal placement, and interact-vs-grab distances in real geometry

### The rule

**Build and prove in the fast scene; SHIP into the world scene.** A system that
only works in the world scene **has a map dependency, and that dependency must
be named in its design doc.** No silent map coupling.

### Known lever

The portal / api-key path drives the map to the **server default** (the Fitter
resolves landmark prefabs by map name — `World/MapFitter.cs`, `FittedMapPrefabs`
keyed on the map; `Api/ServerApiLink.cs` is the portal side). The fast scene
**sidesteps this entirely** by not loading a map at all (see Investigation).

---

## IDENTITY RIDER (companion law) — bots populate, only portal identities prove

**Bots have no SteamID, no balance, no ledger scope.** They prove *world*
behavior (crowding, pathing, targets to shoot) — **never economic behavior.**

- **One identity:** single-player Bloodwave suffices for any claim about *a*
  player — his own ledger, his own wallet, his own tiers. Every gate 1/2/3 ran
  this way.
- **Two identities:** any claim about **two** portal identities requires
  **Cornerman as Splash God** (a second portal player with a real SteamID).
  This is mandatory for: gate-2b's three cases (non-owner rejection, concurrent
  race, cross-operator isolation), Trust Policy, the Fund's pro-rata payout,
  the Banker's ATM, Guard pay, and **every** hacking / adversarial case.

**Name the identity requirement in each system's gate design UP FRONT** — a
two-identity claim discovered mid-gate is a stall; declared up front it is a
scheduling line.

**Ops rider (gate design, 3.5 onward):** every gate case list carries a header
naming its **SCENE** (fast/`blank.scene` or world) and its **IDENTITY**
requirement (one portal identity, or two = Cornerman as Splash God). Both are
declared before the first case, never discovered inside it.

---

## Provenance (resolved 2026-07-09)

The fast scene was not built for this doctrine — it already existed.
`Code/Addons/lifepunch/_dev/LifePunchDevPlaytest.cs` defines
`scenes/blank.scene` (via `lp_dev_scene`) and keeps `lp_map_flatgrass` as the
legacy `MapInstance.MapName` → `facepunch.flatgrass` swap for hammer-terrain
cases. The portal default-map override runs through `MapInstance` + the Fitter
(`MapFitter.cs`, `FittedMapPrefabs` keyed on map name; `Api/ServerApiLink.cs`
is the portal side); blank.scene's absence of a `MapInstance` is why the
default never engages. Bloodwave is asking Dimmer directly whether his saved
dev scene adds anything ours lacks — no draft owed.

---

## THE SENSOR LAW (companion law) — every claim carries its sensor

**A gate does not assert; it observes.** Before claiming anything, name the
sensor and prove it reads the thing under test. A green result off the wrong
sensor is worse than a red — it is a *false* green, and false greens are what
this section exists to prevent.

**FRESH is two facts, not one.** A compile "looks clean" only proves *recent*
bytes compiled. To prove the compiler read **YOUR** bytes:
1. the compile/parser log timestamp POSTDATES the file write, AND
2. a **positive code-string ID** — a string that exists nowhere except your
   edit appears in the log or the tool result.

**When no sensor reads the thing under test, BUILD one.** This is the law
applied to itself.

Worked examples (each named the technique):
- **Build-the-sensor** — a `.cs` change emits no free log line, so plant one: the
  preview harness logs `rig0 mix linked — 2 standard + 1 advanced`; observing it
  proves the running assembly is yours.
- **EOL-aware compare** — Red repo is LF, the editor tree is CRLF, so drift checks
  compare content ignoring line endings (`diff <(tr -d '\r' A) <(tr -d '\r' B)`);
  a raw hash reports every file as drift and is wrong.
- **Parser-error-as-sensor** — a `.razor.scss` change has no code string, but the
  stylesheet's malformed `@media` rule logs its line number; the number shifting
  `7126 → 7135` (exactly the lines added) proves the parser read the new bytes.
- **Behavioral-repaint-as-positive-ID** — the wallet-hash fix: injecting 1,234
  sats repainted the pane `0.000000 → 0.000012` with no navigation; the old 4dp
  hash mapped 1,234 sats to zero, so only the new code could produce that repaint
   — the behavior IS the ID.
- **Synthetic-bounds probe (reproduce-then-fix in a probe)** — the hub-reach fix:
  `HubReachProbe()` runs the reach math on synthetic bounds reproducing the
  failing geometry (`oldPivotPass=False` across tall/short/big hubs) BEFORE
  showing `newBoundsPass=True`; the probe reproduces the bug, then proves the fix,
  without a live hub.
- **The clone is a sensor** — Packet E: *Red validated the input paths against
  Red's tree; the worker reads Green's.* The clone was reading an old world. Two
  compounding traps: a nested repo (`lifepunchdxrp/`) does not travel with the
  parent's `git pull` — it is `.gitignore`d and separately cloned, so a hand-copied
  folder sits frozen indefinitely; and a **git-less snapshot is not a clone**, so
  nothing on it can be verified at all. The fix is the law applied to itself: when
  no sensor reads the thing under test, build one. `expectedClones` makes the
  authoring node *declare* the commits it validated against, and the worker asserts
  them on ITS node before reading a byte — refusing by name, never substituting.
  Prose in `contextNotes` is a human record; only a machine-checked field is a sensor.

- **Anchor the pattern to STRUCTURE, never to a word** — *a sensor that reports what it did not
  measure is a broken sensor, even when its conclusion happens to be right.* Two cases, one
  session, identical shape: an over-permissive regex matched **prose** where it should have
  matched **structure**.
  - An attribution audit for AI trailers matched the literal string `CLAUDE.md` — a *filename*,
    not a trailer. It should have anchored to a trailer's line-start (`^Co-Authored-By:`).
  - A verdict detector meant to prove a gate script was unexecuted matched the prose *"proven to
    be needed"* — an *English phrase*, not a measured value. It should have anchored to the shape
    of a measurement (`oldPivotPass=`, a `key=value` pair, a line-start `verdict:`).

  Both patterns were unanchored and case-insensitive, so both matched sentences. **Neither reached
  a conclusion, because the result was verified before it was acted on** — the discipline held; the
  sensor did not. That is the point: a sensor you have to double-check by hand is not yet a sensor.
  Anchor to the structure you are detecting.

  Two riders the gate pinned:
  - `.gitignore` patterns are **anchored to the exact name**: `/lifepunchdxrp/`
    ignores that directory and nothing else, so a clone-swap that leaves a
    `lifepunchdxrp_stale` sibling behind is *untracked debris* and trips the
    dirty-tree gate. **A clone-swap procedure must leave zero untracked debris**, or
    the freshness check and the clean-check fight each other.
  - Under `$ErrorActionPreference='Stop'`, PowerShell 5.1 turns any native-command
    stderr into a terminating `NativeCommandError`. A failing `git cat-file -e
    <missing-sha>` writes to stderr — so the naive precondition *crashes* on the
    exact case it exists to catch. Read-only git goes through `Invoke-CdwGit`, which
    returns an exit code and never throws. A fail-closed check that dies loudly
    instead of refusing cleanly is still a broken sensor.

### Harness code is not exempt from invariants

A dev/preview/test harness that manufactures a state the shipped code declares
impossible is a bug, not a convenience. *Case:* the preview harness left
`AdvancedRack` at its `= true` default and built three advanced racks, so the
hub's reconcile stamped all three with the single `advancedgpurack` slot token —
a positional slot-token collision, the exact class the free-tier-leak fix
hardened against. The harness was producing an impossible state. Gate harness
code against the same invariants as ship code.

### Regression law — a constant cannot satisfy a scaling requirement

When a requirement is "X must exceed Y for ANY size," a hand-tuned constant is a
fix for one size, not the requirement — and it fails silently when the size
changes. *Case (Item E):* commit `30d4686` fixed the hub's menu reach to exceed
grab-reach by widening it to a fixed 4.25 m horizontal — but left the vertical a
fixed 1.5 m measured from the pivot. For a ground-aligned hub (pivot at z≈0) a
standing player's ~1.63 m eye failed the vertical check, so Hands+E opened
nothing while the Build tool worked. The constant satisfied the horizontal case
and silently failed the vertical. The fix measures to the model bounds, so reach
scales with the model — the requirement, not a size.

## Cross-references

- `OPS_LOG.md` — the three lpbitcoin gates ran on flatgrass; **the pattern was
  discovered before it was named.** This doctrine names it.
- `UPGRADE_ARC_DESIGN.md` — gate design cites which scene each case proves in,
  and (Identity Rider) which cases need the second portal identity.
