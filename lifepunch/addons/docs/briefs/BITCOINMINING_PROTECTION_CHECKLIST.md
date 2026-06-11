# BITCOINMINING — IP protection checklist

**Lane:** Cornerman audit (docs) · **Red** fixes ship-tree findings  
**Scope:** `lifepunch/addons/Code/Addons/lifepunch/bitcoinmining/` + `Assets/.../bitcoinmining/`  
**Canon:** `addons/docs/BITCOINMINING_IP_DOCTRINE.md`  
**Last run:** 2026-06-11 (post IP doctrine scrub)

---

## G1 — Ship-tree identity grep

```powershell
rg -i "LIFEPUNCH|lifepunch\.co|HASHD RIG CONTROL" lifepunch/addons/Code/Addons/lifepunch/bitcoinmining --glob "*.{cs,razor,scss}"
rg -i "cloud\.facepunch|packages\.facepunch" lifepunch/addons/Assets/addons/lifepunch/bitcoinmining
Get-ChildItem lifepunch/addons/Assets/addons/lifepunch/bitcoinmining/sounds -Recurse -File -ErrorAction SilentlyContinue |
  Where-Object { $_.Extension -match '\.(wav|mp3|ogg|sound|vsnd)$' }
```

| Check | Result | Notes |
|-------|--------|-------|
| LIFEPUNCH source marks in ship code/UI | **PASS** | Identity grep hits present |
| No third-party cloud paths in ship assets | **PASS** | Zero cloud-package hits |
| `about` command LIFEPUNCH™ | **PASS** | `HashdTerminal.razor` |
| Boot line LIFEPUNCH | **PASS** | `>> hashd init — LIFEPUNCH mining daemon` |
| Title bar HASHD | **PASS** | `HASHD RIG CONTROL` |
| LCD amber `#f0a500` | **PASS** | `GpuRackEntity.cs` |
| `addons.json` leads LIFEPUNCH | **PASS** | `config/addons.json` |
| Portal listing draft | **PASS** | `reference/BITCOINMINING_PORTAL_LISTING.md` |
| `™` not `®` | **PASS** | Pending USPTO registration |
| No third-party bitcoin mining study tree | **PASS** | gitignored + absent from working tree |
| No audio binaries in ship tree (pre-intake) | **PASS** | `sounds/bitcoinminer/` — README only |
| Payout interval | **PASS** | `90s` — `BitcoinMiningAddon.MiningPayoutIntervalSeconds` |
| HASHD on hub (not rack CRT) | **PASS** | `BITCOINMINING_HUB_ARCH.md` |

---

## About tab / `about` command — required copy

Player-facing only (`HashdTerminal.razor`):

```text
HASHD RIG CONTROL — LIFEPUNCH™ Bitcoin Miner
Published by LIFEPUNCH — lifepunch.co
Proprietary software. All rights reserved.
Use on your server only. No redistribution or resale.
```

**Forbidden in About:** any third-party author, network, or addon credits.

---

## Visual brand alignment

| Token | Correct (bitcoinmining) | Wrong (drift) |
|-------|-------------------|---------------|
| UI accent | `#f0a500` amber | `#00FF7F` green (hacker) |
| Prompt | `rig0>` | `cornerman@rig:~$` |
| Program | `hashd` / `mine.exe` | `cornerman.exe` |
| Layout family | HASHD rig control (+ Phase 2 modules) | Hacker ops console |

Canonical: `TERMINAL_BRAND_MATRIX.md` · `BITCOINMINING_UX_SPEC.md` · `BITCOINMINING_PHASE2_TOKENS.scss`

---

## validate-headers.ps1 (bitcoinmining)

All `.cs` / `.razor` / `.scss` under `bitcoinmining/` must carry the LIFEPUNCH proprietary header.

---

## Pre-publish staging

- [ ] `prepare-publish.ps1 -Addon bitcoinmining` — no `BitcoinMiningDevSpawn` in upload
- [ ] No third-party cloud model paths in prefabs
- [ ] No third-party `.sound` / `.sound_c` in staging
- [ ] All entity `_c` + vmdl `_c` present for dedicated server
- [ ] Portal description uses `BITCOINMINING_IP_DOCTRINE.md` §2 blurb

---

## Protection verdict

| Area | Status |
|------|--------|
| Ship code UI/copy | **PROTECTED** |
| Ship assets (paths) | **PROTECTED** |
| Portal copy | **READY** (draft in `BITCOINMINING_PORTAL_LISTING.md`) |
| Genre overlap accusations | **Documented** — `BITCOINMINING_IP_DOCTRINE.md` §2–3 |
| Compile / sounds / hub `_c` | **IN PROGRESS** — not an IP issue; ship gate in `BITCOINMINING_PLAYTEST.md` |
