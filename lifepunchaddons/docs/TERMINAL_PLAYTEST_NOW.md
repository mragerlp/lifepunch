# Terminal playtest — run this now (Bloodwave)

> **MCP screenshots often miss screen-space HUD panels.** Trust your **live monitor** for
> `lp_cornerman_ui` / hashd GATEKEEPER — log lines below confirm the UI mounted even when
> `take_screenshot` shows only the 3D world.

## 0. Fresh compile (required after SCSS fixes)

In s&box editor: **Stop play → Play** once. Then run commands from the in-game **developer** `>` bar (staff only — not player gameplay).

## 1. Bitcoin miner (hashd) — PIN gate

```text
lp_map_flatgrass
lp_hashd_pin_preview setup
```

**You should see (bottom-right HUD):** amber panel titled **GATEKEEPER** · **SET PIN** · click CTA → numpad.

**World USE path (real playtest):**

```text
lp_spawn_bitcoin_miner_hub
```

Walk to hub → **USE** → same GATEKEEPER flow (not blocked if you spawned it).

**If body is empty / title only:** SCSS class-root bug — confirm `HashdTerminal.razor.scss` uses `.hashd-terminal` and repo is synced (`Sync-LifePunchAddonsToDxrp.ps1 -Addon bitcoinmining`).

**Console debug (no MCP execute_csharp):**

```text
lp_bitcoinmining_debug
```

Logs hub owner, linked racks, hashd UI mount state, and rig range checks.

## 2. Hacker (cornerman.exe)

```text
lp_map_flatgrass
lp_cornerman_ui
```

**You should see:** fullscreen green ops console · prompt `cornerman@terminal:~$` · log line:
`[cornerman.exe] logged in`.

**World + CRT:**

```text
lp_hacker_kit_preview
```

Spawns rack + CRT; walk to CRT → **USE** (rack should be powered in kit preview).

**Advanced (red):** `lp_vengeance_ui` or `lp_vengeance_preview`

## 3. Log grep (no `not valid with`)

```powershell
Select-String -Path "D:\Steam\steamapps\common\sbox\logs\sbox-dev.log" -Pattern "not valid with|error CS" | Select-Object -Last 20
```

## 4. What we verified via MCP (2026-06-14 ~01:05)

| Command | Log evidence | Screenshot |
|---------|--------------|------------|
| `lp_hashd_pin_preview setup` | `GATEKEEPER SET PIN` | 3D world only — HUD not in high-res capture |
| `lp_cornerman_ui` | `cornerman.exe logged in` | Same — UI is screen-space |

**Your eyes on the monitor are the acceptance test.**
