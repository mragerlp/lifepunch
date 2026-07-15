<#
.SYNOPSIS
  watch-brand-intake.ps1 - Lane A integration for the Grok Imagine
  brand seat. Watches the intake folder; every new image gets a
  provenance stub sidecar and an intake-log line. The folder IS the
  integration: agents treat it as a sensor lane.

.CANON
  BRAND AGENT SEAT ruling 2026-07-15 (docs/cvl via PR #127).
  Delivery schema: brand_<surface>_<name>_v<N>. Drafts = *_v0 or
  concept-*. Assets are sensors; provenance required.

.USAGE
  .\watch-brand-intake.ps1              (watch default folder)
  .\watch-brand-intake.ps1 -Once        (single sweep, no watch loop)
#>
param(
  [string]$IntakeDir = "C:\lifepunch\brand-intake",
  [switch]$Once
)

$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Force -Path $IntakeDir | Out-Null
$LogPath = Join-Path $IntakeDir "_intake-log.md"
if (-not (Test-Path $LogPath)) {
  Set-Content -Path $LogPath -Value "# BRAND INTAKE LOG (watcher-generated; append-only)"
}

function Process-Image {
  param([string]$Path)
  if (-not (Test-Path $Path)) { return }
  $ext = [IO.Path]::GetExtension($Path).ToLower()
  if ($ext -notin @(".png", ".jpg", ".jpeg", ".webp")) { return }
  $base = [IO.Path]::GetFileNameWithoutExtension($Path)
  $sidecar = Join-Path $IntakeDir ($base + ".provenance.md")
  if (Test-Path $sidecar) { return }   # already processed

  $stamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
  $schemaOk = ($base -match "^brand_[a-z0-9\-]+_[a-z0-9\-]+_v[0-9]+") -or ($base -match "^concept-")
  $schemaNote = "PASS"
  if (-not $schemaOk) { $schemaNote = "NONCONFORMING - rename to brand_<surface>_<name>_v<N> or concept-* before graduation" }

  $lines = @(
    ("# PROVENANCE STUB - " + $base + $ext),
    ("- intake: " + $stamp + " (watcher-generated stub)"),
    ("- schema check: " + $schemaNote),
    "- source: Grok Imagine (Tier 1 manual drop; fill fields below)",
    "- dimensions: FILL",
    "- format: " + $ext.TrimStart("."),
    "- intended surface: FILL",
    "- exact generation prompt: FILL (paste verbatim from the agent)",
    "- status: INTAKE-PENDING (graduates to repo _intake/brand on Bloodwave word)",
    "- footer requirement: LIFEPUNCH(TM) - proprietary IP - lifepunch.co"
  )
  Set-Content -Path $sidecar -Value ($lines -join [Environment]::NewLine)
  Add-Content -Path $LogPath -Value ("- " + $stamp + " | " + $base + $ext + " | schema " + $schemaNote)
  Write-Host ("INTAKE: " + $base + $ext + " | schema " + $schemaNote) -ForegroundColor Cyan
}

# Initial sweep (catches anything dropped while watcher was down)
Get-ChildItem -Path $IntakeDir -File | ForEach-Object { Process-Image -Path $_.FullName }
if ($Once) { Write-Host "Single sweep complete." -ForegroundColor Green; exit 0 }

# Watch loop
$watcher = New-Object IO.FileSystemWatcher $IntakeDir
$watcher.EnableRaisingEvents = $true
$action = { Start-Sleep -Milliseconds 500; Process-Image -Path $Event.SourceEventArgs.FullPath }
Register-ObjectEvent $watcher Created -Action $action | Out-Null
Register-ObjectEvent $watcher Renamed -Action $action | Out-Null
Write-Host ("Watching " + $IntakeDir + " - drop Grok renders here. Ctrl+C to stop.") -ForegroundColor Green
while ($true) { Wait-Event -Timeout 5 | Out-Null }
