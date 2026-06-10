#!/usr/bin/env bash
# LifePunch session-start auto-sync (macOS / Linux / Git-Bash).
# Failsafe so every clone (esp. partner lanes) opens on the latest data without anyone
# remembering to pull. Clean-only: never touches a dirty tree, never blocks the session.
# Pairs with .cursor/hooks/session-sync.ps1 (Windows). Both are FAIL-OPEN by design.

export GIT_TERMINAL_PROMPT=0   # never hang on a credential prompt

emit() {
  # $1 = optional additional_context message
  if [ -n "${1:-}" ]; then
    printf '{"additional_context":"%s"}\n' "$(printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g')"
  else
    printf '{}\n'
  fi
  exit 0
}

# Drain stdin (hook input JSON); contents unused.
cat >/dev/null 2>&1 || true

command -v git >/dev/null 2>&1 || emit ""

TOP="$(git rev-parse --show-toplevel 2>/dev/null)" || emit ""
[ -n "$TOP" ] || emit ""
cd "$TOP" || emit ""

GITDIR="$TOP/.git"
if [ -d "$GITDIR/rebase-merge" ] || [ -d "$GITDIR/rebase-apply" ] || [ -f "$GITDIR/MERGE_HEAD" ]; then
  emit "LifePunch auto-sync skipped: a rebase/merge is in progress. Finish it, then 'git pull --rebase'."
fi

git fetch --quiet >/dev/null 2>&1

git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1 || emit ""

BEHIND="$(git rev-list --count 'HEAD..@{u}' 2>/dev/null)"
[ -n "$BEHIND" ] && [ "$BEHIND" != "0" ] || emit ""

if [ -z "$(git status --porcelain 2>/dev/null)" ]; then
  git pull --rebase --quiet >/dev/null 2>&1
  HEAD="$(git rev-parse --short HEAD 2>/dev/null)"
  emit "LifePunch auto-sync: pulled $BEHIND new commit(s); now at $HEAD. You are on the latest."
else
  emit "LifePunch auto-sync WARNING: you are $BEHIND commit(s) behind origin AND have uncommitted changes. NOT auto-pulled (protecting your work). Commit or stash, then 'git pull --rebase' before continuing."
fi
