# LIFEPUNCH UI Standard — brand-aligned panel chrome

> **Changelog 2026-07-14:** Token section reconciled to live `lifepunch.co` `:root`
> (`lifepunch/website/deployments/cloudflare-worker.mjs`) and the approved LP Player Hub
> design spec (`lifepunch/docs/superpowers/specs/2026-07-14-lp-player-hub-design.md`).
> Supersedes the prior DXRP-native purple `#7170e6` / `#191919` token block for LIFEPUNCH
> panel/menu UI. Restraint laws below still apply; HASHD CRT exemption unchanged.

Status: CANON — ratified 2026-07-08; tokens reconciled 2026-07-14.
Original bar (chrome reduction, no "too Claudey" decoration) stands. Brand identity for
LIFEPUNCH-authored panels now tracks the website source mark, not DXRP purple-sibling
chrome.

**Scope exemption:** the HASHD Terminal in-world screen keeps its gray CRT +
amber identity per `DECISION-0010` / `OPS_CRT_TERMINAL_THEMES` — this standard
governs panel/menu UI, not in-world themed screens.

## Token set (mirrors lifepunch.co `:root`)

Source: `cloudflare-worker.mjs` live CSS variables + Player Hub wireframe radii/type.

```scss
// Brand / surfaces (website :root)
$lp-blue:         #017AEF;                 // --lp-blue — primary action / selected wash
$lp-blue-hover:   #33A0FF;                 // --lp-blue-hover
$lp-blue-rgb:     1, 122, 239;             // --lp-blue-rgb — wash / focus alpha
$bg:              #000000;                 // --bg — shell root
$surface:         #1a1d23;                 // --surface — header, cards
$surface-inset:   #12151a;                 // --surface-inset — sidebar, insets
$card-header:     #22262e;                 // --card-header — raised card header
$border:          #374151;                 // --border — structural borders
$text-main:       #ffffff;                 // --text-main
$text-dim:        #9ca3af;                 // --text-dim

// Semantic fills (unchanged grammar — Law 13 / confirm-deny)
$good:            #199c3b;                 // solid affirmative button fill
$bad:             #931010;                 // solid destructive button fill
$accent-soft:     rgba(1, 122, 239, 0.08); // active/selected wash — ONLY accent bg

// Radii / type (Player Hub + website interactive scale)
$radius:          6px;                     // primary buttons / controls
$radius-card:     12px;                    // cards
// Type: Montserrat (headings) + Inter (labels/body/values)
// Spacing rhythm: 12px content · 8px control · 44px min hit (hub)
// Legacy DXRP-native tight radii (2px/4px) are retired for LP-authored panels
```

## Laws

1. **Radius is uniform and restrained.** 6px interactive controls, 12px cards.
   **Nothing is a pill** except true circles (avatars, color dots →
   `border-radius: 50%`).
2. **Accent is a wash, never chrome.** `$lp-blue` (`#017AEF`) appears ONLY as
   active/selected background at 4–8% opacity, primary solid actions, and live
   data tint. Never a decorative border ring, never behind an icon tile.
3. **Active state is carried by opacity, not color.** Nav rest ≈ 0.7 opacity →
   1 on hover/active, plus the barely-there accent wash. Icons stay neutral.
4. **Buttons are flat, solid, semantic.** Solid `$good`/`$bad` (or `$lp-blue`
   primary) fills, small bold label, 6px radius. **No icon tiles** — glyphs sit
   inline, bare.
5. **Rows are flat.** `rgba(white, 0.05)` fill or transparent. A card carries
   a fill OR a hairline divider — never both.
6. **Borders are hairline and rare.** Structural dividers only
   (`0.5px rgba(white, 0.04)`). Filled cards get no border.
7. **Typography is sentence-case.** Uppercase is reserved for tiny eyebrow
   labels (10–14px, tracked ≤0.5px). No tracked-uppercase heading stacks.
8. **No branding chrome in-HUD.** No footer/watermark/™/signature/glow, no
   window drop-shadow. Scrim `rgba(black, 0.5–0.55)` (optional `blur(5px)`).
   Branding belongs on the portal listing, not the live HUD.
9. **Two-screen contract for tracked entities** *(amended slice 3.5)*. Detail
   screen = EVALUATE: identity, stat rows on the standard dark plate, invested
   receipt, deep-link CTA. Upgrades screen = TRANSACT: the per-track purchase
   cards (solo-I / pair / solo-MAX states) with the confirm chip anchored to
   the card's Purchase button; the circuit steppers on the track rows are
   DISPLAY, never control. Every future tracked entity inherits the pair —
   no purchase surfaces on detail screens. Doctrinal grounding:
   `UPGRADE_ECONOMY_DOCTRINE.md`, THE ENTITY DETAIL CONTRACT (the landlord
   pattern reaching the presentation layer).
10. **Hierarchy principle.** Detail screens lead with identity/progression
    (what this entity IS and what it becomes next); stats condense to
    supporting lines beneath. Nothing hidden, everything re-ranked.
11. **One-page law.** Tracked-entity surfaces never grow sub-pages. The
    density escape is progressive disclosure on the same page — never
    navigation.
12. **Interactive visual passes carry hover inspection.** Every element of a
    visual pass (stepper bubbles, tier cells, status glyphs) answers on hover
    with state-adaptive detail. Polish is load-bearing — the "we cared" layer.
13. **Semantic money colors.** Gold/amber = BTC amounts (₿ — chips, rows,
    receipts) AND active earning states (MINING — BTC in motion). Green =
    DXRP cash amounts (the decorative $ figures), the purchase-affirmative ✓,
    and connected-healthy states (LINKED). Red = the denial family
    (shortfalls, ✕, rejection flashes, OFF/UNLINKED). Token-level grammar —
    inherits to every money surface: purchase cards, black market, Banker HUB.
    Semantic color binds to the VALUE only — parentheses, delimiters, and
    separators around money figures are typography, not currency; they stay
    neutral ("₿ 0.25" gold · "(" neutral · "$1,250" green · ")" neutral).
    **The grammar governs world-space displays** (prop readouts, LCD glass) —
    one language everywhere. World-text refinements: the ₿ ICON is orange
    (brand mark) while the AMOUNT is white (data) — the icon/amount split
    supersedes all-gold for world text; $ figures green, whole-dollar
    formatted; count-style states color by completion (0/3 red · partial
    gold/in-progress · full green), parens neutral per the delimiter rule.
    No branding chrome on prop readouts (the chrome diet reaches the world).
14. **Confirm-deny primitive.** A two-choice money moment is a bonded glyph
    pair — **affirm LEFT, deny RIGHT, always adjacent** (`[ + | - ]`). MEANING
    is fixed: YES | NO, one decision with two exits. COLOR is fixed: affirm
    green, deny red (per law 13; any ₿ amount stays gold beside them). The
    glyphs are costume (✓/✕ on the stepper chip today; may vary by surface) —
    **pair, order, and colors are the invariant.** Every future two-choice
    money moment reuses it: purchase cards, contracts, Banker, black market.
15. **Separator Law.** A composite display string is assembled C#-side and
    interpolated as ONE Razor node. A separator (`·` `/` `—`) NEVER sits as a
    bare literal in markup between two `@`-expressions — Razor splits it into
    its own text node and collapses the surrounding whitespace, which renders
    run-ons and stray leading marks. *Worked example (the bug that named this):*
    the Hub card's chip line rendered `·POWERED0/3 RACKS` — a stray dot and a
    run-on — because ` · ` was a literal between `@`-expressions; the rack cards
    were correct only because they happened to build their separator inside one
    interpolated string. Fix: build the whole string in C# (`$"{a} · {b}"`), or
    make each separator a discrete element with its own spacing
    (`<span class="lp-chip-sep">·</span>`). This is the *structural* companion
    to Law 13's rule that separators are neutral typography — Law 13 governs
    their COLOR, Law 15 governs their MARKUP.
16. **A card must not contradict the page it leads to.** An aggregate/summary
    card states the same truth as the surface it opens. Source its meta from the
    SAME data the destination renders — never a parallel query that can diverge.
    *Worked example:* the GPU RACKS category card sourced its count from
    `GetLinkedRacks()` while the chooser it opened rendered fixed slots; a hub
    holding three advanced racks (a bug) made the card read `3/3 · 3 MINING`
    over a page showing one rack. Fixed by reading the card off the same slots
    the chooser renders. Applies to every glance-value tile: it is a promise the
    next click must keep.

## LAW 17 — CURRENCY IDENTITY (ratified 2026-07-12, Bloodwave)
Every menu, panel, readout, or log line that displays currency displays its
identity through the SIGN: ฿ + gold/bitcoin-orange = BTC · $ + green = cash.
The colored sign is the invariant; bare "BTC"/cash text without sign+color
is a violation. Amount text is white by default on LP-authored surfaces;
full-colored amounts are PERMITTED where they match DXRP-native convention
(ULX, upstream menus) or where emphasis warrants — per-surface style
latitude at Bloodwave's eye, not a violation. Icon and container furniture
use theme colors and are not currency signals. Units and separators around
amounts are white ("/min", "/", "(100%)"). Labels following amounts are
white ("invested"). The two identities never share a color and never touch
without a separator (min 8px gap or divider — see Law 15 Separator Law).
DUAL-PRICE TOKEN: where both prices show, format is ฿4 | $20,000 — white
divider bar, tight gaps, each currency full-colored (sign AND amount;
dual-price warrants emphasis). Green is reserved for cash and success states
— never power, status, or BTC-adjacent controls. Applies to all current and
future LP surfaces that hold, move, or price currency. Reference
implementation: lpbitcoin HASHD set, Currency Standard v1.

## Anti-patterns (the "too Claudey" list — reject on sight)

Icon tiles behind glyphs · pill buttons/chips · accent borders and glows ·
fill+border doubling · oversized radii (>12px cards / decorative shells) ·
drop-shadowed windows · tracked-uppercase section headers · in-game
watermarks/footers.

Full divergence work-list for the StaffMenu restyle (line-level): session
artifact `handoff/ULX_STYLE_TOKENS_2026-07-07.md` (untracked; Part 1 of it is
superseded by this page).
