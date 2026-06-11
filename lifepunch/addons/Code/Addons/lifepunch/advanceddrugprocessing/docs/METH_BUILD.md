# Meth Lab — build & playtest

**Spec:** `addons/docs/METH_CREATION_SPEC.md`  
**Sync:** `Sync-LifePunchAddonsToDxrp.ps1 -Addon advanceddrugprocessing`

---

## Editor wiring (VENGEANCE)

1. Open `entities/meth_lab/meth_lab.prefab`.
2. Confirm model path: `addons/lifepunch/advanceddrugprocessing/models/lifepunch/advanceddrugprocessing/meth_lab/meth_lab.vmdl`
3. Add **`MethLabEntity`** component on root (keep `BaseEntity` + collider).
4. Optional: child `TextRenderer` for status LCD → bind `StatusDisplay`.
5. Save scene.

---

## Dev console

```text
lp_spawn_methlab
lp_meth_fill
lp_meth_status
```

1. **Use** lab → batch starts (PrepMix → Heat).
2. On **Vent** stage, **Use** within ~8s or batch fails.
3. Wait **Crystalize** → **Ready** → **Use** to harvest.

---

## Phase 2 (not in scaffold)

- Pocket chemicals + meth bag product
- Drug Dealer market items
- Propane refuel
- Sell at drug drop-off
- Separate stove/jar entities (full GMod kit)
