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
| `hacker-terminal` | **1.0** | Correct at baseline — do not shrink |
| `advanced-hacker-terminal` | **1.0** | Same mesh baseline |
| `gpu-rack` | **0.465** | Crypto Farm mining rig · pitch 90° stand-up · ~25×20×36 @ prefab 1,1,1 |
| `bitcoin-miner` (Ophion hub) | **0.385** | Translation **Z 13.3** · rotation **0** · align **None** @ prefab **1,1,1** · re-verify flatgrass bounds vs collider **10×8×15** |

**Do not** auto-shrink props that already look right @ `import_scale` 1.0 — collider numbers may be stale.

## Reference (working pattern elsewhere in repo)

`advanceddrugprocessing` props use **`import_scale = 0.3937`** at prefab `1.0` — not `39.37`. Treat `39.37` and `0.3937` as different orders of magnitude; never assume without measuring.

## Playtest map

Use **`facepunch.flatgrass`** (`game.scene` `MapName` or `lp_map_flatgrass`) so scale is visible without downtown clutter.
