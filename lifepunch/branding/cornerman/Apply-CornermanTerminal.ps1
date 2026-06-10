<#
.SYNOPSIS
  Apply the "Cornerman // Operations Console" terminal look to a Windows machine:
  Windows Terminal color scheme + defaults, the Spring-Green system accent (green
  window borders), and an oh-my-posh prompt for PowerShell.

.DESCRIPTION
  Idempotent and self-contained: reads its sibling cornerman.omp.json /
  windows-terminal-cornerman.json, so it works from any clone of the monorepo.
  Cosmetic only; changes nothing about the security posture.

.PARAMETER SkipAccent
  Do not touch the Windows accent color / window-border setting.

.PARAMETER SkipOhMyPosh
  Do not install oh-my-posh or modify the PowerShell profile.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\Apply-CornermanTerminal.ps1
#>
[CmdletBinding()]
param(
    [switch]$SkipAccent,
    [switch]$SkipOhMyPosh
)

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$themePath  = Join-Path $here 'cornerman.omp.json'
$schemePath = Join-Path $here 'windows-terminal-cornerman.json'

function Write-Step($m) { Write-Host "==> $m" -ForegroundColor Green }
function Write-Note($m) { Write-Host "    $m" -ForegroundColor DarkGray }

# ---------------------------------------------------------------------------
# 1. Windows Terminal: inject the Cornerman Ops scheme + set profile defaults
# ---------------------------------------------------------------------------
Write-Step "Windows Terminal scheme + defaults"
$wtCandidates = @(
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json",
    "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
)
$wtPath = $wtCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1

if (-not $wtPath) {
    Write-Note "Windows Terminal settings.json not found; skipping (install Windows Terminal, then re-run)."
}
elseif (-not (Test-Path -LiteralPath $schemePath)) {
    Write-Note "Missing $schemePath; skipping scheme injection."
}
else {
    $scheme = Get-Content -LiteralPath $schemePath -Raw | ConvertFrom-Json
    if ($scheme.PSObject.Properties.Name -contains '_comment') { $scheme.PSObject.Properties.Remove('_comment') }

    $settings = Get-Content -LiteralPath $wtPath -Raw | ConvertFrom-Json

    if (-not $settings.schemes) { $settings | Add-Member -NotePropertyName schemes -NotePropertyValue @() -Force }
    $settings.schemes = @($settings.schemes | Where-Object { $_.name -ne $scheme.name }) + $scheme

    if (-not $settings.profiles) { $settings | Add-Member -NotePropertyName profiles -NotePropertyValue ([pscustomobject]@{}) -Force }
    if (-not $settings.profiles.defaults) {
        $settings.profiles | Add-Member -NotePropertyName defaults -NotePropertyValue ([pscustomobject]@{}) -Force
    }
    $d = $settings.profiles.defaults
    $d | Add-Member -NotePropertyName colorScheme -NotePropertyValue $scheme.name -Force
    $d | Add-Member -NotePropertyName cursorShape -NotePropertyValue 'filledBox' -Force
    $d | Add-Member -NotePropertyName font -NotePropertyValue ([pscustomobject]@{ face = 'Cascadia Code'; size = 11 }) -Force
    $d | Add-Member -NotePropertyName useAcrylic -NotePropertyValue $false -Force

    $settings | ConvertTo-Json -Depth 32 | Set-Content -LiteralPath $wtPath -Encoding UTF8
    Write-Note "Applied '$($scheme.name)' to $wtPath (open a new tab to see it)."
}

# ---------------------------------------------------------------------------
# 2. System accent = Spring Green (#00FF7F) + show on title bars / borders
# ---------------------------------------------------------------------------
if (-not $SkipAccent) {
    Write-Step "Windows accent = #00FF7F + green window borders"
    # R=00 G=FF B=7F. DWM AccentColor / Explorer AccentColorMenu use 0xAABBGGRR.
    $accentABGR = 0xFF7FFF00
    # DWM ColorizationColor uses 0xAARRGGBB.
    $colorARGB  = 0xFF00FF7F

    $dwm = 'HKCU:\Software\Microsoft\Windows\DWM'
    New-Item -Path $dwm -Force | Out-Null
    Set-ItemProperty -Path $dwm -Name AccentColor              -Type DWord -Value $accentABGR
    Set-ItemProperty -Path $dwm -Name ColorizationColor        -Type DWord -Value $colorARGB
    Set-ItemProperty -Path $dwm -Name ColorizationAfterglow    -Type DWord -Value $colorARGB
    Set-ItemProperty -Path $dwm -Name ColorPrevalence          -Type DWord -Value 1
    Set-ItemProperty -Path $dwm -Name EnableWindowColorization -Type DWord -Value 1

    # Build an 8-shade AccentPalette (lightest to darkest), RGBA per entry.
    $base = @(0, 255, 127)
    $factors = @(1.6, 1.4, 1.2, 1.0, 0.8, 0.6, 0.45, 0.3)
    $palette = @()
    foreach ($f in $factors) {
        foreach ($c in $base) {
            $v = [math]::Round($c * $f)
            if ($v -gt 255) { $v = 255 }
            $palette += [byte]$v
        }
        $palette += [byte]255
    }
    $accent = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent'
    New-Item -Path $accent -Force | Out-Null
    Set-ItemProperty -Path $accent -Name AccentPalette   -Type Binary -Value ([byte[]]$palette)
    Set-ItemProperty -Path $accent -Name AccentColorMenu -Type DWord  -Value $accentABGR
    Set-ItemProperty -Path $accent -Name StartColorMenu  -Type DWord  -Value $accentABGR

    Write-Note "Set. Restart Explorer (or sign out/in) for borders to fully repaint."
}
else { Write-Note "Skipping accent (per -SkipAccent)." }

# ---------------------------------------------------------------------------
# 3. oh-my-posh prompt for PowerShell
# ---------------------------------------------------------------------------
if (-not $SkipOhMyPosh) {
    Write-Step "oh-my-posh prompt"
    $omp = Get-Command oh-my-posh -ErrorAction SilentlyContinue
    if (-not $omp) {
        $winget = Get-Command winget -ErrorAction SilentlyContinue
        if ($winget) {
            Write-Note "Installing oh-my-posh via winget..."
            winget install --id JanDeDobbeleer.OhMyPosh -e --source winget --accept-source-agreements --accept-package-agreements
            $env:Path += ";$env:LOCALAPPDATA\Programs\oh-my-posh\bin"
        }
        else {
            Write-Note "winget not found; install oh-my-posh manually (https://ohmyposh.dev), then re-run."
        }
    }
    else { Write-Note "oh-my-posh already installed." }

    if (-not (Test-Path -LiteralPath $themePath)) {
        Write-Note "Missing $themePath; skipping profile wiring."
    }
    else {
        $initLine = 'oh-my-posh init pwsh --config "' + $themePath + '" | Invoke-Expression'
        $marker   = '# Cornerman prompt'
        $profiles = @(
            "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1",
            "$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
        )
        foreach ($p in $profiles) {
            $dir = Split-Path -Parent $p
            if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
            $existing = ''
            if (Test-Path -LiteralPath $p) { $existing = Get-Content -LiteralPath $p -Raw }
            if ($existing -notmatch [regex]::Escape($marker)) {
                Add-Content -LiteralPath $p -Value "`n$marker`n$initLine`n"
                Write-Note "Wired prompt into $p"
            }
            else { Write-Note "Prompt already wired in $p" }
        }
    }
}
else { Write-Note "Skipping oh-my-posh (per -SkipOhMyPosh)." }

Write-Host "`nDone. Open a NEW terminal tab. If borders did not repaint, run: Stop-Process -Name explorer -Force (Explorer restarts itself), or sign out/in." -ForegroundColor Cyan
Write-Host "Revert accent anytime: Settings > Personalization > Colors." -ForegroundColor DarkGray
