# One-shot: push GREEN-WORKFLOW-DIRECTIVE.json to Cornerman inbox.
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
. (Join-Path $Here 'Cornerman-Workflow.ps1')
$src = Join-Path $Here 'cornerman-inbox-directive.json'
if (-not (Test-Path -LiteralPath $src)) { throw "Missing $src" }
$text = Get-Content -LiteralPath $src -Raw
Push-CornermanText -Path 'C:\lifepunch\cornerman\inbox\GREEN-WORKFLOW-DIRECTIVE.json' -Text $text
Write-Host 'OK C:\lifepunch\cornerman\inbox\GREEN-WORKFLOW-DIRECTIVE.json' -ForegroundColor Green
