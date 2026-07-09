# Terminal Identity System — the faction terminal grammar

Status: CANON — filed 2026-07-09 from Bloodwave's delivered asset package.
Assets: `lifepunch/branding/terminals/` (role-keyed, staged same day).
Relations: `LIFEPUNCH_UI_STANDARD.md` (panel chrome) · `ECONOMY_DOCTRINE.md`
(Visible-Status Law) · `OPS_CRT_TERMINAL_THEMES` / DECISION-0010 (HASHD).

## The shared grammar (`lp-terminal-*` token family)

One component skin, hue-swapped — the same House-Pattern logic as the 5-tier
tracks, applied to visual identity:

- **Black substrate** — pure-black ground, everything else is emission.
- **Single-hue neon per faction** — one color carries the whole identity.
- **`>_` sigil** — the family mark.
- **Monospace terminal type** throughout.
- **CRT scanline texture** over the field.
- **Corner-bracket / frame chrome** — bracket weight and squareness vary by
  dialect (see below).
- **Boot vignette as lore** — a cmd-style banner (`Microsoft Windows [Version…]`
  + a faction copyright line + a faction prompt like `C:\CORNERMAN>`), and/or a
  `whoami` / `ls` exchange listing the faction's concerns.
- **Quote window** — a floating window (−□× chrome) carrying the faction's
  self-definition ("You don't hack systems. You …").
- **Wordmark + three-word motto lockup** anchored low.

## The four-slot pattern (THE structure)

Every faction ships exactly four slots — future factions **add a folder, never
a new structure**:

```text
lifepunch/branding/terminals/<faction>/
  appicon.png        — app/shortcut mark
  loadingscreen.png  — loading face
  screen.png         — idle/LCD face (sigil + boot-lore + lockup)
  terminal.png       — in-use console face (prompt + quote window + lockup)
lifepunch/branding/terminals/shared/
  universalicon.png  — the shared family mark (multi-hue)
```

All twelve faction slots are populated (2026-07-09 intake, no gaps);
`shared/universalicon.png` intaken from the CVL asset tree (three source
copies verified byte-identical).

## The dialects

Hex values are SAMPLED from the staged PNGs (200×200 grid, saturation- and
brightness-filtered, 8-step quantization, modal bucket) — not eyeballed.

| Dialect | Folder | Neon (modal sampled) | Tier meaning | Voice |
|---|---|---|---|---|
| **CORNERMAN** | `hacker/` | `#38F868` (screen `#10F838`; the `#39FF5E` family) | Standard Hacker tier | Helper: "not a hacker. just helpful." · "You don't hack systems. You corner problems." · `whoami`/`ls` → projects tools scripts · lockup CORNERMAN · BUILD. AUTOMATE. ELEVATE. Rounded, warm glow. |
| **VENGEANCE** | `advanced-hacker/` | `#F80000` (loading warms to `#F82010`) | ADVANCED Hacker tier | Escalated: "You don't hack systems. You execute objectives." · `(c) VENGEANCE Corp.` · lockup V E N G E A N C E · PLAN. EXECUTE. DESTROY. Squared technical frames, thinner strokes, spaced uppercase. |
| **LIFEPUNCH.NET** | `government/` | `#00B8F8` (range `#00A8F8`–`#08D0F8`) | FBI/government console | Institutional: "Unauthorized access is a threat to national security." · `(c) Lifepunch Government Systems.` · lockup LIFEPUNCH.NET — GOVERNMENT SERVERS · two motto lines: "Protecting. Managing. Governing." (terminal face) and "SECURE. CONTROL. SERVE." (screen/loading faces). Heaviest chrome by design: the institutional HUD layer (SECURE TERMINAL session header, clearance OMEGA/LEVEL 10, NODE: GOV-CORE-01, ENCRYPTION: AES-256, LOGGING/AUDIT/TRACE footer, circuit borders, federal crest) is unique to this dialect. |

**Green→red IS the visible tier ladder** — the Visible-Status Law applies to
terminal skins exactly as it does to rack lights: an ADVANCED (red) terminal
is proof of operating at the advanced tier, never of wealth.

## Relationships

- **HASHD** (bitcoin orange CRT, `$hashd-amber` family per DECISION-0010) is
  the **fourth dialect** of this same grammar — it predates this filing and
  stays as-is.
- **Future surfaces** (black-market, chemist tablet, banker vault console…)
  **choose or extend from this system, never invent parallel ones** — a new
  faction = a new folder + a new hue on the same grammar.
- **Loading screens and wallpapers are panelrendertarget content** for the
  physical console props when that lane opens (playbook: dicta.panelrendertarget,
  first-exercise still pending).

## Sanitization (law — every branding intake runs this sweep as step 1)

**RULE:** branding assets carry FICTIONAL identifiers only — no real
credentials, tokens, or keys; no real LAN IPs (`192.168.x.x`, `.229`, `.236`);
no real usernames beyond the faction names; no real filesystem paths.
Private-range set dressing (`10.0.0.1`) and lore hostnames are fine.

**SWEEP DISCIPLINE:** review every staged asset's visible text against the
rule; **report hits rather than silently editing** — the assets are
Bloodwave's to amend.

**2026-07-09 sweep (all 13 staged assets reviewed): CLEAN.** No credentials,
tokens, or keys anywhere; the only IP in the set is `IP: 10.0.0.1` on the
government loading screen (allowed set dressing); all account strings are
faction identities (`cornerman@cornerman`, `vengeance@vengeance`,
`lifepunch@lifepunch.net`, `whoami → government`); all paths are lore paths
(`C:\CORNERMAN>`, `C:\VENGEANCE>`, `C:\GOVERNMENT>`, `~`).

**RULING ON RECORD:** the boot banners intentionally mirror the real cmd
greeting (`Microsoft Windows [Version 10.0.26200.8655]` — the cornerman face
mirrors Green's actual SSH banner). Bloodwave-approved as lore: banner text is
a non-secret greeting and an OS build number is public information. Noted so
future audits don't re-litigate it.

**Cosmetic flag (not a rule hit, owner to amend or bless):** the shared
`universalicon.png` vengeance pane's final prompt reads `vengeance@vegerance`
— "vegerance" typo; every other pane in the set is spelled correctly.

## Publish-exclusion (proposal — owner gates)

`lifepunch/branding/` sits in the ops tree, **outside `lifepunchaddons/`** —
it never ships through the addon publish lane by default, and that stays the
rule: **the branding tree is the source of truth and is non-shipping.** When a
surface consumes one of these assets in-game (e.g. a panelrendertarget console
face), that asset is **promoted by copy** into the owning addon's asset tree
(`lifepunchaddons/Assets/addons/lifepunch/<addon>/…`) at build time, and the
promoted copy ships with the addon like any other game asset. Proposal:
in-game-consumed assets ARE shippable via promotion; the branding tree itself
is never packaged. Owner gate on this ruling.
