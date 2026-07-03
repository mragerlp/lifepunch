# Hacker terminal session doctrine

**Owner canon (2026-06).** Agents and playtest docs must not drift from this. Parent: `addons/docs/PHYSICAL_TERMINAL_DOCTRINE.md`.

## What “terminal” means

If we say **terminal**, we mean a **placeable entity with a program UI attached**:

| Entity name | Program UI | Accent |
|-------------|------------|--------|
| **Hacker Terminal** | `cornerman.exe` (Cornerman) | Green |
| **Advanced Hacking Terminal** | `vengeance.exe` (VENGEANCE) | Red |
| **Government / Police Terminal** | `lifepunch-ops.exe` (lifepunchnet) | Cyan |

A bare CRT mesh, a `TextRenderer` idle line, or a dev spawn helper is **not** a terminal session until the matching **ops program** is running on that entity.

**Hub:** **Server Rack** (`hacker-server-rack`) — powers the CRT and defines link range. Passive like a GPU rack; players **USE the terminal**, not the rack.

See `addons/docs/TERMINAL_BRAND_MATRIX.md` · `addons/docs/PHYSICAL_TERMINAL_DOCTRINE.md`.

## Surfaces (do not conflate)

| Surface | What it is | Hack / payout actions? |
|---------|------------|------------------------|
| **Developer console** | s&box `>` — staff/editor `lp_*` spawn only | **Never** — no `scan`, `hack`, `govdb`, login shortcuts |
| **Ops console** | In-fiction prompt in program UI (`cornerman@terminal:~$`) | **Yes** — scans, hacks, withdrawals, job loop |
| **World LCD** | `lcd_screen` `TextRenderer` — `[ STANDBY ]` / offline | Status only |

**“Console” in design docs = ops console on the Hacker Terminal entity**, not the developer `>` bar. Players earn and act **at the CRT**, not through invisible engine commands.

## Login flow (required before any hack)

1. Player has the **Hacker** DXRP job (Advanced tier for `vengeance.exe` / govdb).
2. Player is at a **powered** Hacker / Advanced Hacker Terminal (rack within 8m, power ON).
3. Player **logs in** — **USE the CRT** at the entity → program boots → ops console opens.
4. Player types `scan`, `hack`, etc. at the **`cornerman@terminal:~$` input** inside the UI.
5. Host validates job + session + proximity on RPC (Phase 2 economy).

**Logged in** = ops console open for that player on that terminal entity. Closing the UI ends the session.

## Editor / staff helpers (not player gameplay)

| Command | Purpose |
|---------|---------|
| `lp_spawn_hacker_terminal` / `lp_spawn_server_rack` | Place entities in map |
| `lp_hacker_kit_preview` | Spawn powered kit — then **USE the CRT** to playtest |
| `lp_cornerman_ui` / `lp_vengeance_ui` | UI compile smoke in editor only |

**No `cornerman` / `vengeance` ConCmds in shipped builds.** Strip `HackerDevSpawn.cs` before portal publish.

## Code seams

| File | Role |
|------|------|
| `HackerTerminalSession.cs` | Session + job gate helpers |
| `HackerTerminal.razor` | Ops command dispatch (`HandleCommand`) |
| `HackerTerminalEntity.cs` | Login RPC (`RequestOpenTerminal`) |
| `HackerEconomySecurity.cs` | Host validation on hack submit (Phase 2) |
| `HackerCommandHost.cs` | **Dev-only** (`#if LIFEPUNCH_LOCAL`) — `cornerman` / `vengeance` smoke; players USE the CRT |
