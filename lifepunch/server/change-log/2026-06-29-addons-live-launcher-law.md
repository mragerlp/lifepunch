# Server Change Record — Addons live; launcher law for both servers

Date: 2026-06-29
Servers: lifepunchmainserver, lifepunchdevelopment
Changed by: Bloodwave / VENGEANCE agent
Reviewed by: (owner)

## Portal Area

- Page: DXRP operator docs + lifepunchnet on-box launch
- Field or action: Mandatory `dxrp-server.cs` path for portal addon fetch
- Risk: high (production pulse, addon mount, player-facing content)

## Change

DXRP addons are **live on the portal**. Dedicated hosts must follow [Launching Server with Addons](https://docs.dxrp.net/launching-server-with-addons):

- **No** bare `sbox-server.exe +game dxura.rp`
- **Yes** `dotnet run dxrp-server.cs --token <portal token>` from install root beside `sbox-server.dll`
- Portal **Add to Server** + gamemode pins drive what the API downloads each startup

Repo canon added: `lifepunch/server/LAUNCHING_SERVER_WITH_ADDONS.md`

LifePunch wrappers (unchanged flow, clarified law):

| Server | Start |
|--------|-------|
| Official 70p | `C:\S&BOX DXRP Server\server1_start.bat` |
| Development | `C:\S&BOX DXRP Server\server2_start.bat` |

## Approval

- Owner approval required: yes (production cutover on lifepunchnet if Official still on legacy bat)
- Owner approval received: pending on-box verify
- Approval notes: Dev already on launcher; Official migration was planned 2026-06-15 — now required for live addons on both

## Test And Verification

- Tested on lifepunchdevelopment first: yes (existing Dev path)
- Validation performed: runbook + start-bat .NET 10 / dxrp-server.cs preflight checks
- Observed result: pending Official `[7/7]` + join smoke with portal-pinned LifePunch addons

## Rollback

Stop `dotnet run dxrp-server.cs`; only revert to legacy bare binary if Dxura republishes `dxura.rp` code archive **and** addon API path is no longer required (unlikely).

## Evidence

- Upstream: https://docs.dxrp.net/launching-server-with-addons
- Repo: `lifepunch/server/LAUNCHING_SERVER_WITH_ADDONS.md`
- Related: `lifepunch/server/change-log/2026-06-15-official-dxrp-server-launcher.md`
