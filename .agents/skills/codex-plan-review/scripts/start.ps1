# Turn 1: start a fresh persistent Codex session on Windows.
# Port of start.sh. Captures thread_id from the JSONL event stream and writes
# the final review to the per-target review file.
# Usage: start.ps1 --prompt-file <tpl> <target> [extra prompt text...]
# Exit codes match start.sh: 0 success, 1 failure, 2 existing thread, 64 usage.

Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "_common.ps1")

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
            Write-Stderr "usage: start.ps1 --prompt-file <tpl> <target> [extra prompt text...]"
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
    Write-Stderr "usage: start.ps1 --prompt-file <tpl> <target> [extra prompt text...]"
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
    $existing = [System.IO.File]::ReadAllText($threadFile).TrimEnd([char[]]"`r`n")
    Write-Stderr "error: review session already exists for $target"
    Write-Stderr "       thread id: $existing"
    Write-Stderr "       run resume.ps1 to continue, or reset.ps1 to start fresh."
    exit 2
}

$prompt = Get-PromptText $promptFile $target $extraPrompt ""
# read-only sandbox: Codex only inspects files, never modifies them.
$codexArguments = @(
    "exec", "--json", "--skip-git-repo-check", "--sandbox", "read-only",
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
if ([string]::IsNullOrEmpty($threadId) -or $threadId -eq "null") {
    Write-Stderr "error: no thread.started event found in $eventsFile"
    Write-Stderr "first 20 events:"
    if (Test-Path -LiteralPath $eventsFile -PathType Leaf) {
        Get-Content -LiteralPath $eventsFile -TotalCount 20 |
            ForEach-Object { Write-Stderr ([string]$_) }
    }
    exit 1
}

[System.IO.File]::WriteAllText($threadFile, $threadId + [Environment]::NewLine, $script:Utf8NoBom)
Write-Output "started review session for $target"
Write-Output "  thread id:    $threadId"
Write-Output "  model/effort: $script:CodexModel / $script:CodexEffort"
Write-Output "  review file:  $reportFile"
Write-Output "---"
Write-FileToStdout $reportFile
