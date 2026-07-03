# CVL OFFLOAD SIGNAL — when to spin up Cornerman (Green B)

> **Bloodwave gets a Windows toast** on VENGEANCE when Red agents hit an offload trigger.
> **Party flatgrass testing = Red only — no toast.**

---

## Signal delivery (VENGEANCE)

When any trigger below fires, Red agents **must**:

1. Run: `powershell -File lifepunch\scripts\Send-CvlOffloadSignal.ps1 -Reason "<one line why>"`
2. Post in chat: **`OFFLOAD SIGNAL — Cornerman`** + the same one-line reason
3. **Stop** starting heavy implementation on Red unless Bloodwave says stay on Red

Toast title: **`CVL — OFFLOAD TO CORNERMAN`** (long duration, warning tone).

---

## OFFLOAD — spin up Cornerman (Cursor/Copilot optional + LM)

| Trigger | Example |
|---------|---------|
| **GREEN CODE** / **GROK REQUIRED** route tag on a bounded slice | Repo audit, ModelDoc map, 3–8 file candidate |
| **Red is in editor/playtest** and agent wants parallel implementation | You're testing `/party`; agent has a separate doc/distill slice |
| **Distill / handoff kit** from long transcript | Architect continuity rebuild, baton prep, inbox distill |
| **Heavy agent run** expected **>15 min** and **no flatgrass proof** in that slice | Refactor pass, checklist sweep, bulk doc reconciliation |
| **Tier-3 only** work | Green Deep / Green Daily report; no s&box eyes needed |
| **Red compile/editor blocked** but bounded Cornerman clone work exists | Sync + patch-handoff while you stay in Host Play |

**Cornerman minimum to start:** LM Studio serve + watchdog (Tier-3). Add **Cursor/Copilot** only when you want **Green Code candidates** reviewed on Red.

---

## NO OFFLOAD — stay on Red (no toast)

| Situation | Why |
|-----------|-----|
| **Manual flatgrass proof** | Party `/party`, staff menu, bitcoin USE — your eyes only |
| **Screenshot / visual sign-off** | Cornerman is eyes-covered |
| **Owner GO / commit / push gate** | Bloodwave must approve on Red |
| **Routine AUTO OK** single-file fix | Burn Composer on Red |
| **Opus architecture** on active lane | Tier-1 stays on Red unless you explicitly split plan vs implement |
| **Cornerman SSH/LM down** | Fix connectivity first; don't pretend offload exists |

---

## After toast — Bloodwave choices

1. **Ignore** — stay on Red; tell agent "stay on Red"
2. **LM only** — Cornerman distill; no Cursor
3. **Full Green B** — RDP Cornerman, pull branch, Cursor/Copilot for candidates → patch-handoff to Red
4. **Defer** — note in baton; offload later

---

## Quick command

```powershell
# Agent fires when trigger hits:
powershell -File lifepunch\scripts\Send-CvlOffloadSignal.ps1 -Reason "Distill party test notes while owner in flatgrass"

# Bloodwave test toast (verify notifications work):
powershell -File lifepunch\scripts\Send-CvlOffloadSignal.ps1 -Reason "TEST — offload signal armed" -Test
```

**Canon:** `GREEN_EXECUTION_MODEL.md` · `CVL_AGENT_ONBOARDING.md` §4–§7
