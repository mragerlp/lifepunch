# Cornerman session — 2026-06-13 (shutdown 4:00 PM EST)

**Owner away.** Hard stop **4:00 PM EST**. **Export to idle at 3:50 PM EST** — **no `git push`** to `main`.

See `CORNERMAN_IDLE_FOLDER.md` (inbox) or `lifepunch/docs/CORNERMAN_IDLE_FOLDER.md`.

---

## 3:50 PM EST — idle export ritual (MANDATORY)

```powershell
cd C:\Projects\lifepunch
git fetch origin
git status

# Prefer inbox copy (VENGEANCE may be offline — clone may lack latest script):
powershell -File C:\lifepunch\cornerman\inbox\Export-CornermanIdle.ps1 `
  -SessionLabel menu-ui-2026-06-13 `
  -Summary "P0 menu SCSS + PIN; see SESSION_SUMMARY.md in idle folder"
```

**Do NOT** `git push origin main` — Red reviews idle and merges on VENGEANCE later.

**Local commits OK** on read-only clone; export copies `patches/` if `origin/main..HEAD` has commits.

**Outbox:** export writes `C:\lifepunch\cornerman\outbox\IDLE_READY.txt` with session folder path.

**After export:** update progress table | 3:50 | idle `<folder>` — menus pass/fail |

---

## Schedule (fill start time when you begin)

| Window | Lane | Task |
|--------|------|------|
| 0:00–1:30 | **P0** | Menu UI — validator green, GATEKEEPER PIN, power row, settings cog |
| 1:30–2:30 | **P1** | Addon code/docs below (pick by skill) |
| 2:30–3:30 | **P2** | Distill / audit / playtest matrix |
| **3:30–3:50** | **STOP coding** | `git status`, run `Export-CornermanIdle.ps1`, fill progress log |
| **4:00** | **SHUTDOWN** | No new tasks |

---

## P0 — Menu UI (must ship or document blocker)

See `CORNERMAN_MENU_UI_FIX_2026-06-13.md` + `SBOX_RAZOR_SCSS_RULES.md`.

```powershell
powershell -File lifepunch\addons\scripts\Validate-SboxRazorScss.ps1
```

**Pass:** bitcoin hub GATEKEEPER → numpad → hub panel; hacker rack PIN; zero `not valid with` in log.

---

## P1 — Additional addon work (code — VENGEANCE / Cursor only)

| ID | Addon | Task | Files | Est |
|----|-------|------|-------|-----|
| A1 | **hackerjob** | Fix CRT gradients breaking SCSS | `HackerTerminal.razor.scss` ~118–129 → solid `background-color` | 20m |
| A2 | **bitcoinmining** | Playtest doc — SCSS forbidden table | `BITCOINMINING_PLAYTEST.md` § log triage | 15m |
| A3 | **bitcoinmining** | Protection grep (no fork) | `BITCOINMINING_PROTECTION_CHECKLIST.md` or `docs/handoff/cornerman-outbox/PROTECTION_GREP_CYBER_2026-06-11.md` pattern | 30m |
| A4 | **adminmenu** | STAFF-09 namespace hygiene | `StaffMenuTestBots.cs` → `LifePunch.DXRP.Addons.StaffMenu` | 15m |
| A5 | **bitcoinmining** | `lp_hashd_pin_preview` smoke note in playtest | already in doc — verify commands work, log result | 15m |
| A6 | **visiblepocket** | Remove/guard dev ConCmd if still in publish path | grep `lp_pocket` · `TECH_DEBT.md` POCKET-01 | 20m |

**Do NOT (Red/owner only):** ModelDoc compile, `prepare-publish.ps1` ship, economy C# (HACKER-01/02), RGB shader compile.

---

## P2 — Distill / audit (Green Qwen OK — output to `outbox/`)

| ID | Task | Brief | Deliverable |
|----|------|-------|-------------|
| D1 | Bitcoin sound shortlist | `CORNERMAN_BITCOINMINING_SOUNDS_TASK.md` | `outbox/BITCOINMINING_SOUND_SHORTLIST.md` refresh |
| D2 | Hacker terminal flow | `CORNERMAN_HACKER_JOB_TERMINAL_TASK.md` | `outbox/HACKER_TERMINAL_FLOW_NOTES.md` one-pager |
| D3 | Menu session audit | This session | `outbox/MENU_SCSS_AUDIT.txt` + `MENU_PLAYTEST_RESULT.txt` |
| D4 | Bitcoin job Market copy | `CORNERMAN_BITCOINMINING_JOB_SOLIDIFICATION_TASK.md` | `outbox/BITCOINMINING_PORTAL_BLURB_DRAFT.md` |
| D5 | Cyber ecosystem table | `CORNERMAN_CYBER_ECOSYSTEM_TASK.md` | encryption hub vs rack vs terminal matrix |

**Model:** `Send-CornermanWorkflow.ps1 -Action WarmDistill` (docs) · `WarmCoder` (SCSS drafts only).

---

## P3 — If everything above is green (bonus, time-boxed)

| ID | Task |
|----|------|
| B1 | Run `scripts/validate-workspace.ps1` — log pass/fail (STAFF-09 may still fail) |
| B2 | `lifepunch/addons/scripts/validate-layout.ps1` for bitcoinmining + hackerjob |
| B3 | Draft `BITCOINMINING_PHASE2` wireframe notes — `CORNERMAN_BITCOINMINING_PHASE2_MENU_TASK.md` |
| B4 | Hacker `server-rack` ModelDoc **checklist only** — no compile on Green |

---

## Ignore (console noise)

- `CS8669`, `CS8603`, `CS8618`, `CS0612`, `CS0618` — warnings, not menu blockers.
- `server-rack.vmat_c` missing — asset compile on VENGEANCE later.
- `improved_atm` prefab spam — DXRP map noise.

---

## Push inbox (Red runs once before owner left)

```powershell
powershell -File lifepunch\scripts\Push-CornermanSession20260613.ps1
```

---

## Progress log

| Time (EST) | Done |
|------------|------|
| | |
| **3:50** | **idle export** (no push) |
| **4:00** | shutdown |
