# Coke line — enhanced pack vs weed engine

**Status:** Cornerman distill (2026-06-11) — portal column still needs Red editor spawn  
**Spec:** `COKE_DRUG_RESKIN_SPEC.md` · Weed index: `reference/WEED_ENGINE_ENTITY_INDEX.md`

## Enhanced coke pack (LifePunch-owned, in repo)

```text
coca_seed  -->  coca_leaf  -->  processing_station  -->  packing_station
                                                      -->  coke-bag / coke-brick (products, ModelDoc TBD)
```

Parallel: `meth_lab` → `MethLabEntity` (meth line — separate spec).

## Weed engine reference (DXRP / portal addon)

```text
weed_pot / lamp  -->  weed_seed_pack / strains  -->  grow stages  -->  drying  -->  packaging  -->  *_bag.dprod  -->  weed_buyer
```

## Mapping table

| Coke (enhanced) | Weed counterpart | Portal content? | Notes |
|-----------------|------------------|-----------------|-------|
| `coca_seed` | `entities/weed/weed_seed_pack.prefab` + `strains/*.wstrain` | TBD — Red spawn | Seed entry — not 1:1 strain system |
| `coca_leaf` | harvest / plant stage (no 1:1 prefab) | TBD | Coke uses leaf entity, not pot stages |
| `processing_station` | `entities/weed/weed_drying_rack.prefab` | TBD | Or `weed_mixing_station.weq` for chem fiction |
| `packing_station` | `entities/weed/weed_packaging_station.prefab` | TBD | Clone packaging wiring pattern |
| `coke-bag` (`DrugBaggieLP.fbx`) | `entities/weed/products/*_bag.dprod` | TBD | `material-map.json` stub on repo |
| `coke-brick` (`Coke Brick.fbx`) | n/a — bulk product | TBD | No direct weed twin |
| `meth_lab` | n/a (meth line) | TBD | `METH_CREATION_SPEC.md` |

## Material-map stubs (repo)

| Slug | Active FBX | Status |
|------|------------|--------|
| `coke-bag` | `intake-raw/source/DrugBaggieLP.fbx` | ModelDoc TODO VENGEANCE |
| `coke-brick` | `intake-raw/source/Coke Brick.fbx` | Extracted from zip on Red |

## Open questions (owner sign-off — spec §9)

1. **Alongside weed or replace** on LifePunch servers?
2. **Job gate:** Drug Dealer only?
3. **Drop-off:** same `weed_buyer` NPC or coke-specific?
4. **Meth_lab** — Phase 1 code shipped; economy Phase 2 Opus.

## Publish gates

- **VENGEANCE** push + portal publish only  
- **Opus review** before economy goes live  
- **Cornerman:** intake manifests + docs only
