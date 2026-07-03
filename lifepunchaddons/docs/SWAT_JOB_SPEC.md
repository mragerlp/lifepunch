# LifePunch SWAT Job — Concept Stub

> **Status:** NOT greenlit. Captured for roadmap alignment with CS2 model pipeline.  
> Owner builds **Cybersecurity Officer** separately.

---

## Intent

SWAT as a DXRP job with tactical gear and weapons sourced via **CS2 study → own meshes** (same mass-production lane as Gun Dealer weapons).

## CS2 reference starting points (study only — never ship CS2 assets)

| Gear | CS2 mesh hint | Notes |
|------|---------------|-------|
| Tactical helmet | `ctm_swat` / heavy CT units | Own rig for DXRP citizen |
| Body armor | SWAT/CT vest variants | Match police job palette |
| Primary | M4/MP5 class already in DXRP | LifePunch skins optional |
| Shield | `weapon_shield` study | Complex — Phase 2+ |

Harvest workflow: `CS2_CHARACTER_HARVEST.md` · queue `config/gear-production.json` · `Intake-Cs2CharacterReference.ps1 -Ident swat`

## Dependencies

- Police job / lifepunchnet terminal ecosystem (`GOVERNMENT_DATABASE_SPEC.md`)
- Portal job registration on DXRP
- Opus sign-off on permissions + loadout economy

## Next step

Owner greenlights → add `swat` row to `addons.json` (gear queue: `gear-production.json` queueOrder 1).
