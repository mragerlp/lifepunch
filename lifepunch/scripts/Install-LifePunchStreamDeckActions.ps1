[CmdletBinding()]
param(
    [string]$OutputFolder = "$env:USERPROFILE\Desktop\LifePunch StreamDeck Actions"
)

$ErrorActionPreference = 'Stop'
$scriptsRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$launcher = Join-Path $scriptsRoot 'Invoke-LifePunchDeckAction.ps1'

if (-not (Test-Path -LiteralPath $launcher)) {
    throw "Missing launcher: $launcher"
}

New-Item -ItemType Directory -Force -Path $OutputFolder | Out-Null

$items = @(
    @{ File = '01-LP-Repo.cmd'; Title = 'LP Repo'; Args = '-Action OpenRepo'; NoExit = $false },
    @{ File = '02-LP-Bitcoin-Files.cmd'; Title = 'LP Bitcoin Files'; Args = '-Action OpenLpBitcoinFiles'; NoExit = $false },
    @{ File = '03-Start-DXRP-Editor.cmd'; Title = 'Start DXRP Editor'; Args = '-Action StartSboxEditor'; NoExit = $false },
    @{ File = '04-Sync-Addons.cmd'; Title = 'Sync Addons'; Args = '-Action SyncAddons'; NoExit = $false },
    @{ File = '05-DXRP-Portal-Chrome.cmd'; Title = 'DXRP Portal Chrome'; Args = '-Action OpenDxrpPortalChrome'; NoExit = $false },
    @{ File = '06-MCP-Health.cmd'; Title = 'MCP Health'; Args = '-Action McpHealth'; NoExit = $true },
    @{ File = '07-Git-Status.cmd'; Title = 'Git Status'; Args = '-Action GitStatus'; NoExit = $true },
    @{ File = '08-Pull-Rebase.cmd'; Title = 'Pull Rebase'; Args = '-Action GitPullRebase'; NoExit = $true },
    @{ File = '09-CVL-Health.cmd'; Title = 'CVL Health'; Args = '-Action CvlObservability'; NoExit = $true },
    @{ File = '10-Start-LifePunch-Day.cmd'; Title = 'Start LifePunch Day'; Args = '-NoProfile -ExecutionPolicy Bypass -File "C:\Users\jared\Projects\lifepunch\lifepunch\scripts\Start-LifePunchDay.ps1"'; NoExit = $true; IsDirect = $true }
)

foreach ($item in $items) {
    $cmdPath = Join-Path $OutputFolder $item.File

    if ($item.IsDirect) {
        $cmdBody = @"
@echo off
title $($item.Title)
powershell.exe $($item.Args)
"@
    }
    else {
        $shellMode = if ($item.NoExit) { '-NoExit -NoProfile' } else { '-NoProfile' }
        $cmdBody = @"
@echo off
title $($item.Title)
powershell.exe $shellMode -ExecutionPolicy Bypass -File "$launcher" $($item.Args)
"@
    }

    Set-Content -LiteralPath $cmdPath -Value $cmdBody -Encoding ASCII
}

Write-Host "Created Stream Deck launcher files in: $OutputFolder" -ForegroundColor Green
Get-ChildItem -LiteralPath $OutputFolder -Filter '*.cmd' | Sort-Object Name | Select-Object -ExpandProperty Name
