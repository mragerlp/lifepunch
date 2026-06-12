<#
.SYNOPSIS
  Ensure rp.sbproj Resources includes addons/lifepunch/<ident>/** for synced addons.
#>
[CmdletBinding()]
param(
    [string[]] $Ident = @('bitcoinmining', 'hackerjob', 'ak47'),
    [string] $ConfigPath = ''
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $ConfigPath) { $ConfigPath = Join-Path $Here 'dxrp-editor.local.json' }
if (-not (Test-Path -LiteralPath $ConfigPath)) {
    Write-Warning "Skip rp.sbproj Resources patch - missing $ConfigPath"
    return
}

$cfg = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
$sbprojPath = [string]$cfg.projectPath
if ([string]::IsNullOrWhiteSpace( $sbprojPath ) -or -not (Test-Path -LiteralPath $sbprojPath)) {
    Write-Warning "Skip rp.sbproj Resources patch - bad projectPath: $sbprojPath"
    return
}

$content = Get-Content -LiteralPath $sbprojPath -Raw
$added = @()
foreach ($ident in $Ident) {
    $needle = "addons/lifepunch/$ident/**"
    if ($content -notlike "*$needle*") {
        $old = 'addons/lifepunch/bitcoinmining/**"'
        $new = "addons/lifepunch/bitcoinmining/**`naddons/lifepunch/$ident/**`""
        if ($content -like "*$old*" -and $ident -ne 'bitcoinmining') {
            $content = $content.Replace( $old, $new )
            $added += $needle
        }
        elseif ($content -notlike "*addons/lifepunch/bitcoinmining/***") {
            $marker = '"Resources": "'
            $idx = $content.IndexOf( $marker )
            if ($idx -ge 0) {
                $insertAt = $content.IndexOf( '"', $idx + $marker.Length )
                if ($insertAt -ge 0) {
                    $content = $content.Insert( $insertAt, "$needle\n" )
                    $added += $needle
                }
            }
        }
    }
}

if ($added.Count -eq 0) {
    Write-Host 'rp.sbproj Resources already includes LifePunch addon mounts.' -ForegroundColor DarkGray
    return
}

[System.IO.File]::WriteAllText( $sbprojPath, $content )
Write-Host "rp.sbproj Resources +$($added.Count):" -ForegroundColor Green
$added | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkGray }
Write-Host "Restart sbox editor if it was open (Resources changed)." -ForegroundColor Yellow
