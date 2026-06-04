# Bitcoin Mining Code

Clean code lane for the LifePunch Bitcoin Mining addon package (`lifepunch.bitcoinmining`).

Archetype: **interactive-entity** (`type: 0`, `primaryReference`, custom code).

## Files

- `Bitminer.cs` — package identity and mounted content paths (source of truth for the manifest content row).
- `BitminerEntity.cs` — the Bitminer S1 device component (mining sim, fan/sound cosmetics, terminal hook, upgrades, sell, self-destruct).
- `BitminerTerminal.razor` / `.razor.scss` — the in-world BitOS terminal UI.
- `docs/RUNTIME_PATTERN.md` — the DXRP integration seams and how the gamemode build re-wires them.

## Dual-build

Unlike the AK-47 (whose DXRP behavior lives in the prefab), the bitminer needs real
`Dxura.RP.Game` code. It uses a `LIFEPUNCH_LOCAL` compile symbol to build two ways from one
source:

- `#if LIFEPUNCH_LOCAL` — Sandbox-only stub that builds locally / in the S&box editor (the
  local `addons.csproj` has no `Dxura.RP.Game` reference).
- `#else` — the real `Dxura.RP.Game` implementation that **ships**; dxrp.net compiles it in the
  gamemode context where those types exist.

The symbol is defined in `Code/Directory.Build.targets`; publish staging never includes that
file, so the server compiles the real branch. See `docs/RUNTIME_PATTERN.md` for the full list
of branched touch-points and the build verification.

The `bitminer.prefab` itself still references DXRP components (`HealthComponent`,
`ContinuousSoundPoint`) and BaseEntity-serialized fields. That is expected and consistent with
how the AK-47 prefab uses DXRP `Equipment` components — prefabs resolve DXRP types from the
mounted package; only the C# code must stay decoupled.
