$ErrorActionPreference = 'Stop'

function Get-RemoteFileText {
    param([string] $RemotePath)
    # PowerShell on Cornerman avoids CMD "type" banner corruption in pulled artifacts.
    $escaped = $RemotePath -replace "'", "''"
    $cmd = "powershell -NoProfile -Command ""Get-Content -LiteralPath '$escaped' -Raw"""
    $out = ssh cornerman $cmd 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw ($out | Out-String).Trim()
    }
    return ($out | Out-String).TrimEnd()
}

$dest = Join-Path $PSScriptRoot '..\docs\handoff\cornerman-outbox'
New-Item -ItemType Directory -Force -Path $dest | Out-Null
$map = @{
    'MODELDOC_READINESS_ROLLUP_FULL_2026-06-17.md' = 'C:/Projects/cornerman-rag/outbox/MODELDOC_READINESS_ROLLUP_FULL_2026-06-17.md'
    'PACKAGE_DOSSIERS_2026-06-17.md'               = 'C:/Projects/cornerman-rag/outbox/PACKAGE_DOSSIERS_2026-06-17.md'
    'REPO_STAGING_GAP_FULL_2026-06-17.md'          = 'C:/Projects/cornerman-rag/outbox/REPO_STAGING_GAP_FULL_2026-06-17.md'
    'FBX_MATERIAL_SLOTS_2026-06-17.json'           = 'C:/Projects/cornerman-rag/outbox/FBX_MATERIAL_SLOTS_2026-06-17.json'
    'DXRP_PUBLISH_READINESS_2026-06-17.md'         = 'C:/Projects/cornerman-rag/outbox/DXRP_PUBLISH_READINESS_2026-06-17.md'
    'SYNC_WORKFLOW_LAW_2026-06-17.md'              = 'C:/Projects/cornerman-rag/outbox/SYNC_WORKFLOW_LAW_2026-06-17.md'
    'SWEEP_STATUS.json'                            = 'C:/lifepunch/cornerman/outbox/SWEEP_STATUS.json'
}
foreach ($name in $map.Keys) {
    $remote = $map[$name]
    try {
        $text = Get-RemoteFileText -RemotePath $remote
        if (-not $text) {
            Write-Host "MISS $name (empty)" -ForegroundColor Yellow
            continue
        }
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText((Join-Path $dest $name), $text, $utf8NoBom)
        Write-Host "OK $name" -ForegroundColor Green
    }
    catch {
        Write-Host "MISS $name — $($_.Exception.Message)" -ForegroundColor Yellow
    }
}
