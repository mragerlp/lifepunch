# Steam Machine hub — fan setup (ModelDoc)

**Phase 1 (now):** Static box only — see `MODEL_BUILD.md`. Prefab has **no fan child** until owner signs static hub.

## Phase 2 — fan child (deferred)

When ready:

1. Add child GO `fan_spin_hub` on `bitcoinhub.prefab` with `ModelRenderer` → `bitcoinhub-fan.vmdl`
2. Enable `LpBitcoinHubVisuals` fan spin (already on prefab root)
3. Tune position with `lp_bitcoin_fan_tune`

## ModelDoc files (Phase 2)

1. `bitcoinhub.vmdl` — chassis (no fan mesh)
2. `bitcoinhub-fan.vmdl` — fan mesh only

Compile both after any edit.
