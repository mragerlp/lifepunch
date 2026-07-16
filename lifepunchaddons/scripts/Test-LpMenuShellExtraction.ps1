<#
.SYNOPSIS
  Verify the universal LpMenuShell extraction and first Bitcoin Ops consumer.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$codeRoot = (Resolve-Path (Join-Path $here '..\Code\Addons\lifepunch')).Path
$failures = New-Object 'System.Collections.Generic.List[string]'
$passes = 0

function Read-Source {
    param([string] $RelativePath)

    $path = Join-Path $codeRoot $RelativePath
    if (-not (Test-Path -LiteralPath $path)) {
        $failures.Add("missing file: $RelativePath")
        return ''
    }

    return [System.IO.File]::ReadAllText($path)
}

function Assert-Match {
    param(
        [string] $Name,
        [string] $Text,
        [string] $Pattern
    )

    if ([regex]::IsMatch($Text, $Pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)) {
        $script:passes++
        Write-Host "PASS [$Name]" -ForegroundColor Green
        return
    }

    $failures.Add("$Name - expected pattern not found")
}

function Assert-NoMatch {
    param(
        [string] $Name,
        [string] $Text,
        [string] $Pattern
    )

    if (-not [regex]::IsMatch($Text, $Pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)) {
        $script:passes++
        Write-Host "PASS [$Name]" -ForegroundColor Green
        return
    }

    $failures.Add("$Name - forbidden pattern found")
}

function Assert-Count {
    param(
        [string] $Name,
        [string] $Text,
        [string] $Pattern,
        [int] $Expected
    )

    $actual = [regex]::Matches($Text, $Pattern).Count
    if ($actual -eq $Expected) {
        $script:passes++
        Write-Host "PASS [$Name]" -ForegroundColor Green
        return
    }

    $failures.Add("$Name - expected $Expected match(es), found $actual")
}

$shell = Read-Source 'LpMenuShell.razor'
$shellScss = Read-Source 'LpMenuShell.razor.scss'
$hashd = Read-Source 'lpbitcoin\bitcoinhub\code\ui\LpHashdPanel.razor'

Assert-Count 'exactly seven named shell slots' $shell '\[Property\]\s*public\s+(?:RenderFragment\?\s+(?:Mark|TopBarControls)|string\s+Wordmark|List<(?:NavItem|DoorCard|StatRow|QuickButton)>\s+(?:NavItems|DoorCards|SnapshotStats|QuickButtons))\s*\{' 7
Assert-Count 'exactly eight component parameters including accent' $shell '\[Property\]\s*public\s+' 8
Assert-Match 'slot 1 Mark fragment' $shell '\[Property\]\s*public\s+RenderFragment\?\s+Mark\s*\{\s*get;\s*set;\s*\}'
Assert-Match 'slot 2 Wordmark string' $shell '\[Property\]\s*public\s+string\s+Wordmark\s*\{\s*get;\s*set;\s*\}'
Assert-Match 'slot 3 TopBarControls fragment' $shell '\[Property\]\s*public\s+RenderFragment\?\s+TopBarControls\s*\{\s*get;\s*set;\s*\}'
Assert-Match 'slot 4 NavItems list' $shell '\[Property\]\s*public\s+List<NavItem>\s+NavItems\s*\{\s*get;\s*set;\s*\}'
Assert-Match 'slot 5 DoorCards list' $shell '\[Property\]\s*public\s+List<DoorCard>\s+DoorCards\s*\{\s*get;\s*set;\s*\}'
Assert-Match 'slot 6 SnapshotStats list' $shell '\[Property\]\s*public\s+List<StatRow>\s+SnapshotStats\s*\{\s*get;\s*set;\s*\}'
Assert-Match 'slot 7 QuickButtons list' $shell '\[Property\]\s*public\s+List<QuickButton>\s+QuickButtons\s*\{\s*get;\s*set;\s*\}'
Assert-Match 'accent color parameter is separate from seven slots' $shell '\[Property\]\s*public\s+string\s+AccentColor\s*\{\s*get;\s*set;\s*\}'
Assert-Match 'inherited pane content aperture is rendered' $shell '@ChildContent'
Assert-NoMatch 'shell does not hide Panel ChildContent' $shell 'public\s+RenderFragment\?\s+ChildContent\s*\{'

Assert-Match 'shared shell owns sidebar header workspace footer' $shell '<aside\s+class="sidebar">.*<header\s+class="page-header hub-header">.*<div\s+class="workspace-body">.*<LifePunchUiFooter\s+Product="@Wordmark"'
Assert-Match 'settings render in pinned footer rail' $shell '<div\s+class="sidebar-foot">.*Where\(\s*item\s*=>\s*item\.IsSettings\s*\)'
Assert-Match 'dashboard renders door cards' $shell '@foreach\s*\(\s*var\s+card\s+in\s+DoorCards\s*\)'
Assert-Match 'dashboard renders snapshot stats' $shell '@foreach\s*\(\s*var\s+stat\s+in\s+SnapshotStats\s*\)'
Assert-Match 'dashboard renders quick buttons' $shell '@foreach\s*\(\s*var\s+quickButton\s+in\s+QuickButtons\s*\)'
Assert-Match 'status variants are exact' $shell 'enum\s+StatusChipVariant\s*\{\s*Info,\s*Success,\s*Locked,\s*Count\s*\}'
Assert-Match 'door card doctrine fields' $shell 'class\s+DoorCard.*RenderFragment\?\s+Icon.*string\s+Title.*List<StatusChip>\s+Chips.*string\s+Description.*string\s+Label.*string\s+Route.*bool\s+Enabled'
Assert-Match 'shell hash covers all explicit slots' $shell 'BuildHash\(\).*Wordmark.*NavItems.*DoorCards.*SnapshotStats.*QuickButtons'
Assert-Match 'shell hash combines accent token' $shell 'var\s+hash\s*=\s*HashCode\.Combine\([^;]*AccentColor'

Assert-Match 'one shell root owns radius and clipping' $shellScss '\.lp-menu-shell\s*\{(?=[^}]*border-radius:\s*12px;)(?=[^}]*overflow:\s*hidden;)[^}]*\}'
Assert-Match 'shared edge children have zero radius' $shellScss '\.lp-menu-shell\s+\.shell-body,.*\.lp-menu-shell\s+\.lp-window-watermark.*\{[^}]*border-radius:\s*0;'
Assert-NoMatch 'shared nav keeps no-left-strip ruling' $shellScss 'border-left\s*:'
Assert-Match 'shared chrome consumes accent token with parser-safe inline color' $shell 'class="lp-ui-panel-title hub-title"\s+style="color: @AccentColor".*class="ops-eyebrow"\s+style="color: @AccentColor"'
Assert-NoMatch 'accent token avoids unsupported CSS variables' ($shell + $shellScss) '(?:var\(--|--[a-zA-Z][a-zA-Z0-9-]*\s*:)'

Assert-Match 'Bitcoin Ops consumes shared shell' $hashd '<LpMenuShell\b'
Assert-Match 'Bitcoin Ops passes all list slots' $hashd 'NavItems="@ShellNavItems\(\)".*DoorCards="@ShellDoorCards\(\)".*SnapshotStats="@ShellSnapshotStats\(\)".*QuickButtons="@ShellQuickButtons\(\)"'
Assert-Match 'Bitcoin Ops passes its accent token' $hashd 'AccentColor="#e87d3e"'
Assert-Count 'Bitcoin Ops supplies Mark once' $hashd '<Mark>' 1
Assert-Count 'Bitcoin Ops supplies TopBarControls once' $hashd '<TopBarControls>' 1
Assert-NoMatch 'Bitcoin Ops no longer constructs sidebar chrome' $hashd '<aside\s+class="sidebar">'
Assert-NoMatch 'Bitcoin Ops no longer constructs top bar chrome' $hashd '<header\s+class="page-header hub-header">'
Assert-NoMatch 'Bitcoin Ops no longer constructs dashboard chrome' $hashd '<div\s+class="pane overview">'
Assert-Match 'Bitcoin Ops defines nav slot data' $hashd 'private\s+List<LpMenuShell\.NavItem>\s+ShellNavItems\s*\('
Assert-Match 'Bitcoin Ops defines door-card slot data' $hashd 'private\s+List<LpMenuShell\.DoorCard>\s+ShellDoorCards\s*\('
Assert-Match 'Bitcoin Ops defines snapshot slot data' $hashd 'private\s+List<LpMenuShell\.StatRow>\s+ShellSnapshotStats\s*\('
Assert-Match 'Bitcoin Ops defines quick-button slot data' $hashd 'private\s+List<LpMenuShell\.QuickButton>\s+ShellQuickButtons\s*\('

Write-Host "LpMenuShell extraction contracts: $passes passed, $($failures.Count) failed" -ForegroundColor Cyan
if ($failures.Count -gt 0) {
    foreach ($failure in $failures) {
        Write-Host "FAIL [$failure]" -ForegroundColor Red
    }
    exit 1
}

exit 0
