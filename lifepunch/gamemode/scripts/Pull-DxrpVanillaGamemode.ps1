<#
.SYNOPSIS
  Pull official DXRP Vanilla gamemode export from the public API into the repo.

.DESCRIPTION
  Vanilla is NOT stored in github.com/dxura/dxrp — it is served at:
    GET https://api.dxrp.net/v1/public/gamemode/default

  Writes:
    gamemodes/vanilla.gamemode
    config/vanilla-gamemode.json (fetch metadata)

.EXAMPLE
  powershell -File lifepunch\gamemode\scripts\Pull-DxrpVanillaGamemode.ps1
#>
[CmdletBinding()]
param(
    [string] $ApiUrl = 'https://api.dxrp.net/v1/public/gamemode/default'
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$GamemodeRoot = (Resolve-Path (Join-Path $Here '..')).Path
$OutPath = Join-Path $GamemodeRoot 'gamemodes\vanilla.gamemode'
$MetaPath = Join-Path $GamemodeRoot 'config\vanilla-gamemode.json'

Write-Host "Fetching DXRP Vanilla from $ApiUrl" -ForegroundColor Cyan
$response = Invoke-RestMethod -Uri $ApiUrl -Method Get

$response | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $OutPath -Encoding UTF8

$meta = [ordered]@{
    schemaVersion   = 1
    source          = 'DXRP public API (canonical vanilla — not in dxura/dxrp git)'
    apiUrl          = $ApiUrl
    fetchedAt       = (Get-Date).ToString('o')
    gamemode        = [ordered]@{
        id              = $response.id
        name            = $response.name
        description     = $response.description
        visibility      = $response.visibility
        defaultJobId    = $response.defaultJobId
        startingBalance = $response.startingBalance
        addonCount      = @($response.addons).Count
        jobCount        = @($response.jobs).Count
        created         = $response.created
        lastModified    = $response.lastModified
    }
    canonicalExport = 'gamemodes/vanilla.gamemode'
    notes           = @(
        'Official DXRP Vanilla — Base Content @ rev 3 only. No LifePunch addons.',
        'Portal "Reset to Vanilla" uses this template via API.',
        '70p / lifepunchmainserver stays on Vanilla until owner promotes ship gamemode.'
    )
}
$meta | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $MetaPath -Encoding UTF8

Write-Host "Saved $($response.name) -> $OutPath" -ForegroundColor Green
Write-Host "  id=$($response.id) addons=$(@($response.addons).Count) jobs=$(@($response.jobs).Count)" -ForegroundColor DarkGray
Write-Host "Metadata -> $MetaPath" -ForegroundColor DarkGray
