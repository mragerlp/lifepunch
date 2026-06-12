# Bitcoin Miner hub architecture (owner canon)

**Slug:** `bitcoin-miner` · **Folder:** `entities/bitcoinminer/`  
**Menu:** existing `HashdTerminal.razor` (amber hashd) — **additions only**

---

## Per player

| Rule | Value |
|------|-------|
| Max hubs | **2** |
| Per hub — small racks | **3** (`gpu-rack`) |
| Per hub — large rack | **1** (`large-gpu-rack`) |

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
- RGB Fans (cosmetic + shader)
- Future: PSU, Cooling, VRAM

---

## HP (owner canon)

| Entity | Max HP |
|--------|--------|
| `bitcoin-miner` hub | 250 |
| `gpu-rack` | 500 |
| `large-gpu-rack` | 2000 |

Damage → metal hit SFX → smoke → explode (existing `GpuRackEntity` path).

---

## Scale (visual)

**Intended in-world read:** Ophion hub = **small desktop control box** · GPU Rack = low horizontal unit · Large GPU Rack = **largest** farm stack.

Prefab roots stay `1,1,1` (`MODEL_SCALE_DOCTRINE.md`). If hub `BoxCollider` Z rivals the large rack but the mesh looks like a PC, the collider is stale — retune on flatgrass with bridge bounds, not prefab root fudge.

## PvP upgrades (miner vs hacker)

| Side | Buys on | Effect |
|------|---------|--------|
| **Miner** | Hub hashd — encryption tracks | Firewall, Wallet Cipher, Alert, Re-hack CD, **Puzzle Hardening** (shorter attacker window) |
| **Hacker** | Server rack — offense tracks | Detection, **Puzzle Time** (more time to crack), Reward, Cooldown |

Host resolves: `attackerPuzzleSeconds = base + hackerPuzzleBonus − minerHardeningBonus` (`BITCOINMINING_ENCRYPTION_SPEC.md`).

## Deprecated

- `bitcoin-terminal` prefab — menu moves to hub
- Separate CRT as hashd control station

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
