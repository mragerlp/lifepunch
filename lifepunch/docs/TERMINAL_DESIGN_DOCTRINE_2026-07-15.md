# LIFEPUNCH TERMINAL DESIGN DOCTRINE — v1

**RATIFIED 2026-07-15, Bloodwave.** Graduated from the session seed `comms\fable\0084`
(`FABLE #8 — TERMINAL DESIGN DOCTRINE SEED v1`) per `dispatch\red\0002` Rider 7. Extends the
**MENU SHELL LAW** (`LIFEPUNCH_UI_STANDARD.md`) with the second UI family.

**Design sensors (Bloodwave chat-carried, 2026-07-15):** OpenCode TUI screenshots ×7, `opencode.ai`
landing, `terminaltrove.com` catalog (explore + `/ai-coding-agents/opencode/`). The doctrine cites
them; seats need not re-browse.

> **CLASS: CANON v1.** Living doctrine — amend with a changelog entry; supersede ruled sub-clauses
> with dated notes, never silent edits.

---

## §1 TWO UI FAMILIES (extends MENU LAW)

- **MENUS** = Player Hub shell grammar (rail+card, Poppins, sidebar canon) — `LIFEPUNCH_UI_STANDARD`
  MENU SHELL LAW.
- **TERMINALS** = TUI grammar (this doctrine). **A terminal is not a menu; the visual split is
  intentional and canonical.**

**Both families share, immutably:** the **universal header/footer STRUCTURE** (per-surface accent,
structure never changes — `BRANDING_SCOPE_RULING_2026-07-15`) and the **Law 17 currency grammar**
(immutable under any theme or family).

### §1b THE LAYER MODEL

- **LAYER 1 — MENUS:** Player Hub, entity/job hubs, every first-touch surface. Simple, light,
  hub-shell grammar: setup, status, purchase, navigation. **A player should never need Layer 2 to
  play the game.**
- **LAYER 2 — TERMINALS:** the complex-operations console an entity opens when its function outgrows
  a menu (**HASHD terminal = the archetype**). Dense state, live operations, the click-first /
  type-deep model (§2).

**THE TERMINAL IS A FOUNDATIONAL COMPONENT, NOT A ONE-OFF.** Build **ONE terminal framework** (shell,
status bars, panel system, subterminal, theme layer); every job that needs complex operations
**SKINS AND CONFIGURES IT** — HASHD/bitcoin first, then chemist lab consoles, bank/hacker systems,
future job surfaces. Per-job identity = **mark + accent + command set + panes**; **the framework
never forks.** Same one-owner discipline as the shared-infra map: one framework, many consumers, no
copies. The asset backlog waiting on the AI stack lands **through** this framework, not as bespoke
per-job UIs.

## §2 INTERACTION MODEL — CLICK-FIRST, TYPE-DEEP

Terminals are **CLICKABLE TUIs**: bordered panels, rows, and inverted-block buttons are mouse targets
(s&box Razor panels styled as TUI — the engine makes click-first natural; the TUI look is a **skin,
not a constraint**). A dedicated **SUBTERMINAL** pane carries the typed command line: prompt row,
orange block cursor, `enter send` hint. Design intent (Bloodwave verbatim shape): *"user-friendly,
but also complex and cool-hacky."*

- **CLICK = the accessible path:** every core function reachable by mouse (power, link, cash out,
  upgrades).
- **TYPE = the depth path:** the subterminal accepts commands for the same functions **plus**
  advanced/flavor functions — hacker fantasy, power-user speed, a future skill-expression surface
  (advanced hacker actions may be **type-only by design**, gameplay-gated).

**Rule:** no REQUIRED core function may be type-only; no advanced function is barred from also having
a click path **unless gameplay rules it** (that gating is an economy/doctrine call, not a UI call).

## §3 TUI VOCABULARY (from the reference set)

- **Pixel-block wordmark** (two-tone glyph style) = the HASHD mark solution; also the theme/cosmetic
  surface (§5).
- **Splash/boot screen:** centered wordmark + version + three-column `/command · description ·
  keybind` table + prompt line. Slots into the existing full-window PIN/boot overlay.
- **Persistent TOP status bar:** title left, live stats right (฿ balance, hub link, hashrate — Law 17
  grammar).
- **Persistent BOTTOM bar:** state left, keybind hints right; **MODE BADGES** as inverted blocks
  (`LOCKED` / `BOOTING` / `MINING` / `LINKED n/3`).
- **Bordered panels** with rule-lines; split footer cells; feature-list bullet grammar
  (**BOLD UPPERCASE TERM:** plain description) for help and getting-started panes.
- **Monospace throughout**; single accent + monochrome (HASHD-amber default).

## §4 s&box FEASIBILITY NOTES (for the implementing seat)

All of §3 is Razor/SCSS-achievable: monospace font from the engine set (**RobotoMono ships with the
engine — confirm at build**; Poppins/Inter precedent applies), borders/rules are styled panels,
"keybinds" are button affordances (real keybinds optional via input handling). **Known SCSS
constraints apply** (no `@media`, comment-parser hazards). The subterminal input = a text-entry panel
+ command dispatcher — **scope its command set small at v1** (the click path already covers core
functions).

## §5 COSMETICS LANE (Donor Law + Cosmetic Firewall)

Terminal themes = wordmark/accent/status-block palette swaps. **Structure immutable; Law 17 signs are
NEVER re-colored by a theme** (Law 17 beats cosmetics — the one hard constraint). Default HASHD-amber;
themed variants (e.g. RGB gradient wordmark) = donor/store items, **QoL-only per Donor Law**. Enters
the Cosmetic Firewall as the terminal's single cosmetic surface.

## §6 SEQUENCE

This doctrine feeds work **after** the current ladder (trial close → #105/#106 merges →
develop→main → Bitcoin Ops plan implementation). The terminal slice inherits: this doctrine +
existing HASHD branding + PIN/boot overlay + Currency Standard. Study work (Green/Red "food"): Green
backcheck of this doctrine against in-tree UI canon for contradictions; Red feasibility spot-check of
§4 claims at build time. **Neither blocks the merges.**

## PRIORITY (from `DUAL_CURRENCY_IDENTITY_RULING_2026-07-15.md` §3)

(1) Player Hub → (2) Bitcoin Hub mapping → (3) **this** HASHD terminal TUI. Menus before terminals.

FROM: Red
