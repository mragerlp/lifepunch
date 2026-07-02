# Packet B — Chrome weight reduction notes (`.header`, `.action-btn` flatten) (DRAFT, no SCSS applied)

**Node:** Green B (Cornerman) · distill only · unattended · 2026-07-02
**Source read:** `StaffMenu.razor.scss` lines 127–150 (`.header`), 1147–1211 (`.action-btn`)
**Status:** NOTES ONLY — no SCSS changes made.

## `.header` (lines 127–144)

```scss
.header {
	flex-direction: row;
	flex-shrink: 0;
	align-items: center;
	justify-content: space-between;
	padding: 14px 20px 16px 20px;
	background-color: $bg-raised;   // #1c1f27 — one step lighter than $bg
	border-bottom: 1px solid $border;
	...
}
```

**Current weight:** `$bg-raised` fill + 1px `$border` divider + generous padding (14/20/16/20). This is a
fairly heavy title bar relative to the 22px shell radius — asymmetric bottom padding (16 vs 14 top) is
intentional per the inline comment (flex-shrink:0 lock note @129) but does add visual weight.

**Flatten candidates (draft only — do NOT apply without Bloodwave GO):**
- Reduce padding to `12px 18px` uniform (saves ~4-6px vertical, keeps the lock-height comment's intent).
- Consider dropping `background-color: $bg-raised` to `$bg` + border-only separation, if the goal is a
  flatter "hairline" header matching lighter DXRP chrome. This is a bigger visual change — flag explicitly,
  don't bundle silently with a padding tweak.

## `.action-btn` (lines 1147–1211)

```scss
.action-btn {
	height: 90px;
	padding: 8px 6px;
	border-radius: 11px;
	background-color: $bg-row;      // #252932
	border: 1px solid $border;
	...
	.material-icons {
		font-size: 22px;
		padding: 8px;
		border-radius: 10px;
		background-color: $accent-soft;
	}
	&:hover {
		background-color: #2d323d;  // hardcoded — NOT a token, inconsistent with $bg-row usage elsewhere
	}
}
```

**Distill observation — hardcoded hover color:** `#2d323d` at line 1188 is a literal hex, not a token,
while every adjacent state (`$bg-row`, `$bg-disabled`) uses SCSS variables. Candidate cleanup (draft only):

```scss
// candidate — do not apply without GO
$bg-row-hover: #2d323d;
```
...then reference `$bg-row-hover` at `.action-btn:hover` (and audit for other hardcoded hex hovers while
in this file, if Red wants a broader token-completeness pass).

**Weight reduction candidates:**
- `height: 90px` is tall for a 4-per-row icon+label tile grid; a `76–80px` box with `.material-icons`
  font-size trimmed to `20px` would reduce chrome bulk while keeping the icon legible. This changes layout
  math (min-width: 120px, 4-per-row via flex-basis:0) — needs a flatgrass proof pass, not a blind resize.
- `padding: 8px` on the icon chip (line 1182) plus `border-radius: 10px` around a 22px icon is generous;
  `6px` padding / `8px` radius would tighten the chip without changing the 4-per-row grid math.

## Scope guard

Per StaffMenu inline law (line 106): *"Do NOT override action-btn, sidebar, or tab metrics per step (that
squashes glyphs)."* Any chrome-weight change here must be a **single global edit**, not a per-UI-scale-step
override — consistent with existing `.lp-ui-size-*` law (lines 107–125, shell-only sizing).
