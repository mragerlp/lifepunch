# LIFEPUNCH Architect — current project state (volatile)

> **Regenerate** when phase, gates, or owner decisions change.  
> **Package upload name:** `ARCHITECT_CURRENT_STATE.md` (same content; repo path below).  
> **Continuity kit baseline commit:** `782ef35` (see `handoff/ARCHITECT_CONTINUITY_KIT_LAW.md`)
**Latest reconciliation commit (three-surface upgrade canon):** `6eb2c74` (GO DOCS pass: DECISION-0010 + DECISION-0006 amendment + pattern alignment)  
> **Source commit:** update on each regen · **Generated:** 2026-06-25  
> **Evergreen law** lives in repo docs — this file is **dated state only**.  
> **GitHub wins** over uploaded Project ZIP snapshots.

---

## Active lane

| Field | Value |
|-------|-------|
| **Package** | `lifepunchbitcoin` / repo ident `bitcoinmining` / s&box `lifepunch.bitcoin` |
| **Staging** | `lpbitcoin/{bitcoinhub,hashdterminal,gpurack}` |
| **Current phase** | **Phase A — Hub polish** |
| **Next legal phase** | Phase B HASHD Terminal — **only after H10 owner sign-off** |
| **After B** | Phase C GPU Racks (2 Standard + 1 Advanced) |

**Executable slice:** next unchecked **H*** in `addons/docs/OWNER_PROGRESS_TRACKER.txt`.

---

## Implementation gates

| Gate | Status |
|------|--------|
| Phase A Hub mesh + proof (H1–H10) | **In progress** — H4/H5 before H10 |
| Hub/Rack upgrade ownership migration (RFC-0005) | **HOLD** — no code until Bloodwave GO |
| Economy overhaul (five-by-five taxonomy, buffer semantics) | **HOLD** — Architect questions open |
| Already-authorized Phase A work | **Allowed** under `ACTIVE_WORKSTREAM.md` |

**HOLD does not freeze** authorized Phase A hub polish governed by the tracker.

---

## Owner decisions (settled)

- No LIFEPUNCH NPC systems (G9, DECISION-0003)
- Hub = operation policy + ledger · `LpHashdPanel` = hub admin shell (preserve) + Universal Upgrades home (HUB · TERMINAL · GPU RACK sub-tabs) per DECISION-0010
- HASHD Terminal owns presentation, command-session state, and its endpoint defense/capability profile (one authoritative logical record). Terminal never mines (DECISION-0005). Hub may persist the profile as infrastructure but must not create two independently mutable copies.
- Three-surface upgrade law (Hub controller / Terminal defense / Rack hardware) is now canon for Bitcoin reference implementation.
- Rack cap: **2 Standard + 1 Advanced** (DECISION-0004)
- Fantasy Check **mandatory** after flatgrass proof (DECISION-0008)
- Canonical slugs: `bitcoinhub`, `hashdterminal`, `gpurack` (advanced variant); retired `advancedgpurack` folder slug
- Model routing: Opus (Tier-1), Grok Build 1 (Tier-2A inside Integration Architect lane), Composer (Tier-2B), Cornerman (Tier-3 **local worker lane** — Green Code / Deep / Daily / Fast profiles; cheap + untrusted, not final ship authority). See `MODEL_ROUTING_AMENDMENT_GROK_BUILD_1.md` + `CORNERMAN_MODEL_ROUTING.md`.
- Visual identity: HASHD amber locked for Bitcoin; green/red/cyan reserved. See `CYBER_VISUAL_IDENTITY_DOCTRINE.md`.

---

## Unresolved Architect questions (do not implement silently)

Category identities and tier names are locked in DECISION-0010 (v1.0 foundation). The following remain open:

- Exact numerical effects per tier
- Cost curves and purchase currency
- Balance multipliers and BTC/USD buffer recalculation formulas
- Save migration mechanics for legacy CPU/Core and per-rack upgrades
- Future Hacker formulas and advanced intrusion simulation depth
- Long-term economic balancing

Clock Path / Core Count gameplay meaning, Buffer category details, cost curves, and intentional realism boundary wording remain pending owner-approved detail.

Rack USE → shared CRT delegation vs second Terminal owner still needs a call.

The five-by-five-by-five structure itself is v1.0 (three domains, fifteen canonical tracks, five-tier schema). Implementation is staged.

---

## Known implementation gaps (volatile — not hard law)

| Gap | Status | Notes |
|-----|--------|-------|
| Market acquire / place | Portal Rev 1 content row live; **not gamemode-pinned**; no code/assets upload yet | Ship needs `_c` + `prepare-publish.ps1` + gamemode pin |
| Gov/LE blocked from hashd | **Doc only** | `TERMINAL_BRAND_MATRIX.md`; not enforced in hub code yet |
| Full Law 6 world states | **Partial** | Boot splash = UI; emissive/audio = H4/R4 checklist |
| PIN graphical gate | **H9 open** | `AccessPinIsSet` in code; full numpad flow TBD |
| Dedicated server `_c` | **Required for ship** | Compile + pull compiled assets |
| Dev ConCmds | **Playtest only** | Strip before publish |
| Per-rack BTC balance | **v2 code** | `LpBitcoinRackEntity.BitcoinAmount` — docs must match code |

---

## Proof status

| Slice | Status |
|-------|--------|
| Hub admin UI (`LpHashdPanel`) unlinked | Owner signed off (2026-06-24) |
| Hub world mesh / flatgrass Phase A | **Not complete** — H10 open |
| Terminal Phase B | **Locked until H10** |
| Law 10 exit | **Blocked** |

---

## Supersedes

- Stale `AGENT_SYNC_BROADCAST.txt` session overrides (e.g. 2026-06-22 ULX-only lane)
- ChatGPT package copies older than source commit — **GitHub monorepo wins**
- VENGEANCE reference ZIP checksums when Design Architect has rebuilt/normalized the kit (see `ARCHITECT_CONTINUITY_KIT_LAW.md`)

---

## Continuity kit refresh

**Law:** `handoff/ARCHITECT_CONTINUITY_KIT_LAW.md`

- Red sends **commit hash + changed files** after canonical doc commits.
- Delta refresh for small edits; **full kit rebuild** for laws, onboarding, this file, decisions, or `ACTIVE_WORKSTREAM.md`.
- Green syncs GitHub only; Design Architect reconciles packages.

---

*Integration Architect maintains on VENGEANCE after approved doc commits.*

---

## Model Routing Update (2026-06-25)

**MODEL_ROUTING_AMENDMENT_GROK_BUILD_1.md** committed.

- Grok Build 1 added as **Tier-2A** for the Integration Architect (technical planning, ModelDoc/asset work, bounded slices).
- Opus remains Tier-1 for hard architecture/economy/permissions/multi-file.
- Grok Output Law, Escalation Law, and Proof Law now apply to all Grok work.
- See the amendment file for the full routing table and requirements.

**Next continuity kit** must include this amendment + `CYBER_VISUAL_IDENTITY_DOCTRINE.md` so fresh ChatGPT/Architect sessions start with correct model law and visual identity rules.

Commit for this update: will be recorded on push (see git log for `MODEL_ROUTING_AMENDMENT_GROK_BUILD_1.md` and related doc updates).

**Terminal canon reconciliation** in progress — old "Terminal upgrades: None" language being replaced with reference to the new doctrine and upcoming DECISION-0010.

### Cornerman Qwen profiles / Tier-3 worker lane (2026-06-27)

- **Tier-3 reframed** from "weak helper / distill-only" to **local, cheap, untrusted worker lane** —
  real work + code candidates, but checked by VENGEANCE compile/proof + Bloodwave approval.
- **Four Green profiles** defined: **Green Code** (Qwen Coder — contained C#/Razor/SCSS candidate
  patches), **Green Deep** (distiller + architecture warmer), **Green Daily** (reports/audits/handoffs),
  **Green Fast** (triage). Exact LM Studio keys verified on Cornerman via `lms ls --llm --detailed`.
- Role law: Qwen Coder = local code worker · Green Deep warms · Grok scouts · Opus owns risky recipe ·
  Bloodwave approves the meal. `OPUS REQUIRED` / `GROK REQUIRED` / `GREEN CODE/DEEP REQUIRED` routes may
  not be silently substituted by Auto for economy/persistence/`[Sync]`/RPC/migration/state-machine work.
- Docs touched: `config/cornerman-tier3-models.json`, `CORNERMAN_MODEL_ROUTING.md`, `MCP_AGENT_ROUTING.md`,
  `OPUS_USAGE_LAW.md`, `MODEL_ROUTING_AMENDMENT_GROK_BUILD_1.md`, this file. Docs-only; model keys left
  profile-named (verify on box).

### Route tags canonized — Cursor Auto is not a routing guarantee (2026-06-27)

- **Canonical tag home:** `OPUS_USAGE_LAW.md` § Task route tags; mirrored in `MCP_AGENT_ROUTING.md`
  and the **always-applied** `.cursor/rules/lifepunch-opus-usage.mdc` (so every agent auto-picks it up).
- Tags: `AUTO OK` (routine), `OPUS REQUIRED` (Tier-1, manual select), `GROK REQUIRED` (Tier-2A, manual),
  `GREEN CODE REQUIRED` / `GREEN DEEP REQUIRED` (Cornerman/LM Studio lane — Auto cannot replace it).
- Auto is fine for routine but **never a routing proof**; it must not silently substitute models for
  economy · persistence · `[Sync(FromHost)]` · RPCs · purchase routing · migration · power/link state
  machines · final major-slice / commit-critical review.
- **Architect duty:** mark every paste with one of those tags so VENGEANCE routes (or stops) correctly.
