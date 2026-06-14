# s&box engine patches — LifePunch

> **Single source of truth** for engine updates that can break LifePunch addons, UI, or publish.
> Agents read this at session start and **append a new section** when the local engine is newer
> than `lastReviewedEngine` below.

| Field | Value |
|-------|-------|
| **Last reviewed engine** | `26.06.10` |
| **Last reviewed news** | [update-26-06-10](https://sbox.game/news/update-26-06-10) |
| **Last reviewed date** | 2026-06-14 |
| **Local install path** | `D:\Steam\steamapps\common\sbox` |

**Check command (run every session before UI/publish work):**

```powershell
powershell -File lifepunch\scripts\Get-SboxEnginePatchStatus.ps1
```

If status is **WARN** or **STALE**, fetch `https://sbox.game/news` (latest post), log impacts
here, run the regression checklist, then bump `lastReviewedEngine` in this file.

---

## Why this exists

The hashd hub menu shipped **title-only / empty body** (Jun 2026) from stacked issues that a
patch-aware gate would have caught:

1. **SCSS root** used uppercase `HashdTerminal { }` — s&box **silently skips** type selectors;
   entire stylesheet never applied (`SBOX_RAZOR_SCSS_RULES.md`).
2. **`BuildHash`** omitted PIN UI state — numpad never re-rendered after CTA click.
3. **USE vs preview** owner gate — `Owner == 0` sent players to PIN BLOCKED.

Engine patches can change compile, UI, networking, and publish without loud errors. Treat every
Steam update as a **regression event**, not “probably fine.”

---

## Agent workflow (law)

### Every session (before editing addons / UI / publish scripts)

1. `git pull --rebase` (monorepo).
2. `Get-SboxEnginePatchStatus.ps1` — if engine > last reviewed, read news + update this doc.
3. If touching `.razor.scss`: `Validate-SboxRazorScss.ps1` **before** playtest.

### After any engine bump (owner or agent)

1. Log the patch section below (link, date, LifePunch impact).
2. Run **Regression checklist** (full or scoped — see table).
3. **Stop play → Play** in editor after SCSS/UI edits (panel close is not enough).
4. Grep `sbox-dev.log`: `not valid with`, `error CS`, `Compile.*Failed`.
5. Smoke: one LifePunch menu panel (staff / hashd PIN / hacker rack) + one world USE path.

### When Bloodwave posts a news URL

Treat it as **immediate triage** — fetch, summarize LifePunch impact, update this doc same session.
Do not wait for a broken playtest to discover it.

---

## Regression checklist

| Area | What to verify | How |
|------|----------------|-----|
| **Razor SCSS** | Class root on `<root class="...">`, not `ComponentName { }` | `Validate-SboxRazorScss.ps1`; grep log `not valid with` |
| **PanelComponent** | `BuildHash` includes all UI state that changes without new props | Code review on `.razor` panels |
| **Menu USE path** | World USE matches dev-preview smoke (owner/PIN gates) | `lp_spawn_*` + USE, not only ConCmd preview |
| **Precompiled game** | Join/load still works; no CLL-only assumptions | Join DXRP dev server after bump |
| **Publish** | Portal upload still valid (`_c` assets, code-only addons) | `prepare-publish.ps1 -Addon <ident>` dry run |
| **Binary assets** | `_d` / model changes trigger rebuild | Touch vmat → confirm `_c` refresh |
| **Deprecated APIs** | No new `[Global]` / `[Frame]` usage | `rg '\[Global\]|\[Frame\]' lifepunch/` |

Known-good UI references: `StaffMenu.razor.scss` (`.lifepunchulx`), `HashdTerminal.razor.scss`
(`.hashd-terminal`). **Audit debt:** `HackerServerRackMenu.razor.scss` still uses type selector —
migrate to class root when that lane is touched.

---

## Patch log

### 26.06.10 — 2026-06-10

**News:** [sbox.game/news/update-26-06-10](https://sbox.game/news/update-26-06-10)

#### LifePunch impact

| Change | Risk | Action |
|--------|------|--------|
| **Precompiled DLLs** (backend compile; CLL removed from manifests) | **High** — join/publish path | Confirm DXRP dev join time; no reliance on client CLL compile; portal still ships addon `_c` |
| **`Game.IsPlaying` fix** on published load | Medium — spawn/menu timing | Re-smoke dev spawn + USE after engine bump |
| **Binary compile references** (`_d` triggers rebuild) | Medium — asset iteration | Re-pull `_c` after ModelDoc/vmat edits |
| **Case-insensitive mount paths** | Low | Keep consistent path casing in `addons.json` / assets |
| **Addons cannot increment Game Stats** | Low | None — we do not use this |
| **`[Global]` / `[Frame]` removed** | Low | None in LifePunch code (2026-06-14 grep) |
| **Screen 2D View** (+Y down, screen space) | Info | Aligns with UI flex layouts; no change unless building 2D games |
| **Indirect light / terrain / buoyancy** | Low for addons | Visual only |

#### Incidents tied to this era (not caused by patch, caught late)

- Hashd terminal empty body — SCSS class root + `BuildHash` (fixed `015b970`).
- Staff menu gradient SCSS — same failure class (`STAFF` brief / `SBOX_RAZOR_SCSS_RULES.md`).

---

## Related docs

| Doc | Role |
|-----|------|
| `SBOX_RAZOR_SCSS_RULES.md` | Forbidden SCSS + validate command |
| `SBOX_EDITOR_REFERENCE.md` | Editor/cloud access model |
| `bitcoinmining/docs/RUNTIME_PATTERN.md` | Hashd mount + dual-build |
| `TECH_DEBT.md` | Temporary baselines + open UI debt |
