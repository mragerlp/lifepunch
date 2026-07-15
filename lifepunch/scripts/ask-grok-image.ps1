<#
.SYNOPSIS
  ask-grok-image.ps1 — CVL bridge to the xAI image generation API.
  Sibling of ask-cornerman.ps1. Any seat (via Bloodwave transport or
  allowlisted script exec) can request brand/art assets mid-slice.

.CANON
  BRAND AGENT SEAT ruling 2026-07-15 (rides Red canon slice, dispatch
  red\0003 item 7). Key Law: own minimum-scope key (GX-1), env var
  XAI_API_KEY, never transcribed, KEY_LEDGER metadata only.
  Rule C-1: no seat reads credential files — this script reads ONLY
  the environment variable.

.PROVENANCE
  Every generated asset gets a sidecar .md with the exact prompt,
  model, timestamp, and intended surface — assets are sensors.

.USAGE
  # Preflight (verify key + list image-capable models — run first):
  .\ask-grok-image.ps1 -Preflight

  # Generate:
  .\ask-grok-image.ps1 -Prompt "HASHD pixel-block wordmark, bitcoin
    orange on near-black, ..." -Slug "brand_workshop-thumb_hashd_v0" `
    -Surface "steam workshop thumbnail" -N 3

.NOTES
  Endpoint per xAI public API (OpenAI-compatible). Model name is
  NOT hardcoded-trusted: preflight queries /v1/models and the script
  fails loud if the requested model is absent (fabricated-sensor
  discipline — verify, don't assume).
#>
param(
  [string]$Prompt,
  [string]$Slug = ("brand_untitled_v0_" + (Get-Date -Format "yyyyMMdd-HHmmss")),
  [string]$Surface = "unspecified",
  [int]$N = 1,
  [string]$Model = "grok-2-image",   # verified against /v1/models at runtime
  [string]$OutDir = "C:\lifepunch\brand-intake",
  [switch]$Preflight
)

$ErrorActionPreference = "Stop"
$BaseUrl = "https://api.x.ai/v1"

# -- KEY (env only; never a file, never transcribed) --
$ApiKey = $env:XAI_API_KEY
if (-not $ApiKey) {
  Write-Error "XAI_API_KEY not set. Mint a minimum-scope key at console.x.ai, then: setx XAI_API_KEY <key> (new shell after). KEY_LEDGER entry GX-1 = metadata only."
  exit 1
}
$Headers = @{ "Authorization" = "Bearer $ApiKey"; "Content-Type" = "application/json" }

# -- PREFLIGHT: models endpoint is the residency sensor --
function Get-ImageModels {
  try {
    $models = Invoke-RestMethod -Uri "$BaseUrl/models" -Headers $Headers -Method GET
  } catch {
    Write-Error "Preflight FAIL: /v1/models unreachable or key rejected. Raw: $($_.Exception.Message)"
    exit 1
  }
  return $models.data | Where-Object { $_.id -match "image" }
}

if ($Preflight) {
  $imgModels = Get-ImageModels
  if (-not $imgModels) {
    Write-Host "PREFLIGHT: key VALID but no image-capable model visible. xAI may not expose Imagine via API on this account/tier yet - Tier 2 stays banked; use the web app (Tier 1 intake)." -ForegroundColor Yellow
    exit 2
  }
  Write-Host "PREFLIGHT PASS. Image-capable models:" -ForegroundColor Green
  $imgModels | ForEach-Object { Write-Host ("  " + $_.id) }
  exit 0
}

if (-not $Prompt) { Write-Error "Prompt required (or use -Preflight)."; exit 1 }

# -- Model residency check (fail loud, never assume) --
$imgModels = Get-ImageModels
if (-not ($imgModels | Where-Object { $_.id -eq $Model })) {
  $avail = ($imgModels | ForEach-Object { $_.id }) -join ", "
  Write-Error "Model '$Model' not in /v1/models. Available image models: [$avail]. Pass -Model explicitly."
  exit 1
}

# -- Generate --
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$Body = @{ model = $Model; prompt = $Prompt; n = $N; response_format = "b64_json" } | ConvertTo-Json -Depth 4

Write-Host "Requesting $N image(s) from $Model..." -ForegroundColor Cyan
try {
  $resp = Invoke-RestMethod -Uri "$BaseUrl/images/generations" -Headers $Headers -Method POST -Body $Body
} catch {
  Write-Error "Generation FAIL: $($_.Exception.Message)"
  exit 1
}

$stamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssK"
$i = 0
foreach ($img in $resp.data) {
  $i++
  $suffix = if ($N -gt 1) { "-$i" } else { "" }
  $pngPath = Join-Path $OutDir "$Slug$suffix.png"
  [IO.File]::WriteAllBytes($pngPath, [Convert]::FromBase64String($img.b64_json))

  # -- Provenance sidecar (assets are sensors) --
  $sidecarLines = @(
    ("# PROVENANCE - " + $Slug + $suffix),
    ("- generated: " + $stamp),
    ("- model: " + $Model + " (verified via /v1/models this run)"),
    ("- intended surface: " + $Surface),
    ("- n-of: " + $i + " / " + $N),
    ("- revised prompt (API-returned, if any): " + $img.revised_prompt),
    "- EXACT PROMPT (verbatim):",
    $Prompt,
    "- delivery schema: BRAND AGENT SEAT ruling 2026-07-15",
    "- footer requirement: LIFEPUNCH(TM) - proprietary IP - lifepunch.co"
  )
  Set-Content -Path (Join-Path $OutDir "$Slug$suffix.provenance.md") -Value ($sidecarLines -join [Environment]::NewLine)
  Write-Host ("SAVED: " + $pngPath + " plus provenance sidecar") -ForegroundColor Green
}
Write-Host "Done. Intake at $OutDir - review, then graduate keepers to the repo intake path on your word." -ForegroundColor Cyan
