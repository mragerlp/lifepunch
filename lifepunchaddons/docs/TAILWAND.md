# tailw& (Tailwand) — LifePunch runbook

**Library:** `tristan.tailwand` · [sbox.game/tristan/tailwand](https://sbox.game/tristan/tailwand)  
**DXRP ref:** `rp.csproj` ProjectReference (required compile dep)  
**Config (repo):** `lifepunch/config/tailwand.config.json` → copied to DXRP game root on sync  
**Generated output (editor):** `dxrp/game/Code/tailwand.generated.scss` — **regenerate in editor; commit after verify**

---

## What it does

Tailwind-shaped utility classes on Razor → editor scans → writes `tailwand.generated.scss`. Import once in component SCSS:

```scss
@import "/tailwand.generated.scss";
```

**Not a ship dependency for portal addons** — utilities live in generated project SCSS at DXRP game root. LifePunch addon `.razor` uses class names; DXRP project must have run **Generate Now** before play compile succeeds.

---

## First-time setup (once per DXRP project)

1. Sync repo → DXRP (copies config):

   ```powershell
   powershell -File lifepunch\scripts\Sync-LifePunchAddonsToDxrp.ps1 -Addon bitcoinmining
   ```

2. Open DXRP editor (`Start-SboxDxrpEditor.ps1 -PreflightFix -BitcoinOnly`).

3. **Editor → tailw& → Initialize** (creates/merges `tailwand.config.json` at game root if missing).

4. **Editor → tailw& → Generate Now** — must run after any Razor utility change.

5. Leave **tailw& → Toggle Watcher** on for auto-regen while editing `.razor`.

6. Commit `Code/tailwand.generated.scss` to repo under `lifepunch/config/` **only after** visual sign-off (optional mirror copy — see below).

---

## LifePunch config scope

`lifepunch/config/tailwand.config.json` scans **LifePunch addon Razor only**:

```json
"content": [ "Code/Addons/lifepunch/**/*.razor" ]
```

Theme tokens align with HASHD / hub admin (amber ops):

| Token | Value | Use |
|-------|-------|-----|
| `hashd` | `#f0a500` | Accent, borders `/35` |
| `hashd-shell` | `rgba(12,14,18,0.96)` | Panel background |
| `hashd-topbar` | `rgba(18,20,26,1)` | Top bar |
| `hashd-title` | `#f7f9fc` | Primary labels |
| `hashd-muted` | `#8b95a8` | Subtitles |

Staff menu blue accent remains hand-SCSS (`StaffMenu.razor.scss`) until a separate token pass.

---

## Active pilot: `LpHashdPanel` chrome only

**Changed:** shell, topbar, brand text, nav row, content frame — utility layout classes on Razor.  
**Unchanged:** `@code`, hub bind, metrics, rack cards, settings, `LpUiChrome.scss` close/cog buttons.  
**Still semantic SCSS:** `.nav-tab` + `.active`, `.status-chip` + `.live`/`.off`, `.brand-mark` (BTC image).

### Playtest

```text
game.scene → Host Play
lp_authorize <token>
lp_bitcoin_preview_hub
```

Or: `lp_bitcoin_spawn_kit` → USE hub.

### If layout looks unstyled

You skipped **Generate Now** — utilities exist in Razor but SCSS was not emitted.

---

## Dynamic classes + safelist

`disabled:`, `group-hover:`, and tab `active` built in C# need either:

- **Semantic SCSS** (what we do for `.nav-tab.active`), or  
- **Safelist** in config / Razor comment:

```razor
@* tailw& safelist: bg-hashd/10 text-hashd border-hashd/45 *@
```

---

## Parity with DXRP

| Check | Status |
|-------|--------|
| In `rp.csproj` | Yes — same compile graph as DXRP |
| Scans synced LifePunch Razor | Yes — `Code/Addons/lifepunch/**/*.razor` |
| Conflicts with DXRP UI | No — DXRP game code does not use tailw& classes today |
| Portal addon self-contained | No — requires game-root `tailwand.generated.scss` at dev time; ship path is committed generated SCSS + Razor class strings |

---

## What not to migrate yet

- Full `StaffMenu.razor.scss` (~1700 lines) — stay hand-SCSS.
- CRT terminal matrix effects — use `quack.matrix_rain` vmats separately (`BITCOINMINING-02`).
- Grid layouts — tailw& reports `grid-*` as unsupported; stay `flex`.

---

## Related

- [SBOX_UI_DESIGNER.md](./SBOX_UI_DESIGNER.md) — visual layout tool (complementary)
- `TECH_DEBT.md` **STACK-03** — pilot tracking
