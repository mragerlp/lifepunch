# Hacker Ops Console (green / red)

**Addon:** `hackerjob` · **Not** lifepunchnet blue — see `reference/GOVERNMENT_DATABASE_TERMINAL_SPEC.md`

## UI families (LifePunch terminals)

| Family | Accent | Program | Layout | Addon |
|--------|--------|---------|--------|-------|
| **Ops Console** | Green `#00FF7F` / Red `#E4002B` | `cornerman.exe` / `vengeance.exe` | Large rail + module panes + command line | `hackerjob` |
| **HASHD rig** | Amber `#f0a500` | `hashd` | Telemetry rail + `rig0>` log | `bitcoinmining` |
| **lifepunchnet ops** | Cyan `#00D4FF` | `lifepunch-ops.exe` | Same *platform* (rail + modules) — **Phase 4** on `governmentdatacenter` | `governmentdatacenter` |

Hacker and police share the **ops-console platform shape** (not spl-mute CLI clone). Colors, programs, commands, and job gates stay separate per `TERMINAL_BRAND_MATRIX.md`.

## Hacker modules

| Module | Standard | Advanced | Purpose |
|--------|----------|----------|---------|
| LOG | ✓ | ✓ | Boot + command scrollback |
| SCAN | ✓ | ✓ | Wallet target table → `hack` |
| TARGET | ✓ | ✓ | Active puzzle + TTL |
| GOVDB | — | ✓ | Treasury node table → `infil` |
| HELP | ✓ | ✓ | Static command reference |

Commands still work at the bottom prompt (`cornerman@terminal:~$` / `vengeance@terminal:~$`).

## Dev smoke

```text
lp_cornerman_ui    # green ops console
lp_vengeance_ui    # red + govdb module
```

Blue police shell: `lp_lifepunch_ops_ui` — **not built yet** (`GOVERNMENT_DATABASE_SPEC.md` Phase 4).
