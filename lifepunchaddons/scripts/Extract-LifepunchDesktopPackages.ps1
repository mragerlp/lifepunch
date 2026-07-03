<#
.SYNOPSIS
  Extract all ZIPs under Desktop lifepunchaddons for audit (never deletes originals).

.EXAMPLE
  powershell -File lifepunchaddons\scripts\Extract-LifepunchDesktopPackages.ps1
  powershell -File lifepunchaddons\scripts\Extract-LifepunchDesktopPackages.ps1 -WhatIf
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string] $Root = "$env:USERPROFILE\OneDrive\Desktop\lifepunchaddons"
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem

if (-not (Test-Path -LiteralPath $Root)) {
    throw "Missing drop root: $Root"
}

$report = @()
$zips = Get-ChildItem -LiteralPath $Root -Recurse -Filter '*.zip' -File -Force

Write-Host "Drop root: $Root" -ForegroundColor Cyan
Write-Host "ZIP files: $($zips.Count)`n" -ForegroundColor Cyan

foreach ($zip in $zips) {
    $slotDir = $zip.DirectoryName
    $extractRoot = Join-Path $slotDir 'extracted'
    $dest = Join-Path $extractRoot ([IO.Path]::GetFileNameWithoutExtension($zip.Name))

    $relSlot = $slotDir.Substring($Root.Length).TrimStart('\')

    if ($PSCmdlet.ShouldProcess($zip.FullName, "Extract to $dest")) {
        New-Item -ItemType Directory -Force -Path $dest | Out-Null
        try {
            [System.IO.Compression.ZipFile]::ExtractToDirectory($zip.FullName, $dest)
            $count = (Get-ChildItem -LiteralPath $dest -Recurse -File -Force).Count
            Write-Host "  OK $relSlot\$($zip.Name) -> extracted\$([IO.Path]::GetFileNameWithoutExtension($zip.Name)) ($count files)" -ForegroundColor Green
            $report += [pscustomobject]@{
                Slot     = $relSlot
                Zip      = $zip.Name
                Extract  = "extracted\$([IO.Path]::GetFileNameWithoutExtension($zip.Name))"
                Files    = $count
                Status   = 'OK'
            }
        }
        catch {
            Write-Host "  FAIL $relSlot\$($zip.Name): $_" -ForegroundColor Red
            $report += [pscustomobject]@{
                Slot     = $relSlot
                Zip      = $zip.Name
                Extract  = ''
                Files    = 0
                Status   = "FAIL: $_"
            }
        }
    }
}

$auditDir = Join-Path $Root 'audit'
if ($PSCmdlet.ShouldProcess($auditDir, 'Write extract_report.json')) {
    New-Item -ItemType Directory -Force -Path $auditDir | Out-Null
    $report | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $auditDir 'extract_report.json') -Encoding UTF8
}

Write-Host "`nReport: $auditDir\extract_report.json" -ForegroundColor DarkGray
