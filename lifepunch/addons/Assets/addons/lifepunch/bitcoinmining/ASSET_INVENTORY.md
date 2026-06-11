# Bitcoin Mining — asset inventory

**Intake scripts:** `addons/scripts/Reorganize-BitcoinMinerGpuRack.ps1`, `Intake-BitcoinTerminalAssets.ps1`

## Ship tree (publish)

| Slug | Role | Source | vmdl |
|------|------|--------|------|
| `gpu-rack` | World mining rack mesh + power anim | `gpu-rack-static.obj` + `gpu-rack-anim.fbx` | TODO |
| `bitcoin-terminal` | CRT / computer prop on rig | `computer.fbx` | TODO |

```text
models/lifepunch/bitcoinmining/
  gpu-rack/           ← see gpu-rack/MODEL_BUILD.md
  bitcoin-terminal/   ← see bitcoin-terminal/MODEL_BUILD.md
entities/bitcoin-miner/
sounds/bitcoin-miner/
```

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
