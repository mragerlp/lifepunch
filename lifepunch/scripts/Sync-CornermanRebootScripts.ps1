<#
.SYNOPSIS
  Push reboot-critical Cornerman scripts to C:\lifepunch\cornerman\ before a Green reboot.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File Sync-CornermanRebootScripts.ps1
#>
$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }

# On Green itself, copy locally — no SSH hop from Cornerman to Cornerman.
if ($env:COMPUTERNAME -eq 'CORNERMAN') {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Here 'Sync-CornermanRebootScriptsLocal.ps1')
    return
}

. (Join-Path $Here 'Cornerman-Workflow.ps1')
$SshTarget = Get-CornermanSshTarget
if (-not (Test-CornermanSshReady -SshTarget $SshTarget)) {
    throw "Cornerman SSH not ready ($SshTarget)"
}

$onBox = 'C:\lifepunch\cornerman'
$files = @(
    'Invoke-CornermanHeadlessBoot.ps1',
    'Start-CornermanLmStudio.ps1',
    'Ensure-CornermanLmLanFirewall.ps1',
    'Install-CornermanHeadlessBoot.ps1',
    'Map-CornermanBridgeShare.ps1',
    'Ensure-CornermanBridgeShare.ps1',
    'Start-CornermanSboxEditorTunnel.ps1',
    'Install-CornermanSboxEditorTunnelWatchdog.ps1',
    'Install-CornermanGreenMcp.ps1',
    'Connect-CornermanBridge.ps1',
    'Install-CornermanLmWatchdog.ps1',
    'Get-CvlCornermanProbe.ps1',
    'Get-CornermanHealthProbe.ps1',
    'Remove-CornermanLemonade.ps1'
)
foreach ($name in $files) {
    $local = Join-Path $Here $name
    if (-not (Test-Path -LiteralPath $local)) { throw "Missing $local" }
    $dest = Join-Path $onBox $name
    if ($name -like '*.ps1') {
        $text = [IO.File]::ReadAllText($local)
        Push-CornermanText -Path $dest -Text $text -SshTarget $SshTarget | Out-Null
    }
    else {
        $bytes = [IO.File]::ReadAllBytes($local)
        Push-CornermanFile -Path $dest -FileBytes $bytes -SshTarget $SshTarget | Out-Null
    }
    Write-Host "OK $name" -ForegroundColor Green
}

$configSrc = Join-Path (Split-Path -Parent $Here) 'config\cornerman-tier3-models.json'
if (Test-Path -LiteralPath $configSrc) {
    $configDest = Join-Path $onBox 'config\cornerman-tier3-models.json'
    $bytes = [IO.File]::ReadAllBytes($configSrc)
    Push-CornermanFile -Path $configDest -FileBytes $bytes -SshTarget $SshTarget | Out-Null
    Write-Host 'OK cornerman-tier3-models.json -> config\' -ForegroundColor Green
}

Write-Host ''
Write-Host 'On Cornerman (elevated, once per box):' -ForegroundColor Cyan
Write-Host '  powershell -ExecutionPolicy Bypass -File C:\lifepunch\cornerman\Install-CornermanHeadlessBoot.ps1'
