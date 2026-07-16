# DRUG PROCESSING HUB DOCTRINE — SEED v1

**Design canon (SEED), 2026-07-15, Bloodwave** (chat-carried; source `fable\0092`, `dispatch\red\0003`
item 6). Extends/reshapes the chemist lane (`codex\0056`) into the full three-lane vision. **Supersedes
nothing ratified** — `codex\0056`'s cocaine-first build order still holds; this is the **destination**
the slices build toward. Grounding: `COCAINE_PROCESSING_DOCTRINE.md` (U1/U2 ratified; U3–U5 not ruled).

> **CLASS: DESIGN CANON — SEED v1.** Build is post-current-ladder. Amend with a changelog entry.

---

## IDENTITY

The **ENHANCED DRUG PROCESSING HUB** — a hub **layered over the existing DRUG DEALER job** (confirms
`codex\0056` Q1: not a new job). Brand: **"Chemist Ops"** mark family (ruled art direction):
- **Flask mark** (slate-blue) = COCAINE lane section art / general Chemist Ops mark.
- **Molecular lattice** (chalk-sketch) = METH lane opening-section art.
- **HASHD pixel-block grammar** = the DRUG PROCESSOR terminal skin reference (one shared terminal
  framework, drug-processor consumer — `TERMINAL_DESIGN_DOCTRINE_2026-07-15`).

## MENU ARCHITECTURE (mirrors Bitcoin Hub laws)

**MAIN HUB PAGE:**
- **Three section DOORS: WEED | COCAINE | METH** (perspective art panels per lane).
- Base surfaces live on the main page like Bitcoin Ops: upgrades summary, info, **STATS**.
  **Stats stay on the main hub page (Bitcoin Hub law) — lane pages do NOT own stats.**

**LANE PAGE (behind each door):**
- Three sub-doors: **RECIPES → UPGRADES → QUESTS.**
- The lane page is that lane's physical production view.

## PHYSICAL ARCHITECTURE

- **LAB TABLE = the HUB** (the world machine; Holdable-Hub Law family).
- **DRUG PROCESSOR = the TERMINAL / controller** (linked device; same hub↔terminal relationship as
  Bitcoin Ops).

## PRODUCTION CHAINS

- **WEED (DXRP NATIVE — UNCHANGED, hard rule):** Grow → Harvest → Drying Rack → CRAFTING TABLE
  (leaf-plucking minigame) → weed brick. **No LP modification to the native chain.**
- **COCAINE:** Grow → Harvest → Drying Rack → **OVEN** → brick. (Same front process as weed; diverges
  after the drying rack.)
- **METH:** Ingredients → **DRUG PROCESSOR** → **OVEN** → brick.

## THE SHARED OVEN (load-bearing design point)

**Cocaine and meth CONVERGE on one shared OVEN entity** as the final production step. Running both
lanes: a **single oven placement produces the brick output for BOTH lanes.** **Weed never touches the
oven** (native chain preserved).

> **OPEN DESIGN QUESTIONS — flagged, need ruling or spec before build:**
> - **Oven batch semantics:** one placement = one combined batch producing N cocaine + M meth bricks
>   from each lane's inputs? Or does "mixed" mean a combined product? *(Fable reads it as: shared
>   entity, batch produces each lane's bricks from that lane's inputs — CONFIRM.)*
> - **Queue / concurrency:** capacity, timer per batch, first-come ordering.
> - **Oven tier / upgrades:** does the oven have its own upgrade track, or do lane upgrades (U1/U2
>   class) apply at the oven stage?

## RECONCILIATION WITH `codex\0056`

- `0056` v1 = **cocaine-only smallest slice: STILL THE BUILD ORDER.**
- `0056` §5 IA (Overview/Labs/Routes/Upgrades/Settings) is **superseded at the hub level** by the
  three-door architecture; lane-page content (Recipes/Upgrades/Quests) reshapes `0056`'s pane list.
  **`0056`'s economy, config, and gate structure (G0–G7) carry unchanged.**
- **METH lane grounding exists:** `METH_PROCESSING_DOCTRINE_FABLE_DRAFT` + `green\0007` — feeds the
  meth lane spec.
- **QUESTS is a NEW surface class** (not in `0056`) — needs its own design pass (quest definitions +
  rewards touch economy = ledger discipline).

## STATUS

**SEED.** Graduated to `docs/` at this canon-carrying PR. The **Chemist epic + sub-issues** will be
drafted against **this architecture** once Bloodwave closes the `codex\0056` ruling slate (Lane Lead
Doctrine applies).

FROM: Red
