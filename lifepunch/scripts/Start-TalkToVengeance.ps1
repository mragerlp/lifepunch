# VENGEANCE (Red) → Cornerman (Green): signal Green to open the red Talk to Vengeance relay.
# Red shortcut on VENGEANCE desktop = GREEN icon. Red Talk to Vengeance.lnk lives on Green desktop only.

param(
    [switch] $SkipRdp
)

$ErrorActionPreference = 'Stop'
$CornermanSsh = if ($env:CORNERMAN_SSH) { $env:CORNERMAN_SSH } else { 'cornerman' }
$CornermanRelayScript = 'C:\Projects\cornerman-rag\Start-CornermanVoiceRelay.ps1'
$CornermanRdp = Join-Path $env:USERPROFILE 'Documents\LifePunch-RDP\cornerman.rdp'

function Test-CornermanSsh {
    param([string]$Target)
    $probe = & ssh.exe -o BatchMode=yes -o ConnectTimeout=8 $Target 'echo ok' 2>&1
    $code = $LASTEXITCODE
    $text = ($probe | Out-String).Trim()
    if ($code -eq 0) { return $true }
    Write-Host ''
    Write-Host 'Cannot reach Cornerman (Green) over SSH.' -ForegroundColor Red
    if ($text -match 'Connection timed out|Could not resolve|No route') {
        Write-Host '  Cornerman may be off or not on the LAN. Wake it, then retry.' -ForegroundColor Yellow
    }
    elseif ($text -match 'Permission denied') {
        Write-Host '  SSH key rejected. Run: ssh cornerman (once) or reload ssh-agent with your key.' -ForegroundColor Yellow
    }
    else {
        Write-Host "  $text" -ForegroundColor Yellow
    }
    Write-Host ''
    Write-Host 'Fallback: open Cornerman (RDP) on OneDrive Desktop,' -ForegroundColor Cyan
    Write-Host '  then double-click red Talk to Vengeance on the Green desktop.' -ForegroundColor Cyan
    return $false
}

function Invoke-CornermanRelayStart {
    param([string]$Target, [string]$RemoteScript)
    $raw = & ssh.exe -o BatchMode=yes -o ConnectTimeout=12 $Target `
        "powershell -NoProfile -ExecutionPolicy Bypass -File `"$RemoteScript`"" 2>&1
    $code = $LASTEXITCODE
    foreach ($line in @($raw)) {
        if ($line -match 'Microsoft\.PowerShell_profile|Execution_Policies|UnauthorizedAccess') { continue }
        if ($line.Trim().Length -gt 0) { Write-Host $line }
    }
    return $code
}

function Open-CornermanRdp {
    if (-not (Test-Path -LiteralPath $CornermanRdp)) {
        Write-Host '  Cornerman RDP file missing — run Install-LifePunchRemoteShortcuts.ps1' -ForegroundColor Yellow
        return
    }
    Start-Process -FilePath "$env:WINDIR\System32\mstsc.exe" -ArgumentList "`"$CornermanRdp`"" | Out-Null
    Write-Host '  Opening Cornerman (RDP) — focus red Talk to Vengeance on Green desktop.' -ForegroundColor Cyan
}

Write-Host ''
Write-Host 'Red -> Green: signaling Cornerman voice relay...' -ForegroundColor Cyan
if (-not (Test-CornermanSsh -Target $CornermanSsh)) {
    Read-Host 'Press Enter to close'
    exit 1
}

$exitCode = Invoke-CornermanRelayStart -Target $CornermanSsh -RemoteScript $CornermanRelayScript
if ($exitCode -ne 0) {
    Write-Host ''
    Write-Host 'Green relay start failed.' -ForegroundColor Red
    Write-Host 'Fallback: Cornerman (RDP) -> red Talk to Vengeance on Green desktop.' -ForegroundColor Cyan
    Read-Host 'Press Enter to close'
    exit 1
}

if (-not $SkipRdp) {
    Open-CornermanRdp
}

Write-Host ''
Write-Host 'OK — Yellow path: Green relay running (voice -> Red / Cursor).' -ForegroundColor Green
Write-Host '  On Green: focus red Talk to Vengeance window -> F7 -> Ready -> hold F8' -ForegroundColor White
Write-Host '  On Red: LifePunch Voice Watch -> Ctrl+V in Cursor when clipboard updates' -ForegroundColor White
Write-Host ''
Read-Host 'Press Enter to close'
