# Red — CS2 weapon batch (VENGEANCE)

One sitting on VENGEANCE with CS2 installed. Goal: **reference glTF + sounds** for every gun in `cs2-weapon-catalog.json`, then rebuild **world models with physics**.

**Keep LifePunch sounds** on AK (and future guns) — CS2 audio is mix reference only.

---

## 0. Sync

```powershell
cd C:\Users\jared\Projects\lifepunchdxrp
git pull --rebase
.\lifepunch\addons\scripts\Sync-LifePunchAddonsToDxrp.ps1
```

---

## 1. Manifest stubs (any machine)

```powershell
cd lifepunch\addons\scripts
powershell -File .\Intake-Cs2WeaponReference.ps1 -ManifestOnly
```

Writes `C:\lifepunch\reference-intake\cs2-weapons\<ident>\MANIFEST.txt` for all 12 catalog weapons.

---

## 2. Batch glTF export (VENGEANCE + CS2)

```powershell
$vpk = 'D:\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\pak01_dir.vpk'
$cli = 'C:\Tools\Source2Viewer-CLI.exe'   # install from https://s2v.app/

powershell -File .\Intake-Cs2WeaponReference.ps1 `
  -Cs2Vpk $vpk -CliPath $cli -ExportGltf
```

CLI may miss some `vmdl_c` names — use S2V GUI per `MANIFEST.txt` for **world/** exports (critical).

---

## 3. Per-weapon S2V GUI pass (do not skip world/)

For each folder under `reference-intake/cs2-weapons/`:

| Export | Folder | Why |
|--------|--------|-----|
| Viewmodel / ag2 | `viewmodel/` | Proportions, reload timing study |
| **World / dropped** | `world/` | **Author `w_<ident>.fbx` from this** |
| Sounds | `sounds/` | Reference mix — re-ship own WAV |
| Mag / extras | `attachments/` | Optional |

Fill in `animations_seen:` and sound event names in each `MANIFEST.txt`.

---

## 4. Rebuild order

| # | ident | Play today | CS2 mesh |
|---|-------|------------|----------|
| 1 | `ak47` | `lp_give_ak_class` | `weapon_rif_ak47` |
| 2–5 | deagle, mp9, ssg08, xm1014 | `lp_give_*` | see catalog |
| 6 | `doublebarrelshotgun` | `lp_give_dbs` | `weapon_shot_sawedoff` |
| 7+ | awp, glock18, m4a4, p250, galilar, famas | class kit only | extended study |

**AK blockers fixed by CS2 world mesh + ModelDoc physics** — see `CS2_WORLD_MODEL_PIPELINE.md`.

---

## 5. Ship checklist (each weapon)

- [ ] `w_<ident>.fbx` from CS2 **world** glTF (own mesh)
- [ ] `w_<ident>.vmdl` with **collision hull**
- [ ] Clone class `w_<dxrpClass>.prefab` → swap model
- [ ] Class `vm_<dxrpClass>` on ViewModelPrefab until FP rig
- [ ] **Own** `.sound` + `.wav` (copy AK pattern)
- [ ] Drop test: equip → drop → rests on floor
- [ ] `prepare-publish.ps1 -Addon <ident>`

---

Canon: `CS2_FIRST_WEAPON_TEST.md` · `config/cs2-weapon-catalog.json`
