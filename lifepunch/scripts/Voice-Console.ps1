# Shared LifePunch voice terminal layout (VENGEANCE PowerShell windows).
# Cornerman relay_ui.py mirrors this spec — keep both in sync when changing banners/events.
#
# VENGEANCE uniform (June 2026): black/dark conhost + node accent banner; body text gray/white
# (not DarkGray — unreadable on black). See lifepunch/branding/lifepunch-ops/UNIFORM_STANDARDS.md

$script:VoiceConsoleWidth = 64

# Readable body palette on dark backgrounds
$script:VoiceColorSubtitle = 'Gray'
$script:VoiceColorMetaLabel = 'Gray'
$script:VoiceColorMetaValue = 'White'
$script:VoiceColorDivider = 'Gray'
$script:VoiceColorMuted = 'White'
$script:VoiceColorLogTitle = 'Cyan'
$script:VoiceColorLogLine = 'Gray'

function Get-VoiceConsoleAccent {
    $cfgPath = Join-Path $env:LOCALAPPDATA 'LifePunch\ops-node.json'
    if (Test-Path -LiteralPath $cfgPath) {
        try {
            $cfg = Get-Content -LiteralPath $cfgPath -Raw | ConvertFrom-Json
            if ($cfg.bannerColor) { return [ConsoleColor]$cfg.bannerColor }
        }
        catch { }
    }
    return [ConsoleColor]'Red'
}

$script:VoiceConsoleAccent = Get-VoiceConsoleAccent

function Get-CornermanSshNoisePatterns {
    return @(
        '^\s*Microsoft Windows \[Version',
        '^\s*\(c\) Microsoft Corporation',
        '^\s*All rights reserved\.\s*$',
        '^\s*C:\\Users\\',
        '^\s*#< CLIXML'
    )
}

function Normalize-CornermanSshFileContent {
    <#
    .SYNOPSIS
      Flatten SSH output and drop Windows banner / profile noise before file parsing.
    #>
    param(
        [AllowNull()]
        $Raw
    )
    if ($null -eq $Raw) { return $null }
    $lines = if ($Raw -is [array]) {
        @($Raw | ForEach-Object { [string]$_ })
    }
    else {
        ([string]$Raw) -split "`r?`n"
    }
    $noise = Get-CornermanSshNoisePatterns
    $filtered = foreach ($line in $lines) {
        $drop = $false
        foreach ($pat in $noise) {
            if ($line -match $pat) { $drop = $true; break }
        }
        if (-not $drop) { $line }
    }
    $text = ($filtered -join "`n").TrimEnd()
    if ([string]::IsNullOrWhiteSpace($text)) { return $null }
    return $text
}

function Get-CornermanSessionLogLines {
    param(
        [AllowNull()]
        $Raw,
        [int] $Tail = 8
    )
    $text = Normalize-CornermanSshFileContent $Raw
    if (-not $text) { return @() }
    $all = @(
        $text -split "`r?`n" |
            Where-Object { $_ -match '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z\s*\|' }
    )
    if ($all.Count -le $Tail) { return $all }
    return $all[($all.Count - $Tail)..($all.Count - 1)]
}

function Get-TextPreview {
    param(
        [AllowNull()]
        [string] $Text,
        [int] $MaxLen = 120
    )
    if ([string]::IsNullOrEmpty($Text)) { return '' }
    $len = $Text.Length
    if ($len -le $MaxLen) { return $Text }
    $take = [Math]::Min($MaxLen, $len)
    if ($take -le 0) { return '' }
    return $Text.Substring(0, $take) + '...'
}

function Invoke-CornermanSshRead {
    <#
    .SYNOPSIS
      Read a file from Cornerman over SSH without tripping on remote PowerShell profile noise.
    #>
    param(
        [Parameter(Mandatory)]
        [string] $RemotePath,
        [string] $SshTarget = $(if ($env:CORNERMAN_SSH) { $env:CORNERMAN_SSH } else { 'cornerman' }),
        [int] $ConnectTimeout = 10,
        [switch] $Raw
    )
    # cmd /c type avoids remote PowerShell profile + brace-quoting issues over SSH.
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    $out = & ssh -o BatchMode=yes -o ConnectTimeout=$ConnectTimeout $SshTarget `
        "cmd /c type `"$RemotePath`"" 2>$null
    $code = $LASTEXITCODE
    $ErrorActionPreference = $prev
    if ($code -ne 0) { return $null }
    if ($Raw) { return $out }
    return Normalize-CornermanSshFileContent $out
}

function Write-VoiceRule {
    param([ConsoleColor] $Color = $script:VoiceConsoleAccent)
    Write-Host ('=' * $script:VoiceConsoleWidth) -ForegroundColor $Color
}

function Write-VoiceHeader {
    param(
        [Parameter(Mandatory)]
        [string] $Title,
        [string] $Subtitle = ''
    )
    Write-Host ''
    Write-VoiceRule
    Write-Host "  $Title" -ForegroundColor $script:VoiceConsoleAccent
    if ($Subtitle) {
        Write-Host "  $Subtitle" -ForegroundColor $script:VoiceColorSubtitle
    }
    Write-VoiceRule
    Write-Host ''
}

function Write-VoiceMeta {
    param(
        [Parameter(Mandatory)]
        [string] $Label,
        [Parameter(Mandatory)]
        [string] $Value
    )
    $pad = $Label.PadRight(11)
    Write-Host "  $pad  " -NoNewline -ForegroundColor $script:VoiceColorMetaLabel
    Write-Host $Value -ForegroundColor $script:VoiceColorMetaValue
}

function Write-VoiceMuted {
    param(
        [Parameter(Mandatory)]
        [string] $Text
    )
    # Config/path hints (server-host-watch, status-token, etc.) — always white on black.
    Write-Host "  $Text" -ForegroundColor $script:VoiceColorMuted
}

function Write-VoiceBody {
    param(
        [Parameter(Mandatory)]
        [string] $Text,
        [ConsoleColor] $Color = $script:VoiceColorLogLine
    )
    foreach ($line in ($Text -split "`r?`n")) {
        if ($line.Length -gt 0) {
            Write-Host $line -ForegroundColor $Color
        }
    }
}

function Write-VoiceStatus {
    param(
        [Parameter(Mandatory)]
        [string] $Label,
        [Parameter(Mandatory)]
        [string] $Value,
        [bool] $Ok = $true
    )
    Write-Host "  ${Label}:  " -NoNewline -ForegroundColor $script:VoiceColorMetaLabel
    $valueColor = if ($Ok) { $script:VoiceColorMetaValue } else { 'Yellow' }
    Write-Host $Value -ForegroundColor $valueColor
}

function Write-VoiceDivider {
    Write-Host ('-' * $script:VoiceConsoleWidth) -ForegroundColor $script:VoiceColorDivider
}

function Write-VoiceEvent {
    param(
        [Parameter(Mandatory)]
        [string] $Name,
        [string] $Detail = '',
        [ConsoleColor] $Color = 'Green'
    )
    $ts = Get-Date -Format 'HH:mm:ss'
    $line = "  [$ts]  $Name"
    if ($Detail) { $line += "  $Detail" }
    Write-Host $line -ForegroundColor $Color
}

function Write-VoiceHeard {
    param(
        [Parameter(Mandatory)]
        [string] $Text,
        [int] $MaxLen = 80
    )
    $preview = $Text
    if ($preview.Length -gt $MaxLen) {
        $preview = $preview.Substring(0, $MaxLen) + '...'
    }
    Write-Host "  I HEARD: $preview" -ForegroundColor White
}

function Write-VoiceSessionLog {
    param(
        [Parameter(Mandatory)]
        [string[]] $Lines,
        [string] $Title = 'SESSION LOG'
    )
    if (-not $Lines -or $Lines.Count -eq 0) { return }
    Write-Host ''
    Write-Host "  $Title" -ForegroundColor $script:VoiceColorLogTitle
    foreach ($line in $Lines) {
        Write-Host "    $line" -ForegroundColor $script:VoiceColorLogLine
    }
}
