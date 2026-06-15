# Ops CRT terminal — shared layout & color themes

**Layout family:** sidebar command reference + scrollback log + typed prompt.  
**Shell class:** `lp-ops-crt` + theme modifier.  
**Source of truth (SCSS):** `Code/Addons/lifepunch/bitcoinmining/LpOpsCrtTerminal.scss`

Hub admin panels (`LpHashdPanel`, hacker rack menu, etc.) use the **modern clickable** surface — not this CRT shell.

**Cyber module shell** (home grid + TERMINAL / NETWORK / DECRYPT / DASHBOARD): `branding/CYBER_TERMINAL_SHELL_SPEC.md` · shared `LifePunchCyberTerminal.scss`. Reference layout: [Cyber Hacker Simulator](https://apps.microsoft.com/detail/9nvc5p0bphgr) (MS Store) — LIFEPUNCH branding only.

---

## Theme map

| Terminal | CSS modifier | Accent / canon hex | Prompt (in-fiction) | Panel (when wired) |
|----------|----------------|-------------------|----------------------|-------------------|
| **Bitcoin hashd CRT** | `lp-ops-crt--gray` | Basic gray `#d4d4d4` on `#141414` | `rig0>` | `LpBitcoinTerminalPanel` |
| **Hacker (Cornerman)** | `lp-ops-crt--hacker` | Green `#00FF7F` family | `cornerman@terminal:~$` | `HackerOpsCrtPanel` (future) |
| **Advanced Hacker (VENGEANCE)** | `lp-ops-crt--vengeance` | Red `#E4002B` | `vengeance@terminal:~$` | same shell, red theme |
| **Government / Police** | `lp-ops-crt--government` | Cyan `#00D4FF` | `lifepunch@lifepunch.net:~$` | TBD |
| **Banker** | `lp-ops-crt--banker` | Navy `#000080` | TBD | TBD |
| **Black Market Dealer** | `lp-ops-crt--blackmarket` | Black `#000000` shell | TBD | TBD |
| **Casino Manager** | `lp-ops-crt--casino` | Magenta `#FF00FF` | TBD | TBD |

---

## Bitcoin (live now)

- **Gray CRT** — civilian mining terminal; amber `#f0a500` stays on **hub admin** (`LpHashdPanel`) only.
- Preview: `lp_bitcoin_preview_terminal`
- Header: `LIFEPUNCH HASHD TERMINAL`

---

## Hacker (saved layout — green)

The green sidebar CRT you signed off on is preserved as `lp-ops-crt--hacker` in `LpOpsCrtTerminal.scss`.

**Reference markup** (copy when refactoring `hackerjob` off legacy `HackerTerminal.razor`):

`addons/docs/branding/reference/HackerOpsCrtPanel.razor`

Wire with:

```html
<root class="lp-ops-crt lp-ops-crt--hacker">
```

Import SCSS from `bitcoinmining/LpOpsCrtTerminal.scss` (or duplicate into `hackerjob/` when that lane ships).

---

## Rules

1. One CRT theme open at a time — `LpBitcoinUi.CloseAll()` pattern applies per product.
2. Do not put mine/sell on hub admin; typed commands stay on CRT.
3. Sidebar lists commands only — player still types to execute.

---

## Related

- `TERMINAL_BRAND_MATRIX.md`
- `BITCOIN_GREENFIELD_REBUILD.md`
- `branding/lifepunch-ops/THEME.md` (when present)
