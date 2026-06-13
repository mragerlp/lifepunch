<#
.SYNOPSIS
  Idempotent SMB map for \\VENGEANCE\SboxBridgeIpc (headless-safe).

.DESCRIPTION
  Tries in order:
    1. Share already reachable
    2. cmdkey generic LifePunch/VengeanceSmb (set once via Map-CornermanBridgeShare.ps1)
    3. cmdkey target VENGEANCE
    4. env:LIFEPUNCH_VENGEANCE_SMB_PASSWORD

  Exits 0 if mapped or already OK; 1 only when no credentials and share missing.

.EXAMPLE
  powershell -File C:\lifepunch\cornerman\Ensure-CornermanBridgeShare.ps1
#>
[CmdletBinding()]
param(
    [string] $VengeanceHost = 'VENGEANCE',
    [string] $VengeanceIp = '192.168.1.236',
    [string] $ShareName = 'SboxBridgeIpc',
    [string] $User = 'VENGEANCE\jared'
)

$ErrorActionPreference = 'Stop'
$uncHost = "\\$VengeanceHost\$ShareName"
$uncIp = "\\$VengeanceIp\$ShareName"

function Test-BridgeReachable {
    $statusHost = Join-Path $uncHost 'status.json'
    $statusIp = Join-Path $uncIp 'status.json'
    return (Test-Path -LiteralPath $uncHost) -or (Test-Path -LiteralPath $uncIp) `
        -or (Test-Path -LiteralPath $statusHost) -or (Test-Path -LiteralPath $statusIp)
}

if (Test-BridgeReachable) {
    Write-Host "OK bridge share already mapped ($uncHost)" -ForegroundColor Green
    exit 0
}

function Get-StoredPassword {
    $envPass = $env:LIFEPUNCH_VENGEANCE_SMB_PASSWORD
    if ($envPass) { return $envPass }

    foreach ($target in @('LifePunch/VengeanceSmb', $VengeanceHost, "LegacyGeneric:target=$VengeanceHost")) {
        $listing = cmdkey /list 2>$null | Out-String
        if ($listing -notmatch [regex]::Escape($target)) { continue }
        # cmdkey does not expose password — net use with saved cred only works after prior map.
    }
    return $null
}

function Invoke-Map([string] $Unc, [string] $PlainPassword) {
    net use $Unc /delete /y 2>$null | Out-Null
    if ($PlainPassword) {
        net use $Unc /user:$User $PlainPassword /persistent:yes | Out-Null
        return $LASTEXITCODE -eq 0
    }
    net use $Unc /persistent:yes 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) { return $true }
    net use $Unc /user:$User /persistent:yes 2>&1 | Out-Null
    return $LASTEXITCODE -eq 0
}

$plain = Get-StoredPassword
$mapped = Invoke-Map -Unc $uncHost -PlainPassword $plain
if (-not $mapped) {
    $mapped = Invoke-Map -Unc $uncIp -PlainPassword $plain
}

if (Test-BridgeReachable) {
    Write-Host "OK bridge share mapped ($uncHost)" -ForegroundColor Green
    exit 0
}

Write-Host 'SKIP — bridge share not mapped (run Map-CornermanBridgeShare.ps1 once on Green desktop).' -ForegroundColor Yellow
exit 1
