# Install lifepunchnet session hub (voice/chat ingest on :9102). Run ELEVATED on lifepunchnet.

param(
    [int] $Port = 9102,
    [string] $HubDir = 'C:\lifepunch\session-hub',
    [string] $RemoteAddress = ''
)

$ErrorActionPreference = 'Stop'

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
          ).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if (-not $isAdmin) { throw 'Run elevated on lifepunchnet.' }

$here = $PSScriptRoot
$ingest = Join-Path $here 'ServerHost-SessionIngest.ps1'
if (-not (Test-Path -LiteralPath $ingest)) { throw "Missing $ingest" }

New-Item -ItemType Directory -Force -Path $HubDir | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $HubDir 'imports') | Out-Null

$prefix = "http://+:$Port/"
$urlacl = netsh http show urlacl url=$prefix 2>$null
if ($urlacl -notmatch [regex]::Escape($prefix)) {
    netsh http add urlacl url=$prefix user="$env:USERDOMAIN\$env:USERNAME" | Out-Null
}

$ruleName = 'LifePunch-SessionHub'
if (Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue) {
    Remove-NetFirewallRule -DisplayName $ruleName
}
$fwArgs = @{
    DisplayName = $ruleName
    Direction   = 'Inbound'
    Action      = 'Allow'
    Protocol    = 'TCP'
    LocalPort   = $Port
    Profile     = 'Public'
}
if ($RemoteAddress) { $fwArgs['RemoteAddress'] = $RemoteAddress.Trim() }
New-NetFirewallRule @fwArgs | Out-Null

$action = New-ScheduledTaskAction -Execute 'powershell.exe' `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$ingest`" -Port $Port"
$trigger = New-ScheduledTaskTrigger -AtStartup
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
    -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)
Register-ScheduledTask -TaskName 'LifePunch-SessionHub' -Action $action -Trigger $trigger `
    -Settings $settings -RunLevel Highest -Force | Out-Null

Start-ScheduledTask -TaskName 'LifePunch-SessionHub' -ErrorAction SilentlyContinue

Write-Host ''
Write-Host 'Session hub installed:' -ForegroundColor Green
Write-Host "  Hub dir   $HubDir"
Write-Host "  HTTP      http://<lifepunchnet-ip>:$Port/ingest  (Bearer token = status-token.txt)"
Write-Host "  Tail      GET /tail?lines=50"
if ($RemoteAddress) {
    Write-Host "  Firewall  TCP $Port open for $RemoteAddress" -ForegroundColor DarkGray
}
else {
    Write-Host '  Firewall  TCP $Port open on Public — pass -RemoteAddress your home IP to scope' -ForegroundColor Yellow
}
