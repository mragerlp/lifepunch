# Cornerman work queue (Tier-3 prep)

**Issued:** 2026-06-11 · **Red:** VENGEANCE integrates via patch handoff  
**Pull first:** `C:\Projects\lifepunch` → `git pull --rebase` (or `Invoke-CornermanMonorepoSync.ps1` from Red)

You do **not** open s&box, ModelDoc, or `git push`. Commit locally; ping Red with commit count + subjects.

---

## Priority order

| # | Task | Brief | Deliverable |
|---|------|-------|-------------|
| 1 | **Coke intake** | `CORNERMAN_COKE_DRUG_INTAKE_TASK.md` | `UNZIP_MANIFEST.txt` + updated `COKE_LINE_MAP.md` |
| 2 | **Deagle distill** | `CORNERMAN_DEAGLE_DISTILL_TASK.md` | USP stats table + `w_deagle/MODEL_BUILD.md` draft |
| 3 | **Bitminer Phase 2 menu** | `CORNERMAN_BITMINER_PHASE2_MENU_TASK.md` | Wireframe + `.razor.scss` token draft (no ship C#) |
| 4 | **Weapon queue hygiene** | `DEAGLE_WEAPON_BRIEF.md` | One-page distill for RAG (`outbox/`) |

Phase 1 Bitminer terminal (`CORNERMAN_BITMINER_TERMINAL_TASK.md`) is **done** — Red integrated `9fa5eb1`.

---

## Per-task commit messages

```text
chore(advanceddrugprocessing): coke unzip manifest + weed map distill
docs(deagle): USP reference stats table + w_deagle MODEL_BUILD draft
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
