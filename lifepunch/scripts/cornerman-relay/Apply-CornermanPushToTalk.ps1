# Deploy push-to-talk to Cornerman cornerman-rag (run on VENGEANCE).

param(
    [string] $CornermanHost = $(if ($env:CORNERMAN_SSH) { $env:CORNERMAN_SSH } else { 'cornerman' }),
    [string] $CornermanRag = 'C:\Projects\cornerman-rag'
)

$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$ScriptsRoot = Split-Path -Parent $Here
. (Join-Path $ScriptsRoot 'Cornerman-Workflow.ps1')

function Push-RagFile([string]$Local, [string]$RemoteName) {
    $remotePath = Join-Path $CornermanRag $RemoteName
    Push-CornermanText -Path $remotePath -Text (Get-Content -LiteralPath $Local -Raw) -SshTarget $CornermanHost
    Write-Host "  $RemoteName" -ForegroundColor Green
}

Write-Host ''
Write-Host 'Cornerman push-to-talk deploy' -ForegroundColor Cyan
Write-Host "  $CornermanHost -> $CornermanRag" -ForegroundColor DarkGray
Write-Host ''

Write-Host 'Copy files...' -ForegroundColor DarkGray
Push-RagFile (Join-Path $Here 'beep.py') 'beep.py'
Push-RagFile (Join-Path $Here 'ptt.py') 'ptt.py'
Push-RagFile (Join-Path $Here 'ptt_capture.py') 'ptt_capture.py'
Push-RagFile (Join-Path $Here 'relay_ui.py') 'relay_ui.py'
Push-RagFile (Join-Path $Here 'commands.py') 'commands.py'
Push-RagFile (Join-Path $Here 'patch_quiet_beep.py') 'patch_quiet_beep.py'
try {
    Push-RagFile (Join-Path $Here 'patch_relay_ptt.py') 'patch_relay_ptt.py'
}
catch {
    Write-Host "  patch_relay_ptt.py skipped (large-file SSH limit) — patch_quiet_beep.py covers beep" -ForegroundColor Yellow
}
$relayStarter = Join-Path $ScriptsRoot 'Start-CornermanVoiceRelay.ps1'
if (Test-Path -LiteralPath $relayStarter) {
    Push-RagFile $relayStarter 'Start-CornermanVoiceRelay.ps1'
}

Write-Host 'Patch cornerman-rag...' -ForegroundColor DarkGray
$ragEsc = $CornermanRag -replace "'", "''"
Invoke-CornermanSshExec -SshTarget $CornermanHost -ScriptBlock @"
Set-Location -LiteralPath '$ragEsc'
if (Test-Path -LiteralPath .\patch_relay_ptt.py) {
    & .\.venv\Scripts\python.exe .\patch_relay_ptt.py
    if (`$LASTEXITCODE -ne 0) { exit `$LASTEXITCODE }
}
& .\.venv\Scripts\python.exe .\patch_quiet_beep.py
if (`$LASTEXITCODE -ne 0) { exit `$LASTEXITCODE }
"@ | Out-Null

Write-Host 'Deploy lifepunchnet Whisper preflight (required by relay.ps1)...' -ForegroundColor DarkGray
& (Join-Path $Here 'Deploy-CornermanWhisperPreflight.ps1') -CornermanHost $CornermanHost

Write-Host ''
Write-Host 'Done.' -ForegroundColor Green
Write-Host '  Cornerman: tap F7 to arm, wait for Ready, hold F8, release' -ForegroundColor Cyan
Write-Host '  Keys: CORNERMAN_ARM_KEY (default F7), CORNERMAN_PTT_KEY (default F8)' -ForegroundColor DarkGray
Write-Host '  Beep: off when TTS guided (default); CORNERMAN_BEEP_VOLUME=0.12 if --no-guided' -ForegroundColor DarkGray
Write-Host '  Clipboard auto-copies on send; paste in Cursor when you are ready' -ForegroundColor DarkGray
Write-Host '  Legacy wake phrase: Talk to Vengeance (Wake).cmd (not recommended)' -ForegroundColor DarkGray
Write-Host ''
