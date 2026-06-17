# DXRP — ModelDoc greenfield lane (June 2026)

**Reset law:** Last 24–48h of throw-it-in-game work stays in the **monorepo as reference only**. DXRP editor mounts **ULX + raw models** — not entity code, not prefabs, not dev spawn until models pass ModelDoc.

**Package law:** `ASSET_CLASSIFICATION_LAW.md` + live audit `ASSET_CLASSIFICATION_REPORT_2026-06.md` (regenerate: `Invoke-LifepunchAssetClassificationAudit.ps1`). Never merge `lp*` folders across gameplay packages.

**Unchanged:** `lifepunchulx` (publish-ready) · `lifepunch-published` export lane · all existing C#/Razor/UI in repo.

---

## What this lane is

| Layer | In DXRP editor? | In monorepo? |
|-------|-----------------|--------------|
| **lifepunchulx** | Yes — compile + ship as today | Yes |
| **`_modeldoc` assets** | Yes — ModelDoc compile only | Yes (`Assets/addons/lifepunch/_modeldoc/`) |
| **Entity code** (bitcoin, hacker, …) | **No** — quarantined in DXRP | Yes — read/reference; reattach after model sign-off |
| **Prefabs + `_c` from broken pass** | **No** — not synced until promoted | Yes — reference; do not overwrite without owner map |
| **Play / spawn / economy test** | **Blocked** until Model Foundation sign-off | — |

---

## One command (VENGEANCE)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File lifepunch\scripts\Setup-ModelDocGreenfieldEditor.ps1
```

Syncs Desktop `lifepunchaddons` -> repo `_modeldoc` -> DXRP lane -> launches editor -> open scene below.

Requires `lifepunch/scripts/dxrp-editor.local.json` (copy from `.example`).

**Fresh scene:** `addons/lifepunch/_modeldoc/scenes/lifepunch-modeldoc.scene`  
(Ground + sky only — no gamemode core, no play test.)

Legacy lane-only (no Desktop sync / no launch):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File lifepunch\scripts\Set-DxrpLifepunchModelDocLane.ps1
```

---

## Build order (foundation first)

```text
Owner drops FBX → repo _modeldoc/<your-folder>/source/
       ↓
ModelDoc: scale, pivot, align, materials, compile vmdl (_c)
       ↓
Owner sign-off: mesh orientation, size vs citizen, anim sanity (fans static in body pass)
       ↓
Promote vmdl → shipped addon models/ path + prefab (entity code unchanged)
       ↓
Phase 1 collision (white wireframe = BoxCollider all axes)
       ↓
Play test (flatgrass / spawn kit) — only after above
```

**Do not** skip to prefab entity wiring or `lp_*` spawn while models are still in `_modeldoc`.

---

## Lane scripts (pick one — never stack)

| Lane | Script | Mounts |
|------|--------|--------|
| **ModelDoc greenfield (now)** | `Set-DxrpLifepunchModelDocLane.ps1` | `lifepunchulx` + `_modeldoc` |
| ULX only | `Set-DxrpLifepunchUlxOnly.ps1` | `lifepunchulx` |
| Bitcoin playtest (later) | `Set-DxrpLifepunchBitcoinOnly.ps1` | `bitcoinmining` + `_dev` |

After model sign-off, switch lanes explicitly — do not `-SyncAllAddons` without owner OK.

---

## Where you drop files

You define folder names and **which model becomes which entity**. Agent waits for your map.

Staging tree (repo + DXRP mirror):

```text
Assets/addons/lifepunch/_modeldoc/
  lpbitcoinmining/          ← your folders
  lphacker/
  lpblackmarket/
  lpbanker/
  universal/
  …/source/*.fbx
  …/textures/
```

When you message intake, use:

```text
Folder: _modeldoc/lpbitcoinmining/hub
Entity: (you tell us)
Main FBX: source/….
Notes: …
```

---

## What we keep from the last pass (reference)

- **UI / Razor** — HASHD, hacker panels, ULX chrome
- **Economy / RPC / entity C#** — unchanged on disk; not compiled in this lane
- **Docs / specs** — UX numbers, cyber ecosystem law
- **Broken vmdl/prefab experiments** — do not delete; do not re-sync to DXRP until replaced

Publish export: still **`adminmenu` / lifepunchulx** only (`portfolio.json` → `publishReadyAddons`).

---

## Related

- `MODEL_FOUNDATION_PASS.md` — per-model checklist before prefab attach
- `MODEL_INTAKE_DROP_MAP.md` — entity map **TBD by owner** this phase
- `PUBLISH_REPO_LANE.md` — two-repo law unchanged
- `DXRP_ULX_ONLY_LANE.md` — ULX-only variant
