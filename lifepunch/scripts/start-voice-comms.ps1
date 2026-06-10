# Start all VENGEANCE voice-comms windows (paste, session archive, lifepunchnet watch).

param(
    [switch] $SkipPreflight,
    [switch] $SkipWatchdog
)

$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot

if (-not $SkipPreflight) {
    $preflight = Join-Path $Here 'Test-VoiceCommsReady.ps1'
    & $preflight
    if ($LASTEXITCODE -ne 0) {
        Write-Host 'Preflight failed — use -SkipPreflight to launch anyway.' -ForegroundColor Yellow
        exit 1
    }
}

function Start-VoiceWindow([string]$Title, [string]$ScriptName) {
    $path = Join-Path $Here $ScriptName
    if (-not (Test-Path -LiteralPath $path)) { throw "Missing $path" }
    $args = @(
        '-NoExit', '-ExecutionPolicy', 'Bypass', '-NoProfile',
        '-Command', "& { `$Host.UI.RawUI.WindowTitle = '$Title'; & '$path' }"
    )
    Start-Process -FilePath 'powershell.exe' -ArgumentList $args -WindowStyle Normal | Out-Null
    Write-Host "  Started: $Title" -ForegroundColor Green
}

Write-Host ''
Write-Host 'Starting LifePunch voice comms on VENGEANCE...' -ForegroundColor Cyan
Start-VoiceWindow 'LifePunch Voice Watch' 'start-vengeance-voice-watch.ps1'
Start-Sleep -Milliseconds 400
Start-VoiceWindow 'LifePunch Session Sync' 'start-session-sync.ps1'
if (-not $SkipWatchdog) {
    Start-Sleep -Milliseconds 400
    Start-VoiceWindow 'LifePunch lifepunchnet Watch' 'start-server-host-watch.ps1'
}

Write-Host ''
Write-Host 'Cornerman: use Talk to Vengeance — wake phrase, then your message.' -ForegroundColor DarkGray
Write-Host 'VENGEANCE: when Cornerman cues paste, Ctrl+V in Cursor.' -ForegroundColor DarkGray
Write-Host ''
