# Server Change Record — s&box 26.06.10 engine update

Date: 2026-06-17
Server: lifepunchdevelopment + lifepunchmainserver
Changed by: VENGEANCE agent (owner-requested)
Reviewed by: (owner after RDP paste)

## Portal Area

- Page: DXRP Servers + lifepunchnet on-box dedicated hosts
- Field or action: Engine version 26.05.20 → 26.06.10+
- Risk: high (player join / version mismatch if skipped)

## Change

Before:

```text
Portal Version column: 26.05.20 (both servers)
VENGEANCE editor: 26.06.10a
```

After:

```text
steamcmd app_update 1892930 validate on lifepunchnet
dxrp-server.cs restart Dev → Official (-IncludeOfficial)
Portal Version: 26.06.10+
```

Reason: s&box 26.06.10 shipped 2026-06-10 (precompiled DLLs, binary compile refs, texture color-space). Dedicated hosts must match editor or clients risk version mismatch.

## Approval

- Owner approval required: yes
- Owner approval received: yes (explicit "make sure our servers are updated")
- Repo automation: `Update-LifepunchnetSboxServers.ps1` + `Invoke-LifepunchnetServerUpdate.ps1`

## Test And Verification

- Tested on lifepunchdevelopment first: required (default script behavior)
- Validation performed: pending on-box paste + portal Last Pulsed / Version
- Observed result: pending

## Rollback

```text
Re-run previous sbox-server.dll backup from install root (if copied pre-update).
Or steamcmd validate again; restart dxrp-server.cs.
```

## Evidence

- Script: lifepunch/server/dxrp-host/scripts/Update-LifepunchnetSboxServers.ps1
- Dispatch: lifepunch/scripts/Invoke-LifepunchnetServerUpdate.ps1
- Engine gate: lifepunch/addons/docs/SBOX_ENGINE_PATCHES.md §26.06.10
