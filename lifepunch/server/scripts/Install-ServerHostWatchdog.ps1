# Install lifepunchnet watchdog + status HTTP server (run ELEVATED on lifepunchnet).

param(
    [int] $WatchdogIntervalMinutes = 2,
    [int] $StatusPort = 9101,
    [string] $StatusDir = 'C:\lifepunch\status',
    [string[]] $AllowedUsers = @('jared')
)

$ErrorActionPreference = 'Stop'

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
          ).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if (-not $isAdmin) { throw 'Run elevated on lifepunchnet.' }

$here = $PSScriptRoot
$watchdog = Join-Path $here 'ServerHost-Watchdog.ps1'
$server   = Join-Path $here 'ServerHost-StatusServer.ps1'
if (-not (Test-Path -LiteralPath $watchdog)) { throw "Missing $watchdog" }
if (-not (Test-Path -LiteralPath $server))   { throw "Missing $server" }

New-Item -ItemType Directory -Force -Path $StatusDir | Out-Null

$tokenFile = Join-Path $StatusDir 'status-token.txt'
if (-not (Test-Path -LiteralPath $tokenFile)) {
    $token = [guid]::NewGuid().ToString('N')
    Set-Content -LiteralPath $tokenFile -Value $token -Encoding ASCII -NoNewline
    Write-Host "Generated status token (copy to VENGEANCE):" -ForegroundColor Yellow
    Write-Host "  $token" -ForegroundColor Cyan
}
else {
    Write-Host 'Status token already exists — unchanged.' -ForegroundColor DarkGray
}

# HTTP urlacl for status server
$prefix = "http://+:$StatusPort/"
$urlacl = netsh http show urlacl url=$prefix 2>$null
if ($urlacl -notmatch [regex]::Escape($prefix)) {
    netsh http add urlacl url=$prefix user="$env:USERDOMAIN\$env:USERNAME" | Out-Null
    Write-Host "Registered urlacl for $prefix" -ForegroundColor DarkGray
}

# Firewall — scope to your admin IP in production; v1 allows inbound on Private
$ruleName = 'LifePunch-ServerHost-Status'
$existing = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
if (-not $existing) {
    New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -Action Allow `
        -Protocol TCP -LocalPort $StatusPort -Profile Private | Out-Null
    Write-Host "Firewall rule added (Private profile, port $StatusPort)." -ForegroundColor DarkGray
    Write-Host '  Tighten RemoteAddress to your home IP when known.' -ForegroundColor Yellow
}

$configPath = Join-Path $StatusDir 'watchdog-config.json'
@{ allowedUsers = $AllowedUsers } | ConvertTo-Json | Set-Content -LiteralPath $configPath -Encoding UTF8

# Scheduled task: watchdog collector
$watchAction = New-ScheduledTaskAction -Execute 'powershell.exe' `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$watchdog`""
$watchTrigger = New-ScheduledTaskTrigger -Once -At ((Get-Date).AddMinutes(1)) `
    -RepetitionInterval (New-TimeSpan -Minutes $WatchdogIntervalMinutes) `
    -RepetitionDuration ([TimeSpan]::MaxValue)
Register-ScheduledTask -TaskName 'LifePunch-ServerHost-Watchdog' -Action $watchAction -Trigger $watchTrigger `
    -RunLevel Highest -Force | Out-Null

# Startup task: HTTP status server (long-running)
$serverAction = New-ScheduledTaskAction -Execute 'powershell.exe' `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$server`" -Port $StatusPort"
$bootTrigger = New-ScheduledTaskTrigger -AtStartup
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)
Register-ScheduledTask -TaskName 'LifePunch-ServerHost-StatusServer' -Action $serverAction -Trigger $bootTrigger `
    -Settings $settings -RunLevel Highest -Force | Out-Null

# Run watchdog once now
& $watchdog -AllowedUsers $AllowedUsers

# Start status server if not running
Start-ScheduledTask -TaskName 'LifePunch-ServerHost-StatusServer' -ErrorAction SilentlyContinue

Write-Host ''
Write-Host 'Installed:' -ForegroundColor Green
Write-Host "  Task: LifePunch-ServerHost-Watchdog (every $WatchdogIntervalMinutes min)"
Write-Host '  Task: LifePunch-ServerHost-StatusServer (at startup)'
Write-Host "  Status: http://<server-ip>:$StatusPort/status  (Bearer token)"
Write-Host ''
Write-Host 'On VENGEANCE: save token to lifepunch/scripts/server-host-watch.local.json and run start-server-host-watch.ps1' -ForegroundColor Cyan
