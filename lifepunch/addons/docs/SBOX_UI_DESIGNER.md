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

**Canon:** `.sui` is source of truth → generated `.razor` / `.razor.scss` are **disposable**. LifePunch **repo** `.razor` files are ship truth after you port logic.

---

## Paths (LifePunch + DXRP)

| What | Repo (source of truth) | DXRP editor (mirror) |
|------|------------------------|----------------------|
| Addon Razor / SCSS | `lifepunch/addons/Code/Addons/lifepunch/<ident>/` | `…/dxrp/game/Code/Addons/lifepunch/<ident>/` |
| `.sui` documents (your choice) | `lifepunch/addons/Assets/addons/lifepunch/<ident>/ui/sui/` *(recommended)* | same under DXRP `Assets/` after sync/copy |
| SUI compile output (scratch) | — | `dxrp/game/Code/_sui_scratch/<panel>/` **first** |
| Ship target after port | `lifepunch/addons/Code/…/<Panel>.razor` | synced via `Sync-LifePunchAddonsToDxrp.ps1` |

**Sync before editor work:**

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
