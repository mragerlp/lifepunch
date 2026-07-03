# LIFEPUNCH™ — Asset Classification Law

**June 2026** — Foundational law for Fab intake, `_modeldoc` staging, and future s&box packages.

These assets are **not** generic props. Every mesh belongs to a **specific gameplay package** and must stay grouped by package identity.

**Do not merge packages** even when assets look similar (shared Filenames, shared Fab authors, or shared mesh families).

---

## Canonical paths

| Layer | Path |
|-------|------|
| Owner drop (raw zips + extracted) | `%USERPROFILE%\OneDrive\Desktop\lifepunchaddons` |
| Repo staging | `lifepunchaddons/Assets/addons/lifepunch/lpbitcoin/bitcoinhub/` (etc.) |
| Per-slot audit | `{lpPackage}/{entitySlot}/audit/manifest.json` |
| Per-package audit | `{lpPackage}/audit/manifest.json` · `issues.md` · `duplicate_report.md` |
| Layout law | `PACKAGE_STAGING_LAYOUT.md` · `config/package-staging.json` |
| Classification reports | `addons/docs/ASSET_CLASSIFICATION_REPORT_*.md` |
| Fab entity map | `FAB_OWNER_MANIFEST_2026.md` |
| Ship slugs | `config/packages.json` · `PACKAGE_NAMING_STANDARD.md` |

**Regenerate reports:** `powershell -File lifepunchaddons\scripts\Invoke-LifepunchAssetClassificationAudit.ps1`

---

## Package map (8 packages — repo truth)

| Folder | Future packageSlug (when shipped) | Slots | Priority |
|--------|-----------------------------------|-------|----------|
| `lpbitcoin` | `lifepunchbitcoin` | `bitcoinhub`, `hashdterminal`, `gpurack`, `advancedgpurack` | **P0** |
| `lphacker` | `lifepunchhacker` | `hackerhub`, `hackerterminal`, `advancedhackerhub`, `advancedhackerterminal` | P1 |
| `lppolice` | *(police lane)* | `policehackerhub`, `policehackerterminal` | P1 |
| `lpgovernment` | *(gov datacenter lane)* | `governmenthub`, `governmentterminal` | P1 |
| `lpblackmarket` | *(black market dealer)* | `blackmarkethub`, `blackmarketterminal`, `blackmarketregister`, `blackmarketlocker` | P2 |
| `lpbanker` | `lifepunchbanker` | `bankerhub`, `bankerterminal`, `bankeratm` | P2 |
| `lpflashdrive` | *(defer gameplay — item economy)* | `usbflashdrive`, `electronicstable` | P3 |
| `lpweapons` | `lifepunchak47` / weapon rows | `ak47military`, `ar15military` | Parallel weapon pipeline |

**Correction vs generic ChatGPT draft:** Police HUB + Police Terminal live in **`lppolicehacker`**, not `lpgovernment`. Government HUB + Government Terminal live only in **`lpgovernment`**. Never fold police into gov folders.

**Correction vs three-entity bitcoin chain:** P0 core chain is **GPU Rack → HASHD Terminal → Bitcoin HUB**. **`advancedgpurack`** is a **fourth slot in the same package** (stacked / advanced tier from the same Crypto Farm Fab family) — not a separate package.

---

## Package law (by folder)

### `lpweapons`

| Slot | Display name |
|------|----------------|
| `ak47military` | AK-47 Military |
| `ar15military` | AR-15 Military |

**Purpose:** Criminal economy, weapon dealers, black market, future weapon progression.

**Build law:** `LIFEPUNCH_WEAPON_IMPLEMENTATION_LAW.md` — weapon **platform** (P0 attachments/collision
→ P1 bones/anims → P2 modularity). Not the digital-machine entity stack. Report: `WEAPON_PLATFORM_REPORT.md`.

**Audit:** Preserve all source meshes, texture variants, material variants. When multiple FBX exports exist, pick the cleanest game-ready FBX as `primary_mesh`; keep alternates under `game/source/fbx/_alt` or `_parts`. **Do not delete alternates.**

---

### `lpflashdrive`

| Slot | Display name |
|------|----------------|
| `usbflashdrive` | USB Flash Drive |
| `electronicstable` | Electronics Table |

**Gameplay:** Portable BTC storage; table = craft / upgrade / purchase station.

**Law:** USB pack contains **multiple color variants** — **do not remove**. Colors may become storage tiers, rarity, malware tiers, encryption tiers, or cosmetics. Future gameplay splits (`bitcoinusb`, `hackerusb`, …) reference this mesh family; they are **not** separate intake packages today.

---

### `lpbitcoinmining` (P0)

| Slot | Display name | Gameplay chain |
|------|----------------|----------------|
| `gpurack` | GPU Rack | Entry |
| `hashdterminal` | HASHD Terminal | Mid |
| `bitcoinhub` | Bitcoin HUB (admin capstone) | Capstone |
| `advancedgpurack` | Advanced GPU Rack (stacked) | Advanced tier — same Fab family as `gpurack` |

**Do not alter naming relationships** between slots and future entity slugs (`gpu-rack`, `bitcoin-terminal`, `bitcoin-miner`, `advanced-gpu-rack`).

**P0 audit depth:** scale consistency · material consistency · texture consistency · triangle counts (after ModelDoc compile).

**Active ModelDoc:** `bitcoinhub/bitcoin-hub.vmdl` ← `generic-pc-desktop.fbx` + `generic-pc-desktop_basecolor.png` (Sketchfab CC BY Bryan). Fab CPU GAMER (`cpu_gamer.fbx`) **retired** for hub — fan spin = child GO Phase 2.

---

### `lphacker`

| Tier | Hub | Terminal |
|------|-----|----------|
| Basic | `hackerhub` | `hackerterminal` |
| Advanced | `advancedhackerhub` | `advancedhackerterminal` |

**Law:** Basic and advanced are **separate progression tiers**. Do not merge folders or share a single vmdl across tiers.

---

### `lppolicehacker` + `lpgovernment`

| Package | Hub slot | Terminal slot |
|---------|----------|---------------|
| `lppolicehacker` | `policehackerhub` | `policehackerterminal` |
| `lpgovernment` | `governmenthub` | `governmentterminal` |

**Law:** Law-enforcement / government infrastructure. Must remain **visually distinct** from hacker assets. Police package is **not** a subdirectory of government.

---

### `lpblackmarket`

| Slot | Role |
|------|------|
| `blackmarkethub` | Underground hub (vault / infrastructure) |
| `blackmarketterminal` | BM ops terminal (CRT catalog UI — when wired) |
| `blackmarketregister` | **BTC checkout** — customer pays in Bitcoin; entity grants **spawnable items via DXRP market** (Gun Dealer shipments, gadgets, etc.) |
| `blackmarketlocker` | **Weapon storage / customization** — regular world prop (locker mesh); not payment or escrow |

**Law:** `blackmarketregister` is the **commerce surface** (BTC → market grant). `blackmarketlocker` is physical storage/loadout only — do not conflate with flash-drive escrow (that stays **banker ATM** + `lpflashdrive`).

Maintain package separation from banker and bitcoin packages.

**Owner drop (Jun 2026):** `UPLOAD READY ADDONS\lpblackmarket\blackmarketregister` (cash register mesh).

---

### `lpbanker`

| Slot | Repo name | Role |
|------|-----------|------|
| `bankerhub` | Banker HUB (safe/vault) | Legitimate finance hub |
| `bankerterminal` | Bank Terminal | Branch terminal |
| `bankeratm` | Banker ATM | Deposit / withdraw / invest |

**Law:** Visual consistency across all three banker slots. ATM reads flash drives — legitimate finance surface (`lpbanker` + `lpflashdrive`). Black market **BTC checkout** is `blackmarketregister`, not the locker.

---

## Package rules (every `{package}/` folder)

Each of the eight packages above receives:

| Artifact | Location |
|----------|----------|
| `manifest.json` | `{package}/audit/manifest.json` (aggregate) + per-slot `{slot}/audit/manifest.json` |
| `issues.md` | `{package}/issues.md` |
| `duplicate_report.md` | `{package}/duplicate_report.md` |

**ZIP archives (owner drop / handoff):** one zip per package — never combine.

```text
lpbitcoin.zip
lphacker.zip
lppolice.zip
lpgovernment.zip
lpblackmarket.zip
lpbanker.zip
lpflashdrive.zip
lpweapons.zip
```

Entity layout inside each package:

```text
lpbitcoin/bitcoinhub/assets/source|textures|models|entities|...
lpbitcoin/bitcoinhub/code/components|ui|docs/
```

---

## Naming rules

- Preserve **LIFEPUNCH folder prefixes:** `lpbitcoin`, `lphacker`, `lpblackmarket`, `lpbanker`, `lpflashdrive`, `lpweapons`, `lpgovernment`, `lppolice`.
- Do **not** rename packages to generic names (`props`, `cyber`, `terminals`, …).
- Public ship names lead with **LIFEPUNCH™** per trademark law; folder names stay lowercase `lp*` for intake.
- Slot folder names are **stable repo ids** — map to entity slugs in `FAB_OWNER_MANIFEST_2026.md`, not the other way around.

---

## Mesh export law

When multiple exports exist for one slot:

1. Set **`primary_mesh`** in slot `audit/manifest.json`.
2. Keep alternates in `game/source/` (`_alt`, `_parts`, `_reference_anim`, blend, obj).
3. **Never delete** alternates to “save space” in the repo staging tree.
4. Blockers (blend-only, obj-only) must appear in `{package}/issues.md` until FBX exists or ModelDoc accepts the format.

---

## Phase law (ModelDoc → ship)

1. ModelDoc + owner sign-off (scale, pivot, orientation) — `MODEL_FOUNDATION_PASS.md`
2. Promote vmdl → shipped addon paths + prefab hierarchy — `LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md`
3. Phase 1 collision (`BoxCollider` all axes — baseline; convex hulls = endgame per `TECH_DEBT.md` MACHINE-01)
4. P1–P4 machine stack (attachments, lights, fans, states) before full gameplay polish
5. Play test last (flatgrass — `CYBER_REFERENCE_LAWS.md` Law 5)

**Do not** sync entity code to DXRP until mesh sign-off for that slot.

---

## Related

- `LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md` — machines not props; P0–P4 checklist
- `LIFEPUNCH_WEAPON_IMPLEMENTATION_LAW.md` — weapon platform (lpweapons parallel track)
- `ASSET_CLASSIFICATION_REPORT_2026-06.md` — latest inventory + health scores
- `MODELDOC_STUDIO_LANE.md` — standalone editor (no DXRP gamemode)
- `DXRP_MODELDOC_GREENFIELD_LANE.md` — DXRP editor lane when gamemode context required
- `Normalize-LifepunchDesktopPackages.ps1` — builds `assets/` layout from Desktop drop
- `config/portfolio.json` — active vs quarantine vs publish-ready code packages
