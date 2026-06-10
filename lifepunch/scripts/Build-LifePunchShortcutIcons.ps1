<#
.SYNOPSIS
  Build Windows-compatible .ico files and publish to Documents\LifePunch-Icons.

.DESCRIPTION
  Explorer ignores PNG in IconLocation and often rejects home-grown PNG-in-ICO blobs.
  Uses ffmpeg when available (proper ICO). Publishes to a stable local folder so
  OneDrive Desktop shortcuts resolve icons reliably.
#>
[CmdletBinding()]
param(
    [string] $PublishDir = $(Join-Path $env:USERPROFILE 'Documents\LifePunch-Icons'),
    [string] $FfmpegPath = ''
)

$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
. (Join-Path $Here 'LifePunch-ShortcutIcons.ps1')

$iconDir = Join-Path (Get-LifePunchBrandingRoot) 'shortcut-icons'
New-Item -ItemType Directory -Force -Path $PublishDir | Out-Null

if (-not $FfmpegPath) {
    $candidates = @(
        (Get-Command ffmpeg -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source),
        "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-8.1.1-full_build\bin\ffmpeg.exe"
    )
    foreach ($c in $candidates) {
        if ($c -and (Test-Path -LiteralPath $c)) { $FfmpegPath = $c; break }
    }
}

function Build-IcoWithFfmpeg {
    param([string]$PngPath, [string]$IcoPath)
    if (-not $FfmpegPath) { return $false }
    $args = @('-y', '-i', $PngPath, '-vf', 'scale=256:256:flags=lanczos', $IcoPath)
    $p = Start-Process -FilePath $FfmpegPath -ArgumentList $args -Wait -PassThru -WindowStyle Hidden
    return ($p.ExitCode -eq 0 -and (Test-Path -LiteralPath $IcoPath))
}

function Build-IcoFallback {
    param([string]$PngPath, [string]$IcoPath)
    Add-Type -AssemblyName System.Drawing
    $tempPng = Join-Path $env:TEMP "lifepunch-ico-src.png"
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
}

$tierMap = @{
    universal    = 'lifepunch-universal'
    vengeance    = 'lifepunch-vengeance'
    cornerman    = 'lifepunch-cornerman'
    lifepunchnet = 'lifepunch-lifepunchnet'
}

Write-Host ''
Write-Host 'Build LifePunch shortcut icons' -ForegroundColor Cyan
if ($FfmpegPath) { Write-Host "  ffmpeg: $FfmpegPath" -ForegroundColor DarkGray }
else { Write-Host '  ffmpeg: not found (using fallback; install ffmpeg for best Explorer display)' -ForegroundColor Yellow }
Write-Host "  publish: $PublishDir" -ForegroundColor DarkGray
Write-Host ''

$script:PublishedRoot = $PublishDir

foreach ($tier in $tierMap.Keys) {
    $base = $tierMap[$tier]
    $pngPath = Join-Path $iconDir "$base.png"
    if (-not (Test-Path -LiteralPath $pngPath)) { throw "Missing $pngPath" }
    $repoIco = Join-Path $iconDir "$base.ico"
    $pubIco = Join-Path $PublishDir "$base.ico"
    $built = Build-IcoWithFfmpeg -PngPath $pngPath -IcoPath $repoIco
    if (-not $built) { Build-IcoFallback -PngPath $pngPath -IcoPath $repoIco }
    Copy-Item -LiteralPath $repoIco -Destination $pubIco -Force
    $len = (Get-Item -LiteralPath $pubIco).Length
    Write-Host "  $base.ico -> $pubIco ($len bytes)" -ForegroundColor Green
}

Write-Host 'Done.' -ForegroundColor Cyan
Write-Host ''
