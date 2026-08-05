# MacOS Kit Runtime Worth — Implementation Plan

> **For agentic workers:** Execute task-by-task. Local editor tree only unless Bloodwave GO for commit.

**Goal:** Prove MacOS Codex menu kit has runtime/preview worth on VENGEANCE.  
**Architecture:** Overlay Hub-Final + Tags into `lifepunchdxrp` Code/Addons; browser-open Wallet preview; write proof pack.  
**Tech stack:** PowerShell copy, s&box host play + Claude Bridge screenshots, browser preview.

**Spec:** `lifepunch/docs/superpowers/specs/2026-08-05-macos-kit-runtime-worth-design.md`

## Tasks

### Task 1: Backup + overlay Hub-Final

- Backup `lifepunchdxrp/game/Code/Addons/lifepunch/playerhub` → `_quarantine/2026-08-05/playerhub-pre-macos`
- Copy Mac `LifePunch-Hub-Final/PLAYERHUB/*` → that playerhub path
- Also mirror into monorepo `lifepunchaddons/.../playerhub` for source consistency (local, no commit)

### Task 2: Mount Tags

- Create `.../Code/Addons/lifepunch/lifepunchtags/` with Mac `lifepunchtags/code/**` and README
- Mirror into `lifepunchaddons` the same way
- Ensure `LIFEPUNCH_LOCAL` already defined in addons.csproj (it is)

### Task 3: Compile settle

- Hotload or `-ReplaceExisting -NoSync` relaunch if needed
- Capture compile errors; fix only trivial blockers or quarantine Tags if non-trivial

### Task 4: Runtime captures

- `playerhub`, `lifepunchtags`/`tags`, `lp_bitcoin_preview_hub`
- Copy PNGs to handoff folder

### Task 5: Wallet browser proof

- Start static server or `Start-Process` index.html
- Screenshot / copy existing `lifepunch-wallet-preview.png` + live capture if possible

### Task 6: Matrix + SUMMARY.md in handoff folder
