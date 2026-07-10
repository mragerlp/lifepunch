# DECISION-0011 — Reject a junction between the repo and the editor addon tree

> **Status:** Rejected (permanent) — do not re-propose
> **Date:** 2026-07-10
> **Proposed by:** Claude Code (Red), during the editor-sync hygiene review
> **Approved by:** Bloodwave

> Recorded so the junction is never proposed a third time. It has been torn out once
> already (`fa010a5`) and rejected on review once (this decision).

## Context

The s&box editor compiles a hand-synced copy of the addon at
`D:\Steam\steamapps\common\sbox\dxrp\game\Code\Addons\lifepunch\`, not the repo working tree.
A junction (`mklink /J`) from the editor path to the repo's `lifepunchaddons/Code/Addons/lifepunch`
was proposed to make "one file, one tree" and retire the hand-sync.

## Decision

**No junction. Permanently.** The sanctioned sync mechanism is
`lifepunch/scripts/Sync-LifePunchAddonsToDxrp.ps1` (`-WhatIf` first, every time — the dry run is
the authorization).

## Why (two independent reasons)

1. **The editor tree is the repo TRANSFORMED, not a mirror.** `Sync-LifePunchAddonsToDxrp.ps1`
   applies a **deploy-time rename** (`adminmenu/` → `lifepunchulx/`, script line 123) and a
   **quarantine mechanic** (`WeaponDevGive.cs` → `.quarantine` when the weapon addons aren't in the
   sync set, lines ~311-320). A junction points the editor at the *untransformed* repo, so it would
   silently **bypass the rename and un-quarantine the dev weapon-give** — a gameplay/security change
   wearing a build-hygiene costume. (The apparent "content divergence" between the trees that first
   looked alarming was CRLF-vs-LF plus these transforms, not real divergence.)

2. **Prior art: it was already torn out.** Commit `fa010a5` — *"fix(scripts): resolve addon source at
   repo-root lifepunchaddons, drop junction dep"* — removed an earlier junction because it was
   *"undocumented, not created by any setup script, and does not survive git operations,"* breaking
   ten scripts silently.

## Note for future sessions

Red repo is **LF**, the editor tree is **CRLF**; the sync script handles this and LF files compile
in the editor (proven). If "one file, not a sync step" is wanted again, the only acceptable path is
**registering the repo addon path directly in the editor's addon config** (verified against s&box's
addon-path traversal first) — never a reparse-point junction over the transform.
