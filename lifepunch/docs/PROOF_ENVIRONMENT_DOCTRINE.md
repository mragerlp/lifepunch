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

## Cross-references

- `OPS_LOG.md` — the three lpbitcoin gates ran on flatgrass; **the pattern was
  discovered before it was named.** This doctrine names it.
- `UPGRADE_ARC_DESIGN.md` — gate design cites which scene each case proves in,
  and (Identity Rider) which cases need the second portal identity.
