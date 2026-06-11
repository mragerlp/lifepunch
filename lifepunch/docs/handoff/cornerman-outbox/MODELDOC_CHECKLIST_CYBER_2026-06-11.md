# ModelDoc checklist — cyber addons (owner return)

Do in **DXRP editor** after `Sync-LifePunchAddonsToDxrp.ps1 -Addon <ident>`.  
**Done =** vmdl compiles, `_c` appears next to vmdl, prefab shows mesh in spawn menu / dev cmd.

---

## hackerjob (all blocked on `_c` today)

### 1. `server-rack.vmdl` — **do first** (powers terminals)

1. Pull repo + sync hackerjob to DXRP
2. Re-run intake if textures empty:
   `Intake-HackerServerRack.ps1 -SourceRoot "%USERPROFILE%\OneDrive\Desktop\serverrack"`
3. Open `models/.../server-rack/server-rack.vmdl`
4. Source: `source/server-rack.dae`
5. Map PBR from `source/textures/` → create `server-rack.vmat` (see `material-map.json`)
6. `import_scale` — match human-scale rack (~2 m tall); compare placed prefab to player
7. **Compile** → confirm `server-rack.vmdl_c`
8. Open `entities/server-rack/server-rack.prefab` → compile → `server-rack.prefab_c`
9. Smoke: `lp_spawn_server_rack` → USE → power menu

### 2. `hacker-terminal.vmdl` — standard (cornerman green)

1. Source: `source/hacker-terminal.fbx`
2. Map materials — green accent `#00FF7F` on CRT bezel/screen where applicable
3. Align origin Z = bottom; tune `import_scale` to match bitcoin-terminal baseline if needed
4. Compile → `hacker-terminal.vmdl_c`
5. Prefab compile → `lp_spawn_hacker_terminal` / `lp_cornerman_preview`

### 3. `advanced-hacker-terminal.vmdl` — vengeance red

1. Source: `source/hacker-terminal.fbx` (owner `computer.fbx`)
2. Red material pass `#E4002B` — distinct from standard terminal
3. Compile → `advanced-hacker-terminal.vmdl_c`
4. Smoke: `lp_spawn_advanced_hacker_terminal` / `lp_vengeance_preview`

### 4. `advanced-server-rack.vmdl` — **after Red scaffold**

1. Source: `advanced-server-rack/source/advanced-server-rack.obj`
2. Map 9 MTL slots (cabinet, drives, lights, cables…)
3. Match height to basic rack or deliberately taller (advanced tier visual)
4. Compile → scaffold prefab Red adds → `lp_spawn_advanced_server_rack`

---

## bitcoinmining

### 5. `gpu-rack.vmdl` — ✅ `_c` exists

- Verify materials in-world; RGB fan shader if using custom vmat (`RGB_FAN_LED_SHADER.md`)

### 6. `gpu-rack-stacked.vmdl` — ✅ `_c` exists

- Stacked centering per MODEL_BUILD

### 7. `bitcoin-miner.vmdl` — **hub blocker**

1. Source: `entities/bitcoinminer/source/Ophion.fbx` (or hub model path in MODEL_BUILD)
2. Wire `power_on` / `power_off` if anim clips present
3. Hub vmats + compile `_c`
4. `bitcoin-miner.prefab` compile
5. Smoke: `lp_spawn_bitcoin_miner_hub` → power gate → HASHD

### 8. `bitcoin-terminal.vmdl` — legacy

- Optional; hub supersedes. Do not block ship on this.

---

## governmentdatacenter

### 9–10. **Waiting on intake**

- Landmark + `government-terminal` vmdl after `Intake-GovernmentDatacenter.ps1`
- Owner pack ready at `addon stuff\...\governmentterminal\`

---

## Compile order (recommended)

```text
server-rack → hacker-terminal → advanced-hacker-terminal → gpu-rack verify → bitcoin-miner hub → advanced-server-rack
```

After each compile: `git pull` on repo clone — DXRP may write `_c` back via sync script (confirm workflow).
