# Bitcoin Miner — Runtime pattern

Original LIFEPUNCH implementation — `addons/docs/BITMINER_IP_DOCTRINE.md`. Ship LifePunch-owned assets + proprietary code only.

The **Bitcoin Miner** is a code-driven interactive entity (mining payouts, upgrades, LIFEPUNCH hashd terminal).

## Asset split

| Layer | Slug | Path |
|-------|------|------|
| Entity | `gpu-rack` | `entities/gpu-rack/gpu-rack.prefab` |
| World mesh | `gpu-rack` | `models/lifepunch/bitcoinmining/gpu-rack/gpu-rack.vmdl` |
| Sounds | `bitcoin-miner` | `sounds/bitcoin-miner/*.sound` |

- World model: `addons/lifepunch/bitcoinmining/models/lifepunch/bitcoinmining/gpu-rack/gpu-rack.vmdl`
- Model tree: `gpu-rack/` (`source/`, `textures/{cord,psu,rack,motherboard,gpu}/`, `material-map.json`)
- Raw export archive (not published): `C:/lifepunch/reference-intake/bitcoinmining/gpu-rack-export/`

Reorganize script: `addons/scripts/Reorganize-BitcoinMinerGpuRack.ps1`

## Terminal (Phase 1 — Cornerman)

- **Open:** `[ConCmd("hashd")]` / `[ConCmd("mine")]` → nearest `BitminerEntity` within 8m → `BitminerTerminal.Open`
- **Close:** `hashd close` / `mine close` / ✕ button / walk >150m
- **Inside:** HASHD CLI (`help`, `mining`, `bitcoin`, `upgrade`, …); `menu` stubs tabbed UI (Phase 2)
- **Pattern:** `BitminerTerminalHost` dual-build mount (same as StaffMenu / other LifePunch terminals)

Task brief: `addons/docs/briefs/CORNERMAN_BITMINER_TERMINAL_TASK.md`

### Phase 1 source files

| File | Role |
|------|------|
| `BitminerCommandHost.cs` | `[ConCmd("hashd")]` / `[ConCmd("mine")]` — nearest rig within 8m / 4m; `close` subcommand |
| `BitminerTerminalHost.cs` | `#if LIFEPUNCH_LOCAL` mount vs `GameManager.ShowUi`; viewer position for range |
| `BitminerEntity.cs` | Synced mining state, RPCs, optional `IPressable` secondary open |
| `BitminerTerminal.razor` | Define-free CLI; all gamemode coupling via host helpers |
