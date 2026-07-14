# Reset persisted Codex session state on Windows.
# Usage: reset.ps1 <target>
# Exit codes match reset.sh: 0 success, 64 usage.

Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "_common.ps1")

if ($args.Count -ne 1) {
    Write-Stderr "usage: reset.ps1 <plan-path>"
    exit 64
}

$target = [string]$args[0]
$paths = @(
    (Get-ThreadFile $target),
    (Get-ReportFile $target),
    (Get-EventsFile $target),
    ((Get-EventsFile $target) + ".stderr")
)
$removed = 0
foreach ($path in $paths) {
    if (Test-Path -LiteralPath $path) {
        Remove-Item -LiteralPath $path -Force
        Write-Output "removed $path"
        $removed++
    }
}

if ($removed -eq 0) {
    Write-Output "no review state on file for $target"
}
