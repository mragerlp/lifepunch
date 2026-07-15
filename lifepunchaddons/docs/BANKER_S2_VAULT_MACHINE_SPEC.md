# LIFEPUNCH™ Banker S2 — vault storage machine spec (content-only)

**Issue:** #139 · **Status:** baseline shipped, editor proof owed · **Surface:** machine spec + prefab/component skeleton + state machine code
**Package identity (per S1 proposal):** packageSlug `lifepunchbanker` · packageFolder `lpbanker` · sboxIdentifier `lifepunch.banker` · legacy repoIdent `bankerjob` · entity slug `bankerhub` (asset slot already staged with the Safe intake; ship prefab slug `bankvault`).

## 1. Scope and fences (from the #139 CONDUCTOR LIVE comment)

- Vault/storage as a **digital machine** per `LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md` — machine, not prop.
- **Content-only.** Placeholder manifest + open/close states. **ZERO economy**: no deposits,
  withdrawals, interest, yields, fees, or wallet/bank mutations. The $LP hookup is S4 (#141,
  head-dev-only).
- Box-before-bones: static box baseline first. No bone/animation stacks in this slice.
- No menu-shell UI edits; USE-prompt interaction only.

## 2. Machine stack mapping (build order per the standard)

| Layer | S2 baseline (this slice) | Endgame (owed) |
|---|---|---|
| Model | `models/dev/box.vmdl` placeholder, dark-steel tint. Safe intake exists at `lpbanker/bankerhub/assets/source/fbx/Safe_all.fbx` + textures — **not yet a compiled vmdl** | ModelDoc pass on the Safe intake per `MODEL_FOUNDATION_PASS.md` (P0 gate, owner mesh sign-off) |
| Collision | Single static `BoxCollider` 40×40×48u — honest baseline, tracked **BANKER-01** in `TECH_DEBT.md` | Multiple convex hulls in ModelDoc (body, door, hinge, feet) |
| Physics | Static world machine (no Rigidbody — a vault does not tip over) | Same; heavy-object rules if ever grabbable |
| Attachments | Status light child `vault_status_glow` positioned from renderer bounds in code | Authored ModelDoc attachments: `led_status`, `door_hinge`, `keypad`, `screen` |
| Lights | `PointLight` component driven by state (never emissive-only) | Same pattern on authored attachment |
| Animation | **None** (box-before-bones) | `door_open` / `door_close` takes after P0 sign-off |
| Sound | None in S2 | Boot chirp, door clunk, running hum, timed to state |
| State machine | `LpBankVaultEntity`: OFF → BOOTING (3s) → RUNNING, host-authoritative `[Sync(FromHost)]`; door OPEN/CLOSED sub-state only while RUNNING | + LOCKDOWN/BROKEN/HACKED when the S4/security design rules them |
| Gameplay | USE cycles power/door; placeholder manifest labels only | S4 economy (gated), PIN/ownership, teller links |

## 3. Law 6 state read (spectator test)

| State | Read |
|---|---|
| OFF | Dark machine, no light |
| BOOTING | Amber blinking status light (~2 Hz) |
| RUNNING (door closed) | Steady green status light |
| RUNNING (door open) | Steady blue status light |

## 4. Files in this slice

| File | Role |
|---|---|
| `Code/Addons/lifepunch/lpbanker/bankerhub/code/components/LpBankVaultEntity.cs` | State machine + USE + placeholder manifest (zero economy) |
| `Code/Addons/lifepunch/lpbanker/bankerhub/code/components/LpBankVaultVisuals.cs` | State → light visuals (Law 6) |
| `Assets/addons/lifepunch/lpbanker/bankerhub/assets/entities/bankvault.prefab` | Prefab skeleton: collider + renderer + both components |
| `docs/BANKER_S2_VAULT_MACHINE_SPEC.md` | This spec |
| `docs/TECH_DEBT.md` | BANKER-01 baseline entry |

Target-path authoring per `PACKAGE_STAGING_LAYOUT.md`; no new files under legacy
`Code/Addons/lifepunch/bankerjob/` (per the S1 naming proposal).

## 5. Proven vs owed (eyes covered — no editor bridge this session)

**Proven (repo sensors):**
- Zero economy: no `ChargeHost`/`PayHost`/`WalletBalance`/`BankBalance`/inventory-API references in the diff (grep evidence in the round report).
- Validator parity: no new `validate-layout.ps1` errors vs the clean-develop baseline (8 pre-existing lpbitcoin/Monnow errors, ruled non-blocking).
- State machine and door logic are host-authoritative by construction (`Networking.IsHost`, `[Rpc.Host]`, `[Sync(SyncFlags.FromHost)]`), mirroring the proven `LpBitcoinHubEntity` idiom.

**Owed (editor proof — flatgrass, Law 5):**
- Compile proof of both components in the s&box editor.
- Prefab spawns; scale vs citizen; collider walk test; placeholder box renders (not watermelon).
- USE loop: OFF → BOOTING blink → RUNNING green → door toggle blue.
- Screenshot set + owner sign-off before any P0 advance.
