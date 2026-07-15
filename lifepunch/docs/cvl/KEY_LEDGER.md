# KEY & CREDENTIAL LEDGER — every key the CVL holds, and the rules that govern them
Canon home: lifepunch/docs/cvl/KEY_LEDGER.md
v1 · 2026-07-13 · Ratified by Bloodwave

## Why this file exists
Key Law (DXRP doctrine): every integration gets its own minimum-scope
key. This ledger is the census — any seat or future audit can see
what keys exist, their scope, where they live, and what rules bind
them. A key not in this ledger is an incident.

## Active keys

### GH-1 — GitHub fine-grained PAT "lifepunch"
- Purpose: read-only API access for the Red seat (Claude Code,
  VENGEANCE) via the official GitHub MCP server.
- Scope: repository mragerlp/lifepunch ONLY. Permissions: Contents
  (read), Pull requests (read), Metadata (read). No account perms.
- Storage: repo-root .env (gitignored) + user-level Claude config
  (C:\Users\jared\.claude.json, outside the repo). Nowhere else.
- Expiry: 90 days from 2026-07-13. Rotate at expiry: mint new, edit
  .env, re-run the mcp add command.
- History: first mint 2026-07-13 was exposed in Fable's context the
  same day (seat read the credential file to debug an edit) →
  REVOKED within minutes, re-minted clean. The leak→revoke rule
  worked as written. The root cause became rule C-1 below.

### GL-1 — GitLab project access token (lifepunch-rdp-server)
- Purpose: read-only API/repo access for server-ops work (Blue).
- Type: PROJECT access token (not personal) — belongs to the
  lifepunch-rdp-server project itself. Role: Reporter. Scopes:
  read_api + read_repository only.
- Storage: repo-root .env (GITLAB_TOKEN line).
- Status: minted and stored; WIRING PENDING — glab CLI slice,
  post-merge. Unused until that slice's GO.

### GH-2 — CORNERMAN GitHub access, SSH key `github-class`
- Purpose: git transport (fetch/pull) for the CORNERMAN private clone
  at `C:\Kepler\Repositories\lifepunch` (Green/Odysseus muscle lane).
- Type: **SSH keypair** (`github-class`), resident on CORNERMAN. Origin
  is `git@github.com:mragerlp/lifepunch.git` — SSH, not HTTPS.
- Auth: PROVEN — `ssh -T git@github.com` returned the GitHub identity
  banner ("Hi mragerlp"); a subsequent `git fetch` was quiet (exit 0).
  Records: `cursor\0041`/`cursor\0042` (repo wiring), Rider 2 of
  `dispatch\red\0002`.
- Storage: CORNERMAN-local (`~/.ssh`). The private key never leaves the
  machine and never enters chat, relays, commits, or lane records (C-2).
- **REVOKE-OWED — redundant PAT.** An earlier GitHub PAT was persisted
  in CORNERMAN's Git Credential Manager (GCM + dpapi) during the HTTPS
  attempt. With SSH now the transport, that PAT is **redundant**. Key
  Law is one credential per integration → the PAT is **revoke-owed**:
  Bloodwave revokes it on GitHub AND erases it from the credential
  manager. Until both are done, GH-2 is dual-stored against C-4/one-key
  discipline; this ledger tracks the debt, not the token.

## Credential rules (standing, all seats, all keys)

C-1 — NO SEAT READS A CREDENTIAL FILE. .env and any file holding a
  secret is off-limits to every seat including Fable, for any
  purpose including debugging. Verification is always indirect:
  `git check-ignore .env`, `claude mcp list`, or a live API test
  through the wired tool. (Born from the GH-1 exposure: the leak
  path was a seat reading the file, not the human mishandling it.)
C-2 — Tokens never appear in chat, relays, commits, BOARD lines,
  packet bodies, or lane records. A token that appears anywhere
  outside its two storage locations is revoked immediately, no
  deliberation, then re-minted.
C-3 — MCP wiring uses default local scope ONLY. --scope project is
  FORBIDDEN: it writes the credential into the tracked .mcp.json,
  i.e., into the repository.
C-4 — Minimum scope is structural, not aspirational: single
  resource, read-only, expiry set. A write scope requires its own
  ruling naming the write it enables.
C-5 — Repo-root .env is the single on-disk home for CVL tokens (one
  NAME=value per line). Its .gitignore line is protected canon —
  any diff touching it fails gate review by default.

## Gate-review diff pattern (standing)
At every PR-open, Red exports the diff to the lane for Fable's
byte-level gate-review eyes:
  gh pr diff <N> > C:\lifepunch\comms\red\PR<N>_<date>.diff
Red's own wired GitHub MCP may additionally read PRs directly; the
export remains the conductor's sensor.

## Plugin cull (ruled 2026-07-13, executes at leisure)
Uninstall as dead/redundant/forbidden: vercel, stripe, greptile,
coderabbit, typescript-lsp, pyright-lsp, remember, Desktop
Commander, chrome-devtools-mcp, playwright, learning-output-style,
qodo-skills. Browser-automation pair reinstalls at the web slice if
needed. CONSOLE_PLUGINS_DOCTRINE trims its installed-set list to
match (v1.2) at its next touch — the doctrine's rules per class
remain binding regardless of list state.
