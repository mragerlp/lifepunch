# Hacker terminal — entity prefab build (Red / editor)

**Prefabs shipped** under `entities/hacker-terminal/` and `entities/advanced-hacker-terminal/` (cloned from bitcoin-terminal pattern). Razor UI stays in code (`HackerTerminal.razor`) — the prefab is the **world CRT** + interact collider + `lcd_screen`.

Paths (from `HackerJob.cs`):

| Tier | Prefab | Model |
|------|--------|-------|
| Standard | `entities/hacker-terminal/hacker-terminal.prefab` | `hacker-terminal.vmdl` |
| Advanced CRT | `entities/advanced-hacker-terminal/advanced-hacker-terminal.prefab` | `advanced-hacker-terminal.vmdl` |
| Basic rack | `entities/server-rack/server-rack.prefab` | `server-rack.vmdl` |
| Advanced rack | `entities/advanced-server-rack/advanced-server-rack.prefab` | `advanced-server-rack.vmdl` |

---

## Owner tune (after ModelDoc compile)

---

## Prefab contents

| Component | Notes |
|-----------|-------|
| `Rigidbody` | Gravity on; mass ~50–80 |
| `BoxCollider` | Tune to CRT footprint (~20×14×24 class scale; adjust after mesh compile) |
| `ModelRenderer` | Model = tier `*.vmdl`; scale until ~desk height |
| `HackerTerminalEntity` | **Tier** = Standard or Advanced |
| `TextRenderer` (optional) | Wire to `HackerTerminalEntity.ScreenText` for idle `[ STANDBY ]` line |

**Tags:** `entity`, `hands_interact` (match bitcoinmining interact pattern).

**NetworkMode:** networked entity (same as bitcoinmining root).

---

## Dev smoke

```text
lp_cornerman_preview
lp_vengeance_preview
lp_spawn_hacker_terminal
lp_spawn_advanced_hacker_terminal
lp_spawn_server_rack
lp_spawn_advanced_server_rack
lp_hacker_kit_preview
```

Stand within **6m**; use interact (or dev UI commands). Prefab missing → check compile + sync:

```powershell
powershell -File lifepunch/scripts/Sync-LifePunchAddonsToDxrp.ps1 -Addon hackerjob
```

---

## Advanced tier visuals

Owner `computer.fbx` intaken to `advanced-hacker-terminal/source/hacker-terminal.fbx`. ModelDoc: map materials with Vengeance `#E4002B` accents per `TERMINAL_BRAND_MATRIX.md`.
