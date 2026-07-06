# Cornerman — off-Cursor handoff (June 2026)

> **SUPERSEDED for MCP full capacity (June 2026):** Green **must** run Cursor with triple MCP
> (`sbox` + `sbox-editor` + `cornerman-lm`). Use `Restore-CornermanDualStack.ps1` from Red.
> This doc remains for **git lane** law (Red commits; Green distill/outbox only).

**Status:** Green may run Cursor again for **dual-stack MCP**; Red still owns **all git commits**.  
**Cornerman role:** Tier-3 distill, voice/PTT, optional second Cursor — **not** integrate commits.

**Eyes covered (law):** If something covers Green's eyes, say so to the owner — same as Cursor agents.
Green has **no** Claude Bridge and **no** view of the editor unless the owner sends a screenshot or
RDPs in. Distills and Qwen drafts are **not** eyes. On visual/playtest/spawn/scale questions, lead with:
**Cornerman's eyes are covered** — I only have [inbox / repo / distill], not your screen or the game.

---

## What changed

| Before | Now |
|--------|-----|
| Green commits locally → `Pull-CornermanPatches.ps1 -Push` | Red commits directly on VENGEANCE → `git push origin main` |
| Cornerman Cursor agents distill docs | Red absorbs distill; Cornerman reads **inbox** only if owner assigns manual/Odysseus work |
| `git pull --rebase` on `C:\Projects\lifepunch` after every Red push | Green clone **optional** — `git reset --hard origin/main` when touching files on box |

---

## Cornerman box — if owner still uses it

1. **Sync clone** — desktop shortcut **`Cornerman (Sync from Red)`** (green tier icon, same naming as `Cornerman (RDP)`).
   - Launcher: `C:\Projects\cornerman-rag\Cornerman (Sync from Red).cmd`
   - Red deploys shortcut + files from VENGEANCE: `powershell -File lifepunch\scripts\Push-CornermanResetScript.ps1`
   - **When:** after Red pushed `main`; clone behind; stuck rebase/merge; before reading inbox docs that cite repo paths.
   - **Never:** when Green has local commits you need to keep (Green should not commit — Red owns git).
2. **Read inbox:** `C:\lifepunch\cornerman\inbox\CORNERMAN_OFF_CURSOR_HANDOFF.md` (this file, pushed by Red)
3. **Do NOT** expect Cursor agents or automatic commits.
4. **Model (LM Studio):** default **distill** (`qwen/qwen3.6-35b-a3b`). Switch to **Qwen 2.5 Coder** only when the inbox brief says `WarmCoder` — see `CORNERMAN_MODEL_ROUTING.md`. Red runs `Send-CornermanWorkflow.ps1 -Action WarmCoder` before C#/Razor draft tasks.
5. **Optional (no Cursor):** copy `outbox/` mirrors into Odysseus/RAG; run PTT relay per `CORNERMAN_PUSH_TO_TALK.md`.

---

## Closed on Red (no Green action)

| Item | Commit area |
|------|-------------|
| BitcoinMiningAddon three-entity arch + registry | `dfd2f18` |
| BitcoinMiningAddon G1–G3 (protection, portal listing, player UX) | `3b92de8` |
| ULX v2 staff menu polish | `63b87e8` |
| AK47 CS2 study distill | `3954155` |
| Hacker/coke/deagle protection scaffolds | `670fdee` |

---

## Cornerman active queue (Green — same sprint as Red)

| Priority | Task | Model | Brief / output |
|----------|------|-------|----------------|
| **P0** | **Inventory project (Visible Pocket)** | **distill** | `CORNERMAN_INVENTORY_PROJECT_TASK.md` → `outbox/VISIBLE_POCKET_*` |
| P0a | llad UI study (not ship) | distill | `LLAD_MODULAR_INVENTORY_STUDY.md` → `VISIBLE_POCKET_UI_NOTES.txt` |
| P0b | Hotbar HUD scss draft | **coder** (when Red assigns) | task 6 in inventory brief |
| — | Deagle / coke / hacker | distill | **backlog** — `CORNERMAN_WORK_QUEUE.md` |

Red warms **distill** before Green inventory session: `Send-CornermanWorkflow.ps1 -Action WarmDistill`.

---

## Red active queue (VENGEANCE)

| Priority | Task | Doc |
|----------|------|-----|
| **P0** | Visible Pocket POCKET-01 + play-test | `RED_VENGEANCE_VISIBLE_POCKET_BUILD.md` |
| **P0** | BitcoinMiningAddon RGB shader (editor) | `RGB_FAN_LED_SHADER.md` |
| **P1** | BitcoinMiningAddon Phase 2 module UI | `RED_BITCOINMINING_PHASE2_BUILD.md` |
| **P2** | Owner ModelDoc: terminal + stacked `_c` | `BITCOINMINING_FINISH_RUNBOOK.md` |
| **P3** | Hacker Phase 2 Opus | `RED_HACKER_JOB_BUILD.md` |

---

## Optional Cornerman (manual / Odysseus — no Cursor)

| Task | Input | Output |
|------|-------|--------|
| Inventory distill batch | Inbox after `Push-CornermanInventoryProject.ps1` | `outbox/VISIBLE_POCKET_DXRP_SUMMARY.txt` etc. |
| RAG refresh | Pull `main`, read spec + discovery | Mirror to `outbox/` |
| Voice tests | `Send-CornermanWorkflow.ps1 -Action StartVoiceRelay` | PTT smoke only |

**Do not** commit C#, Razor ship code, ModelDoc, or push git from Green.

---

## Red push inbox to Cornerman

```powershell
cd C:\Users\jared\Projects\lifepunch\lifepunch\scripts
.\Push-CornermanInventoryProject.ps1
.\Send-CornermanWorkflow.ps1 -Action WarmDistill
.\Push-CornermanOffCursorHandoff.ps1
```

---

## Related

- `CORNERMAN_IDLE_FOLDER.md` — **primary handoff while VENGEANCE is offline** (idle export, no push)
- `LOCAL_AI_WORKSTATION.md` §7c (patch handoff — legacy when Cursor returns)
- `BITCOINMINING_FINISH_RUNBOOK.md`
- `lifepunch/docs/AGENT_PROMPT.md` Block 0 sync
