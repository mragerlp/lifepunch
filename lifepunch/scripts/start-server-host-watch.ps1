# Start the VENGEANCE-side lifepunchnet security/uptime watcher.

. (Join-Path $PSScriptRoot 'Voice-Console.ps1')
$watch = Join-Path $PSScriptRoot 'watch-server-host.ps1'
Write-Host 'lifepunchnet watch ON' -ForegroundColor White
Write-Host 'Requires server-host-watch.local.json (token from C:\lifepunch\status\status-token.txt)' -ForegroundColor White
Write-Host ''
& $watch
