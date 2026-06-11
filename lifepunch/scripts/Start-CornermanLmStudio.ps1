<#
.SYNOPSIS
  Start LM Studio server on Cornerman and optionally warm a Tier-3 model.

.PARAMETER WarmModel
  distill = qwen/qwen3.6-35b-a3b (doc prep default)
  coder   = qwen2.5-coder-32b-instruct
  none    = server only

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File Start-CornermanLmStudio.ps1 -WarmModel distill
#>
[CmdletBinding()]
param(
    [ValidateSet('distill', 'coder', 'none')]
    [string] $WarmModel = 'distill',
    [string] $BindHost = 'auto',
    [int] $Port = 1234,
    [switch] $Quiet
)

$ErrorActionPreference = 'Stop'

function Write-Lms([string]$m) {
    if (-not $Quiet) { Write-Host $m }
}

function Get-LmsExe {
    $candidates = @(
        (Join-Path $env:USERPROFILE '.lmstudio\bin\lms.exe'),
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
    $out = & $lms @LmsArgs 2>&1
    $code = $LASTEXITCODE
    $ErrorActionPreference = $prev
    $out | ForEach-Object { Write-Lms "$_" }
    return $code
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

function Test-LmsProbe {
    param([string] $HostIp)
    foreach ($probeHost in @($HostIp, '127.0.0.1')) {
        try {
            $uri = "http://${probeHost}:${Port}/v1/models"
            $null = Invoke-RestMethod -Uri $uri -TimeoutSec 10
            return $true
        }
        catch { }
    }
    return $false
}

$BindHost = Get-CornermanBindHost -Preferred $BindHost
$lms = Get-LmsExe
Write-Lms "LM Studio: $lms (bind $BindHost)"

$startCode = Invoke-Lms -LmsArgs @('server', 'start', '--port', "$Port", '--bind', $BindHost)
if ($startCode -ne 0 -and -not (Test-LmsProbe -HostIp $BindHost)) {
    throw "lms server start failed (exit $startCode) and probe unreachable"
}

$modelId = switch ($WarmModel) {
    'distill' { 'qwen/qwen3.6-35b-a3b' }
    'coder'   { 'qwen2.5-coder-32b-instruct' }
    default   { $null }
}

if ($modelId) {
    Write-Lms "Loading $modelId (gpu max)..."
    $loadCode = Invoke-Lms -LmsArgs @('load', $modelId, '--gpu', 'max', '-y')
    if ($loadCode -ne 0) { throw "lms load failed for $modelId (exit $loadCode)" }
}

try {
    $uri = "http://${BindHost}:${Port}/v1/models"
    $models = (Invoke-RestMethod -Uri $uri -TimeoutSec 15).data.id
    Write-Lms "Tier-3 OK: $uri"
    if (-not $Quiet) { $models | ForEach-Object { Write-Host "  $_" } }
}
catch {
    $msg = $_.Exception.Message
    throw "LM Studio server up but probe failed: $uri - $msg"
}
