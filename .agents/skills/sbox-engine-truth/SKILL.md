---
name: sbox-engine-truth
description: s&box / Facepunch Source 2 C# engine discipline for this repo. Use for ANY C#, .cs, .razor, component, entity, panel, system, prefab, networking, [Sync], [Rpc], [Property], ConCmd, hotload or s&box API work — including one-line edits and "just add a field". s&box is NOT Unity and NOT GMod: its lifecycle, spawn/destroy, transform, and replication models differ, and stock reflexes (void Start, receiverless GetComponent, Physics.Raycast, SerializeField, StartCoroutine, Instantiate) produce code that will not compile or will silently fail to replicate. Derive every idiom from an in-tree exemplar before writing. Any API with no in-tree exemplar is FLAGGED in the report before use, never assumed.
---

# s&box engine truth — derive, never recall

> **Tracked ground truth: `lifepunch/docs/engine/SBOX_CONTEXT.md`.** Read it — it is the
> canon of record for the engine surface (architecture, networking, money/state, config
> layers, razor/SCSS, build-and-proof reality, golden examples). This skill is the trigger
> and the discipline; that document is the facts. On conflict, **the pinned fork wins over
> both**, and the disagreement earns a correction PR.

## LAW 0 — DERIVATION

**Before writing any component, panel, entity or system: open the nearest in-tree
exemplar and match its idioms.** Two trees are authoritative, in this order:

1. **Vanilla DXRP** — `lifepunchdxrp/game/Code/` (Dimmer's engine-native style)
2. **LIFEPUNCH house code** — `lifepunchaddons/Code/Addons/lifepunch/`

**Any API with NO in-tree exemplar is FLAGGED in the report before use.** Do not fill
it in from general s&box knowledge, from a vendor skill, or from memory. A flagged API
is a question for Bloodwave, not a decision for you.

When the tree's idiom disagrees with anything below, **the tree wins** — and say so,
because this file is then stale and needs a PR.

## LAW 0.5 — WHICH TREE ARE YOU IN? (ask before the first keystroke)

The two trees are **different repositories with different owners, headers and rules.**
Confusing them is the #1 costly mistake here.

| Path | Lane | Rules |
|---|---|---|
| `lifepunchdxrp/game/…` | **DXRP OFFICIAL** — Dimmer's IP | DXRP conventions only. **NO LIFEPUNCH headers, no `lp_*` ConCmds, no `lifepunch/` paths.** Contributions go through `C:\Users\jared\Projects\dxrp-public`, issue-first, PR to `dxura/dxrp`. |
| `lifepunchaddons/Code/…` | **LIFEPUNCH proprietary** | `PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co` header on every `.cs`/`.razor`/`.scss`. |

**A file under `lifepunchdxrp/game/` is not ours to restyle.** `PlanterEntity`, `DryRackEntity`,
`RollingTableEntity`, `DrugDrop`, `PrinterEntity`, `BaseEntity` and everything else there is
Dimmer's. Editing it is a **lane switch**, not a code change — stop and say so.

**Match the file you are in, not your habits.** Vanilla always supplies `NetFlags` on
`[Rpc.Broadcast]`; house code sometimes uses the bare form. Vanilla uses `IsProxy` and
`TimeUntil`; house code uses `Networking.IsHost` and `TimeSince`. Neither is "correct" in the
abstract. Lane bible: `lifepunch/docs/DXRP_CONTRIBUTOR_LANE.md`.

## NEVER / ALWAYS

Every row was verified against the tree. The `file:line` **is** the authority.

| NEVER (Unity / GMod reflex) | ALWAYS (this tree) | Exemplar |
|---|---|---|
| `void Start()` as a lifecycle hook | `protected override void OnStart()` | `lifepunchdxrp/game/Code/Player/Player.cs:18` · `…/lifepunch/advanceddrugprocessing/MethLabEntity.cs:44` |
| receiverless `GetComponent<T>()` | scope it: `go.GetComponent<T>()`, or prefer `Components.Get<T>()` | `…/Entity/BaseEntity.cs:148` · `…/Sporting/BasketballEntity.cs:52` |
| `Physics.Raycast` | `Scene.Trace.Ray( from, to )` | `…/Sporting/BasketballEntity.cs:240` |
| `[SerializeField]` | `[Property]` | `…/World/WorldSpawn.cs:22` · `…/MethLabEntity.cs:30` |
| `StartCoroutine` | `TimeSince` / `TimeUntil` fields, ticked in `OnUpdate`/`OnFixedUpdate` | `…/World/Recycler.cs:24` · `…/MethLabEntity.cs:41` |
| `Instantiate(prefab)` / `new GameObject` **in house code** | `prefab.Clone( … )` | `…/lifepunch/LifePunchMachineDestroyFx.cs:46` · `…/MethLabDevSpawn.cs:111` |
| static `Destroy(obj)` | `GameObject.Destroy()` | `…/Construct/BaseConstruct.cs:89` · `…/LpBitcoinCashRedeemEntity.cs:81` |
| `transform.position` | `WorldPosition` · `LocalPosition` · `WorldTransform` | `…/World/Bin.cs:12` · `…/MethLabDevSpawn.cs:128` |
| bare `[Sync]` in LIFEPUNCH code | `[Sync( SyncFlags.FromHost )]`, declared | `…/bitcoinmining/LpBitcoinRackEntity.cs:39` |
| improvised RPC attributes | declared only: `[Rpc.Host]` · `[Rpc.Broadcast]` · `[Rpc.Owner]` | `…/GameManager.cs:213` · `…/hackerjob/HackerServerRackEntity.cs:126` · `…/Entity/BaseEntity.cs:159` |
| guessing a console-command form | `[ConCmd( "lp_name" )]` | `…/lpbitcoin/bitcoinhub/code/components/LpBitcoinDevSpawn.cs:25` |

Lifecycle signature is **always** `protected override void OnX()` — `OnAwake`, `OnStart`,
`OnUpdate`, `OnFixedUpdate`, `OnEnabled`, `OnDisabled`, `OnDestroy`. No parameters.

**Anchor to structure, not to a word.** `BaseEvent.cs:48` declares `public void Start()` —
a plain domain method on a non-Component class, not a lifecycle hook. A grep for
`void Start()` false-positives on it. Match `class X : Component` **plus** the `override`.

## FLAGGED — no in-tree exemplar. Report before use.

Absent from **LIFEPUNCH** house code (present in vanilla DXRP, so *usable* — but say so
first): `IsProxy` (`…/ToolEquipment.cs:16`), `Network.TakeOwnership`, `NetworkMode`,
`new GameObject`, `DestroyImmediate`, bare `[Sync]`, `[Rpc.Owner]`, `TimeUntil`.

Absent from **both** trees — no exemplar anywhere, treat as unproven:
`INetworkSpawn`, `[Button]`, `Physics.Raycast`, `[SerializeField]`, `StartCoroutine`.

## HOST AUTHORITY, AND WHAT `[Sync]` DOES NOT PROVE

Gameplay state is **host-authoritative**. Gate mutations on `Networking.IsHost`
(`…/MethLabEntity.cs:52`); LIFEPUNCH house code gates on that, not on `IsProxy`.

> **`[Sync]` is UNPROVEN until it is observed on a second client.**

A declaration is not an observation. `SyncFlags.FromHost` replicates host→all clients *by
declaration*; whether a given property actually lands on a **non-owner's** screen is a
measurement, and a host-side assertion cannot make it — the bug *is* host/client
disagreement, so a host-only sensor reads the wrong side by definition.

Read before touching any replicated property:
`lifepunch/docs/handoff/NONOWNER_CLIENT_READ_SURFACE_2026-07-10.md` ·
`lifepunch/docs/handoff/GATE_ADVANCEDRACK_SYNC_TWO_CLIENT.md`

Replication patterns and exact syntax: **[references/networking.md](references/networking.md)**.

## COMPILE IS THE ONLY TRUTH

The Sensor Law (`lifepunch/docs/PROOF_ENVIRONMENT_DOCTRINE.md`) applied to hotload:

**A clean-looking compile proves only that *recent* bytes compiled.** To prove the compiler
read **your** bytes, you need two facts, not one:

1. the compile/parser log timestamp **postdates** your file write, **and**
2. a **positive code-string ID** — a string that exists nowhere except your edit appears
   in the log or tool result.

**A behavioral change only the new code could produce is itself a positive ID.** If the old
code provably could not do X, then observing X identifies the new assembly. Where no sensor
reads the thing under test, **build one** — plant a `Log.Info` whose text exists only in this
version (`Log.Info` · `Log.Warning` · `Log.Error` are all in-tree).

**The editor compiles a hand-synced copy, not this repo.** Editing here and hotloading
without syncing gives a FALSE all-clear. See the `lifepunch-editor-gate` skill.

## Harvested and REJECTED — two claims that are false for this tree

External s&box skill packs assert both. Both were tested and both fail here. **In-tree
confirmation overrides any vendor claim.**

- **"`MathF` is not available in the sandbox."** FALSE — **98 call sites** across both trees,
  e.g. `…/bitcoinmining/LpBitcoinEconomy.cs:45` (`MathF.Max`), `…/GameManager.cs:294`
  (`MathF.Ceiling`). `Math.` and `System.Math.` are also used.
- **"`GetComponent<T>()` is a Unity pattern — don't use it."** FALSE as stated — it is used
  in **69 files**, always with a receiver (`go.GetComponent<T>()`). What does not exist is
  Unity's *receiverless* call. The precise rule is in the table above.

## Report contract

Label every claim: `VERIFIED FROM REPO` (with file:line) · `INFERRED FROM PATTERNS` ·
`NEEDS SBOX-EDITOR PROOF` · `NEEDS SBOX RUNTIME PROOF` · `OWNER DECISION REQUIRED` ·
`OUT OF SCOPE`. High-stakes surfaces — economy, persistence, `[Sync(FromHost)]`, RPCs,
purchase routing, migration, power/link state machines — need a plan first and Bloodwave GO.
