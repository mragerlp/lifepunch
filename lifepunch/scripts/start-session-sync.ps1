# Start VENGEANCE -> lifepunchnet session hub sync (run beside voice watch).

$sync = Join-Path $PSScriptRoot 'sync-cornerman-sessions-to-lifepunchnet.ps1'
Write-Host 'Session sync ON (Cornerman -> lifepunchnet hub)' -ForegroundColor Green
Write-Host '  Requires session hub on lifepunchnet (:9102) + server-host-watch.local.json token' -ForegroundColor DarkGray
Write-Host ''
& $sync
