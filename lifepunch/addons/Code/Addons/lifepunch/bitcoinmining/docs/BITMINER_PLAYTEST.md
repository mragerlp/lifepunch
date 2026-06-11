# Bitcoin Miner — play-test checklist

**Editor:** DXRP + API (`Start-SboxDxrpEditor.ps1`) · **Sync:** `Sync-LifePunchAddonsToDxrp.ps1 -Addon bitcoinmining`

---

## 1. Spawn a rig

**Fast (dev console):**

```text
lp_spawn_bitminer
```

Spawns `bitcoin-miner.prefab` ~3 m in front of you with full components.

**Manual:** Asset Browser → DXRP → `addons/lifepunch/bitcoinmining/entities/bitcoin-miner/bitcoin-miner.prefab` → drag into map → **save scene**.

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

Expected: green terminal UI, LCD text updates on rig, fans spin while mining (placeholder fan GOs until vmdl anim ships).

---

## 4. Known gaps (not blockers for Phase 1)

- Sounds missing (`sounds/bitcoin-miner/` — hum disabled on prefab)
- Power anim not wired (`gpu-rack-anim.fbx` → `power_on` / `power_off`)
- Economy RPCs need host + wallet — verify sell/upgrade on live DXRP server, not editor-only stub
- Remove `BitminerDevSpawn.cs` before portal publish

---

## 5. After editor tweaks

Copy compiled outputs from DXRP `game/Assets/addons/lifepunch/bitcoinmining/` back into monorepo `lifepunch/addons/Assets/...`.
