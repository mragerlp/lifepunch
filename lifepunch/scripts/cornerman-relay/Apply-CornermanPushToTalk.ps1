# Deploy push-to-talk to Cornerman cornerman-rag (run on VENGEANCE).

param(
    [string] $CornermanHost = $(if ($env:CORNERMAN_SSH) { $env:CORNERMAN_SSH } else { 'cornerman' }),
    [string] $CornermanRag = 'C:/Projects/cornerman-rag'
)

$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot

function Scp-File([string]$Local, [string]$RemoteName) {
    $dest = "${CornermanHost}:${CornermanRag}/${RemoteName}"
    & scp -o BatchMode=yes $Local $dest
    if ($LASTEXITCODE -ne 0) { throw "scp failed: $Local -> $dest" }
    Write-Host "  $RemoteName" -ForegroundColor Green
}

Write-Host ''
Write-Host 'Cornerman push-to-talk deploy' -ForegroundColor Cyan
Write-Host "  $CornermanHost -> $CornermanRag" -ForegroundColor DarkGray
Write-Host ''

Write-Host 'Copy files...' -ForegroundColor DarkGray
Scp-File (Join-Path $Here 'ptt.py') 'ptt.py'
Scp-File (Join-Path $Here 'ptt_capture.py') 'ptt_capture.py'
Scp-File (Join-Path $Here 'relay_ui.py') 'relay_ui.py'
Scp-File (Join-Path $Here 'commands.py') 'commands.py'
Scp-File (Join-Path $Here 'patch_relay_ptt.py') 'patch_relay_ptt.py'

Write-Host 'Patch cornerman-rag...' -ForegroundColor DarkGray
ssh -o BatchMode=yes $CornermanHost "cd $CornermanRag; .venv/Scripts/python.exe patch_relay_ptt.py"

Write-Host ''
Write-Host 'Done.' -ForegroundColor Green
Write-Host '  Cornerman: tap F7 to arm, wait for Ready, hold F8, release' -ForegroundColor Cyan
Write-Host '  Keys: CORNERMAN_ARM_KEY (default F7), CORNERMAN_PTT_KEY (default F8)' -ForegroundColor DarkGray
Write-Host '  Clipboard auto-copies on send; paste in Cursor when you are ready' -ForegroundColor DarkGray
Write-Host '  Legacy wake phrase: Talk to Vengeance (Wake).cmd (not recommended)' -ForegroundColor DarkGray
Write-Host ''
