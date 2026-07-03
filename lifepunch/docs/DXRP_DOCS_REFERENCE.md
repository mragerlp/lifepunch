# DXRP Docs Reference

This file tracks public DXRP documentation that affects LifePunch planning and implementation.

Observed docs site:

```text
https://docs.dxrp.net/
```

Observed public addon browser:

```text
https://dxrp.net/addons
```

Observed published addon example:

```text
https://dxrp.net/addons/019e4013-08a5-77d0-975c-df132345045e
```

Use public addon pages as examples for the finished publish presentation: detail page, metadata, `Add to Server`, content rows, and Code Explorer. Implementation details still need confirmation from source code or trusted DXRP references before copying patterns.

Observed DXRP source-available repository:

```text
https://github.com/dxura/dxrp/tree/develop
```

Observed DXRP game project root:

```text
https://github.com/dxura/dxrp/tree/develop/game
```

Observed page heading:

```text
DXRP Docs
```

Observed intro:

```text
Welcome to the DXRP documentation, here you'll get an information on various aspects of the game/platform.
```

## Navigation

Observed sidebar sections:

- Developer
  - `TODO`
- Operator
  - `Launching Server with Addons`
- Player
  - `Quickstart`

Observed on-page links:

- `Community Server Guide`
  - `https://github.com/dxura/dxrp-public/wiki/Operator`
- `Launching Server with Addons`

## LifePunch Relevance

The Operator docs are directly relevant to:

- `lifepunch/server` — **canon runbook:** `lifepunch/server/LAUNCHING_SERVER_WITH_ADDONS.md`
- `lifepunchaddons`
- `lifepunch/gamemode`

Both hosted LifePunch servers (`lifepunchmainserver`, `lifepunchdevelopment`) must use **`dotnet run dxrp-server.cs`** per [Launching Server with Addons](https://docs.dxrp.net/launching-server-with-addons). Portal token drives `GET /v1/server/addons` on every startup.

The DXRP `develop` repository is source-available, not open source. Treat it as a compatibility and contribution reference, not as material to copy into LifePunch. Any official-project improvements should be small, original, and submitted only through Dxura-approved contribution channels.

Official `game/` layout observed:

```text
game/
  Assets/
  Code/
  Editor/
  Libraries/
  Localization/
  ProjectSettings/
  Sources/
  rp.sbproj
  rp.slnx
```

Relevant `game/Code/` areas:

- `Addons/`: addon service registration and official addon code.
- `Config/`: partial `GameConfig` files split by domain.
- `Equipment/`: equipment, viewmodel, weapon components, ammo, reload, recoil, shooting, scope, and dropped equipment.
- `Player/`: partial player implementation, including equipment ownership and `GiveHost` runtime spawning.
- `UI/`, `System/`, `World/`, `Entity/`, `Chat/`, `Api/`: core game systems.

Relevant `game/Assets/` areas:

- `addons/official/<ident>/`: official addon assets.
- `models/`, `materials/`, `prefabs/`, `scenes/`, `sounds/`, `ui/`, `gameplay/`, `decals/`, `shaders/`: main game assets.

Addon/runtime observations from `develop`:

- `AddonServiceRegistry` discovers classes with `AddonServiceAttribute` and attaches one service component per type to the `GameManager` root.
- `Player.GiveHost` resolves a `GameModeEquipmentDto`, loads `resource.PrefabPath()` with `GameObject.GetPrefab`, clones the prefab under the player's equipment holder, sets `Identifier`, and network-spawns it.
- `Equipment.CreateViewModel` uses a prefab-assigned `ViewModelPrefab` when present, otherwise falls back to `resource.SecondaryPrefabPath()`.
- Equipment resource paths are therefore critical: primary prefab drives world/equipment spawn, secondary prefab drives viewmodel fallback, and missing paths produce useful log errors.
- The official server launcher clears `game/Code/Addons` and `game/Assets/addons`, downloads addon packages into `<networkIdentifier>/<addonIdentifier>`, and can build `game/Code/rp.csproj` to verify addons.

LifePunch structure implications:

- Keep LifePunch addon package source aligned with DXRP's mounted layout: `Assets/addons/lifepunch/<ident>/` and `Code/Addons/lifepunch/<ident>/`.
- Keep gamemode equipment/content/market records separate from addon source, because official runtime resolves `GameModeEquipmentDto` fields rather than scanning LifePunch docs.
- Keep project settings and S&box project metadata portable where possible; official generated project files may contain local S&box paths, but LifePunch should avoid tracking owner-machine-specific paths.
- Future upstream PR candidates should be infrastructure-safe: docs fixes, validation improvements, clearer addon/runtime diagnostics, and small compatibility patches with an approved issue or accepted channel.

## Upstream Contribution Pattern

Observed public DXRP contribution examples:

- `PikPakPik/dxrp-public` is a fork used to submit PRs into `dxura/dxrp`.
- Early PikPakPik PRs targeted `main`, for example:
  - `#11` `Improve translation prompt...`, merged 2025-11-29, one commit, base `main`.
  - `#19` `fix(wire): Equal gate...`, merged 2026-05-17, one commit, base `main`.
- Current PikPakPik PRs target `develop`, for example:
  - `#32` `fix(gag): prevent sanctioning players with higher ranks`, merged by `dimmerly`, three commits, base `develop`.
  - `#35` `Fix : freeze status allowing movement`, merged by `dimmerly`, one commit, base `develop`.
- DXRP maintainers then merge `develop` into `main` separately when ready.

LifePunch upstream workflow should follow this shape:

1. Keep LifePunch private work separate from DXRP source.
2. When a change is useful to official DXRP, isolate only the original, general-purpose fix.
3. Open or reference an issue first for non-trivial changes.
4. Branch from DXRP `develop`, not LifePunch `main`.
5. Keep PRs small, conflict-free, and scoped to one DXRP concern.
6. Do not include LifePunch branding, private server config, addon assets, secrets, or community-specific policy.
7. In the PR body, explain the bug/need, the exact fix, and the local verification.

## LifePunch to DXRP Fork Bridge

Use two repositories locally:

- The LifePunch private checkout remains the server/community workspace.
- The DXRP public fork checkout remains the upstream-contribution workspace.

The fork checkout is wired as:

- `origin`: `https://github.com/mragerlp/dxrp-public.git`
- `upstream`: `https://github.com/dxura/dxrp.git`
- default branch: `develop`

Do not add `dxura/dxrp` as a remote inside the LifePunch repository. The repositories have different histories and different disclosure rules.

Recommended sync loop:

1. Pull official DXRP changes into the fork checkout: `lifepunch\scripts\sync-dxrp-fork.ps1`.
2. Push the updated fork when ready: `lifepunch\scripts\sync-dxrp-fork.ps1 -PushOrigin`.
3. Create upstreamable work from the fork checkout with a branch like `lifepunch/fix-addon-path-resolution`.
4. Copy or reimplement only the general DXRP change from LifePunch notes into that branch.
5. Keep LifePunch addon assets, private gamemode configuration, portal exports, staff policy, and server-specific docs out of the DXRP fork.
6. Open PRs from `mragerlp/dxrp-public:<branch>` to `dxura/dxrp:develop`.

## Confirmation Needed

- Whether Developer docs expand beyond `TODO`.
- Whether docs include official addon package/content row rules beyond portal UI.
- Whether API behavior is documented under a separate page or only in portal UI.
- Whether public pull requests are currently enabled and what Dxura's preferred issue/PR workflow is for infrastructure contributions.

## Launching Server with Addons (confirmed 2026-06-29)

Upstream: https://docs.dxrp.net/launching-server-with-addons

**Prerequisites:** .NET 10 SDK, Git, `sbox-server.dll`, `dxrp-server.cs` in same folder.

**Launch:** `dotnet run dxrp-server.cs --token YOUR_TOKEN`

**Each startup:**

1. Pull latest DXRP from GitHub (`repoUrl` / `branch` in config)
2. Fetch addons from `apiEndpoint` for the server token
3. Clear and re-download addon files
4. Build / optional verify (`verifyAddons`)
5. Launch server; auto-restart on stop

**Config keys:** `token`, `repoUrl`, `branch`, `apiEndpoint`, `map`, `extraArgs`, `verifyAddons`

LifePunch mapping: `lifepunch/server/LAUNCHING_SERVER_WITH_ADDONS.md`
