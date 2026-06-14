# LifePunch × DXRP — Agent Foundation

> Read this first. Hand it to any agent in any of our repos so it operates inside
> the established foundation instead of re-deriving (or diverging from) it.
> This doc **mirrors** the always-on `.cursor/rules` — the rules are the law; if
> they ever disagree with this doc, the rules win and this doc should be updated.

## Who / what

LifePunch is the largest community server for **DXRP**, a source-available DarkRP-style
RP game by **Dxura**, built on **s&box** (Facepunch's Source 2 engine). We build
high-quality custom content (weapons, entities, staff/admin tooling, UI, gamemode/server
ops) for our server and to license to other DXRP servers. Treat this as a business: be
direct, ship quality.

## Repos — know where you are

### 1. GitHub monorepo → THE SOURCE OF TRUTH

**`https://github.com/mragerlp/lifepunch`** (private monorepo). Live local checkout:
`C:\Users\jared\Projects\lifepunchaddons`. Holds all lanes — `lifepunch/addons/`, `website/`,
`server/`, `portal/`, `gamemode/`, `admin-panel/`, `.cursor/rules`, `docs/`, `legal/`, etc.
**Owner does all design/build integration here.** Git `origin` is always this repo.
(Do **not** use any OneDrive clone — removed June 2026 as a git-corruption risk.)

### 2. GitLab lane projects → focused workspaces for partners (June 2026+)

GitLab does **not** replace GitHub. Four per-lane projects under `gitlab.com/mragerlp` give
shottaWEB and the RDP server agent scoped repos. Owner exports lanes from the GitHub monorepo;
partner commits on GitLab integrate back into GitHub. Full map:
`lifepunch/docs/GITLAB_ORGANIZATION.md` + `gitlab-projects.json`.

| GitLab project | Lane | Primary agent |
|----------------|------|---------------|
| `lifepunch-foundation` | rules, docs, legal | All read |
| `lifepunch-addons` | `lifepunch/addons/**` | Owner |
| `lifepunch-website` | `lifepunch/website/**` | **shottaWEB** |
| `lifepunch-rdp-server` | server, portal, gamemode, ops | **RDP server agent** |

**Copy/paste for new chats:** `lifepunch/docs/AGENT_PROMPT.md`.

### 3. Upstream / integration (GitHub, third-party)

1. **`mragerlp/dxrp-public`** → our DXRP fork (`origin=dxrp-public`, `upstream=dxura/dxrp`).
   Synced via `lifepunch/scripts/sync-dxrp-fork.ps1` (ff-merge upstream `develop`).
2. **The Steam checkout** (`D:\Steam\steamapps\common\sbox\dxrp`, `origin=dxura/dxrp`) →
   read-only **upstream** runtime/test copy where the editor runs. **Never** commit LifePunch
   work here.

### 4. Publish lane → portal snapshot (not law)

**`mragerlp/lifepunch-published`** — export-only tree for DXRP portal. Built by
`Export-LifepunchPublishLane.ps1` from `publishReadyAddons` in `portfolio.json`.
Core monorepo stays where all agents work. See `PUBLISH_REPO_LANE.md` + `GIT_CHECKPOINTS.md`.

## Grounding = the monorepo's `.cursor/rules` (alwaysApply) are law

- **lifepunch-operating-context** — business style; **asset ownership default = ours**, do
  NOT raise provenance / "is this ok to ship" concerns (the user flags external work
  explicitly); git workflow; publish notes.
- **lifepunch-quality-bar** — **NO SPAGHETTI (≠ no hacks).** A simple, honest hack/baseline
  is fine and often necessary as we scale. The enemy is *spaghetti*: convoluted,
  unmaintainable, non-modular code with tangled interdependencies and unpredictable control
  flow. Keep solutions modular/swappable, use the engine's systems as designed, prefer the
  fully-owned solution, no dead/orphan assets. Don't present an interim baseline as the
  polished endgame; track genuinely-temporary work in `lifepunch/addons/docs/TECH_DEBT.md`.
- **dxrp-addon-foundation** — folder lane + validators; `addons.json` is source of truth.
  Also mandates the **proprietary header on every source file** (`.cs`/`.razor`/`.scss`): every
  file opens with the `PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co` block (name slot filled
  from `addons.json`) before any `using`/`namespace`/style. No exceptions, incl. dev/test helpers.
- **lifepunch-trademark-ip** — trademark, brand-architecture, and proprietary-IP doctrine
  (repo-wide). **LIFEPUNCH** is the only mark we own (owner: **Peak Performance Products LLC**);
  **DXRP / Dxura / s&box / Facepunch are third-party** — reference nominatively only, and
  **lead product names with LIFEPUNCH** ("LIFEPUNCH Admin Menu for DXRP", not "DXRP Admin Menu").
  Canonical detail: `lifepunch/legal/TRADEMARK_AND_IP.md`. Never commit sensitive identifiers
  (EIN, domicile address) — those stay off the repo.
- **lifepunch-rules-workflow** + **lifepunch-website-organization** — website/rules deploy.
- **lifepunch-sbox-patches** — engine patch log, version check, UI/publish regression gate.

Also read `lifepunch/docs/WORKSPACE_STRUCTURE.md` and `lifepunch/docs/GITLAB_ORGANIZATION.md`.
**s&box engine:** `lifepunch/addons/docs/SBOX_ENGINE_PATCHES.md` — run `lifepunch/scripts/Get-SboxEnginePatchStatus.ps1` each session.
**LPDXRP** = LifePunch DXRP (shorthand). **VIP (OG)** / **EVIP (OG)** = early donors at first addon launch — `lifepunch/docs/LPDXRP_OG_SUPPORTERS.md`.
Don't fork parallel grounding/docs — update the existing single source of truth.

If you are operating on (or setting up) the **local AI workstation** — the Corsair AI
Workstation 300 ("Strix Halo") box used as our private local inference/RAG node — read
`lifepunch/docs/LOCAL_AI_WORKSTATION.md`. That box is a clone, **never** the source of
truth; secrets stay quarantined off it and the same git rules apply.

## Named systems (shared vocabulary)

**Canonical reference:** `lifepunch/docs/MACHINE_CAST.md` — **read on every new session** after
`git pull --rebase`. Then read **`lifepunch/docs/OPS_CLARITY_CHECKPOINT.md`** (June 2026
checkpoint: how we look at the LifePunch web — at a glance, not a telescope). Paste
`AGENT_SYNC_BROADCAST.txt` into any stale chat to force alignment.

### Operational clarity (checkpoint — law moving forward)

Organization on the voice/ops stack is **operational clarity**, not decoration. We built uniform
shortcuts, consoles, and preflight so humans and agents see **which layer failed** without
archaeology.

| Idea | Rule |
|------|------|
| **At a glance** | Tier icon + shortcut name + one preflight FAIL → know the node/layer |
| **Universal (tri-stack)** | Target **white-light** (R+G+B) — **Start Day**, **CVL Same Page** |
| **Red / green / blue** | **Primaries** R=VENGEANCE, G=Cornerman, B=lifepunchnet — not a group nickname |
| **RGB mixes** | Yellow=R+G, Cyan=G+B, Magenta=B+R — see `CVL_RGB_DOCTRINE.md` |
| **Rainbow** | Emerges from logged hub gradient — **not yet**; standard RGB phase now |
| **Explorer icons** | Gray folder + gray `.txt` on every node — `OneDrive\Desktop\uniforms\`; `Set-LifePunchExplorerIcons.ps1` |
| **PowerShell thumbnail** | Shared retro desktop tab icon on every node — `uniforms\PNGs\powershell-prompt-thumbnail.png`; `Set-PowerShellPromptThumbnail.ps1` |
| **One `.lnk` → one script** | Installers own targets; see `lifepunch/branding/shortcut-icons/SHORTCUT_ICONS.md` |

Full checkpoint (shortcuts, voice flow, per-node cheat sheet, failure surfaces):
**`lifepunch/docs/OPS_CLARITY_CHECKPOINT.md`**. Uniform standards (web-wide):
**`OneDrive\Desktop\uniforms\UNIFORM_STANDARDS.md`** (repo mirror:
`lifepunch/branding/lifepunch-ops/UNIFORM_STANDARDS.md`). Cursor rules when editing installers:
`.cursor/rules/lifepunch-shortcut-icons.mdc` · `.cursor/rules/lifepunch-explorer-icons.mdc`.

| Codename | One line |
|----------|----------|
| **VENGEANCE** | Primary PC — Cursor, GitHub source of truth (`lifepunchaddons` checkout) |
| **Cornerman** | Home LAN AI box — mic, local LLM/STT, Tier-3 prep (`LOCAL_AI_WORKSTATION.md`, `CORNERMAN_MODEL_ROUTING.md`) |
| **lifepunchnet** | Hosted always-on server — DXRP ops, Whisper, watchdog (`LIFEPUNCHNET_INSTRUCTIONS.txt`) |
| **LPDXRP** | **LifePunch DXRP** — shorthand for our server + addon portfolio on DXRP (`LPDXRP_OG_SUPPORTERS.md`) |
| **shottaWEB** | Website partner (Brian) — GitLab `lifepunch-website` only; say **shottaWEB** in agent chat |
| **RDP server agent** | Agent **role** on **lifepunchnet** (Block C) — not a separate machine name |
| **AK47 lane** | Git branch `lane/ak47` — quarantined viewmodel experiment; **not** on ship path (`lifepunch/docs/lanes/AK47_LANE.md`) |

Deprecated: "Server Host", "RDP Server Host", "the server box" → **lifepunchnet**.

**Agent-facing aliases:** say **Bloodwave** for the owner (same as Jared / Mr. Rager / mragerlp / mrragerlp);
say **shottaWEB** for the partner (Brian). Bloodwave is the default owner reference (editor test character).
See `MACHINE_CAST.md` § How agents should refer. lifepunchnet RDP may show `administrator` — still the owner.

## Efficiency & guardrails (cost-safe operation)

The `lifepunch-operating-context` rule is law here; this is the orientation. We run best-in-class
(Opus 4.8) but every token is real $USD, so:

- **Route by difficulty:** Tier-1 Opus for architecture / multi-file C# / subtle debugging /
  security-legal-structural work; Tier-2 Sonnet/auto for the routine ~80% (scoped edits, docs,
  search, validators); Tier-3 **Cornerman** (local, when live) for bulk summarize / context-prep /
  drafts at zero Cursor tokens. Start low, escalate to Opus the moment it's genuinely hard; when
  unsure, use Opus. Never gamble a hard problem on a weak model to save cost.
- **Session hygiene:** one focused chat per task, start fresh often, continue via a short summary
  into a new chat — long contexts re-bill as cache reads. Attach specific files/ranges, not folders.
- **Capture once:** decisions/learnings land in the single source of truth so nobody re-derives them.
- **Out of scope (do not reference, document, or build):** legacy EVO / EVORP / SPL-mute / null-EVORP
  tooling or branding — not part of LifePunch CVL or any lane. If you find stray mentions in docs you
  touch, remove them; do not add new ones.
- **Guardrails:** verify by stakes not model; local models prep but don't decide; commit only your
  own lane (Cornerman commits nothing it didn't author) and **never commit unprompted — ask the owner
  first**; dev/clones only — production needs owner approval; the stop hook won't commit/push
  merge-conflict markers.

## Identity & ownership

- LifePunch code: namespace `LifePunch.DXRP.Addons.*`, package `lifepunch.*`. Study public
  addons as patterns; never copy their identifiers (`SWB`, `SWE`, `BeCreativeRP`, …).
- Original from-scratch LifePunch content is **LifePunch IP** — may be licensed/sold to other
  servers and is defended (anti-clone + DMCA; see `lifepunch.co/tos` §5–6). Third-party/ported
  assets (Valve/CS2, s&box, community models) stay their owners' — used with attribution,
  never sold/redistributed. Third-party-modeled work stays under `reference/`, never published.
- Trademark / brand-architecture / proprietary-IP doctrine is now **law** in the
  **lifepunch-trademark-ip** rule (canonical: `lifepunch/legal/TRADEMARK_AND_IP.md`); licensing /
  EULA terms surface in the **website ToS** (`lifepunch.co/tos` §5–6). Keep legal boilerplate out
  of code comments — point to the rule/ToS instead.

## Architecture patterns

- DXRP weapons/equipment = **prefab + component composition** (Equipment root + child
  WeaponComponents; separate ViewModel prefab) — not per-gun god classes. Mirror official
  `m4a1`.
- Build **reusable templates, not one-offs**. Reference `dxura/dxrp @develop` for compatibility.

## Workflow & shipping

- Single shared `main`; **always `pull --rebase` + normal `push`; NEVER force-push.** A
  user-level auto-commit+push hook runs on `stop` (a backstop). Partner works the **website only** (disjoint).
- **Always-current (session-start auto-sync — FAILSAFE):** at the start of any session, before reading
  or editing, sync the clone (`git fetch`; if clean, `git pull --rebase`). If behind **and** dirty, stop
  and tell the owner. A bundled `sessionStart` hook (`.cursor/hooks/session-sync.*`) automates this in
  every lane; the always-on rule is the guaranteed layer (applies even with no prompt pasted). Law:
  `lifepunch-operating-context` (Git workflow → Always-current).
- **Commit consent — recommend then approve:** an agent **never commits unprompted**. At a natural
  checkpoint the agent states **scope + recommend commit (+ push if N commits behind)**; Bloodwave
  says `commit to main` or `commit and push`. Law: `GIT_CHECKPOINTS.md`.
- Addons must ship compiled `_c` files (the dedicated server doesn't compile). Servers enforce
  `RestrictCloudOrg="facepunch"` → assets must be **self-contained**, never cloud-referenced.
- Publish staging: `scripts/prepare-publish.ps1 -Addon <ident>`. Validate:
  `scripts/validate-workspace.ps1` (root) and `lifepunch/addons/scripts/validate-layout.ps1`.
- Don't publish a portal revision just to test a prefab offset — iterate locally first.

## Current direction (June 2026)

**Tonight (2026-06-14) — foundation if you lose chat context:**

| Topic | Canon |
|-------|-------|
| **Two repos** | Core `mragerlp/lifepunch` = law/WIP/quarantine. Publish `lifepunch-published` = export snapshot only. |
| **Quarantine** | Active dev: `adminmenu` + `bitcoinmining`. All other idents frozen — `portfolio.json`, `QUARANTINE_REGISTER.md` |
| **Publish now** | **`adminmenu` (`lifepunch.ulx`) only** — v1 ship-ready; LifePunch servers, not for resale |
| **Bitcoin** | Ophion P0 from `BITCOIN_OPHION_CURSOR_BRIEF.md` — active dev, **not** publish export until visual sign-off |
| **Ideation** | ChatGPT Step 1 → paste CURSOR BRIEF → Cursor VENGEANCE. `WORKFLOW_IDEATION_FIRST.md` · paste: `handoff/CHATGPT_STEP1_PASTE.txt` |
| **Git checkpoints** | Agent recommends scope; owner approves. `GIT_CHECKPOINTS.md` · handoff: `handoff/JUNE_2026_FOUNDATION_CHECKPOINT.md` |
| **Cornerman LM** | Headless `lms` on `:1234`. Dual MCP required — `Restore-CornermanDualStack.ps1` if off-Cursor. |
| **Dual s&box MCP** | `sbox` + `sbox-editor` on both VENGEANCE and Cornerman when paired. `SBOX_EDITOR_MCP.md` |
| **Pre-launch** | `Test-PreLaunchCheckup.ps1 -Fix` before editor work |

**Handoff paste for any node:** `AGENT_SYNC_BROADCAST.txt` after `git pull --rebase`.

**Recently landed (foundation is current as of this note):**
- **Ops clarity checkpoint — June 2026.** Voice web uniform (shortcut tiers, consoles, Explorer
  icons, PowerShell tab thumbnail, preflight surfaces) canonized in `OPS_CLARITY_CHECKPOINT.md`,
  `UNIFORM_STANDARDS.md`, `SHORTCUT_ICONS.md`, and agent sync broadcast. **Start Day** (tri-stack) =
  full stack; partial restarts = Voice Comms / Talk to Vengeance (red). Gray folder + `.txt` icons
  and the shared retro-desktop PowerShell thumbnail on all nodes.
- **Trademark / IP doctrine — finalized + law.** `lifepunch-trademark-ip` rule + the full
  `lifepunch/legal/` tree (`TRADEMARK_AND_IP.md`, marks, specimens, clearance evidence) are in.
- **Efficiency & cost discipline + Cornerman — merged.** Model-routing tiers (T1 Opus / T2
  Auto-Composer default / T3 Cornerman), session hygiene, knowledge-capture, and the multi-agent
  safeguards live in `lifepunch-operating-context`; mirror above. On Ultra, **Auto/Composer
  don't draw the $400 pool** — default there, reserve the pool for Tier-1 Opus.
- **GitLab lane organization — LIVE (lanes-synced).** Four projects under `gitlab.com/mragerlp`
  (`lifepunch-foundation`, `-addons`, `-website`, `-rdp-server`) created + pushed + protected `main`.
  GitHub monorepo stays canonical; GitLab is per-lane partner workspaces.
  Map: `GITLAB_ORGANIZATION.md` + `gitlab-projects.json`. Copy-paste: `AGENT_PROMPT.md`.
- **Trademark — operate under `™` now.** LIFEPUNCH runs on common-law rights while #402997/#397871
  are pending; use `LIFEPUNCH™`, never `®` until registration issues (see `lifepunch-trademark-ip`
  rule + `legal/TRADEMARK_AND_IP.md §7b`). Business wrapper: `docs/BUSINESS_CONTEXT.md`.

**Operational state:**
- Billing on individual **Ultra** (hard-stop at $400 API pool). **shottaWEB still on the shared
  Cursor Team plan** (live until ~next May), website lane. Routing unchanged: Auto/Composer default.
- Canonical repo: `https://github.com/mragerlp/lifepunch`. GitLab lanes synced.
- **Cornerman — LIVE.** Headless LM Studio on `:1234` (distill+embed VRAM; coder on disk until
  `WarmCoder`). Dual MCP when paired with VENGEANCE (`SBOX_EDITOR_MCP.md`). Day-one:
  `DAY_ONE_AGENT_PROMPT.md` · daily LM: `Fix-CornermanLmServe.ps1` · routing:
  `CORNERMAN_MODEL_ROUTING.md`.
- **RDP server agent:** **ACTIVE** — grounded and working its `lifepunch-rdp-server` lane, cloned over
  an SSH deploy key (clone + grounding verified). The RDP/server lane is core to Cornerman's security
  posture ("0 leaky pipes"). Its official prompt is Block C in `AGENT_PROMPT.md`.

**Open tracked items (see `lifepunch/addons/docs/TECH_DEBT.md`):**
- **STAFF-09** — `StaffMenuTestBots.cs` (dev-only test helper) is in `namespace Dxura.RP.Game;`
  (should move to a LifePunch namespace). It is now **excluded from publish staging**
  (`prepare-publish` skips `*TestBots.cs` / `*DevGive.cs` / `_dev/`), so it no longer blocks shipping;
  the namespace cleanup stays tracked.
- **EFF-01** — full validate-before-push hook gate is deferred until the validator is green
  (STAFF-09). The merge-conflict-marker guard in the stop hook is **active** now.

**Current / next build:**
- **Admin menu (`lifepunch.ulx`)** — **publish-ready v1**; export to `lifepunch-published`. Do not refactor without owner ask.
- **Bitcoin miner hub** — Ophion visual + player UX pass (active dev, not publish yet). `BITCOIN_OPHION_CURSOR_BRIEF.md`.
- **Hub pattern law** — `addons/docs/LIFEPUNCH_HUB_PATTERN.md` for all computer-heavy jobs.
- AK-47 and all quarantined idents — **paused** until promote + ChatGPT brief.
- New products: ChatGPT Step 1 brief **before** code.
