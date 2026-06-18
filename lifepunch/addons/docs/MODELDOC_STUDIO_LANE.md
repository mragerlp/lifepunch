# LIFEPUNCH ModelDoc Studio — standalone lane (no DXRP)

**June 2026** — Lightweight s&box project for ModelDoc only. No DXRP gamemode, no `game.scene`, no portal API, no entity C# compile.

---

## Why

DXRP loads the full gamemode + systems scene graph. ModelDoc work only needs meshes, textures, and a blank review scene. This lane cuts editor overhead and avoids touching DXRP mounts.

---

## Your empty folders (create once)

Under wherever you want to work (repo staging **or** your own root), create:

```text
lpbitcoin/
  bitcoinhub/
    assets/source/fbx/
    assets/source/blend/
    assets/source/obj/
    assets/textures/
    assets/models/
    assets/entities/
    assets/sounds/
    assets/ui/
    code/components/
    code/ui/
    code/docs/
    audit/
```

Repeat per entity slot (`hashdterminal`, `gpurack`, …). Package folders: `lpbitcoin`, `lphacker`, `lppolice`, etc. See `PACKAGE_STAGING_LAYOUT.md`.

Tell the agent when folders exist — we run `Place-LifepunchModelDocAssets.ps1` to copy **only ModelDoc files** (source, textures, models, audit). Skips `code/` unless you ask.

---

## Built-in studio project (repo)

```text
lifepunch/modeldoc-studio/game/
  modeldoc.sbproj          # standalone game, NOT dxura.rp
  scenes/modeldoc-blank.scene
  Assets/addons/lifepunch/lpbitcoin/...
```

---

## One-time setup

```powershell
copy lifepunch\scripts\modeldoc-studio.local.json.example lifepunch\scripts\modeldoc-studio.local.json
# edit sboxDevPath if needed — projectPath defaults to repo modeldoc-studio
```

---

## Daily workflow

```powershell
# Sync repo staging -> studio + open editor
powershell -File lifepunch\scripts\Start-SboxModelDocStudio.ps1

# Or populate your empty folders from repo canonical staging:
powershell -File lifepunch\addons\scripts\Place-LifepunchModelDocAssets.ps1 -Package lpbitcoin -Entity bitcoinhub -TargetRoot "D:\Your\Empty\Root"

# P0 hub only into studio:
powershell -File lifepunch\scripts\Start-SboxModelDocStudio.ps1 -Package lpbitcoin -Entity bitcoinhub
```

**Open in editor:**

- Project: `modeldoc-studio/game/modeldoc.sbproj`
- Scene: `scenes/modeldoc-blank.scene`
- ModelDoc: `addons/lifepunch/lpbitcoin/bitcoinhub/assets/models/bitcoin-hub.vmdl`

**MCP:** use `sbox-editor` (chomnr) on port 9090 — same as DXRP lane, but project is ModelDoc Studio.

---

## What we copy (ModelDoc necessary)

| Include | Skip (until promotion) |
|---------|-------------------------|
| `assets/source/**` | `code/**` |
| `assets/textures/**` | `assets/entities/**` |
| `assets/models/**` (vmdl, vmat, maps) | `assets/sounds/**`, `assets/ui/**` |
| `audit/manifest.json` | Desktop `extracted/` zips |

---

## vs DXRP lane

| | ModelDoc Studio | DXRP greenfield lane |
|--|-----------------|----------------------|
| Gamemode | None (standalone) | dxura.rp |
| Startup scene | `modeldoc-blank.scene` | DXRP `game.scene` systems |
| ULX / portal | No | ULX mounted |
| Use when | Mesh compile + sign-off | Full DXRP context later |

After ModelDoc sign-off, promote vmdl into shipped `bitcoinmining/` paths — still no need to open DXRP for mesh work.

---

## Related

- `LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md` — full machine stack (P0–P4)
- `PACKAGE_STAGING_LAYOUT.md`
- `MODEL_FOUNDATION_PASS.md`
- `Place-LifepunchModelDocAssets.ps1`
