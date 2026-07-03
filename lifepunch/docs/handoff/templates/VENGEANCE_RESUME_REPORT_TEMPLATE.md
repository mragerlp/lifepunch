# VENGEANCE — RESUME <LANE> AFTER <PARALLEL-WORK> CLOSEOUT

**Owner:** Bloodwave  
**Role:** Integration Architect on VENGEANCE  
**Repo:** `C:\Users\jared\Projects\lifepunchdxrp`  
**Mode:** report first — **no implementation until Bloodwave GO**

---

## Step 1 — Sync

```powershell
cd C:\Users\jared\Projects\lifepunchdxrp
git fetch
git pull --rebase
git status -sb
git log -1 --oneline
```

Report: branch, HEAD, dirty state (source/doc vs compiled noise).

## Step 2 — Confirm separation

- Parallel work remains in its own repo/branch (e.g. `dxrp-public`)
- No foreign lane code in monorepo
- Active workstream gate still correct (`ACTIVE_WORKSTREAM.md`)

## Step 3 — Read canon

<List lane-specific docs — use WORKSTREAM_RESTART_WORKFLOW.md reference instance for Bitcoin.>

## Step 4 — Read Cornerman packet

Newest: `C:\lifepunch\cornerman\outbox\RESTART_PACKET_<lane>_*.md`  
Mirror: `lifepunch/docs/handoff/cornerman-outbox/`

If missing: `NO CORNERMAN PACKET FOUND — HOLDING IMPLEMENTATION`

## Step 5 — Inspect implementation

Inspect lane code paths. Label each item (VERIFIED FROM REPO / CANON / NEEDS SBOX RUNTIME PROOF / OWNER DECISION REQUIRED).

## Step 6 — Recommend exactly ONE next action

Pick one (lane-specific list). Explain why. **Do not implement.**

## Step 7 — Hard no until GO

No edits, economy, RPCs, `[Sync]`, migration, commit, or push.

---

## Required response format (12 sections)

1. CURRENT GIT / WORKTREE STATE  
2. DXRP / PARALLEL WORK SEPARATION CHECK  
3. CANON READ SUMMARY  
4. CORNERMAN PACKET SUMMARY  
5. IMPLEMENTATION STATE CHECK  
6. CONFLICTS / STALE LANGUAGE  
7. RECOMMENDED ONE NEXT ACTION  
8. FILES LIKELY INVOLVED IF APPROVED  
9. PROOF REQUIRED  
10. OPUS / AUTO / GREEN ROUTING  
11. BLOCKERS  
12. WAITING FOR BLOODWAVE GO  

End with:

```text
No implementation performed. Waiting for Bloodwave GO.
```
