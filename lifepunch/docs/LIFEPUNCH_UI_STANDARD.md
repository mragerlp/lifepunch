# LIFEPUNCH UI Standard — DXRP-native sibling style

Status: CANON — ratified 2026-07-08. Source: the 2026-07-07 parity extraction
against DXRP-native menus (`lifepunchdxrp/game/Code/UI/styles.scss`, Party Menu,
Dimmer's TabMenu — the documented `dxura/dxrp#73` parity style), driven by
Dimmer's feedback that over-decorated menus read "too Claudey".

**The bar:** every LIFEPUNCH menu reads as a **sibling of DXRP's native UI** —
same tokens, same restraint. Chrome reduction is a feature.

**Scope exemption:** the HASHD Terminal in-world screen keeps its gray CRT +
amber identity per `DECISION-0010` / `OPS_CRT_TERMINAL_THEMES` — this standard
governs panel/menu UI, not in-world themed screens.

## Token set (mirrors native `styles.scss`)

```scss
$bg:            #191919;                 // native $color-primary (window surface)
$bg-sidebar:    #111111;                 // native $color-secondary (recessed)
$bg-raised:     #1f1f23;                 // neutralized raised elevation
$bg-row:        #26262b;                 // neutralized row elevation
$accent:        #7170e6;                 // native $color-accent — wash/data only
$accent-soft:   rgba(113,112,230,0.08);  // active wash — the ONLY accent bg
$good:          #199c3b;                 // solid affirmative button fill
$bad:           #931010;                 // solid destructive button fill
$text:          #F6F9FF;                 // native $color-tertiary
$text-dim:      #888b91;                 // native $color-gray-400
$border:        rgba(255,255,255,0.04);  // hairline divider (0.5px structural)
$radius:        2px;                     // ALL interactive elements
$radius-shell:  4px;                     // the one large container
// spacing 4/8/12/16/20/24 px · type 12/14/16/18/22 px (native scales)
```

## Laws

1. **Radius is tiny and uniform.** 2px interactive, 4px shell. **Nothing is a
   pill** except true circles (avatars, color dots → `border-radius: 50%`).
2. **Accent is a wash, never chrome.** Purple appears ONLY as active/selected
   background at 4–8% opacity and as text color on live data. Never a fill,
   never a border ring, never behind an icon.
3. **Active state is carried by opacity, not color.** Nav rest ≈ 0.7 opacity →
   1 on hover/active, plus the barely-there accent wash. Icons stay neutral.
4. **Buttons are flat, solid, semantic.** Solid `$good`/`$bad` fills, small
   bold label, 2px radius. **No icon tiles** — glyphs sit inline, bare.
5. **Rows are flat.** `rgba(white, 0.05)` fill or transparent. A card carries
   a fill OR a hairline divider — never both.
6. **Borders are hairline and rare.** Structural dividers only
   (`0.5px rgba(white, 0.04)`). Filled cards get no border.
7. **Typography is sentence-case.** Uppercase is reserved for tiny eyebrow
   labels (10–14px, tracked ≤0.5px). No tracked-uppercase heading stacks.
8. **No branding chrome in-HUD.** No footer/watermark/™/signature/glow, no
   window drop-shadow. Scrim `rgba(black, 0.5–0.55)` (optional `blur(5px)`).
   Branding belongs on the portal listing, not the live HUD.
9. **Two-screen contract for tracked entities.** Detail screen = EVALUATE
   (identity + this-entity next-step delta) · upgrades screen = TRANSACT
   (full circuit + confirm chip). Every future tracked entity inherits the
   pair — no purchase surfaces on detail screens, no telemetry heroes on
   upgrade screens.
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

## Anti-patterns (the "too Claudey" list — reject on sight)

Icon tiles behind glyphs · pill buttons/chips · accent borders and glows ·
fill+border doubling · big radii (8–22px) · drop-shadowed windows ·
tracked-uppercase section headers · in-game watermarks/footers.

Full divergence work-list for the StaffMenu restyle (line-level): session
artifact `handoff/ULX_STYLE_TOKENS_2026-07-07.md` (untracked; Part 1 of it is
superseded by this page).
