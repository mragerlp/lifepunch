# DXRP Portal — Live Field Guide (LIFEPUNCH™)

Observed in authenticated portal **2026-06-23** via Cursor browser while owner published **lifepunchulx r7**.

Network context: top-right combobox must be **LIFEPUNCH™**. Some pages (Audit, Sanctions) show **Select Network** until a network is chosen — data is empty until then.

---

## URL patterns

| Area | Pattern | LifePunch example |
|------|---------|-------------------|
| Addon editor | `https://dxrp.net/portal/addons/<dxrpAddonId>` | `019ee8ed-2bba-7f7a-8836-09b70b816722` |
| Gamemode editor | `https://dxrp.net/portal/gamemodes/<gamemodeId>` | Development: `019eca7a-d259-747f-9670-c6642e0d3c19` |
| Player profile | `https://dxrp.net/portal/players/<steamId64>` | Owner: `76561198103223564` |
| Primary nav | `https://dxrp.net/portal/{dashboard,servers,players,gamemodes,audit}` | — |
| Overflow nav | `https://dxrp.net/portal/{maps,rulesets,ranks,inventory,addons,factions,sanctions}` | — |

**Law:** UUID after `/portal/addons/` = canonical `dxrpAddonId` in `addons.json`. Slug (`lifepunchulx`) is separate.

Public listing (unauthenticated): `https://dxrp.net/addons/<uuid>` — same UUID.

---

## Primary navigation (top bar)

| Tab | Purpose | Key UI |
|-----|---------|--------|
| **Dashboard** | Network pulse | Online/recent/total players, player lookup paste, global balance graph, announcements editor, live server table (name, status, players, peak, uptime, health). 15s refresh. |
| **Servers** | Hosted server records | Search, Add, row actions (edit per server). |
| **Players** | Player search/list | Leads to `/portal/players/<steamId64>` detail. |
| **Game Modes** | Gamemode list + pins | WIP banner. Columns: Name, Visibility, Jobs, Addons, Created. |
| **Audit** | **Network-wide** accountability log | Filters: Player ID, Actions dropdown, Entity ID. Columns: When, Action, Player, Entity, Description. Refresh + History icons. |

**Overflow (`…`):** Maps, Rulesets, **Ranks**, Inventory, **Addons** (list), Factions, **Sanctions**.

---

## Addon publish (lifepunchulx)

**Package:** `019ee8ed-2bba-7f7a-8836-09b70b816722` · identifier `lifepunchulx` · code-only · **7 revisions** (r7 shipped 2026-06-23).

### Details panel fields

- Visibility (Public)
- Addon Identifier: `lifepunchulx`
- S&box Identifier: `lifepunchulx` (portal UI; repo targets `lifepunch.lifepunchulx` — confirm if client mount issues persist)
- Revisions count

### Tabs on addon page

| Tab | Role |
|-----|------|
| **Content** | Content rows for entity addons (maps, weapons, etc.). ULX has **none** — correct for code-only. |
| **Config** | Listing markdown, media, pricing. |

### Publish New Revision modal

- **0 content items** for code-only ULX — expected.
- **Code upload:** select folder whose **contents** are the ship files (13 × ~163 KB), not parent `Code/`.
  - Path: `upload/Code/Addons/lifepunch/lifepunchulx/` → pick **`lifepunchulx`** folder.
- **Assets:** skip for ULX.
- Do **not** leave Code on “Reusing from revision N” when shipping new bytes.
- Audit log actions on publish: `Create` + `UploadCodePackage` on entity **AddonRevision**.

---

## Gamemode pin (separate step from publish)

**Development gamemode:** `019eca7a-d259-747f-9670-c6642e0d3c19` · **LIFEPUNCH™ Development** · Private · 2 addons.

### Tabs

General · **Addons (N)** · Content · Jobs · Market · Minigames

### Addons tab columns

| Column | Meaning |
|--------|---------|
| Addon | Package name + description |
| Installed | Revision **pinned on this gamemode** |
| Latest | Newest published revision on portal |
| Status | Up To Date / **Update Available** |

**Observed 2026-06-23 after r7 publish:** `lifepunchulx` showed **Installed Rev 1**, **Latest Rev 7**, **Update Available**. Publishing r7 ≠ pinning r7. Must bump Installed to Latest (Edit gamemode → Addons → update pin → Save), then **Sync Servers** or restart dedicated.

Second pinned addon: **Base Content** (Rev 3, up to date).

### High-risk actions

- **Sync Servers** — pushes gamemode to hosted servers (owner approval).
- **Delete Game Mode** / **Reset to Vanilla** — never without explicit owner OK.
- **Export / Import** — rollback / canonical `.gamemode` workflow.

Other gamemodes on network (2026-06-23): **LIFEPUNCH** (ship, 2 addons), **TEST**, **Vanilla (clean)**.

---

## Audit (network tab) — future ULX Audit tab backend

**URL:** `/portal/audit`

**Filters:** Player ID, Actions (dropdown), Entity ID, search button.

**Columns:** When · Action · Player · Entity · Description

**Observed actions:** Chat, DispatchAction, Apply, Update, Create, UploadCodePackage, GenerateToken, …

**Observed entities:** Server, ServerAction, GameMode, AddonRevision

**Use:** Verify publish/pin/sync; who changed ranks, sanctions, gamemodes. Do not delete or hide entries.

**Gap vs lifepunchulx in-game Audit tab:** Staff menu Audit tab is UI-complete but needs DXRP **client-exposed** audit read API — portal Audit is the live source today; in-game tab cannot mirror it until platform exposes read path.

---

## Players — future Player & Staff Management

**URL:** `/portal/players/<steamId64>`

**Observed owner profile (Bloodwave):**

| Section | Fields / actions |
|---------|------------------|
| Header | Avatar, name, Steam ID (copy, external link), Get Age, Back |
| Stats | Balance (editable), Level (editable), Play time |
| Rank badge | Owner (visible on profile) |
| Inventory | Button → inventory view |
| Staff notes | Internal textarea (0/2000) |
| Footer | Joined, Last seen |
| **Sanctions** (card) | Show All, **Sanction** button, table Issued/Type/Reason |
| **Audit Log** (card) | Per-player subset: When, Action, Description; Actions filter dropdown |

**Observed per-player audit actions:** Death, Kill, Waypoint, SetHealth, … (gameplay/admin trail — overlaps ULX dispatch targets).

**Players list tab:** Search/list entry point (Dashboard also has “Paste player ID…” lookup).

**Gap vs lifepunchulx footer “Player & Staff Management → Coming Soon”:** Portal already has player profile, sanctions, ranks assignment (via rank on profile?), and audit — product work is **surfacing** portal-grade flows in-game or deep-linking, not inventing data from scratch.

---

## Ranks — permissions for ULX + staff

**URL:** `/portal/ranks`

**Columns:** Order · Name · Permissions · Actions (edit pencil)

**Observed ladder (LIFEPUNCH™):**

| Order | Name | Permissions |
|-------|------|-------------|
| 69 | Owner | All |
| 10 | Super Admin | All |
| 7 | Community Manager | 92 |
| 5 | Admin | 83 |
| 4 | Mod | 79 (+1 inherited) |
| 3 | EVIP | 4 (+1 inherited) |
| 2 | VIP | 4 (+1 inherited) |
| 1 | Members | 3 |
| 0 | None (Default) | 1 |

**ULX owner setting:** grant `lifepunchulx.settings.edit` on ranks that may edit network website URL in-game (Owner by default).

Rank edit UI: flags (Show On Nameplate, Show In Chat, Hide On Player List), server restriction, wildcard toggle, inherits-from, granular permission checklist.

---

## Sanctions

**URL:** `/portal/sanctions`

Network-wide sanctions list (requires network selected). Per-player sanctions also on player profile card. Ties to moderation commands in ULX.

---

## Addons list (overflow menu)

**URL:** `/portal/addons` (authenticated list — distinct from public `/addons` marketplace)

Manage all network packages; row opens `/portal/addons/<uuid>` editor.

---

## Publish → pin → server workflow (canonical)

```text
1. prepare-publish.ps1 -Addon adminmenu
2. Sync-DesktopPublishFolder.ps1 -Addon adminmenu
3. Portal → addon UUID → Publish Revision → upload lifepunchulx/ contents (13 files)
4. Portal → gamemode → Addons tab → bump lifepunchulx Installed to Latest → Save
5. Sync Servers and/or restart dedicated host
6. Join client → sbox.log proof → lifepunchulx / menu / ulx
7. Portal Audit → confirm UploadCodePackage + GameMode Update/Apply
```

---

## Mapping to lifepunchulx roadmap

| In-game (not done / partial) | Portal source today |
|------------------------------|---------------------|
| Audit tab (live rows) | `/portal/audit` + player Audit Log card |
| Player & Staff Management footer | `/portal/players`, `/portal/ranks`, `/portal/sanctions` |
| Settings `lifepunchulx.settings.edit` | `/portal/ranks` permission grant |
| Roster / live profile | DXRP RankSystem + portal player data (already in StaffMenu) |

---

## Repo sync pointers

- `lifepunch/addons/config/addons.json` — `dxrpAddonId`, `dxrpAddonIdentifier`, `sboxIdentifier`
- `lifepunch/gamemode/config/addon-revisions.json` — revision tracking, portal URL, pin notes
- `lifepunch/portal/config/portal-tabs.json` — nav inventory
- Per-tab READMEs under `lifepunch/portal/*/` — procedures; this file is **live observed** truth
