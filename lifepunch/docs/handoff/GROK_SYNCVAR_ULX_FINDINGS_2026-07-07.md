# GROK_SYNCVAR_ULX_FINDINGS_2026-07-07

> **Location note (future greps / agents):**  
> This file lives at workspace-root `handoff/GROK_SYNCVAR_ULX_FINDINGS_2026-07-07.md`  
> (created on request for this specific Grok handoff).  
> All other session briefs live under `lifepunch/docs/handoff/`.  
> Two handoff folders exist. Do not assume a single location when grepping.  
> Consolidate on the cleanup list. Review this file where it actually is.

---

**SECTION 1 — lpbitcoin SyncVar audit (read-only findings):**

- **Entity: LpBitcoinHubEntity**
  - File path: lifepunchaddons/Code/Addons/lifepunch/lpbitcoin/bitcoinhub/code/components/LpBitcoinHubEntity.cs
  - Properties:
    - IsPowered (bool):
      - Genuinely required for client replication: yes (client visuals, power state in HashdPanel/terminal UI)
      - Excess: no
      - Proposed change: move into HubCoreState struct (one Sync property)
      - Risk note: client power visuals and UI toggles may see delayed or batched updates if struct dirtying differs from per-field
    - AccessPinIsSet (bool):
      - Genuinely required for client replication: yes (UI pin gate display)
      - Excess: no
      - Proposed change: move into HubSecurityState struct
      - Risk note: client pin UI state may desync on partial updates
    - AccessPinHash (int):
      - Genuinely required for client replication: no (host-only verification; client only sends raw pin)
      - Excess: yes (host-only state)
      - Proposed change: remove [Sync]; keep host-only field or internal
      - Risk note: none (client never reads hash for logic)
    - Owner (long):
      - Genuinely required for client replication: yes (ownership checks in UI)
      - Excess: no
      - Proposed change: move into HubSecurityState struct
      - Risk note: client ownership-derived UI (e.g. manage buttons) may batch-update
    - HubWalletBtc (float):
      - Genuinely required for client replication: yes (balance display in hub panel)
      - Excess: no
      - Proposed change: move into HubCoreState struct
      - Risk note: live wallet updates in UI may batch instead of per-field
    - AlertFeed (string):
      - Genuinely required for client replication: yes (serialized alerts for logs panel)
      - Excess: no (already compacted)
      - Proposed change: keep as-is or migrate to NetList<LpBitcoinHubAlert> if supported
      - Risk note: list truncation or parse errors in UI if serialization changes
    - UnreadAlertCount (int):
      - Genuinely required for client replication: yes (badge count in UI)
      - Excess: no
      - Proposed change: move into HubAlertsState struct with AlertFeed
      - Risk note: badge may not increment independently of full feed refresh

- **Entity: LpBitcoinTerminalEntity**
  - File path: lifepunchaddons/Code/Addons/lifepunch/bitcoinmining/LpBitcoinTerminalEntity.cs
  - Properties:
    - LinkedHubId (Guid):
      - Genuinely required for client replication: yes (client resolves linked hub for commands/UI)
      - Excess: no
      - Proposed change: keep or include in TerminalLinkState struct
      - Risk note: unlink/link flows in terminal UI may delay if grouped

- **Entity: LpBitcoinRackEntity**
  - File path: lifepunchaddons/Code/Addons/lifepunch/bitcoinmining/LpBitcoinRackEntity.cs
  - Properties:
    - LinkedHubId (Guid):
      - Genuinely required for client replication: yes (association for hub queries)
      - Excess: no
      - Proposed change: keep or move to RackLinkState struct
      - Risk note: rack-to-hub visuals/commands may stale briefly
    - IsMining (bool):
      - Genuinely required for client replication: yes (status display, rate calc)
      - Excess: no
      - Proposed change: move into RackMiningState struct
      - Risk note: mining on/off indicators in panel may batch-update
    - BitcoinAmount (float):
      - Genuinely required for client replication: yes (balance display, sell/deposit)
      - Excess: no
      - Proposed change: move into RackMiningState struct
      - Risk note: live balance updates (payouts) in UI may not be per-field granular
    - ClockGhz (float):
      - Genuinely required for client replication: yes (rate display)
      - Excess: no
      - Proposed change: move into RackUpgrades struct with levels/cores
      - Risk note: displayed rate in panel may update only on full struct change
    - CoreCount (int):
      - Genuinely required for client replication: yes (rate display)
      - Excess: no
      - Proposed change: move into RackUpgrades struct
      - Risk note: same as ClockGhz
    - CpuUpgradeLevel (int):
      - Genuinely required for client replication: yes (upgrade progress UI)
      - Excess: no
      - Proposed change: move into RackUpgrades struct
      - Risk note: upgrade UI progress may not reflect independently
    - CoreUpgradeLevel (int):
      - Genuinely required for client replication: yes (upgrade progress UI)
      - Excess: no
      - Proposed change: move into RackUpgrades struct
      - Risk note: same as CpuUpgradeLevel
    - MiningProgress (float):
      - Genuinely required for client replication: no (derivable on client from _sincePayout + rate when IsMining true)
      - Excess: yes (UI-only field)
      - Proposed change: remove [Sync]; compute client-side in panel
      - Risk note: progress bar in UI may drift if client timing differs from host

- Entities NOT audited (coverage gaps):
  - LpBitcoinHubVisuals.cs
  - LpBitcoinRackVisuals.cs
  - LpHashdPanel.razor
  - LpBitcoinTerminalPanel.razor
  - LpBitcoinPortalEconomySync.cs
  - LpBitcoinPowerLeds.cs
  - LpBitcoinPowerAnim.cs
  - LpBitcoinUi.cs
  - LpBitcoinTerminalLogPanel.cs
  - LpBitcoinTerminalUiHost.cs
  - LpBitcoinTerminalScreen.cs
  - LpBitcoinTerminalCommands.cs
  - all prefab/material/asset files
  - any BaseEntity overrides or shared LifePunch* components pulled into bitcoinmining

- Internal todos verbatim:
  - id: audit-lpbitcoin-syncvars content: Audit all [Sync(FromHost)] and networked state in lpbitcoin (Hub, Terminal, GPU Rack) entities and supporting components. status: completed
  - id: list-all-sync-properties content: List every individual Sync property by entity with type and purpose. status: completed
  - id: identify-compaction-opportunities content: Identify fields that can be grouped into structs or moved to NetDict<Guid, State> per Dimmer advice and machine standard. status: completed
  - id: check-for-netdict-usage content: Confirm no NetDict / complex net collections are used yet for machine states. status: completed
  - id: check-alerts-compaction content: Review how alerts are handled (string serialization) as precedent for compaction. status: completed
  - id: report-status-and-recommend content: Provide clear status report + recommended next steps for cleaning before further Phase work. status: completed
  - id: consider-followup-compaction-plan content: If owner approves, create DECISION or plan for struct compaction + possible NetDict for racks on hub. status: pending

**SECTION 2 — lifepunchulx additions (the desktop staging-folder work):**

- File: StaffMenuActions.cs
  - Staging path: C:\Users\jared\desktop\lifepunch\addons\publish\lifepunchulx\upload\Code\Addons\lifepunch\lifepunchulx\StaffMenuActions.cs
  - Intended repo destination path: lifepunchaddons/Code/Addons/lifepunch/adminmenu/StaffMenuActions.cs
  - What it does: adds setjob StaffAction using StaffArgKind.Job (enables /job dropdown in arg-form with player select + confirm flow)
  - Replaces/supersedes: none (extends existing catalog)
  - Behavior changes: new "Set Job" entry appears in Commands tab for users with command.job.manage; existing setjob (if present) now uses dropdown instead of prior chips UI
  - Incomplete or untested: dropdown population + confirm dispatch not run in full flatgrass/Host Play; relies on AssignableJobs() from host

- File: StaffMenuHost.cs
  - Staging path: C:\Users\jared\desktop\lifepunch\addons\publish\lifepunchulx\upload\Code\Addons\lifepunch\lifepunchulx\StaffMenuHost.cs
  - Intended repo destination path: lifepunchaddons/Code/Addons/lifepunch/adminmenu/StaffMenuHost.cs
  - What it does: (1) adds StaffJobOption record + AssignableJobs() for /job dropdown data (local stub + GameModeJobs path); (2) updates all waypoint/settings calls to single StaffMenuBridgeService
  - Replaces/supersedes: (for compaction) WaypointSyncService.cs and StaffSettingsService.cs
  - Behavior changes: none to exposed API or command behavior; /job now has live job list with colors; old two services no longer instantiated
  - Incomplete or untested: local stub list vs real GameModeJobs parity not verified on target server; no owner-permission regression run

- File: StaffMenu.razor
  - Staging path: C:\Users\jared\desktop\lifepunch\addons\publish\lifepunchulx\upload\Code\Addons\lifepunch\lifepunchulx\StaffMenu.razor
  - Intended repo destination path: lifepunchaddons/Code/Addons/lifepunch/adminmenu/StaffMenu.razor
  - What it does: implements compact searchable dropdown for StaffArgKind.Job (filter TextEntry, color swatches, active state, header chevron) replacing prior chips; adds _job/_jobFilter/_jobDropdownOpen state, SetJob/ToggleJobDropdown/FilteredJobOptions/ValueFor updates, BuildHash inclusion, BeginArgs/CancelArgs/ConfirmArgs wiring
  - Replaces/supersedes: prior chips/filter job UI block
  - Behavior changes: job selection UX changes from chips to classic dropdown (with colors per user choice); confirm flow now requires explicit dropdown choice before Confirm button enables for setjob
  - Incomplete or untested: filter case-insensitivity and empty-state in dropdown not fully exercised; no multi-client concurrent job set test

- File: StaffMenu.razor.scss
  - Staging path: C:\Users\jared\desktop\lifepunch\addons\publish\lifepunchulx\upload\Code\Addons\lifepunch\lifepunchulx\StaffMenu.razor.scss
  - Intended repo destination path: lifepunchaddons/Code/Addons/lifepunch/adminmenu/StaffMenu.razor.scss
  - What it does: adds .job-dropdown / .job-dropdown-header / .job-swatch / .job-placeholder / .job-chevron / .job-dropdown-list / .job-filter / .job-option styles (hover/active, compact layout)
  - Replaces/supersedes: prior .chips/.job-picker styles for job arg (if present)
  - Behavior changes: visual only (dropdown appearance)
  - Incomplete or untested: responsive/overflow behavior on long job lists not verified

- File: StaffMenuBridgeService.cs
  - Staging path: C:\Users\jared\desktop\lifepunch\addons\publish\lifepunchulx\upload\Code\Addons\lifepunch\lifepunchulx\StaffMenuBridgeService.cs (created)
  - Intended repo destination path: lifepunchaddons/Code/Addons/lifepunch/adminmenu/StaffMenuBridgeService.cs
  - What it does: single [AddonService] SingletonComponent consolidating all waypoint + settings host RPCs (RequestWaypointsHost/RequestSettingsHost/SetWebsiteHost + filtered Receive*Client); on-demand only, explicit "no [Sync] state"
  - Replaces/supersedes: WaypointSyncService.cs and StaffSettingsService.cs (must be removed from repo destination on land)
  - Behavior changes: none (Host methods and RPC payloads identical); fewer AddonService instances
  - Incomplete or untested: full hot-reload / multi-server publish test not performed in session

- Anything with regression risk to existing installs (published daily-use addon):
  - Service compaction: low risk if Host.cs updated atomically (old services removed); high risk if partial publish leaves dangling references to WaypointSyncService/StaffSettingsService on live servers
  - /job addition: new feature only (no regression to kick/ban/ existing actions); risk only if StaffArgKind.Job enum or job dropdown breaks existing arg-form rendering for other commands
  - All changes confined to desktop staging folder (not monorepo source); existing servers see no change until new publish bundle

- Anything else from this session a fresh implementer needs to know:
  - All lifepunchulx modifications targeted only user-specified desktop publish staging folder (C:\Users\jared\desktop\lifepunch\addons\publish\lifepunchulx\upload\...); monorepo source at lifepunchaddons/Code/Addons/lifepunch/adminmenu/ untouched for ulx
  - lpbitcoin audit was 100% read-only on monorepo source; no files written
  - Desktop staging path contains no .git (not a repo)
  - No git commits, adds, or pushes occurred in session (main repo working tree clean; no unprompted commits per rules)
  - /job dropdown UI chosen as "classic compact with colors" per explicit user selection in session
  - Editor testing / flatgrass proof / Host Play steps noted in UPLOAD_README but not executed here
  - lpbitcoin uses Guid linking (no NetDict yet); compaction opportunities identified but not applied
