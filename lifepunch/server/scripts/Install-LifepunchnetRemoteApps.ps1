<#
.SYNOPSIS
  Install community/ops apps on lifepunchnet so VENGEANCE stays lean (run via RDP on Blue).

.DESCRIPTION
  Run ELEVATED on lifepunchnet after git pull. Installs Discord (default) and optional apps via winget.
  Apps run on the hosted box; you use them through lifepunchnet (RDP) with audio on VENGEANCE.

.EXAMPLE
  cd C:\lifepunch\lifepunch-rdp-server\lifepunch\server\scripts
  powershell -ExecutionPolicy Bypass -File .\Install-LifepunchnetRemoteApps.ps1

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\Install-LifepunchnetRemoteApps.ps1 -Apps discord,slack -NoStartup
#>
[CmdletBinding()]
param(
    [ValidateSet('discord', 'slack', 'spotify', 'itunes', 'firefox', 'chrome')]
    [string[]] $Apps = @('discord'),
    [switch] $NoStartup
)

$ErrorActionPreference = 'Stop'

function Write-Step([string]$m) { Write-Host ('==> ' + $m) -ForegroundColor Green }

$wingetIds = @{
    discord = 'Discord.Discord'
    slack   = 'SlackTechnologies.Slack'
    spotify = 'Spotify.Spotify'
    itunes  = 'Apple.iTunes'
    firefox = 'Mozilla.Firefox'
    chrome  = 'Google.Chrome'
}

$startupNames = @{
    discord = 'Discord.lnk'
    slack   = 'Slack.lnk'
    spotify = 'Spotify.lnk'
    itunes  = 'iTunes.lnk'
}

Write-Step 'lifepunchnet remote apps (RAM stays on Blue, not VENGEANCE)'
if ($env:COMPUTERNAME -notmatch '(?i)lifepunchnet') {
    Write-Host "WARN: hostname is $($env:COMPUTERNAME) — intended for lifepunchnet only." -ForegroundColor Yellow
}

$winget = Get-Command winget -ErrorAction SilentlyContinue
if (-not $winget) {
    throw 'winget not found. Install App Installer from Microsoft Store, then re-run.'
}

$appsDir = 'C:\lifepunch\apps'
New-Item -ItemType Directory -Force -Path $appsDir | Out-Null
$startup = [Environment]::GetFolderPath('Startup')

foreach ($app in $Apps) {
    $id = $wingetIds[$app]
    if (-not $id) { continue }
    Write-Step "winget install $id"
    & winget install --id $id --accept-package-agreements --accept-source-agreements --disable-interactivity
    if ($LASTEXITCODE -gt 1) {
        Write-Host "  winget exit $LASTEXITCODE (0/1 = ok or already installed)" -ForegroundColor DarkYellow
    }

    if (-not $NoStartup -and $startupNames.ContainsKey($app)) {
        $exe = switch ($app) {
            'discord' { "${env:LOCALAPPDATA}\Discord\Update.exe" }
            'slack'   { "${env:LOCALAPPDATA}\slack\slack.exe" }
            'spotify' { "${env:APPDATA}\Spotify\Spotify.exe" }
            'itunes'  {
                $candidates = @(
                    "${env:ProgramFiles}\iTunes\iTunes.exe"
                    "${env:ProgramFiles(x86)}\iTunes\iTunes.exe"
                )
                ($candidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1)
            }
        }
        if ($exe -and (Test-Path -LiteralPath $exe)) {
            $lnk = Join-Path $startup $startupNames[$app]
            $shell = New-Object -ComObject WScript.Shell
            $sc = $shell.CreateShortcut($lnk)
            if ($app -eq 'discord') {
                $sc.TargetPath = $exe
                $sc.Arguments = '--processStart Discord.exe'
            }
            else {
                $sc.TargetPath = $exe
            }
            $sc.WorkingDirectory = Split-Path $exe -Parent
            $sc.Save()
            Write-Host "  Startup: $lnk" -ForegroundColor Cyan
        }
    }
}

$readme = @"
# lifepunchnet remote apps

Installed from Install-LifepunchnetRemoteApps.ps1 on $(Get-Date -Format o).

Use from VENGEANCE: double-click **lifepunchnet (RDP)** — audio plays on your desk (audiomode local).

| App | Why on Blue |
|-----|-------------|
| Discord | Community changelog + chat — saves ~500MB–1GB on VENGEANCE |
| Slack | Optional team chat (same pattern) |
| Spotify / iTunes | Optional media (same pattern) |
| Browser | Edge is built-in; extra browsers optional |

Quit local copies on VENGEANCE (tray -> Exit) after this install.
"@
Set-Content -LiteralPath (Join-Path $appsDir 'README.md') -Value $readme -Encoding UTF8

Write-Host ''
Write-Host 'Done. On VENGEANCE: exit local Discord, RDP to lifepunchnet, open Discord there.' -ForegroundColor Cyan
Write-Host 'See lifepunch/docs/REMOTE_APPS_LIFEPUNCHNET.md' -ForegroundColor DarkGray
