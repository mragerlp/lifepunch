---
applyTo: "**"
description: "LifePunch website rules deploy files — OneDrive Rules-Test1 for active work, V1 for production"
sourceRule: ".cursor/rules/lifepunch-rules-workflow.mdc"
---

> **Synced from** `.cursor/rules/lifepunch-rules-workflow.mdc` â€” edit source there, then re-run `Sync-CursorRulesToCopilotInstructions.ps1`.

# LifePunch Rules Workflow

- **Active work:** `%USERPROFILE%\OneDrive\Lifepunch\Rules\Rules-Test1.txt` — paste this into Cloudflare for in-game / sandbox testing.
- **Production paste:** `%USERPROFILE%\OneDrive\Lifepunch\Rules\Rules-V1.txt` — update **only when you explicitly promote** Test1 to V1.
- **Repo mirrors:** `lifepunch/website/deployments/Rules/Rules-Test1.txt` and `Rules-V1.txt`; dev worker source: `lifepunch/website/deployments/cloudflare-worker.mjs`.
- Legacy path `OneDrive\Documents\Lifepunch\Rules` is a fallback only if `OneDrive\Lifepunch\Rules` is missing.

## Sync commands

`lifepunch/website/deployments/scripts/sync-rules-from-onedrive.ps1`

| Direction | Use when |
|-----------|----------|
| **Push** | After editing `cloudflare-worker.mjs` in the repo — copies to **Test1 only** (not V1) |
| **Pull** | After editing **Test1** on OneDrive — copies Test1 into repo + `cloudflare-worker.mjs` |
| **Promote** | When you say production is ready — copies **Test1 → V1** (OneDrive + repo + worker) |

- Do **not** overwrite V1 during normal dev pushes.
- Regenerate **`current-rules.md`** from V1 with `build-current-rules-md.mjs` **after Promote**, not after every Test1 change.
- **Rules-V2.txt** is a layout comparison prototype; regenerate from V1 with `build-rules-v2-copy.mjs` only when refreshing that comparison.

## Source of truth (avoid accidental overrides)

**OneDrive `Rules-Test1.txt` is canonical** for active rules work. The repo mirror and `cloudflare-worker.mjs` are downstream copies.

### Before any agent edit to rules or worker

1. **Pull first** unless the user confirms they edited **only** inside Cursor in this session:
   `sync-rules-from-onedrive.ps1 -Direction Pull`
2. If the user says they edited Test1 **outside Cursor**, Pull immediately and briefly summarize what changed vs the repo before editing.
3. If OneDrive Test1 is **newer** than the repo mirror (or hashes differ), Pull before proceeding — **never** copy repo → OneDrive to "sync."

### Push and Promote (user must ask explicitly)

- **Never Push** (`worker → Test1`) unless the user explicitly requests it. Push overwrites OneDrive Test1 with repo content and can wipe outside edits.
- **Never Promote** (`Test1 → V1`) unless the user explicitly says production is ready.

### After Pull or Promote

- Treat OneDrive Test1, repo `Rules-Test1.txt`, and `cloudflare-worker.mjs` as aligned until the next outside edit.
- Remind the user to paste OneDrive Test1 into Cloudflare when deploy-relevant rule/worker changes were made.
