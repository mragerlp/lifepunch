# CORNERMAN — Bitcoin Visual Doctrine + Upgrades Prep (2026-06-25)

**Priority:** High — prep for Architect paste + hands-on tonight  
**Lane:** lpbitcoin / Bitcoin only (Hacker/Gov strictly quarantined)  
**Eyes:** Covered — work from repo + provided text descriptions only. No play claims.  
**Duration target:** 8–12 hours medium/slow pace (distill, index, map, draft planning artifacts)  
**Output style:** Clear, grep-friendly, line-number heavy where useful. Produce navigation aids Red/Grok can use tonight.

## Context you must internalize first

- New canonical: `CYBER_VISUAL_IDENTITY_DOCTRINE.md` (just committed at ffa29df)
- Locked identities:
  - Cornerman = Hacker = Green
  - VENGEANCE = Advanced Hacker = Red
  - lifepunchnet = Gov/Police = Cyan
  - HASHD = Bitcoin = Amber (with limited gold/bronze/warm white donor cosmetics)
- Bitcoin surfaces (Hub + Terminal + Racks) **must not** use full green/red/cyan as base themes.
- Upcoming work: Universal Upgrades top tab + Hub / Terminal / Rack sub-tabs (ULX-style upper chips inside LpHashdPanel).
- Terminal is now a real surface (defense progression + appearance) — not "just CRT".
- Phase A is still gated on H1 owner sign-off. No full economy yet.

## Task Queue (do in rough order, take your time, be thorough)

### Task 1: Doctrine Reconciliation Map (2–3 hours)
Read the new doctrine + these files and produce a single clean artifact:

Files to cross-reference:
- `CYBER_VISUAL_IDENTITY_DOCTRINE.md`
- `TERMINAL_BRAND_MATRIX.md`
- `BITCOIN_UPGRADE_TAXONOMY.md`
- `lifepunch/docs/BITCOINMINING_DONOR_PERKS.md`
- `LIFEPUNCH_CYBER_ECOSYSTEM.md`
- `ACTIVE_WORKSTREAM.md` (Bitcoin section)
- `BITCOIN_SHIP_ROADMAP.md`

Deliverable: `CYBER_VISUAL_DOCTRINE_RECONCILE_2026-06-25.md` (or similar) containing:
- Every place the old "Terminal upgrades: None" language still exists (docs + code comments).
- Every file that will almost certainly need a small edit when the Architect paste lands.
- Clear "allowed vs forbidden" summary for HASHD donor cosmetics vs role colors.
- List of places where state colors (Warning/Error/Hacked) must override any cosmetic.

Include file paths + line numbers or section headers.

### Task 2: LpHashdPanel Architecture Map for Upgrades Tab (2–3 hours)
Focus on the current implementation so we can plan the new top tab + sub-chips fast tonight.

Main file: `lifepunchaddons/Code/Addons/lifepunch/lpbitcoin/bitcoinhub/code/ui/LpHashdPanel.razor`

Also relevant:
- `LpHashdPanel.razor.scss`
- Any partials or shared chrome files it uses
- `StaffMenu.razor` (for the ULX upper category chip pattern)

Produce:
- Detailed current tab structure (OpsTab enum, _tabs array, SelectTab / IsSidebarTabActive logic).
- Exact location of the existing "Upgrades" drill-in (OpenRackUpgrades / CloseRackUpgrades).
- Where the main tab bar is rendered.
- All places that would need to change to promote Upgrades to a first-class top tab with three sub-chips (Hub / Terminal / GPU Rack).
- Notes on current chrome (header pills, power/wallet/date, PIN gate) that must be preserved.
- Any SCSS gotchas (box-sizing was one recently).

Make it extremely grep-friendly with line numbers where possible.

### Task 3: Terminal Functions + CRT / LCD Pattern Prep (2–3 hours)
We have the three OneDrive asset packs (hackerassets, advancedhackerassets, governmentandpolicehackerassets).

Each has: `terminal/`, `screen/`, `loadingscreen/`, `appicon/`.

Current Bitcoin CRT: `LpBitcoinTerminalPanel.razor` + scss, and the hashdterminal model.

Hacker side reference: `HackerTerminal.razor` (even though quarantined, the UI pattern is useful).

Tasks:
- Map the four asset slots to likely in-game uses:
  - Main CRT full experience (boot + running ops console)
  - In-world LCD / monitor child plane (flavor text when idle or during states)
  - Loading / boot splash
  - Icon / small branding
- Extract the common visual grammar from the PNG descriptions we have (L-brackets, Windows header parody, floating quote box, big brand + tagline bottom-right, scanlines, etc.).
- List what would be needed for a shared "Ops CRT" theme system (amber for HASHD, with safe donor variants).
- Note any current implementation in Bitcoin Terminal that already does typed prompt + log + modules, so we don't reinvent.
- Identify places where defense indicators (from new Terminal upgrades) could visually surface on the CRT without breaking the amber identity.

Produce a planning artifact: something like `TERMINAL_CRT_LCD_PATTERN_PREP.md`.

### Task 4: Donor Cosmetics Guard Requirements (1–2 hours)
From `lifepunch/docs/BITCOINMINING_DONOR_PERKS.md` + the new doctrine.

- List every current or planned place where a skin/theme/RGB/sound choice could be made.
- Mark exactly where we will need:
  - Rank check (VIP/EVIP)
  - HASHD-safe color filter (no full green/red/cyan)
  - State color override (Warning/Error/Hacked always wins)
- Note any existing code paths (even stubs) for theme switching in HashdTerminal or LpHashdPanel.

### Task 5: Night's Hands-on Readiness Packet (1–2 hours)
Create or update a single "tonight packet" that Red/Grok can load fast when the Architect paste arrives.

Contents suggestions:
- One-page "Current Bitcoin canon snapshot" (post-doctrine).
- "Files almost certain to be edited in first Upgrades shell slice".
- "Questions the Architect paste must answer" (pulled from doctrine + taxonomy + roadmap).
- Quick links / grep strings for the most important components.
- Any open DECISIONs or HOLDs that interact with visual identity.

### Task 6: Optional Deep Index (as time allows)
Produce a small set of text indexes:
- All mentions of "Upgrades" in the lpbitcoin tree + key docs.
- All mentions of "Terminal" in context of upgrades or visuals.
- Component names and Razor file paths related to the hub panel and terminal panel.

## Rules for this run

- Bitcoin lane only. Do not generate code or briefs that would advance quarantined lanes.
- Eyes covered: base everything on repo text + the asset pack descriptions already in chat history. Do not claim to have "seen" editor or game visuals.
- Output should be immediately useful for fast hands-on editing tonight (navigation, lists, maps, questions).
- Medium/slow pace is fine — quality and thorough cross-referencing > speed.
- If something feels like it would require owner visual confirmation, note it as "needs screenshot" instead of guessing.

## Deliverables (in rough priority)

1. Doctrine reconciliation map + touch list
2. LpHashdPanel current architecture map (with upgrade insertion points)
3. Terminal CRT / LCD pattern prep document
4. Donor guard requirements list
5. "Tonight readiness packet"
6. Any supporting indexes

Put main deliverables in a clear place (e.g. under `docs/` or a dated handoff note) so they are easy to pull when the paste lands.

Start when ready. Take breaks. This is prep so the real work tonight can move fast once the structured Architect plan arrives.
