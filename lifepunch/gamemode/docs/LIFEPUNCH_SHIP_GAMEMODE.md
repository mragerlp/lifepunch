# LIFEPUNCH™ — ship gamemode (DXRP portal)

**Status:** Portal gamemode created · **not live on servers yet** · becomes production when bitcoinmining is publish-ready.

---

## Two gamemodes (do not conflate)

| Portal name | Role | When to use |
|-------------|------|-------------|
| **LIFEPUNCH™** | **Ship / production** gamemode — publish-ready addon pins, real community loadout | Assign to **70p** + **Development** after bitcoin sign-off |
| **LifePunch** (`019e36c0-…`) | **Legacy / dev** gamemode — earlier pins, AK47/weapon tests, WIP attachments | Development testing only until migration complete |

**Law:** New publish-ready work pins on **LIFEPUNCH™**, not the legacy LifePunch row. Do not mix revision pins across gamemodes without owner approval.

---

## Current server state (June 2026)

| Server | Today | Target |
|--------|-------|--------|
| **70p** (`lifepunchmainserver`) | Often **Vanilla** on portal | **LIFEPUNCH™** when bitcoin + gamemode pins are validated |
| **Development** (`lifepunchdevelopment`) | LifePunch gamemode or test pins | **LIFEPUNCH™** first — then promote to 70p |

Vanilla = base `dxura.rp` only (no LifePunch addon pins). **LIFEPUNCH™** = the real branded gamemode experience.

---

## Rollout (bitcoin finish → live)

1. **Editor proof** — bitcoinmining P0 on flatgrass (`BITCOINMINING_PLAYTEST.md`, polish checklist green).
2. **Publish addon** — `prepare-publish.ps1 -Addon bitcoinmining` → portal revision with `_c` assets.
3. **Pin on LIFEPUNCH™** — Portal → Game Modes → **LIFEPUNCH™** → Addons tab → pin `lifepunchbitcoin` revision.
4. **Content / Market / Jobs** — attach equipment + market rows on **LIFEPUNCH™** only (gamemode lane files).
5. **Development server** — assign **LIFEPUNCH™** → **Sync Servers** → **Restart** → playtest.
6. **70p promotion** — owner sign-off → assign **LIFEPUNCH™** on main → Sync → Restart.
7. **Record** — `lifepunch/server/change-log/` entry for gamemode assignment + sync.

---

## Portal IDs

Fill when captured from dxrp.net:

| Gamemode | Portal ID |
|----------|-----------|
| **LIFEPUNCH™** (ship) | `TBD` — paste from Game Modes detail URL |
| LifePunch (legacy) | `019e36c0-a67f-701c-90f2-460e0b0f1487` |

Update `lifepunch/gamemode/config/gamemode.json` when the LIFEPUNCH™ ID is known.

---

## Agent law

- **Do not** assign **LIFEPUNCH™** to 70p or run **Sync Servers** until bitcoinmining is publish-ready and development playtest passes.
- **Do not** treat legacy **LifePunch** pins as the ship target for new addons.
- **Do** export **LIFEPUNCH™** gamemode (`Export` on portal) before risky pin changes.

Related: `GAMEMODE_PIPELINE.md` · `portal/game-modes/README.md` · `addons/docs/BITCOINMINING_POLISH_CHECKLIST.md`
