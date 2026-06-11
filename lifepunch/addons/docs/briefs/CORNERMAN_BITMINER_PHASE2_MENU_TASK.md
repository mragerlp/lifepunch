# Cornerman task — Bitminer Phase 2 tabbed menu (draft only)

**Lane:** Tier-3 UI prep · **Red ships** after Opus review on VENGEANCE  
**Issued:** 2026-06-11  
**Prerequisite:** Phase 1 CLI done (`BitminerTerminal.razor` in repo)

---

## Goal

Draft the **tabbed menu** shell for `menu` command — wireframes + SCSS tokens — without editing ship-tree `.razor` on Green unless Red explicitly merges your patch.

**You do NOT:** change economy RPCs, dual-build seams, or `BitminerEntity.cs`.

---

## Read first

| Doc | Section |
|-----|---------|
| `BITMINER_UX_SPEC.md` | §3b tabs, §3a boot |
| `StaffMenu.razor` + `.scss` | Tab bar, confirm modals, HUD mount pattern |
| `BitminerTerminal.razor` | Phase 1 CLI — `menu` stub today |
| `branding/cornerman/THEME.md` | Palette tokens |

---

## Deliverables

### 1. Wireframe markdown

Create `lifepunch/addons/docs/briefs/BITMINER_PHASE2_WIREFRAME.md`:

- ASCII or bullet layout per tab: **Dashboard**, **Wallet**, **Upgrades**, **Terminal**, **About**
- Each tab: primary actions → existing RPC names (`SetMiningState`, `RequestSellBitcoin`, `RequestUpgrade`)
- Confirm modal copy for **SELL ALL** and **Purchase upgrade**
- Boot sequence → auto-switch to Dashboard (or stay CLI if `Terminal` tab preferred)

### 2. SCSS token draft

Create `lifepunch/addons/docs/briefs/BITMINER_PHASE2_TOKENS.scss` (reference only — not compiled):

```scss
// Cornerman tokens — Red copies into BitminerTerminal.razor.scss
$bg: #0a0f0a;
$border: #1a3a2a;
$accent: #00FF7F;
// ... tab bar, card, button, error states
```

Match StaffMenu density; keep retro terminal feel.

### 3. `menu` command behavior spec

One paragraph for Red: how `_viewMode` toggles CLI ↔ tabs (mirror `StaffMenu` tab index pattern).

### 4. RAG outbox

Copy summary to `C:\lifepunch\cornerman\outbox\BITMINER_PHASE2_MENU.md`.

---

## Optional (if time)

- Distill `BITMINER_UX_SPEC.md` + `BITMINER_BUILD.md` into one-page `BITMINER_QUICKREF.md` for RAG.

---

## Commit (local)

```text
docs(bitcoinmining): Phase 2 tabbed menu wireframe + scss token draft
```
