<#
.SYNOPSIS
  Publish the shared PowerShell prompt thumbnail (retro desktop) for all LifePunch nodes.

.DESCRIPTION
  Canonical art: icons/powershell-prompt-thumbnail.png (same on every web node).
  Builds icons/powershell-prompt-thumbnail.ico, fans out to outfits/*/ *console.png,
  and returns the absolute .ico path for Windows Terminal profile icons.

  Call from Apply-LifePunchOpsConsole.ps1 on vengeance, cornerman, lifepunchnet.
#>
[CmdletBinding()]
param(
    [string] $OpsRoot = $PSScriptRoot
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($OpsRoot)) {
    $OpsRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
}
$iconDir = Join-Path $OpsRoot 'icons'
$png = Join-Path $iconDir 'powershell-prompt-thumbnail.png'
$ico = Join-Path $iconDir 'powershell-prompt-thumbnail.ico'

if (-not (Test-Path -LiteralPath $png)) {
    throw "Missing PowerShell prompt thumbnail: $png"
}

function Get-LifePunchFfmpegPathLocal {
    $candidates = @(
        (Get-Command ffmpeg -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source),
        "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-8.1.1-full_build\bin\ffmpeg.exe"
    )
    foreach ($c in $candidates) {
        if ($c -and (Test-Path -LiteralPath $c)) { return $c }
    }
    return $null
}

function Build-LifePunchPngIcoLocal {
    param([string]$PngPath, [string]$IcoPath, [string]$FfmpegPath)
    if ($FfmpegPath) {
        $args = @('-y', '-i', $PngPath, '-vf', 'scale=256:256:flags=lanczos', $IcoPath)
        $p = Start-Process -FilePath $FfmpegPath -ArgumentList $args -Wait -PassThru -WindowStyle Hidden
        if ($p.ExitCode -eq 0 -and (Test-Path -LiteralPath $IcoPath)) { return $true }
    }
    Add-Type -AssemblyName System.Drawing
    $tempPng = Join-Path $env:TEMP 'lifepunch-powershell-prompt-256.png'
    $img = [System.Drawing.Image]::FromFile($PngPath)
    try {
        $bmp = New-Object System.Drawing.Bitmap 256, 256
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.DrawImage($img, 0, 0, 256, 256)
        $g.Dispose()
        $bmp.Save($tempPng, [System.Drawing.Imaging.ImageFormat]::Png)
        $bmp.Dispose()
    }
    finally { $img.Dispose() }
    $pngBytes = [System.IO.File]::ReadAllBytes($tempPng)
    Remove-Item -LiteralPath $tempPng -Force -ErrorAction SilentlyContinue
    $fs = [System.IO.File]::Create($IcoPath)
    try {
        $bw = New-Object System.IO.BinaryWriter $fs
        $bw.Write([uint16]0); $bw.Write([uint16]1); $bw.Write([uint16]1)
        $bw.Write([byte]0); $bw.Write([byte]0); $bw.Write([byte]0); $bw.Write([byte]0)
        $bw.Write([uint16]1); $bw.Write([uint16]32)
        $bw.Write([uint32]$pngBytes.Length); $bw.Write([uint32]22)
        $bw.Write($pngBytes); $bw.Dispose()
    }
    finally { $fs.Dispose() }
    return $true
}

$ffmpeg = Get-LifePunchFfmpegPathLocal
[void](Build-LifePunchPngIcoLocal -PngPath $png -IcoPath $ico -FfmpegPath $ffmpeg)

$outfitMap = @{
    vengeance    = 'vengeanceconsole.png'
    cornerman    = 'cornermanconsole.png'
    lifepunchnet = 'lifepunchnetconsole.png'
}
foreach ($machine in $outfitMap.Keys) {
    $dest = Join-Path $OpsRoot "outfits\$machine\$($outfitMap[$machine])"
    $dir = Split-Path -Parent $dest
    if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    Copy-Item -LiteralPath $png -Destination $dest -Force
}

$publishDir = Join-Path $env:USERPROFILE 'Documents\LifePunch-Icons'
New-Item -ItemType Directory -Force -Path $publishDir | Out-Null
Copy-Item -LiteralPath $ico -Destination (Join-Path $publishDir 'powershell-prompt-thumbnail.ico') -Force

if (-not (Test-Path -LiteralPath $ico)) {
    throw "Failed to build PowerShell prompt thumbnail: $ico"
}
Write-Output (Resolve-Path -LiteralPath $ico).Path
