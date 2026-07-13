<#
.SYNOPSIS
    Consult the CORNERMAN local models from an implementer seat, mid-task.

.DESCRIPTION
    Posts a prompt (optionally with inlined file contents) to LM Studio's
    OpenAI-compatible API on CORNERMAN and prints the reply.

    Canon: lifepunch/docs/cvl/CORNERMAN_CONSULT_DOCTRINE.md

    THE LAWS THAT BIND THIS SCRIPT — read them, they are not decoration:

      C-A  LEADS-GRADE ONLY. The reply is ADVICE, never a sensor. It does not
           prove anything. It is the same class as a Green packet.

      C-B  CITE-VERIFICATION LAW. Local models fabricate file:line cites.
           EVERY cite this script returns is machine-verified against the live
           tree before it is used, quoted, or acted on. An unverified local
           cite in a seat report is a defect.

      C-D  SECRETS STAY OUT. NO credentials, tokens, API keys, .env contents,
           or portal player data in any prompt or any -Files argument.
           KEY_LEDGER C-1/C-2 extend to prompts: a prompt is a transmission.
           This script does not read .env and never should.

      C-E  ATTRIBUTION. Work influenced by a consult is still the seat's work.
           Consults are process, not authorship. No model trailers, ever.

    RESIDENCY SENSOR (ruled 2026-07-13, Bloodwave):
    GET /api/v0/models 'state' field is the truth of what can answer.
    /v1/models lists AVAILABILITY only and will happily name a model that is
    not in VRAM — a chat POST against it then hangs until timeout. This script
    preflights residency and hard-fails with the model's actual state string.

.PARAMETER Prompt
    The question. Required.

.PARAMETER Files
    Optional paths whose contents are inlined into the prompt, each fenced and
    labelled with its path so the model can cite it.

.PARAMETER Model
    Model id. Defaults to the coder model per doctrine section 2.

.EXAMPLE
    .\ask-cornerman.ps1 -Prompt "Review this for TOCTOU" -Files .\Wallet.cs

.EXAMPLE
    .\ask-cornerman.ps1 -Prompt "Explain what this subsystem does" -Files A.cs,B.cs
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $Prompt,

    [string[]] $Files,

    [string] $Model = 'qwen2.5-coder-32b-instruct',

    [string] $BaseUrl = 'http://10.10.10.2:1234',

    [int] $MaxTokens = 2048,

    [double] $Temperature = 0.2,

    [int] $TimeoutSec = 600
)

$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# PREFLIGHT — residency, not availability. See RESIDENCY SENSOR above.
# ---------------------------------------------------------------------------
Write-Host "[preflight] GET $BaseUrl/api/v0/models" -ForegroundColor DarkGray

try {
    $catalog = Invoke-RestMethod -Uri "$BaseUrl/api/v0/models" -TimeoutSec 20
}
catch {
    throw "CORNERMAN unreachable at $BaseUrl - $($_.Exception.Message)"
}

$target = $catalog.data | Where-Object { $_.id -eq $Model }

if (-not $target) {
    $known = ($catalog.data | ForEach-Object { $_.id }) -join ', '
    throw "Model '$Model' is not installed on CORNERMAN. Installed: $known"
}

if ($target.state -ne 'loaded') {
    throw @"
CONSULT REFUSED - model '$Model' is not resident.
  actual state : $($target.state)
  required     : loaded

Loading or swapping a model on CORNERMAN is a BLOODWAVE CONSOLE ACT
(CORNERMAN_CONSULT_DOCTRINE section 2). No seat loads it. No retry loop
will fix this. Report the state string and stop.
"@
}

Write-Host "[preflight] '$Model' state=loaded - OK" -ForegroundColor DarkGray

# ---------------------------------------------------------------------------
# BUILD THE PROMPT
# ---------------------------------------------------------------------------
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine($Prompt)

foreach ($path in $Files) {
    if (-not (Test-Path -LiteralPath $path)) {
        throw "-Files: '$path' not found. Nothing is inlined from a path that does not resolve."
    }

    $resolved = (Resolve-Path -LiteralPath $path).Path
    $content = Get-Content -LiteralPath $resolved -Raw

    [void]$sb.AppendLine()
    [void]$sb.AppendLine("--- FILE: $resolved ---")
    [void]$sb.AppendLine('```')
    [void]$sb.AppendLine($content)
    [void]$sb.AppendLine('```')

    Write-Host "[inline] $resolved ($($content.Length) chars)" -ForegroundColor DarkGray
}

$body = @{
    model       = $Model
    messages    = @(
        @{ role = 'user'; content = $sb.ToString() }
    )
    temperature = $Temperature
    max_tokens  = $MaxTokens
} | ConvertTo-Json -Depth 6

# ---------------------------------------------------------------------------
# CONSULT
# ---------------------------------------------------------------------------
Write-Host "[consult] POST $BaseUrl/v1/chat/completions ($Model)" -ForegroundColor DarkGray
$sw = [System.Diagnostics.Stopwatch]::StartNew()

try {
    $reply = Invoke-RestMethod -Uri "$BaseUrl/v1/chat/completions" `
        -Method Post `
        -ContentType 'application/json' `
        -Body ([System.Text.Encoding]::UTF8.GetBytes($body)) `
        -TimeoutSec $TimeoutSec
}
catch {
    throw "Consult failed after $([math]::Round($sw.Elapsed.TotalSeconds,1))s - $($_.Exception.Message)"
}

$sw.Stop()

Write-Host ''
Write-Host ('-' * 70) -ForegroundColor DarkGray
Write-Host "model      : $($reply.model)" -ForegroundColor DarkGray
Write-Host "elapsed    : $([math]::Round($sw.Elapsed.TotalSeconds,1))s" -ForegroundColor DarkGray
Write-Host "tokens     : prompt=$($reply.usage.prompt_tokens) completion=$($reply.usage.completion_tokens)" -ForegroundColor DarkGray
Write-Host ('-' * 70) -ForegroundColor DarkGray
Write-Host ''

$reply.choices[0].message.content

Write-Host ''
Write-Host 'ADVICE, NOT A SENSOR (law C-A). Machine-verify every file:line cite above (law C-B).' -ForegroundColor Yellow
