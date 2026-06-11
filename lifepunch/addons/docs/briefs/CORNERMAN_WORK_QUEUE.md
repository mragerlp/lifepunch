# Cornerman work queue (Tier-3 prep)

**Issued:** 2026-06-11 · **Red:** VENGEANCE tests Bitminer + integrates via patch handoff  
**Pull first:** `C:\Projects\lifepunch` → `git pull --rebase` (or `Invoke-CornermanMonorepoSync.ps1` from Red)

You do **not** open s&box, ModelDoc, or `git push`. Commit locally; ping Red with commit count + subjects.

**While Red play-tests Bitminer + smoke-tests guns:** finish **#0 AK47** if still open, then **#1 Hacker Job terminal** is the main lane.

---

## Priority order

| # | Task | Brief | Deliverable |
|---|------|-------|-------------|
| 0 | **AK47 CS2 study** | `CORNERMAN_AK47_CS2_STUDY_TASK.md` | `CS2_AK47_STUDY.md` + `M4A1_CLASS_ANIM_MAP.md` + `SOURCE_INTAKE` §CS2 |
| 1 | **Hacker Job terminal** | `CORNERMAN_HACKER_JOB_TERMINAL_TASK.md` | `HACKER_TERMINAL_FLOW.md` + `TERMINAL_PUZZLE_CATALOG.md` + platform tokens + gov DB scaffold |
| 2 | **Coke intake** | `CORNERMAN_COKE_DRUG_INTAKE_TASK.md` | `UNZIP_MANIFEST.txt` + updated `COKE_LINE_MAP.md` |
| 3 | **Deagle distill** | `CORNERMAN_DEAGLE_DISTILL_TASK.md` | USP stats table + `w_deagle/MODEL_BUILD.md` draft |
| 4 | **Bitminer finish (docs)** | `CORNERMAN_BITMINER_FINISH_TASK.md` | Protection checklist + portal listing + player flow (**three-entity distill done** on `2e81a2c`) |
| 5 | **Bitminer Phase 2 menu** | `CORNERMAN_BITMINER_PHASE2_MENU_TASK.md` | Wireframe + `.razor.scss` token draft (no ship C#) |
| 6 | **Weapon queue hygiene** | `DEAGLE_WEAPON_BRIEF.md` | One-page distill for RAG (`outbox/`) |

**Closed:** vmat audit (`BITMINER_VMAT_AUDIT.md`) — Red completed vmats + vmdl + prefab 2026-06-11.

Phase 1 Bitminer terminal (`CORNERMAN_BITMINER_TERMINAL_TASK.md`) is **done** — Red integrated `9fa5eb1`.

---

## Per-task commit messages

```text
docs(ak47): CS2 study distill + M4 class anim map
docs(hackerjob): terminal flow, puzzle catalog, and platform tokens
chore(advanceddrugprocessing): coke unzip manifest + weed map distill
docs(deagle): USP reference stats table + w_deagle MODEL_BUILD draft
docs(bitcoinmining): three-entity arch + remote rack hashd UX distill
docs(bitcoinmining): Phase 2 tabbed menu wireframe + scss tokens
```

Ping Red after each commit batch: `N commits on Green — subjects: ...`

---

## References on box

| Path | Role |
|------|------|
| `C:\lifepunch\cornerman\inbox\` | Red-dropped briefs |
| `C:\lifepunch\cornerman\outbox\` | Your distill output for RAG |
| `C:\lifepunch\reference-intake\` | Archives (coke unzip writes here) |
| `lifepunch/addons/docs/reference/WEED_ENGINE_ENTITY_INDEX.md` | Weed entity names for coke map |
