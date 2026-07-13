# Networking — replication patterns, harvested from in-tree usage

Every syntax form below was read out of the tree. Counts are whole-tree
(`lifepunchdxrp/game/Code` + `lifepunchaddons/Code/Addons/lifepunch`).

---

## 1. Replicated property — the LIFEPUNCH combo

```csharp
[Property, ReadOnly] [Sync( SyncFlags.FromHost )] public Guid LinkedHubId { get; set; }
```

`lifepunchaddons/Code/Addons/lifepunch/bitcoinmining/LpBitcoinRackEntity.cs:39`

The full sibling set on that entity — the shape to copy — is `:39` `LinkedHubId`,
`:45` `AssignedSlotToken`, `:46` `IsMining`, `:47` `BitcoinAmount`, `:48` `ClockGhz`,
`:49` `CoreCount`, `:50` `MiningProgress`, `:55` `ComputeTier`.

- `[Property]` — editor-inspectable. `[SerializeField]` does not exist here.
- `[ReadOnly]` — governs the **inspector**, not code assignment. Confirm against the
  current API with `describe_type` before relying on it; the API drifts between SDK
  versions, and reflection is the source of truth, not training data.
- `[Sync( SyncFlags.FromHost )]` — host→**all clients**, not owner-scoped.

**Bare `[Sync]` (no flags) exists in vanilla DXRP** —
`lifepunchdxrp/game/Code/Equipment/Equipments/Default/BuildEquipment.cs:24` — and has
**no exemplar in LIFEPUNCH**. Always specify the flag in house code.

### The failure this pattern prevents

A `[Property]` **without** `[Sync]` on an entity whose siblings all carry it is a **truth
bug**, not an authority bug. Authority asks *may I act on this?* and is already correct.
Truth asks *what am I even looking at?* — two players look at the same object and disagree.
Derived members compound it: if `AdvancedRack` does not replicate, then `YieldMultiplier`
(`LpBitcoinRackEntity.cs:58`) and `DisplayName` (`:65`) are wrong on every non-owner client.

Live case, still open: `LpBitcoinRackEntity.cs:32` —
`[Property] public bool AdvancedRack { get; set; }` — no `[Sync]`, unlike all eight siblings.
See `lifepunch/docs/handoff/GATE_ADVANCEDRACK_SYNC_TWO_CLIENT.md`.

## 2. Host gate

```csharp
if ( Networking.IsHost ) { … }
```

`lifepunchaddons/Code/Addons/lifepunch/advanceddrugprocessing/MethLabEntity.cs:52` ·
`lifepunchdxrp/game/Code/GameNetworkManager.cs:220`

House code gates on `Networking.IsHost`. `IsProxy` is a **vanilla-only** idiom
(`lifepunchdxrp/game/Code/Equipment/Equipments/Default/ToolEquipment.cs:16`) with **no
LIFEPUNCH exemplar** — flag before introducing it.

Also present in vanilla: `Networking.IsClient` (`GameNetworkManager.cs:101`).

## 3. Network spawn

```csharp
explosion.NetworkSpawn();                       // LifePunchMachineDestroyFx.cs:47
lab.NetworkSpawn( player.Network.Owner );       // MethLabDevSpawn.cs:49
playerGameObject.NetworkSpawn( channel );       // dxrp GameNetworkManager.cs:370
```

**Order matters.** Set host-assigned properties **after** `Clone` and **before**
`NetworkSpawn` — a value assigned after the spawn may never reach clients. The suspect
path in this repo does exactly that: `LpBitcoinDevSpawn.cs:1628` sets
`rack.AdvancedRack = stacked;` between `ClonePrefabAt` and `NetworkSpawnIfNeeded`.

**Prefab-borne values ship with the network spawn.** A value serialised into the prefab
may look replicated when it is merely *seeded*. That is why the two-client gate
distinguishes prefab-spawned racks (C1/C2) from runtime-assigned ones (**C3**), and why
C4 — a live update with **no rejoin** — is the only case that proves replication rather
than seeding.

## 4. Ownership

`gameObject.Network.AssignOwnership( caller )` — `lifepunchdxrp/game/Code/GameManager.cs:258`
`GameObject.Network.TakeOwnership()` — `…/Sporting/SoccerBallEntity.cs:42`

Both are **vanilla-only**; neither has a LIFEPUNCH exemplar. Bitcoin entities spawn owned by
Steam ID via the DXRP market — **`lpbitcoin` does not wire ownership.** `CanManageHub(callerId)`,
`LinkedHubId` and `AssignedSlotToken` all *presume* an ownership relation DXRP already
established. Do not re-implement it. See
`lifepunch/docs/handoff/NONOWNER_CLIENT_READ_SURFACE_2026-07-10.md`.

## 5. RPCs — declared, never improvised

Three forms exist in the trees. Nothing else does.

| Attribute | Count | Exemplar |
|---|---|---|
| `[Rpc.Host]` | 228 | `lifepunchdxrp/game/Code/GameManager.cs:213` · `…/lifepunch/adminmenu/StaffMenuBridgeService.cs:34` |
| `[Rpc.Broadcast]` | 119 | `…/lifepunch/hackerjob/HackerServerRackEntity.cs:126` (bare) |
| `[Rpc.Owner]` | 14 | `lifepunchdxrp/game/Code/Entity/BaseEntity.cs:159` — **vanilla only** |

With flags:

```csharp
[Rpc.Broadcast( NetFlags.HostOnly | NetFlags.Reliable )]      // dxrp GameManager.cs:544
[Rpc.Owner( NetFlags.HostOnly | NetFlags.Reliable )]          // dxrp BaseEntity.cs:159
```

**Vanilla DXRP always supplies `NetFlags` on `[Rpc.Broadcast]`; LIFEPUNCH sometimes uses the
bare form** (`HackerServerRackEntity.cs:126`). When editing vanilla, match vanilla. When
editing house code, match the file you are in.

## 6. Interfaces

`INetworkListener` — `lifepunchdxrp/game/Code/GameNetworkManager.cs:12` (2 files).
`INetworkSpawn` — **NO IN-TREE EXEMPLAR** in either tree. Flag before use.

## 7. The gate a replicated property owes

Nothing that touches replication is done until a **second client** has seen it. The
acceptance shape, from `GATE_ADVANCEDRACK_SYNC_TWO_CLIENT.md`:

```
A    pre-fix behaviour recorded — the fix is proven NEEDED before it is applied
B    [Sync] applied; [ReadOnly] verified against the current API, not memory
C3   runtime-assigned value — host == client        <- the actual bug
C4   live update, no rejoin — client repaints       <- proves replication, not seeding
```

C3 and C4 must be read **from the non-owner's screen**. A green on C1/C2 alone proves only
that prefab data ships, which was never in doubt.
