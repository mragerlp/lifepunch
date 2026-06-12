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
$lmCatalogOk = $false
$requiredCatalog = @(
    'qwen/qwen3.6-35b-a3b'
    'qwen2.5-coder-32b-instruct'
    'text-embedding-nomic-embed-text-v1.5'
)
$requiredServe = @(
    'qwen/qwen3.6-35b-a3b'
    'text-embedding-nomic-embed-text-v1.5'
)
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

        function Test-IdPresent($req, $ids) {
            if ($ids -contains $req) { return $true }
            if ($req -like '*embed*') {
                return @($ids | Where-Object { $_ -like '*embed*' -or $_ -eq 'lp-embed' }).Count -gt 0
            }
            return $false
        }
        $catalogMissing = @($requiredCatalog | Where-Object { -not (Test-IdPresent $_ $ids) })
        $serveMissing = @($requiredServe | Where-Object { -not (Test-IdPresent $_ $ids) })
        $lmCatalogOk = ($catalogMissing.Count -eq 0)
        $lmTier3Ok = $lmCatalogOk -and ($serveMissing.Count -eq 0)
        if ($lmTier3Ok) { break }
    }
    catch { }
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
    lmTier3Ok      = $lmTier3Ok
    lmCatalogOk    = $lmCatalogOk
    lmModels       = $lmModels
}
$payload | ConvertTo-Json -Compress
