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

Also read `lifepunch/docs/WORKSPACE_STRUCTURE.md` and `lifepunch/docs/GITLAB_ORGANIZATION.md`.
Don't fork parallel grounding/docs — update the existing single source of truth.

If you are operating on (or setting up) the **local AI workstation** — the Corsair AI
Workstation 300 ("Strix Halo") box used as our private local inference/RAG node — read
`lifepunch/docs/LOCAL_AI_WORKSTATION.md`. That box is a clone, **never** the source of
truth; secrets stay quarantined off it and the same git rules apply.

## Named systems (shared vocabulary)

Use these names consistently so references are unambiguous across chats and agents:

- **Cornerman** — the LifePunch **local AI workstation** (Corsair AI Workstation 300,
  AMD Ryzen AI Max 385 / "Strix Halo"). A private, LAN-only local inference + RAG node that
  does the cheap heavy-lifting and context-prep (summaries, drafts, embeddings, triage) so
  frontier models handle the high-leverage thinking. It is a **clone, never the source of
  truth**, holds **no secrets**, and follows the same git rules as any agent. Full reference:
  `lifepunch/docs/LOCAL_AI_WORKSTATION.md`; day-one setup prompt:
  `lifepunch/docs/DAY_ONE_AGENT_PROMPT.md`. When anyone says "Cornerman," this is the box.
- **Primary PC** — the owner's main dev machine (`C:\Users\jared\Projects\lifepunchaddons`),
  live checkout of `https://github.com/mragerlp/lifepunch` = **source of truth**.
- **shottaWEB** — website partner; GitLab write lane = `lifepunch-website`.
- **RDP server agent** — server/portal/gamemode ops; GitLab write lane = `lifepunch-rdp-server`.

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
- **Commit consent — ask first:** an agent **never commits unprompted**. When work hits a natural
  commit point, *ask the owner whether to commit* (propose scope + message) and commit only on an
  explicit yes. This is law in `lifepunch-operating-context` (Git workflow → Commit consent).
- Addons must ship compiled `_c` files (the dedicated server doesn't compile). Servers enforce
  `RestrictCloudOrg="facepunch"` → assets must be **self-contained**, never cloud-referenced.
- Publish staging: `scripts/prepare-publish.ps1 -Addon <ident>`. Validate:
  `scripts/validate-workspace.ps1` (root) and `lifepunch/addons/scripts/validate-layout.ps1`.
- Don't publish a portal revision just to test a prefab offset — iterate locally first.

## Current direction (June 2026)

**Recently landed (foundation is current as of this note):**
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
- **Cornerman** (local AI box) arriving imminently — bring-up via `DAY_ONE_AGENT_PROMPT.md`;
  reference `LOCAL_AI_WORKSTATION.md`; optional experimental Odysseus layer documented (§8).
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
- The **in-game staff/admin menu** (server-agnostic, driven by `lifepunch/admin-panel/` roles +
  `permissions/matrix.md`, LifePunch-owned IP, branded `lifepunch.ulx`) is **built and shipping its
  v1** to the DXRP portal.
- AK-47 weapon work remains **paused**.
- For any new addon: propose feature set + architecture + permission mapping for sign-off **before**
  building.
