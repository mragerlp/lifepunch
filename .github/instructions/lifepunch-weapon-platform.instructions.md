---
applyTo: "**"
description: "LIFEPUNCH weapon platform law — not gun models; attachments, bones, anims, states"
sourceRule: ".cursor/rules/lifepunch-weapon-platform.mdc"
---

> **Synced from** `.cursor/rules/lifepunch-weapon-platform.mdc` â€” edit source there, then re-run `Sync-CursorRulesToCopilotInstructions.ps1`.

# LifePunch — Weapon Platform Law

**Canonical:** `lifepunch/addons/docs/LIFEPUNCH_WEAPON_IMPLEMENTATION_LAW.md`

## Core law

> Never think "gun model". Think **weapon platform**. Mesh ~10%. Build: Mesh → Skeleton →
> Attachments → Animation → Particles → Sound → Gameplay → Upgrades.

**Entities** use `LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md` — do not apply machine P0–P4 to weapons verbatim.

## Agent mandatory reads (weapon work)

1. `LIFEPUNCH_WEAPON_IMPLEMENTATION_LAW.md`
2. `WEAPON_INTAKE.md` · `VIEWMODEL_RIG_PIPELINE.md`
3. `WEAPON_MASS_PRODUCTION.md` / `WEAPON_PROGRAM.md` (when shipping Gun Dealer class)
4. `PACKAGE_STAGING_LAYOUT.md` — `lpweapons/{slot}/assets|code`
5. `docs/lanes/AK47_LANE.md` — if on `lane/ak47` only

## P0 gates (before gameplay tuning)

- Scale vs citizen (length, grip, muzzle, mag)
- **Multiple convex hulls** — not one box forever (`TECH_DEBT.md` WEAPON-01)
- Full **attachment node** list (muzzle, shell_eject, camera_ads, …)

## P1+

- Independent bones (bolt, mag, trigger, charging handle)
- Required anim set (fire, reload, ADS, jam, …)
- Effects/audio from attachment origins — not mesh center

## Workstream

- **Bitcoin lane** is active production gate — weapons are **parallel** (`lpweapons`, quarantined AK).
- AK FP experiments: **`lane/ak47` branch only** — Block E in `AGENT_PROMPT.md`.

## Required deliverable

Every weapon: platform report (tris, attachments, anims, collision, bones, origins) per law doc.
