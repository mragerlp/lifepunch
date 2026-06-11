# Push Test-LifepunchnetWhisperPreflight.ps1 to Cornerman (Green cyan-leg gate).

param(
    [string] $CornermanHost = $(if ($env:CORNERMAN_SSH) { $env:CORNERMAN_SSH } else { 'cornerman' })
)

$ErrorActionPreference = 'Stop'
$scriptsRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$preflight = Join-Path $scriptsRoot 'Test-LifepunchnetWhisperPreflight.ps1'
if (-not (Test-Path -LiteralPath $preflight)) { throw "Missing $preflight" }

$remotePath = 'C:\Projects\lifepunch\lifepunch\scripts\Test-LifepunchnetWhisperPreflight.ps1'
Write-Host ''
Write-Host 'Deploy lifepunchnet Whisper preflight to Cornerman' -ForegroundColor Cyan
$b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($preflight))
$remote = @"
New-Item -ItemType Directory -Force -Path 'C:\Projects\lifepunch\lifepunch\scripts' | Out-Null
[IO.File]::WriteAllBytes('$remotePath', [Convert]::FromBase64String('$b64'))
Write-Host 'Preflight deployed'
"@
$enc = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($remote))
ssh -o BatchMode=yes $CornermanHost "powershell -NoProfile -EncodedCommand $enc"
if ($LASTEXITCODE -ne 0) { throw 'deploy preflight failed' }
Write-Host "  $remotePath" -ForegroundColor Green
Write-Host 'Done. Restart Talk to Vengeance on Cornerman.' -ForegroundColor Cyan
Write-Host ''
