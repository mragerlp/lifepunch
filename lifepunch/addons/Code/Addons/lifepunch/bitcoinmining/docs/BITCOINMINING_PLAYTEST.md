# Bitcoin Miner — play-test checklist

**Editor:** `Start-SboxDxrpEditor.ps1` (opens DXRP normally) · **Sync:** `Sync-LifePunchAddonsToDxrp.ps1 -Addon bitcoinmining`

**API key (optional):** in console after host play — `authorize <dxrp.net server token>`

---

## 0. Enter play mode (DXRP is DedicatedServerOnly)

### Root cause (confirmed 2026-06-11)

**Play fails when the active tab is a prefab stage** (`Prefab: GPU Rack`, `Prefab: Large GPU Rack`, etc.). Bridge reports `sceneName: "gpu-rack"` — that is **not** DXRP play mode. Hosting from there always yields `Unable to create a lobby outside of a game`.

**Play works from `scenes/game.scene`** — bridge reports `sceneName: "Game"`, log shows `[Fitter] Fitting thieves.rpdowntown3t` and `Mr. Rager has joined the game`.

### Steps (every session)

1. **Close all prefab tabs** (save/discard the `*` on Large GPU Rack if prompted).
2. Asset Browser → **scenes** → double-click **`game.scene`** — tab title must say **Game**, not `Prefab: …`.
3. Press **Play** (green arrow). First cold load: wait **2–5 minutes** while downtown compiles; early Stop = `Couldn't load map (A task was canceled.)`.
4. Log/console shows player join + map fit → you're in. Then: `lp_hashd_preview` or `lp_spawn_gpu_rack`.
5. **Start Hosting** is optional and only **after** step 3 succeeds (not from prefab edit mode).
6. Portal/API when needed: `authorize <token>` in console.

**Stall on cold start:** broken `advanceddrugprocessing` models on disk can spam recompiles — local DXRP install may rename that folder to `advanceddrugprocessing._disabled` (not in `rp.sbproj` Resources).

### Log triage (`D:\Steam\steamapps\common\sbox\logs\sbox-dev.log`)

| Log line | Severity | Cause | Fix (owner/agent) |
|----------|----------|-------|-------------------|
| `lifepunch_rgb_fan_led.shader` + `Feature combo not found` | **P0 block** | Custom GPU vmat shader not compiled | **Fixed baseline:** `gpu-rack-gpu.vmat` → `complex.shader` (BITCOINMINING-03). Endgame: compile shader in editor, restore RGB vmat. |
| `gpu-rack-gpu.vmat_c` / `gpu_basecolor...vtex_c` not found | **P0 block** | Downstream of failed vmat compile | Recompile vmat + vmdl after vmat fix; `Pull-DxrpCompiledAssetsToRepo.ps1`. |
| `Couldn't load map (A task was canceled.)` | **P0 block** | Map load aborted (Stop clicked too soon, prefab tab active, or compile stall) | Open **`scenes/game.scene`** (not prefab); Play once and **wait** 2–5 min; disable broken `advanceddrugprocessing._disabled` folder locally. |
| `Unable to create a lobby outside of a game` | User flow | Start Hosting clicked before Play | Play first, then Start Hosting (§0 above). |
| `ToolsStallMonitor Stall detected` | Watch | Long on-demand recompiles (bitcoinmining vmdl/vmat) | Fix P0 shader; avoid leaving `gpu-rack-test` in startup scene. |
| `FanBlades.00x` / `GPU_Fan_x.00x` incorrect extension | **P0 loop** | Stacked FBX material slots not remapped | **Fixed:** remaps in `gpu-rack-stacked.vmdl` → rack/gpu vmats. |
| `bassm\Desktop\PSU...` content-relative error | Warning | Stacked FBX embeds artist absolute paths | Ignored after remap; PSU uses our `gpu-rack-psu.vmat`. |
| `dark green.vmat_c` / `lime green.vmat_c` on terminal | **P1 loop** | CRT FBX `Lime Green` / `Dark Green` slots | **Fixed:** remap → `bitcoin-terminal-monitor.vmat`. |
| `bitcoin-miner/*.sound_c` not found | **P1 loop** | Prefab refs sounds that do not exist yet | **Fixed:** prefab sound props nulled until owned audio ships. |
| `Skipping texture streaming` (gpu textures) | Watch | Recompile storm settling | Stops after vmat/vmdl `_c` stable; restart editor if it persists >30s. |
| `repeating-linear-gradient` / `linear-gradient` invalid `background-image` | **P1 loop** | s&box UI panel SCSS rejects CSS gradients | **Fixed:** solid colors in `HashdTerminal.razor.scss` (no gradients). |
| `Failed to get player inventory` **403** | Expected offline | No `authorize` token / portal API | Console: `authorize <dxrp.net token>` — not required for `lp_spawn_gpu_rack` / hashd UI. |
| `Unable to load prefab improved_atm` (×11) | DXRP map | Map fitting references missing SPL ATM addon | Noise only; downtown still loads. |
| `Couldn't find Input Action called "Pocket"` | DXRP | Pocket bind not in project InputSettings | Ignore for bitcoinmining playtest. |
| `returning error texture` metal036 / door vmdl | DXRP map | Downtown fitting props missing `_c` on cold compile | Cosmetic checkerboard on some doors; map playable. |
| `lp_spawn_gpu_rack: gpu-rack + bitcoin-terminal placed` | **OK** | Dev spawn succeeded | Run `hashd` near rig or `lp_hashd_preview` from play mode. |
| FPS tanks right after `lp_spawn_gpu_rack` | **P0 perf** | `ModelCollider` on full `gpu-rack*.vmdl` with `PhysicsHullFromRender` / `HullPerElement` + per-frame `TextRenderer` rebuild | **Fixed:** prefabs use tuned `BoxCollider` + `StartAsleep`; `GpuRackEntity` throttles screen text + RGB attribute writes. |

**MCP check:** `read_log` filter `bitcoinmining`, `error`, `spawn`, `403`. **Do not** leave test rigs in `game.scene` — use `lp_spawn_gpu_rack` in play mode instead.

## 1. See the hashd console (fastest)

Enter play mode (hosted), then:

```text
lp_hashd_preview
```

Spawns small rack + CRT kit and **opens the hashd overlay immediately**. The CRT world mesh can still show ERROR until `bitcoin-terminal.vmdl` is compiled in ModelDoc — the console UI does not depend on the CRT mesh.

**Three entities (owner canon):** Bitcoin Terminal = control · GPU Rack = small · Large GPU Rack = stacked (2× yield). See `docs/reference/BITCOINMINING_THREE_ENTITY_ARCH.md`.

---

## 2. Spawn a rig

**Fast (dev console):**

```text
lp_spawn_gpu_rack
```

Spawns **GPU Rack** (`gpu-rack.prefab`) + **Bitcoin Terminal** (`bitcoin-terminal.prefab`) as linked pair. Works with a DXRP pawn **or** editor camera.

```text
lp_spawn_bitcoin_terminal
lp_spawn_large_gpu_rack
lp_spawn_bitcoinmining_full_kit
```

CRT only · stacked rack only · all three entities (terminal + small + advanced).

**Manual:** Asset Browser → DXRP → `addons/lifepunch/bitcoinmining/entities/gpu-rack/gpu-rack.prefab` → drag into map → **save scene**.

**Verify scene (dev console):**

```text
lp_gpu_rack_count
```

Logs `BITCOINMINING_TEST rigs=N pos=...` for every `GpuRackEntity` in the active scene.

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

**World scale:** `gpu-rack` root `Scale` **0.65** · `large-gpu-rack` **0.5** (tuned from early oversized import; `0.4`/`0.3` was too small in play). Collider + mesh share root scale; nudge prefab root if still off.

---

## 5. Known gaps (not blockers for Phase 1)

- Sounds missing (`sounds/bitcoin-miner/` — hum disabled on prefab)
- Power anim not wired (`gpu-rack-anim.fbx` → `power_on` / `power_off`)
- Economy RPCs need host + wallet — verify sell/upgrade on live DXRP server, not editor-only stub
- Remove `BitcoinMiningDevSpawn.cs` before portal publish

---

## 6. After editor tweaks

Copy compiled outputs from DXRP `game/Assets/addons/lifepunch/bitcoinmining/` back into monorepo `lifepunch/addons/Assets/...`.
