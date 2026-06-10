# Sync lifepunch-ops assets from lifepunchnet

When RDP/SSH to **lifepunchnet** (`205.209.104.22`) is available, refresh the monorepo from the canonical on-box folder:

**Source (lifepunchnet):** `C:\lifepunch\branding\lifepunch-ops\`  
**Destination (monorepo):** `lifepunch/branding/lifepunch-ops/`

## RDP handoff (recommended)

1. RDP to lifepunchnet as `jared`.
2. Copy the entire `C:\lifepunch\branding\lifepunch-ops\` folder to VENGEANCE (clipboard, OneDrive, or shared drive).
3. On VENGEANCE, replace `lifepunch\branding\lifepunch-ops\` in the monorepo (keep `nodes.json` if only wallpapers differ).
4. Commit + push to GitHub.
5. Re-run `Apply-LifePunchOpsConsole.ps1` on each node.

## SCP (when port 22 is open)

From VENGEANCE (adjust user/host if needed):

```powershell
scp -r jared@205.209.104.22:C:/lifepunch/branding/lifepunch-ops/* `
  C:\Users\jared\Projects\lifepunchaddons\lifepunch\branding\lifepunch-ops\
```

## After sync

```powershell
cd C:\Users\jared\Projects\lifepunchaddons\lifepunch\branding\lifepunch-ops
powershell -ExecutionPolicy Bypass -File .\Apply-LifePunchOpsConsole.ps1 -Machine vengeance -NodeIp <desk-LAN-IP>
```

Cornerman: same script with `-Machine cornerman`. lifepunchnet: already applied on-box.
