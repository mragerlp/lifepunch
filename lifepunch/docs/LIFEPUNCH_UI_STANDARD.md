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

## Anti-patterns (the "too Claudey" list — reject on sight)

Icon tiles behind glyphs · pill buttons/chips · accent borders and glows ·
fill+border doubling · big radii (8–22px) · drop-shadowed windows ·
tracked-uppercase section headers · in-game watermarks/footers.

Full divergence work-list for the StaffMenu restyle (line-level): session
artifact `handoff/ULX_STYLE_TOKENS_2026-07-07.md` (untracked; Part 1 of it is
superseded by this page).
