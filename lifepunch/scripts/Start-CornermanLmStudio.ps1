<#
.SYNOPSIS
  Start LM Studio server on Cornerman and warm Tier-3 models.

.PARAMETER WarmModel
  distill = qwen/qwen3.6-35b-a3b only
  coder   = qwen2.5-coder-32b-instruct only
  all     = all three Tier-3 models (default for boot/watchdog)
  none    = server only

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File Start-CornermanLmStudio.ps1 -WarmModel all
#>
[CmdletBinding()]
param(
    [ValidateSet('distill', 'coder', 'all', 'none')]
    [string] $WarmModel = 'all',
    [string] $BindHost = 'auto',
    [int] $Port = 1234,
    [switch] $Quiet
)

$ErrorActionPreference = 'Stop'

# Canonical Cornerman Tier-3 catalog — keep in sync with cornerman-inbox-directive.json + CORNERMAN_MODEL_ROUTING.md
$script:CornermanTier3Models = @(
    'qwen/qwen3.6-35b-a3b'
    'qwen2.5-coder-32b-instruct'
    'text-embedding-nomic-embed-text-v1.5'
)

function Write-Lms([string]$m) {
    if (-not $Quiet) { Write-Host $m }
}

function Get-LmsExe {
    $candidates = @(
        (Join-Path $env:USERPROFILE '.lmstudio\bin\lms.exe')
        (Join-Path $env:LOCALAPPDATA 'LM Studio\bin\lms.exe')
    )
    foreach ($c in $candidates) {
        if (Test-Path -LiteralPath $c) { return $c }
    }
    $pathHit = Get-Command lms -ErrorAction SilentlyContinue
    if ($pathHit) { return $pathHit.Source }
    throw 'lms CLI not found. Install LM Studio and ensure lms is on PATH or under ~/.lmstudio/bin/'
}

function Invoke-Lms {
    param([Parameter(Mandatory)][string[]] $LmsArgs)
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $out = @(& $script:lms @LmsArgs 2>&1 | ForEach-Object { "$_" })
    $code = $LASTEXITCODE
    $ErrorActionPreference = $prev
    $script:LastLmsOutput = $out -join "`n"
    $out | ForEach-Object { Write-Lms "$_" }
    return $code
}

function Test-LmsAlreadyLoaded {
    param([string]$Text)
    return $Text -match 'already exists|already loaded|is already loaded'
}

function Get-CornermanBindHost {
    param([string] $Preferred = 'auto')
    if ($Preferred -and $Preferred -ne 'auto') {
        $hit = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
            Where-Object { $_.IPAddress -eq $Preferred }
        if ($hit) { return $Preferred }
        Write-Lms "BindHost $Preferred not on this box - auto-detecting LAN IP"
    }
    $addrs = @(Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
        Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*' })
    $eth = $addrs | Where-Object { $_.InterfaceAlias -match 'Ethernet|eth|LAN' } | Select-Object -First 1
    if ($eth) { return $eth.IPAddress }
    $priv = $addrs | Where-Object { $_.IPAddress -like '192.168.*' } | Select-Object -First 1
    if ($priv) { return $priv.IPAddress }
    if ($addrs.Count -gt 0) { return $addrs[0].IPAddress }
    return '127.0.0.1'
}

function Get-LmsModelIds([string]$HostIp) {
    foreach ($probeHost in @($HostIp, '127.0.0.1')) {
        try {
            $uri = "http://${probeHost}:${Port}/v1/models"
            return @((Invoke-RestMethod -Uri $uri -TimeoutSec 10).data.id)
        }
        catch { }
    }
    return @()
}

function Test-LmsProbe([string]$HostIp) {
    return (Get-LmsModelIds -HostIp $HostIp).Count -gt 0
}

function Get-WarmTargets([string]$Mode) {
    switch ($Mode) {
        'distill' { return @('qwen/qwen3.6-35b-a3b') }
        'coder'   { return @('qwen2.5-coder-32b-instruct') }
        'all'     { return $script:CornermanTier3Models }
        default   { return @() }
    }
}

function Test-ModelPresent([string[]]$Present, [string]$RequiredId) {
    if ($Present -contains $RequiredId) { return $true }
    # LM Studio may alias embed models (e.g. lp-embed) while API still serves /v1/models.
    if ($RequiredId -like '*embed*') {
        return @($Present | Where-Object { $_ -like '*embed*' -or $_ -eq 'lp-embed' }).Count -gt 0
    }
    return $false
}

function Test-Tier3Ready([string]$HostIp, [string[]]$Required) {
    $present = Get-LmsModelIds -HostIp $HostIp
    if ($present.Count -eq 0) { return $false }
    foreach ($id in $Required) {
        if (-not (Test-ModelPresent -Present $present -RequiredId $id)) { return $false }
    }
    return $true
}

$BindHost = Get-CornermanBindHost -Preferred $BindHost
$script:lms = Get-LmsExe
$targets = Get-WarmTargets -Mode $WarmModel

if ($WarmModel -ne 'none' -and (Test-Tier3Ready -HostIp $BindHost -Required $targets)) {
    Write-Lms "Tier-3 already ready ($($targets.Count) models) on :$Port"
    if (-not $Quiet) { Get-LmsModelIds -HostIp $BindHost | ForEach-Object { Write-Host "  $_" } }
    return
}

Write-Lms "LM Studio: $script:lms (bind $BindHost)"

$startCode = Invoke-Lms -LmsArgs @('server', 'start', '--port', "$Port", '--bind', $BindHost)
if ($startCode -ne 0 -and -not (Test-LmsProbe -HostIp $BindHost)) {
    throw "lms server start failed (exit $startCode) and probe unreachable"
}

foreach ($modelId in $targets) {
    $present = Get-LmsModelIds -HostIp $BindHost
    if (Test-ModelPresent -Present $present -RequiredId $modelId) {
        Write-Lms "Already listed: $modelId"
        continue
    }
    $gpuFlag = if ($modelId -like '*embed*') { '0.05' } else { 'max' }
    Write-Lms "Loading $modelId (gpu $gpuFlag)..."
    $loadCode = Invoke-Lms -LmsArgs @('load', $modelId, '--gpu', $gpuFlag, '-y')
    if ($loadCode -ne 0 -and -not (Test-LmsAlreadyLoaded -Text $script:LastLmsOutput)) {
        throw "lms load failed for $modelId (exit $loadCode)"
    }
    if (Test-LmsAlreadyLoaded -Text $script:LastLmsOutput) {
        Write-Lms "Already loaded in LM Studio: $modelId"
    }
}

if ($WarmModel -ne 'none') {
    if (-not (Test-Tier3Ready -HostIp $BindHost -Required $targets)) {
        $have = (Get-LmsModelIds -HostIp $BindHost) -join ', '
        throw "Tier-3 incomplete after warm. Expected: $($targets -join ', '). Have: $have"
    }
}

try {
    $uri = "http://${BindHost}:${Port}/v1/models"
    $models = Get-LmsModelIds -HostIp $BindHost
    Write-Lms "Tier-3 OK: $uri ($($models.Count) models)"
    if (-not $Quiet) { $models | ForEach-Object { Write-Host "  $_" } }
}
catch {
    $msg = $_.Exception.Message
    throw "LM Studio server up but probe failed: $uri - $msg"
}
