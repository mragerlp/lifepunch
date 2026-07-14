# Print the latest Codex report on Windows without making a Codex call.
# Usage: show.ps1 <target>
# Exit codes match show.sh: 0 success, 1 missing report, 64 usage.

Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "_common.ps1")

if ($args.Count -ne 1) {
    Write-Stderr "usage: show.ps1 <plan-path>"
    exit 64
}

$target = [string]$args[0]
$threadFile = Get-ThreadFile $target
$reportFile = Get-ReportFile $target

if (-not (Test-Path -LiteralPath $reportFile -PathType Leaf)) {
    Write-Stderr "error: no review on file for $target"
    exit 1
}

if (Test-Path -LiteralPath $threadFile -PathType Leaf) {
    $threadId = [System.IO.File]::ReadAllText($threadFile).TrimEnd([char[]]"`r`n")
    Write-Output "thread id: $threadId"
}
Write-Output "review file: $reportFile"
Write-Output "---"
Write-FileToStdout $reportFile
