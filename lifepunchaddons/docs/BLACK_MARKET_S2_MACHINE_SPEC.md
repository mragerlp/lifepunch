# LIFEPUNCH™ Black Market — BM-S2 machine spec (storefront + dead-drop)

**2026-07-15 · GitHub issue #147 · content-only slice.** Digital machines per
`LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md` (model → collision → states OFF/BOOTING/RUNNING).
Consumes the S1 registration proposal (PR #158, `BLACK_MARKET_DEALER_S1_REGISTRATION_PROPOSAL.md`);
does **not** decide rulings R2–R8.

**Hard fences honored:** zero economy (no sales, no BTC/cash transfers, no market rows, no grants);
no fencing flow (R6 OPEN); no job gate wiring (S1 portal contract pending); no touch of lpbitcoin,
lpplayerhub, banker, chemist, or #149 S4 trees.

> **EDITOR PROOF OWED.** This slice was authored with the editor bridge down (eyes covered).
> Nothing below claims compile, scale, collider, spawn, or visual verification. The flatgrass
> acceptance in #147 (spawn + USE + state cycle + bridge screenshot) is owed by a bridge-connected
> session before this slice counts as machine-proven.

---

## 1. Entity slots

Two new entity slots under the staged `lpblackmarket` package (folder name = ship slug,
`PACKAGE_STAGING_LAYOUT.md`). Existing staged slots (hub/register/locker/terminal) are untouched —
repurposing them onto S2 roles is a mesh-selection decision left to owner sign-off.

| Slot | Machine | Role (Law 2 analog) | Code (this slice) |
|---|---|---|---|
| `blackmarketstorefront` | Dealer stall / hidden storefront | Operator-facing hub surface | `Code/Addons/lifepunch/lpblackmarket/blackmarketstorefront/code/` |
| `blackmarketdeaddrop` | Dead-drop stash | Satellite, location-is-knowledge | `Code/Addons/lifepunch/lpblackmarket/blackmarketdeaddrop/code/` |

Shared state machine: `Code/Addons/lifepunch/lpblackmarket/_shared/code/components/LpBlackMarketMachine.cs`.

Code is authored on the transitional path (`lifepunchaddons/Code/Addons/lifepunch/lpblackmarket/…`)
per the staging layout's "author toward target paths" rule — **not** under the legacy
`blackmarketdealer` repoIdent, matching the S1 R7 recommendation without deciding it.

## 2. Model layer (P0 — owed)

Box-before-bones. No vmdl is authored in this slice; candidates for owner mesh sign-off:

| Machine | Mesh candidates (staged sources) | Notes |
|---|---|---|
| Storefront | `lpblackmarket/blackmarkethub/assets/source/fbx/Safe_Vault_TRIO.fbx` (vault) or a purpose-built stall | Scale vs citizen (~64–72u) unverified — editor proof owed |
| Dead-drop | `lpblackmarket/blackmarketlocker/assets/source/fbx/SF_Locker_19.fbx` (locker) | Same |

Until a vmdl exists, prefabs may ship a placeholder box mesh — honest baseline per
`MODEL_FOUNDATION_PASS.md`.

## 3. Collision

Phase-1 **BoxCollider baseline** (TECH_DEBT `BLACKMARKET-01`): `LpBlackMarketMachine`
auto-creates a single BoxCollider sized from renderer bounds (or a citizen-relative 32×32×48u
stand-in when no mesh is present) and logs `LP_BLACKMARKET_SENSOR baseline-boxcollider`.
Endgame: multiple ModelDoc convex hulls (stall: counter, shelf, feet; drop: shell, lid).

## 4. Attachments (P1 plan — not authored)

`led_status`, `screen` (storefront), `stash_slot`, `light_conceal`. Authored in ModelDoc after
P0 mesh sign-off; effects/audio originate from attachments, not mesh center.

## 5. State machine (Law 6 — implemented)

`LpBlackMarketMachineState`: **OFF → BOOTING (BootSeconds, default 2.5 s) → RUNNING**, host-
authoritative (`[Sync(SyncFlags.FromHost)]`, transitions host-only). USE (`Component.IPressable`
→ `[Rpc.Host]`): OFF starts boot; RUNNING logs the display-only placeholder inventory then powers
off; BOOTING ignores input. Every transition emits `LP_BLACKMARKET_SENSOR state …`.
OVERCLOCKED / BROKEN / HACKED: later slices. State-driven lights/sound: P1–P3, hook provided
(`OnStateChangedHost`).

## 6. Prefab skeleton (target hierarchy — prefabs owed with editor proof)

```text
BlackMarketStorefront                     BlackMarketDeadDrop
├── Mesh (ModelRenderer — box baseline)   ├── Mesh (ModelRenderer — box baseline)
├── BoxCollider (BLACKMARKET-01)          ├── BoxCollider (BLACKMARKET-01)
├── LpBlackMarketStorefrontEntity         ├── LpBlackMarketDeadDropEntity
├── LedStatus (P1)                        └── StashSlot (P1)
└── Screen (P1 — UI child plane, #135/S5)
```

## 7. Placeholder inventory

Display-only string labels surfaced via host log sensor. Not market rows, not content references,
no prices, no grants — SKU selection collides with OPEN rulings R2/R5. The stub browse panel is a
UI slice behind the #135 shell (S5) and is **not** shipped here.

## 8. Acceptance vs #147 (status)

| #147 acceptance | Status |
|---|---|
| Machines spawn on flatgrass | **Owed** — editor bridge down this session |
| USE opens placeholder | Partial — USE + placeholder implemented, log-sensor only; panel owed (S5/#135) |
| State machine cycles | Implemented (code); flatgrass cycle proof owed |
| Bridge screenshot | **Owed** |
| Grep: no wallet/ledger API | Provable now — `rg -i "wallet|ledger|balance|payout|btc" Code/Addons/lifepunch/lpblackmarket/` returns comment/doc mentions only, zero API calls |

## 9. Open flags

- **R6 (fencing / No-NPC Law):** untouched; nothing here sells, buys, or fences.
- **R7 (ident):** code placed under `lpblackmarket` package path with headers using the S1-proposed
  field map (`lifepunch.blackmarket` / transitional `blackmarketdealer`). This follows the S1
  proposal; it does not ratify it. No manifest (`addons.json`/`packages.json`) registration made.
- **Compile proof owed:** `.cs` under `Code/Addons/lifepunch/` may compile in the umbrella dev
  project; no editor was available to prove it this session.
