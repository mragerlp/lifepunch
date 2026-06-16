# lifepunchulx — Changelog

Proprietary & Confidential — © 2026 lifepunch.co. Sole-owned IP of lifepunch.co.
Portal package: **lifepunchulx** (s&box ident `lifepunch.ulx`).

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
- **Publish-ready** — first LIFEPUNCH addon cleared for portal publish (`lifepunchulx` / `lifepunch.ulx`).

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
