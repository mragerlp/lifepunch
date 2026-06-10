# Deploy command parser + conversation logging to Cornerman (run on VENGEANCE).

param(
    [string] $CornermanHost = $(if ($env:CORNERMAN_SSH) { $env:CORNERMAN_SSH } else { 'cornerman' }),
    [string] $CornermanRag = 'C:/Projects/cornerman-rag'
)

$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot

function Scp-File([string]$Local, [string]$Name) {
    & scp -o BatchMode=yes $Local "${CornermanHost}:${CornermanRag}/${Name}"
    if ($LASTEXITCODE -ne 0) { throw "scp failed: $Name" }
    Write-Host "  $Name" -ForegroundColor Green
}

Write-Host ''
Write-Host 'Cornerman voice network deploy' -ForegroundColor Cyan
Scp-File (Join-Path $Here 'commands.py') 'commands.py'
Scp-File (Join-Path $Here 'conversation_log.py') 'conversation_log.py'
Scp-File (Join-Path $Here 'patch_voice_network.py') 'patch_voice_network.py'
ssh -o BatchMode=yes $CornermanHost "cd $CornermanRag; .venv/Scripts/python.exe patch_voice_network.py"
Write-Host 'Done. Restart Talk to Vengeance / Talk to Cornerman on Cornerman.' -ForegroundColor Green
Write-Host ''
