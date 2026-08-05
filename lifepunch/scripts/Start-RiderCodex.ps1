<#
.SYNOPSIS
  Launch Codex CLI from Rider with LifePunch monorepo root (-C) and MCP env.
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]] $CodexArgs
)

$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Codex = Join-Path $env:LOCALAPPDATA 'Programs\OpenAI\Codex\bin\codex.exe'
if (-not (Test-Path -LiteralPath $Codex)) {
    $cmd = Get-Command codex -ErrorAction SilentlyContinue
    if (-not $cmd) { throw 'codex.exe not found' }
    $Codex = $cmd.Source
}

$env:SBOX_BRIDGE_IPC_DIR = Join-Path $env:TEMP 'sbox-bridge-ipc'
$env:SBOX_LOG_PATH = 'D:\Steam\steamapps\common\sbox\logs\sbox-dev.log'
$env:CODEX_HOME = Join-Path $env:USERPROFILE '.codex'

Set-Location -LiteralPath $RepoRoot
Write-Host "Codex cwd: $RepoRoot (-C)" -ForegroundColor DarkCyan
Write-Host "MCP: ~/.codex/config.toml (sbox, sbox-editor, cornerman-lm, cavelux, …)" -ForegroundColor DarkGray
Write-Host "Skills/AGENTS: repo AGENTS.md + .agents/skills" -ForegroundColor DarkGray

$launch = @('-C', $RepoRoot) + @($CodexArgs)
& $Codex @launch
exit $LASTEXITCODE
