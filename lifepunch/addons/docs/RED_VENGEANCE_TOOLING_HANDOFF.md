# VENGEANCE tooling handoff (Cornerman outbox → Red)

**Updated:** 2026-06 · Green off-Cursor — outbox files mirrored under `lifepunch/docs/handoff/cornerman-outbox/`

---

## Lane order (Jared on VENGEANCE)

```text
1. git pull --rebase
2. P0 — Bitminer RGB fan shader compile + START/STOP play-test
3. P1 — Visible Pocket Step 1 (DXRP pocket discovery, Opus)
4. P1 — Slot limits → P2 HUD → P3 bank prop
5. Write back: to-cornerman-visible-pocket.txt
```

---

## P0 — Bitminer RGB fan LEDs

**Outbox:** `to-vengeance-bitminer-rgb.txt`

```powershell
powershell -File lifepunch/scripts/Sync-LifePunchAddonsToDxrp.ps1 -Addon bitcoinmining
powershell -File lifepunch/scripts/Start-SboxDxrpEditor.ps1
```

**Play-test:** `hashd` → START → GPU card fan RGB rainbow ramps with fan spin (~8s). STOP → LEDs off.

**Expected ship tree (after Green patch lands or VENGEANCE implements):**

| Path | Role |
|------|------|
| `Assets/.../bitcoinmining/shaders/lifepunch_rgb_fan_led.shader` | Custom LED shader |
| `gpu-rack-gpu.vmat` | Shader ref + `g_flLedActive` |
| `BitminerEntity.UpdateRgbFanLeds()` | Tied to `IsMining` + fan ramp |

**Note:** Fan mesh spin still uses Evo child GOs (`BITMINER-01`). RGB needs `GPU_Emission.png` / rack emission mask.

**Status:** RGB source pulled from Cornerman clone to VENGEANCE — **compile + START/STOP play-test still required** before calling P0 done.

---

## P1 — Visible Pocket

| Doc | Purpose |
|-----|---------|
| `VISIBLE_POCKET_SPEC.md` | Canonical rules |
| `RED_VENGEANCE_VISIBLE_POCKET_BUILD.md` | Opus steps |

**Outbox:** `to-vengeance-visible-pocket.txt`

---

## Also queued (not P0/P1)

- SGE polish
- Hit Shapes staff menu
- llad MIS — `reference/intake/` study only

---

## Git sync cue

**Outbox:** `to-vengeance-git-sync.txt` — pull order: RGB → Visible Pocket.

**Reply slot:** `to-cornerman-visible-pocket.txt` — VENGEANCE fills after Step 1.
