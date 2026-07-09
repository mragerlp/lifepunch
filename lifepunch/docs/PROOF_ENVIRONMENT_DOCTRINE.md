# Proof Environment Doctrine — the Two-Scene Law

Status: CANON — ratified 2026-07-09. Process law: where a claim gets proven.
Companions: `OPS_LOG.md` (the pattern in practice) · `UPGRADE_ARC_DESIGN.md`
(gate design) · `ECONOMY_DOCTRINE.md` (what the identities mean).

---

## THE TWO-SCENE LAW

**Development and proof run in the cheapest scene that can host the claim.**

### Fast scene (the default)

DXRP gamemode + a **minimal map** — no hammer terrain, clean sightlines,
negligible geometry. **Editor performance is a first-class working
condition:** a wedged or grinding editor has cost this project hours, and the
fast scene is the cheapest boot that still runs the gamemode.

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

---

## Investigation — Dimmer's dev-scene pattern (report, 2026-07-09)

**Finding: we already have the fast scene, and it is more minimal than
flatgrass.** `Code/Addons/lifepunch/_dev/LifePunchDevPlaytest.cs` defines it:

- **`scenes/blank.scene`** — DXRP core prefab + a dev plane
  (`models/dev/plane.vmdl`, 100×100), **no hammer map, no `MapInstance`**.
  Faster boot than flatgrass, clean scale shots. `lp_dev_scene` prints the
  runbook (open blank.scene → Host Play).
- **`lp_map_flatgrass`** (legacy) swaps a live scene's `MapInstance.MapName`
  to `facepunch.flatgrass` — kept only for when hammer terrain is actually
  needed.

**Mechanism of the portal default-map override:** the map is a `MapInstance`
component carrying a `MapName`; the server/portal default flows through the
Fitter (`MapFitter.cs`) which fits landmark prefabs by that name. **Host Play
from `blank.scene` has no `MapInstance`**, so nothing to override — the portal
default never engages. That is the clean bypass; no api-key wrangling needed.

**Proposal (owner GO):** adopt **`scenes/blank.scene` as the canonical fast
scene**, retire flatgrass to the "need hammer terrain" case. It is cheaper than
flatgrass, already committed, and already the recommended path in
`lp_dev_scene`. Open question worth asking Dimmer: whether his saved dev scene
adds anything blank.scene lacks (pre-placed rigs? a landmark stub?) — if not,
we are already on the pattern.

---

## Cross-references

- `OPS_LOG.md` — the three lpbitcoin gates ran on flatgrass; **the pattern was
  discovered before it was named.** This doctrine names it.
- `UPGRADE_ARC_DESIGN.md` — gate design cites which scene each case proves in,
  and (Identity Rider) which cases need the second portal identity.
