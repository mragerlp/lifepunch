# Sbox UI Designer — LifePunch runbook

**Library:** `kikozl.sbox_ui_designer` (installed in DXRP `Libraries/`)  
**DXRP ref:** `rp.csproj` ProjectReference — required for compile, optional for daily work  
**Pair with:** [TAILWAND.md](./TAILWAND.md) for utility-class polish on generated or hand-written Razor

---

## When to use it

| Use SUI | Skip SUI |
|---------|----------|
| New panel **layout shell** (header, tabs rail, content frame) | Logic-heavy menus (`StaffMenu`, hub terminals with `@code` + host RPCs) |
| Visual spacing/anchor iteration before hand-merge | Replacing entire shipped `.razor` files in one compile |
| HUD / hotbar prototypes | Portal ship without merging proprietary header + namespace |

**Canon:** `.sui` is **your** visual source of truth while iterating → generated `.razor` / `.razor.scss` in `_sui_scratch/` are **disposable reference**. After port, LifePunch **repo** `LpHashdPanel.razor` + `.razor.scss` are ship truth (logic + bindings stay hand-written).

---

## Co-editing workflow (you = visuals, agent = code)

| Lane | You (UI Designer) | Agent (Cursor) |
|------|-------------------|----------------|
| **Edit** | `hashd-hub-ui.sui` — layout, spacing, colors, images | `LpHashdPanel.razor` `@code`, host RPCs, tab logic, PIN |
| **Preview** | Compile (`Ctrl+B`) → **Test in Play** on scratch panel | `lp_bitcoin_preview_hub` on shipped `LpHashdPanel` |
| **Handoff → repo** | Run pull script (below) when a visual pass is ready | Port layout/class/CSS deltas from scratch or `.sui` into ship Razor |
| **Handoff → DXRP** | — | `Sync-LifePunchAddonsToDxrp.ps1 -Addon bitcoinmining` after port |

### Your loop (Designer)

1. Open **`Assets/.../bitcoinmining/ui/sui/hashd-hub-ui.sui`** in Sbox UI Designer.
2. Edit layout — drag anchors, swap images (e.g. `ui/hashd/btc.png`), tune Details panel.
3. **Compile** (`Ctrl+B`) → output lands in `Code/_sui_scratch/hashd_hub_ui/` (never overwrites ship files).
4. **Test in Play** — bundled preview scene; confirm spacing and images.
5. When happy, pull to repo:

```powershell
powershell -File lifepunch\scripts\Pull-DxrpUiDesignerToRepo.ps1 -IncludeScratch
```

6. Tell the agent what changed (or say “port latest designer pass”) — agent merges structure/CSS into `LpHashdPanel.razor` + `.razor.scss` and keeps all `@code`.

### Agent loop (port)

1. Read pulled `.sui` + `Code/_sui_scratch/hashd_hub_ui/HashdHubUiLayout.razor(.scss)`.
2. Copy **class names, hierarchy, sizes, colors, image paths** into ship files.
3. **Do not** replace ship `.razor` with generated file wholesale — preserve `@if`, `@foreach`, `onclick`, sync bindings.
4. Sync repo → DXRP; hotload; `lp_bitcoin_preview_hub` screenshot proof.

### Critical: sync direction

| Command | Direction | When |
|---------|-----------|------|
| `Pull-DxrpUiDesignerToRepo.ps1` | DXRP → repo | **After every Designer session** before git or agent port |
| `Sync-LifePunchAddonsToDxrp.ps1` | repo → DXRP | After agent port — **wipes unsaved DXRP-only edits** |

**Never** run repo → DXRP sync while you still have un-pulled Designer work in the editor tree.

### Canvas size (must match ship panel)

**Do not use 1920×1080** for `hashd-hub-ui.sui`. The live hub uses **`lp-ui-size-l` = 1080×660** (`LpUiScale.scss`).

| Setting | Value |
|---------|--------|
| Canvas **Base Width / Height** | **1080 × 660** |
| **Scale Mode** | **Fixed Resolution** (not Screen Height 1080) |
| Root + Shell | Both **1080×660**, shell anchor **Top Left** (not centered in a fake fullscreen) |

`ScreenHeight1080` + a 1920 canvas scales the whole document like a fullscreen HUD — the 1080×660 menu floats inside it and **Test in Play** stacks layout wrong.

### Mutual-exclusive states (Razor `@if` → Designer toggles)

Ship Razor shows **one** of PIN / hub body and **one** tab pane. SUI compiles **all** nodes unless you collapse extras:

| What | Default in SUI | To edit |
|------|----------------|---------|
| PIN gate | `HiddenInDesigner` + **Visibility: Collapsed** | Show PIN, collapse `hub_body` |
| Hub body | Visible | Default overview editing |
| Tab panes | Only **Overview** visible | Collapse overview, show Wallet/Racks/Settings |

In Details → **Visibility: Collapsed** = `display: none` in compiled preview (matches Razor hiding). **Hidden in designer** only skips designer flex layout — it does **not** hide Test in Play by itself.

### Shared assets (e.g. BTC logo)

| File | Role |
|------|------|
| `ui/hashd/btc.png` | Transparent mark — sidebar + PIN (Designer **Image** or ship `.brand-mark` CSS) |
| `ui/hashd/btc-mark.png` | Legacy matte PNG — keep until all refs retired |

Image path in Designer: `addons/lifepunch/bitcoinmining/ui/hashd/btc.png` (leading `/` optional in SUI).

---

## Paths (LifePunch + DXRP)

| What | Repo (source of truth) | DXRP editor (mirror) |
|------|------------------------|----------------------|
| Addon Razor / SCSS | `lifepunch/addons/Code/Addons/lifepunch/<ident>/` | `…/dxrp/game/Code/Addons/lifepunch/<ident>/` |
| `.sui` documents (your choice) | `lifepunch/addons/Assets/addons/lifepunch/<ident>/ui/sui/` *(recommended)* | same under DXRP `Assets/` after sync/copy |
| SUI compile output (scratch) | — | `dxrp/game/Code/_sui_scratch/<panel>/` **first** |
| Ship target after port | `lifepunch/addons/Code/…/<Panel>.razor` | synced via `Sync-LifePunchAddonsToDxrp.ps1` |

**Pull designer work back (after UI Designer sessions):**

```powershell
powershell -File lifepunch\scripts\Pull-DxrpUiDesignerToRepo.ps1 -IncludeScratch
```

**Sync before editor work (repo → DXRP — overwrites un-pulled DXRP edits):**

```powershell
powershell -File lifepunch\scripts\Sync-LifePunchAddonsToDxrp.ps1 -Addon bitcoinmining
```

**Launch editor:**

```powershell
powershell -File lifepunch\scripts\Start-SboxDxrpEditor.ps1 -PreflightFix -BitcoinOnly
```

---

## Quick start (first session)

1. Open **DXRP** (`rp.sbproj`).
2. Asset Browser → open **`Assets/addons/lifepunch/bitcoinmining/ui/sui/hashd-chrome-layout.sui`** (pre-built HASHD chrome — or create your own via **New → Sbox UI Document**).
3. Store under `Assets/addons/lifepunch/bitcoinmining/ui/sui/` (create folder if needed).
4. Double-click `.sui` → **Sbox UI Designer** opens.
5. **Tools → Install Sample Documents** → open `hud_survival.sui` or `simple_panel.sui` to learn anchors.
6. Design shell only: top bar, tab row, content placeholder — **no** `@foreach` / wallet logic in SUI.
7. **Compile** (`Ctrl+B`) → output folder = `Code/_sui_scratch/hashd_chrome/` (scratch, not ship path).
8. **Test in Play** — bundled preview scene mounts UI on a ScreenPanel.
9. Port layout classes/structure into `LpHashdPanel.razor` + `.razor.scss`; keep all `@code` and host bindings in repo files.
10. Add proprietary header to any committed `.razor` before git commit.

---

## Scratch → port workflow (do not overwrite ship files)

```text
.sui (layout only)
    ↓ Compile (Ctrl+B) → Code/_sui_scratch/…
    ↓ Test in Play
    ↓ Copy structure + class names into repo Panel.razor
    ↓ Merge @code / Hub / DXRP host from existing file
    ↓ Add LifePunch proprietary header
    ↓ Sync-LifePunchAddonsToDxrp.ps1
    ↓ chomnr hotload or host play proof
```

### Rules

- **Never** compile SUI directly onto `StaffMenu.razor`, `LpHashdPanel.razor`, or `HackerTerminal.razor` on first pass — compile refuses non-`SUI:GENERATED` files or wipes logic.
- Use **`<name>.User.scss`** (SUI creates once) for HASHD amber glow, CRT chrome, hover polish SUI does not own.
- Generated files carry `SUI:GENERATED` — treat as reference, not ship artifacts, unless you fully commit to SUI-owned panels.

---

## Editor UI map

| Area | Purpose |
|------|---------|
| **Palette** | Drag Panel, Label, Button, ProgressBar, … |
| **Hierarchy** | Reparent, F2 rename, drag reorder |
| **Details** | Anchor 3×3, size, colors, text |
| **Compile** (`Ctrl+B`) | Validator + write Razor/SCSS + manifest |
| **Test in Play** | Real play mode preview (preferred over modal Preview) |
| **Compile Results** | Generated / Skipped / Preserved / Conflicts |

**Canvas:** middle-mouse pan, wheel zoom, `Ctrl+0` fit, snap grid optional.

---

## LifePunch panel targets (priority)

| Panel | SUI fit | Notes |
|-------|---------|-------|
| **`hashd-chrome-layout.sui`** | **Ready** | `Assets/.../bitcoinmining/ui/sui/hashd-chrome-layout.sui` — HASHD hub chrome shell (900×600) |
| **`hashd-hub-ui.sui`** | **Your working copy** | Full LpHashdPanel layout mirror — edit in UI Designer; hand back for port into `LpHashdPanel.razor`. Regenerate from Razor: `python lifepunch/addons/scripts/build-hashd-hub-ui-sui.py` |
| `LpHashdPanel` | Chrome shell + nav rail | Logic stays in repo; see TAILWAND pilot for utilities |
| `LpBitcoinTerminalPanel` | CRT frame + boot splash layout | Typed command logic stays hand-written |
| `StaffMenu` | Tab rail + profile pane layout | Large `@code` — SUI for subsection prototypes only |
| `HackerTerminal` | CRT + puzzle chrome | Fix `UI-ENGINE-01` lowercase root class when porting |

---

## MCP + play proof

| Step | Tool |
|------|------|
| Compile errors | `sbox-editor` → `code_get_compile_errors` |
| Hotload markup | `sbox-editor` → `trigger_hotload` |
| Open hub UI | `sbox` → `console_run` → `lp_bitcoin_preview_hub` |
| Screenshot | `sbox` → `take_screenshot` |

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| CS0111 duplicate `BuildRenderTree` | Tools → **Clean All SUI Caches**; remove orphan generated razors in `Code/` |
| Compile conflict | Output path hits hand-written `.razor` — change scratch output folder |
| Styles silent-skip | Root SCSS selector must be **lowercase class** (`.hashd-terminal`), not PascalCase component name |
| Preview blank | Compile Results errors → Tools → Regenerate Preview |

---

## Related docs

- [TAILWAND.md](./TAILWAND.md) — utility CSS on Razor (HASHD chrome pilot)
- [BITCOIN_GREENFIELD_REBUILD.md](./BITCOIN_GREENFIELD_REBUILD.md) — optional `SuiDocument.*` MCP tools
- [CVL_FULL_CAPACITY_UPDATES.md](../../docs/CVL_FULL_CAPACITY_UPDATES.md) — library update routine
