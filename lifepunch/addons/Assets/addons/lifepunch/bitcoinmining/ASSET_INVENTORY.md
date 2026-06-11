# Bitcoin Mining — asset inventory

**Intake scripts:** `addons/scripts/Reorganize-BitcoinMinerGpuRack.ps1`, `Intake-BitcoinTerminalAssets.ps1`

## Ship tree (publish)

| Slug | Entity name | Role | Source | vmdl |
|------|-------------|------|--------|------|
| `bitcoin-terminal` | **Bitcoin Terminal** | hashd control station (CRT prop) | `computer.fbx` | **Needs compile** — no `_c` yet → ERROR mesh |
| `gpu-rack` | **Bitcoin Miner** (small rack) | Remote mining hardware | `gpu-rack-static.obj` + `gpu-rack-anim.fbx` | **Shipped** |
| `gpu-rack-stacked` | **Advanced Bitcoin Miner** | Large stacked rack | `gpu-rack-stacked-anim.fbx` | **vmdl in repo** — compile in ModelDoc |

```text
models/lifepunch/bitcoinmining/
  gpu-rack/           ← small rack — gpu-rack/MODEL_BUILD.md
  bitcoin-terminal/   ← CRT — bitcoin-terminal/MODEL_BUILD.md
entities/
  bitcoin-terminal/   ← separate placeable (NOT child of miner)
  bitcoin-miner/      ← small rack only
  advanced-bitcoin-miner/  ← stacked rack prefab (AdvancedRack = 2× yield)
sounds/bitcoin-miner/
```

**Architecture:** `docs/reference/BITMINER_THREE_ENTITY_ARCH.md`

## Archives (not published)

| Path | Contents |
|------|----------|
| `C:/lifepunch/reference-intake/bitcoinmining/gpu-rack-export/` | Raw Blender GPU farm export |
| `C:/lifepunch/reference-intake/bitcoinmining/bitcoin-terminal-export/` | `computer.blend` + `computer.fbx` mirror |

## Code (repo)

| File | Role |
|------|------|
| `BitminerEntity.cs` | Economy, `IsMining`, terminal open |
| `BitminerTerminal.razor` | Phase 1 CLI; owner tabbed UI from Downloads bitcointerminal lane |

Spec: `addons/docs/BITMINER_UX_SPEC.md`
