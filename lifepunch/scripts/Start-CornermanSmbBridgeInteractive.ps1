<#
.SYNOPSIS
  Map \\VENGEANCE\SboxBridgeIpc in Cornerman's interactive desktop session (required for sbox MCP).

.DESCRIPTION
  OpenSSH cannot persist net use for the session Cursor uses. This registers a one-shot
  Interactive scheduled task that runs Map-CornermanBridgeShare.ps1, then verifies UNC.

.EXAMPLE
  powershell -File lifepunch\scripts\Start-CornermanSmbBridgeInteractive.ps1
#>
[CmdletBinding()]
param(
    [string] $SshTarget = '',
    [int] $WaitSeconds = 12
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
. (Join-Path $Here 'Cornerman-Workflow.ps1')

if (-not $SshTarget) { $SshTarget = Get-CornermanSshTarget }
if (-not (Test-CornermanSshReady -SshTarget $SshTarget)) {
    throw "Cornerman SSH not ready ($SshTarget)"
}

$null = Repair-VengeanceSmbPasswordFile
if (-not (Get-VengeanceSmbPassword)) {
    throw 'Missing vengeance-smb.password — run Initialize-VengeanceSmbBridgeUser.ps1 on VENGEANCE'
}
$null = Sync-VengeanceSmbPasswordToCornerman -SshTarget $SshTarget

foreach ($name in @('Map-CornermanBridgeShare.ps1', 'Ensure-CornermanBridgeShare.ps1')) {
    $local = Join-Path $Here $name
    Push-CornermanFile -Path (Join-Path 'C:\lifepunch\cornerman' $name) `
        -FileBytes ([IO.File]::ReadAllBytes($local)) -SshTarget $SshTarget | Out-Null
}

$runnerOnGreen = @'
$ErrorActionPreference = 'Stop'
$unc = "\\VENGEANCE\SboxBridgeIpc"
$map = 'C:\lifepunch\cornerman\Map-CornermanBridgeShare.ps1'
$probeOut = 'C:\lifepunch\cornerman\bridge-share-interactive-probe.json'
$passFile = 'C:\lifepunch\cornerman\config\vengeance-smb.password'
$userFile = 'C:\lifepunch\cornerman\config\vengeance-smb.user'
if (-not (Test-Path -LiteralPath $map)) { throw "Missing $map" }
if (-not (Test-Path -LiteralPath $passFile)) { throw "Missing $passFile" }
$plain = (Get-Content -LiteralPath $passFile -Raw).Trim()
$user = if (Test-Path -LiteralPath $userFile) { (Get-Content -LiteralPath $userFile -Raw).Trim() } else { 'VENGEANCE\lpbridge' }
$sec = ConvertTo-SecureString $plain -AsPlainText -Force
$prevEap = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
& $map -Password $sec -User $user *>&1 | ForEach-Object { Write-Output $_ }
$ErrorActionPreference = $prevEap
$result = [ordered]@{
  ts = (Get-Date).ToUniversalTime().ToString('o')
  unc_share = Test-Path -LiteralPath $unc
  unc_status = Test-Path -LiteralPath (Join-Path $unc 'status.json')
  session = $env:USERNAME
  mcp_ipc = $null
}
$mcpPath = Join-Path $env:USERPROFILE '.cursor\mcp.json'
if (Test-Path -LiteralPath $mcpPath) {
  try {
    $result.mcp_ipc = (Get-Content -LiteralPath $mcpPath -Raw | ConvertFrom-Json).mcpServers.sbox.env.SBOX_BRIDGE_IPC_DIR
  } catch { }
}
($result | ConvertTo-Json -Compress) | Set-Content -LiteralPath $probeOut -Encoding UTF8
if (-not $result.unc_status) { exit 1 }
'@

Push-CornermanText -Path 'C:\lifepunch\cornerman\Run-SmbMapInteractive.ps1' -Text $runnerOnGreen -SshTarget $SshTarget

$schedule = @'
$tn = 'LifePunch SmbMapInteractive'
$script = 'C:\lifepunch\cornerman\Run-SmbMapInteractive.ps1'
Unregister-ScheduledTask -TaskName $tn -Confirm:$false -ErrorAction SilentlyContinue
$a = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$script`""
$p = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited
Register-ScheduledTask -TaskName $tn -Action $a -Principal $p -Force | Out-Null
Start-ScheduledTask -TaskName $tn
Start-Sleep -Seconds 12
if (Test-Path -LiteralPath 'C:\lifepunch\cornerman\bridge-share-interactive-probe.json') {
  Get-Content -LiteralPath 'C:\lifepunch\cornerman\bridge-share-interactive-probe.json' -Raw
} else {
  Write-Output 'probe_missing'
  exit 1
}
'@

Write-Host '== Interactive SMB map on Green ==' -ForegroundColor Cyan
$r = Invoke-CornermanSshExec -ScriptBlock $schedule -ConnectTimeout 90
Write-Host $r.Output

if ($r.ExitCode -ne 0 -or [string]$r.Output -notmatch 'unc_status.:true') {
    throw 'Interactive SMB map failed — run Map-CornermanBridgeShare.ps1 on Green desktop manually.'
}

Write-Host '== Refresh Green mcp.json -> UNC ==' -ForegroundColor Cyan
& (Join-Path $Here 'Install-CornermanSboxBridgeMcp.ps1') -SkipShare -SkipLmClone -SshTarget $SshTarget

& (Join-Path $Here 'Install-CornermanBridgeShareMapTask.ps1') -SshTarget $SshTarget -RunNow | Out-Null

Write-Host 'OK Green SMB mapped in interactive session' -ForegroundColor Green
Write-Host 'Green: Cursor -> Reload Window' -ForegroundColor Cyan
