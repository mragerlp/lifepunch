# Start a persistent Codex implementation session on Windows.
# Usage: start.ps1 --prompt-file <tpl> <target> [custom instructions...]
# Exit codes match start.sh: 0 success, 1 failure, 2 existing thread, 64 usage.

Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrEmpty($env:STATE_DIR)) {
    $env:STATE_DIR = Join-Path (Split-Path -Parent $PSScriptRoot) "state"
}
. (Join-Path $PSScriptRoot "../../codex-plan-review/scripts/_common.ps1")

$promptFile = ""
$remaining = New-Object System.Collections.Generic.List[string]
$index = 0
while ($index -lt $args.Count) {
    $argument = [string]$args[$index]
    if ($argument -eq "--") {
        $index++
        break
    } elseif ($argument -eq "--prompt-file") {
        $index++
        if ($index -ge $args.Count) {
            Write-Stderr "usage: start.ps1 --prompt-file <tpl> <target> [custom instructions...]"
            exit 64
        }
        $promptFile = [string]$args[$index]
        $index++
    } elseif ($argument.StartsWith("--prompt-file=")) {
        $promptFile = $argument.Substring("--prompt-file=".Length)
        $index++
    } elseif ($argument.StartsWith("-")) {
        Write-Stderr "error: unknown flag: $argument"
        exit 64
    } else {
        break
    }
}
for (; $index -lt $args.Count; $index++) {
    $remaining.Add([string]$args[$index])
}

if ([string]::IsNullOrEmpty($promptFile) -or $remaining.Count -lt 1) {
    Write-Stderr "usage: start.ps1 --prompt-file <tpl> <target> [custom instructions...]"
    exit 64
}

$target = $remaining[0]
$extraPrompt = if ($remaining.Count -gt 1) {
    ($remaining.GetRange(1, $remaining.Count - 1) -join " ")
} else {
    ""
}

$threadFile = Get-ThreadFile $target
$reportFile = Get-ReportFile $target
$eventsFile = Get-EventsFile $target
$stderrFile = $eventsFile + ".stderr"

if (Test-Path -LiteralPath $threadFile -PathType Leaf) {
    $existingThread = [System.IO.File]::ReadAllText($threadFile).TrimEnd([char[]]"`r`n")
    Write-Stderr "error: implementation session already exists for $target"
    Write-Stderr "       thread id: $existingThread"
    Write-Stderr "       run resume.ps1 to continue, or reset.ps1 to start fresh."
    exit 2
}

$prompt = Get-PromptText $promptFile $target $extraPrompt ""
$codexArguments = @(
    "exec", "--json", "--skip-git-repo-check", "--sandbox", "workspace-write",
    "--color", "never", "-c", "model=$script:CodexModel", "-c",
    "model_reasoning_effort=$script:CodexEffort", "-o", $reportFile, $prompt
)
$codexExit = Invoke-CodexProcess $codexArguments $eventsFile $stderrFile

if ($codexExit -ne 0) {
    Write-Stderr "error: codex exec failed (rc=$codexExit)"
    Write-Stderr "stderr tail:"
    Write-TailToStderr $stderrFile 20
    exit 1
}

$threadId = Get-ThreadIdFromEvents $eventsFile
if ([string]::IsNullOrEmpty($threadId)) {
    Write-Stderr "error: no thread.started event found in $eventsFile"
    Write-Stderr "first 20 events:"
    Get-Content -LiteralPath $eventsFile | Select-Object -First 20 |
        ForEach-Object { Write-Stderr ([string]$_) }
    exit 1
}

[System.IO.File]::WriteAllText($threadFile, $threadId + [Environment]::NewLine, $script:Utf8NoBom)

Write-Output "started implementation session for $target"
Write-Output "  thread id:   $threadId"
Write-Output "  model/effort: $script:CodexModel / $script:CodexEffort"
Write-Output "  report file: $reportFile"
Write-Output "---"
Write-FileToStdout $reportFile
