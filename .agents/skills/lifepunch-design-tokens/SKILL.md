---
name: lifepunch-design-tokens
description: "s&box adapter for ui-ux-pro-max. Locked LIFEPUNCH visual tokens, the s&box SCSS constraint table, and an APPLIES / TRANSLATES-AS / VOID-IN-SBOX map for every ui-ux-pro-max rule category. Use before any LIFEPUNCH Razor/SCSS panel, Player Hub, or brand-aligned menu work."
---

# LIFEPUNCH design tokens — the s&box adapter for `ui-ux-pro-max`

Web/mobile design intelligence assumes a browser. **s&box is not a browser.** This skill is the adapter:
it owns **tokens + engine constraints + applicability**, and nothing else.

**Read alongside:** `ui-ux-pro-max` (shape and priority) · `lifepunch-razor-ui` (**build law — it wins on
any conflict about how to write the file**).

## When to apply

Any new or changed `.razor` / `.razor.scss`, Player Hub, branded panel, or currency readout.
**Skip:** pure C# with no UI · ModelDoc · the HASHD in-world CRT (explicitly exempt, below).

---

## 1. Locked tokens

Source: `lifepunch/docs/LIFEPUNCH_UI_STANDARD.md` (reconciled 2026-07-14) · `cloudflare-worker.mjs` `:root`
· `lifepunch/docs/superpowers/specs/2026-07-14-lp-player-hub-design.md`.

| Token | Value | Use |
|---|---|---|
| `$lp-blue` / `--lp-blue` | `#017AEF` | Primary action; selected wash |
| `$lp-blue-hover` | `#33A0FF` | Hover |
| `$lp-blue-rgb` | `1, 122, 239` | Wash alpha |
| `$bg` | `#000000` | Shell root |
| `$surface` | `#1a1d23` | Header / cards |
| `$surface-inset` | `#12151a` | Sidebar / insets |
| `$card-header` | `#22262e` | Raised card header |
| `$border` | `#374151` | Structural border |
| `$text-main` | `#ffffff` | Body / values |
| `$text-dim` | `#9ca3af` | Secondary labels |
| `$good` / `$bad` | `#199c3b` / `#931010` | Affirm / deny |
| `$accent-soft` | `rgba(1,122,239,0.08)` | Selected wash **only** |
| `$radius` / `$radius-card` | `6px` / `12px` | Controls / cards |
| Type | **Poppins** (headings, buttons) + **Inter** (labels, body, values) | Brand pairing |
| Rhythm | **44px min hit** · 8px control gap · 12px content gap | Hub spacing |

**No raw hex in components.** Token vars only — a hex literal in a panel is a defect.

### Law 17 — currency grammar (RATIFIED)

| Sign | Color | Meaning |
|---|---|---|
| BTC mark (฿ / ₿ per surface) | gold / bitcoin-orange | BTC identity |
| `$` | green | DXRP cash |
| Amount text | white (default on LP panels) | Data |
| Separators / units | white | **Typography, not currency** |

Dual-price shape: **`฿4 | $20,000`** — white divider bar, tight gaps, **each side fully colored**.

### `$LP` mark — **PENDING-RATIFICATION**

`#017AEF` is a **temporary** `$LP` glyph/emphasis color. **Blue `$LP` is NOT Law 17 cash green — `$LP` is
not DXRP `$`.** The hub wireframe uses blue as a placeholder and is approved as such; **the final sign and
color remain an open Bloodwave ruling.** Until then, **label `$LP` as temporary in UI copy and in plans.**

### HASHD CRT — **EXEMPT**

The in-world HASHD terminal keeps its gray CRT + amber. **Out of scope for these panel tokens.**

---

## 2. s&box SCSS constraint table

**These are engine facts, not preferences. Most failures here are SILENT** — the rule is dropped and the
panel renders subtly wrong, with no error.

| Constraint | Engine behavior | Do this instead | Sensor |
|---|---|---|---|
| **No `@media`** | Unknown rule → **whole block skipped** | Flex-only shell-size classes; Razor `@if` for density | `lifepunch-razor-ui` SKILL.md:146-149 |
| **No `display: grid`** | Unsupported | `display: flex` only | `SBOX_RAZOR_SCSS_RULES.md` |
| **`inline-flex` invalid** | **Silently dropped** | `display: flex` | razor-ui SKILL.md:146-147 |
| **Forbidden display values** | `block` / `none` / `inline` / `inline-block` **fail the file** | Hide via Razor `@if`; lay out with flex | `SBOX_RAZOR_SCSS_RULES.md` |
| **No gradients** | `linear-gradient` invalid | Solid `background-color` | Same |
| **Parser reads words inside comments** | `property: value` shapes in `//` comments trip invalid-property warnings | Keep `property: value` shapes out of comments; ASCII in `@code` | razor-ui SKILL.md:138-149 |
| **No two adjacent `@()` in one attribute** | Transpiler emits `(A)(B)` with no `+` → **the whole class collapses** | Merge: `@( (A) + (B) )` | razor-ui SKILL.md:136-137 |
| **Class root** | A type selector on `PanelComponent` is skipped | `<root class="...">` | `SBOX_RAZOR_SCSS_RULES.md` + `razor_lint` |

### ✅ **[DISPROVEN — 2026-07-14, editor-proven]** — deep nesting is **NOT** an engine limit

> ## **THE CLAIM WAS FALSE. IT IS NOW DEAD.**
>
> **THE CLAIM (retired):** *"s&box silently drops SCSS selectors nested 4+ levels deep."*
>
> **THE EXPERIMENT** (`comms\red\0039`, Bloodwave GO): a probe panel nested six boxes, each painted a
> distinct background by a selector **one level deeper than the last** — `.depth-probe` (L1) → `.d1` (L2)
> → `.d2` (L3) → `.d3` (L4) → `.d4` (L5) → `.d5` (L6) → `.d6` (**L7**). Synced, cold-compiled, rendered,
> screenshot read back.
>
> ## **RESULT: ALL SEVEN LEVELS APPLIED. ZERO SELECTORS DROPPED.**
> **Every box painted its own colour — including L4, L5, L6 and L7, the exact depths the claim said would
> silently fail.** Sensor: `03_SCSS_DEPTH_PROBE_ALL_7_LEVELS_APPLIED.png`.
>
> **CONSEQUENCE — say this correctly from now on:**
> - **Deep nesting is NOT an engine constraint.** It does not belong in the constraint table above, and
>   **it must never again be cited as a reason a panel "silently renders wrong."**
> - **Flattening remains good STYLE** — shallow class trees are readable and easy to override. **Keep doing
>   it because it is good style, not because the engine forces it.** *That distinction matters: a style
>   preference dressed as an engine law sends the next debugger hunting a phantom.*
>
> ### WHY THIS ENTRY STAYS INSTEAD OF BEING DELETED
> The claim reached a **canon-grade skill** from an **L3 draft** (`comms\cursor\0020`) and a
> `.cursor/rules` file — **two advisory sources, neither of which is law** — and it sat here shaping how
> every seat wrote SCSS. **It was never true.** Deleting the entry would erase the lesson with the error.
>
> ## **AN UNPROVEN CLAIM IN A CANON SKILL IS INSTRUCTION, NOT A NOTE.** *Seats obey it whether or not it
> carries a hedge — and the hedge is what let it survive nine months of being wrong.* **Label it, sensor
> it, or cut it.**

**Validate every panel:** `lifepunchaddons/scripts/Validate-SboxRazorScss.ps1`

---

## 3. `ui-ux-pro-max` applicability map

**APPLIES** = use as written · **TRANSLATES-AS** = the intent survives, the mechanism does not ·
**VOID-IN-SBOX** = the engine has no such surface; ignore it.

| `ui-ux-pro-max` category | Applicability | Translation |
|---|---|---|
| **1 Accessibility** (CRITICAL) | **TRANSLATES-AS** | Contrast, keyboard focus, labels **APPLY**. ARIA / skip-links / screen readers are **VOID** — there is no a11y tree. Use **visible** labels, focus rings, and a clear escape route. |
| **2 Touch & Interaction** (CRITICAL) | **APPLIES** | 44×44 min, 8px spacing, press feedback, disabled-while-loading. Tokens already lock this. |
| **3 Performance** (HIGH) | **TRANSLATES-AS / VOID** | WebP/AVIF, `srcset`, CLS tricks are **VOID**. Keep panels light; avoid layout thrash; reserve space with flex stubs. |
| **4 Style Selection** (HIGH) | **TRANSLATES-AS** | Match the locked tokens. **No emoji icons.** "Platform-adaptive" → DXRP sibling restraint + brand blue. |
| **5 Layout & Responsive** (HIGH) | **TRANSLATES-AS** | Mobile-first breakpoints and viewport meta are **VOID** (no `@media`). Use flex-only shell-size classes; **one scroll region per tab.** |
| **6 Typography & Color** (MEDIUM) | **APPLIES** | Poppins + Inter; semantic tokens; **no raw hex in components.** |
| **7 Animation** (MEDIUM) | **TRANSLATES-AS** | 150–300ms crossfade if the engine accepts it; prefer `opacity`. Reduced-motion is mostly **VOID**. **No decorative motion.** |
| **8 Forms & Feedback** (MEDIUM) | **APPLIES** | Visible labels; errors near the field; **confirm/deny per Law 14.** |
| **9 Navigation** (HIGH) | **TRANSLATES-AS** | Sidebar tab rail. Deep links → in-hub tab switches. Bottom-nav mobile patterns are **VOID**. |
| **10 Charts & Data** (LOW) | **TRANSLATES-AS** | Prefer rows/plates over chart libs. **Color-not-only still APPLIES.** |

**VOID-IN-SBOX, explicitly:** viewport meta · disable-zoom · WebP/AVIF · `touch-action` · PWA/offline ·
bundle splitting · CSS Grid · `@media` breakpoints · hover-as-sole-affordance.

**APPLIES, explicitly:** touch-target sizes · spacing scale · contrast · focus visibility · single primary
CTA · state clarity · **semantic money colors (Law 13 / Law 17)**.

## Canon

`lifepunch/docs/LIFEPUNCH_UI_STANDARD.md` (tokens, Law 17) · `lifepunch/docs/SBOX_RAZOR_SCSS_RULES.md` ·
`.agents/skills/lifepunch-razor-ui/SKILL.md` (**build law — wins on conflict**) ·
`lifepunch/docs/superpowers/specs/2026-07-14-lp-player-hub-design.md`
