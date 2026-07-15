# LANE LEAD DOCTRINE — v1

**RATIFIED 2026-07-15, Bloodwave** (chat-carried; `dispatch\red\0003` item 2). Companion to
`COMMS_PROTOCOL.md` Rule 26 (issue-centric lane workflow). The structure for running a **multi-issue
lane** under one owner.

> **CLASS: RULED. Write-once.** Supersede with a new record citing this one by filename.

---

## 1. THE STRUCTURE — EPIC ISSUE + ONE LEAD AGENT

A lane may have **ONE LEAD AGENT** who owns the lane's work end to end:

- **Fable authors the EPIC** — the top-level issue that frames the lane's goal and scope. The lead
  does not author its own epic (authority separation: the epic is a work order, `L1` Fable-authored).
- **The lead owns the FEATURE BRANCH** for the lane (one long-lived branch off `develop`).
- **The lead decomposes the work into SUB-ISSUES** and manages their execution — it plans and sequences
  the lane's internal work under the epic.
- **The lead reviews SUB-PRs into the feature branch** — sub-work merges into the *feature branch*
  (not `develop`), and the lead is the reviewer for those internal merges.
- **The lead posts STATUS on the epic** — the epic issue is the lane's status surface (Rule 26).
- **The lead is the SOLE UPWARD COMMUNICATOR** to Bloodwave/Fable for that lane — one voice out of the
  lane, so the conductor hears one coherent status, not N sub-agents.

## 2. LANE CLOSE — ONE PR TO DEVELOP

At lane close, the lead opens **one feature-branch PR → `develop`**, and **Bloodwave merges it.** The
lane's many sub-issues and sub-PRs resolve *inside* the feature branch; only the finished lane crosses
into `develop`, through one gate.

## 3. INVARIANTS CARRIED (unchanged — the doctrine adds structure, never authority)

- **Bloodwave is the sole merge gate.** The lead reviews sub-PRs *into the feature branch*; it does
  **not** merge to `develop`/`main` — those are protected, PR-required, Bloodwave's button.
- **Protected branches stay PR-required** — no direct push to `develop`/`main` by anyone.
- **One DRIVE per worktree** (`COMMS_PROTOCOL` Rule 25 / `EDITOR_ACCESS_LAW_V2`). A lane's feature
  branch is one worktree; the lead's authority to review sub-PRs is lane-internal, not editor DRIVE.
- **Authority follows the model / seat charter** — a lead's grade is its own seat's grade; leading a
  lane confers no authority the seat did not already hold.
- **The lead flags, it does not rule.** Rulings remain Bloodwave's; a lead's status post is advice-
  class upward, the same as any round.

## 4. RELATIONSHIP TO RULE 26

Rule 26 makes lane work issue-centric (issue = source of truth, branch = work, comment = round). This
doctrine is the **multi-issue** shape of that: the epic is the lane's top issue, sub-issues are its
decomposition, and the feature-branch PR is the single crossing into `develop`. A single-issue lane
needs no lead — it is just Rule 26.

FROM: Red
