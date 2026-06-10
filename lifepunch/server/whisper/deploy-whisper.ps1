<#
.SYNOPSIS
  Start lifepunchnet Whisper Docker container on :9000 (small.en).

.DESCRIPTION
  Waits for Docker daemon (needs interactive session / Docker Desktop on Windows).
  Registered by Install-LifePunchNetBoot.ps1 as LifePunch-Whisper-Deploy (AtLogon).
#>
[CmdletBinding()]
param(
    [string] $ContainerName = 'whisper',
    [string] $Image = 'hwdsl2/whisper-server',
    [string] $Model = 'small.en',
    [int] $Port = 9000,
    [int] $DockerWaitSeconds = 180
)

$ErrorActionPreference = 'Stop'
$logDir = 'C:\lifepunch\whisper'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$logFile = Join-Path $logDir 'deploy-whisper.log'

function Write-Log([string]$Message) {
    $line = '{0}  {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message
    Add-Content -LiteralPath $logFile -Value $line -Encoding UTF8
}

function Test-DockerReady {
    docker info 2>$null | Out-Null
    return ($LASTEXITCODE -eq 0)
}

Write-Log 'deploy-whisper start'
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Log 'docker CLI not found'
    exit 1
}

$deadline = (Get-Date).AddSeconds($DockerWaitSeconds)
while (-not (Test-DockerReady)) {
    if ((Get-Date) -gt $deadline) {
        Write-Log "docker not ready after ${DockerWaitSeconds}s"
        exit 1
    }
    Start-Sleep -Seconds 5
}

Write-Log 'docker ready'
docker pull $Image 2>&1 | ForEach-Object { Write-Log $_ }

$existing = docker ps -a --filter "name=^/${ContainerName}$" --format '{{.Names}}' 2>$null
if ($existing -eq $ContainerName) {
    docker start $ContainerName 2>&1 | ForEach-Object { Write-Log $_ }
}
else {
    docker run -d --name $ContainerName --restart unless-stopped `
        -p "${Port}:9000" -e "WHISPER_MODEL=$Model" $Image 2>&1 | ForEach-Object { Write-Log $_ }
}

Start-Sleep -Seconds 3
$running = docker ps --filter "name=^/${ContainerName}$" --filter 'status=running' --format '{{.Names}}'
if ($running -ne $ContainerName) {
    Write-Log 'container not running after start'
    exit 1
}

try {
    $health = Invoke-RestMethod -Uri "http://127.0.0.1:${Port}/health" -TimeoutSec 15
    Write-Log ('health OK: ' + ($health | ConvertTo-Json -Compress))
}
catch {
    Write-Log ('health check skipped or failed: ' + $_.Exception.Message)
}

Write-Log 'deploy-whisper done'
exit 0
