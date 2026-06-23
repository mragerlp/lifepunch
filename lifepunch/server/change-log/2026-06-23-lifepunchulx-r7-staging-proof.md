# Server Change Record — lifepunchulx r7 + s&box staging proof

Date: 2026-06-23  
Server: lifepunchdevelopment (Blue / lifepunchnet, port 27016)  
Changed by: Bloodwave + Blue Cursor (staging SteamCMD)  
Reviewed by: Bloodwave (in-game menu confirmed)

## Portal Area

- Addon: `lifepunchulx` · `019ee8ed-2bba-7f7a-8836-09b70b816722` · **revision 7** (13 code files)
- Gamemode: **LIFEPUNCH™ Development** · `019eca7a-d259-747f-9670-c6642e0d3c19`
- Risk: high (engine branch + addon mount)

## Problem

After latest s&box **release** update, `dxrp-server.cs` addon mount hit whitelist/mounter failures. Client join showed `Unknown Command` for `lifepunchulx` / `menu` / `ulx`. Portal r7 publish was correct; release engine path was not.

Dxura (Dimmer): **use staging** — broken in release.

## Change

Before:

```text
lifepunchnet: steamcmd app_update 1892930 validate (release)
VENGEANCE client: s&box release branch
Result: addon assembly not mounted on client; commands missing
```

After:

```text
lifepunchnet:
  steamcmd +login anonymous +app_update 1892930 -beta staging validate +quit
  copy sbox-server.* → C:\S&BOX DXRP Server\
  Fix-LifepunchnetSteamClient.ps1 (RDP user)
  server2_start.bat / dotnet run dxrp-server.cs (unchanged)

VENGEANCE client: Steam → Betas → staging

Gamemode: lifepunchulx pinned revision 7 on Development
```

## Approval

- Owner approval required: yes
- Owner approval received: yes (staging deploy + in-game proof)

## Test And Verification

- [x] Dedicated `[7/7]` on staging binaries
- [x] Join Dev (27016) from staging client
- [x] `lifepunchulx` / menu opens Admin Menu UI
- [ ] Full click-through / permission smoke (follow-up)

## Rollback

```bat
steamcmd.exe +login anonymous +app_update 1892930 validate +quit
```

Recopy `sbox-server.*`; switch client off staging. Re-test when Facepunch fixes release mounter.

## Do Not

- Run `auto_update.bat` on lifepunchnet without `-UseStagingBranch` — reverts to release
- Run `auto_update_all.bat` unless owner wants Official 70p on staging too

## Related

- `lifepunch/addons/docs/SBOX_ENGINE_PATCHES.md` §26.06.23
- `lifepunch/gamemode/config/addon-revisions.json` (lifepunchulx r7)
