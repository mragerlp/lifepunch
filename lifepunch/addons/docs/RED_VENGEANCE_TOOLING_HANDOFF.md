# VENGEANCE tooling handoff (Cornerman outbox → Red)

**Updated:** 2026-06-10 · Green off-Cursor — outbox files mirrored under `lifepunch/docs/handoff/cornerman-outbox/`

---

## IDE stack (Cursor on VENGEANCE)

**Status:** **Installed** — extensions + `SBOX_LOG_PATH` on Red; `dotnet build Code/addons.csproj` green (2026-06-10). One manual step: palette **S&box: Validate Workspace** after Cursor reload.

**Installer:** `lifepunch/scripts/Install-VengeanceIdeStack.ps1`

### Install checklist

| Step | Target | VENGEANCE status |
|------|--------|------------------|
| 1 | **Cursor C#** (`anysphere.csharp` + `.NET Install Tool`) | ✅ Installed — **not** `ms-dotnettools.csdevkit` (Microsoft blocks Dev Kit outside VS Code; Cursor marketplace does not ship it) |
| 2 | **S&box API Tools** (`alexistb2904.sbox-api-tools`) | ✅ Installed via VSIX v0.1.0 (not in Cursor marketplace index) |
| 3 | **Slang** (`shader-slang.slang-language-extension`) | ✅ v2.0.10 — `.shader`/`.hlsl` highlighting, VFX intellisense; `slang.workspaceFlavor: vfx` in `lifepunch/addons/.vscode/settings.json` |
| 4 | **SboxShare** | Editor Library Manager only — not Cursor |
| 5 | **Open folder** | `C:\Users\jared\Projects\lifepunchaddons\lifepunch\addons\` (not `C:\Projects\lifepunch\…` — that path is absent on Red) |
| 6 | **Solution** | Open `addons.slnx` → Solution Explorer loads LifePunch `Code/addons.csproj` + s&box base/tools refs |

Workspace config: `lifepunch/addons/.vscode/settings.json` + `extensions.json`.

### Quick verify (owner / Red)

```powershell
# CLI build (LIFEPUNCH_LOCAL — no Dxura.RP refs)
dotnet build lifepunch/addons/Code/addons.csproj
```

**Expected under `LIFEPUNCH_LOCAL`:** no `Dxura.RP.*` errors; `bitcoinmining` + `visiblepocket` compile clean.

**2026-06-10 CLI result:** `dotnet build` **0 errors** (61 doc warnings OK). `StaffMenuTestBots` wrapped in `#if !LIFEPUNCH_LOCAL`.

**Palette (manual after Cursor reload on `lifepunch/addons/`):** `S&box: Validate Workspace`

**IDE stack = verified** after palette validate passes once (owner confirm).

### Extension IDs (installed on Red)

```
anysphere.csharp
ms-dotnettools.vscode-dotnet-runtime
alexistb2904.sbox-api-tools
shader-slang.slang-language-extension
```

**Shader edit loop (P0 GPU rack RGB):** edit `Assets/.../shaders/lifepunch_rgb_fan_led.shader` in Cursor (Slang mode) → save in **s&box editor** to compile/hotload → `Pull-DxrpCompiledAssetsToRepo.ps1` for `_c` publish artifacts. Official doc: [shader getting started](https://sbox.game/dev/doc/rendering/shaders/getting-started/).

### Two eyes MCP (s&box editor + Cornerman distill)

| MCP | Eye | Role |
|-----|-----|------|
| `sbox` | Live editor | `capture_view`, spawn cmds, play mode, hierarchy |
| `cornerman-lm` | Local reasoning | `local_reasoning`, distill — hits Green `http://<cornerman-ip>:1234/v1` |

**Install / refresh (VENGEANCE):**

```powershell
powershell -File lifepunch\scripts\Install-VengeanceCornermanLmMcp.ps1
powershell -File lifepunch\scripts\Send-CornermanWorkflow.ps1 -Action WarmDistill
powershell -File lifepunch\scripts\Start-SboxDxrpEditor.ps1 -NoSync
```

Then **restart Cursor** → Settings → MCP → both servers green. IP from `lifepunch/scripts/remote-hosts.json` (currently `192.168.1.229`).

**Cornerman → Claude Bridge (Green Cursor driving Red editor):**

The bridge uses **file IPC** on VENGEANCE `%TEMP%\sbox-bridge-ipc`. Green MCP must watch the same folder via SMB.

**VENGEANCE dual MCP (June 2026):** pair **Claude Bridge** (`sbox` in Cursor) with **chomnr editor MCP** (`sbox-editor` → `http://127.0.0.1:9090/sbox-mcp`). Install: `Install-VengeanceSboxEditorMcp.ps1` · canon: `lifepunch/docs/SBOX_EDITOR_MCP.md`.

```powershell
# Once, elevated on VENGEANCE:
net share SboxBridgeIpc="%TEMP%\sbox-bridge-ipc" /GRANT:Everyone,FULL

# Then from normal shell:
powershell -File lifepunch\scripts\Install-CornermanSboxBridgeMcp.ps1
```

On **Cornerman**: restart Cursor → MCP → `sbox` + `cornerman-lm` green. `sbox` hits `\\VENGEANCE\SboxBridgeIpc`; editor stays on VENGEANCE.

---

## Lane order (Jared on VENGEANCE)

```text
1. git pull --rebase
2. P0 — BitcoinMiningAddon RGB fan shader compile + START/STOP play-test
3. P1 — Visible Pocket Step 1 (DXRP pocket discovery, Opus)
4. P1 — Slot limits → P2 HUD → P3 bank prop
5. Write back: to-cornerman-visible-pocket.txt
```

---

## P0 — BitcoinMiningAddon RGB fan LEDs

**Outbox:** `to-vengeance-bitcoinmining-rgb.txt`

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
| `GpuRackEntity.UpdateRgbFanLeds()` | Tied to `IsMining` + fan ramp |

**Note:** Fan mesh spin still uses legacy child GOs (`BITCOINMINING-01`). RGB needs `GPU_Emission.png` / rack emission mask.

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
