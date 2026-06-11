# Bitcoin Miner — play-test checklist

**Editor:** DXRP + API (`Start-SboxDxrpEditor.ps1`) · **Sync:** `Sync-LifePunchAddonsToDxrp.ps1 -Addon bitcoinmining`

---

## 0. See the hashd console (fastest)

Enter play mode, then:

```text
lp_hashd_preview
```

Spawns small rack + CRT kit and **opens the hashd overlay immediately**. The CRT world mesh can still show ERROR until `bitcoin-terminal.vmdl` is compiled in ModelDoc — the console UI does not depend on the CRT mesh.

**Three entities (owner canon):** Terminal = control · Bitcoin Miner = small rack · Advanced Bitcoin Miner = stacked rack (TODO). See `docs/reference/BITMINER_THREE_ENTITY_ARCH.md`.

---

## 1. Spawn a rig

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

## 2. Open terminal

Within **8 m horizontal / 4 m vertical** of the rig:

| Input | Action |
|-------|--------|
| `hashd` | Open LIFEPUNCH hashd CLI |
| `mine` | Same as `hashd` |
| `hashd close` | Close terminal |
| **Use key** on rig | `IPressable` → same as `hashd` |

---

## 3. CLI smoke test

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

## 4. Known gaps (not blockers for Phase 1)

- Sounds missing (`sounds/bitcoin-miner/` — hum disabled on prefab)
- Power anim not wired (`gpu-rack-anim.fbx` → `power_on` / `power_off`)
- Economy RPCs need host + wallet — verify sell/upgrade on live DXRP server, not editor-only stub
- Remove `BitminerDevSpawn.cs` before portal publish

---

## 5. After editor tweaks

Copy compiled outputs from DXRP `game/Assets/addons/lifepunch/bitcoinmining/` back into monorepo `lifepunch/addons/Assets/...`.
