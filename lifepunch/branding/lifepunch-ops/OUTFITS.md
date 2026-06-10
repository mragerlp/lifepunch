# Hacker Job — machine uniforms

The voice pipeline and ops consoles are a real operation — nodes in the **LifePunch web**.
Each machine wears an **outfit** from the Hacker Job art set: their uniform, not a generic theme.

## Cast (web nodes)

| Tier | Machine | Role | Color | Prompt |
|------|---------|------|-------|--------|
| **Hacker Terminal** | Cornerman | Local AI / mic / relay | Neon green `#00FF7F` | `cornerman@cornerman:~$` |
| **Enhanced Hacker Terminal** | VENGEANCE | Desk / Cursor / monorepo | Neon red `#E4002B` | `vengeance@vengeance:~$` |
| **Government Terminal** | lifepunchnet | Hosted Whisper, watchdog, sessions | Electric cyan `#00D4FF` | `lifepunch@lifepunch.net:~$` |

## Canonical outfit folders (OneDrive)

Artist source — edit here first, then sync into the repo:

| Machine | Path |
|---------|------|
| VENGEANCE | `%USERPROFILE%\OneDrive\Desktop\Hacker Job\Enhanced Hacker Terminal\vengeance` |
| Cornerman | `%USERPROFILE%\OneDrive\Desktop\Hacker Job\Hacker Terminal\cornerman` |
| lifepunchnet | `%USERPROFILE%\OneDrive\Desktop\Hacker Job\Government Terminal\lifepunchnet` |

## Desktop wallpapers (uniform)

Same HUD layout on every machine — color matches the tier. Edit in OneDrive first:

| Machine | OneDrive source | Repo output |
|---------|-----------------|-------------|
| VENGEANCE | `%USERPROFILE%\OneDrive\Desktop\wallpapers\vengeancewallpaper.png` | `wallpapers/lifepunch-ops-wallpaper-vengeance.png` |
| Cornerman | `...\wallpapers\cornermanwallpaper.png` | `wallpapers/lifepunch-ops-wallpaper-cornerman.png` |
| lifepunchnet | `...\wallpapers\lifepunchnetwallpaper.png` | `wallpapers/lifepunch-ops-wallpaper-lifepunchnet.png` |

`Sync-OutfitsFromOneDrive.ps1` pulls outfits from Hacker Job and wallpapers from `Desktop\wallpapers`.

## Asset parity

| Cornerman | VENGEANCE | lifepunchnet |
|-----------|-----------|--------------|
| `cornermanappicon.png` | `vengeanceappicon.png` | `lifepunchnetappicon.png` |
| `cornermanconsole.png` | `vengeanceconsole.png` | `lifepunchnetconsole.png` |
| `cornermanscreen.png` | `vengeanceterminal.png` | `lifepunchnetterminal.png` |
| `cornermanbanner.png` | `vengeanceloadingscreen.png` | `lifepunchnetbanner.png` |
| `cornermanconsole.png` | `vengeanceconsole.png` | `lifepunchnetconsole.png` |

**Console uniform** (cmd + PowerShell + Windows Terminal): pure **black** background, single accent
text color per node — see outfit `*console.png`. Applied by `Apply-LifePunchOpsConsole.ps1`
(conhost registry + WT scheme). PowerShell opens with the console copyright line from `nodes.json`.

Repo copies live under `outfits/<machine>/`.

## Taglines (wear with pride)

| Machine | Primary | Secondary |
|---------|---------|-----------|
| VENGEANCE | PLAN. EXECUTE. DESTROY. | — |
| Cornerman | BUILD. AUTOMATE. ELEVATE. | — |
| lifepunchnet | SECURE. CONTROL. SERVE. | PROTECTING. MANAGING. GOVERNING. |

Government terminal copy (lifepunchnet):

```text
lifepunch@lifepunch.net:~$ whoami
government
lifepunch@lifepunch.net:~$ ls
citizens  records  surveillance  infrastructure
```

Full government tier spec: `outfits/lifepunchnet/TIER-SPEC.md`

## Sync → apply

```powershell
cd <repo>\lifepunch\branding\lifepunch-ops
powershell -ExecutionPolicy Bypass -File .\Sync-OutfitsFromOneDrive.ps1
powershell -ExecutionPolicy Bypass -File .\Apply-LifePunchOpsConsole.ps1 -Machine vengeance -NodeIp <LAN-IP>
powershell -ExecutionPolicy Bypass -File .\Apply-LifePunchOpsConsole.ps1 -Machine cornerman -NodeIp <LAN-IP>
# lifepunchnet: copy pack on-box or RDP, then -Machine lifepunchnet
```

**Uniform apply** sets: dark mode (system + apps), per-node **colored title bars**,
**gray taskbar**, and wallpaper. RDP sessions inherit dark theme from the remote box after apply.

See `THEME.md` for terminal schemes and palette tokens.

## Desktop shortcut icons (VENGEANCE)

Shortcuts use **tier icons** so you can see where they lead without reading the name:

| Icon color | Tier | Paired shortcuts |
|------------|------|------------------|
| Tri-stack (all 3) | **Universal** | LifePunch — Start Day, Voice Preflight |
| Red | **VENGEANCE** | LifePunch Voice Comms |
| Green | **Cornerman** | Cornerman (RDP), Talk to Vengeance |
| Blue | **lifepunchnet** | lifepunchnet (RDP) |

Canonical PNGs: `lifepunch/branding/shortcut-icons/`. Refresh after pull:

```powershell
cd <repo>\lifepunch\scripts
powershell -ExecutionPolicy Bypass -File .\Install-LifePunchShortcutIcons.ps1
```
