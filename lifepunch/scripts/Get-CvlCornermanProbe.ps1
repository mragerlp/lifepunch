# Runs ON Cornerman (via SSH EncodedCommand from VENGEANCE). Emits one JSON line.
$ErrorActionPreference = 'SilentlyContinue'
$rag = 'C:\Projects\cornerman-rag'
$gitRoot = 'C:\Projects\lifepunch'
$headlessLog = 'C:\lifepunch\cornerman\headless-boot.log'

$gitHead = 'no-clone'
if (Test-Path -LiteralPath (Join-Path $gitRoot '.git')) {
    Push-Location $gitRoot
    $gitHead = (git log -1 --format='%h %s' 2>$null)
    if (-not $gitHead) { $gitHead = 'git-error' }
    Pop-Location
}

$relayRunning = $false
Get-CimInstance Win32_Process -Filter "Name = 'python.exe'" -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -match 'relay\.py' } |
    ForEach-Object { $relayRunning = $true }

$sttTail = ''
$sttPath = Join-Path $rag 'outbox\stt-path.log'
if (Test-Path -LiteralPath $sttPath) {
    $lines = @(Get-Content -LiteralPath $sttPath -ErrorAction SilentlyContinue)
    if ($lines.Count -gt 0) { $sttTail = [string]$lines[-1] }
}

$lmStudioOk = $false
$lmModelCount = 0
$lmModels = ''
$lmTier3Ok = $false
$requiredTier3 = @(
    'qwen/qwen3.6-35b-a3b'
    'qwen2.5-coder-32b-instruct'
    'text-embedding-nomic-embed-text-v1.5'
)
try {
    $r = Invoke-WebRequest -Uri 'http://127.0.0.1:1234/v1/models' -TimeoutSec 4 -UseBasicParsing
    if ($r.StatusCode -eq 200) {
        $lmStudioOk = $true
        $parsed = $r.Content | ConvertFrom-Json
        if ($parsed.data) {
            $ids = @($parsed.data | ForEach-Object { $_.id })
            $lmModelCount = $ids.Count
            $lmModels = ($ids -join ',')
            if ($lmModels.Length -gt 120) { $lmModels = $lmModels.Substring(0, 120) }
            $lmTier3Ok = ($requiredTier3 | Where-Object { $ids -notcontains $_ }).Count -eq 0
        }
    }
}
catch { }

$payload = [ordered]@{
    node           = 'cornerman'
    hostname       = $env:COMPUTERNAME
    gitHead        = $gitHead.Trim()
    relayCmd       = Test-Path -LiteralPath (Join-Path $rag 'Talk to Vengeance.cmd')
    relayStarter   = Test-Path -LiteralPath (Join-Path $rag 'Start-CornermanVoiceRelay.ps1')
    outboxExists   = Test-Path -LiteralPath (Join-Path $rag 'outbox\to-vengeance.txt')
    relayRunning   = $relayRunning
    sttPathLast    = $sttTail
    headlessLogOk  = Test-Path -LiteralPath $headlessLog
    lmStudioOk     = $lmStudioOk
    lmModelCount   = $lmModelCount
    lmTier3Ok      = $lmTier3Ok
    lmModels       = $lmModels
}
$payload | ConvertTo-Json -Compress
