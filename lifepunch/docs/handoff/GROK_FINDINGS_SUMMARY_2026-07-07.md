# GROK_FINDINGS_SUMMARY_2026-07-07

Faithful structured summary of `handoff/GROK_SYNCVAR_ULX_FINDINGS_2026-07-07.md` (workspace-root copy).
Written because the chat paste path drops large content. No editorializing; verbatim quotes where compression would lose meaning.

> Source file location note (verbatim intent): the source lives at workspace-root `handoff/`;
> all other session briefs live under `lifepunch/docs/handoff/`. "Two handoff folders exist.
> Do not assume a single location when grepping. Consolidate on the cleanup list."

---

## Section 1 — lpbitcoin SyncVar audit (read-only findings)

### LpBitcoinHubEntity
`lifepunchaddons/Code/Addons/lifepunch/lpbitcoin/bitcoinhub/code/components/LpBitcoinHubEntity.cs`

| Property | Required for client? | Excess? | Proposed change | Risk note |
|---|---|---|---|---|
| IsPowered (bool) | Yes — client visuals, power state in HashdPanel/terminal UI | No | Move into HubCoreState struct (one Sync property) | Client power visuals and UI toggles may see delayed or batched updates if struct dirtying differs from per-field |
| AccessPinIsSet (bool) | Yes — UI pin gate display | No | Move into HubSecurityState struct | Client pin UI state may desync on partial updates |
| AccessPinHash (int) | **No** — host-only verification; client only sends raw pin | **Yes** (host-only state) | Remove `[Sync]`; keep host-only field or internal | None (client never reads hash for logic) |
| Owner (long) | Yes — ownership checks in UI | No | Move into HubSecurityState struct | Ownership-derived UI (e.g. manage buttons) may batch-update |
| HubWalletBtc (float) | Yes — balance display in hub panel | No | Move into HubCoreState struct | Live wallet updates in UI may batch instead of per-field |
| AlertFeed (string) | Yes — serialized alerts for logs panel | No (already compacted) | Keep as-is or migrate to `NetList<LpBitcoinHubAlert>` if supported | List truncation or parse errors in UI if serialization changes |
| UnreadAlertCount (int) | Yes — badge count in UI | No | Move into HubAlertsState struct with AlertFeed | Badge may not increment independently of full feed refresh |

### LpBitcoinTerminalEntity
`lifepunchaddons/Code/Addons/lifepunch/bitcoinmining/LpBitcoinTerminalEntity.cs`

| Property | Required for client? | Excess? | Proposed change | Risk note |
|---|---|---|---|---|
| LinkedHubId (Guid) | Yes — client resolves linked hub for commands/UI | No | Keep or include in TerminalLinkState struct | Unlink/link flows in terminal UI may delay if grouped |

### LpBitcoinRackEntity
`lifepunchaddons/Code/Addons/lifepunch/bitcoinmining/LpBitcoinRackEntity.cs`

| Property | Required for client? | Excess? | Proposed change | Risk note |
|---|---|---|---|---|
| LinkedHubId (Guid) | Yes — association for hub queries | No | Keep or move to RackLinkState struct | Rack-to-hub visuals/commands may stale briefly |
| IsMining (bool) | Yes — status display, rate calc | No | Move into RackMiningState struct | Mining on/off indicators in panel may batch-update |
| BitcoinAmount (float) | Yes — balance display, sell/deposit | No | Move into RackMiningState struct | Live balance updates (payouts) in UI may not be per-field granular |
| ClockGhz (float) | Yes — rate display | No | Move into RackUpgrades struct with levels/cores | Displayed rate in panel may update only on full struct change |
| CoreCount (int) | Yes — rate display | No | Move into RackUpgrades struct | Same as ClockGhz |
| CpuUpgradeLevel (int) | Yes — upgrade progress UI | No | Move into RackUpgrades struct | Upgrade UI progress may not reflect independently |
| CoreUpgradeLevel (int) | Yes — upgrade progress UI | No | Move into RackUpgrades struct | Same as CpuUpgradeLevel |
| MiningProgress (float) | **No** — derivable on client from `_sincePayout` + rate when IsMining true | **Yes** (UI-only field) | Remove `[Sync]`; compute client-side in panel | Progress bar in UI may drift if client timing differs from host |

**Net verdicts:** 2 excess sync properties (AccessPinHash, MiningProgress — both remove-`[Sync]` candidates); all others keep, with struct-compaction proposals (HubCoreState, HubSecurityState, HubAlertsState, TerminalLinkState, RackLinkState, RackMiningState, RackUpgrades).

### Coverage gaps — NOT audited
LpBitcoinHubVisuals.cs, LpBitcoinRackVisuals.cs, LpHashdPanel.razor, LpBitcoinTerminalPanel.razor, LpBitcoinPortalEconomySync.cs, LpBitcoinPowerLeds.cs, LpBitcoinPowerAnim.cs, LpBitcoinUi.cs, LpBitcoinTerminalLogPanel.cs, LpBitcoinTerminalUiHost.cs, LpBitcoinTerminalScreen.cs, LpBitcoinTerminalCommands.cs, all prefab/material/asset files, and "any BaseEntity overrides or shared LifePunch* components pulled into bitcoinmining".

### Internal todos (verbatim)
- id: audit-lpbitcoin-syncvars content: Audit all [Sync(FromHost)] and networked state in lpbitcoin (Hub, Terminal, GPU Rack) entities and supporting components. status: completed
- id: list-all-sync-properties content: List every individual Sync property by entity with type and purpose. status: completed
- id: identify-compaction-opportunities content: Identify fields that can be grouped into structs or moved to NetDict<Guid, State> per Dimmer advice and machine standard. status: completed
- id: check-for-netdict-usage content: Confirm no NetDict / complex net collections are used yet for machine states. status: completed
- id: check-alerts-compaction content: Review how alerts are handled (string serialization) as precedent for compaction. status: completed
- id: report-status-and-recommend content: Provide clear status report + recommended next steps for cleaning before further Phase work. status: completed
- id: consider-followup-compaction-plan content: If owner approves, create DECISION or plan for struct compaction + possible NetDict for racks on hub. status: pending

---

## Section 2 — lifepunchulx staging additions (desktop staging-folder work)

All five files staged under `C:\Users\jared\desktop\lifepunch\addons\publish\lifepunchulx\upload\Code\Addons\lifepunch\lifepunchulx\`;
all intended repo destination `lifepunchaddons/Code/Addons/lifepunch/adminmenu/`.

### StaffMenuActions.cs
- Does: adds `setjob` StaffAction using `StaffArgKind.Job` (enables /job dropdown in arg-form with player select + confirm flow).
- Replaces/supersedes: none (extends existing catalog).
- Behavior changes: new "Set Job" entry appears in Commands tab for users with `command.job.manage`; existing setjob (if present) now uses dropdown instead of prior chips UI.
- Incomplete/untested: dropdown population + confirm dispatch not run in full flatgrass/Host Play; relies on `AssignableJobs()` from host.

### StaffMenuHost.cs
- Does: (1) adds `StaffJobOption` record + `AssignableJobs()` for /job dropdown data (local stub + GameModeJobs path); (2) updates all waypoint/settings calls to single StaffMenuBridgeService.
- Replaces/supersedes (for compaction): WaypointSyncService.cs and StaffSettingsService.cs.
- Behavior changes: none to exposed API or command behavior; /job now has live job list with colors; old two services no longer instantiated.
- Incomplete/untested: local stub list vs real GameModeJobs parity not verified on target server; no owner-permission regression run.

### StaffMenu.razor
- Does: implements compact searchable dropdown for `StaffArgKind.Job` (filter TextEntry, color swatches, active state, header chevron) replacing prior chips; adds `_job`/`_jobFilter`/`_jobDropdownOpen` state, `SetJob`/`ToggleJobDropdown`/`FilteredJobOptions`/`ValueFor` updates, BuildHash inclusion, BeginArgs/CancelArgs/ConfirmArgs wiring.
- Replaces/supersedes: prior chips/filter job UI block.
- Behavior changes: job selection UX changes from chips to classic dropdown (with colors per user choice); confirm flow now requires explicit dropdown choice before the Confirm button enables for setjob.
- Incomplete/untested: filter case-insensitivity and empty-state in dropdown not fully exercised; no multi-client concurrent job set test.

### StaffMenu.razor.scss
- Does: adds `.job-dropdown` / `.job-dropdown-header` / `.job-swatch` / `.job-placeholder` / `.job-chevron` / `.job-dropdown-list` / `.job-filter` / `.job-option` styles (hover/active, compact layout).
- Replaces/supersedes: prior `.chips`/`.job-picker` styles for job arg (if present).
- Behavior changes: visual only (dropdown appearance).
- Incomplete/untested: responsive/overflow behavior on long job lists not verified.

### StaffMenuBridgeService.cs (created new)
- Does: single `[AddonService]` SingletonComponent consolidating all waypoint + settings host RPCs (`RequestWaypointsHost`/`RequestSettingsHost`/`SetWebsiteHost` + filtered `Receive*Client`); on-demand only, explicit "no [Sync] state".
- Replaces/supersedes: WaypointSyncService.cs and StaffSettingsService.cs — "must be removed from repo destination on land".
- Behavior changes: none (Host methods and RPC payloads identical); fewer AddonService instances.
- Incomplete/untested: full hot-reload / multi-server publish test not performed in session.

### Regression risk to existing installs (published daily-use addon)
- Service compaction: "low risk if Host.cs updated atomically (old services removed); high risk if partial publish leaves dangling references to WaypointSyncService/StaffSettingsService on live servers."
- /job addition: new feature only (no regression to kick/ban/existing actions); risk only if `StaffArgKind.Job` enum or job dropdown breaks existing arg-form rendering for other commands.
- All changes confined to desktop staging folder (not monorepo source); existing servers see no change until new publish bundle.

### Everything else a fresh implementer needs to know
- All lifepunchulx modifications targeted only the user-specified desktop publish staging folder; monorepo source at `lifepunchaddons/Code/Addons/lifepunch/adminmenu/` untouched for ulx.
- lpbitcoin audit was 100% read-only on monorepo source; no files written.
- Desktop staging path contains no `.git` (not a repo).
- No git commits, adds, or pushes occurred in that session (main repo working tree clean; no unprompted commits per rules).
- /job dropdown UI chosen as "classic compact with colors" per explicit user selection in session.
- Editor testing / flatgrass proof / Host Play steps noted in UPLOAD_README but not executed.
- lpbitcoin uses Guid linking (no NetDict yet); compaction opportunities identified but not applied.
