# CORNERMAN — LPWEAPONS PLATFORM AUDIT + PREP (parallel to lpbitcoin)

**Owner:** Bloodwave  
**Role:** Green Deep (Qwen3.6-27B) on Cornerman  
**Scope:** lpweapons package + weapon platform across the entire lpaddons project  
**Priority:** Secondary to lpbitcoin Phase 1, but high value parallel prep  
**Eyes covered:** Yes

## Strategic Context

- Weapons are an explicit **parallel track** to bitcoin (see ACTIVE_WORKSTREAM and LIFEPUNCH_WEAPON_IMPLEMENTATION_LAW.md).
- lpbitcoin Phase 1 (Hub → Terminal → Racks) remains the hard production gate.
- Real server fun and donation value will come from a cohesive set of high-quality LifePunch addons (bitcoin + weapons + ulx + future cyber jobs).
- Goal: Make DXRP feel like it depends on LifePunch content.

We are not doing new weapon implementation today. This is deep prep and distillation so that when Red returns, there is clear, structured work ready for Opus or Grok Build 1 slices.

## Must Ground First

Read these in order before producing any reports:

1. `LIFEPUNCH_WEAPON_IMPLEMENTATION_LAW.md` (core law — "weapon platform", not gun model)
2. `WEAPON_INTAKE.md`
3. `VIEWMODEL_RIG_PIPELINE.md`
4. `WEAPON_MASS_PRODUCTION.md`
5. `WEAPON_PROGRAM.md` and `WEAPON_CLASS_SPEC.md`
6. Current lpweapons folder structure in the repo
7. Any existing weapon assets or code under lpweapons/
8. The quarantined AK47 work (search for lane/ak47 references or the branch state)
9. Recent weapon-related briefs in `addons/docs/briefs/`

Use the standardized report template for everything:
`lifepunch/docs/handoff/LIFEPUNCH_AI_REPORT_TEMPLATE.md`

Save reports to both:
- `lifepunch/docs/reports/`
- `C:\LIFEPUNCH\Reports\`

## Deliverables (produce structured reports)

Create separate reports using the template for each major area:

1. **LPWEAPONS_CURRENT_PLATFORM_STATUS.md**  
   Audit how well the current lpweapons code/assets/docs follow the Weapon Implementation Law (P0–P5).  
   Cover: scale/collision/attachments, skeleton, animation state, particles/sounds, DXRP integration.

2. **AK47_LANE_QUARANTINE_REVIEW.md**  
   Status of the AK47 work on the lane/ak47 branch vs main.  
   What exists, what is broken, risks, what can be salvaged, what needs to be restarted cleanly.

3. **WEAPON_INTAKE_PIPELINE_HEALTH.md**  
   Review the intake checklist against reality.  
   Identify gaps, missing tooling, or documentation that would slow future weapon intake.

4. **VIEWMODEL_RIG_PIPELINE_READINESS.md**  
   Current state of first-person rig support.  
   What is reusable from DXRP, what LifePunch still needs to own, any known blockers.

5. **WEAPON_MASS_PRODUCTION_QUEUE_PREP.md**  
   Map the planned 5-class queue (AK47, Deagle, MP9, SSG08, XM1014, etc.).  
   For each: current status, missing pieces, recommended next prep step for Red.

6. **WEAPON_VS_CYBER_ENTITY_PATTERN_ALIGNMENT.md**  
   How should lpweapons share (or deliberately diverge from) patterns coming out of lpbitcoin (three-surface upgrades, Universal Upgrades home, Terminal as real surface, donor rules, etc.)?

7. **WEAPON_UI_AND_CUSTOMIZATION_OPPORTUNITIES.md**  
   Ideas for future weapon menus / attachment selection / upgrade surfaces that could feel consistent with LpHashdPanel + cyber ops style.  
   Keep high-level — no implementation.

8. **WEAPON_DONOR_COSMETICS_AND_VISUAL_LAW.md**  
   Draft rules for donor/cosmetic weapon skins that align with the Bitcoin visual doctrine (HASHD amber family, no full green/red/cyan on Bitcoin surfaces, state colors override, etc.). Extend the doctrine cleanly to weapons.

9. **LPWEAPONS_TO_FULL_LPADONS_CONNECTIONS.md**  
   How weapons could interact with other future LifePunch systems (Black Market selling weapons, Drug Dealer using weapons as leverage, Banker financing weapon purchases, etc.). High-level opportunity mapping only.

## Rules for this work

- lpbitcoin Phase 1 is still the hard priority. Do not let weapon work distract from any lpbitcoin tasks still running.
- Stay strictly in prep/distillation mode.
- Use the new report template for every output.
- Clearly separate FACTS from IDEAS.
- End every report with the confidence scoring table.
- Include a CHATGPT TASKS section in each report.

## Completion

When these (or as many as time allows) are done, include them in your normal end-of-run signal around 11:30 PM.

Example addition to your completion message:
"... + 7 weapon platform reports delivered"

---

Send this as additional work for the long unattended run. Weapons are valuable parallel prep that will make the full lpaddons package much stronger when we start shipping.