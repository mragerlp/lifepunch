# s&box engine patches — LifePunch

> **Single source of truth** for engine updates that can break LifePunch addons, UI, or publish.
> Agents read this at session start and **append a new section** when the local engine is newer
> than `lastReviewedEngine` below.

| Field | Value |
|-------|-------|
| **Last reviewed engine** | `26.06.23` (staging proof on lifepunchnet) |
| **Last reviewed news** | [update-26-06-10](https://sbox.game/news/update-26-06-10) + Dxura staging workaround 2026-06-23 |
| **Last reviewed date** | 2026-06-23 |
| **Local install path** | `D:\Steam\steamapps\common\sbox` |

**Check command (run every session before UI/publish work):**

```powershell
powershell -File lifepunch\scripts\Get-SboxEnginePatchStatus.ps1
```

If status is **WARN** or **STALE**, fetch `https://sbox.game/news` (latest post), log impacts
here, run the regression checklist, then bump `lastReviewedEngine` in this file.

---

## Why this exists

The hashd hub menu shipped **title-only / empty body** (Jun 2026) from stacked issues that a
patch-aware gate would have caught:

1. **SCSS root** used uppercase `HashdTerminal { }` — s&box **silently skips** type selectors;
   entire stylesheet never applied (`SBOX_RAZOR_SCSS_RULES.md`).
2. **`BuildHash`** omitted PIN UI state — numpad never re-rendered after CTA click.
3. **USE vs preview** owner gate — `Owner == 0` sent players to PIN BLOCKED.

Engine patches can change compile, UI, networking, and publish without loud errors. Treat every
Steam update as a **regression event**, not “probably fine.”

---

## Agent workflow (law)

### Every session (before editing addons / UI / publish scripts)

1. `git pull --rebase` (monorepo).
2. `Get-SboxEnginePatchStatus.ps1` — if engine > last reviewed, read news + update this doc.
3. If touching `.razor.scss`: `Validate-SboxRazorScss.ps1` **before** playtest.

### After any engine bump (owner or agent)

1. Log the patch section below (link, date, LifePunch impact).
2. Run **Regression checklist** (full or scoped — see table).
3. **Stop play → Play** in editor after SCSS/UI edits (panel close is not enough).
4. Grep `sbox-dev.log`: `not valid with`, `error CS`, `Compile.*Failed`.
5. Smoke: one LifePunch menu panel (staff / hashd PIN / hacker rack) + one world USE path.

### When Bloodwave posts a news URL

Treat it as **immediate triage** — fetch, summarize LifePunch impact, update this doc same session.
Do not wait for a broken playtest to discover it.

---

## Regression checklist

| Area | What to verify | How |
|------|----------------|-----|
| **Razor SCSS** | Class root on `<root class="...">`, not `ComponentName { }` | `Validate-SboxRazorScss.ps1`; grep log `not valid with` |
| **PanelComponent** | `BuildHash` includes all UI state that changes without new props | Code review on `.razor` panels |
| **Menu USE path** | World USE matches dev-preview smoke (owner/PIN gates) | `lp_spawn_*` + USE, not only ConCmd preview |
| **Dedicated DXRP** | Addon mount + whitelist compile on lifepunchnet | Join Dev after bump; grep server log for `SB1000`, `[7/7]` |
| **Publish** | Portal upload still valid (`_c` assets, code-only addons) | `prepare-publish.ps1 -Addon <ident>` dry run |
| **Binary assets** | `_d` / model changes trigger rebuild | Touch vmat → confirm `_c` refresh |
| **Deprecated APIs** | No new `[Global]` / `[Frame]` usage | `rg '\[Global\]|\[Frame\]' lifepunch/` |

Known-good UI references: `StaffMenu.razor.scss` (`.lifepunchulx`), `HashdTerminal.razor.scss`
(`.hashd-terminal`). **Audit debt:** `HackerServerRackMenu.razor.scss` still uses type selector —
migrate to class root when that lane is touched.

---

## Patch log

### 26.06.23 — staging branch required for DXRP addon mount (2026-06-23)

**Source:** Dxura (Dimmer) — release addon mounter/whitelist broken after latest s&box update; use **staging s&box**.

**Proof:** lifepunchulx r7 on LIFEPUNCH™ Development — menu opens in-game after **both** client and lifepunchnet dedicated host on staging. Release branch → `Unknown Command` / client never mounted assembly.

#### LifePunch impact

| Change | Risk | Action |
|--------|------|--------|
| **Release** dedicated addon mount / whitelist | **High** — portal-pinned code-only addons fail to compile/mount on dedicated | Use **staging** on lifepunchnet **and** joining clients until Facepunch ships fix to release |
| **SteamCMD** default `app_update 1892930 validate` | **High** — pulls **release**, undoes staging | Use `-beta staging` on Blue; do **not** run `auto_update.bat` until `-UseStagingBranch` or manual staging |
| **Client/server branch mismatch** | **High** — cannot join or mount | Match branches: staging client ↔ staging `sbox-server.dll` |
| **Portal publish / gamemode pin** | Unchanged | Still r7 on `019ee8ed-…`; launch still `dotnet run dxrp-server.cs` |

#### lifepunchnet staging (SteamCMD app 1892930)

```bat
cd /d "C:\S&BOX DXRP Server"
steamcmd.exe +login anonymous +app_update 1892930 -beta staging validate +quit
```

Copy `sbox-server.*` into launch root → `Fix-LifepunchnetSteamClient.ps1` → `server2_start.bat` (same as always).

**Revert when release fixed:**

```bat
steamcmd.exe +login anonymous +app_update 1892930 validate +quit
```

**Client:** Steam → s&box → Properties → Betas → **staging** (VENGEANCE join testing).

Canon: `lifepunch/server/change-log/2026-06-23-lifepunchulx-r7-staging-proof.md` · `addon-revisions.json` (lifepunchulx r7).

---

### 26.06.10 — 2026-06-10

**News:** [sbox.game/news/update-26-06-10](https://sbox.game/news/update-26-06-10)

#### LifePunch impact

| Change | Risk | Action |
|--------|------|--------|
| **Precompiled DLLs** (backend compile; CLL removed from manifests) | **High** — join/publish path | Confirm DXRP dev join time; no reliance on client CLL compile; portal still ships addon `_c` |
| **`Game.IsPlaying` fix** on published load | Medium — spawn/menu timing | Re-smoke dev spawn + USE after engine bump |
| **Binary compile references** (`_d` triggers rebuild) | Medium — asset iteration | Re-pull `_c` after ModelDoc/vmat edits |
| **Case-insensitive mount paths** | Low | Keep consistent path casing in `addons.json` / assets |
| **Addons cannot increment Game Stats** | Low | None — we do not use this |
| **`[Global]` / `[Frame]` removed** | Low | None in LifePunch code (2026-06-14 grep) |
| **Screen 2D View** (+Y down, screen space) | Info | Aligns with UI flex layouts; no change unless building 2D games |
| **Indirect light / terrain / buoyancy** | Low for addons | Visual only |

#### Incidents tied to this era (not caused by patch, caught late)

- Hashd terminal empty body — SCSS class root + `BuildHash` (fixed `015b970`).
- Staff menu gradient SCSS — same failure class (`STAFF` brief / `SBOX_RAZOR_SCSS_RULES.md`).

---

## Related docs

| Doc | Role |
|-----|------|
| `SBOX_RAZOR_SCSS_RULES.md` | Forbidden SCSS + validate command |
| `SBOX_EDITOR_REFERENCE.md` | Editor/cloud access model |
| `bitcoinmining/docs/RUNTIME_PATTERN.md` | Hashd mount + dual-build |
| `TECH_DEBT.md` | Temporary baselines + open UI debt |
