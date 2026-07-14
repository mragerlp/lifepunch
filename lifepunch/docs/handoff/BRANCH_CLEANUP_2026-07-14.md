# Branch cleanup list — 2026-07-14

**STATUS:** LIST ONLY — do not delete remotes until Bloodwave GO.  
**Sensor:** `git fetch --all --prune` then `git branch -r --merged origin/develop` on VENGEANCE.  
**Base tip observed:** `origin/develop` @ `7bb8514d` (PR #92 merge).

## Remote branches currently merged into `origin/develop`

These refs still exist on a remote and are ancestors of `origin/develop`. Safe delete candidates after owner GO.

| Branch | Tip SHA (short) | Merge commit into develop | PR# | Recommendation |
|---|---|---|---|---|
| `origin/cursor/cornerman-scan-script-2026-07-14` | `ea558883` | `7bb8514d` | [#92](https://github.com/mragerlp/lifepunch/pull/92) | **Delete remote** after GO (merged; tip retained in develop history) |
| `blue-rdp/checkpoint-lpbitcoin-pre-sleep-20260701` | `a6c3665d` | `8f45abe2` (via PR #4 / subsequent develop ancestry) | [#4](https://github.com/mragerlp/lifepunch/pull/4) | **Delete remote** after GO if Blue lane no longer needs the checkpoint label; confirm with Blue before pruning `blue-rdp` |

## Remotes present but NOT merged into `origin/develop`

Out of scope for delete. Listed so this census is complete.

| Branch | Note |
|---|---|
| `origin/main` | Protected production line — never treat as stale feature branch |
| `blue-rdp/main` | Blue lane main — not a develop feature head |
| `gitlab-rdp/main` | GitLab RDP mirror main |
| `gitlab-rdp-server/main` | GitLab RDP server mirror main |

## Recently merged PR heads already absent from remotes

`git branch -r --merged` is short because most head branches were already deleted after merge. Census of recent develop merges whose heads are **gone** (no action):

| Former head | Merge commit | PR# | Status |
|---|---|---|---|
| `cursor/batch-skill-install-2026-07-14` | `62cf94a9` | #91 | Already deleted |
| `codex/next-slice-2026-07-14` | `b864b544` | #90 | Already deleted |
| `cursor/opencode-harness-adoption-2026-07-14` | `e2d0506e` | #88 | Already deleted |
| `cursor/kepler-ade-adoption-2026-07-14` | `fb990c6c` | #87 | Already deleted |
| `cursor/trip-path-placeholder-calibrate-2026-07-14` | `f3794075` | #86 | Already deleted |
| `codex/lifepunch-a1-donor-multiplier-2026-07-14` | `eceb54c1` | #85 | Already deleted |
| `cursor/trip-adoption-2026-07-14` | `510d4097` | #84 | Already deleted |
| `cursor/mcp-stale-refs-2026-07-14` | `5248088b` | #83 | Already deleted |
| `codex/lifepunch-triple-mcp-readability-2026-07-14` | `a6829b29` | #82 | Already deleted |
| `codex/lifepunch-dev-link-all-2026-07-14` | `b8eb159a` | #81 | Already deleted |
| `codex/lifepunch-repin-2357845-2026-07-13` | `d46fc080` | #80 | Already deleted |
| `red/donor-law-copilot-regen-2026-07-13` | `9d80d51d` | #79 | Already deleted |
| `red/canon-consult-superpowers-2026-07-13` | `ab98eebd` | #77 | Already deleted |

## Explicit non-actions

- No `git push --delete` in this pass.
- No local branch pruning required for this list.
- Open HOLD PRs (`cursor/lp-player-hub-spec-*`, `cursor/ui-standard-reconcile-*`, etc.) are **not** merge candidates for cleanup until merged.
