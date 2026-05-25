# Public DXRP Navigation

This folder documents the public/top DXRP navigation before entering the authenticated LifePunch portal.

Observed top navigation:

- `DXRP` logo / home
- `Servers`
- `Addons`
- `Terms`
- `Docs`
- `Portal`

## Public Docs Site

Observed URL:

```text
https://docs.dxrp.net/
```

Observed docs structure:

- `Developer`
  - `TODO`
- `Operator`
  - `Launching Server with Addons`
- `Player`
  - `Quickstart`

Observed key links:

- `Community Server Guide`: `https://github.com/dxura/dxrp-public/wiki/Operator`
- `Launching Server with Addons`

LifePunch docs reference:

- `../../docs/DXRP_DOCS_REFERENCE.md`

## Purpose

Keep public DXRP pages separate from authenticated LifePunch portal operations.

- Public `Servers` likely shows DXRP network/server listings.
- Public `Addons` likely shows DXRP addon marketplace/listings.
- `Portal` enters authenticated network management.

## Public Home Page

Observed URL:

```text
https://dxrp.net/
```

Observed hero:

```text
The RP experience you know, reimagined
Next generation roleplay, built for performance, scalability, and community.
```

Observed actions:

- `Discord`
- `Play Now`
  - Shows current online count under the button. Screenshot showed `75 online`.
- `Create a Network`
- `Scroll to learn more`

Operational notes:

- This is the public DXRP landing page, not LifePunch-owned configuration.
- `Create a Network` is relevant as a reference for how DXRP expects communities to onboard.
- Public messaging emphasizes performance, scalability, and community. This is useful language to understand DXRP positioning when presenting LifePunch addons or servers publicly.

## Operational Rule

Do not confuse public DXRP pages with LifePunch-owned portal settings. Public pages are reference/discovery surfaces; authenticated portal pages are where LifePunch configuration changes happen.

## Public Terms Page

Observed URL:

```text
https://dxrp.net/terms
```

Observed heading:

```text
Terms of Use
Last updated: April 2026
```

Observed platform context:

- DXRP is described as a roleplay platform built on top of S&box by Facepunch Studios.
- Use of DXRP remains subject to S&box/Facepunch/Steam platform rules.
- Terms apply to the web portal, in-game systems, APIs, and associated services.
- Operating a server confirms acceptance of the terms.

Observed sections:

- `Acceptance of Terms`
- `Eligibility`
- `Player Responsibilities`

LifePunch operating implications:

- LifePunch addon, server, website, Discord, and API work should not violate DXRP, S&box, Facepunch, or Steam rules.
- Developer work should be reviewed for compliance before public release.
- API usage and server automation should be treated as part of DXRP service usage, not separate from the terms.
- Terms screenshots are not a substitute for reading the full terms when making policy-sensitive decisions.

## Public Addons Page

Observed URL:

```text
https://dxrp.net/addons
```

Observed heading:

```text
Addons
Browse community addons for DXRP servers
```

Observed controls:

- Back button.
- Search field with placeholder `Search addons...`.
- Sort dropdown, currently `Most Used`.
- Refresh button.
- Addon grid/card layout.
- Cards show image/thumbnail art and addon title.
- Cards show a small top-left badge with an icon and number.

Observed public addon cards:

- `Base Content`
- `Kevlar`
- `Pickpocket`
- `Nuke`
- `Balls (Example)`
- `guns`
- `Hello World!`
- `Monnow's Fishing`
- `Simple weapons`
- `Steam Group Rewards`
- `Volleyball`
- `Yell & Whisper`

Observed card metadata:

- Small badge with a numeric count on each card. Observed examples: `33`, `7`, `4`, `1`, and `0`.
- Exact badge meaning still needs confirmation. It may represent usage, content count, install count, or revision/content metadata.

Operational notes:

- This is a public discovery/marketplace surface.
- This is not the private LifePunch addon manager.
- Use it to compare public presentation, naming, artwork, visibility, and credit/ownership once LifePunch addons are ready for wider release.
- Public addon presentation depends heavily on thumbnail/card artwork, so LifePunch addon art should be treated as part of release quality.

## Public Servers Page

Observed URL:

```text
https://dxrp.net/servers
```

Observed heading:

```text
Servers
Discover servers that offer unique RP experiences
```

Observed controls:

- Back button.
- Search field with placeholder `Search servers...`.
- `Filters` button.
- Refresh button.
- Server listing/table layout.

Observed columns:

- `Server`
- `Description`
- `Players`

Observed row actions/icons:

- Player count indicator.
- Yellow document/list-style icon.
- Green play/connect-style icon.

Observed server examples:

- `DankRP |[DarkRP.com]Lax-Rules|2x Weed|LOW PING|64p`
  - Tags observed: `DANK NETWORKS`, `VANILLA`
  - Player count observed: `43`
- `DXRP | Official EN | 64p`
  - Tags observed: `OFFICIAL`, `VANILLA`
  - Player count observed: `16`
- `DXRP Français [dxrp.fr] | Fluide & Stable | 69p`
  - Tags observed: `FRANCE`, `VANILLA`
  - Player count observed: `13`
- `NukeRP [AUS] 3x Weed | $15K Start | Low Ping | 64 Slots`
  - Tags observed: `[AUS] NUKERP`, `VANILLA`
  - Player count observed: `2`
- `MoatRP.com - Lax-Rules - Events - LOWEST PING`
  - Tags observed: `MOATRP`, `VANILLA`
  - Player count observed: `2`
- `[FR] Horizon RP Free accès temporaire - discord.gg/dkkA9psmTr`
  - Tags observed: `HORIZON RP`, `VANILLA`
  - Player count observed: `1`
- `MURDA RP | EVENTS - 20K START - LOW PING`
  - Tags observed: `MURDA RP`, `VANILLA`
  - Player count observed: `0`
- `CosmicRP DXRP Server - www.cosmic-networks.com`
  - Tags observed: `COSMICRP DXRP SERVER`, `VANILLA`
  - Player count observed: `0`

Operational notes:

- This is a public server discovery page.
- It is useful for comparing how LifePunch appears publicly against official and community servers.
- Public listing tags like `VANILLA`, `OFFICIAL`, and network tags may matter for `lifepunchmainserver` positioning.
- Public descriptions often include Discord links, gameplay modifiers, region/language, starting money, ping, slot count, and event messaging.
- Public ordering appears influenced by active player count or server popularity, but exact sorting needs confirmation.
- This page is not the private `lifepunch/server` management area.

## Confirmation Needed

- Exact public Servers filter options.
- Public server detail fields after opening a server row.
- Exact public Addons card metadata meaning.
- Addon detail page fields after opening a public addon card.
- Whether public addon pages expose ownership/credit information for LifePunch packages.
