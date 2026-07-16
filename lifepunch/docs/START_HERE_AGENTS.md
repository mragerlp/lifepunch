# START HERE — LIFEPUNCH™ agents

> **Claude Code reads `CLAUDE.md` (repo root) FIRST, then this page** (doctrine 2026-07-09). This page
> **routes to the law** — it is not the law. You are **not grounded** until you finish this page **and**
> your lane's mandatory reads (`CVL_AGENT_ONBOARDING.md` §12). Authority order: **`CLAUDE.md`** (workflow
> doctrine) → `.cursor/rules` → this page. If they disagree, the higher one wins.

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

**First, the *why*:** `lifepunch/docs/LIFEPUNCH_MISSION.md` — the goal, the two-lane logic, and quality-as-moat. Read it before the *how* below.

**Then, the *laws*:** `lifepunch/docs/DESIGN_LAWS.md` — the cross-lane design laws every job must obey: **Job-Depth** (depth over breadth), **Physical-Payout** (product is carried to a drop entity, no payout UI, any job), and **Bitcoin Session-Power** (bitcoin is a session power; hacker is the sanctioned counterplay). Read before proposing or building any job, payout, or currency surface.

0. **`CLAUDE.md`** (repo root) — workflow doctrine: plan in Chat · build in Code · review with Codex · ship with GO. Claude Code's first read.
1. `lifepunch/docs/CVL_AGENT_ONBOARDING.md` — the full grounding doc (who / lanes / laws / state).
2. `lifepunch/docs/handoff/AGENT_GROUNDING_INDEX.md` — grounding index + the handoff-file pattern (Cursor/Copilot pastes are legacy).
3. `lifepunch/docs/BRANCH_MODEL.md` · `lifepunch/docs/LIFEPUNCH_REPO_LAYOUT.md` · `lifepunch/docs/MACHINE_CAST.md`.
4. `.cursor/rules/` (alwaysApply) — **repo law; wins over this page**.
5. **Development sessions:** `lifepunch/docs/CORNERMAN_FOR_AGENTS.md` — how to use the Cornerman work queue (offload pattern, model policy, fast-fail).

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

- **The "lpbitcoin only" gate is DEAD (killed 2026-07-14).** It routed through
  `.cursor/rules/lifepunch-active-workstream-gate.mdc`, **a file deleted in `6d306081`** — so the rule
  died while the restriction it carried survived here, in canon, in the doc the grounding order routes
  every seat into. Read as law, it placed essentially **all current work** (the CVL slices, the drug
  lane, the DXRP re-pin) off-lane. **There is no active-workstream gate.** Scope comes from the active
  brief in `lifepunch/docs/handoff/` and Bloodwave's relay — nowhere else. Finding: `comms\red\0031`.
- Use the **current unchecked ID** from `ACTIVE_WORKSTREAM` + `OWNER_PROGRESS_TRACKER` + current baton — do not assume a stale `H*` / `T*` / `R*` slice.
- **Today's canon (2026-07-12) — a fresh session's current state, from the tree:**
  - **Repo skills** (`.claude/skills/`: grounding · economy · config · editor-gate · razor-ui · sbox-engine-truth · cornerman-packets) auto-load at grounding (`CLAUDE.md` "Repo skills are canon-grade").
  - **Seat model + CVL seat flow + Codex charter:** `CLAUDE.md` (SEAT MODEL / CVL SEAT FLOW / CODEX SEAT CHARTER).
  - **Addon build ladder** (lpbitcoin → chemist → tablet): `LIFEPUNCH_ADDON_ARCHITECTURE.md` (ADDON BUILD LADDER).
  - **lpbitcoin config spec** (BLOCK-0, APPROVED — the queued finish line): `lifepunch/docs/handoff/LPBITCOIN_HYBRID_CONFIG_PROPOSAL_2026-07-12.md`.
  - **Lane B deploy checklist** (bitcoinmining fresh gamemode install): `lifepunch/docs/handoff/LANE_B_LPBITCOIN_INSTALL_CHECKLIST_2026-07-12.md`.

## 5. Proof law

- **Runtime proof before "done."** Use flatgrass / `lp_map_flatgrass` when appropriate as the **low-demand proof map** for gameplay/UI validation; use a larger map only when the feature depends on larger-map context. Flatgrass is **not** a universal requirement for every change (docs-only proof = links resolve, paths correct, clean `git status`).
- Eyes-covered: no visual / playtest claim without an `sbox` bridge screenshot from **Red**.

## 6. Commit / push / trailer law

- Agents do **not** commit or push by default. Propose scope → Bloodwave **GO** → commit as `mragerlp <mragerlp@gmail.com>` → **no AI trailers on any git surface** — commit messages, PR titles, PR descriptions, merge-commit messages (`Co-authored-by: Cursor`, `Co-authored-by: AI`, `Generated-by`, `Assisted-by`, generated-with footers, or any agent attribution are forbidden).
- **Cornerman (Green) branch nuance:** defaults to **`main`** as a clean truth mirror / export-stability reader; may read **`develop`** only when the inbox task explicitly targets active work, current testing, or a `develop`-bound audit. Green stays read-only / distill / outbox unless Bloodwave explicitly opens a patch-handoff lane.

---

**Repo self-map for agents:** `lifepunch/docs/handoff/REPO_ONBOARDING_AUDIT_2026-07-03.md`
