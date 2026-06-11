# Cornerman — off-Cursor handoff (June 2026)

**Status:** Green box **no longer runs Cursor.** Red (VENGEANCE) owns git, C#, ModelDoc coordination, and urgent docs.  
**Cornerman role:** Voice/PTT relay, optional local RAG ingest, file mirror — **not** code commits or patch handoff unless owner revives Cursor on Green.

---

## What changed

| Before | Now |
|--------|-----|
| Green commits locally → `Pull-CornermanPatches.ps1 -Push` | Red commits directly on VENGEANCE → `git push origin main` |
| Cornerman Cursor agents distill docs | Red absorbs distill; Cornerman reads **inbox** only if owner assigns manual/Odysseus work |
| `git pull --rebase` on `C:\Projects\lifepunch` after every Red push | Green clone **optional** — `git reset --hard origin/main` when touching files on box |

---

## Cornerman box — if owner still uses it

1. **Sync clone (optional)** — use the script (safe mid-rebase):
   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File C:\lifepunch\cornerman\inbox\Reset-CornermanClone.ps1
   ```
   Red pushes this to inbox via `Push-CornermanResetScript.ps1`. Manual equivalent: `git rebase --abort` then `git fetch origin` then `git reset --hard origin/main`.
2. **Read inbox:** `C:\lifepunch\cornerman\inbox\CORNERMAN_OFF_CURSOR_HANDOFF.md` (this file, pushed by Red)
3. **Do NOT** expect Cursor agents or automatic commits.
4. **Optional (no Cursor):** copy `outbox/` mirrors into Odysseus/RAG; run PTT relay per `CORNERMAN_PUSH_TO_TALK.md`.

---

## Closed on Red (no Green action)

| Item | Commit area |
|------|-------------|
| Bitminer three-entity arch + registry | `dfd2f18` |
| Bitminer G1–G3 (protection, portal listing, player UX) | `3b92de8` |
| ULX v2 staff menu polish | `63b87e8` |
| AK47 CS2 study distill | `3954155` |
| Hacker/coke/deagle protection scaffolds | `670fdee` |

---

## Red active queue (VENGEANCE)

| Priority | Task | Doc |
|----------|------|-----|
| **P0** | Bitminer Phase 2 module UI | `RED_BITMINER_PHASE2_BUILD.md` Step 1 |
| **P1** | Owner ModelDoc: terminal + stacked `_c` | `BITMINER_FINISH_RUNBOOK.md` E1–E2 |
| **P2** | `addons.json` + publish staging | `BITMINER_PORTAL_LISTING.md` |
| **P3** | Hacker Phase 2 Opus (job gate, host scan) | `RED_HACKER_JOB_BUILD.md` |
| **P4** | AK47 S2V glTF export | `reference-intake/cs2-weapons/ak47/` |

---

## Optional Cornerman (manual / Odysseus — no Cursor)

Only if owner explicitly asks:

| Task | Input | Output |
|------|-------|--------|
| RAG refresh | Pull `main`, read `lifepunch/addons/docs/reference/` | Copy summaries to `C:\lifepunch\cornerman\outbox\` |
| Coke unzip | Owner drops zips per `UNZIP_MANIFEST.txt` | Update manifest on disk (Red commits) |
| Voice tests | `Send-CornermanWorkflow.ps1 -Action StartVoiceRelay` | PTT smoke only |

**Do not** edit `BitminerTerminalProp.cs`, ModelDoc, or push git from Green.

---

## Red push inbox to Cornerman

```powershell
cd C:\Users\jared\Projects\lifepunchaddons\lifepunch\scripts
.\Push-CornermanOffCursorHandoff.ps1
```

---

## Related

- `LOCAL_AI_WORKSTATION.md` §7c (patch handoff — legacy if Cursor returns)
- `BITMINER_FINISH_RUNBOOK.md`
- `lifepunch/docs/AGENT_PROMPT.md` Block 0 sync
