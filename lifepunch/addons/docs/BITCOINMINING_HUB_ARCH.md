# Bitcoin Miner hub architecture (owner canon)

**Slug:** `bitcoin-miner` · **Folder:** `entities/bitcoinminer/`  
**Menu:** existing `HashdTerminal.razor` (amber hashd) — **additions only**

---

## Per player

| Rule | Value |
|------|-------|
| Max hubs | **2** |
| Per hub — small racks | **2** (`gpu-rack`) — slots **GPURack-1 … GPURack-2** |
| Per hub — advanced racks | **2** (`advanced-gpu-rack`) — slots **AdvancedGPURack-1 … AdvancedGPURack-2** |

**Purchase caps are enforced by the DXRP portal / market content rows**, not by LifePunch dev spawn ConCmds. LifePunch code labels linked racks by type (`LpBitcoinIdent.FormatRackSlotId`); do not hard-cap in `LpBitcoinDevSpawn`.

**Phase A prop baseline (owner sign-off Jun 2026):** printer-style gravity drop, grabbable (`hands_interact`), model-synced collider. Standard GPU rack = static open frame (fan child GOs **disabled**); advanced = stacked mesh with baked fan bank — intentional tier read, not a spawn bug.

Each hub controls **only its linked racks** (same spawner `Owner` + within **8m / 4m** of hub). Racks are **separate Market purchases** — not bought inside hashd (Phase 2 deploy TBD).

---

## Power flow

```text
1. Hub spawns OFFLINE. USE hub or `hashd` near hub → HUB POWER GATE UI
2. Type `power on` → click POWER ON on rail → hub anim + startup sound
3. Hashd rig control opens on powered hub (USE or `hashd`)
4. Rail START/STOP or `mining` commands → GPU rack mining + rack anims
5. `power off` → confirm POWER OFF → linked racks stop, fans ramp down
```

Dev skip: `lp_hub_power 1` / `lp_hub_power 0`

---

## Upgrades

### On hub (`bitcoin-miner`) — encryption (PvP defense)

See `BITCOINMINING_ENCRYPTION_SPEC.md` — mirrors hacker server-rack offense.

### On each rack — hardware (money)

- CPU Clock (7 tiers)
- CPU Cores (3 tiers)
- RGB Fans (cosmetic + shader) — **donor-only variants** when shipped; see `BITCOINMINING_DONOR_PERKS.md`
- Future: PSU, Cooling, VRAM

---

## HP (owner canon)

| Entity | Max HP |
|--------|--------|
| `bitcoin-miner` hub | 250 |
| `gpu-rack` | 500 |
| `advanced-gpu-rack` | 2000 |

Damage → metal hit SFX → smoke → explode (existing `GpuRackEntity` path).

---

## Scale (visual)

**Intended in-world read:** Ophion hub = **Raijintek Ophion gaming PC tower** (standing ITX build — visible GPU/PSU, hashd control station). Reference: [Sketchfab Gaming PC (Ophion)](https://sketchfab.com/3d-models/gaming-pc-765427bb0cc3495592f94e0ac468d48c). **GPU Rack** = standing open-frame crypto mining rig. Reference: [Sketchfab Crypto Farm / Mining Rig](https://sketchfab.com/3d-models/crypto-farm-mining-rig-049f02ffd15c41ca8cb8020feb43993f). **Advanced GPU Rack** = stacked farm unit (largest).

Prefab roots stay `1,1,1` (`MODEL_SCALE_DOCTRINE.md`). Tune `import_scale` in `bitcoin-miner.vmdl` until mesh bounds match a ~15″ tall tower on flatgrass — not a shrunken desk puck.

## PvP upgrades (miner vs hacker)

| Side | Buys on | Effect |
|------|---------|--------|
| **Miner** | Hub hashd — encryption tracks | Firewall, Wallet Cipher, Alert, Re-hack CD, **Puzzle Hardening** (shorter attacker window) |
| **Hacker** | Server rack — offense tracks | Detection, **Puzzle Time** (more time to crack), Reward, Cooldown |

Host resolves: `attackerPuzzleSeconds = base + hackerPuzzleBonus − minerHardeningBonus` (`BITCOINMINING_ENCRYPTION_SPEC.md`).

## Deprecated

- Using the hub menu as a typed command console (rig0 input moved to monitor only).

---

## Dev (after path migration)

```text
lp_spawn_bitcoin_miner_hub
lp_hashd_preview          # opens menu on nearest hub
```

---

## Related

- `LIFEPUNCH_CYBER_ECOSYSTEM.md`
- `ASSET_INTAKE_CYBER_ECOSYSTEM.md`
