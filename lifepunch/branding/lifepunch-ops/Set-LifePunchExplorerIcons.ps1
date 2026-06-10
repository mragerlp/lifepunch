<#
.SYNOPSIS
  LifePunch uniform Explorer icons (all nodes) — folder + .txt.

.DESCRIPTION
  Builds .ico from icons/lifepunch-folder.png and icons/lifepunch-txt.png,
  publishes to Documents\LifePunch-Icons, and applies:
    - Shell Icons 3/4 (closed/open folder; HKLM + HKCU — Win11 needs HKLM)
    - Folder / Directory / LibraryFolder DefaultIcon
    - Explorer Advanced IconsOnly=1 (skip imageres folder thumbnails)
    - .txt DefaultIcon (txtfile, txtfilelegacy, UserChoice ProgId, SystemFileAssociations)
  Call from Apply-LifePunchOpsConsole.ps1 on vengeance, cornerman, lifepunchnet.
#>
[CmdletBinding()]
param(
    [string] $OpsRoot = $PSScriptRoot,
    [string] $PublishDir = $(Join-Path $env:USERPROFILE 'Documents\LifePunch-Icons')
)

$ErrorActionPreference = 'Stop'

function Get-LifePunchFfmpegPath {
    $candidates = @(
        (Get-Command ffmpeg -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source),
        "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-8.1.1-full_build\bin\ffmpeg.exe"
    )
    foreach ($c in $candidates) {
        if ($c -and (Test-Path -LiteralPath $c)) { return $c }
    }
    return $null
}

function Build-LifePunchPngIco {
    param(
        [string]$PngPath,
        [string]$IcoPath,
        [string]$FfmpegPath,
        [string]$TempLabel = 'asset'
    )
    if ($FfmpegPath) {
        $args = @('-y', '-i', $PngPath, '-vf', 'scale=256:256:flags=lanczos', $IcoPath)
        $p = Start-Process -FilePath $FfmpegPath -ArgumentList $args -Wait -PassThru -WindowStyle Hidden
        if ($p.ExitCode -eq 0 -and (Test-Path -LiteralPath $IcoPath)) { return $true }
    }
    Add-Type -AssemblyName System.Drawing
    $tempPng = Join-Path $env:TEMP "lifepunch-$TempLabel-256.png"
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

function Set-LifePunchRegistryDefaultIcon {
    param(
        [string[]]$RegPaths,
        [string]$WithIndex
    )
    foreach ($regPath in $RegPaths) {
        New-Item -Path $regPath -Force | Out-Null
        Set-ItemProperty -Path $regPath -Name '(default)' -Value $WithIndex
    }
}

function Set-LifePunchExplorerFolderViewPolicy {
    $adv = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    if (-not (Test-Path -LiteralPath $adv)) {
        reg.exe add 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' /f | Out-Null
    }
    Set-ItemProperty -Path $adv -Name 'IconsOnly' -Value 1 -Type DWord -Force
}

function Set-LifePunchShellIconsRegistry {
    param(
        [string]$Root,
        [string]$IcoPath
    )
    $shellIcons = Join-Path $Root 'Shell Icons'
    New-Item -Path $shellIcons -Force | Out-Null
    Set-ItemProperty -Path $shellIcons -Name '3' -Value $IcoPath
    Set-ItemProperty -Path $shellIcons -Name '4' -Value $IcoPath
}

function Invoke-LifePunchShellIconsHklm {
    param([string]$IcoPath)
    $hk = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons'
    $existing = Get-ItemProperty -Path $hk -ErrorAction SilentlyContinue
    if ($existing.'3' -eq $IcoPath -and $existing.'4' -eq $IcoPath) { return $true }

    try {
        Set-LifePunchShellIconsRegistry -Root 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' -IcoPath $IcoPath
        return $true
    }
    catch {
        $escaped = $IcoPath -replace '\\', '\\'
        $regBody = @"
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons]
"3"="$escaped"
"4"="$escaped"
"@
        $regFile = Join-Path $env:TEMP 'lifepunch-folder-shell-icons-hklm.reg'
        Set-Content -LiteralPath $regFile -Value $regBody -Encoding Unicode
        $import = Start-Process -FilePath 'reg.exe' -ArgumentList @('import', $regFile) -Verb RunAs -PassThru -Wait
        if ($import.ExitCode -ne 0) {
            Write-Host '    Folder: approve UAC to set HKLM Shell Icons (required on Windows 11).' -ForegroundColor Yellow
            Write-Host "    Or run elevated: reg import `"$regFile`"" -ForegroundColor DarkGray
            return $false
        }
        return $true
    }
}

function Set-LifePunchExplorerFolderIcon {
    param([string]$IcoPath)
    $resolved = (Resolve-Path -LiteralPath $IcoPath).Path
    $withIndex = "$resolved,0"
    Set-LifePunchExplorerFolderViewPolicy
    Set-LifePunchShellIconsRegistry -Root 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' -IcoPath $resolved
    [void](Invoke-LifePunchShellIconsHklm -IcoPath $resolved)
    Set-LifePunchRegistryDefaultIcon -RegPaths @(
        'HKCU:\Software\Classes\Folder\DefaultIcon',
        'HKCU:\Software\Classes\Directory\DefaultIcon',
        'HKCU:\Software\Classes\LibraryFolder\DefaultIcon'
    ) -WithIndex $withIndex
    return $resolved
}

function Get-LifePunchTxtProgIds {
    $progIds = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    [void]$progIds.Add('txtfile')
    [void]$progIds.Add('txtfilelegacy')
    $assoc = Get-ItemProperty 'HKLM:\Software\Classes\.txt' -ErrorAction SilentlyContinue
    if ($assoc.'(default)') { [void]$progIds.Add($assoc.'(default)') }
    $userChoice = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.txt\UserChoice' -ErrorAction SilentlyContinue
    if ($userChoice.ProgId) { [void]$progIds.Add($userChoice.ProgId) }
    return @($progIds)
}

function Set-LifePunchTxtIcon {
    param([string]$IcoPath)
    $resolved = (Resolve-Path -LiteralPath $IcoPath).Path
    $withIndex = "$resolved,0"
    $regPaths = @(
        'HKCU:\Software\Classes\.txt\DefaultIcon',
        'HKCU:\Software\Classes\SystemFileAssociations\.txt\DefaultIcon'
    )
    foreach ($progId in Get-LifePunchTxtProgIds) {
        $regPaths += "HKCU:\Software\Classes\$progId\DefaultIcon"
    }
    Set-LifePunchRegistryDefaultIcon -RegPaths $regPaths -WithIndex $withIndex
    return $resolved
}

function Invoke-LifePunchExplorerIconRefresh {
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $ie4u = Join-Path ${env:WinDir} 'System32\ie4uinit.exe'
    if (Test-Path -LiteralPath $ie4u) {
        Start-Process -FilePath $ie4u -ArgumentList '-show' -WindowStyle Hidden -ErrorAction SilentlyContinue
    }
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 1200
    Start-Process explorer.exe
    $ErrorActionPreference = $prev
}

function Publish-LifePunchIcon {
    param(
        [string]$Name,
        [string]$FfmpegPath
    )
    $png = Join-Path $OpsRoot "icons\$Name.png"
    if (-not (Test-Path -LiteralPath $png)) { throw "Missing icon source: $png" }
    $repoIco = Join-Path $OpsRoot "icons\$Name.ico"
    $pubIco = Join-Path $PublishDir "$Name.ico"
    Build-LifePunchPngIco -PngPath $png -IcoPath $repoIco -FfmpegPath $FfmpegPath -TempLabel $Name | Out-Null
    Copy-Item -LiteralPath $repoIco -Destination $pubIco -Force
    return $pubIco
}

New-Item -ItemType Directory -Force -Path $PublishDir | Out-Null
$ffmpeg = Get-LifePunchFfmpegPath

$folderPub = Publish-LifePunchIcon -Name 'lifepunch-folder' -FfmpegPath $ffmpeg
$folderApplied = Set-LifePunchExplorerFolderIcon -IcoPath $folderPub
Write-Host "    Folder icon: $folderApplied" -ForegroundColor DarkGray

$txtPub = Publish-LifePunchIcon -Name 'lifepunch-txt' -FfmpegPath $ffmpeg
$txtApplied = Set-LifePunchTxtIcon -IcoPath $txtPub
Write-Host "    .txt icon: $txtApplied" -ForegroundColor DarkGray

Invoke-LifePunchExplorerIconRefresh
