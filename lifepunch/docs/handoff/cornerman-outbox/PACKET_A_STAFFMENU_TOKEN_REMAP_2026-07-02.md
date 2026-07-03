# Packet A — StaffMenu token remap notes + tab/selected-row wash (DRAFT, no SCSS applied)

**Node:** Green B (Cornerman) · distill only · unattended · 2026-07-02
**Source read:** `lifepunch/addons/Code/Addons/lifepunch/adminmenu/StaffMenu.razor.scss` (current, `ulx-v2` palette)
**Status:** NOTES ONLY — nothing written to StaffMenu.razor.scss. Owner GO required before apply.

**Note on work packets:** the two named source packets
(`to-cornerman-autopilot-ui-foundation-2026-07-02.txt`, `to-cornerman-ui-foundation-prep-2026-07-02.txt`)
were not found in the repo at distill time — this packet was built directly from the target
reference file instead. Flag to Red/Bloodwave in case those packets still need to be authored/committed.

## Current token set (lines 12–29)

```scss
$bg: #14161c;
$bg-raised: #1c1f27;
$bg-row: #252932;
$accent: #4f8cff;
$accent-hover: #3d7af0;
$accent-soft: rgba(79, 140, 255, 0.12);
$accent-glow: rgba(79, 140, 255, 0.14);
$dxrp-cyan: #08b2e3;
$danger: #e7544a;
$text: #e8eaed;
$text-dim: #9aa0ab;
$text-disabled: #6b7280;
$bg-disabled: #1e2129;
$border: rgba(255, 255, 255, 0.07);
$border-disabled: rgba(255, 255, 255, 0.04);
$ulx-footer-bg: #060606;
$shell-radius: 22px;
```

Legacy fallback tokens are still commented at line 31–32 (pre-`ulx-v2`) — do not delete, they are the
documented revert path if `.ulx-v2` is pulled from the razor.

## Tab wash (`.tabs .tab-sel`, lines 891–911)

Current selected-tab treatment: `$accent-soft` fill + `rgba(79,140,255,0.35)` border ring, `margin-bottom: -1px`
trick to cover the `.tabs` strip's bottom border. This is intentional (see inline comment @889) — any remap
must preserve the -1px overlap or a dark sliver reappears between fill and sides.

**Distill observation:** hover and selected states currently share the exact same `$accent-soft` background
(lines 894 vs 904) — visually a selected tab does not read differently on hover vs rest. If DXRP `PartyMenu`
parity wants a distinguishable "selected + hovered" wash, candidate token (draft only, NOT applied):

```scss
// candidate — do not apply without GO
$accent-soft-hover: rgba(79, 140, 255, 0.18);
```

## Selected player-row wash (`.player-row.selected`, lines 812–828)

Full accent fill (`background-color: $accent`) + white text/icon override, with an explicit nested
`&.selected:hover` pin (lines 825–827) to stop the transition flicker between `.selected` accent and the
`:hover` grey — this is a deliberate anti-flicker guard, not dead code. Any token remap touching `$accent`
must re-verify this pin still resolves to a flat, non-animating color on hover of a selected row.

## Reference comparison — BLOCKED

`dxrp-public PartyMenu.razor.scss` and `outbox/STAFF_MENU_PARTY_STYLE_DRAFT.scss` were **not found** in this
repo checkout (`Test-Path` / glob both empty). Cannot diff tab/selected-row language against DXRP Party
pattern until one of these is available locally. Distill stops here for the comparison; token candidates
above are self-contained observations from StaffMenu alone.

## Recommended next step (owner review)

1. Confirm whether `PartyMenu.razor.scss` should be vendored/copied in for reference, or if this comparison
   is deferred to Red (who may have `dxrp-public` checked out at `C:\Users\jared\Projects\dxrp-public`).
2. If accent-soft-hover distinction is wanted, Red applies as a single scoped diff to `.tab-sel:hover` only —
   not a global `$accent-soft` rename (that would also touch `.action-btn .material-icons` fill, out of scope).
