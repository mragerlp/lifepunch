<#
.SYNOPSIS
  Remove leaked s&box MCP execute_csharp temp files from the DXRP editor folder.

.DESCRIPTION
  Failed execute_csharp snippets leave Editor/__Exec_*.cs behind and poison every
  subsequent dxura.rp.editor compile (CS1026, unreachable code, Sandbox.Log errors).
  Run after MCP exec sessions or from Start-SboxDxrpEditor.ps1 before launch.

.EXAMPLE
  powershell -File lifepunch\scripts\Sweep-SboxExecSnippets.ps1
#>
[CmdletBinding()]
param(
    [string] $DxrpGameRoot = 'D:\Steam\steamapps\common\sbox\dxrp\game'
)

$ErrorActionPreference = 'Stop'
$editorDir = Join-Path $DxrpGameRoot 'Editor'
if (-not (Test-Path -LiteralPath $editorDir)) {
    Write-Host "Sweep-SboxExecSnippets: no Editor folder at $editorDir" -ForegroundColor DarkGray
    exit 0
}

$files = @(Get-ChildItem -LiteralPath $editorDir -Filter '__Exec_*.cs' -File -ErrorAction SilentlyContinue)
if ($files.Count -eq 0) {
    Write-Host 'Sweep-SboxExecSnippets: no leaked __Exec_*.cs files.' -ForegroundColor DarkGray
    exit 0
}

foreach ($file in $files) {
    Remove-Item -LiteralPath $file.FullName -Force
    Write-Host "Removed $($file.Name)" -ForegroundColor Yellow
}

Write-Host "Sweep-SboxExecSnippets: removed $($files.Count) file(s). Recompile editor if it was open." -ForegroundColor Green
