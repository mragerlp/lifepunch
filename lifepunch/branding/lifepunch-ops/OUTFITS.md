# Hacker Job — machine uniforms

The voice pipeline and ops consoles are a real operation. Each machine wears an **outfit**
from the Hacker Job art set — their uniform, not a generic theme.

## Cast

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

## Asset parity

| Cornerman | VENGEANCE | lifepunchnet |
|-----------|-----------|--------------|
| `cornermanappicon.png` | `vengeanceappicon.png` | `lifepunchnetappicon.png` |
| `cornermanconsole.png` | `vengeanceconsole.png` | `lifepunchnetconsole.png` |
| `cornermanscreen.png` | `vengeanceterminal.png` | `lifepunchnetterminal.png` |
| `cornermanbanner.png` | `vengeanceloadingscreen.png` | `lifepunchnetbanner.png` |

Repo copies live under `outfits/<machine>/`. Desktop wallpapers are built from:

- VENGEANCE → `vengeanceterminal.png`
- Cornerman → `cornermanbanner.png`
- lifepunchnet → `lifepunchnetbanner.png`

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

See `THEME.md` for terminal schemes and palette tokens.
