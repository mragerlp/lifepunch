# Session hub HTTP server on lifepunchnet - ingests voice/chat lines for Odysseus + agents.
# POST /ingest (Bearer token)  GET /tail  GET /status

param(
    [int] $Port = 9102,
    [string] $HubDir = 'C:\lifepunch\session-hub',
    [string] $TokenFile = 'C:\lifepunch\status\status-token.txt',
    [string] $LogName = 'voice-session.ndjson'
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'ServerHost-CvlSignalGuard.ps1')

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

$statusDir = Split-Path -Parent $TokenFile
$allowlist = Get-CvlAllowlistIps -StatusDir $statusDir

Write-Host "lifepunchnet session hub listening on port $Port" -ForegroundColor Green
Write-Host "  Hub: $logPath" -ForegroundColor DarkGray
if ($allowlist) {
    Write-Host "  Client IP allowlist: $($allowlist -join ', ')" -ForegroundColor DarkGray
}
else {
    Write-Host '  Client IP allowlist: OFF (run Secure-LifepunchnetCvlPorts.ps1)' -ForegroundColor Yellow
}

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

    if ($allowlist -and -not (Test-CvlClientIp -Request $req -Allowlist $allowlist)) {
        Write-Json $res 403 @{ error = 'client ip not allowlisted' }
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
            if ($raw.Length -gt 512000) {
                Write-Json $res 413 @{ error = 'body too large' }
                continue
            }
            $payload = $raw | ConvertFrom-Json
            $entry = [ordered]@{}
            foreach ($prop in $payload.PSObject.Properties) {
                if ($null -ne $prop.Value) {
                    $entry[$prop.Name] = $prop.Value
                }
            }
            if (-not $entry.ts) {
                $entry.ts = (Get-Date).ToUniversalTime().ToString('o')
            }
            if (-not $entry.Contains('source')) { $entry.source = 'unknown' }
            if (-not $entry.Contains('type')) { $entry.type = 'event' }
            if (-not $entry.Contains('text') -and $entry.Contains('user_text')) {
                $entry.text = [string]$entry.user_text
            }
            $guard = Test-CvlIngestEntry -Entry $entry
            if (-not $guard.ok) {
                Write-Json $res 400 @{ error = $guard.error }
                continue
            }
            $line = ($entry | ConvertTo-Json -Compress -Depth 8)
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
