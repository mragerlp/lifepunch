<#
.SYNOPSIS
  Warm Tier-3 LM in Cornerman's interactive desktop session + ensure LAN firewall.

.EXAMPLE
  powershell -File lifepunch\scripts\Start-CornermanTier3Interactive.ps1
#>
[CmdletBinding()]
param(
    [string] $SshTarget = '',
    [int] $WaitSeconds = 55
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
. (Join-Path $Here 'Cornerman-Workflow.ps1')

if (-not $SshTarget) { $SshTarget = Get-CornermanSshTarget }
if (-not (Test-CornermanSshReady -SshTarget $SshTarget)) {
    throw "Cornerman SSH not ready ($SshTarget)"
}

$vengeanceIp = (Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Where-Object { $_.IPAddress -like '192.168.*' } |
    Select-Object -First 1 -ExpandProperty IPAddress)
if (-not $vengeanceIp) { $vengeanceIp = '192.168.1.236' }

foreach ($name in @('Ensure-CornermanLmLanFirewall.ps1', 'Start-CornermanLmStudio.ps1')) {
    $local = Join-Path $Here $name
    Push-CornermanFile -Path (Join-Path 'C:\lifepunch\cornerman' $name) `
        -FileBytes ([IO.File]::ReadAllBytes($local)) -SshTarget $SshTarget | Out-Null
}

$runner = @"
`$ErrorActionPreference = 'Stop'
`$out = 'C:\lifepunch\cornerman\tier3-interactive-probe.json'
Get-Process -ErrorAction SilentlyContinue | Where-Object { `$_.ProcessName -match '^LM Studio$' } | ForEach-Object {
  `$null = `$_.CloseMainWindow(); Start-Sleep -Milliseconds 400
}
Start-Sleep -Seconds 2
& powershell -NoProfile -ExecutionPolicy Bypass -File 'C:\lifepunch\cornerman\Ensure-CornermanLmLanFirewall.ps1'
& powershell -NoProfile -ExecutionPolicy Bypass -File 'C:\lifepunch\cornerman\Start-CornermanLmStudio.ps1' -WarmModel daily
Start-Sleep -Seconds 6
`$result = [ordered]@{
  ts = (Get-Date).ToUniversalTime().ToString('o')
  session = `$env:USERNAME
  local_ok = `$false
  lan_ok = `$false
  local_models = 0
  lan_models = 0
  listening = `$false
}
`$listen = netstat -an | Select-String ':1234\s+.*LISTENING'
if (`$listen) { `$result.listening = `$true }
foreach (`$pair in @(@{ k='local_ok'; h='127.0.0.1' }, @{ k='lan_ok'; h='192.168.1.229' })) {
  try {
    `$n = (Invoke-RestMethod "http://`$(`$pair.h):1234/v1/models" -TimeoutSec 10).data.Count
    `$result[`$pair.k] = `$true
    if (`$pair.k -eq 'local_ok') { `$result.local_models = `$n }
    else { `$result.lan_models = `$n }
  } catch { }
}
(`$result | ConvertTo-Json -Compress) | Set-Content -LiteralPath `$out -Encoding UTF8
if (-not `$result.local_ok) { exit 1 }
"@

Push-CornermanText -Path 'C:\lifepunch\cornerman\Run-Tier3Interactive.ps1' -Text $runner -SshTarget $SshTarget

$schedule = @'
$tn = 'LifePunch Tier3Interactive'
$script = 'C:\lifepunch\cornerman\Run-Tier3Interactive.ps1'
Unregister-ScheduledTask -TaskName $tn -Confirm:$false -ErrorAction SilentlyContinue
$a = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$script`""
$p = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest
Register-ScheduledTask -TaskName $tn -Action $a -Principal $p -Force | Out-Null
Start-ScheduledTask -TaskName $tn
Start-Sleep -Seconds 55
if (Test-Path -LiteralPath 'C:\lifepunch\cornerman\tier3-interactive-probe.json') {
  Get-Content -LiteralPath 'C:\lifepunch\cornerman\tier3-interactive-probe.json' -Raw
} else { Write-Output 'probe_missing'; exit 1 }
'@

Write-Host '== Interactive Tier-3 warm on Green ==' -ForegroundColor Cyan
$r = Invoke-CornermanSshExec -ScriptBlock $schedule -ConnectTimeout 120 -SshTarget $SshTarget
Write-Host $r.Output

if ($r.ExitCode -ne 0 -or [string]$r.Output -notmatch 'local_ok.:true') {
    throw 'Interactive Tier-3 warm failed — run Start-CornermanLmStudio.ps1 on Green desktop.'
}

Write-Host '== VENGEANCE LAN probe ==' -ForegroundColor Cyan
$t = Test-NetConnection -ComputerName 192.168.1.229 -Port 1234 -WarningAction SilentlyContinue
Write-Host "TcpTestSucceeded=$($t.TcpTestSucceeded)"
if ($t.TcpTestSucceeded) {
    $m = Invoke-RestMethod -Uri 'http://192.168.1.229:1234/v1/models' -TimeoutSec 10
    Write-Host "LAN OK: $($m.data.Count) models" -ForegroundColor Green
}
else {
    Write-Host 'LAN still blocked from VENGEANCE — check Green firewall or run Ensure-CornermanLmLanFirewall.ps1 elevated on Green.' -ForegroundColor Yellow
}

Write-Host 'Green: Cursor -> Reload Window' -ForegroundColor Cyan
