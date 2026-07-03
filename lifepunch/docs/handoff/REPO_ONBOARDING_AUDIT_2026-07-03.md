# REPO ONBOARDING AUDIT — LIFEPUNCH™

**Date:** 2026-07-03  
**Auditor:** Grok Build 0.1 (Cursor Agent, VENGEANCE/Red context)  
**Mode:** AUDIT ONLY — no source edits, no doc rewrites, no commits, no pushes, no branch creation, no filesystem changes except this single report file.  
**Repo root audited:** `C:\Users\jared\Projects\lifepunch` (GitHub `mragerlp/lifepunch`)  
**Git state at start of audit:** see §1

---

## 1. Current git state

```text
Branch: develop
HEAD: 7fd971c chore(tooling): default xAI model grok-build-0.1 for Cursor
Status -sb: ## develop...origin/develop
Porcelain: CLEAN
Diff --stat: (none)
git pull --rebase origin develop: up to date (no rebase needed)
```

- Worktree **clean** and on `develop`.
- Audit proceeded.
- No uncommitted changes before or during audit (only this new report file will be created).

---

## 2. Repo structure verified

From root README, `lifepunch/docs/LIFEPUNCH_REPO_LAYOUT.md`, `BRANCH_MODEL.md`, `CVL_AGENT_ONBOARDING.md`, `REPO_DOMAIN_MAP.md` references:

- **GitHub monorepo root** (`C:\Users\jared\Projects\lifepunch` on Red/VENGEANCE; `C:\Projects\lifepunch` on Green/Cornerman).
- **`lifepunch/`** — Ops (docs, scripts, server/platform/business/tooling, handoff packets, decisions, branding, admin-panel, etc.).
- **`lifepunchaddons/`** — Product (s&box addon packages at repo root: `lpbitcoin/`, `lphacker/`, config/, publish-lane scaffolding, _archive, _modeldoc, etc.).
- **`lifepunchdxrp/`** — Nested DXRP fork clone (own `.git`, gitignored by monorepo). Used for editor testing + mounting `lifepunchaddons` packages for Red host play / flatgrass proof. **Not** the official upstream contribution tree.
- **Official DXRP upstream contribution tree** (separate): `C:\Users\jared\Projects\dxrp-public` (or legacy `C:\Users\jared\Projects\dxrp`) → `mragerlp/dxrp-public` + `upstream` `dxura/dxrp`. **Never mix** with private LIFEPUNCH work.

Explicit retirement language present:
- "Retired: `C:\Users\jared\Projects\lifepunchaddons` as a workspace/repo root — that name is only the in-repo product folder now."
- Correct clone for Red is the monorepo root containing `lifepunchaddons/` at top level.

Branch law (consistent across BRANCH_MODEL, CVL_AGENT_ONBOARDING, AGENT_ONBOARDING, handoff pastes):
- `develop` = active test/integration (daily Red work, GitHub default).
- `main` = clean finalized repo truth (protected; Cornerman primarily pulls main; exports from main).
- Work on `develop` → owner GO → PR/merge `develop` → `main` → sync `main` → `develop`.
- Feature prefixes: `bitcoin/*`, `lane/*`, `fix/*`, `docs/*`.

---

## 3. Onboarding entrypoints found

| Path | Purpose (from content) | Fresh/Stale/Unclear | Should remain canonical? |
|------|------------------------|---------------------|---------------------------|
| `README.md` (repo root) | High-level start for agents + layout + validate scripts. Points to REPO_DOMAIN_MAP, RESTRUCTURE_*, CONFIG_SOURCE_OF_TRUTH, lifepunchaddons/docs/ACTIVE_WORKSTREAM (pointer), AGENT_PROMPT. | Mostly fresh; points to some addons/docs paths that may have moved post-restructure. | Yes (top of tree), but strengthen "start here for agents" section. |
| `lifepunch/README.md` | Ops/platform overview. | Present but thin in sampled content. | Keep as sub-entry. |
| `lifepunch/docs/AGENT_ONBOARDING.md` | "Agent Foundation". Points to CVL_AGENT_ONBOARDING as the single grounding paste. Good mandatory reads table. | Fresh in spirit; some pointers to `addons/docs/ACTIVE...` and restructure-era notes. | Strong reference; not the one-paste. |
| `lifepunch/docs/CVL_AGENT_ONBOARDING.md` | **The single grounding document** ("one paste"). Lanes, CVL roles, routing, owner GO, eyes-covered, handoff baton, re-ground on pull, mandatory reads. | Very fresh (July 2026). | **Primary canonical entry for new agents.** |
| `lifepunch/docs/handoff/AGENT_GROUNDING_INDEX.md` | Per-machine/IDE paste files (RED_CURSOR_GROUNDING_PASTE.txt etc.) + quickstarts. | Fresh. | Yes — the "which paste do I use?" index. |
| `lifepunch/docs/BRANCH_MODEL.md` | Branch law, machine pull law, pre-merge checklist (proof + GO), session workflow. | Fresh and clear. | Yes. |
| `lifepunch/docs/LIFEPUNCH_REPO_LAYOUT.md` | Folder model (lifepunch/ ops, lifepunchaddons/ product, lifepunchdxrp/ nested fork). Explicitly retires old workspace root. | Fresh. | Yes. |
| `lifepunch/docs/MACHINE_CAST.md` | CVL RGB naming + Architect outside CVL. | Fresh. | Yes (mandatory vocabulary). |
| `lifepunch/docs/handoff/NEW_CHAT_BRANCH_LAW_PASTE.txt` + machine pastes | Short bootstrap pastes. | Present and referenced. | Yes (use on every new chat). |
| `lifepunch/docs/handoff/ARCHITECT_*` + `ARCHITECT_HANDOFF_README.md` | Architect continuity. | Many recent; for design lane. | Keep in handoff. |

**Observation:** No single ultra-thin `START_HERE_AGENTS.md` at root or `lifepunch/docs/`. CVL_AGENT_ONBOARDING + AGENT_GROUNDING_INDEX + BRANCH_MODEL + REPO_LAYOUT come closest to "start here."

---

## 4. Agent routing docs found

- **Cursor (Agent / Red primary for MCP/proof):** DUAL_IDE_CURSOR_VSCODE.md, MCP_AGENT_ROUTING.md, CURSOR_GROK_XAI_SETUP.md, RED_CURSOR_GROUNDING_PASTE.txt (handoff), .cursor/rules/* (alwaysApply).
- **VS Code + Copilot (primary in-editor writer):** DUAL_IDE..., COPILOT_AGENT_ONBOARDING.md, .github/instructions/copilot-repo-ownership.instructions.md, copilot-instructions.md.
- **Cornerman (Green, distill/outbox, eyes-covered, read-only deploy key, patch-handoff to Red):** Many CORNERMAN_* docs, GREEN_EXECUTION_MODEL.md, CORNERMAN_MCP_MODES.md, CVL_RGB_DOCTRINE.md, handoff/cornerman-inbox + outbox packets, branding/cornerman/.
- **Codex (reviewer only — PASS / REVISE / HOLD):** Referenced in DUAL_IDE and upstream DXRP contexts.
- **Opus (Tier-1 scarce: architecture, multi-file C#, economy, security):** .cursor/rules/lifepunch-opus-usage.mdc + instructions, CVL_AGENT_ONBOARDING (route tags), OPUS_USAGE_LAW.md.
- **Grok (Tier-2A: planning, audits, bounded slices, ModelDoc):** MODEL_ROUTING_AMENDMENT_GROK_BUILD_1.md, CURSOR_GROK_XAI_SETUP (grok-build-0.1), CVL mentions.
- **Red / VENGEANCE:** Primary writer + host of editor truth + flatgrass proof (Red Host Play only).
- **Green / Cornerman:** Distill + cheap execution + inbox/outbox; no uncontrolled visual claims.
- **VS Code warning:** Explicit that VS Code + Copilot is the controlled primary writer; Cursor is peer for specific concerns; do not let VS Code become "uncontrolled second writer."
- **Dual IDE law:** Copilot (VS Code) for implementation; Cursor for MCP/flatgrass/sync/plumbing; handoff between them.

---

## 5. Canon / decision docs found

- `lifepunch/docs/DECISIONS/` (10 decisions + README as of audit):
  - DECISION-0001 Single Authoritative Owner
  - 0002 Hub Owns Mining
  - 0003 No NPC Core Progression
  - 0004 Three Rack Limit
  - 0005 Terminal Never Mines
  - 0006 Hub Controller Upgrades
  - 0007 Preserve Hub UI Shell
  - 0008 Fantasy Check Gate
  - 0009 Gameplay Laws Document
  - **0010 Universal Upgrades Home** (Hub / Terminal / GPU Rack tabs in LpHashdPanel; Terminal defense real; Terminal never mines)
- `lifepunch/docs/DECISIONS/README.md` — how to add, RFC pipeline.
- Bitcoin-specific: handoff/AUTOPILOT_BITCOIN_*, LPBITCOIN_RESTART_PACKET_*, cornerman-outbox bitcoin packets; .cursor/rules/lifepunch-bitcoinmining-ip.mdc; KNOWLEDGE/bitcoin/; references to BITCOIN_SHIP_ROADMAP and CYBER_REFERENCE_LAWS (pointers sometimes inside lifepunchaddons/docs or handoff).
- Gameplay / cyber: LIFEPUNCH_GAMEPLAY_LAWS.md, LIFEPUNCH_FEEL.md, CYBER_REFERENCE_LAWS (Law 5 flatgrass, Law 1 reuse, Law 9 no "while we're here").
- Visual/brand: CYBER_VISUAL_IDENTITY_DOCTRINE.md (referenced in prior canon), TERMINAL_BRAND_MATRIX, etc.
- Owner gates and "no code during docs/canon/GO DOCS passes" appear in CVL_AGENT_ONBOARDING, AGENT_PROMPT, rules.

**Active lane gate (from .cursor rule + handoff):** lpbitcoin (Hub → Terminal → GPU Rack) only until owner sign-off + proof. Other lanes (Hacker etc.) blocked/quarantined.

---

## 6. Workflow / script docs found

~199 tracked .ps1 under `lifepunch/scripts/`.

**Onboarding / agent critical (read or run with care):**
- Install-Cornerman*, Connect-CornermanBridge, Ensure-Cornerman*, Get-Cornerman*, Dispatch-Cornerman*, Cornerman-Workflow, Build-ArchitectChatGptOnboardZip, Install-CursorGrokXai, Test-XaiGrokApi, Install-CommitHygieneHook.
- Dxrp-*: Dxrp-LifepunchPaths, Ensure-DxrpUpstreamCurrent, Initialize-DxrpVanillaWorkbench, Dxrp-VanillaWipe, sync-dxrp-fork (referenced).
- Export-*: Export-GitLabLane (main only), Export-LifepunchPublishLane.
- Setup-*, Ensure-*, Sync-LifePunchAddonsToDxrp, Start-SboxDxrpEditor, Validate-*/layout scripts.

**Categories observed:**
- Read-only / probe: Get-*, many status/health.
- Modify local (bridge, mounts, editor launch): Cornerman bridge, Enable-*, Start-*, Sync-Addons.
- Repo state or publish affecting: Export-*, Install-CommitHygieneHook, some publish staging.
- Dangerous without GO: anything that pushes, exports from main, installs persistent hooks/bridges, or touches upstream dxrp-public.

**Docs linking scripts:** BRANCH_MODEL (export law from main), DXRP_CONTRIBUTOR_LANE (sync-dxrp-fork, Ensure-DxrpUpstreamCurrent), CVL/AGENT docs, handoff pastes, .cursor rules.

Many scripts have no "do not run unless..." comments visible at discovery time — risk for ungrounded agents.

---

## 7. Current "read first" order for a new general agent

Recommended (practical, from current canon):

1. `git fetch && git checkout develop && git pull --rebase origin develop` + `git status -sb` (clean? on develop?).
2. `lifepunch/docs/CVL_AGENT_ONBOARDING.md` (the one-paste; re-read on any pull that touches it).
3. `lifepunch/docs/BRANCH_MODEL.md` + `MACHINE_CAST.md` + `GREEN_EXECUTION_MODEL.md`.
4. `lifepunch/docs/handoff/AGENT_GROUNDING_INDEX.md` + the machine-specific paste for your node/IDE (e.g. RED_CURSOR_GROUNDING_PASTE.txt).
5. `lifepunch/docs/LIFEPUNCH_REPO_LAYOUT.md` + `REPO_DOMAIN_MAP.md` (folder ownership).
6. `.cursor/rules/` (alwaysApply: active-workstream-gate, agent-session-discipline, commit-hygiene, opus-usage, etc.) + matching `.github/instructions/`.
7. Current handoff baton / ARCHITECT_CURRENT_STATE.md / CVL_RELAY_BATON.md (state of the orchestra).
8. Lane-specific (see §8–10).
9. Proof / commit law (eyes-covered, flatgrass on Red, Bloodwave GO before commit, `mragerlp` author, no AI trailers).

---

## 8. Current "read first" order for lpbitcoin agents

1. `lifepunch/docs/handoff/AGENT_GROUNDING_INDEX.md` + your machine paste + CVL_AGENT_ONBOARDING (re-ground).
2. `.cursor/rules/lifepunch-active-workstream-gate.mdc` (or mirrored instructions).
3. Pointers in gate: `lifepunchaddons/docs/ACTIVE_WORKSTREAM.md`, `BITCOIN_SHIP_ROADMAP.md`, `CYBER_REFERENCE_LAWS.md` (Law 5 flatgrass, Law 1 reuse, Law 9 no scope creep), `DXRP_ADDON_PUBLISH_DOCTRINE.md`, `OWNER_PROGRESS_TRACKER.txt` / H* checklist (current unchecked ID).
4. Recent handoff state: `AUTOPILOT_BITCOIN_*.md`, `LPBITCOIN_RESTART_PACKET_*.md`, cornerman-outbox bitcoin packets.
5. Canon decisions: DECISION-0010 (Universal Upgrades Home — HUB/TERMINAL/GPU RACK), 0002, 0005, 0006, 0007, 0008 (Fantasy Check), 0009.
6. Visual/brand + digital machine: relevant KNOWLEDGE/bitcoin/, TERMINAL_BRAND_MATRIX, LIFEPUNCH_DIGITAL_MACHINE_STANDARD, MODEL_FOUNDATION_PASS.
7. Proof law: runtime / host play on `lp_map_flatgrass` + fresh spawn + screenshots via Red bridge; full proof package (day/night/USE/citizen/clip) before "done" for a checklist ID. No Phase B until Phase A + owner H10 sign-off.
8. Route: Opus for hard slices (one ID), Grok for planning/audits, Cursor for MCP/proof, Copilot (VS Code) for implementation, Cornerman distill only.
9. Owner GO before any commit/push on the lane.

**Note:** Some gate pointers still reference `lifepunchaddons/docs/...` paths that were not prominently present in tracked top-level md under addons in this audit (mostly archives + modeldoc). Current practice lives heavily in handoff packets + .cursor rules + DECISIONS.

---

## 9. Current "read first" order for private DXRP server testing agents

(Working inside `lifepunch/lifepunchdxrp` + mounting `lifepunchaddons` packages for Red host play.)

1. CVL_AGENT_ONBOARDING + BRANCH_MODEL + REPO_LAYOUT (understand lifepunchdxrp is the **nested testing fork**, not upstream).
2. LIFEPUNCH_REPO_LAYOUT (mounting story: editor syncs packages from lifepunchaddons/ into lifepunchdxrp/ for play).
3. Scripts: Sync-LifePunchAddonsToDxrp, Start-SboxDxrpEditor (with -BitcoinOnly etc.), Ensure-DxrpLifepunchResources.
4. MCP stack (sbox bridge for runtime proof on lp_map_flatgrass).
5. Active lane gate + bitcoin docs (since current work is lpbitcoin).
6. Proof = Red Host Play on flatgrass + bridge screenshots; editor-only does not count.
7. **Never** treat this tree as the place for official DXRP upstream PRs.

**Differs from official upstream:** This tree carries LifePunch proprietary mounts, headers in testing, private paths. It is for **our server testing**, not Dimmer's review.

---

## 10. Current "read first" order for official DXRP upstream agents

(Working in `C:\Users\jared\Projects\dxrp-public` or the dxrp clone → `mragerlp/dxrp-public` + `dxura/dxrp`.)

1. DXRP_CONTRIBUTOR_LANE.md (the separation bible).
2. CVL_AGENT_ONBOARDING § on the two lanes (declare "DXRP upstream" this session).
3. AGENT_PROMPT / handoff DXRP_PARTY_CURSOR_BOOTSTRAP_PASTE (or equivalent for the bounty/issue).
4. `.cursor/rules/lifepunch-dxrp-style-gate.mdc` + `dxrp-addon-foundation`.
5. Commit hygiene: Install-CommitHygieneHook on the dxrp-public clone; `mragerlp` only; **no AI trailers**; no LifePunch © headers, no `lifepunch/` paths, no bitcoin/U1 code, no private machine paths.
6. Start from `upstream/develop` (or equivalent); rebase before PR; small scoped PRs citing issues.
7. Style match: TabMenu, dxrp.json, existing DXRP UI patterns (reference dxura/dxrp @develop).
8. Proof: flatgrass/bridge where gameplay/UI; editor context secondary.
9. Codex review (PASS/REVISE/HOLD) before upstream PR ship.
10. Never mix with private monorepo work in the same chat/session.

---

## 11. Stale / conflicting docs

| Path | Problem | Severity | Recommended action |
|------|---------|----------|--------------------|
| `README.md`, `AGENT_ONBOARDING.md`, some .github/instructions | Still point to `lifepunchaddons/docs/ACTIVE_WORKSTREAM.md`, `BITCOIN_SHIP_ROADMAP.md`, `CYBER_REFERENCE_LAWS.md` as if primary tracked locations. Current practice heavily in handoff/ + .cursor/rules + DECISIONS. | P1 | Update pointers or ensure the addons/docs files exist and are the SoT (or centralize and update all pointers). |
| Various instructions (pre-restructure) | Old paths like `lifepunch/addons/...` or assuming `lifepunchaddons/` as the workspace root for cd/scripts. | P1 | Audit and normalize to current monorepo layout (lifepunch/ for ops, lifepunchaddons/ at root). |
| BRANCH_MODEL.md clone note | Says "Clone (VENGEANCE): `C:\Users\jared\Projects\lifepunchdxrp` (junction `lifepunch` OK)". User query and REPO_LAYOUT use `C:\Users\jared\Projects\lifepunch` as monorepo root. Minor naming drift. | P2 | Clarify: monorepo = `.../lifepunch`; the nested testing tree = `.../lifepunch/lifepunchdxrp`. |
| AGENT_ONBOARDING / rules | Some "flatgrass is the truth" + "editor screenshots do not count" language is strong and correct for host-play verification in the bitcoin lane, but could be misread as universal requirement for every change. | P2 | Ensure language consistently says "runtime proof before done; use flatgrass / lp_map_flatgrass when appropriate as the low-demand proof map." |
| Handoff folder | Very large (dozens of dated pastes, inbox/outbox, templates). Some older ones may be superseded. | P2 | Consider a "current" vs "archive" split or index with dates + supersession notes (AGENT_GROUNDING_INDEX helps but is not exhaustive). |
| lifepunchaddons/ internal docs (MODELDOC_*, PACKAGE_*, RED_VENGEANCE_*) | Assume running with cwd inside lifepunchaddons or use relative scripts/ paths. Correct for addon authors, but confusing if an agent treats the subdir as the whole repo. | P2 | Add clear "this file lives inside lifepunchaddons/" headers where needed. |
| No single thin START_HERE at root or lifepunch/docs/ | Agents must discover CVL + handoff index. | P1 (polish) | Propose thin canonical entry (see §15). |

No major contradictions on branch law or private-vs-upstream separation — those are consistently strong.

---

## 12. Missing onboarding links

- Root README and AGENT_ONBOARDING do not prominently link the handoff/AGENT_GROUNDING_INDEX.md or the machine paste files as "first thing after pull."
- No obvious link from CVL_AGENT_ONBOARDING or AGENT_GROUNDING_INDEX back to this style of "REPO_ONBOARDING_AUDIT" or a living "how the repo itself is organized for agents."
- .cursor/rules active gate and some instructions still hard-point to files under `lifepunchaddons/docs/` whose current tracked presence is unclear from broad ls (mostly archives surfaced).
- Few scripts have "requires Bloodwave GO" or "run only on Red after clean develop" headers in the files themselves (docs reference them, but the scripts are the executable surface).
- No consolidated "dangerous scripts for ungrounded agents" list in onboarding docs.

---

## 13. Docs that should be canonical

- `lifepunch/docs/CVL_AGENT_ONBOARDING.md` — the one-paste grounding.
- `lifepunch/docs/handoff/AGENT_GROUNDING_INDEX.md` — which paste / quickstart per node+IDE.
- `lifepunch/docs/BRANCH_MODEL.md`
- `lifepunch/docs/LIFEPUNCH_REPO_LAYOUT.md` + `REPO_DOMAIN_MAP.md`
- `lifepunch/docs/MACHINE_CAST.md` + `GREEN_EXECUTION_MODEL.md`
- `.cursor/rules/` (the alwaysApply set) — law wins over prose.
- `lifepunch/docs/DECISIONS/README.md` + individual DECISION-00xx (especially 0010 for current bitcoin canon).
- `lifepunch/docs/handoff/CVL_RELAY_BATON.md` + latest AUTOPILOT / state files for orchestra handoff.

---

## 14. Docs that should be archived, renamed, or demoted

- Older dated handoff files that have clear successors (e.g. superseded CORNERMAN_LONG_RUN, early JUNE checkpoints) — move to a dated archive/ subdir or mark with "SUPERSEDED by ...".
- Any lingering `lifepunch/addons/...` path references in instructions/READMEs (post monorepo mv) — either delete or update.
- Pre-restructure onboarding notes that conflict with current CVL/REPO_LAYOUT.
- Duplicate "restart packet" / "bootstrap paste" variants that have been corrected (keep the _CORRECTED or latest dated as primary; demote others).

---

## 15. Proposed single source of truth entrypoint

**Recommended:** Keep `lifepunch/docs/CVL_AGENT_ONBOARDING.md` as the primary "paste this" for any new agent/chat.

Add or strengthen a thin, stable pointer at repo root or `lifepunch/docs/`:

Option A (preferred for minimal change): `lifepunch/docs/AGENTS.md` (or `START_HERE_AGENTS.md`) that is 30-50 lines:
- One-paragraph "what this repo is."
- "Run the startup git sequence."
- "Paste CVL_AGENT_ONBOARDING.md first."
- "Use AGENT_GROUNDING_INDEX for your machine paste."
- "Read BRANCH_MODEL + REPO_LAYOUT + MACHINE_CAST."
- "Read .cursor/rules (law)."
- "Current lane gate: see active-workstream rule + handoff bitcoin state."
- "Private LIFEPUNCH vs dxrp-public separation (link DXRP_CONTRIBUTOR_LANE)."
- "Owner GO + runtime proof (flatgrass when appropriate) before done."
- Link to this audit report once approved.

This gives a single obvious file while preserving the depth in CVL + handoff.

---

## 16. Proposed onboarding patch plan

**P0 (must fix before more agents onboard / to prevent drift):**
- Audit and fix all "lifepunchaddons/docs/ACTIVE_WORKSTREAM.md" + "BITCOIN_SHIP_ROADMAP" pointers so they either point to real tracked files or to the handoff/ equivalents + .cursor rule.
- Add or update a thin `lifepunch/docs/AGENTS.md` (or root-level) as the obvious first read.
- Ensure every .cursor rule and top onboarding doc explicitly says "runtime proof before done; use flatgrass / lp_map_flatgrass as the preferred low-demand proof map when appropriate" (not "flatgrass always required").
- Add "requires Bloodwave GO / run only after clean develop on authorized node" comments or headers to high-risk scripts (Export-*, certain Install-*/Ensure-*, anything that pushes or touches upstream).

**P1 (should fix soon):**
- Normalize all pre-mv path references (`lifepunch/addons/...` → current layout) in docs and instructions.
- Consolidate / index handoff/ with clearer "current state" vs "historical" (date + supersedes links). Keep AGENT_GROUNDING_INDEX up to date.
- Add a short "dangerous scripts" section to CVL_AGENT_ONBOARDING and AGENT_GROUNDING_INDEX.
- Clarify clone paths consistently (monorepo root vs nested lifepunchdxrp vs dxrp-public).

**P2 (polish):**
- Add "this file is inside lifepunchaddons/" headers to product-internal docs.
- Consider a living "REPO_ONBOARDING_AUDIT.md" (or link to latest dated) as the "how agents are supposed to learn the repo" companion to CVL.
- Review older handoff pastes for archival.

---

## 17. Risks if we do nothing

- New agents (or new chats) will follow stale "cd lifepunchaddons" or "addons/docs/ACTIVE..." and get confused about repo root vs product tree.
- Agents may treat flatgrass as a universal always-required proof instead of the low-demand host-play map for gameplay/UI changes (or conversely, skip runtime proof entirely).
- Mixing of private LIFEPUNCH headers/IP/paths into dxrp-public PRs (or vice-versa) because the two-lane gate is not re-read every session.
- Cornerman or ungrounded agents running state-changing scripts (bridge, export, upstream sync) without context or GO.
- "Eyes-covered" violations (visual claims without Red bridge screenshots on lp_map_flatgrass).
- Owner time wasted re-explaining repo layout, branch law, and role routing on every new agent or after pulls that change canon.
- Drift between .cursor rules (law) and prose docs.

---

## 18. Opus handoff packet

**Concise packet for Architect / Opus to turn this audit into a canonical docs patch (no implementation yet):**

- **Goal:** Make onboarding impossible to get wrong on first session. One obvious entry + correct pointers + explicit two-lane + proof + GO law everywhere.
- **Inputs to use:** This audit (2026-07-03), CVL_AGENT_ONBOARDING.md (current one-paste), AGENT_GROUNDING_INDEX.md, BRANCH_MODEL.md, LIFEPUNCH_REPO_LAYOUT.md, MACHINE_CAST.md, DXRP_CONTRIBUTOR_LANE.md, DUAL_IDE_CURSOR_VSCODE.md, .cursor/rules/lifepunch-active-workstream-gate.mdc + agent-session-discipline + opus-usage + commit-hygiene, DECISIONS/ (esp 0010 + bitcoin ones), recent AUTOPILOT_BITCOIN + LPBITCOIN packets, handoff templates.
- **Must produce (P0):**
  1. Thin `lifepunch/docs/AGENTS.md` (or START_HERE_AGENTS.md) that every new chat is told to read after the git sequence.
  2. Audit/fix all ACTIVE_WORKSTREAM / BITCOIN_SHIP / CYBER pointers in rules, README, AGENT_ONBOARDING, instructions. Decide: keep under lifepunchaddons/docs/ as tracked SoT or move/centralize and update everything.
  3. Language pass: "runtime proof before done; prefer lp_map_flatgrass + fresh spawn via Red bridge as the low-demand proof map for gameplay/UI changes." Remove or qualify any "flatgrass proof is always required" universals.
  4. Add explicit two-lane declaration + "no LifePunch headers in dxrp-public" + "no dxrp-public paths in private monorepo work" in the top 3 onboarding files and the active gate rule.
  5. Script hygiene headers for high-risk scripts (GO required, node required, branch required).
- **Role clarity to preserve:** Red/Cursor = implementation + proof + commits (after GO); Copilot (VS Code) = primary in-editor writer; Cornerman = distill/outbox/eyes-covered/patch-handoff only; Codex = reviewer gate for upstream; Opus = scarce hard slices; Grok = planning/audits per routing.
- **Owner gate language:** "No code during docs / canon / GO DOCS passes." "Propose scope → Bloodwave GO → commit as mragerlp (no AI trailers)."
- **Do not:** rewrite all handoff pastes; just make the entry + pointers + laws consistent. After patches, regenerate any continuity kits that reference old paths.
- **Verification:** After changes, a fresh agent should be able to answer all 21 "teach a new agent" questions in the audit prompt from the top 5-7 files without guessing.

---

**No docs modified except this audit report. Waiting for Bloodwave GO.**
