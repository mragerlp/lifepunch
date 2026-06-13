# Today prep — finish Bitcoin Miner, start Hacker Job

**Date:** 2026-06-13 · **Red:** Vengeance + s&box playtest

---

## Bitcoin Miner — finish line (P0 this session)

| Step | Action | Done when |
|------|--------|-----------|
| 1 | **Flatgrass playtest** — hub power, PIN, `hashd`, rack link, fan spin, sounds | Screenshots in `BITCOINMINING_PLAYTEST.md` scale table updated |
| 2 | **Remove dev spawn** — delete or gate `BitcoinMiningDevSpawn.cs` before publish staging | Not in `prepare-publish.ps1` upload |
| 3 | **Market rows** — `addons.json` content rows match portal copy (`BITCOINMINING_IP_DOCTRINE.md` §2) | `dxrpAddonId` filled when portal package created |
| 4 | **Compile check** — all hub/rack vmats + vmdl `_c` in Assets tree | Dedicated-server mount OK |
| 5 | **Optional TECH_DEBT** — real `Metal036_2K_Color.jpg` intake if hub still placeholder | Logged in `TECH_DEBT.md` only if still placeholder |

**Do not block on:** third-party study folder — separation audit **CLEAR**.

---

## Hacker Job — start line (P1 after Bitcoin playtest pass)

| Step | Action | Ref |
|------|--------|-----|
| 1 | Read `HACKER_JOB_SPEC.md` + `HACKER_PHASE2_ECONOMY_PREP.md` | Economy = Opus lane |
| 2 | **ModelDoc** — compile `_c` for terminal + server rack prefabs | `hackerjob` MODEL_BUILD.md files |
| 3 | **Playtest** — `cornerman.exe` / puzzle flow on flatgrass | `HACKER_TERMINAL_FLOW.md` |
| 4 | **Cornerman distill** (optional) — terminal fiction + protection checklist | `WarmDistill` on Green |

**Brand guard:** amber HASHD = bitcoinmining only; hacker stays green `#00FF7F` / `cornerman.exe` per `TERMINAL_BRAND_MATRIX.md`.

---

## Cornerman status (post cleanup)

- Third-party study staged → `C:\lifepunch\reference-intake\bitcoinmining\third-party-bitminer-study\` on Green (27 files, **not in git**)
- Monorepo reset → `origin/main` at `77fa06a` (matches GitHub until Vengeance pushes `49564d4+`)
- LM **daily lane** — distill + embed loaded; coder on disk
- **LM Watchdog** — `LifePunch-Cornerman-LM-Watchdog` installed (10m + logon)

---

## First command when you sit down

```text
s&box → flatgrass → playtest Bitcoin hub + racks → then open Hacker prefab scene
```
