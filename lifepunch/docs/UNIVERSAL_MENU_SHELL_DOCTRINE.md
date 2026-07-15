# UNIVERSAL MENU SHELL DOCTRINE — the 7-slot shared shell

**RATIFIED 2026-07-15, Bloodwave** (chat-carried; ruling record `fable\0093`, slot contract
`dispatch\red\0004`). **This is the peak menu design ruling — load-bearing.** Every LIFEPUNCH addon
menu is **ONE SHARED SHELL skinned per product.** Supersedes per-addon bespoke shell construction.
This **is** the UI CORE PRINCIPLE in-tree ("one light core, layered per purpose" —
`LIFEPUNCH_UI_STANDARD` MENU SHELL LAW).

**Source visuals** (Bloodwave-approved, `brand-intake\lpchemist\`): `concept-drugprocessingUI.jpg`
(dashboard with real Chemist content in every slot) · `concept-menu-skeleton.jpg` (annotated wireframe
with slot labels).

> **CLASS: RULED. Write-once.** Supersede with a new record citing this one by filename.

---

## 1. THE SHELL (shared Razor component — `LpMenuShell.razor`)

Every addon menu ships this identical structure:

- **SIDEBAR (left, fixed):** identity block **top** (addon mark + name) · vertical nav items
  (addon-specific, order varies) · active-item treatment · **SETTINGS pinned bottom.**
- **TOP BAR (full width):** addon wordmark **left** (accent color) · controls **right** (addon-specific).
- **CONTENT AREA (center):** eyebrow (addon name, accent) · page title (icon + page name, large white
  bold) · callout banner (amber/brown, shared style) · page content (varies by pane).
- **SNAPSHOT PANEL (right, dashboard route only):** key stats (3–4 rows).
- **QUICK BUTTONS (bottom of dashboard, spanning width):** 3 shortcuts to key panes.
- **FOOTER (every page):** `LIFEPUNCH™ · proprietary IP · lifepunch.co` · adapts to the addon accent ·
  **copy-to-clipboard** (copies the `lifepunch.co` URL) — ruling D1, `POLISH_RULINGS_2026-07-15`.

## 2. THE 7-SLOT CONTRACT (Razor component parameters)

`LpMenuShell.razor` accepts **exactly 7 parameterized slots.** Everything else is shared chrome —
**not parameterized, identical across all consumers.**

### Parameterized slots (vary per addon)
| # | Slot | Razor type | Example (Bitcoin Ops) |
|---|---|---|---|
| 1 | Mark | `RenderFragment` | HASHD pixel-block icon |
| 2 | Wordmark | `string` | "BITCOIN OPS" |
| 3 | TopBarControls | `RenderFragment` | Power toggle + balance + cashout |
| 4 | NavItems | `List<NavItem>` | Dashboard..Settings (6 items) |
| 5 | DoorCards | `List<DoorCard>` | Hub / Terminal / GPU Racks |
| 6 | SnapshotStats | `List<StatRow>` | Setup / Racks / Wallet |
| 7 | QuickButtons | `List<QuickButton>` | Upgrades / Wallet / Transfers |

### Shared chrome (NOT parameterized — the shell owns these)
- Sidebar frame (identity block top, nav middle, SETTINGS bottom)
- **Active nav treatment (filled rounded block + left accent strip)** — ⚠ **see §6 CONTRADICTION FLAG**
- Eyebrow (repeats Wordmark in accent color, auto-generated)
- Page title area (icon + route name, driven by active NavItem)
- Callout banner component (amber/brown, per-page string content)
- Snapshot panel frame (right column, dashboard route only)
- Quick-button row frame (bottom, dashboard route only)
- Footer (LIFEPUNCH™ · proprietary IP · lifepunch.co + copy function)
- Shell border-radius (one root owns outer radius + `overflow:hidden`)

## 3. SLOT DATA SHAPES

```
DoorCard {
  Icon: RenderFragment       // addon-specific mark/image
  Title: string              // "WEED", "BITCOIN HUB"
  Chips: List<StatusChip>    // NATIVE, LOCKED, "3/3 RACKS"
  Description: string        // one-line subtitle
  Label: string              // right-side faded label
  Route: string              // nav target on click
  Enabled: bool              // false = LOCKED appearance
}

StatusChip {
  Text: string
  Variant: enum { Info, Success, Locked, Count }
}
```

## 4. ACCENT CONTRACT

Each consumer passes **ONE accent color token.** The shell applies it to: wordmark, eyebrow, active
nav block, chips, quick-button borders, callout banner tint (if the addon-tinted variant is ruled).
**The accent MUST NOT be green (cash-semantic, Law 17) or white (structural).**

## 5. SKINNING CONTRACT (what changes per addon)

| Slot | Bitcoin Ops | Chemist Ops | Player Hub |
|---|---|---|---|
| Accent color | Bitcoin orange/amber | Violet | LP blue |
| Mark | HASHD pixel-block | Flask (slate-violet) | LP roundel |
| Wordmark | BITCOIN OPS | CHEMIST OPERATIONS | PLAYER HUB |
| Nav items | 6 (dashboard..settings) | 6 (dashboard..settings) | TBD |
| Top-bar controls | Power + balance + cashout | Power + stash | TBD |
| Door cards | Hub/Terminal/Racks | Weed/Cocaine/Meth | TBD |
| Snapshot stats | Setup/Racks/Wallet | Lanes/Output/Wallet | TBD |
| Quick buttons | Upgrades/Wallet/Transfers | Production/Wallet/Routes | TBD |

Marks scoped per `BRANDING_SCOPE_RULING_2026-07-15` (LP roundel = Player Hub only; job UIs own marks).

## 6. IMPLEMENTATION PATH

1. **Extract from Bitcoin Ops** (first consumer — already ships the pattern; a refactor **extracts**,
   it does not invent).
2. **Chemist Ops** = second consumer (proves the abstraction).
3. **Player Hub** = third consumer (migration from `LpPlayerHubRoot`, which predates this ruling — its
   own slice).
4. **Customize** = fourth consumer (new, post-ladder — `CUSTOMIZE_TAB_DOCTRINE_2026-07-15`).

**Gates:** lands **after** the current polish pass (OpenCode PR #130) + shell rebase
(`dispatch\opencode\0004`). **The shell extraction gets its own issue + lead agent** per
`LANE_LEAD_DOCTRINE_2026-07-15`.

## 7. ⚠ CONTRADICTION FLAGS — held for Bloodwave's word (I landed the substance verbatim; I did not silently reconcile)

Two clauses of this doctrine **reverse prior Bloodwave rulings.** Landed as written per the dispatch,
flagged here rather than smuggled:

1. **Active nav = "filled rounded block + LEFT ACCENT STRIP."** This **reverses** the **SIDEBAR
   HIGHLIGHT ruling** (Bloodwave, BOARD 2026-07-14: *"the left-aligned vertical blue accent bar … is
   NOT the LIFEPUNCH style. Use the BASE HIGHLIGHT only … no left-edge strip"*) **and**
   `SIDEBAR_DESIGN_CANON v1(c)` in `LIFEPUNCH_UI_STANDARD` (*"filled rounded block … the no-left-strip
   ruling stands"*). The Bloodwave-approved skeleton render shows the strip, so this **appears to be an
   intentional reversal** — **but the prior ruling was explicit, so it needs an explicit word.** If
   confirmed, `SIDEBAR_DESIGN_CANON v1(c)` + the SIDEBAR HIGHLIGHT ruling get a supersession note.
2. **Identity block at TOP.** `POLISH_RULINGS_2026-07-15` records sidebar identity position as **OPEN**
   (TOP as-shipped vs an earlier Bloodwave BOTTOM note — strike-one owed). This doctrine asserts
   **TOP**; if that is the resolving word, POLISH_RULINGS' OPEN item closes on TOP — **confirm.**

FROM: Red
