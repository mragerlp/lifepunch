# Minimal HTTP status server — VENGEANCE watcher polls GET /status with a shared token.
# Binds port 9101. Run at startup (Install-ServerHostWatchdog.ps1 registers this).

param(
    [int] $Port = 9101,
    [string] $StatusDir = 'C:\lifepunch\status',
    [string] $TokenFile = 'C:\lifepunch\status\status-token.txt'
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $TokenFile)) {
    throw "Missing token file: $TokenFile — run Install-ServerHostWatchdog.ps1 first."
}
$expectedToken = (Get-Content -LiteralPath $TokenFile -Raw).Trim()

$prefix = "http://+:$Port/"
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($prefix)

try {
    $listener.Start()
}
catch {
    throw @"
Could not bind $prefix — run Install-ServerHostWatchdog.ps1 (elevated) to register urlacl, or:
  netsh http add urlacl url=$prefix user=$env:USERNAME
"@
}

Write-Host "lifepunchnet status server listening on port $Port" -ForegroundColor Green

while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    $req = $ctx.Request
    $res = $ctx.Response
    $path = $req.Url.LocalPath.TrimEnd('/')

    $auth = $req.Headers['Authorization']
    $tokenOk = ($auth -eq "Bearer $expectedToken")

    $body = ''
    $code = 200
    $ctype = 'application/json; charset=utf-8'

    if (-not $tokenOk) {
        $code = 401
        $body = '{"error":"unauthorized"}'
    }
    elseif ($path -eq '/status' -or $path -eq '') {
        $watchdog = Join-Path $StatusDir 'watchdog.json'
        if (Test-Path -LiteralPath $watchdog) {
            $body = Get-Content -LiteralPath $watchdog -Raw
        }
        else {
            $code = 503
            $body = '{"error":"watchdog not ready"}'
        }
    }
    else {
        $code = 404
        $body = '{"error":"not found"}'
    }

    $res.StatusCode = $code
    $res.ContentType = $ctype
    $bytes = [Text.Encoding]::UTF8.GetBytes($body)
    $res.ContentLength64 = $bytes.Length
    $res.OutputStream.Write($bytes, 0, $bytes.Length)
    $res.OutputStream.Close()
}
