<#
.SYNOPSIS
  Mirror .cursor/rules/*.mdc → .github/instructions/*.instructions.md for GitHub Copilot (VS Code).

.DESCRIPTION
  Cursor reads .cursor/rules automatically. Copilot does NOT — it uses:
    - .github/copilot-instructions.md (repo-wide)
    - .github/instructions/*.instructions.md (applyTo globs)

  This script copies every alwaysApply rule into Copilot instruction files with applyTo: "**"
  so ALL repo law is injected on every Copilot chat in this workspace.

  Source of truth remains .cursor/rules — edit there, then re-run this script.

.EXAMPLE
  powershell -File lifepunch\scripts\Sync-CursorRulesToCopilotInstructions.ps1
#>
[CmdletBinding()]
param(
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path

$RulesDir = Join-Path $RepoRoot '.cursor\rules'
$GithubDir = Join-Path $RepoRoot '.github'
$InstructionsDir = Join-Path $GithubDir 'instructions'
$CopilotRoot = Join-Path $GithubDir 'copilot-instructions.md'

if (-not (Test-Path -LiteralPath $RulesDir)) {
    throw "Missing rules folder: $RulesDir"
}

function Strip-MdcFrontmatter {
    param([string] $Text)
    $lines = $Text -split "`r?`n", -1
    if ($lines.Count -lt 2 -or $lines[0].Trim() -ne '---') {
        return $Text
    }
    $end = 1
    while ($end -lt $lines.Count -and $lines[$end].Trim() -ne '---') {
        $end++
    }
    if ($end -ge $lines.Count) {
        return $Text
    }
    $rest = $lines[($end + 1)..($lines.Count - 1)] -join "`n"
    return $rest.TrimStart("`r", "`n")
}

function Get-RuleDescription {
    param([string] $Path)
    $lines = [System.IO.File]::ReadAllLines($Path, [System.Text.Encoding]::UTF8)
    foreach ($line in $lines) {
        if ($line -match '^\s*description:\s*(.+)\s*$') {
            return $Matches[1].Trim().Trim('"')
        }
    }
    return 'LifePunch repo law (Cursor alwaysApply rule)'
}

if (-not $WhatIf) {
    New-Item -ItemType Directory -Force -Path $InstructionsDir | Out-Null
}

$ruleFiles = @(Get-ChildItem -LiteralPath $RulesDir -Filter '*.mdc' | Sort-Object Name)
$written = @()

foreach ($rule in $ruleFiles) {
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($rule.Name)
    $destName = "$baseName.instructions.md"
    $destPath = Join-Path $InstructionsDir $destName
    $description = Get-RuleDescription -Path $rule.FullName
    $body = Strip-MdcFrontmatter -Text ([System.IO.File]::ReadAllText($rule.FullName, [System.Text.Encoding]::UTF8))

    $content = @"
---
applyTo: "**"
description: "$($description -replace '"', '\"')"
sourceRule: ".cursor/rules/$($rule.Name)"
---

> **Synced from** ``.cursor/rules/$($rule.Name)`` — edit source there, then re-run ``Sync-CursorRulesToCopilotInstructions.ps1``.

$body
"@

    if ($WhatIf) {
        Write-Host "[WhatIf] $destName ($($rule.Length) bytes)" -ForegroundColor DarkGray
    }
    else {
        [System.IO.File]::WriteAllText($destPath, $content, (New-Object System.Text.UTF8Encoding $false))
        Write-Host "  $destName" -ForegroundColor Green
    }
    $written += $destName
}

# Manual Copilot instruction files (no .mdc source) — never delete on sync
$ManualInstructionFiles = @(
    'copilot-repo-ownership.instructions.md'
)

# Remove instruction files whose source rule was deleted
$existing = @(Get-ChildItem -LiteralPath $InstructionsDir -Filter '*.instructions.md' -ErrorAction SilentlyContinue)
foreach ($stale in $existing) {
    if ($stale.Name -in $ManualInstructionFiles) { continue }
    if ($stale.Name -notmatch '^(.+)\.instructions\.md$') { continue }
    $ruleStem = $Matches[1]
    $sourceRule = Join-Path $RulesDir "$ruleStem.mdc"
    if (-not (Test-Path -LiteralPath $sourceRule)) {
        if ($WhatIf) {
            Write-Host "[WhatIf] remove stale $($stale.Name)" -ForegroundColor Yellow
        }
        else {
            Remove-Item -LiteralPath $stale.FullName -Force
            Write-Host "  removed stale $($stale.Name)" -ForegroundColor Yellow
        }
    }
}

$generatedAt = (Get-Date).ToString('yyyy-MM-dd HH:mm UTC', [System.Globalization.CultureInfo]::InvariantCulture)
$index = @"
# LifePunch — GitHub Copilot repository instructions

**Machine:** VENGEANCE · **Workspace:** ``lifepunchaddons`` (github.com/mragerlp/lifepunch)

## Source of truth

| Layer | Path |
|-------|------|
| **Cursor law (edit here)** | ``.cursor/rules/*.mdc`` |
| **Copilot mirror (generated)** | ``.github/instructions/*.instructions.md`` |

Regenerate after any rule change:

``````powershell
powershell -File lifepunch\scripts\Sync-CursorRulesToCopilotInstructions.ps1
``````

Last sync: **$generatedAt** · **$($ruleFiles.Count)** rule files

## How Copilot loads this

VS Code applies **every** file in ``.github/instructions/`` with ``applyTo: "**"`` on **all** chat requests
in this workspace, **plus** this file (``copilot-instructions.md``).

Open workspace root ``lifepunchaddons`` in VS Code (not a subfolder only).

## Law hierarchy (conflicts — repo wins)

1. ``.cursor/rules`` / ``.github/instructions`` (this mirror)
2. ``lifepunch/addons/docs/ACTIVE_WORKSTREAM.md`` + ``BITCOIN_SHIP_ROADMAP.md``
3. ``lifepunch/docs`` canon · ``DECISIONS/``
4. Chat history (lowest)

## Active lane (June 2026)

**lifepunchbitcoin** / ``lpbitcoin`` only until Law 10 flatgrass + owner sign-off.
Blocked: Hacker, Banker, Government, Casino, …

## Git / commits

- Author: ``mragerlp <mragerlp@gmail.com>`` only
- **Never** AI ``Co-authored-by`` / Cursor trailers in commits
- Propose scope; wait for Bloodwave **yes** before commit

## Copilot ↔ Cursor handoff

- **Copilot (VS Code):** Full monorepo — in-editor work, workflow/stack simplification, Dimmer-style DXRP
- **Cursor:** MCP bridge, flatgrass proof, heavy plumbing when Copilot hands off
- One **writer** per file; ``git pull --rebase`` before picking up handoff
- **Manual law (not from .mdc):** ``instructions/copilot-repo-ownership.instructions.md``

## Mirrored rules ($($ruleFiles.Count))

$(($ruleFiles | ForEach-Object { "- ``$($_.Name)`` → ``instructions/$([System.IO.Path]::GetFileNameWithoutExtension($_.Name)).instructions.md``" }) -join "`n")

## Manual grep (still useful)

``````powershell
rg -n "your topic" .cursor\rules
Get-ChildItem .cursor\rules\*.mdc
``````
"@

if ($WhatIf) {
    Write-Host "[WhatIf] copilot-instructions.md" -ForegroundColor DarkGray
}
else {
    [System.IO.File]::WriteAllText($CopilotRoot, $index, (New-Object System.Text.UTF8Encoding $false))
}

Write-Host ''
Write-Host "Sync Cursor rules -> Copilot: $($ruleFiles.Count) files" -ForegroundColor Cyan
Write-Host "  Out: .github/instructions/*.instructions.md" -ForegroundColor DarkGray
Write-Host "  Out: .github/copilot-instructions.md" -ForegroundColor DarkGray
Write-Host '  VS Code: reload window if Copilot already open' -ForegroundColor Yellow
