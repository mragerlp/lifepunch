# LifePunch — GitLab CI/CD Plan (draft, not yet executed)

> Planning doc for adding CI/CD to the GitLab lane repos. **Nothing here is live yet.** Execute in a
> dedicated session (one focused chat) when ready. Source of truth stays the GitHub monorepo; CI runs
> on the GitLab lanes. Read `GITLAB_ORGANIZATION.md` first.
>
> Doctrine: cost-safe, simple, no spaghetti. Start with the smallest pipeline that actually runs and
> adds value; expand only when a real toolchain exists. Verify by stakes.

## 0. Why CI is deferred (current blockers — resolve before building)

1. **Shared runners likely need account verification.** GitLab.com requires a credit-card check to
   use free shared runners (anti-crypto-mining). Until verified (or a self-hosted runner exists),
   pipelines will not execute. **First step: confirm runner availability** (Project → Settings → CI/CD
   → Runners) before writing real jobs.
2. **No buildable website toolchain yet.** `lifepunch/website/` has no `package.json` / `wrangler.*`
   / config. A website build/lint pipeline is premature until the site's stack lands.
3. **s&box lanes can't build in CI.** GitLab runners have no s&box SDK, so `rdp-server` / `addons`
   cannot compile. Only **structural validation** is feasible there.
4. **Windows/PowerShell validators don't fit Linux runners.** `validate-lifepunch-workspace.ps1`,
   `validate-server-parity.ps1`, `validate-layout.ps1` are Windows/path-aware. Either (a) port the
   minimal checks to a cross-platform script (node/python), or (b) use a **self-hosted Windows
   runner** to run them as-is. Decide per cost/benefit.
5. **Repo-structure wrinkle.** Lane content lives under `lifepunch/…`, not the repo root, but GitLab
   reads `.gitlab-ci.yml` at the **repo root**. See §3 for the two clean fixes.

## 1. Principles

- **Lane-scoped.** Each lane gets its own pipeline; CI never reaches across lanes.
- **Cheap + fast.** Short jobs, cached deps, `interruptible: true`, run only on relevant changes
  (`rules:`/`changes:`). No always-on heavy jobs.
- **No secrets in CI config.** Any token is a **masked + protected** CI/CD variable, never in
  `.gitlab-ci.yml`, never echoed. Secrets stay off the lanes (mirrors the repo secret-quarantine rule).
- **Protected `main` already enforces** Developer-push + no-force-push; CI complements, not replaces.
- **Validate, don't deploy (v1).** No production deploys from CI until explicitly approved by owner.

## 2. Per-lane scope (what CI should actually do)

| Lane | v1 (feasible now) | Later (when toolchain exists) |
|------|-------------------|-------------------------------|
| `lifepunch-foundation` | JSON validity (`gitlab-projects.json`), markdown lint, link check | rule/doc lint conventions |
| `lifepunch-addons` | `addons.json` structural validation (cross-platform), JSON/YAML lint | s&box build/validate on **self-hosted Windows runner** w/ SDK |
| `lifepunch-website` | (skip until stack lands) | `npm ci` → lint → typecheck → build (wrangler/Vite/etc.) |
| `lifepunch-rdp-server` | JSON/YAML structural checks, config sanity | server config validation; integration smoke tests |

## 3. Solving the root-`.gitlab-ci.yml` placement

Pick ONE:

- **Option A — Inject a root `.gitlab-ci.yml` per lane via the export** (recommended; mirrors the
  grounding-bundle pattern). Keep per-lane CI files in the monorepo at
  `lifepunch/ci/<lane>.gitlab-ci.yml`; `setup-gitlab-projects.ps1` copies the matching one to the
  lane **root** as `.gitlab-ci.yml` on export. Single source of truth, regenerated each export.
- **Option B — Per-project custom CI path** (Project → Settings → CI/CD → General pipelines → CI/CD
  configuration file). Point it at a file under `lifepunch/…`. Less code, but config lives in the
  GitLab UI (drift risk, not in git history).

**Recommendation: Option A** — consistent with how grounding is already injected, fully in-repo.

## 4. Example skeletons (proposed — DO NOT add until runners confirmed)

### 4a. Foundation — lightweight structural checks (Linux, no SDK)

```yaml
# lifepunch/ci/foundation.gitlab-ci.yml  -> injected as .gitlab-ci.yml at lane root
stages: [validate]

json-and-markdown:
  stage: validate
  image: node:20-alpine
  interruptible: true
  rules:
    - changes: ["**/*.json", "**/*.md"]
  script:
    - apk add --no-cache jq
    - echo "Validate all JSON files parse"
    - find . -name '*.json' -not -path './.git/*' -print0 | xargs -0 -I{} sh -c 'jq -e . "{}" >/dev/null || (echo "BAD JSON: {}" && exit 1)'
    - npx --yes markdownlint-cli2 "**/*.md" || true   # start non-blocking; tighten later
```

### 4b. Addons — `addons.json` structural validation (cross-platform port)

```yaml
# lifepunch/ci/addons.gitlab-ci.yml
stages: [validate]

addons-structure:
  stage: validate
  image: node:20-alpine
  interruptible: true
  rules:
    - changes: ["lifepunchaddons/**/*"]
  script:
    - node lifepunchaddons/scripts/validate-addons.mjs   # TODO: port from the PS validators
```

> Note: the existing PowerShell validators stay the canonical local check. The CI port should cover
> only the cross-platform-safe subset (JSON shape, required keys, path/case rules) — not s&box build.

### 4c. Website — placeholder (enable when the stack lands)

```yaml
# lifepunch/ci/website.gitlab-ci.yml  (commented until toolchain exists)
# stages: [install, check, build]
# install:  { image: node:20, script: ["cd lifepunch/website", "npm ci"], cache: { key: { files: ["lifepunch/website/package-lock.json"] }, paths: ["lifepunch/website/node_modules"] } }
# lint:     { image: node:20, stage: check, script: ["cd lifepunch/website", "npm run lint"] }
# typecheck:{ image: node:20, stage: check, script: ["cd lifepunch/website", "npm run typecheck"] }
# build:    { image: node:20, stage: build, script: ["cd lifepunch/website", "npm run build"] }
```

## 5. Phased rollout (execution order)

1. **Confirm runners** (verify account or stand up a self-hosted runner). If none, stop here.
2. **Wire Option A** into `setup-gitlab-projects.ps1` (inject `lifepunch/ci/<lane>.gitlab-ci.yml` → lane root `.gitlab-ci.yml`). Add a `ciConfig` field per project in `gitlab-projects.json`.
3. **Ship foundation pipeline first** (§4a) — lowest risk, proves the runner + structure work.
4. **Add the addons structural validator** (§4b) after porting the cross-platform check.
5. **rdp-server structural checks** next.
6. **Website pipeline** only after the site has `package.json`/build scripts.
7. Decide on a **self-hosted Windows runner** if you want the existing PowerShell validators in CI.

## 6. Security in CI (hard rules)

- No secrets in `.gitlab-ci.yml`. Use **masked + protected** CI/CD variables; restrict to protected
  branches/tags. Never `echo` a secret or print full env.
- CI never gets write-git/deploy creds in v1 (validation only). Production deploy is a later, separately
  approved phase with scoped, protected credentials.
- Pin job images by tag (avoid `latest` drift). Keep third-party actions/tools minimal and reviewed.

## 7. Ongoing (use the GitLab plugin)

- `pipeline-status` command → check pipeline health / drill into failed jobs from the editor.
- `gitlab-ci-author` skill → write/optimize the actual `.gitlab-ci.yml` when executing this plan.
- `review-merge-request` → review lane MRs with pipeline context.

## 8. Status

- **State:** PLAN ONLY — not executed. No `.gitlab-ci.yml` exists in any lane.
- **Owner gate:** confirm runners + pick §3 option before building.
- **Related:** `GITLAB_ORGANIZATION.md`, `gitlab-projects.json`, `scripts/setup-gitlab-projects.ps1`.
