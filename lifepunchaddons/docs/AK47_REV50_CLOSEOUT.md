# AK-47 — Rev 50 closeout gate

**STATUS: PARKED (2026-06-11)** — Owner pivot to **CS2-first rebuild**. Do **not** pin Rev 50 or publish more AK revisions. See `CS2_FIRST_WEAPON_TEST.md`.

~~**Target:** call Rev **50** the shipping candidate for `lifepunchdevelopment` (Gun Dealer shipment + market).~~

Repo kit is **publish-ready** pending one editor smoke on VENGEANCE. Do not publish again for prefab JSON tweaks until that smoke passes.

---

## Done in repo (no more revision churn for these)

| Area | State |
|------|-------|
| World prefab | `w_ak47.prefab` — M4-class grip, muzzle `20.08,0,7.21`, ejection `1.77,-0.42,7.67`, no 180° flip |
| Viewmodel prefab | `vm_ak47.prefab` — **M4 class placeholder FP** (bonemerged `v_ak47` disabled — skeleton mismatch caused frankenstein mesh) |
| World model | `w_ak47.vmdl` — `import_scale` 0.039, Z lift 8 |
| Viewmodel mesh | `v_ak47.vmdl` + `source/ak47_vm.fbx` compiled (`_c` on disk) |
| Sounds | Full owned WAV set wired on prefab |
| Killfeed | `ui/ak47_killfeed.png` |
| Stats | Prefab matches `AK47.cs` (28 dmg · 600 RPM · 30/90 · 2.4s reload) |
| Dev test | `lp_give_ak` in `_dev/WeaponDevGive.cs` (excluded from publish) |
| Content paths | Mounted `addons/lifepunch/ak47/...` everywhere |

**Baseline (tracked):** FP shows **M4 viewmodel** until `v_ak47` is rigged to M4 bones (bonemerge was disabled 2026-06-11). 3P still uses LifePunch `w_ak47`. See `TECH_DEBT` FP-AK-01.

---

## Three gates before you pin Rev 50

Run on VENGEANCE after `Sync-LifePunchAddonsToDxrp.ps1 -Addon ak47`:

```text
lp_give_ak
```

| # | Check | Pass |
|---|-------|------|
| **G1** | First person | **M4 class arms + anim** (placeholder skin); reload/fire OK; no mesh distortion |
| **G2** | Third person + crate | AK in hand; muzzle flash at barrel; shipment height ≈ M4 crate |
| **G3** | Combat | Fire/reload sounds; 30-round mag; auto spray feels ~600 RPM |

All three pass → publish staging → portal Rev 50 → pin gamemode → sync dev server only.

---

## Publish (copy-paste)

```powershell
cd C:\Users\jared\Projects\lifepunch\lifepunchaddons
.\scripts\validate-layout.ps1
.\scripts\prepare-publish.ps1 -Addon ak47
```

Portal changelog:

```text
AK-47 Rev 50: M4-rig viewmodel baseline, w_ak47 hold/muzzle fix, full LifePunch sounds — golden kit ship candidate.
```

Gamemode (development only):

1. LifePunch gamemode → AK-47 addon → pin **Rev 50**
2. Market tab → AK-47 shipment row uses same revision
3. Save → sync **lifepunchdevelopment** → restart server

---

## Stop doing

- Publishing Revs 51+ for rotation/scale guesses — fix in editor, sync repo once, one final rev
- Portal JSON path edits — paths are correct
- Removing `invisible.vmat` — still required (ViewModel tint forces alpha 1)

---

## After Rev 50 ships

- Red starts deagle queue (`RED_WEAPON_MASS_PRODUCTION_PLAN.md` #2)
- FP-AK-01 clean endgame (owned per-class rig) stays in `TECH_DEBT.md` — not a Rev 50 blocker

Canon: `FAST_WEAPON_TEST.md` G1 · `AK47_FIX_CHECKLIST.md` · `VIEWMODEL_BUILD.md`
