---
applyTo: "**"
description: "LIFEPUNCH digital machine doctrine — ModelDoc-first, not props; collision, attachments, states"
sourceRule: ".cursor/rules/lifepunch-digital-machine.mdc"
---

> **Synced from** `.cursor/rules/lifepunch-digital-machine.mdc` â€” edit source there, then re-run `Sync-CursorRulesToCopilotInstructions.ps1`.

# LifePunch — Digital Machine Standard

**Canonical:** `lifepunch/addons/docs/LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md`

## Core law

> Never think "prop". Think **machine**. Mesh is one layer. Build: Model → Collision → Physics →
> Attachments → Lights → Animation → Sound → State → Gameplay component.

## Agent mandatory reads (entity / ModelDoc work)

1. `LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md` (this doctrine)
2. `MODEL_FOUNDATION_PASS.md` — P0 before prefab
3. `MODELDOC_STUDIO_LANE.md` — standalone editor (no DXRP gamemode)
4. `PACKAGE_STAGING_LAYOUT.md` — `lp{package}/{entity}/assets|code`
5. `CYBER_REFERENCE_LAWS.md` — Law 2 (roles), Law 6 (states)
6. `ACTIVE_WORKSTREAM.md` — single lane gate

## ModelDoc first

- Work in **ModelDoc Studio** or `lp*` staging — not DXRP `game.scene` for mesh passes.
- Study `citizen.vmdl` + Facepunch weapon vmdls for ModelDoc patterns.
- **No rigged fan bodies** as main mesh — child GO or separate anim takes (Phase 2+).

## Collision

- **Endgame:** multiple convex hulls in ModelDoc (chassis, fans, feet, …).
- **Baseline:** Phase 1 `BoxCollider` all axes is allowed if labeled in `TECH_DEBT.md` — not the finish line.

## States

Machines must support OFF → BOOTING → RUNNING (+ OVERCLOCK / BROKEN / HACKED where designed).
Lights and sound follow state — not texture-only fakery.

## Staging paths

- Intake: `Assets/addons/lifepunch/lpbitcoin/bitcoinhub/…` (not `_modeldoc/game/`).
- Owner drop: `%USERPROFILE%\OneDrive\Desktop\UPLOAD READY ADDONS\`.
- Populate: `Initialize-UploadReadyAddons.ps1` · `Place-LifepunchModelDocAssets.ps1`.

## Convex plugin (Cursor)

**Convex** MCP is installed for reactive TypeScript backends. LifePunch **s&box entities do not use Convex**
today. Use Convex only when owner explicitly builds realtime backend features (website portal, live ops).
Do not substitute Convex for ModelDoc or DXRP gameplay.

## Weapons (sibling law)

Cyber **entities** = digital machines. **Weapons** = weapon platforms —
`LIFEPUNCH_WEAPON_IMPLEMENTATION_LAW.md` + **lifepunch-weapon-platform** rule. Do not apply entity
P0–P4 checklist to Gun Dealer kits.
