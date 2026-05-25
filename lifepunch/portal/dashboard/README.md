# Dashboard

Purpose: network overview for LifePunch.

Observed fields:

- Online Players
- Recent Players (24H)
- Total Players
- Player Lookup
- Global Balance
- Announcements
- Live Overview

Observed values from screenshot:

- Online Players: `0`
- Recent Players (24H): `3`
- Total Players: `4887`
- Global Balance: `$61,294,059`

Observed dashboard controls:

- Player Lookup textbox with placeholder `Paste player ID...`.
- Announcements editor.
- Announcement `Preview` button.
- Announcement `Save` button.

Observed announcement content categories:

- Discord: `discord.gg/lifepunchco`
- Website: `www.lifepunch.co`
- Welcome message.
- Rules/RP guideline message.

Observed Live Overview table:

- Columns: `Name`, `Status`, `Players`, `Peak`, `Uptime`, `Health`.
- `LifePunch Official | 70p`
  - Status: `Offline`
  - Peak: `0`
- `LifePunch Official | DEVELOPMENT SERVER`
  - Status: `Offline`
  - Peak: `0`

Observed authenticated portal top navigation:

- Dashboard
- Servers
- Players
- Game Modes
- Audit
- More menu (`...`)
- Network selector: `LifePunch`

Observed `...` dropdown menu:

- Maps
- Rulesets
- Ranks
- Inventory
- Addons
- Factions
- Sanctions

This dropdown is the access point for additional portal features that still need individual page review.

Operational rules:

- Dashboard data is read-only unless editing announcements.
- Do not edit announcements without owner approval.
- Do not store player lookup results in this repo unless needed for an audit case.
- Treat announcement `Save` as an owner-approved action.
- Treat Global Balance and player statistics as snapshots, not static config.

Portal confirmation needed:

- Exact announcement save behavior.
- Any dashboard-only permission gates.
- Whether Live Overview server rows link to server detail pages.
- Whether Global Balance graph can be filtered or exported.
