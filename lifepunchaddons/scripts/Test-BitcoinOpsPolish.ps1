<#
.SYNOPSIS
  Verify the source contracts for the Bitcoin Ops polish pass.
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

$hashd = Read-Source 'lpbitcoin\bitcoinhub\code\ui\LpHashdPanel.razor'
$menuShell = Read-Source 'LpMenuShell.razor'
$bitcoinOpsMarkup = $hashd + [Environment]::NewLine + $menuShell
$hashdScss = Read-Source 'lpbitcoin\bitcoinhub\code\ui\LpHashdPanel.razor.scss'
$shellScss = Read-Source 'LifePunchUiShell.scss'
$token = Read-Source 'LifePunchCurrencyToken.razor'
$tokenScss = Read-Source 'LifePunchCurrencyToken.razor.scss'
$footer = Read-Source 'LifePunchUiFooter.razor'
$footerScss = Read-Source 'LifePunchUiFooter.razor.scss'
$staff = Read-Source 'adminmenu\StaffMenu.razor'
$hackerTerminal = Read-Source 'hackerjob\HackerTerminal.razor'
$hackerRack = Read-Source 'hackerjob\HackerServerRackMenu.razor'
$visiblePocket = Read-Source 'visiblepocket\VisiblePocketHud.razor'
$visiblePocketScss = Read-Source 'visiblepocket\VisiblePocketHud.razor.scss'
$bitcoinTerminal = Read-Source 'bitcoinmining\LpBitcoinTerminalPanel.razor'
$playerHub = Read-Source 'playerhub\code\ui\LpPlayerHubRoot.razor'

Assert-Match 'A shared token API' $token 'public\s+string\s+Sign\s*\{\s*get;\s*set;\s*\}.*public\s+string\s+Amount\s*\{\s*get;\s*set;\s*\}.*public\s+string\s+Label\s*\{\s*get;\s*set;\s*\}.*public\s+string\s+SignClass\s*\{\s*get;\s*set;\s*\}.*public\s+string\s+TokenClass\s*\{\s*get;\s*set;\s*\}'
Assert-Match 'A token sign and amount spans' $token '<span\s+class="@SignClass">@Sign</span>\s*<span\s+class="lp-money-amt">@Amount</span>'
Assert-Match 'A optional label spacing' $tokenScss '\.lp-currency-label\s*\{[^}]*margin-left:\s*4px;'
Assert-Match 'A dynamic token rebuild hash' $token 'protected\s+override\s+int\s+BuildHash\(\)\s*=>\s*HashCode\.Combine\(\s*Sign,\s*Amount,\s*Label,\s*SignClass,\s*TokenClass\s*\);'
Assert-Count 'A all seven ruled token instances' $bitcoinOpsMarkup '<LifePunchCurrencyToken\b' 7
Assert-Match 'A1 invested token' $hashd 'TokenClass="entity-invested-token"'
Assert-Match 'A2 buffer current token' $hashd 'TokenClass="server-buffer-current"'
Assert-Match 'A2 buffer capacity token' $hashd 'TokenClass="server-buffer-capacity"'
Assert-Match 'A3 estimated value token' $menuShell 'TokenClass="overview-wallet-value"'
Assert-Match 'A4 bank rate token' $hashd 'TokenClass="transfers-rate-bank"'
Assert-Match 'A5 rack balance token' $hashd 'TokenClass="transfers-rack-balance"'
Assert-Match 'A6 tight header token' $hashd 'TokenClass="header-wallet-token"'

Assert-Match 'B1 root owns radius and clipping' $hashdScss '\.lp-bitcoin-ops\s+\.shell\s*\{(?=[^}]*border-radius:\s*\$ops-card-radius;)(?=[^}]*overflow:\s*hidden;)[^}]*\}'
Assert-Match 'B1 edge children have zero radius' $hashdScss '\.lp-bitcoin-ops\s+\.shell-body,\s*\.lp-bitcoin-ops\s+\.pin-gate,\s*\.lp-bitcoin-ops\s+\.pin-header,\s*\.lp-bitcoin-ops\s+\.hub-body,\s*\.lp-bitcoin-ops\s+\.hub-main,\s*\.lp-bitcoin-ops\s+\.sidebar,\s*\.lp-bitcoin-ops\s+\.workspace,\s*\.lp-bitcoin-ops\s+\.hub-header,\s*\.lp-bitcoin-ops\s+\.lp-window-watermark,\s*\.lp-bitcoin-ops\s+\.lp-window-watermark\s+\.lp-source-footer\s*\{[^}]*border-radius:\s*0;'
Assert-Match 'B2 fixed action rail' $hashdScss '\.lp-bitcoin-ops\s+\.overview-checklist-action-group\s*\{[^}]*justify-content:\s*center;[^}]*width:\s*156px;'
Assert-Match 'B2 direct actions match rail width' $hashdScss '\.lp-bitcoin-ops\s+\.overview-checklist-action\s*\{[^}]*width:\s*156px;'
Assert-Match 'B3 shared callouts align left' $shellScss '\.lp-ui-intro\s*\{[^}]*text-align:\s*left;'
Assert-NoMatch 'B3 panel callout text overrides do not center' $hashdScss '\.lp-bitcoin-ops[^\{]*\.lp-ui-intro[^\{]*\{[^}]*text-align:\s*center;'
Assert-NoMatch 'B3 flex callout overrides do not center content' $hashdScss '\.lp-bitcoin-ops[^\{]*\.lp-ui-intro[^\{]*\{[^}]*justify-content:\s*center;'
Assert-NoMatch 'Razor rack-track declaration stays in code context' $hashd '@\{\s*var\s+rackTracks\s*='

Assert-Match 'C1 pane title says Dashboard' $bitcoinOpsMarkup 'PageTitle\s*=\s*tab\s*==\s*OpsTab\.Overview\s*\?\s*"Dashboard".*<span>@activeItem\.PageTitle</span>'
Assert-Match 'C1 missing-link copy says Dashboard' $hashd 'link on Dashboard'
Assert-NoMatch 'C1 visible Overview title removed' $hashd '<span>Overview</span>'
Assert-NoMatch 'C1 visible Overview link copy removed' $hashd 'link on Overview'
Assert-Match 'C4 state helper is ON or OFF' $hashd 'private\s+string\s+HubPowerStateLabel\(\)\s*=>\s*Hub\?\.IsPowered\s*==\s*true\s*\?\s*"ON"\s*:\s*"OFF";'
Assert-Count 'C4 state appears in header and Settings' $hashd '@HubPowerStateLabel\(\)' 2
Assert-NoMatch 'C4 POWER-prefixed toggle labels removed' $hashd '"POWER ON"\s*:\s*"POWER OFF"'

Assert-Match 'D1 footer accepts product identity' $footer 'public\s+string\s+Product\s*\{\s*get;\s*set;\s*\}'
Assert-Match 'D1 footer carries proprietary label' $footer '>proprietary IP</span>'
Assert-Match 'D1 footer displays publisher host' $footer 'LifePunchSourceMark\.PublisherUrl'
Assert-Match 'D1 footer copies canonical URL' $footer 'Clipboard\.SetText\(\s*LifePunchSourceMark\.UiFooterUrl\s*\)'
Assert-Match 'D1 footer identity remains flexible' $footerScss '\.lp-footer-identity\s*\{[^}]*flex:\s*1\s+1\s+auto;[^}]*min-width:\s*0;'
Assert-Match 'D1 Staff Menu product' $staff '<LifePunchUiFooter\s+Product="ULX Console"\s*/>'
Assert-Match 'D1 Hacker Terminal product' $hackerTerminal '<LifePunchUiFooter\s+Product="Hacker Terminal"\s*/>'
Assert-Match 'D1 Hacker Rack product' $hackerRack '<LifePunchUiFooter\s+Product="Server Rack Control"\s*/>'
Assert-Match 'D1 Visible Pocket product' $visiblePocket '<LifePunchUiFooter\s+Product="Visible Pocket"\s*/>'
Assert-Match 'D1 Visible Pocket footer accepts pointer input' $visiblePocketScss '\.pocket-bar\s*\{[^}]*pointer-events:\s*all;'
Assert-Match 'D1 Bitcoin Terminal shared footer' $bitcoinTerminal '<LifePunchUiFooter\s+Product="Bitcoin Terminal"\s*/>'
Assert-NoMatch 'D1 Bitcoin Terminal duplicate copy state removed' $bitcoinTerminal '_urlCopied|CopySourceUrl|RevertCopyLabel'
Assert-Match 'D1 Bitcoin Ops base footer' $hashd '<LifePunchUiFooter\s+Product="Bitcoin Ops"\s*/>'
Assert-NoMatch 'D1 Bitcoin Ops duplicate footnote removed' $hashd 'settings-footnote-credit'
Assert-Match 'D1 Player Hub base footer' $playerHub '<LifePunchUiFooter\s+Product="Player Hub"\s*/>'

Write-Host "Bitcoin Ops polish contracts: $passes passed, $($failures.Count) failed" -ForegroundColor Cyan
if ($failures.Count -gt 0) {
    foreach ($failure in $failures) {
        Write-Host "FAIL [$failure]" -ForegroundColor Red
    }
    exit 1
}

exit 0
