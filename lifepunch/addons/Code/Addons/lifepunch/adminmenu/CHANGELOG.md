# lifepunchulx — Changelog

Proprietary & Confidential — © 2026 lifepunch.co. Sole-owned IP of lifepunch.co.
Portal package: **lifepunchulx** (s&box ident `lifepunch.lifepunchulx`).

## v1.0.2 — portal r9 (2026-06-29)

- **Dedicated compile fix** — DXRP `Player.PlayTime` is `TimeSince` (elapsed seconds); roster + profile pane now convert to minutes explicitly (`/ 60f`, same as DXRP VoteSystem). Fixes CS1503 on portal r8 when the dedicated host compiles against current DXRP.
- **Refresh throttle** — roster rebuild cadence uses `RealTimeSince` (matches LifePunch bitcoin sync pattern; avoids Razor `TimeSince` compile edge on newer engine builds).

## v1.0.1 — portal r6 (2026-06-23)

- **Scroll policy cleanup** — removed cross-lane class names from the lifepunchulx bundle; shared scroll helpers are addon-neutral (`lp-ui-scroll-region` only). StaffMenu scroll regions declare that class in markup.
- No gameplay or permission changes; publish hygiene only.

## v1.0.1 — portal r5 (2026-06-22)

- **Dedicated-server compile fix** — self-contained 13-file bundle ships shared UI deps inside `lifepunchulx/` (`LifePunchUiScale`, scroll policy, footer) so dedicated servers no longer hit CS0246 on `LifePunchUiScaleSize`.
- **Server-agnostic sidebar** — empty default reference tiers (no hard-coded Owner/Super Admin ladder on foreign servers).
- **Sidebar scroll tail** — roster list bottom padding fix at XL scale.
- Code-only; no feature regressions vs v1.0.0.

## v3.0.0 — first production publish (2026-06-16)

**In-game title unchanged:** header still reads **Admin Menu** (subtitle **ULX Console**). Opens via `lifepunchulx`, `/lifepunchulx`, or aliases `menu` / `ulx`.

### Architecture (unchanged promise)

- Thin UX + dispatch layer over DXRP's native admin backend — no new authority, every action re-validated host-side.
- Permission-gated UI via live `RankSystem.HasLocalPermission`; `CanLocalTarget` locks equal/higher ranks.
- Code-only package (6 ship files); no Assets or content rows. Editor test bots live in `Code/_dev/` (excluded from publish staging).

### Command catalog (25 actions)

- **Moderation (7):** Kick, Ban, Jail, Gag, Warn, Spectate, Screenshot.
- **Commands (13):** God, Cloak, Incognito, Fake Disconnect, Freeze, Set Health, Arrest, Unarrest, Force RP Name, Cancel Demote, Clear Props, Force Sell Door.
- **Ability (5):** Goto, Bring, Return, Teleport All, Noclip.
- Per-rank **ban-duration ceiling** (client UX guardrail) with quick-pick chips (1h → permanent).
- Hover tooltips on every command and player row.

### Tabs & tools

- **Moderation / Commands / Ability** — uniform 4-per-row action grid; active-tab highlight preserves hover.
- **Waypoints** — go / set / clear; live saved-waypoint list synced from the host via addon-owned `WaypointSyncService` (no DXRP core edits).
- **Audit** — in-menu log with Player ID + Entity ID filters (portal-mirrored columns; live API bind pending — see TECH_DEBT STAFF-07).
- **Settings** — owner-configurable network website URL (`lifepunchulx.settings.edit`); UI Scale S / M / L / XL (canonical **XL 1160×700**); read-only network tag + click-to-copy website link.

### Player intelligence

- Collapsible **Staff** + **Players** sidebar sections with tier grouping; live online count; empty reference tiers (Owner / Super Admin / Admin / Mod) for ladder context.
- Search by name or paste **SteamID64** to target off-roster players.
- Profile pane: avatar, Steam ID (copy), role (rank color), job (job color), time played, health, armor, cash/bank, kills/deaths — all live session reads.
- Quick **Goto / Bring / Return** from profile; **Return a player** by SteamID64 on Waypoints tab.
- **View Audit** shortcut from profile when permitted.

### UX & stability

- HUD-mounted panel (`GameManager.ShowUi`) — menu is fully clickable on DXRP servers; `LockCamera` while open.
- Shared LIFEPUNCH chrome: `LifePunchUiFooter`, 22px shell radius, header network chip, ULX blue palette.
- Copy-to-clipboard: network tag, profile Steam ID, website link — each with "Copied!" feedback.
- Throttled roster rebuilds + cached stat hash (no sidebar/hover flicker); scroll-capped lists; locked header/tab heights.
- **LifePunchUiScrollPolicy** — wheel-only scroll, drag-scroll disabled, clamped offsets (sidebar roster, audit, waypoints at XL).
- Waypoints list layout fix at XL scale; collapsible sidebar rail with cog spacing polish.

### Known / not in v3.0.0

- Footer **Player & Staff Management** → "Coming Soon" placeholder.
- Sanction history in profile pane (async API — TECH_DEBT STAFF-06).
- Live audit fetch on dxrp.net build returns empty until `ServerApiClient` exposes the read (STAFF-07).

---

## v2.0.0

Core updates

- **Tabbed ULX console** — Moderation, Commands, Ability, Waypoints, and Audit tabs, with a reliable active-tab highlight that preserves hover.
- **Waypoints tools** — go / set / clear, plus a per-server saved waypoint list synced live from the host (permission-gated).
- **Audit viewer** — in-menu audit log with Player ID / Entity ID filters.
- **"Return a player" by SteamID64** — paste a SteamID to send a player back to where they were brought from; plus quick teleport (Goto / Bring / Return) from the profile pane.
- **Owner Settings tab** — set the network's website URL (persisted server-side); edit is permission-gated (`lifepunchulx.settings.edit`), read-only for everyone else, with a "Saved!" confirmation.
- **Copy-to-clipboard controls** — network tag, profile Steam ID, and the website link are click-to-copy with "Copied!" feedback.
- **Roster overhaul** — collapsible player sidebar, de-duped Players vs. tiered Staff sections (no more double "Owner"/double-highlight), live "Online Players (N)" head-count, and online indicators on the collapsed rail.
- **Stability & polish** — fixed sidebar/hover flicker (throttled per-frame rebuilds + cached stat hash), centered Material Icons glyphs, scroll-capped lists, locked header/tab heights, and pixel-aligned header controls.
- **Command rebrand** — single entry point `lifepunchulx` / `/lifepunchulx` (removed `staffmenu` and `adminmenu` aliases).

## v2.0.4

- **UI Scale** — Settings uses S / M / L / XL steps anchored on **XL (1160×700)** as the canonical layout; smaller steps only trim the shell slightly (no per-step squish of buttons, sidebar, or icons). Default scale is XL. Sidebar **Staff / Players** roster uses section + tier wrappers with clearer header/rank/player spacing for long scrollable lists (~70 players).

## v2.0.3 — publish-ready

- **Settings panel size controls** — centered Compact / Standard / Expanded labels (flex + padding fix; no clipped top-edge text).
- **Publish-ready** — first LIFEPUNCH addon cleared for portal publish (`lifepunchulx` / `lifepunch.lifepunchulx`).

## v2.0.2

- **Hub-family polish** — shared `LifePunchUiFooter`, 22px shell radius, header network chip + chrome close/cog (ULX blue palette unchanged).
- **Title** — header reads **Admin Menu** (subtitle ULX Console); footer uses shared LIFEPUNCH mark in ULX blue.

## v2.0.1

- **Chat + console aliases** — `/menu`, `/ulx`, `menu`, and `ulx` open the same ULX panel as `lifepunchulx` / `/lifepunchulx`.

Under the hood: every action routes through DXRP's re-validated host RPCs (no new authority granted); the menu is self-contained via `WaypointSyncService` + `StaffSettingsService` and no longer depends on DXRP core.

Known/pending (not in this release): the footer "Player & Staff Management" entry opens a "Coming Soon" placeholder; sanction history in the profile pane is still a TODO (STAFF-06).

## v1.0.0

- First in-game vertical slice: server-agnostic ULX console that gates each action on the viewer's portal rank and dispatches through DXRP's native admin backend.
- Moderation/commands actions (Kick, Freeze, Goto, Bring, Spectate, God, etc.) via permission-aware dispatch.
- Live player profile pane (Steam ID, role, job, time played, health, armor, cash/bank, kills/deaths).
- Hover tooltips on commands and player rows; in-menu addon signature; proprietary sole-ownership header and canonical identifiers.
