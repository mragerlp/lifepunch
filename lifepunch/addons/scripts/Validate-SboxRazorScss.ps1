<#
.SYNOPSIS
  Scan LifePunch .razor.scss for properties known to break s&box stylesheet compile.

.EXAMPLE
  powershell -File lifepunch\addons\scripts\Validate-SboxRazorScss.ps1
  powershell -File lifepunch\addons\scripts\Validate-SboxRazorScss.ps1 -Path bitcoinmining
#>
[CmdletBinding()]
param(
    [string] $Path = ''
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$codeRoot = (Resolve-Path (Join-Path $Here '..\Code\Addons\lifepunch')).Path
$scanRoot = if ($Path) { Join-Path $codeRoot $Path } else { $codeRoot }

if (-not (Test-Path -LiteralPath $scanRoot)) {
    throw "Scan root not found: $scanRoot"
}

$patterns = @(
    @{ Name = 'box-sizing'; Regex = 'box-sizing\s*:' },
    @{ Name = 'display-block'; Regex = 'display\s*:\s*block\b' },
    @{ Name = 'display-none'; Regex = 'display\s*:\s*none\b' },
    @{ Name = 'max-height-none'; Regex = 'max-height\s*:\s*none\b' },
    @{ Name = 'linear-gradient'; Regex = 'linear-gradient\s*\(' },
    @{ Name = 'repeating-linear-gradient'; Regex = 'repeating-linear-gradient\s*\(' },
    @{ Name = 'word-break'; Regex = 'word-break\s*:' }
)

$files = Get-ChildItem -LiteralPath $scanRoot -Recurse -Filter '*.razor.scss' -File
$findings = @()

foreach ($file in $files) {
    $lineNum = 0
    foreach ($line in Get-Content -LiteralPath $file.FullName) {
        $lineNum++
        foreach ($p in $patterns) {
            if ($line -match $p.Regex) {
                $rel = $file.FullName.Substring($codeRoot.Length).TrimStart('\')
                $findings += [pscustomobject]@{
                    File = $rel
                    Line = $lineNum
                    Rule = $p.Name
                    Text = $line.Trim()
                }
            }
        }
    }
}

Write-Host "s&box Razor SCSS scan: $scanRoot" -ForegroundColor Cyan
Write-Host "Files: $($files.Count)" -ForegroundColor DarkGray

if ($findings.Count -eq 0) {
    Write-Host 'OK — no forbidden patterns' -ForegroundColor Green
    exit 0
}

$findings | Format-Table -AutoSize
Write-Host ('FAIL - ' + $findings.Count + ' finding(s). See addons/docs/SBOX_RAZOR_SCSS_RULES.md') -ForegroundColor Red
exit 1
