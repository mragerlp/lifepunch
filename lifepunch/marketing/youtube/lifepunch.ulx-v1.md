🛡️ lifepunch.ulx v1
A ULX-Style Staff Menu for DXRP

A clean, modern, fully server-agnostic in-game staff menu for any DXRP.net-powered server.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

OVERVIEW
This is a polished, ULX-inspired (but built clean from scratch) staff console that opens instantly via console or chat command (adminmenu / /adminmenu). It's intentionally architected as a thin UX + dispatch layer over DXRP's own admin backend — it never reimplements authentication, authority, or actions.

Every command routes to DXRP's existing AdminSystem host RPCs where one exists, or to the registered chat ICommand otherwise, and every action is re-validated host-side — so the client never holds authority and the menu can't be exploited or desynced from your server's rules.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

REAL-TIME, PORTAL-DRIVEN — NOTHING IS HARDCODED
Because it binds directly to the server's live RankSystem over the connected DXRP.net portal API, the menu reflects your portal as it is right now, not a baked-in snapshot:

• Permission-gated UI — each viewer sees only the actions their rank actually permits (RankSystem.HasPermission), gated by permission, not rank name. Correct on every server with zero configuration. Update a rank's permissions on the portal and the menu updates the moment data refreshes.

• CanTarget enforcement — players you can't action (equal or higher rank) are visibly locked, matching DXRP's own hierarchy rules.

• Live player intelligence — roster, roles, rank colors, job (with real job color), health/armor, cash/bank balances, kills/deaths, and playtime are all pulled live from the connected session. The player profile pane is a real-time read, not a cached estimate.

• Auto-adjusting staff tiers — the roster groups players under their real portal rank names automatically, so custom ladders ("Trial Mod", "Head Admin", anything) appear without edits.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEST-IN-CLASS UI / UX
• A categorized command catalog (Moderation / Commands / Ability) with a highlighted active tab so you always know where you are.

• A live, searchable Online Players list — filter by name or paste a SteamID64 to target players who aren't even on the visible roster.

• A rich player profile pane with avatar and color-accurate live stats (role color, job color, green currency with real comma formatting, red health, cyan armor matching DXRP's HUD).

• A clear active-target banner with one-click deselect, re-click-to-deselect rows, and a uniform 4-per-row action grid that never stretches or squeezes.

• Hover tooltips on every command ("Kick player", "Go invisible", "Set player's health"…) and player rows, so even new staff know exactly what each control does.

• Per-command argument forms with quick-pick chips (e.g. ban durations), and a per-rank ban-duration ceiling — a guardrail the portal itself can't express, ideal for delegating moderation safely.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Enjoy ⛶

Mr. Rager | mrragerlp | lifepunch.co

-----------------------------------------------------------------------------------
DXRP            @     | https://DXRP.net/
Website        @     | https://lifepunch.co/
Discord         @     | https://discord.gg/lifepunchco
Steam           @     | https://steamcommunity.com/groups/lifepunchofficial

Check out s&box | https://sbox.game/

-----------------------------------------------------------------------------------
© 2026 lifepunch.co. All rights reserved. lifepunch.ulx is the sole-owned intellectual property of lifepunch.co and is NOT licensed for resale, redistribution, sublicensing, copying, or reuse by any person or entity. It is available exclusively through the DXRP.net portal. "DXRP" and all other names shown are trademarks of their respective owners; their use here is nominative only and implies no affiliation or endorsement.
