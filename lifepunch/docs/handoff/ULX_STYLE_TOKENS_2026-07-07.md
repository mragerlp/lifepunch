# ULX ↔ DXRP-native style tokens — parity extraction (2026-07-07)

**Purpose.** Ground the lifepunchulx StaffMenu restyle (Dimmer feedback: menus read "too Claudey" / over-decorated) against the DXRP-native house style. Target = read as a **sibling** of our own Party Menu, which already matches Dimmer's TabMenu (the documented `dxura/dxrp#73` parity style). **Functionality unchanged — this is chrome reduction only.**

**Sources (Red-side; Green couldn't do this — the reference files live in the gitignored `lifepunchdxrp/` fork, see PACKET_A 2026-07-02 "Reference comparison — BLOCKED"):**
- Native tokens: `lifepunchdxrp/game/Code/UI/styles.scss`
- Party Menu: `lifepunchdxrp/game/Code/UI/HUD/Components/PartyMenu.razor(.scss)`
- TabMenu (Dimmer): `lifepunchdxrp/game/Code/UI/Menus/TabMenu/TabMenu.razor(.scss)`
- Current: `lifepunchaddons/Code/Addons/lifepunch/adminmenu/StaffMenu.razor(.scss)`

---

## Part 1 — Shared native style-token spec (Party Menu ∩ TabMenu)

Both reference menus `@import "styles.scss"` and draw from the same token set. The shared language:

### Tokens (from `styles.scss`)
| Token | Value | Role |
|---|---|---|
| `$color-primary` | `#191919` | content-pane / window surface |
| `$color-secondary` | `#111111` | sidebar surface (recessed) |
| `$color-tertiary` | `#F6F9FF` | primary text (near-white, faintly cool) |
| `$color-white` | `#ffffff` | max-emphasis text / selected-row text |
| `$color-gray-400` | `#888b91` | dim/secondary text, rest-state icons |
| `$color-accent` | `#7170e6` | **accent only** (purple) |
| `$color-good` | `#199c3b` | solid affirmative button fill |
| `$color-bad` | `#931010` | solid destructive button fill |
| `$rounding` | **`2px`** | radius on essentially everything |
| `$space-1..6` | `4 / 8 / 12 / 16 / 20 / 24 px` | spacing scale |
| `$text-xs..xl` | `12 / 14 / 16 / 18 / 22 px` | type scale |
| `$border` | `rgba(white, 0.025)` | (defined but dividers usually hand-rolled at `0.04`) |

### Shared patterns
- **Radius is tiny and uniform.** `$rounding: 2px` on buttons, rows, inputs, cards. The one large container (TabMenu `.menu-container`) uses `$space-1` = **4px**. PartyMenu `.window` uses `$rounding` = 2px. **Nothing is a pill** except true circles (avatars, color dots → `border-radius: 50%`).
- **Accent is a wash, never chrome.** Purple appears *only* as: active/selected background at **4–8% opacity** (`rgba($color-accent, 0.04–0.08)`), and as **text color** on live data (player job label, finance values). Never a fill, never a border ring, never behind an icon.
- **Active state is carried by opacity, not color.** Sidebar nav (`.menuButton`) sits at `opacity: 0.7`, rises to `1` on hover/active; the active wash is a barely-there `rgba(accent, 0.05–0.08)`. Icons are plain `$color-tertiary`/`gray-400` — *not* accent, *not* tiled. No per-row dividers, no borders on nav rows.
- **Buttons are flat, solid, semantic.** PartyMenu `.primary-btn` = solid `$color-good` fill; `.danger-btn` = solid `$color-bad`; label 11px/700, `$rounding`. No icon tile behind the glyph.
- **Rows are flat.** `rgba(white, 0.05)` fill (or transparent), `$rounding`, optional 10px color dot. Selected = `rgba(accent, 0.08)` wash. Cards carry a fill **or** a `0.5px rgba(white,0.04)` divider — **not both**.
- **Borders are hairline and rare.** Structural dividers only: `0.5px solid rgba(white, 0.04)` (sidebar edge, title-bar underline). Filled cards get **no** border.
- **Typography is mostly sentence-case.** TabMenu `.section-header h1` = `$text-2xl` (30px)/600, white, **not uppercase**. Uppercase is reserved for *small eyebrow* labels only: `.section-group-title` (14px/600, accent, uppercase) and PartyMenu `.section-label` (10px, uppercase, 0.5px). The single window title (PartyMenu `.title`) is 14px/700 uppercase/0.5px — small, not a heading stack.
- **No branding chrome.** No footer, no watermark, no ™, no signature, no glow. Overlay scrim `rgba(black, 0.5–0.55)`; TabMenu adds `backdrop-filter: blur(5px)`. **No window drop-shadow.**

### Proposed target ULX token set (mirrors native; implement in Part 2)
```scss
$bg:            #191919;                 // native $color-primary        (was #14161c)
$bg-raised:     #1f1f23;                 // neutralized raised elevation (was #1c1f27)
$bg-row:        #26262b;                 // neutralized row elevation    (was #252932)
$accent:        #7170e6;                 // UNCHANGED — already native $color-accent
$accent-hover:  #5f5ed4;                 // UNCHANGED
$accent-soft:   rgba(113,112,230,0.08);  // UNCHANGED — wash only
$danger:        #e7544a;                 // keep (close/kick affordance)
$text:          #F6F9FF;                 // native $color-tertiary        (was #e8eaed)
$text-dim:      #888b91;                 // native $color-gray-400        (was #9aa0ab)
$border:        rgba(255,255,255,0.04);  // native hairline divider       (was 0.07)
$radius-shell:  4px;                     // native large container        (was $shell-radius 22px)
$radius:        2px;                     // native $rounding, all interactive
// DROP: $accent-glow, $ulx-footer-bg branding usage, all icon-tile backgrounds
```
The accent **already matches** native (`#7170e6` = `$color-accent`, set in PACKET_A's `ulx-v2` for dxrp#73). The gap is **not hue** — it's radius, elevation cast, icon tiles, pills, footer, borders, shadow, and casing.

---

## Part 2 — Divergence table (StaffMenu current → target)

Line refs = `StaffMenu.razor.scss`. **Priority:** ⬛ core (Bloodwave's directives) · ◻ parity-polish.

### A. Radius (native 2px interactive / 4px shell)
| Element | ~Line | Current | Target | Pri |
|---|---|---|---|---|
| `$shell-radius` (window, watermark round) | 30, 70, 89 | `22px` | `4px` (`$radius-shell`) | ⬛ |
| `.action-btn` | 1228 | `11px` | `2px` | ⬛ |
| `.tabs .tab` | 857 | `9px` | `2px` | ⬛ |
| `.header-chip` | 158 | `999px` (pill) | `2px` | ⬛ |
| `.chip` (duration presets) | 1071 | `14px` (pill) | `2px` | ⬛ |
| `.panel-size-opt` | 1684 | `999px` (pill) | `2px` | ⬛ |
| `.job-dropdown-header` / `-list` | 1116, 1149 | `8px` | `2px` | ⬛ |
| `.job-option` | 1165 | `6px` | `2px` | ⬛ |
| `.confirm-btn` | 1193 | `8px` | `2px` | ⬛ |
| `.arg-form` | 1029 | `10px` | `4px` | ⬛ |
| `.target-banner` | 980 | `8px` | `2px` | ⬛ |
| `.profile-card` / `.settings-group` / `.audit-table` / `.wp-list` | 1311, 1654, 1522, 1925 | `10–12px` | `4px` | ⬛ |
| `.action-pill` (audit) | 1611 | `10px` | `2px` | ◻ |
| `.icon-btn` / `.lp-ui-chrome-btn` | 200, 275 | `8px` | `2px` | ◻ |
| `.title-badge` | 2085 | `12px` | **removed** (Part 3 §5) | ⬛ |
| `.job-swatch` | 1126 | `3px` | `2px` (leave — negligible) | ◻ |

### B. Accent demotion (chrome → accent-only: active states + data highlights)
| Element | ~Line | Current (accent as chrome) | Target | Pri |
|---|---|---|---|---|
| `.action-btn .material-icons` | 1248–1252 | accent glyph in `$accent-soft` tile, `8px` pad, `10px` radius | plain glyph, **no tile bg**, color `$text-dim` (accent optional on hover) | ⬛ |
| `.title-badge` bg + `box-shadow: …$accent-glow` | 2086–2088 | accent-soft fill + accent glow | **remove badge** | ⬛ |
| `.tabs .tab-sel` | 887–889 | `$accent-soft` fill + `$accent-border` ring + `-1px` overlap | drop ring + `-1px`; active = faint `$accent-soft` wash + full-strength text/weight (native menuButton language) | ⬛ |
| `.header-chip-link:hover` | 176–177 | accent-border + accent-soft | neutral hover (`rgba(white,0.06)`) | ⬛ |
| `.arg-form` border | 1031 | `1px solid $accent` | `1px solid $border` | ⬛ |
| `.profile-avatar` border | 1370 | `2px solid rgba(accent,0.3)` | `2px solid rgba(white,0.15)` (native color-preview border) | ◻ |
| `.chip.active` | 1085–1087 | accent-soft **+ accent-border ring** | accent-soft wash only (drop ring) — selected-data highlight is OK | ◻ |
| `.player-row.selected` | 806 | **solid** `$accent` fill + white text | native uses a *wash* (`rgba(accent,0.08)` + accent text). Soften for roster parity **but preserve the `&.selected:hover` anti-flicker pin** (PACKET_A). Judgment call → confirm in Step 2. | ◻ |
| **Keep as-is (legit accent):** `.group-label` accent eyebrow (682), `.job-option.active` (1178), `.action-pill` data tag (1611), live stat text colors in razor (health/armor/cash) | — | accent = data highlight | keep | — |

### C. Elevation & surface cast
| Element | ~Line | Current (cool/blue cast) | Target (native warm-neutral) | Pri |
|---|---|---|---|---|
| `$bg` | 13 | `#14161c` | `#191919` | ◻ |
| `$bg-raised` | 14 | `#1c1f27` | `#1f1f23` | ◻ |
| `$bg-row` | 15 | `#252932` | `#26262b` | ◻ |
| `$text` | 23 | `#e8eaed` | `#F6F9FF` | ◻ |
| `$text-dim` | 24 | `#9aa0ab` | `#888b91` | ◻ |

### D. Borders (native hairline; no fill+border doubling)
| Element | ~Line | Current | Target | Pri |
|---|---|---|---|---|
| `$border` | 27 | `rgba(255,255,255,0.07)` | `rgba(255,255,255,0.04)` | ⬛ |
| Filled cards carrying **both** fill + `1px $border` (`.arg-form`, `.target-banner`, `.settings-group`, `.audit-table`, `.wp-list`, `.action-btn`) | various | fill **and** 1px border | keep fill; drop border **or** thin to `0.5px` divider — not both | ⬛ |
| Structural dividers (`.header` underline, `.players` right edge) | 137, 460 | `1px $border` | `0.5px rgba(white,0.04)` | ◻ |

### E. Shadow & overlay
| Element | ~Line | Current | Target | Pri |
|---|---|---|---|---|
| `.window` `box-shadow` | 73 | `0 28px 64px rgba(0,0,0,0.72)` | **remove** (native has none) | ⬛ |
| root scrim | 48 | `rgba(4,6,12,0.62)` | `rgba(0,0,0,0.55)` (+ optional `blur(5px)` per TabMenu) | ◻ |

### F. Typography & casing (sentence-case the headers)
| Element | ~Line | Current | Target | Pri |
|---|---|---|---|---|
| `.title-primary` + `.title-sub` | 2101–2113 | 18/700 title **stack** + uppercase "ULX CONSOLE" eyebrow | single "Admin Menu" title, native 14px/700 (drop the sub-eyebrow stack) | ⬛ |
| `.pane-title` | 413 | uppercase, `letter-spacing: 1px` | sentence-case "Online Players", drop tracking | ⬛ |
| `.parent-label` | 631 | uppercase, `1.2px` tracking | sentence-case "Staff (n)" / "Players (n)", drop tracking | ⬛ |
| `.audit-row-head` | 1596 | uppercase, `0.6px` | keep (table-header convention; tiny) — thin tracking to `0.4px` | ◻ |
| `.group-label` | 682 | uppercase, accent, `1.1px` | **keep** — matches native `.section-group-title` eyebrow | — |

---

## Part 3 — Structural notes (StaffMenu patterns the native style lacks)

These are *structures*, not just token values — the restyle removes/flattens them.

1. **Icon tiles on action buttons.** `.action-btn` renders every glyph inside an `$accent-soft` rounded tile (`padding:8px; border-radius:10px; background:$accent-soft; color:$accent`, scss 1244–1252). Native buttons place the icon **inline, bare** (PartyMenu `.primary-btn` = `<i>` + label, no tile). → **Flatten:** remove the tile background/padding/radius; glyph sits inline, neutral color. This is the single most "Claudey" element and the top-line fix.

2. **Pill buttons.** `.header-chip` (999px), `.chip` (14px), `.panel-size-opt` (999px) are pill-shaped. Native has **no** pills (only true circles). → De-pill to `2px` (Part 2 §A).

3. **Branded footer + signature (in-HUD).** `.lp-window-watermark` + `<LifePunchUiFooter />` (™ mark + URL, scss 77–104, 250–268) and the `.signature` ownership mark (376–400) put branding on the live HUD panel. Native menus have none. → **Minimize in-game:** the ™/URL belongs on the **portal listing**, not the HUD. Propose hiding the watermark row + signature in the in-game menu (retain the component for portal/store screenshots via a class toggle if wanted). Confirm scope in Step 2.

4. **Large tracked-uppercase headers.** `.pane-title`, `.parent-label` render section headers in tracked UPPERCASE. Native section headers are sentence-case (`.section-header h1`); uppercase is reserved for tiny eyebrows. → Sentence-case the big ones (Part 2 §F); keep only the `.group-label` eyebrow.

5. **Title badge + glow + heading stack.** `.title-badge` = 42×42 accent tile with `box-shadow: 0 0 18px $accent-glow` wrapping a shield glyph, beside a two-line `.title-stack` (18px "Admin Menu" + uppercase "ULX Console"). Native title = one small text line. → **Remove** badge, glow, and the sub-eyebrow; keep a single "Admin Menu" title (shield glyph inline is fine, un-tiled).

6. **Heavy window frame.** 22px radius + `0 28px 64px` drop-shadow. Native windows: 2–4px radius, no shadow, scrim only. → Part 2 §A/§E.

7. **Fill + border doubling.** Many cards carry both a fill and a 1px border (belt-and-suspenders). Native uses one or the other. → Part 2 §D.

### 🔒 /job dropdown — inherit tokens, do NOT regress structure
The just-committed searchable `/job` dropdown (`.job-dropdown`, `-header`, `-list`, `.job-option`, `.job-swatch`, `.job-filter`, `.job-chevron`, `.job-placeholder`; razor 598–626) **keeps its structure**: header button → filter TextEntry → scrollable option list with color swatches → toggle chevron. The restyle only touches its **token values** (radius `8px`/`6px`→`2px`; `.job-option.active` stays `$accent-soft` as a legit data highlight; `.job-swatch` unchanged). **No markup edits to the dropdown, no behavior change** — verify it still opens/filters/selects after the sync in Step 3.

---

**Next:** Step 2 — restyle hunks proposed against this table, STOP for GO. Step 3 — apply → one-shot repo→DXRP sync → sbox-bridge screenshot vs Party Menu → iterate to sibling parity → Bloodwave verifies in-game before commit.
