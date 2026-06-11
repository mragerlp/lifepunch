# Coke line — enhanced pack vs weed engine

**Status:** Discovery — fill TBD columns after DXRP editor spawn session (VENGEANCE).

## Enhanced coke pack (LifePunch-owned, in repo)

```text
coca_seed  -->  coca_leaf  -->  processing_station  -->  packing_station
                                                      -->  coke-bag / coke-brick (products, ModelDoc TBD)
```

## Weed engine reference (DXRP / portal addon)

Typical weed chain (from download cache + spawn menu):

```text
weed_pot / lamp  -->  strain seed  -->  grow stages  -->  drying  -->  bag product  -->  buyer / drop-off
```

## Mapping table (complete on editor pass)

| Coke (enhanced) | Weed counterpart (guess) | Portal content? | Notes |
|-----------------|--------------------------|-----------------|-------|
| `coca_seed` | `entities/weed/weed_seed_pack.prefab` + strains | TBD | Prefab exists |
| `coca_leaf` | harvest / plant stage (no 1:1 prefab) | TBD | Prefab exists |
| `processing_station` | `entities/weed/weed_drying_rack.prefab` or mixing | TBD | New station type |
| `packing_station` | `entities/weed/weed_packaging_station.prefab` | TBD | Clone weed packaging wiring |
| `coke-bag` (vmdl TBD) | `entities/weed/products/*_bag.dprod` | TBD | Raw FBX in intake |
| `coke-brick` (vmdl TBD) | n/a or bulk product | TBD | Raw zip in intake |

Weed index: `addons/docs/reference/WEED_ENGINE_ENTITY_INDEX.md` — Cornerman refines after unzip work.

## Open questions (owner sign-off — see spec section 9)

1. **Alongside weed or replace** on LifePunch servers?
2. **Job gate:** Drug Dealer only?
3. **Drop-off:** same buyer NPC as weed?
4. **Meth_lab** in pack — ship now or defer?

## Publish gates

- **VENGEANCE** push + portal publish only  
- **Opus review** before economy goes live (drug income)  
- **Cornerman:** intake unzip + docs only — no editor, no push
