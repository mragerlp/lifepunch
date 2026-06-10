# Deploy uniforms to lifepunchnet

Canonical **Government Terminal** art lives in OneDrive (`Government Terminal/lifepunchnet`)
and is copied into `outfits/lifepunchnet/` via `Sync-OutfitsFromOneDrive.ps1` on VENGEANCE.

When the hosted box is reachable, dress lifepunchnet from the monorepo pack.

## RDP handoff (recommended when SSH :22 times out)

1. RDP to lifepunchnet (`205.209.104.22`) as `jared`.
2. Copy `lifepunch\branding\lifepunch-ops\` from the monorepo to `C:\lifepunch\branding\lifepunch-ops\` on-box.
3. Elevated PowerShell on lifepunchnet:

```powershell
cd C:\lifepunch\branding\lifepunch-ops
powershell -ExecutionPolicy Bypass -File .\Apply-LifePunchOpsConsole.ps1 -Machine lifepunchnet
```

4. Open a new terminal tab — expect cyan **LifePunch Ops**, `lifepunch@lifepunch.net` prompt, government banner.

## SCP (when port 22 is open)

```powershell
scp -r C:\Users\jared\Projects\lifepunchaddons\lifepunch\branding\lifepunch-ops `
  jared@205.209.104.22:C:/lifepunch/branding/
```

Then run `Apply-LifePunchOpsConsole.ps1 -Machine lifepunchnet` on-box.

## Refresh art first

On VENGEANCE, before copying to lifepunchnet:

```powershell
cd <repo>\lifepunch\branding\lifepunch-ops
powershell -ExecutionPolicy Bypass -File .\Sync-OutfitsFromOneDrive.ps1
```

See `OUTFITS.md` for the full Hacker Job cast and OneDrive paths.
