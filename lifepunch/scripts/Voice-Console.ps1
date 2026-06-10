# Shared LifePunch voice terminal layout (VENGEANCE PowerShell windows).
# Cornerman relay_ui.py mirrors this spec — keep both in sync when changing banners/events.

$script:VoiceConsoleWidth = 64

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
        Write-Host "  $Subtitle" -ForegroundColor DarkGray
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
    Write-Host "  $pad  $Value" -ForegroundColor DarkGray
}

function Write-VoiceDivider {
    Write-Host ('-' * $script:VoiceConsoleWidth) -ForegroundColor DarkGray
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
    Write-Host "  $Title" -ForegroundColor DarkMagenta
    foreach ($line in $Lines) {
        Write-Host "    $line" -ForegroundColor Gray
    }
}
