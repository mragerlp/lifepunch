# Start VENGEANCE -> lifepunchnet session hub sync (run beside voice watch).

. (Join-Path $PSScriptRoot 'Voice-Console.ps1')
$sync = Join-Path $PSScriptRoot 'sync-cornerman-sessions-to-lifepunchnet.ps1'
Write-Host 'Session sync ON (Cornerman -> lifepunchnet hub)' -ForegroundColor Green
Write-VoiceMuted 'Requires session hub on lifepunchnet (:9102) + server-host-watch.local.json token'
Write-Host ''
& $sync
