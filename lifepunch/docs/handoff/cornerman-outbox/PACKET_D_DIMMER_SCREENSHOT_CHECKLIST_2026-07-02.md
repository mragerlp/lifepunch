# Packet D — Dimmer screenshot checklist prep (paths for Red proof tonight)

**Node:** Green B (Cornerman) · distill only · unattended · 2026-07-02
**Status:** PREP ONLY — no in-game claims made from this session (eyes-covered law). Bridge status.json
was observed present (`\\VENGEANCE\SboxBridgeIpc\status.json` exists, last write 2026-07-02 07:35 UTC) but
MCP join / editor QA was explicitly skipped tonight per instructions — this is repo-only prep for Red to
execute the actual flatgrass proof pass.

## Checklist (Red to execute on Vengeance, Host Play → flatgrass)

Per `ACTIVE_WORKSTREAM.md` §3 proof package + `lifepunch-ui-scale` law dev checklist:

```text
☐ Screenshot #1 — StaffMenu default open, Day lighting, XL scale
☐ Screenshot #2 — StaffMenu default open, Night lighting, XL scale
☐ Screenshot #3 — Tab strip: .tab-sel active state visible (accent ring + soft fill)
☐ Screenshot #4 — Sidebar: expanded vs collapsed rail (.collapse-btn toggle, both states)
☐ Screenshot #5 — .player-row selected state (full accent fill, white text/icon)
☐ Screenshot #6 — .action-btn command grid, rest + hover state if capturable
☐ Screenshot #7 — UI scale S vs XL comparison (shell resize only, per lifepunch-ui-scale law)
☐ 30s clip — open StaffMenu → switch tabs → select a player row → collapse/expand sidebar
```

## Target file paths (for Red's reference during capture)

- `lifepunch/addons/Code/Addons/lifepunch/adminmenu/StaffMenu.razor.scss` (styles under proof)
- Sibling `.razor` (markup) — not read this session (SCSS-only distill); Red should confirm class wiring
  matches the selectors named above (`.tab-sel`, `.player-row.selected`, `.settings-entry-on`, `.collapsed`).

## Save location (once captured)

Per `ACTIVE_WORKSTREAM.md` §3: store proof paths/filenames in the polish checklist **Sign-off log** when
owner approves — this packet does not invent a new proof-storage location.

## Reminder — eyes-covered law

This packet does **not** assert that StaffMenu renders correctly, that the tab/selected-row wash looks any
particular way in-game, or that scale steps resolve visually. All of that requires Red's screenshot per the
checklist above. Green B's role here is limited to distilling *what to check* from the SCSS source, not
*confirming it looks right*.
