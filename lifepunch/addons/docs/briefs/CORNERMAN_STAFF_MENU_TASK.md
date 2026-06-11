# Cornerman task — lifepunch.ulx staff menu fix

**Lane:** Cornerman (WarmCoder for SCSS · distill for Hit Shapes notes) → **outbox** → Red integrates on VENGEANCE  
**Issued:** 2026-06-11 · **Priority:** P0 (owner blocked on menu quality / log noise)

---

## Goal

Fix the **LIFEPUNCH staff menu** (`adminmenu` addon, s&box ident `lifepunch.ulx`) so it is stable in DXRP play: no s&box UI errors on open, visuals stay ulx-v2, clicks still work via HUD mount.

**Red does NOT want another bitcoin mining-style log loop.** Same root cause class as `HashdTerminal.razor.scss` (CSS gradients rejected by s&box UI).

---

## P0a — Material Icons font (fixed on Red 2026-06-11)

**Root cause:** `.staffmenu { font-family: Poppins }` cascaded onto every `<i class="material-icons">`,
so ligatures (`shield`, `gavel`, `terminal`, …) rendered as **plain text**, not glyphs.

**Fix:** top-level `.material-icons { font-family: Material Icons; text-transform: none; }` in
`StaffMenu.razor.scss` (same pattern as `BuildMenu.razor.scss` + engine `base.scss`).

Red verify: open `staffmenu` in play — tab/action icons are glyphs, not words.

---

## P0 — Remove CSS gradients (ship-blocking)

**File:** `lifepunch/addons/Code/Addons/lifepunch/adminmenu/StaffMenu.razor.scss`

**Problem:** Seven `background-image: linear-gradient(...)` rules (ulx-v2 polish, commit `63b87e8`). s&box UI panels reject gradients → console spam / broken paint (proven on hashd terminal).

**Fix pattern (copy from bitcoinmining):**

```scss
// s&box UI does not support CSS gradients on background-image (log spam on open).
background-color: <solid>;
// optional: box-shadow for depth instead of gradient faux-glow
```

**Locations to patch (grep `linear-gradient` in file):**

| Selector / area | Replace with |
|-----------------|--------------|
| `.window` | solid `$bg` or `#1a1e28` + existing `box-shadow` |
| `.header-accent` | solid `$dxrp-cyan` or `$accent` (2px bar — already height 2px) |
| `.header` | solid `$bg-raised` |
| `.player-row.selected` (or similar) | solid `rgba(79, 140, 255, 0.08)` |
| action tiles / glow states | solid rgba + `box-shadow` |

**Do NOT remove** `ulx-v2` class from `StaffMenu.razor` — keep branding; only swap unsupported CSS.

**Deliverable (Green outbox):**

- `outbox/STAFF_MENU_SCSS_FIX.scss` — full patched file **or** a diff Red can apply
- One-line note: gradient count before → after (must be **0**)

**Red verify:**

1. `Sync-LifePunchAddonsToDxrp.ps1 -Addon adminmenu` (or full sync)
2. Play from `scenes/game.scene` → `staffmenu` or `adminmenu`
3. Log filter `gradient` → **empty** while menu open
4. Clicks: select player, run Kick/Freeze, close — still works (`StaffMenuHost` HUD mount unchanged)

---

## P1 — Hit Shapes study (distill only — no third-party ship)

**Reference:** [xaz/hit_shapes](https://sbox.game/xaz/hit_shapes) — radial moderation wheel.

**Output:** `outbox/STAFF_MENU_HIT_SHAPES_NOTES.txt`

- What UX to borrow: radial quick-actions on **selected player profile banner** (Kick / Mute / Goto / Spectate)
- What NOT to ship: Hit Shapes package dependency, xaz assets, or non-LIFEPUNCH code
- How it maps to existing `StaffMenuActions` categories (Moderation vs Commands)

Red / Opus integrates later — **not** in this Cornerman commit.

---

## P2 — STAFF-09 namespace (optional if time)

**File:** `StaffMenuTestBots.cs` — move `namespace Dxura.RP.Game` → `LifePunch.DXRP.Addons.StaffMenu` + usings.

Cosmetic validator fix; low risk. Red can land without Opus.

---

## Files to read (in order)

1. `StaffMenu.razor` + `StaffMenu.razor.scss` — UI under fix
2. `StaffMenuHost.cs` — mount/click pattern (**do not change** unless Red asks)
3. `StaffMenuActions.cs` — action catalog
4. `lifepunch/addons/docs/TECH_DEBT.md` — STAFF-01…09
5. `HashdTerminal.razor.scss` — gradient fix precedent (lines 47–49 comment)
6. `gamemode/config/addon-revisions.json` — adminmenu Rev 1 click-fix history

---

## Model routing

| Step | Model |
|------|-------|
| Hit Shapes notes | **WarmDistill** (`Send-CornermanWorkflow.ps1 -Action WarmDistill`) |
| SCSS gradient removal | **WarmCoder** (`-Action WarmCoder`) |
| C# / host changes | **Red only** |

---

## Commit / handoff

**Green:** outbox files only (no git push from Green unless owner revives Cursor there).  
**Red ping line:** `OK cornerman staff-menu scss @<sha>` or paste outbox paths.

**Suggested Red commit message:**

```text
fix(ulx): remove unsupported CSS gradients from staff menu SCSS
```

---

## Out of scope

- Audit API wiring (STAFF-07)
- Sanction history pane (STAFF-06)
- Portal publish / `_c` compile (Red runs `prepare-publish.ps1 -Addon adminmenu`)
