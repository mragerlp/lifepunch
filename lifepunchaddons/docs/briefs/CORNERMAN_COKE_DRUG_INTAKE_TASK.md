# Cornerman task — Coke / enhanced drug asset intake

**Lane:** Cornerman (Qwen 2.5) · **Red:** VENGEANCE editor + Opus before ship  
**Issued:** 2026-06-11

---

## Goal

Prep LifePunch **cocaine / enhanced drug dealer** assets for VENGEANCE ModelDoc while Jared works on Bitcoin Miner gpu-rack models.

**You do NOT:** open s&box, publish portal, or `git push`.

---

## Source locations

| What | Path |
|------|------|
| Full owner pack | `C:\Users\jared\OneDrive\Desktop\bloat\serverstuff\advanceddrugprocessing\` |
| After Red intake | `lifepunchaddons/Assets/.../advanceddrugprocessing/` |
| Archive | `C:\lifepunch\reference-intake\advanceddrugprocessing\full-export\` |

Read `Assets/.../advanceddrugprocessing/ASSET_INVENTORY.md` after `git pull`.

---

## Tasks

### 1. Unzip raw archives (into archive mirror, not repo binaries unless asked)

Under source pack, extract to flat folders:

- `cocaine-brick/source/Coke Brick.zip` → FBX + textures
- `chemical-barrel/source/model.zip`
- `meth_raw/source/model.zip`
- `meth_bag/source/*.zip`

Document extracted filenames in `reference-intake/.../UNZIP_MANIFEST.txt`.

### 2. `coke-brick` + `coke-bag` material-map stubs

**Done on VENGEANCE (2026-06-11)** — verify paths after `git pull`:

```text
models/lifepunch/advanceddrugprocessing/coke-brick/material-map.json
models/lifepunch/advanceddrugprocessing/coke-bag/material-map.json
```

Cornerman: only fix if channel paths drift after unzip manifest work.

### 3. Distill weed vs coke map

Update `COKE_LINE_MAP.md` § mapping table from:

- `addons/docs/COKE_DRUG_RESKIN_SPEC.md`
- **`addons/docs/reference/WEED_ENGINE_ENTITY_INDEX.md`** (Red pre-seeded from download cache)
- `ASSET_INVENTORY.md` (coke side)

Fill **Weed counterpart** column with best-guess prefab paths; mark uncertain cells `TBD — needs Red editor spawn`.

### 4. Commit on Green (local only)

```text
chore(advanceddrugprocessing): coke intake manifests + material-map stubs
```

Ping VENGEANCE: N commits, subjects. **Red publishes.**

---

## Red checklist (not Cornerman)

- [x] `Intake-AdvancedDrugProcessingAssets.ps1` (run on VENGEANCE 2026-06-11)
- [x] `coke-bag` / `coke-brick` material-map stubs + brick zip extracted to `intake-raw/source/`
- [ ] DXRP editor: spawn weed + coke entities, complete `COKE_LINE_MAP.md`
- [ ] ModelDoc `coke-bag`, `coke-brick`
- [ ] Opus review economy / portal rows
- [ ] `prepare-publish.ps1 -Addon advanceddrugprocessing`

---

## Reference

- Portal addon: `019e36bf-31bf-7b2a-a56f-1ab4467cec29`
- Weapon parallel: `WEAPON_PROGRAM.md` (class kit, not new engine)
