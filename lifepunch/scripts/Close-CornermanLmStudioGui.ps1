<#
.SYNOPSIS
  Close LM Studio GUI on Green - Tier-3 headless lms serve on :1234 stays up.

.DESCRIPTION
  Uses CloseMainWindow in the interactive user session only. Never Stop-Process (lms serve must stay).
  From VENGEANCE (SSH), runs a one-shot Interactive scheduled task on Green so the
  desktop window actually closes (SSH batch session cannot reach GUI handles).

.EXAMPLE
  powershell -File lifepunch\scripts\Close-CornermanLmStudioGui.ps1
  powershell -File lifepunch\scripts\Close-CornermanLmStudioGui.ps1 -SshTarget cornerman
#>
[CmdletBinding()]
param(
    [string] $SshTarget = '',
    [switch] $Quiet
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }

$closeBlock = @'
$closed = 0
Get-Process -ErrorAction SilentlyContinue | Where-Object {
    $_.ProcessName -match 'LM Studio'
} | ForEach-Object {
    if ($_.MainWindowHandle -ne 0) {
        if ($_.CloseMainWindow()) { $closed++ }
        Start-Sleep -Milliseconds 300
    }
}
$tier3Ok = $false
try {
    $r = Invoke-WebRequest -Uri 'http://127.0.0.1:1234/v1/models' -TimeoutSec 4 -UseBasicParsing
    $tier3Ok = ($r.StatusCode -eq 200)
}
catch { }
$guiLeft = @(Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -match 'LM Studio' }).Count
$outPath = 'C:\lifepunch\cornerman\close-lm-gui-result.json'
[ordered]@{
    closedGuiWindows  = $closed
    tier3ApiOk        = $tier3Ok
    lmGuiProcessCount = $guiLeft
} | ConvertTo-Json -Compress | Set-Content -LiteralPath $outPath -Encoding UTF8
'@

function Write-CloseResult($result) {
    if ($Quiet) { return }
    $guiNote = if ($result.lmGuiProcessCount -gt 0) {
        "GUI process(es) still present ($($result.lmGuiProcessCount)) - tray/headless OK if Tier-3 up"
    }
    else { 'no LM Studio GUI process' }
    $tierNote = if ($result.tier3ApiOk) { 'Tier-3 :1234 OK' } else { 'WARN Tier-3 :1234 not responding' }
    $color = if ($result.tier3ApiOk) { 'Green' } else { 'Yellow' }
    Write-Host "  closed=$($result.closedGuiWindows) $guiNote; $tierNote" -ForegroundColor $color
}

function Invoke-CloseLmGuiLocal {
    $null = New-Item -ItemType Directory -Force -Path 'C:\lifepunch\cornerman' -ErrorAction SilentlyContinue
    $runner = Join-Path 'C:\lifepunch\cornerman' 'Run-CloseLmStudioGui.ps1'
    Set-Content -LiteralPath $runner -Value $closeBlock -Encoding UTF8
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $runner
    $resultPath = 'C:\lifepunch\cornerman\close-lm-gui-result.json'
    if (-not (Test-Path -LiteralPath $resultPath)) { throw 'close-lm-gui-result.json missing' }
    return (Get-Content -LiteralPath $resultPath -Raw | ConvertFrom-Json)
}

function Invoke-CloseLmGuiInteractiveRemote([string]$Target) {
    . (Join-Path $Here 'Cornerman-Workflow.ps1')
    $onBoxRunner = 'C:\lifepunch\cornerman\Run-CloseLmStudioGui.ps1'
    Push-CornermanText -Path $onBoxRunner -Text $closeBlock -SshTarget $Target | Out-Null

    $schedule = @"
`$tn = 'LifePunch CloseLmGui'
`$script = '$onBoxRunner'
Unregister-ScheduledTask -TaskName `$tn -Confirm:`$false -ErrorAction SilentlyContinue
`$a = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -File `"`$script`""
`$p = New-ScheduledTaskPrincipal -UserId `$env:USERNAME -LogonType Interactive -RunLevel Highest
Register-ScheduledTask -TaskName `$tn -Action `$a -Principal `$p -Force | Out-Null
Start-ScheduledTask -TaskName `$tn
Start-Sleep -Seconds 4
`$resultPath = 'C:\lifepunch\cornerman\close-lm-gui-result.json'
if (Test-Path -LiteralPath `$resultPath) {
  Get-Content -LiteralPath `$resultPath -Raw
} else {
  [ordered]@{ closedGuiWindows = 0; tier3ApiOk = `$false; lmGuiProcessCount = -1 } | ConvertTo-Json -Compress
}
"@

    $r = Invoke-CornermanSshExec -SshTarget $Target -ScriptBlock $schedule -ConnectTimeout 30
    if ($r.ExitCode -ne 0) { throw "Close LM GUI interactive task failed: $($r.Output)" }
    $jsonLine = ($r.Output -split "`n" | Where-Object { $_.Trim().StartsWith('{') } | Select-Object -Last 1)
    if (-not $jsonLine) { throw 'Close LM GUI: no JSON from Green interactive task' }
    return ($jsonLine | ConvertFrom-Json)
}

if ($env:COMPUTERNAME -eq 'CORNERMAN') {
    $result = Invoke-CloseLmGuiLocal
    Write-CloseResult $result
    exit $(if ($result.tier3ApiOk) { 0 } else { 1 })
}

. (Join-Path $Here 'Cornerman-Workflow.ps1')
if (-not $SshTarget) { $SshTarget = Get-CornermanSshTarget }
if (-not (Test-CornermanSshReady -SshTarget $SshTarget)) {
    throw "Cornerman SSH not ready ($SshTarget)"
}

$result = Invoke-CloseLmGuiInteractiveRemote -Target $SshTarget
Write-CloseResult $result
exit $(if ($result.tier3ApiOk) { 0 } else { 1 })
