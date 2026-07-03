<#
.SYNOPSIS
  Windows toast on VENGEANCE when work should move to Cornerman (Green B).

.DESCRIPTION
  Red agents call this when CVL_OFFLOAD_SIGNAL.md triggers fire.
  Bloodwave sees: "CVL — OFFLOAD TO CORNERMAN" + reason line.

.EXAMPLE
  powershell -File Send-CvlOffloadSignal.ps1 -Reason "GREEN CODE: ModelDoc audit while owner playtests party"
  powershell -File Send-CvlOffloadSignal.ps1 -Reason "TEST" -Test
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string] $Reason,
    [switch] $Test
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
. (Join-Path $Here 'Send-LifePunchToast.ps1')

$msg = if ($Test) {
    "TEST — offload signal armed. Party playtest = Red only (no toast). See handoff/CVL_OFFLOAD_SIGNAL.md"
}
else {
    if ($Reason.Length -gt 200) { $Reason = $Reason.Substring(0, 197) + '...' }
    $Reason
}

$ok = Send-LifePunchToast -Title 'CVL — OFFLOAD TO CORNERMAN' -Message $msg -Tone 'warning'
if ($ok) {
    Write-Host "Offload signal sent: $msg" -ForegroundColor Yellow
}
else {
    Write-Host "OFFLOAD SIGNAL (toast unavailable): $msg" -ForegroundColor Yellow
}
