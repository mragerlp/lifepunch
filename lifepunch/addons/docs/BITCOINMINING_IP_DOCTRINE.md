# LIFEPUNCH Bitcoin Miner — IP doctrine

**Status:** Canonical · **Applies:** `lifepunch.bitcoinmining` ship tree + portal + all agents  
**Owner:** PEAK PERFORMANCE PRODUCTS LLC · brand **LIFEPUNCH™** · lifepunch.co

---

## 1. Source identifier

**LIFEPUNCH™ Bitcoin Miner for DXRP** is original downloadable content published by LIFEPUNCH. It is **not** a port, fork, sublicense, or tribute build of any third-party addon, network, or author.

Bitcoin-mining roleplay predates any single modern addon author — it is a **Garry's Mod / DarkRP genre**. LIFEPUNCH built this from **original work** and public genre conventions only — **not** copy-paste, not sublicensed UI/meshes/sounds, and **no credits** to other addon businesses or creators.

No individual “invented” the miner job; LIFEPUNCH owns **this** implementation.

- **Publisher on every listing:** LIFEPUNCH (lifepunch.co)
- **In-product About:** LIFEPUNCH™ proprietary notice only — **no third-party credits on the miner**
- **Assets:** LifePunch-owned or owner-licensed meshes, vmats, sounds — self-contained under `addons/lifepunch/bitcoinmining/`
- **Code:** Proprietary header on every `.cs` / `.razor` / `.scss` file

**Respect note (other products only):** **ULX / Ulysses** may be credited on `**lifepunch.ulx`** (staff menu) as the historical GMod admin lineage — that credit does **not** extend to the Bitcoin Miner addon.

---

## 2. Portal nominative comparison (paste-ready)

> **LIFEPUNCH™ Bitcoin Miner for DXRP** is an original placeable mining kit: HASHD rig control (`hashd`), LifePunch-owned GPU rack meshes, and server-authoritative BTC economy. It is **not affiliated with, endorsed by, or derived from** any other bitcoin mining or crypto-miner addon for Garry's Mod, s&box, or DXRP. Bitcoin-mining roleplay is a long-standing **genre** on RP servers; LIFEPUNCH ships its **own** art, branding (amber HASHD / `rig0>`), and architecture (hub + racks + encryption). Published by **LIFEPUNCH** — lifepunch.co. Proprietary; no redistribution.

Use nominative mentions of **DXRP** and **s&box** only as platform compatibility (see `lifepunch-trademark-ip` rule). **Never** name other addon authors, networks, or menus in portal copy, About tabs, or credits.

---

## 3. Architecture differences (we already win here)


| Common single-entity pattern              | LIFEPUNCH canon                                                         |
| ----------------------------------------- | ----------------------------------------------------------------------- |
| CRT / terminal mesh **on the mining rig** | **Bitcoin Miner hub** (Ophion) runs HASHD — racks are **hardware only** |
| One combined prefab                       | **Hub** + up to 3 small racks + 1 large rack per hub                    |
| Interact-only UI                          | `**hashd` / `mine` commands** + hub USE + power gate                    |
| Fixed 60s payout cadence                  | `**MiningPayoutIntervalSeconds = 90`** (`BitcoinMiningAddon.cs`)        |


GPU racks expose **LCD telemetry** (`TextRenderer`) — not a full terminal skin on the rack mesh.

---

## 4. Economy constants (LifePunch-owned tuning)


| Constant        | Value                     | Where                                            |
| --------------- | ------------------------- | ------------------------------------------------ |
| Payout interval | **90 seconds**            | `BitcoinMiningAddon.MiningPayoutIntervalSeconds` |
| Base speed      | `0.005` BTC per tick unit | `GpuRackEntity`                                  |
| BTC sell price  | `$1500`                   | `GpuRackEntity`                                  |


Genre overlap (upgrade tiers, sell command) is fine. **Our numbers and cadence are ours.**

---

## 5. Sounds policy

- Ship tree contains **zero audio binaries** until owner intake (`sounds/bitcoinminer/README.md`).
- Slot **names** (`server-hum`, `keyboard`, …) describe roles — they are **not** permission to copy anyone else's WAVs.
- Publish staging must contain **only** owner-recorded or licensed files under `sounds/bitcoinminer/`.
- **Never** commit third-party bitcoin mining study archives (gitignored under `reference/`).

---

## 6. Ship-tree protection (agent gate)

Before publish or public screenshot:

```powershell
# Ship identity — terminal UI must carry LIFEPUNCH source marks
rg -i "LIFEPUNCH|lifepunch\.co|HASHD RIG CONTROL" lifepunch/addons/Code/Addons/lifepunch/bitcoinmining --glob "*.{cs,razor,scss}"

# No third-party cloud package refs in ship assets
rg -i "cloud\.facepunch|packages\.facepunch" lifepunch/addons/Assets/addons/lifepunch/bitcoinmining

# Sounds: README only until owner intake (no audio binaries in ship tree)
Get-ChildItem lifepunch/addons/Assets/addons/lifepunch/bitcoinmining/sounds -Recurse -File -ErrorAction SilentlyContinue |
  Where-Object { $_.Extension -match '\.(wav|mp3|ogg|sound|vsnd)$' }
```

First grep **must have hits**; cloud-path grep **must be zero**; sounds listing **must be empty** (pre-intake).

Also verify:

- [ ] No third-party cloud model paths in prefabs
- [ ] No third-party `.sound` / `.sound_c` / `.wav` in publish staging (until owner intake)
- [ ] `about` → LIFEPUNCH™ only
- [ ] `addons.json` leads with **LIFEPUNCH**
- [ ] No forbidden third-party bitcoin mining study tree in repo

Checklist: `briefs/BITCOINMINING_PROTECTION_CHECKLIST.md`

---

## 7. Agent instructions

1. **Do not** add third-party credits or “inspired by [author]” lines to miner ship docs or UI.
2. **Do not** re-import third-party meshes, sounds, or UI copy.
3. **Do** lead with **LIFEPUNCH** on all miner listings.
4. Clone accusations → genre ≠ copy; cite §2–§5.
5. **Vocabulary:** Use only LIFEPUNCH canon (`bitcoinmining`, `hashd`, GPU racks, Bitcoin Miner hub). Do **not** name, grep for, or document legacy third-party miner/admin addons — they are not part of this repo’s vocabulary. Protection checks use **positive identity greps** (§6) and study-tree absence only.

---

## 8. Related

- `reference/BITCOINMINING_PORTAL_LISTING.md`
- `BITCOINMINING_UX_SPEC.md`
- `lifepunch/legal/TRADEMARK_AND_IP.md`

