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

$color = if ($cfg.bannerColor) { [ConsoleColor]$cfg.bannerColor } else { [ConsoleColor]'Cyan' }

try {
    $build = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -ErrorAction Stop).CurrentBuild
    $ubr = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -ErrorAction Stop).UBR
    Write-Host "Microsoft Windows [Version 10.0.$build.$ubr]" -ForegroundColor $color
}
catch {
    Write-Host 'Microsoft Windows' -ForegroundColor $color
}

if ($cfg.consoleCopyright) {
    Write-Host $cfg.consoleCopyright -ForegroundColor $color
}

Write-Host ''
