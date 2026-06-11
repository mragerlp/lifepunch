<#
.SYNOPSIS
  Push reboot-critical Cornerman scripts to C:\lifepunch\cornerman\ before a Green reboot.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File Sync-CornermanRebootScripts.ps1
#>
$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
. (Join-Path $Here 'Cornerman-Workflow.ps1')
$SshTarget = Get-CornermanSshTarget
if (-not (Test-CornermanSshReady -SshTarget $SshTarget)) {
    throw "Cornerman SSH not ready ($SshTarget)"
}

$onBox = 'C:\lifepunch\cornerman'
$files = @(
    'Invoke-CornermanHeadlessBoot.ps1',
    'Start-CornermanLmStudio.ps1',
    'Install-CornermanHeadlessBoot.ps1'
)
foreach ($name in $files) {
    $local = Join-Path $Here $name
    if (-not (Test-Path -LiteralPath $local)) { throw "Missing $local" }
    $bytes = [IO.File]::ReadAllBytes($local)
    Push-CornermanFile -Path (Join-Path $onBox $name) -FileBytes $bytes -SshTarget $SshTarget | Out-Null
    Write-Host "OK $name" -ForegroundColor Green
}

Write-Host ''
Write-Host 'On Cornerman (elevated, once per box):' -ForegroundColor Cyan
Write-Host '  powershell -ExecutionPolicy Bypass -File C:\lifepunch\cornerman\Install-CornermanHeadlessBoot.ps1'
