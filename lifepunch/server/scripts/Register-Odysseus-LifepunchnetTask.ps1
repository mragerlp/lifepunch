# Register Odysseus at logon on lifepunchnet (after admin password set in UI once).
# Run elevated on lifepunchnet.

param(
    [string] $InstallDir = 'C:\lifepunch\odysseus',
    [string] $TaskName = 'LifePunch-Odysseus'
)

$ErrorActionPreference = 'Stop'
$launch = Join-Path $InstallDir 'launch-windows.ps1'
if (-not (Test-Path -LiteralPath $launch)) {
    throw "Missing $launch - run Install-Odysseus-Lifepunchnet.ps1 first."
}

$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument @(
    '-NoProfile', '-ExecutionPolicy', 'Bypass', '-WindowStyle', 'Hidden',
    '-Command', "Set-Location '$InstallDir'; .\launch-windows.ps1"
)
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited
Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Principal $principal -Force | Out-Null
Write-Host "Registered $TaskName at logon." -ForegroundColor Green
