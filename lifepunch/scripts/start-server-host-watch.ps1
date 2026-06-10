# Start the VENGEANCE-side lifepunchnet security/uptime watcher.

$watch = Join-Path $PSScriptRoot 'watch-server-host.ps1'
Write-Host 'lifepunchnet watch ON' -ForegroundColor Green
Write-Host '  Requires server-host-watch.local.json (token from C:\lifepunch\status\status-token.txt)' -ForegroundColor DarkGray
Write-Host ''
& $watch
