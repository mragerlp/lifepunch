<#
.SYNOPSIS
  Boot gate: turn the Claude Bridge's vacuous `versionsAligned` pass into an explicit FAIL.

.DESCRIPTION
  DEFECT (red\0032, fired falsely TWICE on 2026-07-14):
    the bridge reports  versionsAligned = (bridgeVersion == mcpServerVersion)
    and when the editor is DEAD, BOTH are null. null == null is TRUE.
    So the boolean reads GREEN over a corpse.

  WE DO NOT OWN THE BRIDGE. `versionsAligned` is computed inside a third-party
  plugin (LouSputthole/Sbox-Claude); it has ZERO hits anywhere in this repo, so
  it cannot be patched from here. What we DO own is the only place the lie can
  hurt us: THE SEAT THAT READS IT. This gate is that place.

  THE RULE:  ABSENCE OF A VERSION IS A FAILURE, NOT A PASS.
  A version that is null, empty, or whitespace FAILS. It is never "aligned",
  never "unknown but probably fine", and never silently skipped.

  This is the GREEN-BY-OMISSION family, stated as a gate:
    a check that cannot distinguish "I verified it and it is fine"
    from "I could not verify it" IS NOT A CHECK.

.PARAMETER StatusJson
  Raw JSON from the bridge's get_bridge_status. If omitted, reads stdin.

.OUTPUTS
  Exit 0 = PASS (both versions present AND equal AND connected AND round-trip ok)
  Exit 1 = FAIL (any version absent, versions differ, or the bridge is not live)

.EXAMPLE
  # In a boot check, pipe the bridge status in:
  Get-Content bridge-status.json | powershell -File lifepunch\scripts\Assert-BridgeVersion.ps1
#>
[CmdletBinding()]
param(
    [string] $StatusJson
)

$ErrorActionPreference = 'Stop'

if (-not $StatusJson) { $StatusJson = [Console]::In.ReadToEnd() }

if ([string]::IsNullOrWhiteSpace($StatusJson)) {
    Write-Output 'BRIDGE-FAULT: no status payload. ABSENCE IS NOT A PASS.'
    exit 1
}

try { $s = $StatusJson | ConvertFrom-Json }
catch {
    Write-Output "BRIDGE-FAULT: status payload is not JSON. ABSENCE IS NOT A PASS. ($($_.Exception.Message))"
    exit 1
}

$fail = @()

# --- The load-bearing assertions. Each one is a POSITIVE presence check. ---
# A null here is the exact condition that made versionsAligned lie, so it is
# tested FIRST and it is tested for PRESENCE, never for equality.
$bridgeVersion = $s.bridgeVersion
$serverVersion = $s.mcpServerVersion

if ([string]::IsNullOrWhiteSpace($bridgeVersion)) {
    $fail += 'bridgeVersion is ABSENT (null/empty). This is the red\0032 false-pass condition.'
}
if ([string]::IsNullOrWhiteSpace($serverVersion)) {
    $fail += 'mcpServerVersion is ABSENT (null/empty). This is the red\0032 false-pass condition.'
}

# Only compare versions once BOTH are known to exist. Comparing two absences is
# how the original defect passed, and re-doing it here would rebuild the bug.
if ($fail.Count -eq 0 -and ($bridgeVersion -ne $serverVersion)) {
    $fail += "VERSION SKEW: bridge='$bridgeVersion' server='$serverVersion'."
}

# Liveness is a separate fact from version presence, and it is reported separately.
if ($s.connected -ne $true)   { $fail += 'connected is not true - the bridge is not live.' }
if ($s.roundTripOk -ne $true) { $fail += 'roundTripOk is not true - no proven round trip.' }

# versionsAligned is deliberately NOT trusted, and we say so out loud when it lies.
if ($s.versionsAligned -eq $true -and $fail.Count -gt 0) {
    Write-Output 'WARNING: the bridge reported versionsAligned=TRUE while this gate FAILED.'
    Write-Output '         That is the red\0032 defect firing. THE BOOLEAN IS NOT THE SENSOR.'
}

if ($fail.Count -gt 0) {
    Write-Output 'BRIDGE-FAULT:'
    $fail | ForEach-Object { Write-Output "  - $_" }
    Write-Output 'ABSENCE OF A VERSION IS A FAILURE, NOT A PASS.'
    exit 1
}

Write-Output "BRIDGE-OK: bridgeVersion='$bridgeVersion' mcpServerVersion='$serverVersion' connected=true roundTripOk=true"
Write-Output 'Earned by POSITIVE presence assertions, not by versionsAligned.'
exit 0
