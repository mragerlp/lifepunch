# LIFEPUNCH™ Design Architect — continuity kit

**Law:** `ARCHITECT_CONTINUITY_KIT_LAW.md`  
**Baseline commit:** `782ef35`  
**Builder (Red):** `lifepunch/scripts/Build-ArchitectChatGptOnboardZip.ps1 -Build`

GitHub monorepo is authoritative. ZIP bundles are **snapshots only**.

## Build + upload

1. Red commits canon on GitHub → Cornerman `git pull --rebase`.
2. Red runs builder (or Design Architect reconciles a Red export).
3. Design Architect integrity pass + checksums (hashes may differ from Red reference after normalization).
4. Upload to ChatGPT Project in order:
   - `…-00-README.zip`
   - `…-01-chunk.zip` · `…-02-chunk.zip`
5. Project instructions: `ARCHITECT_PROJECT_INSTRUCTIONS.txt`
6. New chat: `NEW_CHAT_BOOTSTRAP_PASTE.txt` only

## Refresh discipline

| Trigger | Action |
|---------|--------|
| Small localized doc edits | Delta refresh in Project knowledge |
| Laws, onboarding, `ARCHITECT_CURRENT_STATE.md`, decisions, `ACTIVE_WORKSTREAM.md` | **Full kit rebuild** |

Red sends **commit hash + changed files** to Design Architect for each refresh.

## CVL roles

- **Red:** Maintain canonical commits.
- **Green:** Sync from Red only.
- **Design Architect:** Reconcile updates; regenerate packages when needed.

## Excluded from compact package (repo-only)

`AGENT_ONBOARDING.md` · `MACHINE_CAST.md` · `DESIGN_DECISION_LOG.md` · `AGENT_SYNC_BROADCAST.txt`

Canon detail: `lifepunch/docs/ARCHITECT.md`
