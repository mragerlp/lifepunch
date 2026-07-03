# Addon quarantine register (June 2026)

**Phase:** `ophion-rebuild-2026-06`  
**Source of truth:** `config/portfolio.json`  
**Production gate:** `docs/ACTIVE_WORKSTREAM.md` — single active lane until Bitcoin sign-off.

**Quick index:** `../_QUARANTINE_INDEX.md` (repo root of addons) — active vs frozen at a glance.

Bloodwave reset: **only** `adminmenu` (lifepunch.ulx) + `bitcoinmining` (Ophion) are active.
Everything else is frozen — not deleted, not extended, **not used as a ship template**.

---

## Quarantine law (agents)

Quarantined trees exist for **historical context and product ideas only**.

| Allowed | Forbidden |
|---------|-----------|
| Read to understand prior UX, economy, or mesh decisions | Edit quarantined source/assets without owner **promotion** |
| Reference in briefs, `TECH_DEBT.md`, or comparison tables | Import/copy quarantined types, prefabs, panels, or SCSS into **active** addons |
| Note "we tried X in hackerjob" when ideating a new lane | Treat quarantined code as a paste-in **reference implementation** |
| | Include quarantined idents in `publishReadyAddons` or `prepare-publish` |
| | Add quarantined paths to DXRP-only sync unless owner directs |

**Active addons are the only compile + ship path.** Quarantine ≠ `reference/` (third-party study) —
both are non-ship, but quarantine is **our** frozen WIP, not external IP.

---

## Active (build here)

| ident | s&box | Why active |
|-------|-------|------------|
| `adminmenu` | `lifepunch.ulx` | Shipped-quality staff menu — leave alone |
| `bitcoinmining` | `lifepunch.bitcoinmining` | P0: Ophion hub visual + player UX from brief |

---

## Quarantined (concepts / context only — do not ship from here)

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

**DXRP install:** quarantined idents are **not** kept under `lifepunch._quarantine/` in the game folder — that caused console spam. Run `Set-DxrpLifepunchBitcoinOnly.ps1` (or `Start-SboxDxrpEditor.ps1 -PreflightFix -BitcoinOnly`) to purge stale trees; sources stay in the monorepo only.

---

## Promote out of quarantine

1. Owner names ident in Cursor chat  
2. Update `portfolio.json` — move ident to `activeAddons`  
3. Remove matching `<Compile Remove>` from `addons.csproj`  
4. ChatGPT Step 1 brief for that product (if new UX)

---

## Foundation doc

Ophion player UX: `docs/briefs/BITCOIN_OPHION_CURSOR_BRIEF.md`
