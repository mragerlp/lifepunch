# Resume a persistent Codex session on Windows.
# Usage: resume.ps1 --prompt-file <tpl> [--notes "..."] <target> [extra text...]
# Exit codes match resume.sh: 0 success, 1 failure, 2 missing thread, 64 usage.

Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "_common.ps1")

$promptFile = ""
$implementerNotes = ""
$remaining = New-Object System.Collections.Generic.List[string]
$index = 0
while ($index -lt $args.Count) {
    $argument = [string]$args[$index]
    if ($argument -eq "--") {
        $index++
        break
    } elseif ($argument -eq "--prompt-file" -or $argument -eq "--notes") {
        $option = $argument
        $index++
        if ($index -ge $args.Count) {
            Write-Stderr "usage: resume.ps1 --prompt-file <tpl> [--notes '...'] <target> [extra prompt text...]"
            exit 64
        }
        if ($option -eq "--prompt-file") {
            $promptFile = [string]$args[$index]
        } else {
            $implementerNotes = [string]$args[$index]
        }
        $index++
    } elseif ($argument.StartsWith("--prompt-file=")) {
        $promptFile = $argument.Substring("--prompt-file=".Length)
        $index++
    } elseif ($argument.StartsWith("--notes=")) {
        $implementerNotes = $argument.Substring("--notes=".Length)
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
    Write-Stderr "usage: resume.ps1 --prompt-file <tpl> [--notes '...'] <target> [extra prompt text...]"
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

if (-not (Test-Path -LiteralPath $threadFile -PathType Leaf)) {
    Write-Stderr "error: no review session for $target"
    Write-Stderr "       run start.ps1 first."
    exit 2
}

$threadId = [System.IO.File]::ReadAllText($threadFile).TrimEnd([char[]]"`r`n")
$prompt = Get-PromptText $promptFile $target $extraPrompt $implementerNotes
$codexArguments = @(
    "exec", "resume", $threadId, "--skip-git-repo-check", "--json", "-c",
    "model=$script:CodexModel", "-c", "model_reasoning_effort=$script:CodexEffort",
    "-o", $reportFile, $prompt
)
$codexExit = Invoke-CodexProcess $codexArguments $eventsFile $stderrFile

if ($codexExit -ne 0) {
    Write-Stderr "error: codex exec resume failed (rc=$codexExit)"
    Write-Stderr "stderr tail:"
    Write-TailToStderr $stderrFile 20
    exit 1
}

Write-Output "resumed review session for $target"
Write-Output "  thread id:   $threadId"
Write-Output "  model/effort: $script:CodexModel / $script:CodexEffort"
Write-Output "  review file: $reportFile"
Write-Output "---"
Write-FileToStdout $reportFile
