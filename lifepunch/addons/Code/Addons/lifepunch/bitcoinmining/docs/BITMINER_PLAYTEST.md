# Bitcoin Miner — play-test checklist

**Editor:** DXRP + API (`Start-SboxDxrpEditor.ps1`) · **Sync:** `Sync-LifePunchAddonsToDxrp.ps1 -Addon bitcoinmining`

---

## 1. Spawn a rig

**Fast (dev console):**

```text
lp_spawn_bitminer
```

Spawns `bitcoin-miner.prefab` ~3 m in front of you with full components. Works with a DXRP pawn **or** editor camera (no pawn required).

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

**Upgrade menu:** `upgrade` or `menu` opens clickable **PURCHASE** buttons for CPU Clock and CPU Cores (still accepts `upgrade cpu` / `upgrade cores`).

Expected: green terminal UI, LCD on `computer_terminal` monitor face, fans spin while mining (placeholder fan GOs until vmdl anim ships).

**LCD tune:** if the world TextRenderer misses the CRT, nudge `computer_terminal` / `lcd_text` transforms on `bitcoin-miner.prefab` in editor.

---

## 4. Known gaps (not blockers for Phase 1)

- Sounds missing (`sounds/bitcoin-miner/` — hum disabled on prefab)
- Power anim not wired (`gpu-rack-anim.fbx` → `power_on` / `power_off`)
- Economy RPCs need host + wallet — verify sell/upgrade on live DXRP server, not editor-only stub
- Remove `BitminerDevSpawn.cs` before portal publish

---

## 5. After editor tweaks

Copy compiled outputs from DXRP `game/Assets/addons/lifepunch/bitcoinmining/` back into monorepo `lifepunch/addons/Assets/...`.
