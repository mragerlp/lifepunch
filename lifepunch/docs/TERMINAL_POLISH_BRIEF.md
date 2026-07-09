# Terminal Polish — Gate-2 Brief

Status: SPEC CAPTURE (not a build order). Filed 2026-07-09 from Bloodwave's
annotated screenshots. Supersedes/extends the earlier drafted brief.
Priority: **slice-3 gate → commit → THEN gate 2 on this brief** (unchanged).
Relations: `TERMINAL_IDENTITY_SYSTEM.md` (dialect re-skin) ·
`LIFEPUNCH_UI_STANDARD.md` (chrome/selection laws · two-screen contract) ·
`UPGRADE_ARC_DESIGN.md` (arc build order · track #2 `terminal_security`).

Surface: the HASHD terminal panel (`LpHashdPanel` on the terminal entity —
distinct from the hub Bitcoin Ops panel). This brief is the base skeleton the
faction terminals re-skin (see item 5).

## 1. Chrome diet

- Title = **"HASHD TERMINAL"** — drop LIFEPUNCH from the title. Footer ™ stays.
- Top bar = **title + settings + CLEAR + ESC only.**
- The **HUB POWER / RACKS / SEL status ribbon leaves the header.** Session
  state already lives in the sidebar STATUS block and the `status` command —
  that is its home. **Terminal chrome ≠ status surface.**

## 2. Command list = reference, not shortcuts

- Entries read as **documentation**, not runnable buttons: `select <n>`, not
  `select 0` (per the original brief).
- Fix highlighting behaviors: **log highlight can't un-highlight** (original
  brief); selection styling follows the UI standard.
- **PRECEDENT (enforced on rig0, slice 3, 2026-07-09):** the command list is
  GRAMMAR, never instances — `link <rackId>` / `unlink <rackId>` /
  `select <rackId>`, one noun system across every rack-addressing verb.
  Numeric index parses as a silent legacy alias, undocumented. **Design intent
  on record:** players fetch rackIds from the HUB rack page (COPY button = the
  intended workflow) and TYPE them at the CRT — deliberate retro friction. No
  autocomplete, no click-to-fill, no IDs listed terminal-side.

## 3. Sidebar = STATUS tenants + retro readout + security line
   (amended 2026-07-09 per Bloodwave's sketches — merges the earlier
   "identity readout" item; one dialect-aware surface, three jobs)

- **STATUS block gains per-rack tenant lines:** true idents (`gpurack-1` /
  `gpurack-2` / `advancedgpurack` …), each with live state in the **three-state
  vocabulary, Law-13 colors** (sketch amendment 2026-07-09): **MINING (gold —
  BTC-in-motion, actively earning) · LINKED (green — connected, idle-healthy) ·
  OFF/UNLINKED (red).** The Power/Racks/Selected summary stays above.
- **Remaining sidebar space = the RETRO READOUT**, exact form from the sketch:
  **`Icon N ..... TIER X`** — numbered rows, icon left, dotted leader, roman
  tier right. This block renders the **TERMINAL entity's OWN tracks**
  (`terminal_security` etc. as they ship) — the CRT's text-ledger voice of the
  hub's circuits. The two-screen family, third voice.
- **SECURITY line:** `SECURITY ....... OK` (green) — **honest today, becomes
  the BREACH surface (red) when the Hacker lane ships**; counter-commands will
  live at this CRT. The HASHD Terminal sidebar is the defender's status
  surface — `terminal_security`'s tier renders here too (track #2, per the
  original item: the terminal detail surface EVALUATES, the Upgrades page
  TRANSACTS — two-screen contract, second entity).
- **Monitoring Suite is this sidebar as a purchasable tier**
  (`UPGRADE_ECONOMY_DOCTRINE.md`, HASHD Terminal table, ratified 2026-07-09):
  STATUS block (T1) → per-rack tenant lines → retro tier readout → remote
  alerts. Gate 2 builds the surface; the track's tiers literally unlock its
  rows when `terminal_security` ships.
- **Layout order top→bottom (sketch):** COMMANDS (existing) → STATUS summary →
  per-rack tenant lines → terminal upgrades readout → SECURITY line →
  *(space permitting)* a **dim contextual hint line** of 2–3 common verbs
  (`mining start · status · help`) — reference text, **NOT clickable**, and
  the first thing to yield if breach-state content needs room. The
  retro-friction law holds.
- All three respect the **fullscreen-PIN gate** (nothing visible pre-auth,
  item 4) and the **tokens-not-hardcoded seam** for dialect re-skins (item 5).
- **Settings-gear ruling (addendum 2026-07-09):** the gear popup's LINKED
  RACKS block is **superseded by the sidebar STATUS spec** — when the per-rack
  tenant lines build, **remove the rack list from the gear popup** (duplicate
  status hidden behind a click; has text-collision layout bugs —
  "IDLEgpurack-1", wrapped buffers — not worth fixing, worth retiring). The
  gear keeps ONLY true settings/utilities: Clear terminal log stays; future
  prefs (sound, boot-skip) live here. **Principle: status is always-visible
  sidebar content; the gear is for actions and preferences, never state.**

## 4. Fullscreen gates

- PIN pad and boot sequence **center and cover the ENTIRE panel below the
  chrome** — sidebar / commands / log are **invisible until PIN clears.**
  - **Bug being fixed:** the current build **leaks rack names pre-auth.**
- Boot keeps **click-to-skip.**
- Window bar + proprietary footer remain.

## 5. Family template note (design with the re-skin seam in mind)

This skeleton — **chrome / sidebar / log / fullscreen gates** — is the **base**
the **hacker + advanced-hacker + government** terminals re-skin via the
`TERMINAL_IDENTITY_SYSTEM` dialects. The staged **loading-screen assets are
those dialects' boot screens.**

Build the polish for the seam: **tokens, not hardcoded orange.** Every color,
sigil, and boot face routes through a dialect token so a re-skin is a token
swap, never a markup fork.
