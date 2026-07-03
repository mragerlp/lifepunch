# Government Terminal — lifepunchnet tier spec

Matches **Hacker Terminal** (Cornerman / green) and **Enhanced Hacker Terminal** (VENGEANCE / red).

## Cast mapping

| Tier | Machine | Color | Asset prefix |
|------|---------|-------|--------------|
| Hacker Terminal | Cornerman | Neon green `#00FF7F` | `cornerman*` |
| Enhanced Hacker Terminal | VENGEANCE | Neon red | `vengeance*` |
| Government Terminal | lifepunchnet | Electric cyan `#00D4FF` | `lifepunchnet*` |

## Terminal copy (government)

```text
lifepunch@lifepunch.net:~$ whoami
government
lifepunch@lifepunch.net:~$ ls
citizens  records  surveillance  infrastructure
```

Console variant:

```text
(c) Lifepunch Government Systems. All rights reserved.
C:\GOVERNMENT>
```

Quote window: `Unauthorized access is a threat to national security. - lifepunch.net`

## Taglines

| Asset | Footer |
|-------|--------|
| appicon / terminal / screen | LIFEPUNCH.NET · GOVERNMENT SERVERS · SECURE. CONTROL. SERVE. |
| console | Protecting. Managing. Governing. |
| banner / loadingscreen | SECURE. CONTROL. SERVE. / PROTECTING. MANAGING. GOVERNING. |

## File parity

| Cornerman | VENGEANCE | lifepunchnet |
|-----------|-----------|--------------|
| cornermanappicon.png | vengeanceappicon.png | lifepunchnetappicon.png |
| cornermanconsole.png | vengeanceconsole.png | lifepunchnetconsole.png |
| cornermanscreen.png | vengeanceterminal.png | lifepunchnetterminal.png |
| cornermanbanner.png | vengeanceloadingscreen.png | lifepunchnetbanner.png + lifepunchnetloadingscreen.png |

Reference composite: `lifepunchnetexample.png` (owner layout bible).

## Next (when ready)

- Multi-size `.ico` from `lifepunchnetappicon.png` (mirror `branding/cornerman/cornerman-terminal-icon.ico`)
- `remote-hosts.json` icon → government icon on VENGEANCE
- In-game Hacker Job worldscreen SCSS palette fork (green job UI vs blue gov terminal — separate addon art)
