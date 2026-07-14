# Shared helpers for the Windows PowerShell Codex workflow scripts.
#
# Windows-specific behavior:
# - Windows PowerShell 5.1 has no Bash-style `</dev/null`, so native Codex
#   processes are started through ProcessStartInfo and stdin is closed
#   immediately.
# - Existing drive-letter paths are normalized to Git Bash's `/c/...` shape
#   before sanitizing, so Bash and PowerShell reuse the same state key.
# - If only a .cmd/.bat Codex shim is available, PowerShell's native-command
#   fallback line-normalizes stdout/stderr while preserving JSONL records.
# - Status text names the .ps1 entrypoints instead of the Bash entrypoints;
#   state behavior and exit-code classes stay the same.

Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

$script:SkillDir = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrEmpty($env:STATE_DIR)) {
    $env:STATE_DIR = Join-Path $script:SkillDir "state"
}
$script:StateDir = $env:STATE_DIR
[void][System.IO.Directory]::CreateDirectory($script:StateDir)

$defaultModel = if ($script:StateDir -like "*codex-implement*") {
    "gpt-5.6-luna"
} else {
    "gpt-5.6-sol"
}

$script:CodexModel = if ([string]::IsNullOrEmpty($env:CODEX_MODEL)) {
    $defaultModel
} else {
    $env:CODEX_MODEL
}
$script:CodexEffort = if ([string]::IsNullOrEmpty($env:CODEX_EFFORT)) {
    "xhigh"
} else {
    $env:CODEX_EFFORT
}
$script:Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Write-Stderr {
    param([string]$Message)
    [Console]::Error.WriteLine($Message)
}

function Get-TargetKey {
    param([Parameter(Mandatory = $true)][string]$Target)

    if (Test-Path -LiteralPath $Target) {
        $resolved = (Resolve-Path -LiteralPath $Target).ProviderPath
        $normalized = $resolved.Replace("\", "/")
        if ($normalized -match "^([A-Za-z]):/(.*)$") {
            $normalized = $Matches[1].ToLowerInvariant() + "/" + $Matches[2]
        }
        $normalized = $normalized.TrimStart("/")
        return $normalized.Replace("/", "__")
    }

    $key = $Target -replace "^/", ""
    $key = $key -replace "/", "__"
    return $key -replace "[^A-Za-z0-9._-]", "_"
}

function Get-ThreadFile {
    param([string]$Target)
    return Join-Path $script:StateDir ((Get-TargetKey $Target) + ".thread")
}

function Get-ReportFile {
    param([string]$Target)
    return Join-Path $script:StateDir ((Get-TargetKey $Target) + ".review.txt")
}

function Get-EventsFile {
    param([string]$Target)
    return Join-Path $script:StateDir ((Get-TargetKey $Target) + ".events.ndjson")
}

function Get-PromptText {
    param(
        [string]$TemplatePath,
        [string]$Target,
        [string]$ExtraPrompt = "",
        [string]$ImplementerNotes = ""
    )

    if (-not (Test-Path -LiteralPath $TemplatePath -PathType Leaf)) {
        Write-Stderr "Prompt template not found: $TemplatePath"
        exit 1
    }

    $prompt = [System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $TemplatePath).ProviderPath)
    # Bash captures awk output with command substitution: normalize record
    # endings first, then remove trailing newlines after placeholder replacement.
    $prompt = $prompt.Replace("`r`n", "`n").Replace("`r", "`n")
    $prompt = $prompt.Replace("{{TARGET}}", $Target)
    $prompt = $prompt.Replace("{{EXTRA_PROMPT}}", $ExtraPrompt)
    $prompt = $prompt.Replace("{{IMPLEMENTER_NOTES}}", $ImplementerNotes)
    return $prompt.TrimEnd([char[]]"`n")
}

function ConvertTo-NativeArgument {
    param([AllowEmptyString()][string]$Argument)

    if ($Argument.Length -gt 0 -and $Argument -notmatch '[\s"]') {
        return $Argument
    }

    $escaped = [regex]::Replace($Argument, '(\\*)"', '$1$1\"')
    $escaped = [regex]::Replace($escaped, '(\\+)$', '$1$1')
    return '"' + $escaped + '"'
}

function Invoke-CodexProcess {
    param(
        [string[]]$Arguments,
        [string]$StdoutPath,
        [string]$StderrPath
    )

    $command = Get-Command codex -CommandType Application -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if ($null -eq $command) {
        $command = Get-Command codex.exe -CommandType Application -ErrorAction SilentlyContinue |
            Select-Object -First 1
    }
    if ($null -eq $command) {
        Write-Stderr "codex executable not found on PATH"
        return 127
    }

    $extension = [System.IO.Path]::GetExtension($command.Source).ToLowerInvariant()
    if ($extension -eq ".exe") {
        $startInfo = New-Object System.Diagnostics.ProcessStartInfo
        $startInfo.FileName = $command.Source
        $startInfo.Arguments = (($Arguments | ForEach-Object { ConvertTo-NativeArgument $_ }) -join " ")
        $startInfo.UseShellExecute = $false
        $startInfo.CreateNoWindow = $true
        $startInfo.RedirectStandardInput = $true
        $startInfo.RedirectStandardOutput = $true
        $startInfo.RedirectStandardError = $true
        $startInfo.StandardOutputEncoding = $script:Utf8NoBom
        $startInfo.StandardErrorEncoding = $script:Utf8NoBom

        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = $startInfo
        try {
            try {
                [void]$process.Start()
                $process.StandardInput.Close()
                $stdoutTask = $process.StandardOutput.ReadToEndAsync()
                $stderrTask = $process.StandardError.ReadToEndAsync()
                $process.WaitForExit()
                $stdout = $stdoutTask.Result
                $stderr = $stderrTask.Result
                $exitCode = $process.ExitCode
            } catch {
                $stdout = ""
                $stderr = $_.Exception.Message + [Environment]::NewLine
                $exitCode = 126
            }
        } finally {
            $process.Dispose()
        }

        [System.IO.File]::WriteAllText($StdoutPath, $stdout, $script:Utf8NoBom)
        [System.IO.File]::WriteAllText($StderrPath, $stderr, $script:Utf8NoBom)
        return $exitCode
    }

    $stderrTemp = [System.IO.Path]::GetTempFileName()
    try {
        $emptyInput = @()
        $stdoutLines = @($emptyInput | & $command.Source @Arguments 2> $stderrTemp)
        $exitCode = $LASTEXITCODE

        $stdout = ($stdoutLines | ForEach-Object { [string]$_ }) -join [Environment]::NewLine
        if ($stdoutLines.Count -gt 0) {
            $stdout += [Environment]::NewLine
        }
        $stderr = if ((Get-Item -LiteralPath $stderrTemp).Length -gt 0) {
            [System.IO.File]::ReadAllText($stderrTemp)
        } else {
            ""
        }

        [System.IO.File]::WriteAllText($StdoutPath, $stdout, $script:Utf8NoBom)
        [System.IO.File]::WriteAllText($StderrPath, $stderr, $script:Utf8NoBom)
        return $exitCode
    } finally {
        Remove-Item -LiteralPath $stderrTemp -Force -ErrorAction SilentlyContinue
    }
}

function Get-ThreadIdFromEvents {
    param([string]$EventsPath)

    foreach ($line in [System.IO.File]::ReadAllLines($EventsPath)) {
        try {
            $eventRecord = $line | ConvertFrom-Json
        } catch {
            continue
        }

        $propertyNames = $eventRecord.PSObject.Properties.Name
        if ($propertyNames -contains "type" -and
            $propertyNames -contains "thread_id" -and
            $eventRecord.type -eq "thread.started") {
            return [string]$eventRecord.thread_id
        }
    }
    return ""
}

function Write-TailToStderr {
    param(
        [string]$Path,
        [int]$LineCount = 20
    )

    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        Get-Content -LiteralPath $Path | Select-Object -Last $LineCount |
            ForEach-Object { Write-Stderr ([string]$_) }
    }
}

function Write-FileToStdout {
    param([string]$Path)
    [Console]::Out.Write([System.IO.File]::ReadAllText($Path))
}
