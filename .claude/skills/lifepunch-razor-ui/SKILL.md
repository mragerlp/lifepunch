---
name: lifepunch-razor-ui
description: LIFEPUNCH UI build law for s&box Razor panels and SCSS. Use for ANY .razor or .scss work — new panes, menus, HUD, entity detail pages, chips, rows, buttons, dialogs, upgrade tracks, cosmetics UI — including one-line style tweaks. Every LIFEPUNCH menu must read as a sibling of DXRP's native UI: same tokens, same restraint, chrome reduction is a feature. Never hardcode a hex, radius or spacing value; tokens are canon. Enforces the Entity Detail Contract, the Cosmetic Detail Contract, the Cosmetic Firewall (cosmetic code carries no economy references), chrome/status separation, and the dialect re-skin seam. Over-decorated menus read "too Claudey" and are rejected on sight.
---

# LIFEPUNCH Razor / SCSS — build law

**This skill points at canon. It does not restate it.** Read the cited file before building.

## 1. THE BAR

Every LIFEPUNCH menu reads as a **sibling of DXRP's native UI** — same tokens, same
restraint. **Chrome reduction is a feature.** The standard exists because Dimmer's feedback
on over-decorated menus was that they read **"too Claudey."**

Canon: **`lifepunch/docs/LIFEPUNCH_UI_STANDARD.md`** (ratified 2026-07-08).
Parity source: `lifepunchdxrp/game/Code/UI/styles.scss`, Party Menu, Dimmer's TabMenu.

## 2. TOKENS ARE NEVER HARDCODED

The token set lives at **`LIFEPUNCH_UI_STANDARD.md:15-32`** and mirrors native `styles.scss`.
They are SCSS `$vars` — `$bg`, `$bg-sidebar`, `$bg-raised`, `$bg-row`, `$accent`,
`$accent-soft`, `$good`, `$bad`, `$text`, `$text-dim`, `$border`, `$radius`, `$radius-shell`.

**Never write a raw hex, radius, or spacing number in a `.razor.scss`.** If a value you need
has no token, that is a canon question, not a local decision.

Spacing is `4/8/12/16/20/24 px`. Type is `12/14/16/18/22 px`. Both are the native scales.

## 3. THE LAWS — read them, do not paraphrase them

`LIFEPUNCH_UI_STANDARD.md:34-117`. The ones most often broken:

- **Radius is tiny and uniform** — 2px interactive, 4px shell. **Nothing is a pill** except
  true circles (avatars, colour dots → `border-radius: 50%`).
- **Accent is a wash, never chrome.** Purple appears ONLY as an active/selected background at
  4–8% opacity, and as text colour on live data. Never a fill, never a border ring, never
  behind an icon.
- **Active state is opacity, not colour.** Rest ≈ 0.7 → 1 on hover/active. Icons stay neutral.
- **Buttons are flat, solid, semantic** — `$good`/`$bad` fills, small bold label, 2px radius.
  **No icon tiles.** Glyphs sit inline, bare.
- **A card carries a fill OR a hairline divider — never both.**
- **Typography is sentence-case.** Uppercase only for tiny tracked eyebrow labels.

**Anti-patterns — reject on sight:** `LIFEPUNCH_UI_STANDARD.md:118+`. Check your work against
that list *before* reporting, not after review.

**Scope exemption:** the HASHD Terminal in-world screen keeps its gray CRT + amber identity
(`DECISION-0010` / `OPS_CRT_TERMINAL_THEMES`). This standard governs panel/menu UI, **not**
in-world themed screens.

## 4. THE ENTITY DETAIL CONTRACT

One component; the entity supplies the model. The Servers page is **the acceptance bar** —
5 `entity-chip-row`, 3 `server-stat-plate`, 0 foreign pills. Measure against it; do not
eyeball. `DevTrackRowProbe` reports L/R/W for any classed panel — measured conformance is
free, so take it.

Three chip grammars currently coexist and **only one is the standard**: `entity-chip`
(Servers, Law-13 state colours `green`/`gold`/`red`/`dim`). `settings-pill` and
`overview-snapshot-*` are legacy foreign grammars being retired.

> **A card must not contradict the page it leads to.** An aggregate that no detail page
> corroborates is a bug, not a summary.

Survey and costed conformance list: `lifepunch/docs/handoff/RECON_MENU_TOPOLOGY_2026-07-09.md`.

**FLAG — no definition of record.** "Entity Detail Contract" is cited by
`ECONOMY_DOCTRINE.md:60`, both 2026-07-09 recon briefs, the Customize design record, and
`LpHashdPanel.razor.scss` — but it is **defined nowhere**, including in
`LIFEPUNCH_UI_STANDARD.md`. Treat the Servers page as the operative definition, and say so
when you rely on it.

## 5. THE COSMETIC DETAIL CONTRACT, AND THE FIREWALL

A sibling of the Entity Detail Contract: one component, entity-supplied cosmetic model.
Topology mirrors Servers — **HUB → TERMINAL → GPU RACKS**, racks one level deeper.

### The Cosmetic Firewall — an architectural fact, not a policy

> **Cosmetic code carries NO reference to `YieldMultiplier`, `ComputeTier`, or any economy
> value.** No-P2W is enforced in code, not asserted in a doc.

Gate your own work before reporting:

```bash
grep -nE 'YieldMultiplier|ComputeTier' <the cosmetic files you touched>   # must be empty
```

### Signal / Style — the law that preserves recognition

- **SIGNAL — code-owned, never customizable:** power-on ramp, flow, wind-down envelope, the
  emissive **intensity ladder**, rack fan sounds. Signal is honest telemetry.
- **STYLE — player-owned:** hue, sound flavour, UI skin.

A rack's **brightness = live tier** (signal). Its **colour = badge** (style). A raider reads
brightness for tier; gold fans just mean someone donated. **Cosmetics touch STYLE only.**

Canon: `lifepunch/docs/handoff/STOPGO_CUSTOMIZE_COSMETICS_DESIGN_2026-07-10.md`.
Build stays **queued behind** `GATE_ADVANCEDRACK_SYNC_TWO_CLIENT.md` — equipped cosmetic
state must replicate, because the value of a donor skin is that **others** see it.

## 6. CHROME / STATUS SEPARATION

Chrome is structure — shell, nav, dividers, containers. Status is live state — chips, plates,
values, tier labels. **They never borrow each other's vocabulary.** A status colour never
becomes chrome; a chrome element never carries live state.

Precision drift is a real bug class here: the hub wallet renders at four different precisions
across panes while the refresh sensor resolves at 4 dp. **Moving a readout between panes
changes its precision silently.** See `RECON_WALLET_TRANSFERS_2026-07-09.md`.

## 7. THE DIALECT RE-SKIN SEAM

Terminal dialects re-skin through one seam — do not scatter theme conditionals through panel
code. Canon: **`lifepunch/docs/TERMINAL_IDENTITY_SYSTEM.md`**.

Two surfaces both call themselves "the terminal": `LpBitcoinTerminalPanel.razor` (in-world,
the live command surface) and the `Terminal` tenant page inside Servers (all-PLANNED,
describes upgrades). **Nothing links them.** A naming ruling is owed before either is
restyled — do not silently pick one.

## 8. Proof

UI is a panel surface, so it proves in the **fast scene** (`blank.scene`), not the world scene.
No visual claim without an `sbox` bridge screenshot from Red — see the `lifepunch-editor-gate`
skill. Read the PNG yourself.

Every LIFEPUNCH `.cs` / `.razor` / `.scss` file carries the
`PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co` header before any `using`, `namespace`, or
style. **Never** in the DXRP fork.
