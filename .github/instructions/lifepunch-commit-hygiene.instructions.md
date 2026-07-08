---
applyTo: "**"
description: "Commit message hygiene â€” no AI/agent attribution; clean upstream PR history"
sourceRule: ".cursor/rules/lifepunch-commit-hygiene.mdc"
---

> **Synced from** `.cursor/rules/lifepunch-commit-hygiene.mdc` â€” edit source there, then re-run `Sync-CursorRulesToCopilotInstructions.ps1`.

# LifePunch â€” Commit Hygiene (No AI Attribution)

Applies to **every** repo an agent commits in â€” especially the **public DXRP fork**
(`mragerlp/dxrp-public` â†’ `dxura/dxrp`). A Cursor co-author trailer on an upstream bounty
PR is a bad look and was a real June 2026 incident on PR #77.

## Law

- **Never let an AI/agent attribution trailer reach a commit.** Forbidden in commit messages:
  - `Co-authored-by: Cursor <cursoragent@cursor.com>` (and any `cursor`/`cursoragent`)
  - `Co-authored-by: Claude / Copilot / ChatGPT / OpenAI / Anthropic`
  - `Generated with â€¦`, `Assisted-by:`, `AI-authored-by:`, `noreply@anthropic.com`
- **Author is Bloodwave / `mragerlp <mragerlp@gmail.com>` only.** Tools are mentioned **nowhere**
  in commits or PRs unless the maintainer explicitly asks.
- **Scope: ALL git surfaces.** The no-AI-attribution rule covers commit messages, PR titles,
  PR descriptions, and merge-commit messages alike. No generated-with footers anywhere.
  (Precedent: the July 2026 PR #32 body slip - a harness-injected footer reached a PR
  description. PR bodies become part of the merge record; scrub them like commit messages.)

## Root cause (know it so you can stop it)

Cursor's **Settings â†’ Agent â†’ Attribution** has two toggles that inject this automatically:
**Commit Attribution** ("Mark Agent commits as 'Made with Cursor'") and **PR Attribution**.
These are **controlled in the UI, not `settings.json`** (and not via `git config`/hooks). They
must stay **OFF**. This is why the trailer appeared even though git author was correct, and why a
`git commit-tree` workaround gets re-routed to `git commit` (the wrapper intercepts `git commit*`).

## Prevention (defense in depth)

1. **Settings OFF** â€” Commit Attribution + PR Attribution both disabled (owner-controlled, UI).
2. **`commit-msg` hook** â€” fail-closed guard that blocks any commit carrying an AI trailer.
   Install per clone (hook lives in `.git/hooks`, not tracked):
   ```powershell
   powershell -File lifepunch\scripts\Install-CommitHygieneHook.ps1
   ```
   Default targets: `dxrp-public` + `lifepunchaddons`. Re-run after a fresh clone.
3. **Pre-push scan** â€” before any public push, scan the range:
   ```powershell
   git log <base>..HEAD --format='%H%n%B' | Select-String 'cursoragent|Co-authored'
   ```

## Recovery (if a trailer already got committed)

The injecting wrapper hooks `git commit*`, so `commit --amend` / `commit-tree` get rewritten.
Use **`git filter-branch`** (different subcommand â†’ bypasses the wrapper, builds objects directly):

```powershell
$env:FILTER_BRANCH_SQUELCH_WARNING=1
git filter-branch -f --msg-filter "sed '/^Co-authored-by: Cursor/d'" <upstream-base>..HEAD
git push --force-with-lease origin <branch>
```

Verify trees are byte-identical afterward (`HEAD^{tree}` unchanged) â€” only the message changes.
`--force-with-lease` on a personal fork's PR branch is acceptable for this; **never** force-push
shared `main`.

## Upstream PR conventions (DXRP)

- Keep individual commit messages clean (`fix(party): align HUD drag and collapse`). Reference the
  issue in the **PR title/body** (`feat: â€¦ (#73)`), not in every commit, to avoid spamming the
  issue timeline. Detail: `lifepunch/docs/DXRP_CONTRIBUTOR_LANE.md`.
- No LIFEPUNCHâ„¢ headers / `game/Libraries/*` dev tools / machine paths in the fork (see
  **dxrp-addon-foundation** + contributor lane).

