# LIFEPUNCH Player Hub — Design Spec

**STATUS: APPROVED wireframe (Kepler task · OpenCode session 2026-07-14)**  
**Source session:** `ses_0a054aa6bffeyFPzE5s62LjDyP` (LIFEPUNCH Player Hub design exploration)  
**Currency:** `$LP` placeholder until final currency ruling · see `DXRP_PLATFORM_DOCTRINE.md`

## Purpose

The LIFEPUNCH Player Hub is the main branded in-game menu players open to:

- View and spend `$LP` (earned through play — not a real-money storefront CTA)
- Track XP / level progression
- Navigate skill trees and spend skill points
- View personal stats across LIFEPUNCH systems

It must read as LIFEPUNCH brand (website tokens), not DXRP purple-sibling chrome, while obeying s&box Razor/SCSS constraints (`flex` not `grid`, no JS). Economy debit rules remain LAW for any spend path.

## Design Tokens

Aligned to live `lifepunch.co` `:root` (`cloudflare-worker.mjs`) and the approved wireframe:

| Token | Value | Use |
|---|---|---|
| `--lp-blue` | `#017AEF` | Primary action, selected wash, `$LP` glyph |
| `--lp-blue-hover` | `#33A0FF` | Primary hover |
| `--lp-blue-rgb` | `1, 122, 239` | Wash / focus / shadow alpha |
| `--bg` | `#000000` | Shell root |
| `--surface` | `#1a1d23` | Header, cards |
| `--surface-inset` | `#12151a` | Sidebar, insets |
| `--card-header` | `#22262e` | Card header / raised inset |
| `--border` | `#374151` | Structural borders |
| `--text-main` | `#ffffff` | Body / values |
| `--text-dim` | `#9ca3af` | Secondary labels |
| Radius interactive | `6px` | Primary buttons / controls |
| Radius card | `12px` | Cards |
| Type | Montserrat (headings) + Inter (labels/body/values) | Brand pairing |
| Spacing rhythm | `12px` content gap · `8px` control gap · `44px` min hit | Touch |

No branding footer, atmospheric glow, glass, gradients, or decorative animation.

## Shell

### Shared shell layout

Target geometry: `1160 x 700`, centered, scaling down within the viewport. Sidebar and header remain fixed; each tab owns one vertical scroll region.

```text
+--------------------------------------------------------------------------+
| LIFEPUNCH PLAYER HUB                    LEVEL 24   $LP 1,280        [ X ] |
+------------------+-------------------------------------------------------+
|                  |                                                       |
|  [AVATAR]        |  PAGE EYEBROW                                         |
|  Player name     |  Page title                                           |
|  Member          |  Short page-specific explanation                      |
|                  |                                                       |
| > Overview       |  +-------------------------------------------------+  |
|   Skills      2  |  |                                                 |  |
|   $LP Store      |  |              ACTIVE TAB CONTENT                 |  |
|   Stats          |  |                                                 |  |
|                  |  |                                                 |  |
|                  |  +-------------------------------------------------+  |
|                  |                                                       |
+------------------+-------------------------------------------------------+
```

| Element | Treatment |
|---|---|
| Root/shell | `#000000`, `#374151` border |
| Sidebar | `#12151a`, approximately 190px wide |
| Header | `#1a1d23`, 64px tall |
| Card | `#1a1d23`, 12px radius |
| Card header/inset | `#22262e` or `#12151a` |
| Primary action | `#017AEF`, hover `#33A0FF`, 6px radius |
| Selected navigation | Blue 10–14% wash, blue left indicator, white label |
| Typography | Montserrat headings; Inter labels, body, and values |
| `$LP` placeholder | `$LP` token in blue; amount white |
| Controls | Minimum 44px interaction height, 8px separation |

No branding footer, atmospheric glow, glass, gradients, or decorative animation.

## Overview

```text
+--------------------------------------------------------------------------+
| OVERVIEW                                                                 |
| Your progression, currency and next available actions.                   |
|                                                                          |
| +---------------------------------------+  +---------------------------+ |
| | PROGRESSION                           |  | $LP BALANCE               | |
| |                                       |  |                           | |
| | Level 24                    74%        |  | $LP 1,280                 | |
| | [======================--------]      |  | Earned through play       | |
| | 18,420 / 25,000 XP                    |  |                           | |
| |                                       |  | [ Open $LP Store ]        | |
| | Next level: 6,580 XP                  |  | How to earn $LP           | |
| | Next unlock: [configured reward]      |  +---------------------------+ |
| |                                       |                                |
| | [ View Skills ]                       |  +---------------------------+ |
| +---------------------------------------+  | SKILL POINTS              | |
|                                            |                           | |
| +---------------------------------------+  | 2 available               | |
| | RECENT PROGRESS                       |  | 14 skills unlocked        | |
| |                                       |  |                           | |
| | + 450 XP   [source event]   8m ago    |  | [ Spend Points ]          | |
| | + 120 XP   [source event]  24m ago    |  +---------------------------+ |
| | +  80 XP   [source event]   1h ago    |                                |
| |                                       |  +---------------------------+ |
| | [ View all activity ]                 |  | STAT SNAPSHOT             | |
| +---------------------------------------+  |                           | |
|                                            | Playtime        --        | |
|                                            | Sessions        --        | |
|                                            | $LP earned      --        | |
|                                            | Events logged   --        | |
|                                            |                           | |
|                                            | [ View Stats ]            | |
|                                            +---------------------------+ |
+--------------------------------------------------------------------------+
```

**Behavior**

- The progression card is the visual anchor.
- XP always shows level, exact values, percentage, and remaining XP.
- `$LP`, skill points, and stats remain secondary supporting cards.
- Recent progress consumes namespaced stat-ledger events; unsupported events are not synthesized.
- Every summary card links directly to the source tab and must match that tab's value.
- "How to earn `$LP`" explains earning routes; it is not a real-money purchase CTA.

## Skills

Skill taxonomy is data-driven and remains unnamed until progression design defines the tracks. The sample labels below are structural placeholders.

```text
+--------------------------------------------------------------------------+
| SKILLS                                      2 AVAILABLE SKILL POINTS      |
| Select a track, inspect requirements, then unlock with skill points.     |
|                                                                          |
| [ All ] [ Track A ] [ Track B ] [ Track C ]              [ Reset view ] |
|                                                                          |
| +-------------+  +--------------------------------+  +-----------------+ |
| | TRACKS      |  | SKILL TREE                     |  | SKILL DETAIL    | |
| |             |  |                                |  |                 | |
| | > Track A   |  | TIER 1                         |  | Skill name      | |
| |   4 / 8     |  | [X Basic I] [X Basic II]       |  | Track A         | |
| |             |  |       |           |            |  | Rank 1 / 3      | |
| |   Track B   |  | TIER 2                         |  |                 | |
| |   2 / 10    |  | [+ Selected] [ ] Locked        |  | Description     | |
| |             |  |       |                        |  | of the precise  | |
| |   Track C   |  | TIER 3                         |  | unlocked effect.| |
| |   0 / 7     |  | [ ] Locked   [ ] Locked        |  |                 | |
| |             |  |       |                        |  | EFFECT          | |
| |             |  | TIER 4                         |  | Configured value| |
| |             |  | [ ] Locked                     |  |                 | |
| |             |  |                                |  | REQUIRES        | |
| |             |  | [X] Unlocked                   |  | Level 20        | |
| |             |  | [+] Available                  |  | Previous skill  | |
| |             |  | [ ] Locked                     |  | 1 skill point   | |
| |             |  |                                |  |                 | |
| |             |  |                                |  | [ Unlock ]      | |
| +-------------+  +--------------------------------+  +-----------------+ |
+--------------------------------------------------------------------------+
```

**Node states**

| State | Visual treatment |
|---|---|
| Unlocked | Blue fill, check glyph, "Unlocked" tooltip |
| Available | Blue border, white content, plus glyph |
| Selected | Blue focus wash plus persistent detail pane |
| Locked | Muted fill, lock glyph, unmet requirement shown |
| Maxed | Strong blue fill, "Max rank" text |

**Interaction**

- Skill points, not `$LP`, unlock skills.
- Selecting a node never spends a point.
- Unlock requires a second explicit action in the detail pane.
- The button label becomes `Unlock for 1 point`.
- Locked buttons explain the unmet requirement rather than silently disabling.
- The tree uses flex rows and connectors rather than unsupported CSS grid.
- Category selection is a secondary filter, not a second top-level navigation system.
- The tree does not require drag or precision zoom.

## Store

```text
+--------------------------------------------------------------------------+
| $LP STORE                                            BALANCE: $LP 1,280   |
| Spend earned $LP on cosmetics and approved non-combat perks.             |
|                                                                          |
| [ All ] [ Cosmetics ] [ Quality of life ] [ Timed boosts ]   [ Search ] |
|                                                                          |
| +-----------------------------------------------+  +-------------------+ |
| | CATALOG                                       |  | PERK DETAIL       | |
| |                                               |  |                   | |
| | +--------------------+ +--------------------+ |  | [Preview area]    | |
| | | Cosmetic name      | | Cosmetic name      | |  |                   | |
| | | Cosmetic           | | Cosmetic           | |  | Selected perk     | |
| | | Short description  | | Short description  | |  | Cosmetic          | |
| | | $LP 250      View  | | $LP 400      View  | |  |                   | |
| | +--------------------+ +--------------------+ |  | Full description  | |
| |                                               |  | and ownership     | |
| | +--------------------+ +--------------------+ |  | scope.             | |
| | | QoL perk           | | Timed boost        | |  |                   | |
| | | Non-combat         | | Non-combat         | |  | DURATION          | |
| | | Short description  | | 15 minutes         | |  | Permanent         | |
| | | $LP 500      View  | | $LP 600      View  | |  |                   | |
| | +--------------------+ +--------------------+ |  | COMBAT IMPACT     | |
| |                                               |  | None               | |
| |                                               |  |                   | |
| |                                               |  | Price    $LP 250  | |
| |                                               |  | Balance  $LP 1,280| |
| |                                               |  | After    $LP 1,030| |
| |                                               |  |                   | |
| |                                               |  | [Review purchase] | |
| +-----------------------------------------------+  +-------------------+ |
|                                                                          |
| [ How to earn $LP ]                    Direct purchase is not promoted.   |
+--------------------------------------------------------------------------+
```

Catalog cards only select a perk. Spending occurs from the detail pane.

**Confirmation state**

```text
                +------------------------------------------+
                | CONFIRM PURCHASE                         |
                |                                          |
                | Selected perk                            |
                | Cosmetic - Permanent                     |
                |                                          |
                | Price                    $LP 250          |
                | Current balance          $LP 1,280        |
                | Remaining balance        $LP 1,030        |
                |                                          |
                | This purchase grants no combat advantage.|
                |                                          |
                | [ Confirm for $LP 250 ] [ Cancel ]       |
                +------------------------------------------+
```

**Economy behavior**

- Affirm is left; cancel is right.
- Confirm locks while the authoritative transaction is pending.
- Balance is refreshed before confirmation; stale or unavailable balance blocks spending.
- No optimistic balance deduction.
- Success updates balance, ownership state, and activity feedback together.
- Failure leaves the perk selected and states the recovery path.
- Insufficient funds shows `Need $LP 120 more`; the button remains visibly disabled.
- Timed perks state whether activation is immediate or inventory-held before purchase.
- Every non-cosmetic listing explicitly displays `Combat impact: None`.
- `$LP` remains blue-placeholder identity until the final currency ruling.

## Stats

```text
+--------------------------------------------------------------------------+
| PLAYER STATS                                                             |
| Activity recorded across LIFEPUNCH systems.                              |
|                                                                          |
| PERIOD: [ Lifetime ] [ 30 days ] [ 7 days ]   SOURCE: [ All sources v ] |
|                                                                          |
| +----------------+ +----------------+ +----------------+ +--------------+|
| | PLAYTIME       | | TOTAL XP       | | SKILLS         | | $LP EARNED   ||
| | --             | | --             | | -- unlocked    | | $LP --       ||
| | configured src | | progression    | | progression    | | ledger       ||
| +----------------+ +----------------+ +----------------+ +--------------+|
|                                                                          |
| +--------------------------------------+ +------------------------------+ |
| | ACTIVITY TREND                       | | PERSONAL HIGHLIGHTS          | |
| |                                      | |                              | |
| | Mon  [========            ]           | | Most active source     --    | |
| | Tue  [============        ]           | | Longest session        --    | |
| | Wed  [======              ]           | | Highest XP event       --    | |
| | Thu  [================    ]           | | Most-used skill        --    | |
| | Fri  [==========          ]           | |                              | |
| |                                      | | No global ranking implied.   | |
| | Summary: activity peaked on Thursday.| |                              | |
| +--------------------------------------+ +------------------------------+ |
|                                                                          |
| +------------------------------------------------------------------------+|
| | ALL STATS                                                              ||
| |                                                                        ||
| | Stat                         Selected period              Lifetime     ||
| | ---------------------------------------------------------------------  ||
| | [Source] event count         --                           --           ||
| | [Source] value earned        --                           --           ||
| | [Source] successful actions  --                           --           ||
| | [Source] progression events  --                           --           ||
| |                                                                        ||
| +------------------------------------------------------------------------+|
+--------------------------------------------------------------------------+
```

**Behavior**

- Available periods come from the backend; unsupported periods are not shown.
- Source filtering follows the event namespace rather than assuming one stat origin.
- The trend uses bars plus a textual summary, so color is not the only signal.
- The table is the complete accessible representation of charted values.
- No percentile, server rank, or leaderboard appears without a real comparison dataset.
- Zero is displayed only when confirmed; unavailable data renders `--`, not a false zero.

## Shared States

| State | Presentation |
|---|---|
| Loading under 300ms | Preserve the current view |
| Loading over 300ms | Fixed-size skeletons matching final geometry |
| Empty | Plain explanation plus one relevant action |
| Partial data | Render known values; unknown values use `--` |
| Error | Inline cause and `Retry`, without discarding the selected tab |
| Store unavailable | Catalog becomes read-only; spending controls disappear |
| Session refresh | Preserve tab, filters, selection, and scroll position |

Navigation, buttons, nodes, and cards receive visible keyboard focus. Hover and pressed states use color/opacity without changing dimensions. Tab transitions use a short 150–200ms crossfade; no decorative movement.

## Pending Inputs

- XP curve, level cap, and level rewards.
- Skill taxonomy, prerequisites, effects, and point-award rules.
- Store catalog, perk duration semantics, and activation timing.
- Final `$LP` currency identity.
- Stat namespaces, supported time periods, and source-specific labels.
- Whether skill or store content needs search at launch.


## Implementation Notes

- Target: s&box `PanelComponent` / Razor + `.razor.scss` under LifePunch addon UI paths (exact package TBD in implementation plan).
- **Layout:** `flex` only — no CSS `grid` (s&box SCSS constraint).
- **No client JS** — all interaction in C# / Razor event handlers.
- **Purchases:** debit-before-await / authoritative host transaction; no optimistic `$LP` deduction (see Store economy behavior).
- Skill unlocks spend **skill points**, never `$LP`.
- `BuildHash` must include every private UI flag that changes markup (filters, confirm open, selected node).
- HASHD in-world CRT themes remain out of scope (exemption in `LIFEPUNCH_UI_STANDARD.md`).
- Pending Inputs above block ship-complete claims until ruled.
