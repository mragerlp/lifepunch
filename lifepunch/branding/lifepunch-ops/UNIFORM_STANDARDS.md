# LifePunch web — uniform standards

**At a glance, not a telescope.** Every node in the LifePunch web (VENGEANCE, Cornerman,
lifepunchnet) wears the same visual language so humans and agents know **where they are** and
**what failed** without archaeology.

OneDrive canonical copy: `%USERPROFILE%\OneDrive\Desktop\uniforms\UNIFORM_STANDARDS.md`

---

## Canonical art roots (OneDrive)

| Asset class | OneDrive source |
|-------------|-----------------|
| Per-node outfits (console, banner, app icon) | `Desktop\Hacker Job\<tier>\<machine>\` |
| Desktop wallpapers (HUD layout, per-node color) | `Desktop\wallpapers\` |
| **Explorer icons (all nodes)** | `Desktop\uniforms\PNGs\grayfoldericon.png` · `graynotes.png` |
| Desktop shortcut tier icons | `lifepunch/branding/shortcut-icons/` (tri-stack / red / green / blue) |

---

## Explorer icons (all nodes — mandatory)

Same gray minimalist art on **every** machine:

| Repo file | OneDrive source | Role |
|-----------|-----------------|------|
| `icons/lifepunch-folder.png` | `uniforms\PNGs\grayfoldericon.png` | Default **folder** icon |
| `icons/lifepunch-txt.png` | `uniforms\PNGs\graynotes.png` | Default **`.txt`** icon |

**Script:** `Set-LifePunchExplorerIcons.ps1` (step in `Apply-LifePunchOpsConsole.ps1`).

**Windows 11 (June 2026):**

- `.txt` — override UserChoice ProgId (often Notepad `AppX…`), `txtfilelegacy`, and
  `SystemFileAssociations\.txt`.
- **Folders** — HKLM `Shell Icons` **3** + **4** (UAC once); `Folder` / `Directory` /
  `LibraryFolder` DefaultIcon; `IconsOnly=1`.
- Published: `Documents\LifePunch-Icons\lifepunch-folder.ico` · `lifepunch-txt.ico`

**Refresh:**

```powershell
cd <repo>\lifepunch\branding\lifepunch-ops
powershell -ExecutionPolicy Bypass -File .\Sync-OutfitsFromOneDrive.ps1
powershell -ExecutionPolicy Bypass -File .\Set-LifePunchExplorerIcons.ps1
```

---

## Desktop shortcut icons (VENGEANCE)

See `lifepunch/branding/shortcut-icons/SHORTCUT_ICONS.md` and
`.cursor/rules/lifepunch-shortcut-icons.mdc`.

---

## Per-node console uniform

See `OUTFITS.md` and `lifepunch/docs/OPS_CLARITY_CHECKPOINT.md` §3.

**VENGEANCE voice / ops windows** (`Voice-Console.ps1`): black/dark background + **node accent** on
title rules only. Body text is **gray labels + white values** — never `DarkGray` on black (unreadable).
Muted hints use `Write-VoiceMuted` (gray). Cornerman `relay_ui.py` mirrors the same contrast.
