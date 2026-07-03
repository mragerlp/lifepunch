# Coke Drug Line — Reskin Spec (work off the weed engine)

**Status:** Asset intake in progress (built coca seed/leaf/stations in repo; coke-bag/brick ModelDoc TBD).  
**Addon lane:** `advanceddrugprocessing` (`lifepunch.advanceddrugprocessing` · portal `019e36bf-31bf-7b2a-a56f-1ab4467cec29`)  
**Strategy:** Same reframe as weapons — **the DXRP weed grow system is the class; coke is our skin.**

**Intake note (2026-06-11):** Owner pack is an **enhanced processing line** (coca seed → leaf → processing/packing stations → bag/brick), not only pot-grow meshes. Map stations to weed drying/packaging in editor; see `Assets/.../advanceddrugprocessing/COKE_LINE_MAP.md`.

---

## 1. The idea (owner vision)

Use the **same entities and flow** the drug dealer job already uses to grow weed — pots, seeds, growth stages, bags, sell/drop-off — but swap every **visible prop** to a **cocaine line**:

| Weed (engine) | Coke (LifePunch skin) |
|---------------|------------------------|
| Weed pot | **Reuse same pot** (or reskin mesh optional) |
| Weed seeds | **Coke seeds** (your asset) |
| Plant / growth stages | **Coke plant / leaves** (your asset) |
| Weed bag / product | **Coke brick / coke bag** (your assets) |
| Grow timers, interact, pocket, job gates | **Keep engine behavior** — tune prices/names only |

**Do not rewrite the grow simulation.** Clone the weed prefab/component wiring, replace `Model` / stage meshes, update display names and economy constants.

---

## 2. Why this is the right shape

Mirrors `WEAPON_PROGRAM.md`:

- Gun Dealer shipment pipeline is **generic** → we only ship class kits.  
- Drug grow pipeline is **generic** → we only ship **stage meshes + product prefabs + portal config**.

Discovery paid once on weed (in DXRP / `advanceddrugprocessing`). Coke is **asset + config**, not a new game system.

---

## 3. What to study first (VENGEANCE editor)

On the LifePunch DXRP dev server with **Advanced Drug Processing** mounted:

1. Spawn menu → find **weed** entities (pot, seed, plant stages, bag, etc.).
2. Note each prefab path under mounted `addons/lifepunch/advanceddrugprocessing/` (or gamemode path if base DXRP).
3. Open one **pot + seed + mature plant** chain in editor:
   - Which **components** drive growth? (`[Sync]` stages, timers, interact)
   - Which **child models** swap per stage?
   - What **content rows** in portal point at each entity?
4. Document the **stage graph** (seed placed → stage 1 → … → harvest → bag).

> Repo today: **built vmdls + prefabs** promoted (`coca_seed`, `coca_leaf`, `processing_station`, `packing_station`, `meth_lab`); `coke-bag` / `coke-brick` are raw intake. Live weed behavior still lives in the **published portal revision** — editor inspection is source of truth until we pull code into the monorepo.

---

## 4. Asset intake (owner has meshes)

Owner assets: **seeds, leaves, bricks, bags** (+ optional plant stages).

```text
C:/lifepunch/reference-intake/coke-drug/
  seeds/
  leaves/
  bricks/
  bags/
  pots/          ← only if reskinning pot; else reuse weed pot prefab
```

Promote to repo after ModelDoc:

```text
Assets/addons/lifepunch/advanceddrugprocessing/
  models/lifepunch/advanceddrugprocessing/
    coke_seed/
    coke_plant/          ← growth stages (or one mesh + scale)
    coke_leaf/
    coke_brick/
    coke_bag/
  entities/
    coke_pot/            ← clone from weed pot OR symlink same prefab
    coke_seed/
    coke_plant/
    coke_bag/
    coke_brick/
```

---

## 5. Build order (repeatable)

| Step | Where | Work |
|------|-------|------|
| 1 | Editor | Map weed entity chain → coke equivalent table |
| 2 | Blender | FBX per coke prop; match **footprint** of weed counterpart |
| 3 | ModelDoc | `.vmdl` + materials per prop |
| 4 | Editor | Clone weed prefabs → save under `advanceddrugprocessing/entities/`; swap models only |
| 5 | Portal | New **content rows** (type 0) for coke entities OR override world models on existing rows |
| 6 | Portal | Job/market config — drug dealer job, prices, drop-off item id (if separate from weed) |
| 7 | Publish | `prepare-publish.ps1 -Addon advanceddrugprocessing` |

**Code changes:** likely **minimal or zero** if weed logic is entirely prefab + config driven. If entity C# hardcodes `"weed"` strings or item ids, branch or data-drive (Tier-1 Opus).

---

## 6. Economy & rules (high-stakes)

- Touches **drug income** and server economy → **Tier-1 (Opus)** validation before ship.
- Server rules (`Rules-V1`) reference **weed drop-offs** today — decide: coke uses **same drop-off** with different item, or new zones (rules + staff policy).
- Wallet/bank: follow existing drug sell pattern (likely wallet cash like other DXRP drugs).

---

## 7. Anti-spaghetti

- ✅ One grow **class** (weed engine), coke = **data + meshes**
- ✅ Reuse pot entity unless art demands otherwise
- ❌ Do not fork a second grow system
- ❌ Do not copy third-party DarkRP weed Lua — DXRP s&box entities only

---

## 8. Relation to other lanes

| Addon | Overlap |
|-------|---------|
| `advanceddrugprocessing` | **This spec** — coke line lives here |
| `hackerjob` | Separate job/terminal — no shared prefabs |
| `bitcoinmining` | Separate economy entity |

---

## 9. Open questions (sign-off before build)

1. **Job gate:** Drug Dealer only, or new Coke Runner job?
2. **Parallel vs replace:** Coke **alongside** weed or **replace** weed on LifePunch servers?
3. **Drop-off:** Same NPC/zone as weed or dedicated coke buyer?
4. **Stage count:** Match weed 1:1 or fewer coke stages (seed → leaf → brick → bag)?
5. **Portal:** New content rows vs retexture existing weed rows?

---

## 10. Your checklist (owner)

1. **Drop assets** into `C:\lifepunch\reference-intake\coke-drug\` (or tell agent path if elsewhere).
2. **In s&box editor** — spawn weed chain, screenshot prefab hierarchy, send paths (or agent session with bridge).
3. **Answer** §9 open questions.
4. **Greenlight** — then we scaffold `entities/` + ModelDoc lane like weapons mass-production.

Cornerman: distill this spec for Red; no editor.
