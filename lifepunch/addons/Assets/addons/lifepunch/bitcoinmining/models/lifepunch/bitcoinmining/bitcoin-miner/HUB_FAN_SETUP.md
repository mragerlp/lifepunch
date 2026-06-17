# Steam Machine hub — fan setup (ModelDoc)

Same **Evo Bitminer pattern** as GPU racks: static body + child fan mesh.

## Open in ModelDoc (DXRP project scope)

1. `bitcoin-miner/bitcoin-miner.vmdl` — chassis (no fan mesh, no animation nodes)
2. `bitcoin-miner/bitcoin-miner-fan.vmdl` — fan mesh only
3. `entities/bitcoinminer/bitcoin-miner.prefab` — `fan_spin_hub` child

Compile all three after any edit.

## What you should see in ModelDoc

**bitcoin-miner.vmdl**
- Render mesh: `steam-machine.fbx`
- Import filter: includes `base_body`, `front_panel`, `back_body` — **not** `fan`
- No AnimationList, no BoneMarkup

**bitcoin-miner-fan.vmdl**
- Same FBX + import scale (`0.152`)
- Import filter: **`fan` only**

## Prefab tune (if fan floats or sits off-center)

1. Open `bitcoin-miner.prefab`
2. Select **`fan_spin_hub`**
3. Move until blade sits in the front fan cage
4. Play → `lp_bitcoin_spawn_hub` → toggle power or `lp_bitcoin_playtest_mining`
5. `lp_bitcoin_fan_tune` logs local pos/rot

## Test commands

```
lp_bitcoin_spawn_hub
lp_bitcoin_playtest_mining
lp_bitcoin_fan_tune
```

Only the fan spins when powered. Panel and case stay locked.
