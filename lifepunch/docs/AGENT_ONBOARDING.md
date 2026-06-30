# LIFEPUNCH™ × DXRP — Agent Foundation

> Read this first. Hand it to any agent in any of our repos so it operates inside
> the established foundation instead of re-deriving (or diverging from) it.
> This doc **mirrors** the always-on `.cursor/rules` — the rules are the law; if
> they ever disagree with this doc, the rules win and this doc should be updated.

## Who / what

LifePunch (**LIFEPUNCH™**) is the largest community server for **DXRP**, a source-available DarkRP-style
RP game by **Dxura**, built on **s&box** (Facepunch's Source 2 engine). We build
high-quality custom content (weapons, entities, staff/admin tooling, UI, gamemode/server
ops) for our server and to license to other DXRP servers. Treat this as a business: be
direct, ship quality.

## CVL design brain — Architect

**Architect** = ChatGPT Plus/Pro on **VENGEANCE** (Red) — formal design role in the LifePunch web.
Architect asks **"Does this make the game better?"** Cursor (Integrator) asks **"Does this ship?"**

| Brain | Tool | Ships code? |
|-------|------|-------------|
| **Architect** | ChatGPT LIFEPUNCH™ Project | No — CURSOR BRIEFs + design docs |
| **Integrator** | Cursor on Red | Yes (owner commit consent) |
| **Distiller** | Cornerman LM on Green | No — outbox prep |

Canon: `lifepunch/docs/ARCHITECT.md` · paste: `handoff/ARCHITECT_ONBOARDING_PASTE.txt`

## LIFEPUNCH™ branding (agents — law)

**LIFEPUNCH™** is our only owned mark (legal entity: **Peak Performance Products LLC**). Agents
must keep the brand consistent in docs, UI copy, listings, and product names.

| Rule | Do |
|------|-----|
| **Source identifier** | Spell **`LIFEPUNCH™`** in all-caps for the brand mark in agent-facing docs and product naming. |
| **Registration** | Use **`™` only** while #402997 / #397871 are pending. **Never `®`** until the USPTO issues registration. |
| **Product names** | **Lead with LIFEPUNCH** — e.g. "LIFEPUNCH Admin Menu for DXRP", not "DXRP Admin Menu". |
| **Third-party marks** | **DXRP / Dxura / s&box / Facepunch** — nominative use only; never imply affiliation or ownership. |
| **Proprietary goods** | Original LIFEPUNCH content is sole-owned IP — not for resale/redistribution by others (see website ToS §5–6). |
| **Community** | Public Discord invite: **`https://discord.gg/lifepunch`** (replaces legacy `discord.gg/lifepunchco`). |
| **Website** | **`https://lifepunch.co`** — Class 41 services specimen; community + server list. |

Canonical trademark/IP detail: `lifepunch/legal/TRADEMARK_AND_IP.md` + **lifepunch-trademark-ip** rule.
Business wrapper: `lifepunch/docs/BUSINESS_CONTEXT.md`.

## Mandatory reads — every session (lean)

| Order | Doc | Why |
|-------|-----|-----|
| 1 | `addons/docs/ACTIVE_WORKSTREAM.md` | Single lane gate |
| 2 | `.cursor/rules` (alwaysApply) | Repo law |
| 3 | `addons/docs/CYBER_REFERENCE_LAWS.md` | Cyber production gate (when on entity/addon work) |
| 4 | `addons/docs/BITCOIN_SHIP_ROADMAP.md` | Step order (bitcoin lane only) |

## Mandatory reads — gameplay / product (when touching design, UX, economy doctrine)

| Order | Doc | Why |
|-------|-----|-----|
| 1 | `lifepunch/docs/LIFEPUNCH_GAMEPLAY_LAWS.md` | G0–G9; Fantasy Check |
| 2 | `lifepunch/docs/LIFEPUNCH_FEEL.md` | Product identity bar |
| 3 | `lifepunch/docs/TERMINOLOGY.md` | Shared vocabulary |
| 4 | `addons/docs/BITCOIN_PLAYER_DESIGN.md` | Bitcoin fantasy (bitcoin lane only) |

## On demand only (do not read on every boot)

| Doc | When |
|-----|------|
| `WORKSTREAM_RESTART_WORKFLOW.md` | Parallel work closed (upstream bounty, side lane) → resume active gate |
| `OWNERSHIP_MATRIX.md` | Role/routing confusion |
| `DECISIONS/README.md` + specific `DECISION-####` | Cite settled design |
| `KNOWLEDGE/**` | Balance, rejections, lane notes for active task |
| `PATTERN_LIBRARY.md` | New pattern / clone target search |
| `RFC/RFC-0005-Hub-Upgrades.md` | Hub upgrade work only (Draft — no implementation until GO) |
| `templates/**` | Architect opening new product doc |
| `scratch/**` | Brainstorm only — never canon |
| `ARCHITECT.md` | Architect/Integrator handoff detail |

## Mandatory reads — entity / ModelDoc work

| Order | Doc | Why |
|-------|-----|-----|
| 1 | `addons/docs/ACTIVE_WORKSTREAM.md` | Single lane gate |
| 2 | `addons/docs/LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md` | Machines not props; P0–P4 |
| 3 | `addons/docs/MODEL_FOUNDATION_PASS.md` | Mesh sign-off before prefab |
| 4 | `addons/docs/MODELDOC_STUDIO_LANE.md` | Standalone editor (no DXRP) |
| 5 | `addons/docs/PACKAGE_STAGING_LAYOUT.md` | `lp*` staging paths |
| 6 | `addons/docs/DXRP_ADDON_PUBLISH_DOCTRINE.md` | Folder=slug, PLACEHOLDER hands-off, portal vs files |
| 7 | `addons/docs/CYBER_REFERENCE_LAWS.md` | Laws 1–11 |

**Weapons (parallel track — not bitcoin gate):**

| Order | Doc | Why |
|-------|-----|-----|
| 1 | `addons/docs/LIFEPUNCH_WEAPON_IMPLEMENTATION_LAW.md` | Platform stack P0–P5 |
| 2 | `addons/docs/WEAPON_INTAKE.md` | Import + naming |
| 3 | `addons/docs/VIEWMODEL_RIG_PIPELINE.md` | FP rig bind |
| 4 | `docs/lanes/AK47_LANE.md` | Quarantine branch only |

Cursor plugins: **Convex** = optional realtime backend only — not s&box entities or weapons.

## Opus usage law (Tier-1 / API pool)

**Canonical:** `lifepunch/docs/OPUS_USAGE_LAW.md` · rule: **lifepunch-opus-usage**.

| Use Opus for | Avoid Opus for |
|--------------|----------------|
| Architecture, debugging, MCP workflows, ModelDoc setup, multi-file C#, Razor UI **blockers**, Phase-1 planning (no code) | README, changelogs, Discord, marketing, doc formatting |

**Four-phase workflow (major tasks):**

1. **Opus — plan only** (files, risks; no code)
2. **Opus — implement one slice** (Phase A / one checklist ID)
3. **Flatgrass proof** (bridge + USE — Law 5)
4. **Opus — review** (defects before next slice)

**lifepunchbitcoin strict scope:** Opus on **Hub** until flatgrass sign-off → **Terminal** → **GPU Rack**.
Connect Anthropic API key in Cursor Settings first; never commit keys.

Hub Opus queue (one slice per Phase 2): collision validation → power state → fan animation → LED state machine → telemetry overlays → interaction polish.

## Publish addons (June 2026 — two-repo law)

**Build in core. Export when portal-ready. Never invent law in the publish clone.**

| Layer | Repo | Role |
|-------|------|------|
| **Core** | `github.com/mragerlp/lifepunch` | All WIP, quarantine, docs, legal, MCP, website, server |
| **Publish** | `github.com/mragerlp/lifepunch-published` | **Portal-ready snapshot only** — clean tree for DXRP upload |

**Manifests (read every addons session):**

- `lifepunch/addons/config/portfolio.json` — `activeAddons` (in-scope dev) · `publishReadyAddons` (export set)
- `lifepunch/addons/config/packages.json` — **packageSlug** law (`lifepunchulx`, `lifepunchbitcoin`, …)
- `lifepunch/addons/docs/PACKAGE_NAMING_STANDARD.md` — public branch + s&box ident naming

**Workflow:**

```text
ChatGPT Step 1 brief → Cursor build (core monorepo) → owner portal-ready sign-off
       ↓
Export-LifepunchPublishLane.ps1  (-Target publish clone; reads publishReadyAddons)
       ↓
prepare-publish.ps1 -Addon <repoIdent>  → DXRP portal Assets + Code upload
```

- **Day-to-day commits:** always on **core** `main`.
- **Export:** only when an ident is in `publishReadyAddons` (today: **`adminmenu` / lifepunchulx** only).
- **Publish repo never contains:** quarantined idents, `reference/`, dev helpers (`*DevSpawn*`, `*TestBots*`), full monorepo docs.
- **Display on portal/listings:** **LIFEPUNCH™** lead · DXRP nominative · **`™` not `®`**.

Full detail: `lifepunch/docs/PUBLISH_REPO_LANE.md` · checkpoints: `GIT_CHECKPOINTS.md`.

## Quarantine (frozen idents — concepts only)

**June 2026 phase:** `ophion-rebuild-2026-06`. Only **`adminmenu`** + **`bitcoinmining`** are active compile/ship work.

Everything in `portfolio.json` → `quarantinedAddons` is **frozen on disk** — not deleted, **not extended**, **not copied into active code paths**, **not exported** to `lifepunch-published`.

| Agents MAY | Agents MUST NOT |
|------------|-----------------|
| Read quarantined files for **concepts, UX ideas, economy notes, prior art** | Edit quarantined `.cs` / `.razor` / assets without owner **promotion** |
| Cite a quarantined ident in a **brief or TECH_DEBT** when comparing approaches | Import types, prefabs, SCSS, or patterns from quarantined trees into active addons |
| Restore via owner promotion workflow | Use quarantined code as a **template to paste** into `adminmenu` or `bitcoinmining` |
| | Run `prepare-publish` / export for quarantined idents |
| | Mount quarantined packages in DXRP-only sync scripts unless owner says otherwise |

**Promotion (owner-only):** name ident → move to `activeAddons` in `portfolio.json` → remove `<Compile Remove>` in `addons.csproj` → ChatGPT Step 1 brief if new UX.

Register + reasons: `lifepunch/addons/docs/QUARANTINE_REGISTER.md`. Ideation gate: `WORKFLOW_IDEATION_FIRST.md`.

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

**Law — before addon or editor work:** DXRP `develop` must match upstream. Run:

```powershell
powershell -File lifepunch\scripts\Ensure-DxrpUpstreamCurrent.ps1 -Sync -UpdatePin -SyncSteam
powershell -File lifepunch\scripts\Sync-LifePunchAddonsToDxrp.ps1 -Addon bitcoinmining
```

Verified tip is recorded in `lifepunch/config/dxrp-upstream-pin.json` (commit after each upstream bump).
`Start-SboxDxrpEditor.ps1` blocks launch when the pin is behind (`-FailIfBehind`).

1. **`mragerlp/dxrp-public`** → our DXRP fork (`origin=dxrp-public`, `upstream=dxura/dxrp`).
   Local clone: `C:\Users\jared\Projects\dxrp-public`. Synced via `sync-dxrp-fork.ps1` (ff-merge upstream `develop`).
   **Upstream bounty / vanilla DXRP work:** read **`lifepunch/docs/DXRP_CONTRIBUTOR_LANE.md`** first — separate focus from LifePunch proprietary addons; never commit LifePunch headers or local MCP `game/Libraries/*` into the fork.
   **Party #73 new chat:** paste **`lifepunch/docs/handoff/DXRP_PARTY_CURSOR_BOOTSTRAP_PASTE.txt`** alone, or **Block F** in `AGENT_PROMPT.md`.
2. **The Steam checkout** (`D:\Steam\steamapps\common\sbox\dxrp`, `origin=dxura/dxrp`) →
   read-only **upstream** runtime/test copy where the editor runs. Aligned via `Sync-DxrpSteamCheckout.ps1`.
   **Never** commit LifePunch work here.

### 4. Publish lane → portal snapshot (not law)

**`mragerlp/lifepunch-published`** — export-only tree for DXRP portal. Built by
`Export-LifepunchPublishLane.ps1` from **`publishReadyAddons`** in `portfolio.json` (not
`activeAddons` — bitcoin can be active but not publish-ready). Core monorepo stays where all
agents work. See **Publish addons** + `PUBLISH_REPO_LANE.md` + `GIT_CHECKPOINTS.md`.

## Grounding = the monorepo's `.cursor/rules` (alwaysApply) are law

- **lifepunch-operating-context** — business style; **asset ownership default = ours**, do
  NOT raise provenance / "is this ok to ship" concerns (the user flags external work
  explicitly); git workflow; publish notes; Tier 1/2/3 pools.
- **lifepunch-opus-usage** — Opus/API pool law; four-phase workflow; Hub → Terminal → GPU Rack scope.
  Full detail: `lifepunch/docs/OPUS_USAGE_LAW.md`.
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
- **lifepunch-commit-hygiene** — **no AI/agent attribution in commits** (no `Co-authored-by: Cursor`,
  Claude, Copilot, …); author is `mragerlp` only. Keep Cursor **Settings → Agent → Attribution**
  (Commit + PR) OFF; install the backstop hook per clone via `Install-CommitHygieneHook.ps1`. Critical
  on the public DXRP fork (`dxrp-public` → `dxura/dxrp`). Recovery (already-committed trailer): the
  Cursor wrapper hooks `git commit*`, so strip with `git filter-branch --msg-filter` then
  `--force-with-lease`. Upstream lane detail: `lifepunch/docs/DXRP_CONTRIBUTOR_LANE.md`.

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
`AGENT_SYNC_BROADCAST.txt` into any stale chat to force **evergreen** alignment (pull/sync → identify node → read `ACTIVE_WORKSTREAM` → lane prompt). **Do not** treat dated session overrides inside old broadcasts as current law — product status lives in `handoff/ARCHITECT_CURRENT_STATE.md`. **Block 0** in
`AGENT_PROMPT.md` now carries an inline CVL tri-stack summary — paste Block 0 even when skipping long reads.

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

**Agent-facing aliases:** **Bloodwave** = visible name (in-game · Steam · Discord · agent chat).
**mrragerlp** = proprietary/legal author on code. **Mr. Rager** = email/legacy contact (same person).
GitHub remote stays `mragerlp/lifepunch`. `BLOODWAVE_ALIAS.md`.
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

- **Digital machines, not props** — every entity = Model → Collision → Physics → Attachments →
  Lights → Animation → Sound → State → Gameplay. Mesh is P0 only. Canon:
  `lifepunch/addons/docs/LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md` + **lifepunch-digital-machine** rule.
- **ModelDoc Studio** — standalone `modeldoc.sbproj` for mesh work without DXRP gamemode load:
  `MODELDOC_STUDIO_LANE.md` · `Start-SboxModelDocStudio.ps1`.
- **Package staging** — Fab intake under `lp{package}/{entity}/assets|code` (not legacy `_modeldoc/game/`):
  `PACKAGE_STAGING_LAYOUT.md` · **Publish doctrine:** `DXRP_ADDON_PUBLISH_DOCTRINE.md` (folder name = entity slug;
  **UPLOAD READY ADDONS PLACEHOLDER** = finished addons only — agents hands-off unless owner asks).
- **Weapon platform** — not gun mesh; attachments, bones, anims, states per
  `LIFEPUNCH_WEAPON_IMPLEMENTATION_LAW.md` + **lifepunch-weapon-platform** rule (`lpweapons`, `lane/ak47`).
- DXRP weapons/equipment = **prefab + component composition** (Equipment root + child
  WeaponComponents; separate ViewModel prefab) — not per-gun god classes. Mirror official
  `m4a1`.
- Build **reusable templates, not one-offs**. Reference `dxura/dxrp @develop` for compatibility.

## DXRP & publish staging (June 2026 — agent law)

**DXRP** (Dxura) = gamemode platform for community servers. **LIFEPUNCH** = our proprietary addon brand on top — unique content vs other DXRP hosts.

**Canonical:** `lifepunch/addons/docs/DXRP_ADDON_PUBLISH_DOCTRINE.md`

Quick rules:

1. **`lpbitcoin/{entity}/`** — entity folder name **is** the slug (`bitcoinhub`, `hashdterminal`, …).
2. **PLACEHOLDER** (`Desktop\UPLOAD READY ADDONS PLACEHOLDER\addons\lifepunch`) — finished, upload-ready packages only. **Agents do not touch** unless owner explicitly asks.
3. **Portal names** (market, content rows, display labels) — owner sets in dxrp.net after upload; not a dev-path blocker.
4. **Dev vs ship** — iterate in repo (`bitcoinmining` playtest OK); promote to `lpbitcoin/` when signed off; then owner fills PLACEHOLDER when ready to publish.

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

**Current (2026-06-30) — lifepunchbitcoin active to portal:**

| Topic | Canon |
|-------|-------|
| **Active task** | **`lifepunchbitcoin`** / `lpbitcoin` — **Phase A Hub polish** (`ACTIVE_WORKSTREAM.md`). **Next slice: H4 + H5** (world power/audio — **GO H4/H5 HUB STATE** before code). **Phase B Terminal** locked until H10. Upgrade migration + economy overhaul **HOLD**. |
| **New chat boot** | **`lifepunch/docs/handoff/CURSOR_NEW_CHAT_BOOTSTRAP_PASTE.txt`** — paste **alone** at fresh Cursor session; agent fills FIRST REPLY block; no extra owner directions unless task line appended. |
| **Machine (Cursor)** | **VENGEANCE** (Integration Architect / Cursor Red) — confirm in first reply, not "digital machine stack" product law. |
| **Owner GO (H4/H5)** | `GO H4/H5 HUB STATE — World LED: … Point light: … Route: GROK REQUIRED \| AUTO OK \| OPUS REQUIRED. H4+H5 one commit.` |
| **Opus / API** | Owner wants **Opus on hard bitcoin slices** (terminal, economy, integration). Anthropic API pool via Cursor Settings; Auto/Composer for routine work. `OPUS_USAGE_LAW.md`. |
| **Editor workbench** | DXRP + LifePunch mounts — sync `lpbitcoin` when coding: `Sync-LifePunchAddonsToDxrp.ps1 -Addon lpbitcoin`. Full stack: `Start-SboxDxrpEditor.ps1 -FullCapacity -PreflightFix -BitcoinOnly -SyncAddon lpbitcoin,adminmenu`. |
| **`lp_*` ConCmds** | Bitcoin dev ConCmds OK for playtest (`lp_bitcoin_preview_hub`, spawn kit, etc.). Do not add unrelated ConCmds (Law 9). |
| **ULX** | `adminmenu` r10 Set Job committed — parallel portal ship when owner says; does not pause bitcoin gate. |
| **Monnow** | Rev 9 path `monnowprinterlp/monnowprinter.prefab` — staging ready; portal pin pending (parallel lane). |
| **CVL stack** | `Start-CvlFullCapacity.ps1` · `Get-CvlConnectivityStatus.ps1 -Pretty` → `allOk: true`. Reload Cursor after MCP changes. |
| **Dual IDE** | **Cursor** = write / MCP / proof / commit. **VS Code Copilot** = mirror reviewer only (not second writer). **Cornerman** = distill. **Codex** = PASS·REVISE·HOLD. **Bloodwave** = GO. `DUAL_IDE_CURSOR_VSCODE.md` |

**Prior (2026-06-22) — ULX vanilla workbench session (historical — superseded for bitcoin lane):**

| Topic | Canon |
|-------|-------|
| **ULX-only override** | Was: vanilla DXRP, no sync, no `lp_*` — use only when owner explicitly runs ULX-only session with `-NoSync`. |
| **ULX baseline** | `adminmenu/` locked to **v3.0.0 r6** (`ba4a305`). No scroll-region migration without owner sign-off. |

**Prior (2026-06-18) — foundation if you lose older context:**

| Topic | Canon |
|-------|-------|
| **Two repos** | Core `mragerlp/lifepunch` = law/WIP/quarantine. Publish `lifepunch-published` = export snapshot only. |
| **Quarantine** | Active dev: `adminmenu` + `bitcoinmining` only. All other idents **frozen** — concepts/context OK, **no edits, no copy-paste ship paths** — `portfolio.json`, `QUARANTINE_REGISTER.md` |
| **Publish now** | **`lifepunchulx`** (`adminmenu`) only — in `publishReadyAddons`; export via `Export-LifepunchPublishLane.ps1` |
| **Bitcoin** | P0 hub = **Steam Machine** static chassis (dev: `bitcoinmining/` · promote to `lpbitcoin/bitcoinhub/`). Folder name = slug (`bitcoinhub`, not `bitcoin-miner`). **Digital machine** stack · `DXRP_ADDON_PUBLISH_DOCTRINE.md` · `LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md` |
| **Ideation** | **Architect** (ChatGPT Step 1) → paste CURSOR BRIEF → Cursor Integrator on VENGEANCE. Voice = **Cursor mic** (Whisper deferred). `WORKFLOW_IDEATION_FIRST.md` |
| **Architect** | Design brain on Red — `ARCHITECT.md` · `handoff/ARCHITECT_*.txt` |
| **ChatGPT templates** | Step1 · Visual pass · Edit session · Ship checklist — `handoff/CHATGPT_*.txt` · index: `briefs/BRIEF_INDEX.md` |
| **Owner alias** | Visible: **Bloodwave** · Proprietary: **mrragerlp** · Contact: Mr. Rager — `BLOODWAVE_ALIAS.md` |
| **Git checkpoints** | Agent recommends scope; owner approves. `GIT_CHECKPOINTS.md` · handoff: `handoff/JUNE_2026_FOUNDATION_CHECKPOINT.md` |
| **Cornerman LM** | Headless `lms` on `:1234`. Dual MCP when Green Cursor active — `Restore-CornermanDualStack.ps1` |
| **Dual s&box MCP** | `sbox` + `sbox-editor` on VENGEANCE every edit session. `SBOX_EDITOR_MCP.md` · bar: `SBOX_EDIT_STANDARDS.md` |
| **ModelDoc Studio** | Standalone editor — **no DXRP gamemode** for mesh passes. `MODELDOC_STUDIO_LANE.md` · `Start-SboxModelDocStudio.ps1` |
| **Digital machines** | Not props — full stack in `LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md` · P0 = ModelDoc sign-off first |
| **Weapon platform** | Not gun mesh — `LIFEPUNCH_WEAPON_IMPLEMENTATION_LAW.md` · `lpweapons` + AK lane parallel to bitcoin |
| **lp* staging** | `lpbitcoin/bitcoinhub|hashdterminal|gpurack` (advanced tier = gpurack variant; retired slug `advancedgpurack`) · `PACKAGE_STAGING_LAYOUT.md` · `DXRP_ADDON_PUBLISH_DOCTRINE.md` · PLACEHOLDER = upload-ready only (agents hands-off) · sync: `Prepare-LpBitcoinModelDoc.ps1` |
| **Pre-launch** | `Test-PreLaunchCheckup.ps1 -Fix` then `Start-SboxModelDocStudio.ps1` (mesh) or `Start-SboxDxrpEditor.ps1` (DXRP play) |

**Handoff paste for any node:** evergreen `AGENT_SYNC_BROADCAST.txt` after `git pull --rebase`; dated product state in `handoff/ARCHITECT_CURRENT_STATE.md`.

**Recently landed (foundation is current as of this note):**
- **Digital machine + weapon platform laws — June 2026.** Entity props = machines
  (`LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md` + **lifepunch-digital-machine** rule). Weapons = platforms
  (`LIFEPUNCH_WEAPON_IMPLEMENTATION_LAW.md` + **lifepunch-weapon-platform** rule). Block 0 items 0c–0e
  in `AGENT_PROMPT.md`. Baselines tracked in `TECH_DEBT.md` (MACHINE-*, WEAPON-*).
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
- **Bitcoin miner hub** — ModelDoc foundation + machine hierarchy (P0 mesh → P1 attachments/lights → states). `LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md` · `MODEL_FOUNDATION_PASS.md`.
- **Hub pattern law** — `addons/docs/LIFEPUNCH_HUB_PATTERN.md` for all computer-heavy jobs.
- AK-47 and all quarantined idents — **paused** until promote + ChatGPT brief.
- New products: **Architect** Step 1 brief **before** code (`ARCHITECT.md`).
