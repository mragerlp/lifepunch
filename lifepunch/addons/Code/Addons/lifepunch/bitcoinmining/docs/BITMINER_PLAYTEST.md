# Bitcoin Miner — play-test checklist

**Editor:** `Start-SboxDxrpEditor.ps1` (opens DXRP normally) · **Sync:** `Sync-LifePunchAddonsToDxrp.ps1 -Addon bitcoinmining`

**API key (optional):** in console after host play — `authorize <dxrp.net server token>`

---

## 0. Host + join (DXRP is DedicatedServerOnly)

1. Open a **map scene** (not a prefab stage) — e.g. downtown map, not `game.scene` prefab stage.
2. Press **Play** (green arrow) first — editor must be **in play mode**.
3. Viewport toolbar → **network** icon → **Start Hosting** (before Play = `Unable to create a lobby outside of a game`).
4. Portal/API data only when needed: `authorize <token>` in console.

### Log triage (`D:\Steam\steamapps\common\sbox\logs\sbox-dev.log`)

| Log line | Severity | Cause | Fix (owner/agent) |
|----------|----------|-------|-------------------|
| `lifepunch_rgb_fan_led.shader` + `Feature combo not found` | **P0 block** | Custom GPU vmat shader not compiled | **Fixed baseline:** `gpu-rack-gpu.vmat` → `complex.shader` (BITMINER-03). Endgame: compile shader in editor, restore RGB vmat. |
| `gpu-rack-gpu.vmat_c` / `gpu_basecolor...vtex_c` not found | **P0 block** | Downstream of failed vmat compile | Recompile vmat + vmdl after vmat fix; `Pull-DxrpCompiledAssetsToRepo.ps1`. |
| `Couldn't load map (A task was canceled.)` | **P0 block** | Map load aborted (often user stop, or asset compile stall mid-load) | Clear bitminer test GOs from `Assets/scenes/game.scene`; fix P0 vmat; retry Play on **map** scene. |
| `Unable to create a lobby outside of a game` | User flow | Start Hosting clicked before Play | Play first, then Start Hosting (§0 above). |
| `ToolsStallMonitor Stall detected` | Watch | Long on-demand recompiles (bitminer vmdl/vmat) | Fix P0 shader; avoid leaving `gpu-rack-test` in startup scene. |
| `dark green.vmat_c` / `lime green.vmat_c` on terminal | Cosmetic | Stale CRT mesh material paths | ModelDoc remap on `bitcoin-terminal.vmdl`; non-blocking for hashd CLI. |
| `bitcoin-miner/*.sound_c` not found | Cosmetic | Sounds not compiled | Non-blocking; hum disabled on prefab. |

**MCP check:** `get_compile_errors` + `read_log` (sbox bridge). **Do not** leave test rigs in `game.scene` — use `lp_spawn_bitminer` in play mode instead.

## 1. See the hashd console (fastest)

Enter play mode (hosted), then:

```text
lp_hashd_preview
```

Spawns small rack + CRT kit and **opens the hashd overlay immediately**. The CRT world mesh can still show ERROR until `bitcoin-terminal.vmdl` is compiled in ModelDoc — the console UI does not depend on the CRT mesh.

**Three entities (owner canon):** Terminal = control · Bitcoin Miner = small rack · Advanced Bitcoin Miner = stacked rack (TODO). See `docs/reference/BITMINER_THREE_ENTITY_ARCH.md`.

---

## 2. Spawn a rig

**Fast (dev console):**

```text
lp_spawn_bitminer
```

Spawns **Bitcoin Miner** (`bitcoin-miner.prefab`) + **Bitcoin Terminal** (`bitcoin-terminal.prefab`) as linked pair. Works with a DXRP pawn **or** editor camera.

```text
lp_spawn_bitcoin_terminal
lp_spawn_advanced_bitminer
lp_spawn_bitminer_full_kit
```

CRT only · stacked rack only · all three entities (terminal + small + advanced).

**Manual:** Asset Browser → DXRP → `addons/lifepunch/bitcoinmining/entities/bitcoin-miner/bitcoin-miner.prefab` → drag into map → **save scene**.

**Verify scene (dev console):**

```text
lp_bitminer_count
```

Logs `BITMINER_TEST rigs=N pos=...` for every `BitminerEntity` in the active scene.

---

## 3. Open terminal

Within **8 m horizontal / 4 m vertical** of the rig:

| Input | Action |
|-------|--------|
| `hashd` | Open LIFEPUNCH hashd CLI |
| `mine` | Same as `hashd` |
| `hashd close` | Close terminal |
| **Use key** on rig | `IPressable` → same as `hashd` |

---

## 4. CLI smoke test

```text
help
status
info
mining start
status
mining stop
bitcoin
upgrade
clear
```

**Scroll:** mouse-wheel the terminal output area (history keeps up to 200 lines).

**UI:** **HASHD RIG CONTROL** — amber telemetry rail (left) + command log (right). Rail **START/STOP** toggles mining without typing.

**Upgrade panel:** `upgrade` or `menu` opens **INSTALL** buttons for CPU Clock and CPU Cores (still accepts `upgrade cpu` / `upgrade cores`).

Expected: green terminal UI, LCD on `lcd_screen` (on `bitcoin-terminal.prefab`), fans spin while mining (placeholder fan GOs until vmdl anim ships).

**LCD tune:** nudge `lcd_screen` transform on `entities/bitcoin-terminal/bitcoin-terminal.prefab` — not on the rack prefab.

---

## 5. Known gaps (not blockers for Phase 1)

- Sounds missing (`sounds/bitcoin-miner/` — hum disabled on prefab)
- Power anim not wired (`gpu-rack-anim.fbx` → `power_on` / `power_off`)
- Economy RPCs need host + wallet — verify sell/upgrade on live DXRP server, not editor-only stub
- Remove `BitminerDevSpawn.cs` before portal publish

---

## 6. After editor tweaks

Copy compiled outputs from DXRP `game/Assets/addons/lifepunch/bitcoinmining/` back into monorepo `lifepunch/addons/Assets/...`.
