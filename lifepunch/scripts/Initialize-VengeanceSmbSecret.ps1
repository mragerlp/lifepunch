<#
.SYNOPSIS
  Save VENGEANCE\jared SMB password for headless Cornerman bridge scripts (UTF-8, no BOM).
#>
[CmdletBinding()]
param(
    [switch] $VerifyMap,
    [string] $SshTarget = ''
)
$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
. (Join-Path $Here 'Cornerman-Workflow.ps1')
if (-not $SshTarget) { $SshTarget = Get-CornermanSshTarget }
$repaired = Repair-VengeanceSmbPasswordFile
if ($repaired) { Write-Host 'Repaired UTF-8 BOM on existing vengeance-smb.password' -ForegroundColor Yellow }
$path = Get-VengeanceSmbPasswordPath
Write-Host ''; Write-Host 'LIFEPUNCH — VENGEANCE SMB password (headless bridge)' -ForegroundColor Cyan
Write-Host "File: $path" -ForegroundColor DarkGray
Write-Host 'Use Windows sign-in PASSWORD (not PIN).' -ForegroundColor Yellow; Write-Host ''
$sec = Read-Host 'VENGEANCE\jared password' -AsSecureString
$saved = Set-VengeanceSmbPassword -Password $sec
Write-Host "Saved (UTF-8 no BOM): $saved" -ForegroundColor Green
if (-not $VerifyMap) { Write-Host 'Verify: powershell -File lifepunch\scripts\Connect-CornermanBridge.ps1 -SkipLmWarm' -ForegroundColor DarkGray; exit 0 }
if (-not (Test-CornermanSshReady -SshTarget $SshTarget)) { throw "Cornerman SSH not ready ($SshTarget)" }
$map = Invoke-CornermanMapBridgeShare -SshTarget $SshTarget
if ($map.Ok) { Write-Host $map.Output -ForegroundColor Green; Write-Host 'Headless SMB map OK.' -ForegroundColor Green; exit 0 }
Write-Host $map.Output -ForegroundColor Red; throw 'Headless SMB map failed.'
