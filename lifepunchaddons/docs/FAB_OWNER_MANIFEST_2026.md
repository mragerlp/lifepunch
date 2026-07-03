# Fab owner manifest — Jun 2026

**Source:** owner Fab library + listing URLs below.  
**Law:** mesh swap only — entity code, Razor UI, RPC, prefab components stay. Phase 1 collision on all axes before fans/anim.

**Fab session:** logged in at `fab.com/library` — all listed assets show **download** buttons in library (owned).

---

## Universal (defer gameplay)

| Fab listing | Fab title (library) | Intended use | Ship now? | Code / notes |
|-------------|----------------------|--------------|-----------|--------------|
| [cc82a206…](https://www.fab.com/listings/cc82a206-7d2e-4f1c-b574-e5f1a39e5e3c) | USB Flash Drive (SIUP 3D ART) | Pocket BTC / hacker raid flash drive | **Defer** | New item + economy — revisit after hub/terminal baseline |

---

## lpbitcoinmining (`bitcoinmining` addon)

| Fab listing | Fab title | Entity slug | Prefab | Code (unchanged) | Export notes |
|-------------|-----------|-------------|--------|------------------|--------------|
| [a5d5bb00…](https://www.fab.com/listings/a5d5bb00-076c-47c7-834b-ebf54d672972) | **CPU GAMER** (Omar Daniel) | `bitcoin-miner` | `entities/bitcoinminer/bitcoin-miner.prefab` | `LpBitcoinHubEntity`, `LpBitcoinHubVisuals` | FBX/GLB/OBJ/Blend; **solid colors, no textures**; blend has RGB + fan anim → use **Evo child-GO spin**, not rigged body |
| [7763e5c3…](https://www.fab.com/listings/7763e5c3-d93d-4aa8-a733-3d357acec1e0) | **Computer all-in-one** (SIUP 3D ART) | `bitcoin-terminal` | `entities/bitcoin-terminal/bitcoin-terminal.prefab` | `LpBitcoinTerminalEntity`, `HashdTerminal.razor` | CRT trio family — tune `lcd_screen` once |
| [9c8621e4…](https://www.fab.com/listings/9c8621e4-43c6-4d42-8859-bf2fb9f0f3ff) | **Crypto Farm / Mining Rig** (Michael Vest) | `gpu-rack` + `advanced-gpu-rack` | `entities/gpurack/`, `entities/advancedgpurack/` | `LpBitcoinRackEntity`, `LpBitcoinRackVisuals` | **Same asset family already in repo** — refresh export + Phase 1 collision; Evo fan child GOs |

---

## lphacker (`hackerjob` addon)

| Fab listing | Fab title (library) | Entity slug | Prefab | Code (unchanged) |
|-------------|----------------------|-------------|--------|------------------|
| [ab865a8b…](https://www.fab.com/listings/ab865a8b-c6c8-4362-8998-50bc8239277d) | **Sci Fi Server rack** (Apoc) | `server-rack` | `entities/server-rack/server-rack.prefab` | `HackerServerRackEntity` |
| [b88398ff…](https://www.fab.com/listings/b88398ff-b7a5-4194-9b9b-a20f6418e16e) | **Retro Display Terminal** (SIUP 3D ART) | `hacker-terminal` | `entities/hacker-terminal/hacker-terminal.prefab` | `HackerTerminalEntity` |
| [9ca40057…](https://www.fab.com/listings/9ca40057-1d77-4551-b5f2-8b3a6fbc8f80) | **Sci Fi Server Rack** (Apoc) | `advanced-server-rack` | `entities/advanced-server-rack/advanced-server-rack.prefab` | `HackerAdvancedServerRackEntity` |
| [032b43f4…](https://www.fab.com/listings/032b43f4-f690-47cb-8856-c33255394e80) | **Retro Computer 80s** (SIUP 3D ART) | `advanced-hacker-terminal` | `entities/advanced-hacker-terminal/advanced-hacker-terminal.prefab` | `HackerTerminalEntity` (Advanced tier) |

---

## Police / government (`governmentdatacenter` addon)

| Fab listing | Fab title (library match TBD) | Entity slug | Prefab | Code |
|-------------|--------------------------------|-------------|--------|------|
| [63d33934…](https://www.fab.com/listings/63d33934-fbed-415f-901c-48b3b8b7e2d8) | Police HUB — confirm title on download | `government-server-rack` *(or new police-hub slug)* | `entities/government-server-rack/` | Gov rack + `PoliceTerminal` lane |
| [c906cc59…](https://www.fab.com/listings/c906cc59-704a-4808-8329-35eac3d7f65c) | **RETRO CRT MILITARY SCANNER TERMINAL** (juavi) | `police-terminal` | `entities/police-terminal/police-terminal.prefab` | `PoliceTerminal` UI host |
| [ac2a94ff…](https://www.fab.com/listings/ac2a94ff-4e8c-4c4b-a315-390e2ee22f7a) | Government HUB — confirm on download | `government-server-rack` or split prefab | TBD on intake | FBI / lifepunchnet lane |
| [e84b0092…](https://www.fab.com/listings/e84b0092-7865-4547-8a9a-028096832736) | Government Terminal — confirm on download | `police-terminal` or gov terminal split | TBD | Gov terminal UI |

*Note:* library also has **Servers (DataCenter)** (Michael Vest) — may map to police/gov hub rows; confirm against listing pages when downloading.

---

## lpblackmarket (`blackmarketdealer` addon)

| Fab listing | Fab title (library) | Entity slug | Prefab | Code / notes |
|-------------|----------------------|-------------|--------|--------------|
| [66cf0cb2…](https://www.fab.com/listings/66cf0cb2-65cf-4d95-a4dd-211020007d4a) | **Vault Safe + Gold & Silver** (Michael Vest) | `black-market-hub` | `entities/blackmarkethub/` | BM hub — entity code TBD on intake |
| [814d0a20…](https://www.fab.com/listings/814d0a20-29ff-4746-994d-edc23f308680) | **Payment Terminal** (EddieEdwin) | `black-market-terminal` | *(create/split on intake)* | Terminal pattern + BM UI |
| [a19f7e5f…](https://www.fab.com/listings/a19f7e5f-316c-4f8a-a2d4-f607efbb9dd7) | **Locker 19** (Alexandr Lipin) | `black-market-locker` | **New entity** | Flash-drive deposit reader — **new gameplay** after props baseline |
| [b272034f…](https://www.fab.com/listings/b272034f-52a1-4e14-bba9-c16f125da90c) | **Assault Rifle - AR 15** (Alexandr Lipin) | weapon addon | separate from prop pass | Full weapon pipeline — **parallel track**, not Phase 1 prop swap |

---

## lpbanker (new lane — scope TBD)

| Fab listing | Fab title (library) | Intended role | Ship now? |
|-------------|----------------------|---------------|-----------|
| [4e1f1bda…](https://www.fab.com/listings/4e1f1bda-c2af-479c-a4dc-74c540351ca7) | Banker Hub — confirm title | Banker hub prop | **New addon/lane** — mesh first, economy later |
| [2d829c99…](https://www.fab.com/listings/2d829c99-c305-4140-a8f6-1a75830c2048) | **Sci-fi Computer console** (Apoc) | Bank terminal | New terminal entity + UI |
| [e1d3cdb1…](https://www.fab.com/listings/e1d3cdb1-6b10-49ce-8165-6e2196ba79c5) | **Modern ATM Machine** (AshenCut) | Player invest ATM | New interactable — after banker hub |

---

## Recommended intake order

1. **bitcoin-miner** (CPU GAMER) — hub powers whole lane  
2. **bitcoin-terminal** (Computer all-in-one) — HASHD CRT  
3. **gpu-rack** (Crypto Farm) — Phase 1 collision on existing + fresh FBX  
4. **hacker** server rack + terminal pair  
5. **advanced** hacker pair  
6. **government / police** pair  
7. **black market** hub + terminal + locker  
8. **banker** lane (new)  
9. **USB flash drive** + **AR-15** (feature work)

---

## Per-asset workflow (repeat)

1. Download FBX from Fab library → owner drop folder (see `MODEL_INTAKE_DROP_MAP.md`)  
2. Intake script or manual copy → `models/.../source/`  
3. ModelDoc → compile → **Phase 1:** white wireframe = BoxCollider **X,Y,Z** on all axes  
4. Pull `_c` → sync DXRP → you sign off prefab  
5. **Do not** touch entity C# unless **new** feature row above  

---

## CPU GAMER hub — important (Fab listing — **superseded for Phase A hub mesh**)

**June 2026:** Active hub mesh = Sketchfab Generic PC Desktop → `bitcoin-hub.vmdl` (see `bitcoinhub/assets/models/MODEL_BUILD.md`). Fab CPU GAMER below is inventory/history only — do not compile for hub.

Listing notes: **no textures (solid colors)**; blend file includes RGB animation and fan movement.  
**Ship approach:** static FBX body + LifePunch vmats for fence/LED; **child-GO fan spin** (same as Evo pattern) — do **not** import animated rig as body render mesh.
