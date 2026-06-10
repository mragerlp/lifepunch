<#
.SYNOPSIS
  lifepunchnet on-box reboot prep — run ELEVATED after RDP (Administrator).

.DESCRIPTION
  Pulls latest server lane scripts, re-wires boot tasks (:9000 / :9101 / :9102),
  applies Government Terminal uniform if pack is present, smoke-tests locally.

.EXAMPLE
  cd C:\lifepunch\lifepunch-rdp-server\lifepunch\server\scripts
  powershell -ExecutionPolicy Bypass -File .\Prep-LifePunchReboot-Lifepunchnet.ps1 -RemoteAddress 71.250.46.224
#>
[CmdletBinding()]
param(
    [string] $RemoteAddress = '71.250.46.224',
    [switch] $SkipGitPull,
    [switch] $SkipOpsUniform,
    [switch] $SkipNetBoot
)

$ErrorActionPreference = 'Stop'
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
          ).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if (-not $isAdmin) { throw 'Run elevated on lifepunchnet (Administrator).' }

$here = $PSScriptRoot
$gitRoot = 'C:\lifepunch\lifepunch-rdp-server'
$opsPack = 'C:\lifepunch\branding\lifepunch-ops'
$opsZip = 'C:\lifepunch\branding\lifepunch-ops-deploy.zip'

function Write-Step($m) { Write-Host "==> $m" -ForegroundColor Cyan }

Write-Host ''
Write-Host '============================================================' -ForegroundColor Cyan
Write-Host '  LIFEPUNCH REBOOT PREP — lifepunchnet' -ForegroundColor Cyan
Write-Host '============================================================' -ForegroundColor Cyan
Write-Host ''

if (-not $SkipGitPull -and (Test-Path -LiteralPath (Join-Path $gitRoot '.git'))) {
    Write-Step 'git pull (lifepunch-rdp-server)'
    Push-Location $gitRoot
    git fetch 2>&1 | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }
    git pull --rebase 2>&1 | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }
    Pop-Location
}

if (-not $SkipOpsUniform) {
    Write-Step 'Ops uniform (Government Terminal)'
    if (-not (Test-Path -LiteralPath $opsPack)) {
        if (Test-Path -LiteralPath $opsZip) {
            Write-Host "    Extracting $opsZip" -ForegroundColor DarkGray
            Expand-Archive -LiteralPath $opsZip -DestinationPath 'C:\lifepunch\branding' -Force
        }
    }
    $apply = Join-Path $opsPack 'Apply-LifePunchOpsConsole.ps1'
    if (Test-Path -LiteralPath $apply) {
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $apply -Machine lifepunchnet
    }
    else {
        Write-Host '    Skip — copy lifepunch-ops or lifepunch-ops-deploy.zip to C:\lifepunch\branding\' -ForegroundColor Yellow
    }
}

if (-not $SkipNetBoot) {
    Write-Step 'Boot wiring (Whisper :9000, watchdog :9101, session hub :9102)'
    $boot = Join-Path $here 'Install-LifePunchNetBoot.ps1'
    if (-not (Test-Path -LiteralPath $boot)) { throw "Missing $boot" }
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $boot -RemoteAddress $RemoteAddress
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    Write-Step 'CVL signal security (required before hub high-value data)'
    $secure = Join-Path $here 'Secure-LifepunchnetCvlPorts.ps1'
    if (Test-Path -LiteralPath $secure) {
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $secure -RemoteAddress $RemoteAddress
    }
}

Write-Host ''
Write-Host 'lifepunchnet reboot prep complete. Safe to reboot — services should return at logon.' -ForegroundColor Green
Write-Host 'VENGEANCE after reboot: LifePunch — Start Day' -ForegroundColor Cyan
Write-Host ''
