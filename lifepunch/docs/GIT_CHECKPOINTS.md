# LIFEPUNCH™ — Git checkpoints (commit / push / pull law)

**June 2026** — Bloodwave + agents. Read with `PUBLISH_REPO_LANE.md` and `portfolio.json`.

This doc answers: *what goes on `main`, what stays local, what goes to publish, and when.*

---

## Two repos — one decision tree

```text
Is it law, WIP, quarantine, legal, MCP, website, or ideation?
  YES → core monorepo (mragerlp/lifepunch) — commit here

Is it portal-ready addon Assets + Code for active portfolio only?
  YES → export to lifepunch-published — never hand-edit publish as source of truth
```

| Action | Core (`lifepunchaddons`) | Publish (`lifepunch-published`) |
|--------|--------------------------|----------------------------------|
| Daily dev | **Always** | Never day-to-day |
| Commit | Yes — checkpoints | Only after export + owner says push publish |
| Pull | Session start (clean tree) | Only on publish machine before portal upload |
| Push | After agent says **"good to commit"** + you confirm | After export when ship-ready |
| Quarantine code | Stays in core, excluded from compile | **Never** |
| ChatGPT briefs / specs | Core `addons/docs/briefs/` | Never |

---

## How agents ask for commits

Agents **recommend**, you **approve**. Not: *"Want me to commit?"*

**Agent says:**

> **Checkpoint ready for `main`.** Scope: [files]. Reason: [one line].  
> **Recommend: commit.** Push after? [yes/no + count of unpushed commits].  
> **Exclude:** [files that must NOT ship in this commit].

**You say:** `commit to main` · `commit and push` · `hold` · `commit only X`

---

## Always commit to core `main`

- `.cursor/rules`, `lifepunch/docs/**` (law, workflow, MCP, checkpoints)
- `lifepunch/legal/**` (no EIN / street address)
- `lifepunch/scripts/**` (validators, export, preflight)
- `config/portfolio.json`, `config/addons.json` (when addon is promoted/demoted)
- `addons/docs/briefs/*.md`, `QUARANTINE_REGISTER.md`, hub pattern / doctrine
- **Active** addon code + assets: `adminmenu`, `bitcoinmining` (when intentionally changed)
- Compile/quarantine excludes in `addons.csproj`

---

## Commit to core — docs only (quarantine planning)

Safe on `main` even when the addon is **not** active:

- Product specs (`BANKER_JOB_SPEC.md`, research briefs)
- `LIFEPUNCH_HUB_PATTERN.md` (model law)
- **Foundation laws (Jun 2026):** `LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md`, `LIFEPUNCH_WEAPON_IMPLEMENTATION_LAW.md`, matching `.cursor/rules/lifepunch-digital-machine.mdc` + `lifepunch-weapon-platform.mdc`, onboarding updates in `AGENT_ONBOARDING.md` / `AGENT_PROMPT.md`
- Handoff / Cornerman outbox under `docs/handoff/` (e.g. `JUNE_2026_FOUNDATION_CHECKPOINT.md`)

**Do not** add quarantined addon **code or assets** in the same commit unless owner promotes in `portfolio.json`.

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
| **New Cursor session** | `git fetch`; if working tree **clean**, `git pull --rebase` |
| **Uncommitted changes + behind remote** | **Stop** — commit or stash first; never pull over WIP |
| **Cornerman read-only clone** | No push; patch-handoff to VENGEANCE (see `LOCAL_AI_WORKSTATION.md`) |
| **Publish clone** | Pull only before portal upload; prefer re-export from core |

**Never:** `git push --force` on `main` · `git reset --hard` without explicit owner ask.

---

## Push law

| Repo | When to push |
|------|----------------|
| **Core `main`** | After a coherent checkpoint commit; you have **6 unpushed commits** today — push is recommended after the next commit |
| **Publish** | After export + owner sign-off that active addons are portal-presentable |
| **GitLab lanes** | Partner lanes only — shottaWEB website, etc. — not a substitute for core |

**Checkpoint habit:** commit → push → note SHA in chat or `handoff/` if it was a big infra/addon milestone.

---

## ChatGPT → Cursor → git flow

```text
1. ChatGPT Step 1 → filled CURSOR BRIEF (paste)
2. Cursor builds in CORE only
3. Agent: "Checkpoint ready" → you: "commit to main"
4. Optional: push (separate yes if you want control)
5. When portal-ready: Export-LifepunchPublishLane.ps1 → publish repo → prepare-publish → portal
6. **Desktop org (Bloodwave local):** `Sync-DesktopPublishFolder.ps1` → `%USERPROFILE%\Desktop\lifepunch\addons\publish\` — see `handoff/DESKTOP_ORG_CHECKPOINT_2026-06.md`
```

Ideation and structure live in **core**. Clean customer tree lives in **publish**.

---

## Current snapshot (update when stale)

- **Branch:** `main`, **6 commits ahead** of `origin/main` (quarantine + Ophion + MCP workflow)
- **Ready to commit now:** publish lane doc + scaffold + export script + agent/workflow doc tweaks
- **Hold:** `bankerjob/` trees, `governmentdatacenter/intake-raw/`
- **Publish folder:** `C:\Users\jared\Projects\lifepunch-published` — local export exists; GitHub repo not created until you run one-time `gh repo create`
