# Hacker Ops Console (green / red)

**Addon:** `hackerjob` · **Not** lifepunchnet blue — see `reference/GOVERNMENT_DATABASE_TERMINAL_SPEC.md`

## UI families (LifePunch terminals)

| Family | Accent | Program | Layout | Addon |
|--------|--------|---------|--------|-------|
| **Ops Console** | Green `#00FF7F` / Red `#E4002B` | `cornerman.exe` / `vengeance.exe` | Cyber shell — home grid + module screens (`CYBER_TERMINAL_SHELL_SPEC.md`) | `hackerjob` |
| **HASHD rig** | Amber `#f0a500` | `hashd` | Telemetry rail + `rig0>` log | `bitcoinmining` |
| **lifepunchnet ops** | Cyan `#00D4FF` | `lifepunch-ops.exe` | Same *platform* (rail + modules) — **Phase 4** on `governmentdatacenter` | `governmentdatacenter` |

Hacker and police share the **ops-console platform shape** (LifePunch-owned rail + modules — not a copied legacy GMod admin CLI). Colors, programs, commands, and job gates stay separate per `TERMINAL_BRAND_MATRIX.md`.

## Hacker (Cyber shell — green / red)

`HackerTerminal.razor` uses the shared **Cyber terminal shell** (`LifePunchCyberTerminal.scss`): home 2×2 module grid, full-screen TERMINAL / NETWORK / DECRYPT / DASHBOARD, header status row, footer log. Layout reference: [Cyber Hacker Simulator](https://apps.microsoft.com/detail/9nvc5p0bphgr).

| Tier | Accent | Brand slug |
|------|--------|------------|
| Standard (Cornerman) | `#00FF7F` | `CORNERMAN` |
| Advanced (VENGEANCE) | `#E4002B` | `VENGEANCE` |

**Dev smoke:**

```text
lp_cornerman_ui    # green cyber shell
lp_vengeance_ui    # red + govdb in NETWORK
```

Legacy rail layout preserved in git history; green sidebar CRT markup reference: `addons/docs/branding/reference/HackerOpsCrtPanel.razor`

---

Blue police shell: `lp_lifepunch_ops_ui` — **not built yet** (`GOVERNMENT_DATABASE_SPEC.md` Phase 4).
