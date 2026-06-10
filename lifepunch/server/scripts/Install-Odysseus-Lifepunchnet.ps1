# Install pinned Odysseus on lifepunchnet (run in RDP session on the box - NOT on VENGEANCE).
# Experimental Tier-3 - see LOCAL_AI_WORKSTATION.md section 8 and ODYSSEUS_LIFEPUNCHNET_START.md

param(
    [string] $InstallDir = 'C:\lifepunch\odysseus',
    [string] $PinnedCommit = '7690860ab1a7b50afd1887b5a61ca60f38961847',
    [int] $Port = 7000,
    [string] $StatusDir = 'C:\lifepunch\status',
    [string] $HubDir = 'C:\lifepunch\session-hub',
    [string] $OllamaModel = 'qwen2.5-coder:7b',
    [switch] $SkipModelPull,
    [switch] $RegisterLogonTask
)

$ErrorActionPreference = 'Stop'

function Write-OdysseusStatus {
    param([hashtable]$Extra)
    New-Item -ItemType Directory -Force -Path $StatusDir | Out-Null
    $payload = [ordered]@{
        ts             = (Get-Date).ToUniversalTime().ToString('o')
        installed      = $true
        pinnedCommit   = $PinnedCommit
        installDir     = $InstallDir
        port           = $Port
        hubLog         = Join-Path $HubDir 'voice-session.ndjson'
        importsDir     = Join-Path $HubDir 'imports'
        modelEndpoint  = 'http://localhost:11434/v1'
        ollama         = (Test-OllamaOk).ok
        httpOk         = (Test-OdysseusHttp -Port $Port).ok
    }
    foreach ($k in $Extra.Keys) { $payload[$k] = $Extra[$k] }
    $path = Join-Path $StatusDir 'odysseus.json'
    $payload | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $path -Encoding UTF8
    return $path
}

function Test-OllamaOk {
    try {
        $r = Invoke-RestMethod -Uri 'http://127.0.0.1:11434/api/tags' -TimeoutSec 5 -ErrorAction Stop
        return @{ ok = $true; detail = 'ollama responding' }
    }
    catch {
        return @{ ok = $false; detail = $_.Exception.Message }
    }
}

function Test-OdysseusHttp {
    param([int]$Port)
    try {
        $r = Invoke-WebRequest -Uri "http://127.0.0.1:$Port" -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
        return @{ ok = ($r.StatusCode -ge 200 -and $r.StatusCode -lt 500); status = $r.StatusCode }
    }
    catch {
        return @{ ok = $false; detail = $_.Exception.Message }
    }
}

Write-Host ''
Write-Host 'Odysseus install (lifepunchnet / Blue memory reader)' -ForegroundColor Cyan
Write-Host "  Dir      $InstallDir"
Write-Host "  Commit   $PinnedCommit"
Write-Host "  URL      http://127.0.0.1:$Port (loopback only)"
Write-Host "  Hub log  $(Join-Path $HubDir 'voice-session.ndjson')"
Write-Host ''

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'git not found on lifepunchnet - install Git for Windows first.'
}

New-Item -ItemType Directory -Force -Path (Split-Path $InstallDir -Parent) | Out-Null
New-Item -ItemType Directory -Force -Path $HubDir | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $HubDir 'imports') | Out-Null

if (-not (Test-Path -LiteralPath (Join-Path $InstallDir '.git'))) {
    git clone https://github.com/pewdiepie-archdaemon/odysseus.git $InstallDir
}
else {
    Write-Host 'Repo exists - fetching...' -ForegroundColor DarkGray
    git -C $InstallDir fetch
}

Set-Location $InstallDir
git checkout $PinnedCommit

$ollama = Get-Command ollama -ErrorAction SilentlyContinue
if (-not $ollama) {
    Write-Host ''
    Write-Host 'Ollama not found.' -ForegroundColor Yellow
    Write-Host '  Install: winget install Ollama.Ollama  (or https://ollama.com/download)' -ForegroundColor Yellow
    Write-Host '  Then re-run this script with -SkipModelPull if model already pulled.' -ForegroundColor Yellow
}
elseif (-not $SkipModelPull) {
    Write-Host ''
    Write-Host "Pulling Ollama model $OllamaModel (may take a while)..." -ForegroundColor Cyan
    & ollama pull $OllamaModel
}

$contextFile = Join-Path $StatusDir 'odysseus-cvl-context.txt'
@(
    'Odysseus CVL context (lifepunchnet)'
    "Hub NDJSON: $(Join-Path $HubDir 'voice-session.ndjson')"
    "Imports:    $(Join-Path $HubDir 'imports')"
    'Live tail:  GET http://127.0.0.1:9102/tail?lines=50 (Bearer from status-token.txt)'
    'Model:      http://localhost:11434/v1 in Odysseus Settings'
    'Tiers:      universal | vengeance | cornerman | lifepunchnet'
    'Rule:       AUTH on, loopback only, no real creds, no write-git for agent'
) | Set-Content -LiteralPath $contextFile -Encoding UTF8

Write-Host ''
Write-Host 'Starting Odysseus (new window)...' -ForegroundColor Green
Write-Host '  1. Copy admin password from terminal; change in Settings immediately.' -ForegroundColor Yellow
Write-Host '  2. Settings -> model API http://localhost:11434/v1' -ForegroundColor Yellow
Write-Host "  3. Context file: $contextFile" -ForegroundColor DarkGray
Write-Host ''

Start-Process powershell -ArgumentList @(
    '-NoExit', '-ExecutionPolicy', 'Bypass', '-NoProfile',
    '-Command', "Set-Location '$InstallDir'; .\launch-windows.ps1"
)

Start-Sleep -Seconds 8
$statusPath = Write-OdysseusStatus @{ phase = 'launched' }

if ($RegisterLogonTask) {
    $taskScript = Join-Path $PSScriptRoot 'Register-Odysseus-LifepunchnetTask.ps1'
    if (Test-Path -LiteralPath $taskScript) {
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $taskScript -InstallDir $InstallDir
    }
}

$http = Test-OdysseusHttp -Port $Port
Write-Host "Open http://127.0.0.1:$Port after the server starts." -ForegroundColor Cyan
Write-Host "Status written: $statusPath (httpOk=$($http.ok))" -ForegroundColor $(if ($http.ok) { 'Green' } else { 'Yellow' })
Write-Host 'Never port-forward :7000 to the internet.' -ForegroundColor Yellow
Write-Host ''
