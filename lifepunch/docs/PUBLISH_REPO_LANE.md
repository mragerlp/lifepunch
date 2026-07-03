# LIFEPUNCH™ — publish repo lane (DXRP addons)

**June 2026** — Two-repo law. Read with `QUARANTINE_REGISTER.md`, `portfolio.json`, and `addons/docs/PACKAGE_NAMING_STANDARD.md`.

---

## Package names (public branch law)

Canonical slugs live in `lifepunch/addons/config/packages.json`. Each **packageSlug** (e.g. `lifepunchbitcoin`, `lifepunchulx`) is the intended **public branch / publish export name** on LIFEPUNCH™.

| packageSlug | repoIdent (monorepo paths today) | s&box |
|-------------|----------------------------------|-------|
| `lifepunchulx` | adminmenu | `lifepunch.ulx` |
| `lifepunchbitcoin` | bitcoinmining | `lifepunch.bitcoin` |
| … | see `packages.json` | `lifepunch.{suffix}` |

Monorepo folders still use **repoIdent** until a deliberate path migration. Export script may still key on repoIdent — target export folders use **packageSlug** when promoted.

---

## Two repos (do not collapse)

| Repo | GitHub (suggested) | Role | Who works here |
|------|------------------|------|----------------|
| **Core monorepo** | `mragerlp/lifepunch` | Law, legal, MCP, quarantine, ChatGPT workflow, **all WIP** | Bloodwave + Cursor on VENGEANCE |
| **Publish lane** | `mragerlp/lifepunch-published` | **Portal-ready addons only** — clean tree for DXRP | Export from core; no quarantine |

Display name: **LIFEPUNCH™** · Remote slug: `lifepunch-published` (ASCII, no ™ in URL).

**Core stays source of truth.** Publish repo is a **branch-shaped snapshot**, not where agents invent law.

---

## What lives where

### Core monorepo (keep working here)

- `.cursor/rules`, `lifepunch/docs`, `lifepunch/legal`
- `config/portfolio.json` + quarantined addon code/assets
- `CHATGPT_STEP1_PASTE`, MCP scripts, Cornerman, website, server
- Active **development** for `adminmenu` + `bitcoinmining`

### Publish repo (blank → export only)

- `README.md` — LIFEPUNCH™ publisher, DXRP nominative
- `config/addons.json` — **publishReadyAddons only** (see `portfolio.json`)
- `Assets/addons/lifepunch/<ident>/` — ship assets + `_c`
- `Code/Addons/lifepunch/<ident>/` — ship code (no DevSpawn/TestBots)
- `SYNC_FROM.md` — last export SHA + date (script-written)

**Never in publish repo:** quarantined idents, `reference/`, legal EIN paths, full monorepo docs, experimental AK47/hacker/drugs.

---

## Workflow

```text
ChatGPT brief → Cursor (core monorepo) → build + quarantine law
       ↓
Owner sign-off: portal-ready
       ↓
Export-LifepunchPublishLane.ps1  (active addons only)
       ↓
lifepunch-published → prepare-publish / DXRP portal upload
```

Day-to-day: **always commit on core.** Export to publish when an addon is **ready to show the world**.

---

## One-time: create blank publish repo

From VENGEANCE (after `gh auth login`):

```powershell
cd C:\Users\jared\Projects\lifepunchdxrp
powershell -File lifepunch\scripts\Export-LifepunchPublishLane.ps1 -Init -Target C:\Users\jared\Projects\lifepunchdxrp-published
cd C:\Users\jared\Projects\lifepunchdxrp-published
git init
git add -A
git commit -m "chore: LIFEPUNCH publish lane scaffold (active portfolio only)"
gh repo create mragerlp/lifepunch-published --private --source=. --remote=origin --push
```

Re-export after ship progress:

```powershell
powershell -File lifepunch\scripts\Export-LifepunchPublishLane.ps1 -Target C:\Users\jared\Projects\lifepunchdxrp-published
```

---

## GitLab `lifepunch-addons`

GitLab lane = **mirror slice** of core `lifepunch/addons/**` for export tooling.  
**Publish repo** = slimmer **customer/portal** tree. Different jobs — do not merge the concepts.

---

## Agents

| Agent | Clone |
|-------|-------|
| Cursor integrate | **Core monorepo only** |
| Portal publish prep | Publish clone (read) or export output |
| shottaWEB | GitLab website lane (unchanged) |

New agents onboard from **core** `AGENT_PROMPT.md` — not from publish repo alone.

---

## Trademark

Publish README and portal listings: **LIFEPUNCH™** lead, DXRP nominative, ™ not ® until USPTO registers.
