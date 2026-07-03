# START HERE — LIFEPUNCH™ agents

> **Read this first, after every `git` sync.** This page **routes to the law** — it is not the law.
> You are **not grounded** until you finish this page **and** your lane's mandatory reads
> (`CVL_AGENT_ONBOARDING.md` §12). If anything here disagrees with `.cursor/rules`, the **rules win**.

## 0. Sync first (every session)

```powershell
git fetch
git checkout develop
git pull --rebase origin develop
git status -sb
```

- **`develop`** = active work / testing / finalization (GitHub default; Red daily).
- **`main`** = clean finalized repo truth (protected; export / distill from here).
- Ship: work on `develop` → owner **GO** → PR `develop` → `main` → sync `main` → `develop`.

## 1. Ground (in order)

1. `lifepunch/docs/CVL_AGENT_ONBOARDING.md` — the one paste (who / lanes / laws / state).
2. `lifepunch/docs/handoff/AGENT_GROUNDING_INDEX.md` — pick your machine + IDE paste.
3. `lifepunch/docs/BRANCH_MODEL.md` · `lifepunch/docs/LIFEPUNCH_REPO_LAYOUT.md` · `lifepunch/docs/MACHINE_CAST.md`.
4. `.cursor/rules/` (alwaysApply) — **repo law; wins over this page**.

## 2. Know where you are (folder + branch law)

- **Private LIFEPUNCH™ repo root:** `C:\Users\jared\Projects\lifepunch` (GitHub `mragerlp/lifepunch`).
  - `lifepunch/` — ops: docs, scripts, platform, business, tooling.
  - `lifepunchaddons/` — product / addon lanes (`lpbitcoin`, `lphacker`, …). **An in-repo folder — never a repo root, never a `cd` target treated as "the repo."**
  - `lifepunchdxrp/` — **nested private DXRP mirror** for LIFEPUNCH server testing / Red Host Play (own `.git`, gitignored).
- **Official DXRP upstream:** `C:\Users\jared\Projects\dxrp-public` — a **separate clone** for Dimmer/Dxura PRs only (`mragerlp/dxrp-public` → `dxura/dxrp`, cut from `upstream/develop`).
- **Worktree safety (one writable agent per worktree):** Before switching lanes or allowing another writable agent into this repo, read `lifepunch/docs/WORKTREE_LANE_SAFETY.md`.

## 3. Hard separation (the #1 costly mistake)

- Private LIFEPUNCH testing happens in `C:\Users\jared\Projects\lifepunch` on `develop`.
- Official DXRP upstream PR work happens **only** in `C:\Users\jared\Projects\dxrp-public` from `upstream/develop`.
- **Never** cross-contaminate LifePunch headers / IP / paths / private-server assumptions into official DXRP PRs (or vice-versa). Lane bible: `lifepunch/docs/DXRP_CONTRIBUTOR_LANE.md`.

## 4. Active lane

- lpbitcoin only. Route through `.cursor/rules/lifepunch-active-workstream-gate.mdc` → `lifepunchaddons/docs/ACTIVE_WORKSTREAM.md`.
- Use the **current unchecked ID** from `ACTIVE_WORKSTREAM` + `OWNER_PROGRESS_TRACKER` + current baton — do not assume a stale `H*` / `T*` / `R*` slice.

## 5. Proof law

- **Runtime proof before "done."** Use flatgrass / `lp_map_flatgrass` when appropriate as the **low-demand proof map** for gameplay/UI validation; use a larger map only when the feature depends on larger-map context. Flatgrass is **not** a universal requirement for every change (docs-only proof = links resolve, paths correct, clean `git status`).
- Eyes-covered: no visual / playtest claim without an `sbox` bridge screenshot from **Red**.

## 6. Commit / push / trailer law

- Agents do **not** commit or push by default. Propose scope → Bloodwave **GO** → commit as `mragerlp <mragerlp@gmail.com>` → **no AI trailers** (`Co-authored-by: Cursor`, `Co-authored-by: AI`, `Generated-by`, `Assisted-by`, or any agent attribution are forbidden).
- **Cornerman (Green) branch nuance:** defaults to **`main`** as a clean truth mirror / export-stability reader; may read **`develop`** only when the inbox task explicitly targets active work, current testing, or a `develop`-bound audit. Green stays read-only / distill / outbox unless Bloodwave explicitly opens a patch-handoff lane.

---

**Repo self-map for agents:** `lifepunch/docs/handoff/REPO_ONBOARDING_AUDIT_2026-07-03.md`
