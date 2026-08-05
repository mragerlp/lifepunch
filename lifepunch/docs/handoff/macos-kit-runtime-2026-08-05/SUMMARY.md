# MacOS Kit Runtime Worth — Proof Pack

**Date:** 2026-08-05  
**Machine:** VENGEANCE  
**Editor project:** `C:\Users\jared\Projects\lifepunch\lifepunchdxrp\game\rp.sbproj`  
**Kit root:** `...\LifePunch-MacOS-Addon-Planning`

## Verdict

| Surface | Kit folder | Runtime worth | Evidence |
|---|---|---|---|
| **Player Hub** | `LifePunch-Hub-Final` | **PROVEN in editor** | Mac Hub-Final overlay opens via `playerhub` / `hub`. Looks like `lifepunch.hub` (blue accent, Overview/Skills/Store/Stats). See `01-playerhub-macos-final-user.png`, `01b-playerhub-live.png`. |
| **Tags** | `lifepunch\...\lifepunchtags` | **COMPILE CLEAN; menu shell not durable yet** | Mounted into editor tree; CS0103 / SB1000 / AppleDouble / syntax blockers fixed. ConCmd `lifepunchtags`/`tags` has loaded SCSS once (`:disabled` unsupported warnings). Full Tags shell screenshot **not** captured this session — do not confuse Hub blue UI with Tags. See `02-tags-runtime-attempt.png`. |
| **Bitcoin Ops (control)** | `LifePunch-Bitcoin-Final` / repo `lpbitcoin` | **PROVEN preview control** | `lp_bitcoin_preview_hub` opened amber dashboard (PIN bypassed). Log: `lp_bitcoin_preview_hub: hub admin open`. See `03-bitcoin-preview-hub.png`. |
| **Wallet** | `LifePunch-Wallet-Finalized` | **Browser preview PROVEN; not s&box** | STATUS: 51/51 static verifier; production host-authority gated. See `04-wallet-browser-preview.png`, `04-wallet-STATUS.md`. Opened `preview/index.html` on VENGEANCE. |
| **ULX** | `LifePunch-ULX-Final` | Static / plan handoff | Not runtime-proven this pack. |
| **Banker** | `LifePunch-Banker-Plan` | Plan-only | Not runtime-proven. |
| **Chemist** | `LifePunch-Chemist-Plan` | Plan-only | Not runtime-proven. |
| **Blender** | `LifePunch-Blender` | Asset / plan lane | Not menu-runtime. |
| **Wallet Work 1/2** | `LifePunch-Wallet-Work *` | Worktrees / drafts | Superseded by Wallet-Finalized for preview claim. |

## Important distinction

- **`lifepunch.hub`** = Player Hub (blue). Your Hub screenshot is correct for Hub.
- **`lifepunch.tags`** = Name appearance menu (separate ConCmds). It must **not** look like Hub.
- **`lifepunch.wallet`** = Bitcoin-lane wallet; browser LOCAL PREVIEW only until host rail GO.

## Fixes landed this session (local trees; no commit)

1. Removed macOS `._*` AppleDouble junk (compile flood / Cursor crash risk).
2. `LpTagsMenuHost`: `var menu = target.Menu`; stuck Closing/Opening force-abandon; ShowUi→ScreenPanel fallback (non-local).
3. Whitelist: reflection checks → ctor round-trips; `Lazy`/`LazyThreadSafetyMode` → lock singleton.
4. Tags Escape sticky-close grace + clear `EscapePressed` on init.
5. `lifepunchdxrp/game/Code/Directory.Build.props` + `rp.csproj` define `LIFEPUNCH_LOCAL` for editor lane.
6. Invalid `#if` inside `$"..."` diagnostic removed (CS1003/CS1073).

## Next (Tags reopen)

1. Confirm `lifepunchtags` prints SCSS/`[lifepunchtags]` lines after a clean editor launch.
2. Capture a frame that shows wordmark `lifepunch.tags` / NAME APPEARANCE (not Hub Overview).
3. Strip `:disabled` pseudo from `LpTagsMenu.razor.scss` if needed for s&box UI.

## Out of scope (unchanged)

- Git commit/push without Bloodwave GO  
- Production wallet ledger / host rail  
- Tags Chat/Scoreboard/Nameplate adapters  
