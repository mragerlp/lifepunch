# DXRP weed engine — entity index (download cache)

**Source:** `D:\Steam\steamapps\common\sbox\download\assets\entities\weed\` (cached from portal)  
**Use:** Cornerman + Red map coke enhanced line → weed counterparts in `COKE_LINE_MAP.md`  
**Verified:** 2026-06-11 on VENGEANCE

## Grow chain (typical)

| Entity | Prefab / path | Notes |
|--------|---------------|-------|
| Pot | `entities/weed/weed_pot.prefab` | Plant container |
| Lamp | `entities/weed/weed_lamp.prefab`, `weed_led_lamp.prefab` | Grow light |
| Seed pack | `entities/weed/weed_seed_pack.prefab` | Strain entry |
| Strains | `entities/weed/strains/*.wstrain` | Per-strain seed + bag product |
| Drying rack | `entities/weed/weed_drying_rack.prefab` | Post-harvest |
| Packaging station | `entities/weed/weed_packaging_station.prefab` | Bag product |
| Breeding station | `entities/weed/weed_breeding_station.prefab` | Strain breeding |
| Mixing station | `equipment/weed_mixing_station.weq` | Equipment row |
| Product bags | `entities/weed/products/*_bag.dprod` | Sellable bags |
| Generic weed bag | `entities/drugs/products/weed_bag.dprod` | Shared bag prefab |
| Buyer | `entities/weed/weed_buyer.prefab` | Drop-off NPC |
| Job | `jobs/weed_grower.jobdef` | Weed grower job gate |

## Coke enhanced pack (LifePunch repo) — mapping hints

| Coke (advanceddrugprocessing) | Likely weed counterpart |
|-------------------------------|-------------------------|
| `coca_seed` | `weed_seed_pack` / strain seed |
| `coca_leaf` | harvest stage / raw bud |
| `processing_station` | `weed_drying_rack` or `weed_mixing_station` |
| `packing_station` | `weed_packaging_station` |
| `coke-bag` (TBD vmdl) | `*_bag.dprod` / `weed_baggie.vmdl` |
| `coke-brick` (TBD vmdl) | bulk product (no direct weed twin?) |
| `meth_lab` | separate line — defer |

Red fills **Portal content?** column after editor spawn test.
