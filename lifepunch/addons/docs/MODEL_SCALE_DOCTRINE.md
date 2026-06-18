# LifePunch — model scale doctrine

**Law:** shipped props use **prefab root `Scale = 1,1,1`**. No prefab fudge (no `0.65`, `0.41`, `0.5` on the root).

**`import_scale` in the vmdl** is the only scale knob. It must produce the **intended original size** in-world — not bigger, not smaller.

## Do not

- Default to **`import_scale = 39.37`** (meters→inches) on LifePunch FBX/OBJ without a bridge measurement. It routinely yields building-sized props.
- Stack prefab scale × huge `import_scale` and call it tuned.
- Claim scale from repo numbers without Claude Bridge bounds (eyes-covered law).

## Do

1. **Prefab root** `1,1,1`.
2. **Start `import_scale = 1.0`** on new models.
3. **Intended size** = `BoxCollider.Scale` on the prefab (gameplay-authoritative hammer units).
4. **Tune once from baseline:** at `import_scale = 1.0`, spawn on `facepunch.flatgrass`, read bounds via bridge, then  
   `import_scale = collider_max / measured_max` (single multiplier — not `39.37`, not stacked prefab fudge). Recompile, re-verify bounds match collider.
5. Record final `import_scale` + verified bounds in the addon playtest doc.

### Verified (Jun 2026, prefab `1,1,1`)

| Model | `import_scale` | Notes |
|-------|----------------|-------|
| `hacker-terminal` | **0.0272** | CRT mesh · **`import_rotation = [-90,0,0]`** · prefab **1,1,1** · HP **100** |
| `advanced-hacker-terminal` | **0.0272** | Same mesh family · HP **100** |
| `gpu-rack` | **0.395** | Y=90° · translation `[-1.389,-0.208,21.382]` · @ prefab 1,1,1 |
| `gpu-rack-stacked` (large) | **0.72** | Same axis treatment as single rack · translation Z **27.682** · ~1.8× single scale (was 0.85 — oversized) |
| `bitcoin-miner` (Steam Machine hub) | **0.152** | Parented FBX export · translation `0` · align Z Bottom @ prefab **1,1,1** · mesh ~32×30×29 vs collider 32×20×28 (Jun 2026) |
| `bitcoin-terminal` (CRT prop) | **0.0272** | **`import_rotation = [-90,0,0]`** · prefab **1,1,1** · mesh ~20u tall · collider **`0,0,9` / `10×4×9`** · **HP 100** |
| `server-rack` (Fab DataCenter) | **0.399** | Fab FBX cm @ import 1.0 → mesh Z ~218u · collider **28×28×87** · height-aligned Jun 2026 |
| `advanced-server-rack` (Fab row) | **0.399** | Same cabinet height as basic · mesh ~164×94×87 @ prefab **1,1,1** · collider updated to match |
| `government-server-rack` | **0.399** | Same Fab mesh family as criminal rack · collider **28×28×87** |
| `police-terminal` (OBJ meters) | **39.37** | Bridge verified ~80×40×55 @ prefab **1,1,1** · collider **50×70×40** |
| `black-market-hub` (Fab vault) | **0.74** | Fab safe FBX · planned collider **36×24×26** · tune when prefab ships |

**Do not** auto-shrink props that already look right @ `import_scale` 1.0 — collider numbers may be stale.

## Reference (working pattern elsewhere in repo)

`advanceddrugprocessing` props use **`import_scale = 0.3937`** at prefab `1.0` — not `39.37`. Treat `39.37` and `0.3937` as different orders of magnitude; never assume without measuring.

## Playtest scene (canonical)

Use **`scenes/blank.scene`** — open in the DXRP editor, then **Host Play**.

- DXRP ships it: `Assets/scenes/blank.scene` (core prefab + `models/dev/plane` ground + skybox).
- No hammer map load — faster and cleaner than `facepunch.flatgrass` for scale/prop work.
- Console: `lp_dev_scene` prints the path if you forget.

**Legacy:** from `game.scene` only, `lp_map_flatgrass` swaps to `facepunch.flatgrass` when you need hammer terrain.
