# Hacker Menu Shell Slot Specification

**Issue:** [#155](https://github.com/mragerlp/lifepunch/issues/155) · **Phase:** HK-S5A, documentation only
**Status:** Phase B gated on [#135](https://github.com/mragerlp/lifepunch/issues/135)
**Consumer:** `hackerjob` · **Shared shell:** `LpMenuShell` from [PR #143](https://github.com/mragerlp/lifepunch/pull/143)

## Purpose

The Hacker menu uses the shared seven-slot `LpMenuShell` for job overview and management. It does
not replace or reproduce `HackerTerminal.razor`. The existing in-world CRT remains the place where
the player operates `cornerman.exe` or `vengeance.exe`; the menu shell summarizes the linked kit
and routes the player back to that physical operating surface.

The Hacker skin follows `CYBER_VISUAL_IDENTITY_DOCTRINE.md`: standard terminals are Cornerman green
and advanced terminals are VENGEANCE red. HASHD amber belongs to Bitcoin and must never appear in
this consumer. Reserved warning, error, offline, booting, hacked, and security-alert states override
the tier accent.

## Surface boundary

| Capability | In-world `HackerTerminal.razor` CRT | Hacker `LpMenuShell` consumer |
|---|---|---|
| Physical authority | Owns terminal validity, range, rack link, rack power, login, and session gates | Displays host-provided linked/offline state; never bypasses a physical gate |
| Command operation | Owns prompt input, `help`, `scan`, `hack`, `govdb`, `infil`, command output, and activity scrollback | Provides no command prompt and does not submit commands |
| Target work | Owns live wallet/GOVDB/HASHD result rows, target selection, puzzle prompt, answer entry, timer, and immediate trace feedback | Displays no targets, balances, puzzle answers, or operation-start controls |
| Machine fiction | Owns CRT boot text, fake host IP, terminal status rail, monospace logs, scanlines, and `cornerman.exe` / `vengeance.exe` authenticity | Uses the shared LIFEPUNCH menu structure with the tier identity applied as its skin |
| Job overview | May retain its compact session dashboard as local terminal telemetry | Owns the cross-kit dashboard: terminal link, rack state, tier/capability summary, and management routes |
| Navigation | Navigates only among CRT modules: HOME, TERMINAL, NETWORK, DECRYPT, DASHBOARD | Navigates menu panes: Dashboard, Hardware, Upgrades, Security, and Settings |
| Hardware actions | May report whether the linked rack permits an operation | May route to the existing rack-management surface; does not remotely power or operate world hardware |
| Economy | Existing Phase-1 no-transfer messages remain CRT prior art | No theft, payout, wallet, or purchase UI in HK-S5A |

**Boundary rule:** if a proposed shell control can scan a target, select a victim, start or answer a
puzzle, execute a terminal command, or alter world-machine power, it belongs to the physical CRT or
rack surface—not the menu shell.

## Seven-slot requirements

`AccentColor` remains the separate eighth component property established by PR #143; it is not an
eighth content slot.

| # | `LpMenuShell` slot | Hacker requirement | Required source data / behavior |
|---|---|---|---|
| 1 | `Mark` (`RenderFragment`) | Hacker-owned tier mark: `◆` for Cornerman, `▲` for VENGEANCE. Never use the Player Hub LP roundel or HASHD mark. | Derived from the linked terminal tier; decorative shape is paired with a text tier label elsewhere. |
| 2 | `Wordmark` (`string`) | `CORNERMAN OPS` for standard tier; `VENGEANCE OPS` for advanced tier. | Derived from the same authoritative tier value as `Mark` and `AccentColor`. |
| 3 | `TopBarControls` (`RenderFragment`) | Read-only `TERMINAL LINK`, `RACK POWER`, and tier badges plus the normal close/return affordance. No power toggle, scan, hack, or cash control. | Host-provided booleans and tier label. Actions may close the menu or route to the existing physical surface only. |
| 4 | `NavItems` (`List<NavItem>`) | Dashboard, Hardware, Upgrades, Security, Settings. Settings is pinned by the shared shell. Do not mirror CRT TERMINAL/NETWORK/DECRYPT modules. | One active route; disabled routes carry visible locked copy. No target- or economy-specific route in Phase A. |
| 5 | `DoorCards` (`List<DoorCard>`) | `HACKER TERMINAL`, `SERVER RACK`, and `ADVANCED CAPABILITY`. Cards summarize whether each physical/capability door is linked, online, available, or locked. | Link/power/tier eligibility only. Terminal action returns to the existing CRT; rack action routes to the existing rack-management surface. |
| 6 | `SnapshotStats` (`List<StatRow>`) | Dashboard rows for terminal link, rack power, security/detection tier, and current capability tier. | Read-only host snapshots. No wallet cash, victim balance, stolen amount, HASHD BTC, or projected payout. |
| 7 | `QuickButtons` (`List<QuickButton>`) | `RETURN TO TERMINAL`, `RACK STATUS`, and `UPGRADES`. | Route/open callbacks only. Buttons remain disabled when their physical dependency is unavailable and show that state in text. |

## Slot data contracts

The Hacker consumer must populate the PR #143 contract without introducing a parallel shell model:

- `NavItem`: `Route`, `Label`, `Icon`, `Tooltip`, `PageIcon`, `PageTitle`, `Callout`,
  `IsActive`, `IsSettings`, `IsDashboard`, `HasAlert`, `Enabled`, and `OnSelected`.
- `DoorCard`: `Icon`, `Title`, `Chips`, `Description`, `Label`, `Route`, `Enabled`,
  status/action classes, optional footer note, and `OnSelected`.
- `StatusChip`: visible `Text` plus `Info`, `Success`, `Locked`, or `Count`; color must not be the
  only state signal.
- `StatRow`: `Label`, display value, description, optional value class, and footer note. Currency
  fields stay empty in HK-S5.
- `QuickButton`: `Label`, `Icon`, `Route`, `CssClass`, `Enabled`, and `OnSelected`.

The consumer view data is one read-only snapshot with these minimum fields:

| Field | Meaning |
|---|---|
| `Tier` | `Standard` or `Advanced`; drives mark, wordmark, and accent together |
| `TerminalLinked` | A valid physical hacker terminal is linked to this menu session |
| `RackLinked` | A valid hacker rack is linked |
| `RackPowered` | The linked rack is host-reported online |
| `DetectionTier` | Read-only rack security/detection level |
| `CapabilityTier` | Current standard/advanced capability label |
| `HasSecurityAlert` | Drives a labeled alert state; it does not expose a target |

Callbacks are navigation boundaries, not gameplay authority. Phase B must continue to validate
commands, sessions, range, power, targets, and puzzles through the existing host-owned terminal
paths. Every private flag that changes rendered shell data must participate in the consumer's
`BuildHash`.

## Visual and typography contract

- Standard tier accent: Cornerman green `#00FF7F`; advanced tier accent: VENGEANCE red `#E4002B`.
  Here green is the locked Hacker machine-role identity, not a cash value. HK-S5 contains no cash
  display.
- Never use HASHD amber, Bitcoin marks, `rig0>` language, Bitcoin wallet telemetry, or Bitcoin
  terminal controls.
- Menu-shell headings and buttons use Poppins; labels, body copy, and values use Inter. Montserrat
  is forbidden in in-game SCSS.
- The physical CRT keeps its terminal typography, scanline treatment, prompt, and dense log grammar;
  those traits do not spread into the shared menu shell.
- State is always expressed with text/iconography as well as color. Reserved machine-state colors
  override the tier accent.

## Non-goals

- No `.razor`, `.razor.scss`, C#, prefab, asset, config, or lpbitcoin changes in Phase A.
- No theft, victim, transfer, payout, target-balance, or other money UI until HK-S4 is ruled and
  delivered.
- No Bitcoin-terminal, HASHD defense, Hub alert, hub wallet, shared Bitcoin CRT asset, sound, or
  shared ops-CRT SCSS work.
- No duplicate terminal emulator, command parser, target list, puzzle, or rack power control inside
  `LpMenuShell`.
- No tablet surface and no new remote-control path for a world terminal.
- No Phase B implementation before #135 and a new conductor LIVE instruction.

## Phase B acceptance boundary

Phase B may implement only this consumer mapping after #135. Acceptance requires all seven slots,
the separate tier accent, non-dashboard content through inherited `Panel.ChildContent`, a
`BuildHash` covering every render-driving value, Poppins/Inter compliance, zero Montserrat, and
proof that opening the CRT still uses the existing `HackerTerminal.razor` rather than a shell copy.
