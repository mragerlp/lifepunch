# Hacker terminal — entity prefab build (Red / editor)

Build **two** prefabs from the bitminer entity pattern. Razor UI stays in code (`HackerTerminal.razor`) — the prefab is the **world CRT** + interact collider.

Paths (from `HackerJob.cs`):

| Tier | Prefab | Model |
|------|--------|-------|
| Standard | `entities/hacker-terminal/hacker-terminal.prefab` | `hacker-terminal.vmdl` |
| Advanced | `entities/advanced-hacker-terminal/advanced-hacker-terminal.prefab` | `advanced-hacker-terminal.vmdl` |

---

## Clone source

**File → Save As** from:

`addons/lifepunch/bitcoinmining/entities/bitcoin-miner/bitcoin-miner.prefab`

into each hackerjob entity folder above.

---

## Strip (remove components / children)

- `BitminerEntity` and all mining logic children
- `HealthComponent` (optional — keep if you want damageable terminals)
- GPU rack child mesh
- Mining UI hooks, power anim drivers, hashd-specific children

---

## Keep / add

| Component | Notes |
|-----------|-------|
| `Rigidbody` | Gravity on; mass ~50–80 |
| `BoxCollider` | Tune to CRT footprint (~20×14×24 class scale; adjust after mesh compile) |
| `ModelRenderer` | Model = tier `*.vmdl`; scale until ~desk height |
| `HackerTerminalEntity` | **Tier** = Standard or Advanced |
| `TextRenderer` (optional) | Wire to `HackerTerminalEntity.ScreenText` for idle `[ STANDBY ]` line |

**Tags:** `entity`, `hands_interact` (match bitminer interact pattern).

**NetworkMode:** networked entity (same as bitminer root).

---

## Dev smoke

```text
lp_spawn_hacker_terminal
lp_spawn_advanced_hacker_terminal
```

Stand within **6m**; use interact (or dev UI commands). Prefab missing → check compile + sync:

```powershell
powershell -File lifepunch/scripts/Sync-LifePunchAddonsToDxrp.ps1 -Addon hackerjob
```

---

## Advanced tier visuals

Same `computer.fbx` base mesh until a unique red CRT ships. ModelDoc: duplicate materials with Vengeance `#E4002B` accents per `TERMINAL_BRAND_MATRIX.md`.
