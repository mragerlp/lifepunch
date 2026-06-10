# Session hub HTTP server on lifepunchnet - ingests voice/chat lines for Odysseus + agents.
# POST /ingest (Bearer token)  GET /tail  GET /status

param(
    [int] $Port = 9102,
    [string] $HubDir = 'C:\lifepunch\session-hub',
    [string] $TokenFile = 'C:\lifepunch\status\status-token.txt',
    [string] $LogName = 'voice-session.ndjson'
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $TokenFile)) {
    throw "Missing token file: $TokenFile - run Install-ServerHostWatchdog.ps1 first."
}
$expectedToken = (Get-Content -LiteralPath $TokenFile -Raw).Trim()
New-Item -ItemType Directory -Force -Path $HubDir | Out-Null
$logPath = Join-Path $HubDir $LogName

$prefix = "http://+:$Port/"
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($prefix)

try { $listener.Start() }
catch {
    throw "Could not bind $prefix - run Install-LifepunchnetSessionHub.ps1 (elevated)."
}

Write-Host "lifepunchnet session hub listening on port $Port" -ForegroundColor Green
Write-Host "  Hub: $logPath" -ForegroundColor DarkGray

function Test-Token($req) {
    $auth = $req.Headers['Authorization']
    return ($auth -eq "Bearer $expectedToken")
}

function Write-Json($res, [int]$code, $obj) {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes(($obj | ConvertTo-Json -Compress))
    $res.StatusCode = $code
    $res.ContentType = 'application/json; charset=utf-8'
    $res.ContentLength64 = $bytes.Length
    $res.OutputStream.Write($bytes, 0, $bytes.Length)
    $res.OutputStream.Close()
}

function Read-Body($req) {
    $reader = New-Object System.IO.StreamReader($req.InputStream, $req.ContentEncoding)
    try { return $reader.ReadToEnd() }
    finally { $reader.Close() }
}

while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    $req = $ctx.Request
    $res = $ctx.Response
    $path = $req.Url.LocalPath.TrimEnd('/').ToLowerInvariant()

    if (-not (Test-Token $req)) {
        Write-Json $res 401 @{ error = 'unauthorized' }
        continue
    }

    if ($path -eq '/status' -and $req.HttpMethod -eq 'GET') {
        $lines = 0
        if (Test-Path -LiteralPath $logPath) {
            $lines = @(Get-Content -LiteralPath $logPath -ErrorAction SilentlyContinue).Count
        }
        Write-Json $res 200 @{ ok = $true; hub = $HubDir; lines = $lines }
        continue
    }

    if ($path -eq '/tail' -and $req.HttpMethod -eq 'GET') {
        $n = 50
        [void][int]::TryParse($req.QueryString['lines'], [ref]$n)
        if ($n -lt 1) { $n = 50 }
        if ($n -gt 500) { $n = 500 }
        $tail = @()
        if (Test-Path -LiteralPath $logPath) {
            $all = @(Get-Content -LiteralPath $logPath -ErrorAction SilentlyContinue)
            if ($all.Count -gt $n) { $tail = $all[($all.Count - $n)..($all.Count - 1)] }
            else { $tail = $all }
        }
        Write-Json $res 200 @{ lines = $tail }
        continue
    }

    if ($path -eq '/ingest' -and $req.HttpMethod -eq 'POST') {
        try {
            $raw = Read-Body $req
            $payload = $raw | ConvertFrom-Json
            $entry = [ordered]@{
                ts     = if ($payload.ts) { [string]$payload.ts } else { (Get-Date).ToUniversalTime().ToString('o') }
                source = [string]$payload.source
                type   = [string]$payload.type
                text   = [string]$payload.text
            }
            $line = ($entry | ConvertTo-Json -Compress)
            Add-Content -LiteralPath $logPath -Value $line -Encoding UTF8
            Write-Json $res 200 @{ ok = $true }
        }
        catch {
            Write-Json $res 400 @{ error = $_.Exception.Message }
        }
        continue
    }

    Write-Json $res 404 @{ error = 'not found' }
}
