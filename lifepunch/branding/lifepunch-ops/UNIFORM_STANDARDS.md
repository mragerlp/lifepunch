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
| **Explorer icons (all nodes)** | `Desktop\uniforms\PNGs\grayfoldericon.png` · `graynotes.png` · `recyclebin2.png` |
| **PowerShell prompt thumbnail (all nodes)** | `Desktop\uniforms\PNGs\powershell-prompt-thumbnail.png` |
| Desktop shortcut tier icons | `lifepunch/branding/shortcut-icons/` (tri-stack / red / green / blue) |

---

## Explorer icons (all nodes — mandatory)

Same gray minimalist art on **every** machine:

| Repo file | OneDrive source | Role |
|-----------|-----------------|------|
| `icons/lifepunch-folder.png` | `uniforms\PNGs\grayfoldericon.png` | Default **folder** icon |
| `icons/lifepunch-txt.png` | `uniforms\PNGs\graynotes.png` | Default **`.txt`** icon |
| `icons/lifepunch-recycle-bin.png` | `uniforms\PNGs\recyclebin2.png` | Desktop **Recycle Bin** (biohazard bin art) |
| `icons/powershell-prompt-thumbnail.png` | `uniforms\PNGs\powershell-prompt-thumbnail.png` | **PowerShell** tab icon (Windows Terminal) + outfit `*console.png` reference |

**Scripts:** `Set-LifePunchExplorerIcons.ps1` + `Set-PowerShellPromptThumbnail.ps1` (steps in `Apply-LifePunchOpsConsole.ps1`).

**Windows 11 (June 2026):**

- `.txt` — override UserChoice ProgId (often Notepad `AppX…`), `txtfilelegacy`, and
  `SystemFileAssociations\.txt`.
- **Folders** — HKLM `Shell Icons` **3** + **4** (UAC once); `Folder` / `Directory` /
  `LibraryFolder` DefaultIcon; `IconsOnly=1`.
- **Recycle Bin** — Shell Icons **31** (empty) + **32** (full); Recycle Bin CLSID
  `{645FF040-5081-101B-9F08-00AA002F954E}` DefaultIcon.
- Published: `Documents\LifePunch-Icons\lifepunch-folder.ico` · `lifepunch-txt.ico` ·
  `lifepunch-recycle-bin.ico`

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
Config/path hints (`server-host-watch`, `status-token`, etc.) use `Write-VoiceMuted` (white).
Cornerman `relay_ui.py` mirrors the same contrast.

**PowerShell prompt thumbnail:** retro pixel desktop — **same art on every node** (node color stays
in the prompt text + title bar). `Set-PowerShellPromptThumbnail.ps1` builds
`icons/powershell-prompt-thumbnail.ico` and wires it into Windows Terminal PowerShell profiles.

**Console palettes** (`windows-terminal-*.json` + `Set-ConhostUniform`): default text is **gray**;
`white` slot is **#FFFFFF** (not accent — old schemes mapped White→red and broke `Write-Host`).
Accent stays on cursor + banner rules only. Repair without full uniform:

`Apply-LifePunchOpsConsole.ps1 -Machine vengeance -ConhostOnly`

Then open a **new** Terminal tab (existing tabs keep the old scheme).
