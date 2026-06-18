# LIFEPUNCH Asset Classification Report

**Generated:** 2026-06-17 00:38 | **Source:** Assets/addons/lifepunch/lp*

> **Superseded (hub only, June 2026):** `bitcoinhub` no longer uses `cpu_gamer.fbx`. Active hub =
> `generic-pc-desktop.fbx` → `bitcoin-hub.vmdl`. See `ASSET_CLASSIFICATION_LAW.md` and
> `bitcoinhub/assets/models/MODEL_BUILD.md`. Regenerate this report after the next audit run.

Canonical law: ASSET_CLASSIFICATION_LAW.md | Regenerate: Invoke-LifepunchAssetClassificationAudit.ps1

---

## 1. Asset inventory

| Package | Slot | Primary mesh | FBX | OBJ | Blend | Tex | Size MB |
|---------|------|--------------|-----|-----|-------|-----|---------|
| lpbanker | bankeratm | assets/source/fbx/SM_ATM_Modern_01.fbx | 1 | 0 | 1 | 14 | 6.69 |
| lpbanker | bankerhub | assets/source/fbx/Safe_all.fbx | 1 | 0 | 1 | 20 | 946.2 |
| lpbanker | bankerterminal | assets/source/fbx/Computer.fbx | 1 | 0 | 1 | 22 | 1105.76 |
| lpbitcoin | advancedgpurack | assets/source/fbx/GPU_Farm_Stacked_Anim.fbx | 1 | 0 | 1 | 32 | 33.41 |
| lpbitcoin | bitcoinhub | assets/source/fbx/cpu_gamer.fbx | 1 | 0 | 1 | 0 | 145.34 |
| lpbitcoin | gpurack | assets/source/obj/GPU_Farm_Static.obj | 0 | 1 | 1 | 32 | 34.61 |
| lpbitcoin | hashdterminal | assets/source/fbx/PC.fbx | 1 | 0 | 1 | 22 | 585.64 |
| lpblackmarket | blackmarkethub | assets/source/fbx/Safe_Vault_TRIO.fbx | 1 | 0 | 1 | 12 | 31.41 |
| lpblackmarket | blackmarketlocker | assets/source/fbx/SF_Locker_19.fbx | 1 | 0 | 0 | 14 | 10.23 |
| lpblackmarket | blackmarketterminal | assets/source/blend/CRT COMPUTER.blend | 0 | 0 | 1 | 6 | 83.92 |
| lpflashdrive | electronicstable | assets/source/fbx/Soldering_Kit.fbx | 1 | 0 | 0 | 13 | 27.71 |
| lpflashdrive | usbflashdrive | assets/source/fbx/USB_flash.fbx | 1 | 0 | 1 | 7 | 353.33 |
| lpgovernment | governmenthub | assets/source/fbx/Server_pillar.fbx | 1 | 0 | 0 | 6 | 9.31 |
| lpgovernment | governmentterminal | assets/source/fbx/sm_computer_console_01.fbx | 1 | 0 | 0 | 5 | 208.81 |
| lphacker | advancedhackerhub | assets/source/fbx/Servers.fbx | 1 | 0 | 0 | 7 | 6.15 |
| lphacker | advancedhackerterminal | assets/source/fbx/PC_all_in_one.fbx | 1 | 0 | 1 | 32 | 1253.58 |
| lphacker | hackerhub | assets/source/fbx/Servers.fbx | 1 | 0 | 0 | 13 | 29.66 |
| lphacker | hackerterminal | assets/source/fbx/Computer.fbx | 1 | 0 | 1 | 32 | 889.29 |
| lppolice | policehackerhub | assets/source/obj/Sci_fi_server_rack.obj | 0 | 1 | 0 | 5 | 12.78 |
| lppolice | policehackerterminal | assets/source/fbx/Terminal_TH.fbx | 1 | 0 | 1 | 29 | 1022.13 |
| lpweapons | ak47military | assets/source/fbx/AK47.fbx | 1 | 0 | 1 | 6 | 24.29 |
| lpweapons | ar15military | assets/source/fbx/ar_15.fbx | 1 | 0 | 0 | 12 | 36.28 |

**Total staged size (all slots):** 6856.53 MB across 22 entity slots in 8 packages.

---

## 2. Duplicate inventory (primary mesh filename)

| Filename | Count | Locations | Merge? |
|----------|-------|-----------|--------|
| Computer.fbx | 2 | lphacker/hackerterminal; lpbanker/bankerterminal | No - separate packages |
| Servers.fbx | 2 | lphacker/advancedhackerhub; lphacker/hackerhub | No - same package tiers/slots |

---

## 3. Missing / thin texture inventory

| Package | Slot | Notes |
|---------|------|-------|

**Expected zero-texture slot:** lpbitcoin/bitcoinhub (CPU GAMER solid vertex colors - LifePunch vmats in ModelDoc).

---

## 4. Recommended game-ready exports

| Package | Slot | Primary | Status |
|---------|------|---------|--------|
| lpbitcoin | advancedgpurack | assets/source/fbx/GPU_Farm_Stacked_Anim.fbx | FBX ready |
| lpbitcoin | bitcoinhub | assets/source/fbx/cpu_gamer.fbx | FBX ready |
| lpbitcoin | gpurack | assets/source/obj/GPU_Farm_Static.obj | OBJ - import or re-export FBX |
| lpbitcoin | hashdterminal | assets/source/fbx/PC.fbx | FBX ready |
| lphacker | advancedhackerhub | assets/source/fbx/Servers.fbx | FBX ready |
| lphacker | advancedhackerterminal | assets/source/fbx/PC_all_in_one.fbx | FBX ready |
| lphacker | hackerhub | assets/source/fbx/Servers.fbx | FBX ready |
| lphacker | hackerterminal | assets/source/fbx/Computer.fbx | FBX ready |
| lppolice | policehackerhub | assets/source/obj/Sci_fi_server_rack.obj | OBJ - import or re-export FBX |
| lppolice | policehackerterminal | assets/source/fbx/Terminal_TH.fbx | FBX ready |
| lpgovernment | governmenthub | assets/source/fbx/Server_pillar.fbx | FBX ready |
| lpgovernment | governmentterminal | assets/source/fbx/sm_computer_console_01.fbx | FBX ready |
| lpblackmarket | blackmarkethub | assets/source/fbx/Safe_Vault_TRIO.fbx | FBX ready |
| lpblackmarket | blackmarketlocker | assets/source/fbx/SF_Locker_19.fbx | FBX ready |
| lpblackmarket | blackmarketterminal | assets/source/blend/CRT COMPUTER.blend | Blend-only - export FBX first |
| lpbanker | bankeratm | assets/source/fbx/SM_ATM_Modern_01.fbx | FBX ready |
| lpbanker | bankerhub | assets/source/fbx/Safe_all.fbx | FBX ready |
| lpbanker | bankerterminal | assets/source/fbx/Computer.fbx | FBX ready |
| lpflashdrive | electronicstable | assets/source/fbx/Soldering_Kit.fbx | FBX ready |
| lpflashdrive | usbflashdrive | assets/source/fbx/USB_flash.fbx | FBX ready |
| lpweapons | ak47military | assets/source/fbx/AK47.fbx | FBX ready |
| lpweapons | ar15military | assets/source/fbx/ar_15.fbx | FBX ready |

**P0 order:** gpurack (resolve static body) -> hashdterminal -> bitcoinhub (`bitcoin-hub.vmdl` in progress; Fab cpu-gamer retired) -> advancedgpurack.

---

## 5. Estimated optimization opportunities

- **lphacker/advancedhackerterminal** (1253.58 MB): large extracted/ + 4K dupes on Desktop; game/textures is subset only - do not delete owner drop
- **lpbanker/bankerterminal** (1105.76 MB): large extracted/ + 4K dupes on Desktop; game/textures is subset only - do not delete owner drop
- **lppolice/policehackerterminal** (1022.13 MB): large extracted/ + 4K dupes on Desktop; game/textures is subset only - do not delete owner drop
- **lpbanker/bankerhub** (946.2 MB): large extracted/ + 4K dupes on Desktop; game/textures is subset only - do not delete owner drop
- **lphacker/hackerterminal** (889.29 MB): large extracted/ + 4K dupes on Desktop; game/textures is subset only - do not delete owner drop
- **lpbitcoin/hashdterminal** (585.64 MB): large extracted/ + 4K dupes on Desktop; game/textures is subset only - do not delete owner drop
- **lpflashdrive/usbflashdrive** (353.33 MB): large extracted/ + 4K dupes on Desktop; game/textures is subset only - do not delete owner drop
- **lpgovernment/governmentterminal** (208.81 MB): large extracted/ + 4K dupes on Desktop; game/textures is subset only - do not delete owner drop
- **lpflashdrive/usbflashdrive**: preserve all color variant textures - optimize at ship (_c), not by deleting variants
- **lpbitcoin/gpurack + advancedgpurack**: shared Crypto Farm textures by design - dedupe in ModelDoc vmats only

---

## 6. Storage savings (estimate only)

- **Staged total today:** 6856.53 MB under lp* staging (includes blend + extracted mirrors on Desktop, not all in git).
- **Rough savings if 4K/extracted kept on Desktop only (not duplicated into git):** ~4932 MB for banker + terminal slots - do not delete owner drop; stop copying 4K into repo when 2K suffices.
- **Ship-time savings:** compile to _c, strip unused LODs after ModelDoc audit - separate pass.

---

## 7. Package health scores

| Package | Priority | Slots | Size MB | Health |
|---------|----------|-------|---------|--------|
| lpbitcoin | P0 | 4 | 799 | 85/100 |
| lphacker | P1 | 4 | 2178.68 | 100/100 |
| lppolice | P1 | 2 | 1034.91 | 85/100 |
| lpgovernment | P1 | 2 | 218.12 | 100/100 |
| lpblackmarket | P2 | 3 | 125.56 | 72/100 |
| lpbanker | P2 | 3 | 2058.65 | 100/100 |
| lpflashdrive | P3 | 2 | 381.04 | 100/100 |
| lpweapons | parallel | 2 | 60.57 | 100/100 |

---

## Objective

Protect source assets while producing clean integration-ready packages for future s&box implementation. Never merge packages - filename similarity is expected across Fab CRT/server/safe families.

