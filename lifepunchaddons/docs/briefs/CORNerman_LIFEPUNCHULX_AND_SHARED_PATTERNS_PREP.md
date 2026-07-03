# CORNERMAN — LIFEPUNCHULX + SHARED PATTERNS ACROSS LPADDONS PREP

**Owner:** Bloodwave  
**Role:** Green Deep  
**Scope:** lifepunchulx (admin menu) + cross-addon UI / pattern consistency for the whole lpaddons project  
**Priority:** Parallel prep (lower than lpbitcoin Phase 1, but high leverage)

## Context

- lifepunchulx is well-received and targeted for portal soon.
- We are building many surfaces (Bitcoin Hub/Terminal, future Banker, Black Market, Drug Dealer extensions, weapons, etc.).
- Goal: Make everything feel like it belongs to the same professional LIFEPUNCH ops family instead of a collection of unrelated addons.

This task is about distilling patterns, finding reuse opportunities, and surfacing inconsistencies so Red can make deliberate architecture decisions later.

## Must Ground

- Current lifepunchulx code and UI (especially menu structure, tabs, cards, scroll, chrome).
- LpHashdPanel and LpBitcoinTerminalPanel patterns.
- New Universal Upgrades home work (from previous prep).
- Weapon platform UI needs (attachment selection, loadouts, etc.).
- Any existing shared UI components (LifePunchUiShell, scroll regions, etc.).
- Cyber Reference Laws and visual identity doctrine.

Use the standard report template for all output.

## Deliverables

Produce structured reports:

1. **LIFEPUNCHULX_CURRENT_STATE_AUDIT.md**  
   High-level map of what the admin menu currently does well and where it feels dated or inconsistent with newer Bitcoin surfaces.

2. **SHARED_UI_PATTERN_CATALOG.md**  
   Extract reusable patterns from ulx + bitcoin that should become the "LifePunch ops UI language" for future addons (tabs, chips, cards, status, headers, etc.).

3. **WEAPON_UI_INTEGRATION_OPPORTUNITIES.md**  
   What kind of menus/flows will weapons likely need (attachment selection, skin/cosmetic picker, upgrade paths)? How can we avoid creating yet another completely different UI style?

4. **CROSS_ADDON_CONSISTENCY_RISKS.md**  
   List places where current or planned addons are at risk of feeling disconnected (different tab styles, different status indicators, different "ops console" language, etc.).

5. **RECOMMENDED_UI_PRIMITIVES_FOR_LPADONS.md**  
   Propose a small set of shared building blocks (or naming conventions) that future LifePunch surfaces should try to reuse.

6. **DONOR_AND_COSMETIC_UI_RULES_ACROSS_ADDONS.md**  
   Extend the visual doctrine so donor cosmetics are handled consistently whether it's on a Bitcoin machine, a weapon skin, or a future cyber job surface.

## Rules

- lpbitcoin Phase 1 is still the hard priority. Do not let this pull focus from any remaining bitcoin work.
- Stay in distillation mode.
- Use the new report template.
- Save to the standard reports locations.
- Clearly separate Facts from Ideas.

Continue until ~11:30 PM or until you have good coverage.