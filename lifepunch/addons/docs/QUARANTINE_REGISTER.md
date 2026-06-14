# Addon quarantine register (June 2026)

**Phase:** `ophion-rebuild-2026-06`  
**Source of truth:** `config/portfolio.json`

Bloodwave reset: **only** `adminmenu` (lifepunch.ulx) + `bitcoinmining` (Ophion) are active.
Everything else is frozen — not deleted, not extended.

---

## Active (build here)

| ident | s&box | Why active |
|-------|-------|------------|
| `adminmenu` | `lifepunch.ulx` | Shipped-quality staff menu — leave alone |
| `bitcoinmining` | `lifepunch.bitcoinmining` | P0: Ophion hub visual + player UX from brief |

---

## Quarantined (reference only)

| ident | Restore when |
|-------|----------------|
| `ak47` | Weapon pipeline after Ophion portal-ready |
| `hackerjob` | Separate job lane; terminal mesh overlap with bitcoin |
| `governmentdatacenter` | After bitcoin economy stable |
| `advanceddrugprocessing` | Opus drug economy sign-off |
| `visiblepocket` | Pocket HUD lane promoted |
| `deagle` / `mp9` / `ssg08` / `xm1014` | Weapon queue |
| `uraniumspecialist` | Sci-fi job intake |
| `additionaldroplocations` | Map fitting on Vengeance |
| `doublebarrelshotgun` | Asset foundation |
| `bankerjob` | New brief + promotion |

**Code:** quarantined folders excluded from `Code/addons.csproj` compile (faster editor, less cross-talk).  
**Assets:** stay on disk; publish scripts should target active idents only.

---

## Promote out of quarantine

1. Owner names ident in Cursor chat  
2. Update `portfolio.json` — move ident to `activeAddons`  
3. Remove matching `<Compile Remove>` from `addons.csproj`  
4. ChatGPT Step 1 brief for that product (if new UX)

---

## Foundation doc

Ophion player UX: `docs/briefs/BITCOIN_OPHION_CURSOR_BRIEF.md`
