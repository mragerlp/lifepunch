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

## Three repos — know where you are

1. **`mragerlp/lifepunch` → THE SOURCE OF TRUTH** (private monorepo). Live local checkout:
   `C:\Users\jared\Projects\lifepunchaddons`. Holds the isolated `lifepunch/addons/` s&box
   project, `gamemode/`, `server/`, `admin-panel/`, `portal/`, `website/`, `economy/`,
   `audit/`, `docs/`, and the `.cursor/rules`. **Do all design/build work here.**
   (Do **not** use any OneDrive clone — removed June 2026 as a git-corruption risk.)
2. **`mragerlp/dxrp-public`** → our DXRP fork (`origin=dxrp-public`, `upstream=dxura/dxrp`).
   Synced via `lifepunch/scripts/sync-dxrp-fork.ps1` (ff-merge upstream `develop`).
   Integration/test.
3. **The Steam checkout** (`D:\Steam\steamapps\common\sbox\dxrp`, `origin=dxura/dxrp`) →
   a read-only **upstream** runtime/test copy where the editor runs. **Never** commit
   LifePunch work or grounding here; you cannot push (it's Dxura's repo) and it must not
   diverge from repo #1.

## Grounding = the monorepo's `.cursor/rules` (alwaysApply) are law

- **lifepunch-operating-context** — business style; **asset ownership default = ours**, do
  NOT raise provenance / "is this ok to ship" concerns (the user flags external work
  explicitly); git workflow; publish notes.
- **lifepunch-quality-bar** — **NO SPAGHETTI**: use the engine's systems as designed, prefer
  the fully-owned solution, no hidden-master/passenger/invisible-material hacks, no
  dead/orphan assets. If an interim hack is unavoidable: call it out, offer the clean path,
  and TRACK it in `lifepunch/addons/docs/TECH_DEBT.md`. Never present a hack as "done".
- **dxrp-addon-foundation** — folder lane + validators; `addons.json` is source of truth.
- **lifepunch-rules-workflow** + **lifepunch-website-organization** — website/rules deploy.

Also read `lifepunch/docs/WORKSPACE_STRUCTURE.md`. Don't fork parallel grounding/docs —
update the existing single source of truth.

## Identity & ownership

- LifePunch code: namespace `LifePunch.DXRP.Addons.*`, package `lifepunch.*`. Study public
  addons as patterns; never copy their identifiers (`SWB`, `SWE`, `BeCreativeRP`, …).
- Original from-scratch LifePunch content is **LifePunch IP** — may be licensed/sold to other
  servers and is defended (anti-clone + DMCA; see `lifepunch.co/tos` §5–6). Third-party/ported
  assets (Valve/CS2, s&box, community models) stay their owners' — used with attribution,
  never sold/redistributed. evo's Bitminer is reference-only, never published.
- Legal/licensing terms live in the **website ToS**, not in agent rules or code comments.

## Architecture patterns

- DXRP weapons/equipment = **prefab + component composition** (Equipment root + child
  WeaponComponents; separate ViewModel prefab) — not per-gun god classes. Mirror official
  `m4a1`.
- Build **reusable templates, not one-offs**. Reference `dxura/dxrp @develop` for compatibility.

## Workflow & shipping

- Single shared `main`; **always `pull --rebase` + normal `push`; NEVER force-push.** A
  user-level auto-commit+push hook runs on `stop`. Partner works the **website only** (disjoint).
- Addons must ship compiled `_c` files (the dedicated server doesn't compile). Servers enforce
  `RestrictCloudOrg="facepunch"` → assets must be **self-contained**, never cloud-referenced.
- Publish staging: `scripts/prepare-publish.ps1 -Addon <ident>`. Validate:
  `scripts/validate-workspace.ps1` (root) and `lifepunch/addons/scripts/validate-layout.ps1`.
- Don't publish a portal revision just to test a prefab offset — iterate locally first.

## Current direction (June 2026)

- AK-47 weapon work is **paused**. Next foundation build: an **in-game staff/admin menu**
  addon that works on ANY DXRP server, driven by the existing policy in
  `lifepunch/admin-panel/` (roles + `permissions/matrix.md`). Server-agnostic, config-driven,
  LifePunch-owned IP.
- Propose feature set + architecture + permission mapping for sign-off **before** building.
