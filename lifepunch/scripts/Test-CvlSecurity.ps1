<#
.SYNOPSIS
  CVL communications security gate — run on VENGEANCE before hub ingest or high-value logging.

.DESCRIPTION
  Verifies bearer auth on :9101/:9102, local token hygiene, and Cornerman SSH path.
  Does not replace lifepunchnet firewall hardening (Secure-LifepunchnetCvlPorts.ps1 on-box).

.EXAMPLE
  powershell -File Test-CvlSecurity.ps1
#>
[CmdletBinding()]
param(
    [string] $ConfigPath = '',
    [string] $CornermanSsh = $(if ($env:CORNERMAN_SSH) { $env:CORNERMAN_SSH } else { 'cornerman' })
)

$ErrorActionPreference = 'Continue'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $ConfigPath) { $ConfigPath = Join-Path $Here 'server-host-watch.local.json' }
. (Join-Path $Here 'Voice-Console.ps1')
$script:VoiceConsoleAccent = 'Cyan'

$script:Ok = $true
$script:Warnings = [System.Collections.Generic.List[string]]::new()

function Report([string]$Label, [bool]$Pass, [string]$Detail = '', [switch]$WarnOnly) {
    if ($WarnOnly) {
        if (-not $Pass) { $script:Warnings.Add("$Label - $Detail") }
        $color = if ($Pass) { 'Green' } else { 'Yellow' }
        $mark = if ($Pass) { 'OK' } else { 'WARN' }
    }
    else {
        if (-not $Pass) { $script:Ok = $false }
        $color = if ($Pass) { 'Green' } else { 'Red' }
        $mark = if ($Pass) { 'OK' } else { 'FAIL' }
    }
    Write-Host ("  [{0}] {1}" -f $mark, $Label) -ForegroundColor $color
    if ($Detail) { Write-Host "        $Detail" -ForegroundColor DarkGray }
}

Write-VoiceHeader -Title 'CVL SECURITY GATE' -Subtitle 'signals hardened before high-value hub data'
Write-Host ''

# --- Local token hygiene ---
if (-not (Test-Path -LiteralPath $ConfigPath)) {
    Report 'server-host-watch.local.json' $false 'missing - copy .example + lifepunchnet token'
}
else {
    $cfg = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
    $token = [string]$cfg.token
    $tokenOk = ($token.Length -ge 32) -and ($token -notmatch 'PASTE|example|changeme')
    Report 'Hub/status token configured' $tokenOk $(if ($tokenOk) { 'local file only (gitignored)' } else { 'set real token from lifepunchnet status-token.txt' })

    Push-Location (Resolve-Path (Join-Path $Here '..\..')).Path
    $staged = git status --porcelain -- 'lifepunch/scripts/server-host-watch.local.json' 2>$null
    Pop-Location
    Report 'Token file not staged in git' ([string]::IsNullOrWhiteSpace($staged)) $(if ($staged) { 'NEVER commit token file' } else { 'clean' })
}

if (-not $cfg) {
    Write-Host ''
    Write-Host 'STOP: fix FAIL items before CVL hub ingest.' -ForegroundColor Red
    exit 1
}

$hostAddr = [string]$cfg.host
$port9101 = if ($cfg.statusPort) { [int]$cfg.statusPort } else { 9101 }
$port9102 = if ($cfg.sessionPort) { [int]$cfg.sessionPort } else { 9102 }
$goodHeaders = @{ Authorization = "Bearer $($cfg.token)" }

# --- API requires bearer ---
try {
    Invoke-RestMethod -Uri "http://${hostAddr}:${port9101}/status" -TimeoutSec 12 | Out-Null
    Report ':9101 rejects missing token' $false 'anonymous read succeeded - misconfigured'
}
catch {
    Report ':9101 rejects missing token' $true 'unauthorized without Bearer'
}

try {
    Invoke-RestMethod -Uri "http://${hostAddr}:${port9102}/status" -TimeoutSec 12 | Out-Null
    Report ':9102 rejects missing token' $false 'anonymous read succeeded - misconfigured'
}
catch {
    Report ':9102 rejects missing token' $true 'unauthorized without Bearer'
}

try {
    $s = Invoke-RestMethod -Uri "http://${hostAddr}:${port9101}/status" -Headers $goodHeaders -TimeoutSec 12
    Report ':9101 auth probe' $true "whisper=$($s.whisper.running)"
}
catch {
    Report ':9101 auth probe' $false $_.Exception.Message
}

try {
    $h = Invoke-RestMethod -Uri "http://${hostAddr}:${port9102}/status" -Headers $goodHeaders -TimeoutSec 12
    Report ':9102 auth probe' $true "hubLines=$($h.lines)"
}
catch {
    Report ':9102 auth probe' $false $_.Exception.Message
}

# --- Transport honesty ---
Report 'Transport is HTTP not TLS' $false 'Bearer token visible on wire if firewall scope wrong' -WarnOnly
Report 'Mitigation: lifepunchnet firewall' $true 'Secure-LifepunchnetCvlPorts.ps1 scopes :9000/:9101/:9102 to home public IP' -WarnOnly

# --- Cornerman path ---
$prev = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'
& ssh -o BatchMode=yes -o ConnectTimeout=8 $CornermanSsh 'powershell -NoProfile -NonInteractive -Command "Write-Output ok"' 2>$null
$sshOk = ($LASTEXITCODE -eq 0)
$ErrorActionPreference = $prev
Report 'Cornerman SSH (LAN)' $sshOk $CornermanSsh

$tokProbe = Invoke-CornermanSshRead -RemotePath 'C:\Projects\lifepunch\scripts\server-host-watch.local.json' -SshTarget $CornermanSsh
$cornermanHasToken = ($null -ne $tokProbe) -and ($tokProbe -match 'token')
Report 'Cornerman has no hub token file' (-not $cornermanHasToken) $(if ($cornermanHasToken) { 'REMOVE token from Cornerman' } else { 'clean' })

# --- Whisper reachable from desk (scoped egress) ---
$tcp9000 = Test-NetConnection -ComputerName $hostAddr -Port 9000 -WarningAction SilentlyContinue
Report 'Whisper :9000 from VENGEANCE' $tcp9000.TcpTestSucceeded $(if ($tcp9000.TcpTestSucceeded) { 'expected when home IP scoped on server' } else { 'check firewall or service' })

Write-Host ''
if ($script:Warnings.Count -gt 0) {
    Write-Host '  WARNINGS (acknowledge)' -ForegroundColor Yellow
    foreach ($w in $script:Warnings) { Write-Host "    - $w" -ForegroundColor Yellow }
    Write-Host ''
}

if ($script:Ok) {
    Write-Host '  SECURITY GATE: PASS - safe to run Invoke-CvlUniversal -IngestToHub' -ForegroundColor Green
    Write-Host '  lifepunchnet: Secure-LifepunchnetCvlPorts.ps1 if home IP changed or never run' -ForegroundColor DarkGray
}
else {
    Write-Host '  SECURITY GATE: FAIL - do not ingest high-value data until fixed' -ForegroundColor Red
}
Write-Host ''
exit $(if ($script:Ok) { 0 } else { 1 })
