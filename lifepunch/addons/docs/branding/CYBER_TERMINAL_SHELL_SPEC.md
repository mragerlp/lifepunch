# Cyber terminal shell (shared home + modules)

**Reference product:** [Cyber Hacker Simulator](https://apps.microsoft.com/detail/9nvc5p0bphgr) (Microsoft Store `9nvc5p0bphgr`, RollerNiGi) — **layout and module flow only**. LIFEPUNCH™ owns all in-fiction names, colors per job, and gameplay wiring. Do not clone third-party art or copy.

**Code:** `Code/Addons/lifepunch/LifePunchCyberTerminal.scss` · `LifePunchCyberTerminalTheme.cs`  
**First consumer:** `hackerjob/HackerTerminal.razor` (Cornerman green · Vengeance red)

---

## Why this shell exists

Physical terminals open an **ops program**, not a single scrollback view. The reference app uses a consistent pattern:

1. **Home** — welcome + 2×2 module cards  
2. **Module screens** — full-screen tool or CLI per card  
3. **Header** — brand slug + `STATUS` / `IP` / `SECURITY` + **MAIN MENU**  
4. **Footer log** — timestamped system lines (always visible)

Hub admin panels (`LpHashdPanel`, etc.) stay **modern dashboard** — this shell is for **typed terminal programs** only (`PHYSICAL_TERMINAL_DOCTRINE.md`).

---

## Core modules (reference → LifePunch mapping)

| Reference module | Purpose | Hacker (`cornerman` / `vengeance`) | Bitcoin HASHD CRT (future) | Gov lifepunchnet (future) |
|------------------|---------|--------------------------------------|----------------------------|---------------------------|
| **TERMINAL** | Command-line ops | Typed prompt + scrollback | `rig0>` commands | `lifepunch@lifepunch.net:~$` |
| **NETWORK** | Scan / probe | Wallet `scan` (+ `govdb` on Vengeance) | Rack link / status | Trace / audit mesh |
| **DECRYPT** | Bypass / crack fiction | Wallet `hack` puzzles (+ `infil` on Vengeance) | Sell / payout auth (TBD) | Counter-breach tools (TBD) |
| **DASHBOARD** | Session overview | Link, rack power, targets, quick jumps | Hub power, BTC totals | City treasury stats |

Each product swaps **accent hex** and **brand slug** from `TERMINAL_BRAND_MATRIX.md` — same grid, different paint.

---

## Color tokens (per terminal)

| Terminal | CSS root class | `--cyber-primary` | `--cyber-border` |
|----------|----------------|-------------------|------------------|
| Cornerman | `.lp-cyber-terminal.tier-standard` | `#00FF7F` | `#1a3a2a` |
| Vengeance | `.lp-cyber-terminal.tier-advanced` | `#E4002B` | `#3a1a1a` |
| HASHD CRT | `.lp-cyber-terminal.theme-hashd` | `#f0a500` | `#3a2e14` |
| lifepunchnet | `.lp-cyber-terminal.theme-government` | `#00D4FF` | `#1a2e3a` |

Amber on HASHD applies to **CRT program** only — Ophion hub keeps `LpHashdPanel` amber dashboard.

---

## Screen enum

`LifePunchCyberScreen`: `Home` · `Terminal` · `Network` · `Decrypt` · `Dashboard`

- **Boot** lands on `Home`.  
- **MAIN MENU** returns to `Home` from any module.  
- Module cards and Dashboard quick-access buttons call the same `EnterScreen()` path.

---

## Header fields

| Field | Fiction | Hacker source |
|-------|---------|---------------|
| Brand | `CORNERMAN` / `VENGEANCE` / `HASHD` / `LIFEPUNCHNET` | `HackerTerminalBrand` |
| STATUS | `CONNECTED` / `OFFLINE` | Terminal link + rack power |
| IP | `205.209.104.22` | Fixed fiction — LifePunch Official (lifepunchnet). **Never** player LAN/WAN or connection metadata. |
| SECURITY | `LEVEL n` | Rack detection tier (or hub PIN tier when wired) |

---

## Footer log

Append on boot, module load, scan complete, and errors. Format:

```text
[hh:mm:ss tt] Establishing secure connection...
```

Cap at ~24 lines; scroll in footer panel.

---

## Implementation checklist

| Step | Item |
|------|------|
| ☑ | Shared SCSS + theme types |
| ☑ | Hacker terminal adopts shell |
| ☐ | HASHD CRT adopts shell (keep gray/amber CRT variant) |
| ☐ | lifepunchnet ops shell (Phase 4) |
| ☐ | Update `OPS_CRT_TERMINAL_THEMES.md` cross-link |

---

## Related

- `TERMINAL_BRAND_MATRIX.md`
- `OPS_CRT_TERMINAL_THEMES.md`
- `HACKER_OPS_CONSOLE_SPEC.md`
- `PHYSICAL_TERMINAL_DOCTRINE.md`
