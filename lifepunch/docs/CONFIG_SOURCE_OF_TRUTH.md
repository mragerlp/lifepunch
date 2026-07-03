# LIFEPUNCH™ — Config source of truth

**Status:** Restructure Phase 3 — index only (no file moves).  
**Updated:** 2026-06-30  
**Read with:** `REPO_DOMAIN_MAP.md` · `PATH_CANON_VENGEANCE.md` (desk clone paths) · `CONFIG_SOURCE_OF_TRUTH` is the answer to *“which file is law?”*

When two files disagree, **fix the canonical file** listed here — do not fork duplicates.

---

## Quick lookup

| Question | Canonical file |
|----------|----------------|
| Which addons exist / ownership headers? | `lifepunch/addons/config/addons.json` |
| Public package slug vs packageFolder parent? | `lifepunch/addons/config/packages.json` + `package-staging.json` |
| Active vs quarantined idents? | `lifepunch/addons/config/portfolio.json` |
| Entity staging layout? | `lifepunch/addons/config/package-staging.json` |
| GitLab export paths? | `lifepunch/docs/gitlab-projects.json` |
| MCP port law? | `lifepunch/config/sbox-mcp-ports.json` |
| CVL machine pins? | `lifepunch/config/cvl-stack-pins.json` |
| Cornerman Tier-3 models? | `lifepunch/config/cornerman-tier3-models.json` |
| DXRP upstream pin (fork)? | `lifepunch/config/dxrp-upstream-pin.json` |
| Gamemode addon revision pins? | `lifepunch/gamemode/config/addon-revisions.json` |
| Hosted server records? | `lifepunch/server/config/servers.json` |
| lifepunchnet install layout (Official vs Dev roots)? | `lifepunch/server/LIFEPUNCHNET_HOST_LAYOUT.md` |
| DXRP host launchers + deploy? | `lifepunch/server/dxrp-host/README.md` |
| Staff roles? | `lifepunch/admin-panel/config/admin-roles.json` |
| lifepunch.co pages? | `lifepunch/website/config/*.json` |
| Publish export manifest (live ship repo)? | `lifepunch-published/config/addons.json` (export output) |

---

## By domain

### PRODUCT — addons

| Path | Role | Editor |
|------|------|--------|
| `lifepunch/addons/config/addons.json` | Addon titles, s&box idents, proprietary metadata | Owner |
| `lifepunch/addons/config/packages.json` | `packageSlug` ↔ `repoIdent` ↔ s&box ident | Owner |
| `lifepunch/addons/config/portfolio.json` | `activeAddons`, `publishReadyAddons`, quarantine list | Owner |
| `lifepunch/addons/config/package-staging.json` | `lp*` entity folder staging | Owner |
| `lifepunch/addons/config/portal/*.json` | Portal content placeholders (dev) | Owner |
| `lifepunch/addons/config/weapon-production.json` | Weapon pipeline queue (quarantine lane) | Owner |
| `lifepunch/addons/config/cs2-weapon-catalog.json` | Reference catalog | Owner |
| `lifepunch/addons/config/gear-production.json` | Gear pipeline | Owner |
| `lifepunch/addons/config/drop-sites.json` | Map drop coords (quarantine) | Owner |

**Not source of truth:** `lifepunch/publish-lane/scaffold/config/addons.json` — scaffold only; live ship = `lifepunch-published`.

### PLATFORM — DXRP ops

| Path | Role | Editor |
|------|------|--------|
| `lifepunch/gamemode/config/gamemode.json` | Gamemode integration | Owner / RDP agent |
| `lifepunch/gamemode/config/addon-revisions.json` | Pinned addon versions on servers | Owner / RDP agent |
| `lifepunch/gamemode/config/equipment.json` | Equipment rows | Owner |
| `lifepunch/gamemode/config/market.json` | Market rows | Owner |
| `lifepunch/gamemode/config/vanilla-gamemode.json` | DXRP baseline reference | Owner |
| `lifepunch/gamemode/config/gamemode-page.json` | Portal gamemode page fields | Owner |
| `lifepunch/gamemode/config/lpmonnowsprinterupgrade-portal.json` | Side-lane portal row | Owner |
| `lifepunch/server/config/servers.json` | lifepunchmainserver / development | RDP agent |
| `lifepunch/server/LIFEPUNCHNET_HOST_LAYOUT.md` | lifepunchnet split roots, engine policy, deploy law | RDP agent |
| `lifepunch/server/dxrp-host/README.md` | Launcher wrappers + `Deploy-DxrpHostLaunchers.ps1` | RDP agent |
| `lifepunch/server/config/server-page-fields.json` | dxrp.net server page | RDP agent |
| `lifepunch/portal/config/*.json` | Portal tab docs | RDP agent |
| `lifepunch/admin-panel/config/admin-roles.json` | Staff hierarchy | Owner |
| `lifepunch/audit/config/audit-taxonomy.json` | Audit workflows | Owner |
| `lifepunch/players/config/player-profile-fields.json` | Player support fields | Owner |

### BUSINESS

| Path | Role | Editor |
|------|------|--------|
| `lifepunch/website/config/*.json` | Site page config (store, rules, auth, …) | shottaWEB + owner |
| `lifepunch/legal/` | Trademark/IP (markdown + specimens) — not JSON | Owner |

**Rules (Cloudflare):** OneDrive `Rules-Test1.txt` is canonical for active rules work; repo mirror `lifepunch/website/deployments/Rules/Rules-Test1.txt` — see **lifepunch-rules-workflow** rule.

### TOOLING — machine / agents

| Path | Role | Editor |
|------|------|--------|
| `lifepunch/config/sbox-mcp-ports.json` | chomnr `:9090`, jtc `:29015`, bridge IPC | Owner |
| `lifepunch/config/cvl-stack-pins.json` | CVL node pins | Owner |
| `lifepunch/config/cornerman-tier3-models.json` | Local LM catalog | Owner |
| `lifepunch/config/dxrp-upstream-pin.json` | dxrp-public fork baseline | Owner |
| `lifepunch/config/tailwand.config.json` | Tail/wand tooling | Owner |
| `lifepunch/docs/gitlab-projects.json` | GitLab lane `monorepoPaths` | Owner |
| `.cursor/rules/` | Agent law | Owner (monorepo only) |
| `scripts/validate-workspace.ps1` | Workspace layout checks | Owner |

**Root vs nested scripts config:** There is **no** repo-root `config/` folder. All machine JSON lives under `lifepunch/config/`.

### PUBLISH (external repo)

| Path | Role |
|------|------|
| `github.com/mragerlp/lifepunch-published` | Export target — `Export-LifepunchPublishLane.ps1` |
| `SYNC_FROM.md` (in publish repo) | Last export SHA — script-written |

---

## Known drift (Phase 4 migration — not fixed here)

| Drift | Canonical target | Today |
|-------|------------------|-------|
| `repoIdent` `bitcoinmining` vs staging `lpbitcoin/` | `PACKAGE_NAMING_STANDARD.md` | Dual tree — validators flag paths |
| `adminmenu` vs `lifepunchulx` slug | `packages.json` | Folder rename deferred |
| Monnow printer paths | TBD side lane | Validator warnings |

Track fixes in `RESTRUCTURE_ROADMAP.md` Phase 4 — one package per slice.

---

## Related

- `REPO_DOMAIN_MAP.md`
- `RESTRUCTURE_ROADMAP.md`
- `PACKAGE_NAMING_STANDARD.md`
- `PUBLISH_REPO_LANE.md`
