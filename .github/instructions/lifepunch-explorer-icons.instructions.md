---
applyTo: "**"
description: "LifePunch uniform Explorer icons (gray folder + gray .txt on all web nodes)"
sourceRule: ".cursor/rules/lifepunch-explorer-icons.mdc"
---

> **Synced from** `.cursor/rules/lifepunch-explorer-icons.mdc` â€” edit source there, then re-run `Sync-CursorRulesToCopilotInstructions.ps1`.

# LifePunch Explorer icons (web uniform)

Canonical standards: `OneDrive\Desktop\uniforms\UNIFORM_STANDARDS.md` (repo mirror:
`lifepunch/branding/lifepunch-ops/UNIFORM_STANDARDS.md`).

## Art (OneDrive → repo)

| OneDrive | Repo |
|----------|------|
| `Desktop\uniforms\PNGs\grayfoldericon.png` | `lifepunch-ops/icons/lifepunch-folder.png` |
| `Desktop\uniforms\PNGs\graynotes.png` | `lifepunch-ops/icons/lifepunch-txt.png` |

Sync: `Sync-OutfitsFromOneDrive.ps1` copies PNGs; `Set-LifePunchExplorerIcons.ps1` builds ICOs
and applies registry on **vengeance, cornerman, lifepunchnet**.

## Windows 11 folder icons

- **HKLM** `Shell Icons` keys **3** and **4** — required; script prompts UAC via `reg import`.
- **HKCU** `Folder` / `Directory` / `LibraryFolder` `DefaultIcon`.
- **IconsOnly = 1** — avoid imageres 3D folder thumbnails masking custom icons.

## Windows 11 .txt icons

Override live **UserChoice** ProgId (often Notepad `AppX…`), plus `txtfilelegacy` and
`SystemFileAssociations\.txt` — not only `txtfile`.

## Apply

```powershell
cd lifepunch\branding\lifepunch-ops
powershell -ExecutionPolicy Bypass -File .\Set-LifePunchExplorerIcons.ps1
# or full uniform:
powershell -ExecutionPolicy Bypass -File .\Apply-LifePunchOpsConsole.ps1 -Machine <node>
```

Published ICOs: `%USERPROFILE%\Documents\LifePunch-Icons\lifepunch-folder.ico` · `lifepunch-txt.ico`
