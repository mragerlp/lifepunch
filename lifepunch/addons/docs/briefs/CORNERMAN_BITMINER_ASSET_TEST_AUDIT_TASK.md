# Cornerman task — Bitcoin mining asset test-readiness audit

**Lane:** Tier-3 prep (distill) · **Priority:** **P1b** (parallel with Hacker Job P0 — owner asked: *can we test?*)  
**Issued:** 2026-06-11 · **Red:** VENGEANCE runs editor smoke after your report  
**You do NOT:** open s&box, ModelDoc, compile, `git push`, or patch C#.

---

## Read first (in order)

| # | Path | Why |
|---|------|-----|
| 1 | `addons/Assets/addons/lifepunch/bitcoinmining/ASSET_INVENTORY.md` | Ship tree + hub canon |
| 2 | `addons/Code/Addons/lifepunch/bitcoinmining/docs/BITMINER_PLAYTEST.md` | Red smoke commands + log triage |
| 3 | `addons/docs/BITMINER_HUB_ARCH.md` | Hub power gate + rack linking |
| 4 | `addons/docs/BITMINER_ENCRYPTION_SPEC.md` | Hub upgrade tracks (UI stub) |
| 5 | `addons/docs/TECH_DEBT.md` | BITMINER-01/02/03 open items |
| 6 | `addons/docs/briefs/BITMINER_PROTECTION_CHECKLIST.md` | IP rows if time |

---

## Task B-TEST-1 — File inventory (repo walk)

Under `addons/Assets/addons/lifepunch/bitcoinmining/`, build a table for **each ship entity**:

| Slug | prefab | prefab_c | vmdl | vmdl_c | source mesh | vmats _c | sounds |
|------|--------|----------|------|--------|-------------|----------|--------|
| `bitcoin-miner` (hub) | | | | | Ophion.fbx | | |
| `gpu-rack` | | | | | gpu-rack-static + anim FBX | | |
| `large-gpu-rack` | | | | | stacked anim FBX | | |
| ~~`bitcoin-terminal`~~ | deprecated | | | | legacy CRT | | |

**Helper (run on Green after `MonorepoPull`):**

```powershell
cd C:\Projects\lifepunch\lifepunch\addons\Assets\addons\lifepunch\bitcoinmining
Get-ChildItem -Recurse -File | Group-Object Extension | Sort-Object Count -Descending | Format-Table Name, Count
Get-ChildItem -Recurse -Filter '*_c' | Select-Object FullName
Get-ChildItem -Recurse entities -Filter '*.prefab*' | Select-Object Name, Directory
```

Flag anything referenced in `Bitminer.cs` / `BitminerHubEntity.cs` paths that is **missing on disk**.

---

## Task B-TEST-2 — Test readiness matrix

For each smoke path in `BITMINER_PLAYTEST.md`, mark **GO / PARTIAL / BLOCKED** and one-line reason:

| Smoke | Commands | Your verdict |
|-------|----------|--------------|
| Hashd UI only | `lp_hashd_preview` | UI works without mesh? |
| Legacy pair spawn | `lp_spawn_bitminer` | terminal + small rack |
| Hub power gate | `lp_spawn_bitcoin_miner_hub` → `power on` → POWER ON | hub prefab + Ophion compile |
| Dev skip power | `lp_hub_power 1` → `hashd` | |
| Full kit | `lp_spawn_bitminer_full_kit` | three entities |
| Mining loop | `mining start` / rail START | rack anims optional |
| Sounds | hub startup / fan loop | `sounds/bitcoinminer/` empty? |

Cross-check **BITMINER-01** (power_on/off sequences), **BITMINER-03** (RGB shader baseline), hub sounds folder.

---

## Task B-TEST-3 — Owner gap list (assets only)

Separate **Red can test now** vs **owner must drop**:

| Gap | Blocker level | Owner action |
|-----|---------------|--------------|
| Hub `bitcoin-miner.vmdl_c` / `prefab_c` | | ModelDoc on Red |
| Ophion hub textures / vmats | | Owner pack in `entities/bitcoinminer/textures/`? |
| `power_on` / `power_off` in vmdl | | ModelDoc Add Simple Animations |
| `sounds/bitcoinminer/*` | | WAV drop + `Intake-BitcoinMinerSounds.ps1` |
| RGB fan shader | | Optional — baseline uses complex.shader |

Do **not** duplicate full cyber-ecosystem intake — link `ASSET_INTAKE_CYBER_ECOSYSTEM.md` if needed.

---

## Deliverable (required)

Create **`outbox/BITMINER_TEST_READINESS.md`** with:

1. **Executive summary** — one paragraph: *Can Red run a meaningful playtest today?* (yes/no/partial)
2. **Entity inventory table** (B-TEST-1)
3. **Smoke verdict table** (B-TEST-2) with recommended **first command** for Red
4. **Owner gap list** (B-TEST-3) — bullet list only what owner must still provide
5. **Cornerman confidence** — high/medium/low + what you could not verify without editor

Optional second file: `outbox/BITMINER_ASSET_FILE_TREE.txt` (flat path list) if helpful for RAG.

---

## Ping Red (one line)

```text
OK cornerman bitminer test audit — see outbox/BITMINER_TEST_READINESS.md — verdict: <GO|PARTIAL|BLOCKED>
```

Hub ingest to lifepunchnet when done (workflow ack).
