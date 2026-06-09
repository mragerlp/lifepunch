# Cornerman // Operations Console — branding pack

Cosmetic theme for the Cornerman local AI workstation. The look is a **real cyber
operations terminal** — understated, premium, "advisor/intelligence" — not a Matrix-rain
movie prop. Purely visual: it does **not** change the security posture (LAN-only, no
secrets on the box). See `../../docs/LOCAL_AI_WORKSTATION.md`.

## Assets in this folder

| File | Use | Spec |
|------|-----|------|
| `cornerman-wallpaper.png` | Desktop + lock-screen background | 4K 16:9, status panel lower-left |
| `cornerman-teams-bg.png` | Microsoft Teams virtual background | 1920×1080, "SECURE NODE" panel left, subject area kept clear right |
| `windows-terminal-cornerman.json` | Windows Terminal color scheme | scheme name `Cornerman Ops` |

## Palette

| Token | Hex | Where |
|-------|-----|-------|
| Background | `#0A0D0A` | Windows accent base, terminal bg |
| Primary green | `#00FF7F` | accent color, cursor, ONLINE/ACTIVE |
| Secondary green | `#19C37D` | selection, secondary status |
| Warning red | `#C1121F` | alerts only |
| Text (mint) | `#D8FFE8` | body text |

## Apply checklist (operator, ~10 min)

1. **Dark mode everywhere** — Settings → Personalization → Colors → *Choose your mode:* **Dark**.
2. **Accent color** — same page → *Accent color:* **Manual** → **Custom** → set `#00FF7F`
   (or `#19C37D` if `00FF7F` is too bright on the taskbar). Tick *Show accent color on
   Start and taskbar* and *on title bars and window borders*.
3. **Wallpaper** — Personalization → Background → *Picture* → browse to
   `cornerman-wallpaper.png` → *Fit:* **Fill**.
4. **Lock screen** — Personalization → Lock screen → *Personalize:* **Picture** → same
   `cornerman-wallpaper.png`.
5. **Windows Terminal** — open Settings (Ctrl+,) → *Open JSON file*. Paste the object from
   `windows-terminal-cornerman.json` into the `"schemes": [ ... ]` array. Under
   *Profiles → Defaults → Appearance* set **Color scheme = Cornerman Ops**, **Font =
   Cascadia Code** (or JetBrains Mono / Fira Code if installed), cursor shape *Filled box*.
   Acrylic background is optional and off-theme; leave off for max contrast.
6. **Microsoft Teams background** — new Teams: join/start a meeting → *More → Video effects
   and settings → Backgrounds → Add new* → pick `cornerman-teams-bg.png`. (Classic Teams:
   drop the file in `%APPDATA%\Microsoft\Teams\Backgrounds\Uploads\`.)
7. **Edge** — Settings → Appearance → *Overall appearance:* **Dark**.

## Status panel (for reference / Teams text / signatures)

```
┌──────────────────────────────┐
│         CORNERMAN            │
│    Intelligence Platform     │
├──────────────────────────────┤
│ NODE STATUS  : ONLINE        │
│ LOCAL AI     : ACTIVE        │
│ GITLAB       : CONNECTED     │
│ OLLAMA       : RUNNING       │
│ DXRP NETWORK : MONITORING    │
└──────────────────────────────┘
```

```
[CORNERMAN SECURE NODE]

STATUS: ONLINE
AGENTS: CONNECTED
THREAT LEVEL: LOW

> awaiting instruction_
```

## Regenerating assets

Both PNGs were generated to this palette/brief. To refresh, regenerate at the same
resolutions keeping: near-black `#0A0D0A`, sparse edge code only, green `#00FF7F`, a single
red `#C1121F` indicator, mint `#D8FFE8` text, generous negative space, no dense Matrix rain.
