<#
.SYNOPSIS
  Launch Claude Code from Rider with LifePunch monorepo MCP + skills root.

.DESCRIPTION
  Rider often opens terminals in lifepunchaddons/. Claude skills walk up to the
  git root, but project MCP was previously disabled under addons/. This wrapper
  always starts from the monorepo root so .mcp.json, CLAUDE.md, .claude/skills,
  and .agents/skills resolve correctly.
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]] $ClaudeArgs
)

$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Claude = Join-Path $env:USERPROFILE '.local\bin\claude.exe'
if (-not (Test-Path -LiteralPath $Claude)) {
    $cmd = Get-Command claude -ErrorAction SilentlyContinue
    if (-not $cmd) { throw 'claude.exe not found on PATH or ~/.local/bin' }
    $Claude = $cmd.Source
}

$env:SBOX_BRIDGE_IPC_DIR = Join-Path $env:TEMP 'sbox-bridge-ipc'
$env:SBOX_LOG_PATH = 'D:\Steam\steamapps\common\sbox\logs\sbox-dev.log'
$env:COLORTERM = 'truecolor'  # richer ANSI colors in Rider / Windows terminals

Set-Location -LiteralPath $RepoRoot
Write-Host "Claude Code cwd: $RepoRoot" -ForegroundColor DarkCyan
Write-Host "MCP: .mcp.json (sbox, sbox-editor, cornerman-lm, cavelux, excalidraw)" -ForegroundColor DarkGray
Write-Host "Skills: .claude/skills + .agents/skills" -ForegroundColor DarkGray

if ($ClaudeArgs -and $ClaudeArgs.Count -gt 0) {
    & $Claude @ClaudeArgs
} else {
    & $Claude
}
exit $LASTEXITCODE
