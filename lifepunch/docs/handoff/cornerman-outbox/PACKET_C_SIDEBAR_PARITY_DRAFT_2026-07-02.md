# Packet C — Sidebar parity Razor/SCSS DRAFT (layout only, NOT applied)

**Node:** Green B (Cornerman) · distill only · unattended · 2026-07-02
**Source read:** `StaffMenu.razor.scss` lines 374–775 (sidebar block, collapse rail, settings-entry)
**Status:** LAYOUT DRAFT for discussion only — no file writes to StaffMenu.razor or .razor.scss.

## Current sidebar structure (as read)

- Sidebar owns full body height down to the window's rounded bottom-left corner (comment @374, @441) —
  chrome (header) is a separate flex-shrink:0 sibling, sidebar + main content share the remaining flex row.
- Collapse rail: `.collapse-btn` chevron (comment @416) toggles a `collapsed` modifier class; collapsed
  state shrinks `.settings-entry` to a centered 32×32 cog only (lines 763–774), no label.
- `.player-row` list has NO hover transition by design (comment @787–790: avoids "smear" on dense lists),
  while `.tabs .tab` DOES have a transition (sparse controls, can't smear). **This split is a deliberate,
  documented pattern — any sidebar parity pass must preserve list-vs-tab transition asymmetry, not
  standardize on one.**
- Settings entry active state uses a standalone `.settings-entry-on` class (comment @752) specifically to
  win CSS specificity ties over the base `.settings-entry` — same pattern family as `.tab-sel` (both avoid
  relying on selector order for correctness under s&box's CSS subset).

## Layout parity draft — flex-scroll chain (per `lifepunch-ui-scale` law)

Following the mandatory flex-scroll chain (`.shell` → chrome flex-shrink:0 → `.lp-ui-workspace` flex:1 →
scroll region), a sidebar-parity draft for a **second panel reusing this pattern** (e.g. if HASHD or another
menu wants StaffMenu-style sidebar) would look like:

```scss
// DRAFT — illustrative only, not written into any live file
.lp-sidebar-parity {
	flex-direction: column;
	flex-shrink: 0;       // sidebar itself doesn't compress
	width: 220px;         // match StaffMenu's implied rail width — confirm exact px from .razor markup
	min-height: 0;
	overflow: hidden;

	.lp-sidebar-scroll {
		flex: 1 1 auto;
		min-height: 0;
		overflow-y: scroll;  // player-row-style list: NO transition on rows (smear law)
	}

	.lp-sidebar-footer {
		flex-shrink: 0;       // settings-entry / collapse rail pinned to bottom
	}
}
```

**Not yet confirmed:** exact sidebar width in px (would need the `.razor` markup, not just `.razor.scss`,
to confirm class wiring — out of scope for this distill pass, SCSS-only per instructions). Flag to Red for
markup-level confirmation before any real apply.

## Open question for Bloodwave / Red

Is "sidebar parity" meant to be (a) a reusable shared partial/class other menus import, or (b) a one-off
visual match on a specific second panel? The draft above assumes (a) since that matches the `lp-ui-*` shared
class convention (`LifePunchUiShell.scss`) documented in `lifepunch-ui-scale` law — but this was not
explicit in the available grounding docs. No code applied pending that answer.
