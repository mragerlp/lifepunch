# Bitminer Runtime Pattern

The Bitminer S1 is a genuinely code-driven interactive entity (mining payouts, charging for
upgrades, permission checks, the BitOS terminal). The AK-47's "decoupled C# + prefab does the
DXRP work" pattern does **not** cover it, because that logic only exists in code that needs
`Dxura.RP.Game`.

## Dual-build

The local shared `addons.csproj` references only the Sandbox engine DLLs — `Dxura.RP.Game` is
not compile-available. dxrp.net, however, compiles uploaded addon code **inside the gamemode
context**, where `Dxura.RP.Game` *is* available.

To satisfy both, the bitminer code is a single source with two branches selected by the
`LIFEPUNCH_LOCAL` compile symbol:

```csharp
#if LIFEPUNCH_LOCAL
    // compile-safe Sandbox-only stub — local + S&box editor build
#else
    // real Dxura.RP.Game implementation — dxrp.net gamemode-context build (this is what SHIPS)
#endif
```

- `LIFEPUNCH_LOCAL` is defined by `Code/Directory.Build.targets` (and `addons.csproj`). It is
  imported via `Directory.Build.targets` so it survives S&box regenerating `addons.csproj`.
- The publish staging copies **only** `Code/Addons/lifepunch/bitcoinmining/*` — never the
  targets file — so dxrp.net does **not** define the symbol and compiles the real branch.

All simulation, networked `[Sync]` state, fan/sound cosmetics, screen text, interaction, RPCs,
and the full terminal UI/command parser are **shared** (outside any `#if`). Only the
gamemode-coupled touch-points are branched.

## Branched touch-points

`BitminerEntity.cs`:

| Concern | `#if LIFEPUNCH_LOCAL` (local) | `#else` (ships to dxrp.net) |
| --- | --- | --- |
| base class | `Component` | `BaseEntity`, `+ IGameEvents, IAreaDamageReceiver` |
| per-second tick | `OnUpdate` host-gated | `IGameEvents.OnSecondlyUpdate` |
| occlusion | none (`_occluded` stays false) | `OnOcclusionChanged` + `GameManager.IsHeadless` |
| pocket tags | `"pocket"` / `"pocket_item"` literals | `Constants.PocketTag` / `Constants.PocketItemTag` |
| interact permission | open (no checks) | `GameUtils.HasPermission` + `player.CantSwitch` |
| sell payout | stub returns `true` | `player.PayHost( value, reason )` |
| upgrade charge | stub returns `true` | `player.ChargeHost( cost, reason )` |
| self-destruct sounds | `Sound.Play` (local) | `SoundEvent.Broadcast(...)` |
| explosion damage | visual only | `AreaDamage` (60 dmg, Explosion) + `IAreaDamageReceiver` |
| destroy hook | `OnDestroy()` | `OnDestroyed()` + `base.OnDestroyed()` |

`BitminerTerminal.razor`:

| Concern | local | ships |
| --- | --- | --- |
| mount | `ScreenPanel` object | `GameManager.ShowUi<BitminerTerminal>()` |
| close | destroy host object | `Destroy()` the component |
| auto-close distance | scene `CameraComponent` | `Player.Local` |

## Verification done

- **Local branch** (`LIFEPUNCH_LOCAL` defined): `dotnet build addons.csproj` → **0 errors**.
- **Ship branch** (symbol removed): builds with **only** missing-type errors for the expected
  DXRP symbols (`BaseEntity`, `IGameEvents`, `AreaDamage`, `Dxura`, …) and the cascading
  `SB2000` generator errors — **no C# syntax errors**. So the branch is structurally sound and
  is expected to compile on dxrp.net where those types exist.
- **Not yet verified**: the real DXRP branch actually running on the dev server. That is the
  remaining test (publish revision → pin on the LifePunch gamemode → sync dev server only).

## Tuning reference

- Mining rate: `0.005 BTC` * clock * cores, paid every `60s`. Bitcoin value: `$1500`/BTC.
- CPU upgrades: 2k/4k/8k/16k/32k/64k/128k (+1.5 GHz each). Cores: 50k/100k/175k (+2 each).
- Start: `2.44 GHz`, `1` core.

## Asset note

`bitminer.vmdl` imports `source/bitminer.fbx` (present) but uses `use_global_default = true`
(`materials/default.vmat`), so it spawns grey/untextured until per-mesh materials are authored.
