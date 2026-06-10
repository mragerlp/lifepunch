# Dot-sourced by PowerShell profile after Apply-LifePunchOpsConsole.ps1.

$cfgPath = Join-Path $env:LOCALAPPDATA 'LifePunch\ops-node.json'
if (-not (Test-Path -LiteralPath $cfgPath)) { return }

try {
    $cfg = Get-Content -LiteralPath $cfgPath -Raw | ConvertFrom-Json
}
catch {
    return
}

if ($global:LifePunchOpsBannerShown) { return }
$global:LifePunchOpsBannerShown = $true

$w = 64
$ip = if ($cfg.nodeIp) { $cfg.nodeIp } else { 'LAN' }
$color = if ($cfg.bannerColor) { [ConsoleColor]$cfg.bannerColor } else { [ConsoleColor]'Cyan' }

Write-Host ''
Write-Host ('=' * $w) -ForegroundColor $color

if ($cfg.brand -eq 'vengeance') {
    Write-Host '  V E N G E A N C E' -ForegroundColor $color
    Write-Host "  $($cfg.tagline)" -ForegroundColor DarkGray
    if ($cfg.tier) { Write-Host "  $($cfg.tier) // $ip" -ForegroundColor DarkGray }
    else { Write-Host "  NODE // $ip" -ForegroundColor DarkGray }
}
elseif ($cfg.brand -eq 'cornerman') {
    Write-Host '  C O R N E R M A N' -ForegroundColor $color
    Write-Host "  $($cfg.tagline)" -ForegroundColor DarkGray
    if ($cfg.tier) { Write-Host "  $($cfg.tier) // $ip" -ForegroundColor DarkGray }
    else { Write-Host "  NODE // $ip" -ForegroundColor DarkGray }
}
elseif ($cfg.brand -eq 'government') {
    Write-Host '  L I F E P U N C H . N E T' -ForegroundColor $color
    Write-Host "  $($cfg.tagline)" -ForegroundColor DarkGray
    if ($cfg.taglineSecondary) {
        Write-Host "  $($cfg.taglineSecondary)" -ForegroundColor DarkGray
    }
    if ($cfg.tier) { Write-Host "  $($cfg.tier) // $ip" -ForegroundColor DarkGray }
    else { Write-Host "  GOVERNMENT TERMINAL // $ip" -ForegroundColor DarkGray }
}
else {
    Write-Host "  LIFEPUNCH OPS  //  NODE: $($cfg.node)  //  $ip" -ForegroundColor $color
    Write-Host "  $($cfg.tagline)" -ForegroundColor DarkGray
}

Write-Host ('=' * $w) -ForegroundColor $color
Write-Host ''
