# CVL session hub bridge — tier-tagged ingest to lifepunchnet :9102.
# Tiers (uniform): universal=tri-stack | vengeance=red | cornerman=green | lifepunchnet=blue

function Get-CvlHubConfig {
    param([string]$ConfigPath = '')
    $here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
    if (-not $ConfigPath) { $ConfigPath = Join-Path $here 'server-host-watch.local.json' }
    if (-not (Test-Path -LiteralPath $ConfigPath)) {
        throw "Missing $ConfigPath - copy server-host-watch.local.json.example and add lifepunchnet token."
    }
    return Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
}

function Send-CvlHubIngest {
    param(
        [Parameter(Mandatory)]
        [ValidateSet('universal', 'vengeance', 'cornerman', 'lifepunchnet')]
        [string] $Tier,
        [Parameter(Mandatory)]
        [string] $Type,
        [Parameter(Mandatory)]
        [string] $Text,
        [string] $Source = '',
        [hashtable] $Extra = @{},
        $Config = $null
    )
    if (-not $Config) { $Config = Get-CvlHubConfig }
    if (-not $Source) {
        $Source = switch ($Tier) {
            'vengeance' { 'vengeance' }
            'cornerman' { 'cornerman' }
            'lifepunchnet' { 'lifepunchnet' }
            default { 'cvl' }
        }
    }
    $hostAddr = [string]$Config.host
    $port = if ($Config.sessionPort) { [int]$Config.sessionPort } else { 9102 }
    $token = [string]$Config.token
    $uri = "http://${hostAddr}:${port}/ingest"
    $headers = @{ Authorization = "Bearer $token" }
    $payload = [ordered]@{
        ts     = (Get-Date).ToUniversalTime().ToString('o')
        tier   = $Tier
        source = $Source
        type   = $Type
        text   = $Text.Trim()
    }
    $forbidden = @('token', 'password', 'secret', 'apikey', 'bearer', 'authorization')
    foreach ($k in $Extra.Keys) {
        $lk = $k.ToString().ToLowerInvariant()
        if ($forbidden | Where-Object { $lk -eq $_ -or $lk -like "*$_*" }) { continue }
        if ($null -ne $Extra[$k]) { $payload[$k] = $Extra[$k] }
    }
    $body = ($payload | ConvertTo-Json -Compress -Depth 10)
    Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body -ContentType 'application/json' -TimeoutSec 15 | Out-Null
}

function Send-CvlHubObject {
    param(
        [Parameter(Mandatory)]
        [hashtable] $Payload,
        $Config = $null
    )
    if (-not $Config) { $Config = Get-CvlHubConfig }
    if (-not $Payload.tier) { $Payload.tier = 'universal' }
    if (-not $Payload.ts) { $Payload.ts = (Get-Date).ToUniversalTime().ToString('o') }
    if (-not $Payload.type) { $Payload.type = 'cvl-event' }
    if (-not $Payload.text -and $Payload.summary) { $Payload.text = [string]$Payload.summary }
    $hostAddr = [string]$Config.host
    $port = if ($Config.sessionPort) { [int]$Config.sessionPort } else { 9102 }
    $token = [string]$Config.token
    $uri = "http://${hostAddr}:${port}/ingest"
    $headers = @{ Authorization = "Bearer $token" }
    $body = ($Payload | ConvertTo-Json -Compress -Depth 12)
    Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body -ContentType 'application/json' -TimeoutSec 15 | Out-Null
}
