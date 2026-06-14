# Cornerman idle folder — staged handoff (no direct push)

**June 2026.** VENGEANCE may be offline while Cornerman works. **Do not `git push origin main`**
from Green unless Jared explicitly says so in-session.

All Cornerman output lands in **`C:\lifepunch\cornerman\idle\`** for Red to review and merge later.
This avoids setbacks from unverified SCSS/UI changes hitting `main` while the owner is away.

---

## Layout

```text
C:\lifepunch\cornerman\idle\
  sessions\
    2026-06-13T1550-menu-ui\
      MANIFEST.json          ← machine-readable index
      SESSION_SUMMARY.md     ← human checklist (fill before export)
      repo\                  ← changed files, paths mirror monorepo (lifepunch/...)
      outbox\                ← distill/audit copies from cornerman\outbox this session
      logs\                  ← git status, validator, playtest notes
      patches\               ← git format-patch (if clone had local commits)
```

**One session = one folder.** Never overwrite an existing session folder.

---

## Cornerman workflow

1. **Read inbox** (`CORNERMAN_SESSION_*.md`, directives).
2. **Work** in clone `C:\Projects\lifepunch` (read-only push key — commits OK locally, push not).
3. **Distill** → `C:\lifepunch\cornerman\outbox\` as today.
4. **3:50 PM EST (mandatory):** run export — **not** push:

```powershell
powershell -File C:\lifepunch\cornerman\inbox\Export-CornermanIdle.ps1 `
  -SessionLabel menu-ui-2026-06-13 `
  -Summary "P0 menu SCSS + PIN; see SESSION_SUMMARY.md"
```

5. **4:00 PM EST:** shutdown. Leave idle folder on disk.

---

## VENGEANCE workflow (when owner returns)

```powershell
# From lifepunchaddons repo on VENGEANCE:
powershell -File lifepunch\scripts\Pull-CornermanIdle.ps1
# Review: %USERPROFILE%\OneDrive\Lifepunch\cornerman-idle-review\<session>\
# Or: C:\lifepunch\cornerman-idle-review\ if OneDrive path missing
```

Red applies only after:
- `Validate-SboxRazorScss.ps1` green on pulled files
- Spot-check SESSION_SUMMARY + MANIFEST
- Playtest on VENGEANCE if UI touched

**Merge options:** manual copy, `git apply`, or `git am` from `patches/` — never blind `git pull` from Green clone.

---

## What goes in idle vs outbox

| Destination | Content |
|-------------|---------|
| `outbox/` | Distills, audits, Qwen drafts (RAG fodder) |
| `idle/sessions/.../repo/` | **Candidate ship files** — SCSS, razor, cs, docs Red might merge |
| `idle/sessions/.../logs/` | Validator output, `git status`, playtest pass/fail |
| `idle/sessions/.../patches/` | Optional local commits from Green clone |

---

## Session end checklist (Cornerman)

- [ ] `Validate-SboxRazorScss.ps1` run; output in `logs/`
- [ ] `SESSION_SUMMARY.md` filled (pass/fail per task, blockers)
- [ ] `Export-CornermanIdle.ps1` completed; path printed
- [ ] **No** `git push` to GitHub
- [ ] Ping file: `outbox\IDLE_READY.txt` with session folder name

---

## Related

- Patch handoff (legacy): `LOCAL_AI_WORKSTATION.md` §7c
- Off-Cursor doctrine: `CORNERMAN_OFF_CURSOR_HANDOFF.md`
- Menu session: `handoff/cornerman-outbox/CORNERMAN_SESSION_2026-06-13.md`
