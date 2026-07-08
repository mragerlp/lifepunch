<#
.SYNOPSIS
  Start LM Studio server on Cornerman and warm Tier-3 models.

.PARAMETER WarmModel
  daily   = distill + embed loaded (default - Cornerman daily lane)
  distill = qwen/qwen3.6-35b-a3b only
  coder   = qwen2.5-coder-32b-instruct only (unloads other big models first)
  all     = alias for daily + verify coder catalog (do NOT load 35b+32b together)
  none    = server only

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File Start-CornermanLmStudio.ps1 -WarmModel daily
#>
[CmdletBinding()]
param(
    [ValidateSet('daily', 'distill', 'deep', 'coder', 'fast', 'all', 'none')]
    [string] $WarmModel = 'daily',
    [string] $BindHost = 'auto',
    [int] $Port = 1234,
    [switch] $Quiet
)

$ErrorActionPreference = 'Stop'

function Import-CornermanTier3Catalog {
    $candidates = @(
        (Join-Path $PSScriptRoot '..\config\cornerman-tier3-models.json')
        'C:\lifepunch\cornerman\config\cornerman-tier3-models.json'
    )
    foreach ($path in $candidates) {
        if (-not (Test-Path -LiteralPath $path)) { continue }
        try {
            $cfg = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
            $ids = @($cfg.catalog | ForEach-Object { [string]$_.model })
            if ($ids.Count -gt 0) {
                return @{ Models = $ids; Config = $cfg; Path = $path }
            }
        }
        catch { }
    }
    return $null
}

$imported = Import-CornermanTier3Catalog
if ($imported) {
    $script:CornermanTier3Models = $imported.Models
    $script:CornermanTier3Config = $imported.Config
}
else {
    # Fallback if JSON not synced yet
    $script:CornermanTier3Models = @(
        'qwen/qwen3.6-35b-a3b'
        'qwen2.5-coder-32b-instruct'
        'text-embedding-nomic-embed-text-v1.5'
    )
    $script:CornermanTier3Config = $null
}

# Canonical Cornerman Tier-3 catalog - prefer lifepunch/config/cornerman-tier3-models.json

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

function Enter-LmsCliLock {
    if (-not $script:LmsCliMutex) {
        $script:LmsCliMutex = New-Object System.Threading.Mutex($false, 'Global\LifePunch.Cornerman.LmsCli')
    }
    if (-not $script:LmsCliMutex.WaitOne(120000)) {
        throw 'Timed out waiting for lms CLI (another warm/watchdog script is running). Retry in 30s.'
    }
}

function Exit-LmsCliLock {
    if ($script:LmsCliMutex) {
        try { [void]$script:LmsCliMutex.ReleaseMutex() } catch { }
    }
}

function Test-LmsCliBusyError([string]$Text) {
    return $Text -match 'being used by another process|cannot access the file'
}

function Invoke-LmsCapture {
    param([string[]] $LmsArgs)
    Enter-LmsCliLock
    $prev = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        try {
            $out = @(& $script:lms @LmsArgs 2>&1 | ForEach-Object { "$_" })
        }
        catch {
            $msg = $_.Exception.Message
            if (Test-LmsCliBusyError $msg) {
                $script:LmsCliBusy = $true
                return ''
            }
            throw
        }
        $joined = $out -join "`n"
        if (Test-LmsCliBusyError $joined) {
            $script:LmsCliBusy = $true
            return ''
        }
        return $joined
    }
    finally {
        $ErrorActionPreference = $prev
        Exit-LmsCliLock
    }
}

function Invoke-Lms {
    param([Parameter(Mandatory)][string[]] $LmsArgs)
    Enter-LmsCliLock
    $prev = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        try {
            $out = @(& $script:lms @LmsArgs 2>&1 | ForEach-Object { "$_" })
        }
        catch {
            $msg = $_.Exception.Message
            if (Test-LmsCliBusyError $msg) {
                $script:LmsCliBusy = $true
                $script:LastLmsOutput = $msg
                Write-Lms "WARN: lms CLI busy (LM Studio already running) - using HTTP probe fallback."
                return 1
            }
            throw
        }
        $code = $LASTEXITCODE
        $script:LastLmsOutput = $out -join "`n"
        if (Test-LmsCliBusyError $script:LastLmsOutput) {
            $script:LmsCliBusy = $true
            Write-Lms "WARN: lms CLI busy - using HTTP probe fallback."
            return 1
        }
        $out | ForEach-Object { Write-Lms "$_" }
        return $code
    }
    finally {
        $ErrorActionPreference = $prev
        Exit-LmsCliLock
    }
}

function Test-LmsAlreadyLoaded {
    param([string]$Text)
    return $Text -match 'already exists|already loaded|is already loaded'
}

function Get-CornermanBindHost {
    param([string] $Preferred = 'auto')
    # 0.0.0.0 - localhost for cornerman-lm MCP on Green + LAN for Red warm probes.
    if (-not $Preferred -or $Preferred -eq 'auto') { return '0.0.0.0' }
    if ($Preferred -eq '0.0.0.0' -or $Preferred -eq '127.0.0.1') { return $Preferred }
    $hit = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
        Where-Object { $_.IPAddress -eq $Preferred }
    if ($hit) { return $Preferred }
    Write-Lms "BindHost $Preferred not on this box - using 0.0.0.0"
    return '0.0.0.0'
}

function Remove-DuplicateLmsLoads {
    $psText = Invoke-LmsCapture -LmsArgs @('ps')
    $dupIds = [regex]::Matches($psText, '(?m)^(\S+:\d+)\s') |
        ForEach-Object { $_.Groups[1].Value } |
        Select-Object -Unique
    foreach ($dupId in $dupIds) {
        Write-Lms "Unloading duplicate LM instance: $dupId"
        Invoke-Lms -LmsArgs @('unload', $dupId) | Out-Null
    }
}

function Get-LmsProbeHosts([string]$BindHost) {
    $hosts = @('127.0.0.1')
    if ($BindHost -and $BindHost -ne '0.0.0.0' -and $BindHost -ne '127.0.0.1') {
        $hosts += $BindHost
    }
    $lan = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
        Where-Object { $_.IPAddress -like '192.168.*' } |
        Select-Object -First 1 -ExpandProperty IPAddress
    if ($lan -and $hosts -notcontains $lan) { $hosts += $lan }
    return $hosts
}

function Get-LmsCatalogIds([string]$BindHost) {
    foreach ($probeHost in (Get-LmsProbeHosts -BindHost $BindHost)) {
        try {
            $uri = "http://${probeHost}:${Port}/v1/models"
            return @((Invoke-RestMethod -Uri $uri -TimeoutSec 10).data.id)
        }
        catch { }
    }
    return @()
}

function Get-LmsLoadedIds {
    $psText = Invoke-LmsCapture -LmsArgs @('ps')
    if ($psText) {
        $fromPs = @([regex]::Matches($psText, '(?m)^(\S+)\s+\S+\s+(?:IDLE|RUNNING)\s') |
            ForEach-Object { $_.Groups[1].Value } |
            Select-Object -Unique)
        if ($fromPs.Count -gt 0) { return $fromPs }
    }
    # CLI locked or empty ps — API lists served models (good enough for warm checks).
    return @(Get-LmsCatalogIds -BindHost $script:BindHostResolved)
}

function Test-Tier3CatalogOnDisk {
    $apiIds = @(Get-LmsCatalogIds -BindHost $script:BindHostResolved)
    if ($apiIds.Count -gt 0) {
        $allOnApi = $true
        foreach ($id in $script:CornermanTier3Models) {
            if (-not (Test-ModelPresent -Present $apiIds -RequiredId $id)) { $allOnApi = $false; break }
        }
        if ($allOnApi) { return $true }
    }
    $lsText = Invoke-LmsCapture -LmsArgs @('ls')
    if (-not $lsText -and $script:LmsCliBusy) {
        return $apiIds.Count -gt 0
    }
    foreach ($id in $script:CornermanTier3Models) {
        $needle = if ($id -like '*embed*') { 'nomic-embed' } else { ($id -split '/')[-1] }
        if ($lsText -notmatch [regex]::Escape($needle)) { return $false }
    }
    return $true
}

function Test-LmsServerUp([string]$BindHost) {
    foreach ($probeHost in (Get-LmsProbeHosts -BindHost $BindHost)) {
        try {
            $uri = "http://${probeHost}:${Port}/v1/models"
            Invoke-RestMethod -Uri $uri -TimeoutSec 10 | Out-Null
            return $true
        }
        catch { }
    }
    return $false
}

function Get-WarmTargets([string]$Mode) {
    if ($script:CornermanTier3Config -and $script:CornermanTier3Config.warmProfiles.$Mode) {
        $profileIds = @($script:CornermanTier3Config.warmProfiles.$Mode)
        $byId = @{}
        foreach ($entry in $script:CornermanTier3Config.catalog) { $byId[$entry.id] = $entry.model }
        return @($profileIds | ForEach-Object { $byId[$_] } | Where-Object { $_ })
    }
    switch ($Mode) {
        'deep'    { return @('qwen/qwen3.6-27b') }
        'daily'   { return @('qwen/qwen3.6-35b-a3b', 'text-embedding-nomic-embed-text-v1.5') }
        'distill' { return @('qwen/qwen3.6-35b-a3b') }
        'fast'    { return @('qwen/qwen3.5-9b') }
        'coder'   { return @('qwen2.5-coder-32b-instruct') }
        'all'     { return @('qwen/qwen3.6-35b-a3b', 'text-embedding-nomic-embed-text-v1.5') }
        default   { return @() }
    }
}

function Unload-BigLmsModels {
    $psText = Invoke-LmsCapture -LmsArgs @('ps')
    foreach ($id in @('qwen/qwen3.6-35b-a3b', 'qwen2.5-coder-32b-instruct')) {
        if ($psText -match "(?m)^$([regex]::Escape($id))\s") {
            Write-Lms "Unloading $id before coder warm..."
            Invoke-Lms -LmsArgs @('unload', $id) | Out-Null
        }
    }
    Remove-DuplicateLmsLoads
}

function Test-ModelPresent([string[]]$Present, [string]$RequiredId) {
    if ($Present -contains $RequiredId) { return $true }
    # LM Studio may alias embed models (e.g. lp-embed) while API still serves /v1/models.
    if ($RequiredId -like '*embed*') {
        return @($Present | Where-Object { $_ -like '*embed*' -or $_ -eq 'lp-embed' }).Count -gt 0
    }
    return $false
}

function Test-WarmTargetsReady([string]$BindHost, [string[]]$Required) {
    if (-not (Test-LmsServerUp -BindHost $BindHost)) { return $false }
    $loaded = Get-LmsLoadedIds
    if ($loaded.Count -eq 0) { return $false }
    foreach ($id in $Required) {
        if (-not (Test-ModelPresent -Present $loaded -RequiredId $id)) { return $false }
    }
    return $true
}

function Test-Tier3ServeReady([string]$BindHost) {
    if (-not (Test-Tier3CatalogOnDisk)) { return $false }
    if (-not (Test-LmsServerUp -BindHost $BindHost)) { return $false }
    $loaded = Get-LmsLoadedIds
    foreach ($id in @('qwen/qwen3.6-35b-a3b', 'text-embedding-nomic-embed-text-v1.5')) {
        if (-not (Test-ModelPresent -Present $loaded -RequiredId $id)) { return $false }
    }
    return $true
}

function Write-LmsServeStatus([string]$BindHost) {
    $loaded = Get-LmsLoadedIds
    $catalogOnly = @($script:CornermanTier3Models | Where-Object { $loaded -notcontains $_ })
    Write-Lms ('LOADED in VRAM ({0}):' -f $loaded.Count)
    if ($loaded.Count -eq 0) { Write-Host '  (none)' }
    else { $loaded | ForEach-Object { Write-Host "  $_" } }
    if ($catalogOnly.Count -gt 0) {
        Write-Lms ('On disk only ({0}) - load via WarmCoder when needed:' -f $catalogOnly.Count)
        $catalogOnly | ForEach-Object { Write-Host "  $_" }
    }
}

$BindHost = Get-CornermanBindHost -Preferred $BindHost
$script:BindHostResolved = $BindHost
$script:LmsCliBusy = $false
$script:lms = Get-LmsExe
$effectiveMode = if ($WarmModel -eq 'all') { 'daily' } else { $WarmModel }
$targets = Get-WarmTargets -Mode $effectiveMode

if ($WarmModel -eq 'none') {
    # server-only path below
}
elseif ($WarmModel -in 'daily', 'all' -and (Test-Tier3ServeReady -BindHost $BindHost)) {
    Write-Lms "Tier-3 serve ready (distill + embed loaded on :$Port)"
    # Ready-path still dedupes: a duplicate ":2" instance from an earlier boot race
    # otherwise survives every subsequent boot (this early return used to skip it).
    Remove-DuplicateLmsLoads
    if (-not $Quiet) { Write-LmsServeStatus -BindHost $BindHost }
    return
}
elseif ($WarmModel -notin 'daily', 'all', 'none' -and (Test-WarmTargetsReady -BindHost $BindHost -Required $targets)) {
    Write-Lms ('Warm targets ready ({0} loaded) on :{1}' -f $targets.Count, $Port)
    if (-not $Quiet) { Write-LmsServeStatus -BindHost $BindHost }
    return
}

Write-Lms "LM Studio: $script:lms (bind $BindHost)"
if ($effectiveMode -eq 'coder') { Unload-BigLmsModels }
else { Remove-DuplicateLmsLoads }

if (Test-LmsServerUp -BindHost $BindHost) {
    Write-Lms "LM server already listening on :$Port (skip lms server start)."
}
else {
    $startCode = Invoke-Lms -LmsArgs @('server', 'start', '--port', "$Port", '--bind', $BindHost)
    if ($startCode -ne 0 -and -not (Test-LmsServerUp -BindHost $BindHost)) {
        if ($script:LmsCliBusy) {
            throw "lms server start skipped (CLI busy) and :$Port probe unreachable. Close duplicate warm scripts or wait 30s."
        }
        throw "lms server start failed (exit $startCode) and probe unreachable"
    }
}

foreach ($modelId in $targets) {
    $loaded = Get-LmsLoadedIds
    if (Test-ModelPresent -Present $loaded -RequiredId $modelId) {
        Write-Lms "Already loaded in VRAM: $modelId"
        continue
    }
    $gpuFlag = if ($modelId -like '*embed*') { '0.05' } else { 'max' }
    # Big models: pin context + parallel explicitly. Relying on app defaults let a runtime
    # update flip parallel to 4, splitting the 32000 context into ~8k slots — Daily-route
    # packets then died at finish_reason:length with empty content (2026-07-08 triage).
    $loadArgs = @('load', $modelId, '--gpu', $gpuFlag)
    if ($modelId -notlike '*embed*') {
        $loadArgs += @('--context-length', '32000', '--parallel', '1')
    }
    $loadArgs += '-y'
    Write-Lms "Loading $modelId (gpu $gpuFlag)..."
    $loadCode = Invoke-Lms -LmsArgs $loadArgs
    if ($loadCode -ne 0 -and -not (Test-LmsAlreadyLoaded -Text $script:LastLmsOutput)) {
        throw "lms load failed for $modelId (exit $loadCode)"
    }
    if (Test-LmsAlreadyLoaded -Text $script:LastLmsOutput) {
        Write-Lms "Already loaded in LM Studio: $modelId"
    }
}

# The load loop can race LM Studio's own last-session restore (fresh boot, CLI briefly busy)
# and end up with a duplicate ":2" instance — sweep once more now that loads have settled.
Remove-DuplicateLmsLoads

if ($WarmModel -ne 'none') {
    if ($WarmModel -in 'daily', 'all') {
        if (-not (Test-Tier3CatalogOnDisk)) {
            throw 'Tier-3 catalog incomplete on disk - download all three models in LM Studio first.'
        }
        if (-not (Test-Tier3ServeReady -BindHost $BindHost)) {
            $have = (Get-LmsLoadedIds) -join ', '
            throw "Tier-3 serve incomplete after warm. Need distill+embed loaded on :$Port. Loaded: $have"
        }
        Write-Lms 'Tier-3 catalog OK - coder on disk; WarmCoder swaps GPU when C# drafts needed.'
    }
    elseif (-not (Test-WarmTargetsReady -BindHost $BindHost -Required $targets)) {
        $have = (Get-LmsLoadedIds) -join ', '
        throw "Warm incomplete. Expected loaded: $($targets -join ', '). Loaded: $have"
    }
}

try {
    $probeHost = (Get-LmsProbeHosts -BindHost $BindHost | Select-Object -First 1)
    $uri = "http://${probeHost}:${Port}/v1/models"
    $loaded = Get-LmsLoadedIds
    Write-Lms ('LM OK: {0} ({1} loaded in VRAM)' -f $uri, $loaded.Count)
    if (-not $Quiet) { Write-LmsServeStatus -BindHost $BindHost }
}
catch {
    $msg = $_.Exception.Message
    throw ('LM Studio server up but probe failed: {0} - {1}' -f $uri, $msg)
}
