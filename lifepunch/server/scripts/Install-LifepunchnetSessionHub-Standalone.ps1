# Self-contained session hub installer for lifepunchnet (no tsclient, no git pull).
# Run ELEVATED on lifepunchnet. Copy this whole file via RDP clipboard from VENGEANCE.

param(
    [int] $Port = 9102,
    [string] $HubDir = 'C:\lifepunch\session-hub',
    [string] $SetupDir = 'C:\lifepunch\session-hub-setup',
    [string] $RemoteAddress = '71.250.46.224'
)

$ErrorActionPreference = 'Stop'

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
          ).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if (-not $isAdmin) { throw 'Run elevated on lifepunchnet.' }

$tokenFile = 'C:\lifepunch\status\status-token.txt'
if (-not (Test-Path -LiteralPath $tokenFile)) {
    throw "Missing $tokenFile - run Install-ServerHostWatchdog.ps1 first."
}

New-Item -ItemType Directory -Force -Path $SetupDir | Out-Null
New-Item -ItemType Directory -Force -Path $HubDir | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $HubDir 'imports') | Out-Null

$ingestPath = Join-Path $SetupDir 'ServerHost-SessionIngest.ps1'
@'
param(
    [int] $Port = 9102,
    [string] $HubDir = 'C:\lifepunch\session-hub',
    [string] $TokenFile = 'C:\lifepunch\status\status-token.txt',
    [string] $LogName = 'voice-session.ndjson'
)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $TokenFile)) { throw "Missing token: $TokenFile" }
$expectedToken = (Get-Content -LiteralPath $TokenFile -Raw).Trim()
New-Item -ItemType Directory -Force -Path $HubDir | Out-Null
$logPath = Join-Path $HubDir $LogName
$prefix = "http://+:$Port/"
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($prefix)
try { $listener.Start() } catch { throw "Could not bind $prefix (run install elevated)" }
Write-Host "lifepunchnet session hub listening on port $Port" -ForegroundColor Green
function Test-Token($req) { return ($req.Headers['Authorization'] -eq "Bearer $expectedToken") }
function Write-Json($res, [int]$code, $obj) {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes(($obj | ConvertTo-Json -Compress))
    $res.StatusCode = $code; $res.ContentType = 'application/json; charset=utf-8'
    $res.ContentLength64 = $bytes.Length; $res.OutputStream.Write($bytes, 0, $bytes.Length); $res.OutputStream.Close()
}
function Read-Body($req) {
    $reader = New-Object System.IO.StreamReader($req.InputStream, $req.ContentEncoding)
    try { return $reader.ReadToEnd() } finally { $reader.Close() }
}
while ($listener.IsListening) {
    $ctx = $listener.GetContext(); $req = $ctx.Request; $res = $ctx.Response
    $path = $req.Url.LocalPath.TrimEnd('/').ToLowerInvariant()
    if (-not (Test-Token $req)) { Write-Json $res 401 @{ error = 'unauthorized' }; continue }
    if ($path -eq '/status' -and $req.HttpMethod -eq 'GET') {
        $lines = 0
        if (Test-Path -LiteralPath $logPath) { $lines = @(Get-Content -LiteralPath $logPath -EA SilentlyContinue).Count }
        Write-Json $res 200 @{ ok = $true; hub = $HubDir; lines = $lines }; continue
    }
    if ($path -eq '/tail' -and $req.HttpMethod -eq 'GET') {
        $n = 50; [void][int]::TryParse($req.QueryString['lines'], [ref]$n)
        if ($n -lt 1) { $n = 50 }; if ($n -gt 500) { $n = 500 }
        $tail = @()
        if (Test-Path -LiteralPath $logPath) {
            $all = @(Get-Content -LiteralPath $logPath -EA SilentlyContinue)
            if ($all.Count -gt $n) { $tail = $all[($all.Count - $n)..($all.Count - 1)] } else { $tail = $all }
        }
        Write-Json $res 200 @{ lines = $tail }; continue
    }
    if ($path -eq '/ingest' -and $req.HttpMethod -eq 'POST') {
        try {
            $payload = (Read-Body $req) | ConvertFrom-Json
            $entry = [ordered]@{
                ts = if ($payload.ts) { [string]$payload.ts } else { (Get-Date).ToUniversalTime().ToString('o') }
                source = [string]$payload.source; type = [string]$payload.type; text = [string]$payload.text
            }
            Add-Content -LiteralPath $logPath -Value ($entry | ConvertTo-Json -Compress) -Encoding UTF8
            Write-Json $res 200 @{ ok = $true }
        } catch { Write-Json $res 400 @{ error = $_.Exception.Message } }
        continue
    }
    Write-Json $res 404 @{ error = 'not found' }
}
'@ | Set-Content -LiteralPath $ingestPath -Encoding UTF8

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
    DisplayName = $ruleName; Direction = 'Inbound'; Action = 'Allow'
    Protocol = 'TCP'; LocalPort = $Port; Profile = 'Public'
}
if ($RemoteAddress) { $fwArgs['RemoteAddress'] = $RemoteAddress.Trim() }
New-NetFirewallRule @fwArgs | Out-Null

$action = New-ScheduledTaskAction -Execute 'powershell.exe' `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$ingestPath`" -Port $Port"
$trigger = New-ScheduledTaskTrigger -AtStartup
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
    -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)
Register-ScheduledTask -TaskName 'LifePunch-SessionHub' -Action $action -Trigger $trigger `
    -Settings $settings -RunLevel Highest -Force | Out-Null
Start-ScheduledTask -TaskName 'LifePunch-SessionHub' -ErrorAction SilentlyContinue

Write-Host ''
Write-Host 'Session hub installed.' -ForegroundColor Green
Write-Host "  Hub     $HubDir"
Write-Host "  Ingest  http://<ip>:$Port/ingest"
Write-Host "  Firewall TCP $Port for $RemoteAddress"
