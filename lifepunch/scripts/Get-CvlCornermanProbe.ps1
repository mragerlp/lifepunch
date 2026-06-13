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

$requiredCatalog = @(
    'qwen/qwen3.6-35b-a3b'
    'qwen2.5-coder-32b-instruct'
    'text-embedding-nomic-embed-text-v1.5'
)
$requiredServe = @(
    'qwen/qwen3.6-35b-a3b'
    'text-embedding-nomic-embed-text-v1.5'
)

function Test-IdPresent($req, $ids) {
    if ($ids -contains $req) { return $true }
    if ($req -like '*embed*') {
        return @($ids | Where-Object { $_ -like '*embed*' -or $_ -eq 'lp-embed' }).Count -gt 0
    }
    return $false
}

function Get-LmsExe {
    $candidates = @(
        (Join-Path $env:USERPROFILE '.lmstudio\bin\lms.exe')
        (Join-Path $env:LOCALAPPDATA 'LM Studio\bin\lms.exe')
    )
    foreach ($c in $candidates) {
        if (Test-Path -LiteralPath $c) { return $c }
    }
    return $null
}

function Get-LmsLoadedIds {
    $lms = Get-LmsExe
    if (-not $lms) { return @() }
    $psText = (& $lms ps 2>&1 | ForEach-Object { "$_" }) -join "`n"
    return @([regex]::Matches($psText, '(?m)^(\S+)\s+\S+\s+(?:IDLE|RUNNING)\s') |
        ForEach-Object { $_.Groups[1].Value } |
        Select-Object -Unique)
}

$lmStudioOk = $false
$lmModelCount = 0
$lmModels = ''
$lmCatalogOk = $false
$lmServeOk = $false
$lmTier3Ok = $false
$lmVramCount = 0
$lmVramLoaded = ''
$lmWatchdogOk = $false

$watchdog = schtasks /Query /TN LifePunch-Cornerman-LM-Watchdog /FO LIST 2>$null
if ($watchdog -match 'Ready|Running') { $lmWatchdogOk = $true }

$lmProbeHosts = @('127.0.0.1')
$lanIp = (Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Where-Object { $_.IPAddress -like '192.168.*' } |
    Select-Object -First 1).IPAddress
if ($lanIp) { $lmProbeHosts += $lanIp }

foreach ($probeHost in $lmProbeHosts) {
    try {
        $r = Invoke-WebRequest -Uri "http://${probeHost}:1234/v1/models" -TimeoutSec 4 -UseBasicParsing
        if ($r.StatusCode -ne 200) { continue }

        $lmStudioOk = $true
        $parsed = $r.Content | ConvertFrom-Json
        if (-not $parsed.data) { continue }

        $ids = @($parsed.data | ForEach-Object { $_.id })
        $lmModelCount = $ids.Count
        $lmModels = ($ids -join ',')
        if ($lmModels.Length -gt 120) { $lmModels = $lmModels.Substring(0, 120) }

        $catalogMissing = @($requiredCatalog | Where-Object { -not (Test-IdPresent $_ $ids) })
        $lmCatalogOk = ($catalogMissing.Count -eq 0)
        break
    }
    catch { }
}

$vramIds = @(Get-LmsLoadedIds)
$lmVramCount = $vramIds.Count
$lmVramLoaded = ($vramIds -join ',')
if ($lmVramLoaded.Length -gt 120) { $lmVramLoaded = $lmVramLoaded.Substring(0, 120) }

if ($lmStudioOk) {
    $serveMissing = @($requiredServe | Where-Object { -not (Test-IdPresent $_ $vramIds) })
    $lmServeOk = ($serveMissing.Count -eq 0) -and ($lmVramCount -gt 0)
    $lmTier3Ok = $lmCatalogOk -and $lmServeOk
}

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
    lmCatalogOk    = $lmCatalogOk
    lmServeOk      = $lmServeOk
    lmTier3Ok      = $lmTier3Ok
    lmVramCount    = $lmVramCount
    lmVramLoaded   = $lmVramLoaded
    lmWatchdogOk   = $lmWatchdogOk
    lmModels       = $lmModels
}
$payload | ConvertTo-Json -Compress
