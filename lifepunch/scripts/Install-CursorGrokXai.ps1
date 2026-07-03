<#
.SYNOPSIS
  Manual Cursor + xAI Grok wiring (Cursor has no native xAI provider slot).

.DESCRIPTION
  Cursor routes custom Grok through **OpenAI-compatible** settings:
    - OpenAI API Key  = your xai-... key
    - Override OpenAI Base URL = https://api.x.ai/v1
    - Add custom model = grok-build-0.1 (or XAI_GROK_MODEL from env file)

  Reads key from lifepunch/secure/xai.local.env (gitignored).
  Validates /v1/chat/completions (what Cursor uses), not only /v1/responses.

.EXAMPLE
  powershell -File lifepunch\scripts\Install-CursorGrokXai.ps1
  powershell -File lifepunch\scripts\Install-CursorGrokXai.ps1 -CopyKeyToClipboard
#>
[CmdletBinding()]
param(
    [switch] $CopyKeyToClipboard,
    [switch] $SkipApiTest,
    [string] $EnvFile = ''
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$MonorepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path

if (-not $EnvFile) {
    $EnvFile = Join-Path $MonorepoRoot 'lifepunch\secure\xai.local.env'
}

function Import-XaiEnvFile {
    param([string] $Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Missing $Path - copy lifepunch/secure/templates/xai.local.env.example and set XAI_API_KEY"
    }
    Get-Content -LiteralPath $Path | ForEach-Object {
        if ($_ -match '^\s*#' -or $_ -notmatch '=') { return }
        $name, $value = $_ -split '=', 2
        Set-Item -Path "Env:$($name.Trim())" -Value $value.Trim()
    }
}

function Test-XaiChatCompletions {
    param(
        [string] $ApiKey,
        [string] $Base,
        [string] $Model
    )
    $body = @{
        model    = $Model
        messages = @(
            @{ role = 'system'; content = 'You are Grok.' }
            @{ role = 'user'; content = 'Reply with exactly: GROK_OK' }
        )
        max_tokens = 32
    } | ConvertTo-Json -Depth 6

    $headers = @{
        Authorization  = "Bearer $ApiKey"
        'Content-Type' = 'application/json'
    }

    Write-Host "POST $Base/chat/completions (model=$Model)" -ForegroundColor Cyan
    $response = Invoke-RestMethod -Uri "$Base/chat/completions" -Method Post -Headers $headers -Body $body
    $text = $response.choices[0].message.content
    Write-Host "API reply: $text" -ForegroundColor Green
    if ($text -notmatch 'GROK_OK') {
        Write-Warning 'Unexpected reply; key works but model output differed.'
    }
}

Import-XaiEnvFile -Path $EnvFile

if (-not $env:XAI_API_KEY) { throw 'XAI_API_KEY empty in env file' }
if ($env:XAI_API_KEY -notmatch '^xai-') { throw 'XAI_API_KEY must start with xai-' }

$base = if ($env:XAI_API_BASE) { $env:XAI_API_BASE.TrimEnd('/') } else { 'https://api.x.ai/v1' }
$model = if ($env:XAI_GROK_MODEL) { $env:XAI_GROK_MODEL } else { 'grok-build-0.1' }

if (-not $SkipApiTest) {
    Test-XaiChatCompletions -ApiKey $env:XAI_API_KEY -Base $base -Model $model
}

Write-Host ''
Write-Host '=== CURSOR MANUAL SETUP (no xAI slot — use OpenAI-compatible override) ===' -ForegroundColor Yellow
Write-Host ''
Write-Host '1. Cursor -> Settings -> Models'
Write-Host '2. OpenAI API Key -> paste your xai-... key (same as XAI_API_KEY in xai.local.env)'
Write-Host '   NOT the Anthropic key. NOT OpenAI sk- key.'
Write-Host '3. Enable "Override OpenAI Base URL" -> https://api.x.ai/v1'
Write-Host '   (no trailing path; do NOT use /chat/completions or /responses)'
Write-Host "4. Add custom model -> $model -> enable it in the model list"
Write-Host '5. Disable other custom OpenAI models that point at wrong endpoints'
Write-Host '6. Reload Window -> pick' $model 'in chat model picker'
Write-Host ''
Write-Host 'WHEN USING CLAUDE/OPUS AGAIN: turn OFF Override OpenAI Base URL first' -ForegroundColor Yellow
Write-Host '(Cursor bug: global override breaks Anthropic until disabled)'
Write-Host ''
Write-Host 'Doc: lifepunch/docs/CURSOR_GROK_XAI_SETUP.md'
Write-Host ''

if ($CopyKeyToClipboard) {
    Set-Clipboard -Value $env:XAI_API_KEY
    Write-Host 'Copied XAI_API_KEY to clipboard for Cursor OpenAI API Key field.' -ForegroundColor Green
}
