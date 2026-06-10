# Install pinned Odysseus on lifepunchnet (run in RDP session on the box — NOT on VENGEANCE).
# Experimental Tier-3 — see LOCAL_AI_WORKSTATION.md section 8 and LIFEPUNCHNET_RDP_ODYSSEUS.txt

param(
    [string] $InstallDir = 'C:\lifepunch\odysseus',
    [string] $PinnedCommit = '7690860ab1a7b50afd1887b5a61ca60f38961847',
    [int] $Port = 7000
)

$ErrorActionPreference = 'Stop'

Write-Host ''
Write-Host 'Odysseus install (lifepunchnet)' -ForegroundColor Cyan
Write-Host "  Dir     $InstallDir"
Write-Host "  Commit  $PinnedCommit"
Write-Host "  URL     http://127.0.0.1:$Port (loopback only)"
Write-Host ''

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'git not found on lifepunchnet — install Git for Windows first.'
}

New-Item -ItemType Directory -Force -Path (Split-Path $InstallDir -Parent) | Out-Null

if (-not (Test-Path -LiteralPath (Join-Path $InstallDir '.git'))) {
    git clone https://github.com/pewdiepie-archdaemon/odysseus.git $InstallDir
}
else {
    Write-Host 'Repo exists — fetching...' -ForegroundColor DarkGray
    git -C $InstallDir fetch
}

Set-Location $InstallDir
git checkout $PinnedCommit

Write-Host ''
Write-Host 'Starting Odysseus (new window)...' -ForegroundColor Green
Write-Host '  Copy admin password from that terminal; change it in Settings.' -ForegroundColor Yellow
Write-Host '  Model backend: install Ollama for Windows, then set http://localhost:11434/v1 in Odysseus Settings.' -ForegroundColor DarkGray
Write-Host '  Session hub context: C:\lifepunch\session-hub\voice-session.ndjson' -ForegroundColor DarkGray
Write-Host ''

Start-Process powershell -ArgumentList @(
    '-NoExit', '-ExecutionPolicy', 'Bypass', '-NoProfile',
    '-Command', "Set-Location '$InstallDir'; .\launch-windows.ps1"
)

Write-Host "Open http://127.0.0.1:$Port after the server starts." -ForegroundColor Cyan
Write-Host 'Never port-forward :7000 to the internet.' -ForegroundColor Yellow
Write-Host ''
