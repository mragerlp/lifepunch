# Cornerman Task — LIFEPUNCH Addon Menu + Upgrade-Path Pattern (DISTILL / SPEC PREP)

**Route tag:** `GREEN DEEP REQUIRED` (Opus/Grok packet prep) · **Warm:** `WarmDistill`
**Hard rule:** Distill + spec docs ONLY. **Do NOT author C#, Razor, or SCSS.** No economy,
persistence, `[Sync(FromHost)]`, RPCs, purchase routing, or migration. Your output is Markdown
that **Opus** (framework build, `OPUS REQUIRED`) and **Grok** (repo audit / bounded planning,
`GROK REQUIRED`) will consume on VENGEANCE. Canon tag defs: `lifepunch/docs/OPUS_USAGE_LAW.md`.

---

## Why this task exists

The `lpbitcoin` Hub menu (`LpHashdPanel`) is now the **reference UI/menu/upgrade architecture**
for ALL future LIFEPUNCH addons. The owner wants every other surface — other Hub assets, the
**Terminal UI**, and a not-yet-built **Money Printer Technician** job — to be built on this same
structure, where each new addon is mostly a **color/style + content delta**, not a new UI system.

Your job is to read the now-canonical Hub UI and extract the **reusable pattern** into clean spec
docs so Opus can decide the shared-component architecture and bang out the other addons quickly.

---

## Step 0 — sync your clone first

```powershell
cd C:\Projects\lifepunch
git fetch
git pull --rebase   # must include commit f5fca7d (Servers nav + centered iOS knobs)
```

If your tree is behind AND dirty, STOP and note it in the outbox — do not discard local work.

---

## Source of truth to read (repo-relative, in your clone)

| Path | What to extract |
|------|-----------------|
| `lifepunch/addons/Code/Addons/lifepunch/lpbitcoin/bitcoinhub/code/ui/LpHashdPanel.razor` | The menu shell + navigation pattern: header, left tab rail, panel body, footer; Upgrades home grid → drill-in → back link; Servers home grid → drill-in → back link; PIN gate; `BuildHash`; `SelectTab`; dev-preview hooks. |
| `lifepunch/addons/Code/Addons/lifepunch/lpbitcoin/bitcoinhub/code/ui/LpHashdPanel.razor.scss` | The component kit: iOS switch (track + white knob geometry), home-box launcher, stat tiles, action buttons w/ in-button confirm animation, status pills, intro bar, brand header. |
| `lifepunch/addons/Code/Addons/lifepunch/lpbitcoin/bitcoinhub/code/components/LpBitcoinDevSpawn.cs` | The `lp_bitcoin_preview_*` ConCmd dev-preview pattern (one command per UI state). |
| `lifepunch/addons/docs/DECISION-0010-Universal-Upgrades-Home.md` | Universal Upgrades Home law: single purchase surface, HUB / TERMINAL / GPU RACK sub-tabs. |
| `lifepunch/addons/docs/BITCOIN_UPGRADE_TAXONOMY.md` | Surfaces → tracks → tiers taxonomy to generalize. |
| `lifepunch/addons/docs/BITCOIN_CONTROLLER_PATTERN.md` | Controller-vs-hardware split (Hub controls, Rack is hardware, Terminal is defense). |
| `lifepunch/addons/docs/CYBER_VISUAL_IDENTITY_DOCTRINE.md` | Where the per-addon color/style delta lives (HASHD amber, etc.). |

Do not modify any of these. Read-only distill.

---

## Outputs (write to your outbox, one file each)

Write to `C:\lifepunch\cornerman\outbox\` and also keep a copy for the patch-handoff. Each doc is
clean Markdown (SuggestionsFilter-style: short sections, tables, explicit headings).

1. **`LIFEPUNCH_ADDON_MENU_PATTERN.md`** — the canonical menu shell + navigation law.
   - Header anatomy (brand badge, power switch, wallet/date chips, alerts bell, close).
   - Left tab rail (icon list, active state).
   - Body + footer.
   - Navigation law: **tab → home grid (one box per item) → drill-in detail → light back link**;
     "one decision per screen." Note where Upgrades and Servers both already follow it.
   - `BuildHash` discipline: every private UI flag that changes markup must be in the hash.

2. **`LIFEPUNCH_UPGRADE_PATH_PATTERN.md`** — the universal upgrade-surface model, generalized.
   - Surfaces → tracks → tiers; Universal Upgrades Home with sub-tabs (per DECISION-0010).
   - A blank template table a new addon fills in (e.g. how Money Printer Technician would map its
     own surfaces: printer unit / ink-or-ops controller / output, purely as an example to fill in).

3. **`LIFEPUNCH_UI_COMPONENT_KIT.md`** — reusable component inventory with the exact intent of each
   (NOT the CSS values — describe the component + its states): iOS switch, home-box launcher, stat
   tiles, action button + in-button confirm/"Cleared" animation, status pills, PIN gate, transient-
   notice ticking, intro bar. Flag which are already generic vs hub-named.

4. **`LIFEPUNCH_ADDON_UI_REUSE_MAP.md`** — what is reusable vs hub-specific. A table: component →
   reusable as-is / rename-and-reuse / hub-only. Then a short "how a new addon adopts this" recipe
   (color/style delta + content, reuse shell + nav + kit). Call out the Terminal UI and the future
   Money Printer Technician job as the first two consumers.

5. **`LIFEPUNCH_UI_OPUS_GROK_PACKET.md`** — the handoff shell for VENGEANCE:
   - **For Opus (`OPUS REQUIRED`):** the open architecture decision — shared base component/class
     library vs per-addon copy; where the shell + kit should physically live; what must stay
     authority-side. List the exact decisions Opus must make. **Do not decide them yourself.**
   - **For Grok (`GROK REQUIRED`):** a repo-audit checklist — inventory every existing per-addon UI
     surface and note divergence from this pattern.
   - **Open questions for Bloodwave** at the bottom.

---

## Definition of done

- 5 Markdown docs in the outbox, internally consistent, no code.
- Each doc names its downstream consumer (Opus / Grok / Bloodwave).
- A one-paragraph outbox summary: what you distilled, what you were unsure about, and the single
  most important decision you are escalating to Opus.

Eyes-covered note: you have NOT seen the game or the editor. Describe the pattern from the repo
files only; do not claim any visual/playtest verification.
