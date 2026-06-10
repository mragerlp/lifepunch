<#
.SYNOPSIS
  Apply per-node LifePunch ops console branding.

.DESCRIPTION
  Hacker Job machine uniforms — each node wears its own outfit from outfits/.
  VENGEANCE (Enhanced Hacker Terminal, red), Cornerman (Hacker Terminal, green),
  lifepunchnet (Government Terminal, cyan). Sync art: Sync-OutfitsFromOneDrive.ps1

.PARAMETER Machine
  vengeance | cornerman | lifepunchnet

.PARAMETER NodeIp
  LAN IP shown in the ops banner.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\Apply-LifePunchOpsConsole.ps1 -Machine vengeance -NodeIp 192.168.1.236
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('vengeance', 'cornerman', 'lifepunchnet')]
    [string] $Machine,

    [string] $NodeIp = ''
)

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$nodesPath = Join-Path $here 'nodes.json'
$profileSnippet = Join-Path $here 'LifePunch-OpsProfile.ps1'
$wallDir = Join-Path $here 'wallpapers'

function Write-Step($m) { Write-Host "==> $m" -ForegroundColor Cyan }
function Write-Note($m) { Write-Host "    $m" -ForegroundColor DarkGray }

function Get-AccentDwords([string]$hex) {
    $h = $hex.Trim().TrimStart('#')
    if ($h.Length -ne 6) { throw "Accent must be 6 hex digits, got: $hex" }
    $r = [byte][Convert]::ToInt32($h.Substring(0, 2), 16)
    $g = [byte][Convert]::ToInt32($h.Substring(2, 2), 16)
    $b = [byte][Convert]::ToInt32($h.Substring(4, 2), 16)
    # BitConverter avoids PowerShell signed-hex literal overflow (0xFF000000).
    $abgr = [BitConverter]::ToUInt32([byte[]]($r, $g, $b, 0xFF), 0)
    $argb = [BitConverter]::ToUInt32([byte[]]($b, $g, $r, 0xFF), 0)
    [pscustomobject]@{
        ABGR = $abgr
        ARGB = $argb
        RGB  = @([int]$r, [int]$g, [int]$b)
    }
}

function Get-OpsPromptBlock {
    param(
        [string] $ThemePath,
        [string] $ShellName
    )
    $cfg = $ThemePath.Replace("'", "''")
    return @(
        '[Console]::OutputEncoding = [Text.Encoding]::UTF8'
        ('function prompt { oh-my-posh print primary --config "' + $cfg + '" --shell ' + $ShellName + ' }')
    ) -join "`n"
}

function Set-ProfileBlock {
    param(
        [string] $Path,
        [string] $Marker,
        [string] $Line
    )
    $dir = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $content = if (Test-Path -LiteralPath $Path) { Get-Content -LiteralPath $Path -Raw } else { '' }
    if ($content -match [regex]::Escape($Marker)) {
        $pattern = '(?ms)' + [regex]::Escape($Marker) + '\r?\n.*?(?=\r?\n# |\r?\n$|$)'
        $content = [regex]::Replace($content, $pattern, ($Marker + "`n" + $Line))
        Set-Content -LiteralPath $Path -Value $content.TrimEnd() -Encoding UTF8
        Write-Note "Updated $Marker in $Path"
    }
    else {
        Add-Content -LiteralPath $Path -Value "`n$Marker`n$Line`n"
        Write-Note "Wired $Marker into $Path"
    }
}

if (-not (Test-Path -LiteralPath $nodesPath)) { throw "Missing $nodesPath" }
$nodes = Get-Content -LiteralPath $nodesPath -Raw | ConvertFrom-Json
$node = $nodes.$Machine
if (-not $node) { throw "Unknown machine profile: $Machine" }

$schemeFile = if ($node.scheme) { [string]$node.scheme } else { 'windows-terminal-lifepunch-ops.json' }
$ompFile = if ($node.omp) { [string]$node.omp } else { 'lifepunch-ops.omp.json' }
$accentHex = if ($node.accent) { [string]$node.accent } else { '00D4FF' }
$schemePath = Join-Path $here $schemeFile
$themePath = Join-Path $here $ompFile

if (-not $NodeIp) {
    try {
        $NodeIp = (
            Get-NetIPAddress -AddressFamily IPv4 -ErrorAction Stop |
            Where-Object {
                $_.IPAddress -notlike '127.*' -and
                $_.PrefixOrigin -ne 'WellKnown' -and
                $_.InterfaceAlias -notmatch 'vEthernet|WSL|Loopback'
            } |
            Sort-Object -Property InterfaceAlias |
            Select-Object -First 1 -ExpandProperty IPAddress
        )
    }
    catch { $NodeIp = '' }
}

$tier = if ($node.tier) { [string]$node.tier } else { '' }
$dressLabel = 'Dressing ' + $Machine + ' - ' + $node.node + $(if ($tier) { ' (' + $tier + ')' })
Write-Step $dressLabel
Write-Note ('Scheme: ' + $schemeFile + '  |  Prompt: ' + $ompFile + '  |  Accent: #' + $accentHex)
Write-Note "IP banner: $(if ($NodeIp) { $NodeIp } else { '(pass -NodeIp)' })"

$stateDir = Join-Path $env:LOCALAPPDATA 'LifePunch'
New-Item -ItemType Directory -Force -Path $stateDir | Out-Null
$state = [ordered]@{
    machine     = $Machine
    node        = [string]$node.node
    host        = [string]$node.host
    tagline     = [string]$node.tagline
    nodeIp      = $NodeIp
    brand       = [string]$node.brand
    bannerColor = [string]$node.bannerColor
    accent      = $accentHex
    scheme      = $schemeFile
    omp         = $ompFile
    applied     = (Get-Date).ToUniversalTime().ToString('o')
}
if ($node.tier) { $state.tier = [string]$node.tier }
if ($node.taglineSecondary) { $state.taglineSecondary = [string]$node.taglineSecondary }
$state | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $stateDir 'ops-node.json') -Encoding UTF8

# 1. Windows Terminal
Write-Step 'Windows Terminal scheme + defaults'
$wtCandidates = @(
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json",
    "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
)
$wtPath = $wtCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1

if (-not $wtPath) {
    Write-Note 'Windows Terminal settings.json not found; install WT, then re-run.'
}
elseif (-not (Test-Path -LiteralPath $schemePath)) {
    Write-Note "Missing $schemePath"
}
else {
    $scheme = Get-Content -LiteralPath $schemePath -Raw | ConvertFrom-Json
    if ($scheme.PSObject.Properties.Name -contains '_comment') {
        $scheme.PSObject.Properties.Remove('_comment')
    }
    $settings = Get-Content -LiteralPath $wtPath -Raw | ConvertFrom-Json
    if (-not $settings.schemes) {
        $settings | Add-Member -NotePropertyName schemes -NotePropertyValue @() -Force
    }
    $settings.schemes = @($settings.schemes | Where-Object { $_.name -ne $scheme.name }) + $scheme
    if (-not $settings.profiles) {
        $settings | Add-Member -NotePropertyName profiles -NotePropertyValue ([pscustomobject]@{}) -Force
    }
    if (-not $settings.profiles.defaults) {
        $settings.profiles | Add-Member -NotePropertyName defaults -NotePropertyValue ([pscustomobject]@{}) -Force
    }
    $d = $settings.profiles.defaults
    $d | Add-Member -NotePropertyName colorScheme -NotePropertyValue $scheme.name -Force
    $d | Add-Member -NotePropertyName cursorShape -NotePropertyValue 'filledBox' -Force
    $d | Add-Member -NotePropertyName font -NotePropertyValue ([pscustomobject]@{ face = 'Cascadia Code'; size = 11 }) -Force
    $d | Add-Member -NotePropertyName useAcrylic -NotePropertyValue $false -Force
    $settings | ConvertTo-Json -Depth 32 | Set-Content -LiteralPath $wtPath -Encoding UTF8
    Write-Note "Applied '$($scheme.name)' to $wtPath"
}

# 2. System accent
$accent = Get-AccentDwords $accentHex
Write-Step ('Windows accent = #' + $accentHex)
$dwm = 'HKCU:\Software\Microsoft\Windows\DWM'
New-Item -Path $dwm -Force | Out-Null
Set-ItemProperty -Path $dwm -Name AccentColor -Type DWord -Value $accent.ABGR
Set-ItemProperty -Path $dwm -Name ColorizationColor -Type DWord -Value $accent.ARGB
Set-ItemProperty -Path $dwm -Name ColorizationAfterglow -Type DWord -Value $accent.ARGB
$taskbarGray = $false
if ($node.PSObject.Properties['taskbarGray']) { $taskbarGray = [bool]$node.taskbarGray }
Set-ItemProperty -Path $dwm -Name EnableWindowColorization -Type DWord -Value 1

$factors = @(1.6, 1.4, 1.2, 1.0, 0.8, 0.6, 0.45, 0.3)
$palette = @()
foreach ($f in $factors) {
    foreach ($c in $accent.RGB) {
        $v = [math]::Round($c * $f)
        if ($v -gt 255) { $v = 255 }
        $palette += [byte]$v
    }
    $palette += [byte]255
}
$accentKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent'
New-Item -Path $accentKey -Force | Out-Null
Set-ItemProperty -Path $accentKey -Name AccentPalette -Type Binary -Value ([byte[]]$palette)

$personalize = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
New-Item -Path $personalize -Force | Out-Null

if ($taskbarGray) {
    $gray = Get-AccentDwords '1E1E1E'
    Set-ItemProperty -Path $personalize -Name ColorPrevalence -Type DWord -Value 0
    Set-ItemProperty -Path $dwm -Name ColorPrevalence -Type DWord -Value 0
    Set-ItemProperty -Path $accentKey -Name AccentColorMenu -Type DWord -Value $gray.ABGR
    Set-ItemProperty -Path $accentKey -Name StartColorMenu -Type DWord -Value $gray.ABGR
    Write-Note 'Accent on title bars only; taskbar/Start = gray (matches other web nodes).'
}
else {
    Set-ItemProperty -Path $personalize -Name ColorPrevalence -Type DWord -Value 1
    Set-ItemProperty -Path $dwm -Name ColorPrevalence -Type DWord -Value 1
    Set-ItemProperty -Path $accentKey -Name AccentColorMenu -Type DWord -Value $accent.ABGR
    Set-ItemProperty -Path $accentKey -Name StartColorMenu -Type DWord -Value $accent.ABGR
    Write-Note 'Accent set. Restart Explorer or open a new terminal to repaint borders.'
}

# 3. Wallpaper
Write-Step 'Desktop wallpaper'
$wpName = [string]$node.wallpaper
$wpPath = Join-Path $wallDir $wpName
if (-not (Test-Path -LiteralPath $wpPath)) {
    $fallback = Join-Path $wallDir 'lifepunch-ops-wallpaper.png'
    if (Test-Path -LiteralPath $fallback) { $wpPath = $fallback }
}
if (Test-Path -LiteralPath $wpPath) {
    $resolved = (Resolve-Path -LiteralPath $wpPath).Path
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name Wallpaper -Value $resolved
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name WallpaperStyle -Value 10
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name TileWallpaper -Value 0
    rundll32.exe user32.dll, UpdatePerUserSystemParameters ,1 ,True | Out-Null
    Write-Note "Wallpaper: $resolved"
}
else {
    Write-Note "No wallpaper for $Machine ($wpName). See SYNC_FROM_LIFEPUNCHNET.md"
}

# 4. oh-my-posh + banner
Write-Step 'oh-my-posh + ops banner profile'
if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if ($winget) {
        Write-Note 'Installing oh-my-posh via winget...'
        winget install --id JanDeDobbeleer.OhMyPosh -e --source winget --accept-source-agreements --accept-package-agreements
        $env:Path += ';' + (Join-Path $env:LOCALAPPDATA 'Programs\oh-my-posh\bin')
    }
    else {
        Write-Note 'Install oh-my-posh manually (https://ohmyposh.dev), then re-run.'
    }
}

$ompMarker = '# LifePunch Ops prompt'
$bannerMarker = '# LifePunch Ops banner'
$bannerLine = '. "' + $profileSnippet + '"'
$profileTargets = @(
    @{ Path = "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"; Shell = 'pwsh' },
    @{ Path = "$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"; Shell = 'powershell' }
)
foreach ($target in $profileTargets) {
    $ompBlock = Get-OpsPromptBlock -ThemePath $themePath -ShellName $target.Shell
    Set-ProfileBlock -Path $target.Path -Marker $ompMarker -Line $ompBlock
    Set-ProfileBlock -Path $target.Path -Marker $bannerMarker -Line $bannerLine
}

Write-Host ''
Write-Host ('Done. NODE=' + $node.node + ' on ' + $Machine + '. Open a NEW Terminal tab to preview.') -ForegroundColor Cyan
Write-Host 'Uniforms: see OUTFITS.md. Art source: OneDrive Desktop\Hacker Job' -ForegroundColor DarkGray
