# LIFEPUNCH Architect — current project state (volatile)

> **Regenerate** when phase, gates, or owner decisions change.  
> **Package upload name:** `ARCHITECT_CURRENT_STATE.md` (same content; repo path below).  
> **Continuity kit baseline commit:** `782ef35` (see `handoff/ARCHITECT_CONTINUITY_KIT_LAW.md`)  
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
- Hub = operation policy + ledger · `LpHashdPanel` = hub admin shell (preserve) · HASHD Terminal = interface only, never mines
- Rack cap: **2 Standard + 1 Advanced** (DECISION-0004)
- Fantasy Check **mandatory** after flatgrass proof (DECISION-0008)
- Canonical slugs: `bitcoinhub`, `hashdterminal`, `gpurack` (advanced variant); retired `advancedgpurack` folder slug

---

## Unresolved Architect questions (do not implement silently)

1. **Final five Hub upgrade categories** and **final five Rack upgrade categories**
2. **Five tier labels** for each side
3. **Clock Path gameplay meaning** — working abstraction only until approved
4. **Core Count gameplay meaning** — working abstraction only until approved
5. **Buffer** as a Rack category vs another system
6. **Buffer formula** — USD/BTC floor source, dynamic vs snapshot conversion
7. **Cost curves**
8. **Is the full five-by-five upgrade tree required for v1.0, or part/all v1.1?** — **Bloodwave must confirm**
9. **Intentional realism boundary** note — pending owner-approved wording
10. **Rack USE → shared CRT** — if retained in code, label as quick-access delegation vs second Terminal owner

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
