# lifepunchnet — Government Terminal uniform (ready to deploy)

**Cosmetic only.** Does not touch Whisper `:9000`, watchdog `:9101`, or session hub `:9102`.

## What you are deploying

| Item | Value |
|------|-------|
| Tier | Government Terminal |
| Scheme | `LifePunch Ops` (cyan) |
| Prompt | `lifepunch@lifepunch.net:path$` |
| Banner | `L I F E P U N C H . N E T` |
| Taglines | SECURE. CONTROL. SERVE. / PROTECTING. MANAGING. GOVERNING. |
| Wallpaper | `wallpapers/lifepunch-ops-wallpaper-lifepunchnet.png` |
| Accent | `#00D4FF` |

Pack path on-box after copy: `C:\lifepunch\branding\lifepunch-ops\`

## Option A — RDP (use when SSH :22 times out)

### 1. Copy pack onto lifepunchnet

From VENGEANCE, copy this entire folder to the server:

```
C:\Users\jared\Projects\lifepunchaddons\lifepunch\branding\lifepunch-ops\
  →  C:\lifepunch\branding\lifepunch-ops\
```

Or use the zip Bloodwave prepared:

```
C:\Users\jared\Projects\lifepunchaddons\lifepunch\branding\lifepunch-ops-deploy.zip
  →  extract to C:\lifepunch\branding\
```

### 2. Run on lifepunchnet (PowerShell)

```powershell
cd C:\lifepunch\branding\lifepunch-ops
powershell -ExecutionPolicy Bypass -File .\Apply-LifePunchOpsConsole.ps1 -Machine lifepunchnet
```

### 3. If oh-my-posh is missing

```powershell
winget install --id JanDeDobbeleer.OhMyPosh -e --source winget --accept-source-agreements --accept-package-agreements
```

Then re-run the apply script.

### 4. Verify (new Windows Terminal tab)

- [ ] Cyan **LifePunch Ops** color scheme
- [ ] Prompt shows `lifepunch@lifepunch.net`
- [ ] Banner: `L I F E P U N C H . N E T` + government taglines
- [ ] Desktop wallpaper = government HUD banner
- [ ] Cyan window accent (sign out/in if title bars did not repaint)

## Option B — SSH (when port 22 is open)

From VENGEANCE:

```powershell
scp -r C:\Users\jared\Projects\lifepunchaddons\lifepunch\branding\lifepunch-ops jared@205.209.104.22:C:/lifepunch/branding/
ssh jared@205.209.104.22 "powershell -ExecutionPolicy Bypass -File C:\lifepunch\branding\lifepunch-ops\Apply-LifePunchOpsConsole.ps1 -Machine lifepunchnet"
```

## Paste to lifepunchnet agent

```text
Dress lifepunchnet in the Government Terminal uniform. Copy lifepunch-ops to C:\lifepunch\branding\lifepunch-ops (full folder from VENGEANCE monorepo or lifepunch-ops-deploy.zip). Run: powershell -ExecutionPolicy Bypass -File C:\lifepunch\branding\lifepunch-ops\Apply-LifePunchOpsConsole.ps1 -Machine lifepunchnet. Open a new terminal — expect cyan LifePunch Ops, lifepunch@lifepunch.net prompt, LIFEPUNCH.NET banner. Cosmetic only; do not restart or reconfigure Whisper, watchdog, or session hub.
```

Monorepo commit with this pack: `313c692` or later on `main`.
