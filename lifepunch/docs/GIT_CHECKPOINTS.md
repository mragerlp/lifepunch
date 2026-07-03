# LIFEPUNCH™ — Git checkpoints (commit / push / pull law)

**July 2026** — Bloodwave + agents. Read with **`BRANCH_MODEL.md`**, `PUBLISH_REPO_LANE.md`, and `portfolio.json`.

**One line:** **`main` is truth.** **`develop` is where we test.** Ship = merge **`develop` → `main`**, then sync **`main` → `develop`**.

This doc answers: *what goes on `develop` vs `main`, what stays local, what goes to publish, and when.*

---

## Branch model (summary)

| Branch | Purpose |
|--------|---------|
| **`develop`** | Daily integration — commit here |
| **`main`** | Ship-ready — merge from `develop` on owner GO |
| **`bitcoin/*`, `lane/*`, `fix/*`** | Short-lived off `develop` |

Full law: **`BRANCH_MODEL.md`**

---

## Two repos — one decision tree

```text
Is it law, WIP, quarantine, legal, MCP, website, or ideation?
  YES → core monorepo (mragerlp/lifepunch) — commit on develop

Is it portal-ready addon Assets + Code for active portfolio only?
  YES → export to lifepunch-published — never hand-edit publish as source of truth
```

| Action | Core (`lifepunchdxrp`) | Publish (`lifepunch-published`) |
|--------|------------------------|----------------------------------|
| Daily dev | **Always** on **`develop`** | Never day-to-day |
| Commit | Yes — checkpoints on **`develop`** | Only after export + owner says push publish |
| Pull | Session start: `git pull --rebase origin develop` | Only on publish machine before portal upload |
| Push | After agent says **"good to commit"** + you confirm | After export when ship-ready |
| Quarantine code | Stays in core, excluded from compile | **Never** |
| ChatGPT briefs / specs | Core `addons/docs/briefs/` | Never |

---

## How agents ask for commits

Agents **recommend**, you **approve**. Not: *"Want me to commit?"*

**Agent says:**

> **Checkpoint ready for `develop`.** Scope: [files]. Reason: [one line].  
> **Recommend: commit.** Push after? [yes/no + count of unpushed commits].  
> **Exclude:** [files that must NOT ship in this commit].

**You say:** `commit to develop` · `commit and push` · `hold` · `commit only X` · `merge to main` (ship GO)

---

## Always commit to core `develop`

- `.cursor/rules`, `lifepunch/docs/**` (law, workflow, MCP, checkpoints)
- `lifepunch/legal/**` (no EIN / street address)
- `lifepunch/scripts/**` (validators, export, preflight)
- `config/portfolio.json`, `config/addons.json` (when addon is promoted/demoted)
- `addons/docs/briefs/*.md`, `QUARANTINE_REGISTER.md`, hub pattern / doctrine
- **Active** addon code + assets: `adminmenu`, `bitcoinmining` (when intentionally changed)
- Compile/quarantine excludes in `addons.csproj`

---

## Commit to core — docs only (quarantine planning)

Safe on **`develop`** even when the addon is **not** active:

- Product specs (`BANKER_JOB_SPEC.md`, research briefs)
- `LIFEPUNCH_HUB_PATTERN.md` (model law)
- **Foundation laws (Jun 2026):** `LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md`, `LIFEPUNCH_WEAPON_IMPLEMENTATION_LAW.md`, matching `.cursor/rules/lifepunch-digital-machine.mdc` + `lifepunch-weapon-platform.mdc`, onboarding updates in `AGENT_ONBOARDING.md` / `AGENT_PROMPT.md`
- Handoff / Cornerman outbox under `docs/handoff/`

**Do not** add quarantined addon **code or assets** in the same commit unless owner promotes in `portfolio.json`.

---

## Merge to `main` (owner GO only)

When a lane milestone is ship-ready:

1. `develop` is clean and pushed
2. Owner says **merge to main** or opens PR `develop` → `main`
3. Optional: `Export-GitLabLane.ps1 -Slug lifepunch-rdp-server` from **`main`**
4. Note SHA in `handoff/` for big milestones

---

## Do NOT commit to core (yet)

| Path / type | Why |
|-------------|-----|
| `bankerjob/` code + assets | Quarantined WIP — promote via ChatGPT brief first |
| `*/intake-raw/**` | Raw third-party dumps — keep local or `reference-intake/` off-repo |
| `reference/**` | Study only — never LifePunch IP |
| `.dxrp-publish/` | Generated staging — regenerable |
| OneDrive secrets, EIN, domicile | Never in repo |
| Accidental `*_c` from wrong machine | Verify before commit |

---

## Never put on publish repo

- Quarantined idents, `reference/`, full monorepo docs, `.cursor/rules`
- Dev files: `*DevSpawn*`, `*TestBots*`, `*DevGive*`, `_dev/`
- Unpromoted WIP (bankerjob, hackerjob, etc.)

Publish tree = **export script output only** (`Export-LifepunchPublishLane.ps1`).

---

## Pull law

| When | Rule |
|------|------|
| **New Cursor session** | `git fetch`; checkout **`develop`**; if working tree **clean**, `git pull --rebase origin develop` |
| **Uncommitted changes + behind remote** | **Stop** — commit or stash first; never pull over WIP |
| **Cornerman read-only clone** | No push; patch-handoff to VENGEANCE (see `LOCAL_AI_WORKSTATION.md`) |
| **Publish clone** | Pull only before portal upload; prefer re-export from core |

**Never:** `git push --force` on **`main`** or **`develop`** · `git reset --hard` without explicit owner ask.

---

## Push law

| Repo / branch | When to push |
|---------------|--------------|
| **Core `develop`** | After every coherent checkpoint commit |
| **Core `main`** | After owner GO merge from `develop` |
| **Publish** | After export + owner sign-off that active addons are portal-presentable |
| **GitLab lanes** | Partner lanes only — shottaWEB website, etc. — not a substitute for core |

**Checkpoint habit:** commit on **`develop`** → push → note SHA in chat or `handoff/` if it was a big infra/addon milestone.

---

## ChatGPT → Cursor → git flow

```text
1. ChatGPT Step 1 → filled CURSOR BRIEF (paste)
2. Cursor builds in CORE on develop
3. Agent: "Checkpoint ready" → you: "commit to develop"
4. Optional: push (separate yes if you want control)
5. Ship GO → merge develop → main → optional GitLab export
6. When portal-ready: Export-LifepunchPublishLane.ps1 → publish repo → prepare-publish → portal
7. **Desktop org (Bloodwave local):** Sync-DesktopPublishFolder.ps1 → Desktop publish folder
```

Ideation and structure live in **core on develop**. Clean customer tree lives in **publish**.

---

## Current snapshot (update when stale)

- **Truth branch:** `main` @ merge PR #2 line (`6c3408b`) — behind `develop` until next owner GO merge
- **Test branch:** `develop` @ latest integration (default on GitHub)
- **Hold:** `bankerjob/` trees, `governmentdatacenter/intake-raw/`
- **Publish folder:** `C:\Users\jared\Projects\lifepunch-published`
