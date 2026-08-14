<#
.SYNOPSIS
  Static compatibility gate for the fixture-backed Player Hub Slices 1-5.

.DESCRIPTION
  This is intentionally narrower than an editor compile. It catches the
  Blackbox scaffold defects that are deterministic from source: Blazor-only
  component APIs, malformed SCSS variables, unsupported layout syntax,
  unresolved scaffold properties, an unmounted tab host, and accidental
  transaction seams. Runtime acceptance still requires a fresh s&box compile
  and render proof through CAVELUX.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$playerHubRoot = (Resolve-Path (Join-Path $here '..\Code\Addons\lifepunch\playerhub')).Path
$uiRoot = Join-Path $playerHubRoot 'code\ui'
$modelPath = Join-Path $playerHubRoot 'code\data\LpPlayerHubModels.cs'
$rootPath = Join-Path $uiRoot 'LpPlayerHubRoot.razor'
$rootScssPath = Join-Path $uiRoot 'LpPlayerHubRoot.razor.scss'
$tokenPath = Join-Path $uiRoot 'LpPlayerHubTokens.scss'
$findings = [System.Collections.Generic.List[string]]::new()

function Add-Finding {
    param(
        [string] $File,
        [int] $Line,
        [string] $Rule,
        [string] $Text
    )

    $relative = $File.Substring($playerHubRoot.Length).TrimStart('\')
    [void] $findings.Add(('{0}:{1} [{2}] {3}' -f $relative, $Line, $Rule, $Text.Trim()))
}

function Add-TextMatches {
    param(
        [System.IO.FileInfo] $File,
        [string] $Pattern,
        [string] $Rule
    )

    $lineNumber = 0
    foreach ($line in Get-Content -LiteralPath $File.FullName) {
        $lineNumber++
        if ($line -match $Pattern) {
            Add-Finding -File $File.FullName -Line $lineNumber -Rule $Rule -Text $line
        }
    }
}

if (-not (Test-Path -LiteralPath $modelPath)) {
    throw "Player Hub model file not found: $modelPath"
}

if (-not (Test-Path -LiteralPath $rootPath)) {
    throw "Player Hub root component not found: $rootPath"
}

$razorFiles = @(Get-ChildItem -LiteralPath $uiRoot -Recurse -Filter '*.razor' -File)
$scssFiles = @(Get-ChildItem -LiteralPath $uiRoot -Recurse -Filter '*.razor.scss' -File)

foreach ($file in $razorFiles) {
    Add-TextMatches -File $file -Pattern '\[Parameter\]' -Rule 'sbox-property'
    Add-TextMatches -File $file -Pattern '\bEventCallback(?:\s*<|\b)' -Rule 'blazor-callback'
    Add-TextMatches -File $file -Pattern '@\([^\r\n]*\)\s*@\(' -Rule 'adjacent-razor-expression'
	Add-TextMatches -File $file -Pattern '\s/\s+@' -Rule 'razor-separator-law'
    Add-TextMatches -File $file -Pattern '\bModel\.ActiveTab\b' -Rule 'unresolved-active-tab'
    Add-TextMatches -File $file -Pattern '\bThumbnailUrl\b' -Rule 'unapproved-store-field'
    Add-TextMatches -File $file -Pattern '\bModel\.Price\b' -Rule 'wrong-store-price-field'
    Add-TextMatches -File $file -Pattern '\bitem\.Price\b' -Rule 'wrong-store-price-field'
    Add-TextMatches -File $file -Pattern '\bNavigateTo\s*\(' -Rule 'undefined-navigation'

    $text = Get-Content -Raw -LiteralPath $file.FullName
    if ($file.FullName -eq $rootPath) {
        if ($text -notmatch '@inherits\s+PanelComponent\b') {
            [void] $findings.Add('code\ui\LpPlayerHubRoot.razor:1 [root-type] Root must inherit PanelComponent.')
        }
    }
    elseif ($text -notmatch '@inherits\s+Panel\b') {
        Add-Finding -File $file.FullName -Line 1 -Rule 'child-type' -Text 'Mounted child must inherit Panel.'
    }

    if ($file.FullName -ne $rootPath -and $text -match '@inherits\s+PanelComponent\b') {
        Add-Finding -File $file.FullName -Line 1 -Rule 'nested-panel-component' -Text 'Only the root may inherit PanelComponent.'
    }

    if ($file.FullName -ne $rootPath -and $text -match 'override\s+void\s+On(?:Enabled|Disabled)\s*\(') {
        Add-Finding -File $file.FullName -Line 1 -Rule 'child-lifecycle' -Text 'Child Panel cannot own component lifecycle hooks.'
    }

    if ($file.FullName -ne $rootPath -and $text -match '\bLifePunchMenuInputBlock\b') {
        Add-Finding -File $file.FullName -Line 1 -Rule 'child-input-block' -Text 'Root exclusively owns menu input-block registration.'
    }
}

$forbiddenScss = @(
    @{ Name = 'escaped-scss-variable'; Pattern = '\\\$' },
    @{ Name = 'css-grid'; Pattern = 'display\s*:\s*grid\b|\bgrid-(?:template|column|row|area|gap)\b' },
    @{ Name = 'inline-flex'; Pattern = 'display\s*:\s*inline-flex\b' },
    @{ Name = 'web-display-mode'; Pattern = 'display\s*:\s*(?:block|none|inline|inline-block)\b' },
    @{ Name = 'media-query'; Pattern = '@media\b' },
    @{ Name = 'gradient'; Pattern = '(?:linear|radial|conic)-gradient\s*\(' },
	@{ Name = 'raw-two-pixel-radius'; Pattern = 'border-radius\s*:\s*2px\b' },
	@{ Name = 'font-without-fallback'; Pattern = 'font-family\s*:\s*(?:Inter|Poppins)\s*;' }
)

foreach ($file in $scssFiles) {
    foreach ($rule in $forbiddenScss) {
        Add-TextMatches -File $file -Pattern $rule.Pattern -Rule $rule.Name
    }

    if ($file.FullName -ne $rootScssPath) {
        Add-TextMatches -File $file -Pattern '#[0-9a-fA-F]{3,8}\b' -Rule 'raw-component-color'
    }
}

if (-not (Test-Path -LiteralPath $tokenPath)) {
    [void] $findings.Add('code\ui\LpPlayerHubTokens.scss:1 [token-surface] Missing shared Player Hub token partial.')
}
else {
    $tokenText = Get-Content -Raw -LiteralPath $tokenPath
    $definedTokens = @{}
    foreach ($match in [regex]::Matches($tokenText, '(?m)^\s*(\$[A-Za-z0-9_-]+)\s*:')) {
        $definedTokens[$match.Groups[1].Value] = $true
    }

    foreach ($file in $scssFiles) {
        $scssText = Get-Content -Raw -LiteralPath $file.FullName
        foreach ($match in [regex]::Matches($scssText, '\$[A-Za-z0-9_-]+')) {
            if (-not $definedTokens.ContainsKey($match.Value)) {
                Add-Finding -File $file.FullName -Line 1 -Rule 'undefined-token' -Text $match.Value
            }
        }
    }
}

$sharedStyleContracts = @(
    @{ Path = 'Shared\LpPlayerHubEmpty.razor.scss'; Selectors = @('.hub-state-icon', '.hub-state-title', '.hub-state-message', '.hub-state-action') },
    @{ Path = 'Shared\LpPlayerHubError.razor.scss'; Selectors = @('.hub-state-icon', '.hub-state-title', '.hub-state-message', '.hub-state-action') }
)

foreach ($contract in $sharedStyleContracts) {
    $stylePath = Join-Path $uiRoot $contract.Path
    if (-not (Test-Path -LiteralPath $stylePath)) {
        [void] $findings.Add(('code\ui\{0}:1 [shared-state-style] Missing shared state stylesheet.' -f $contract.Path))
        continue
    }

    $styleText = Get-Content -Raw -LiteralPath $stylePath
    foreach ($selector in $contract.Selectors) {
        if ($styleText -notmatch [regex]::Escape($selector)) {
            [void] $findings.Add(('code\ui\{0}:1 [shared-state-style] Missing selector {1}.' -f $contract.Path, $selector))
        }
    }
}

$allRazorText = ($razorFiles | ForEach-Object { Get-Content -Raw -LiteralPath $_.FullName }) -join "`n"
foreach ($sharedComponent in @('LpPlayerHubEmpty', 'LpPlayerHubError')) {
	$callCount = [regex]::Matches($allRazorText, ('<' + $sharedComponent + '\b')).Count
	if ($callCount -eq 0) {
		[void] $findings.Add(('code\ui:1 [shared-state-callsite] Missing <{0}> use for absent or invalid input.' -f $sharedComponent))
	}
}

$rootText = Get-Content -Raw -LiteralPath $rootPath
$rootScssText = Get-Content -Raw -LiteralPath $rootScssPath
$requiredMounts = @(
    'LpPlayerHubOverview',
    'LpPlayerHubStats',
    'LpPlayerHubSkills',
    'LpPlayerHubStore'
)

foreach ($component in $requiredMounts) {
    if ($rootText -notmatch ('<' + [regex]::Escape($component) + '\b')) {
        [void] $findings.Add(('code\ui\LpPlayerHubRoot.razor:1 [tab-mount] Missing <{0}> mount.' -f $component))
    }
}

if ($rootText -match 'hub-placeholder|PlaceholderTitle|PlaceholderBody') {
    [void] $findings.Add('code\ui\LpPlayerHubRoot.razor:1 [slice1-placeholder] Slice 1 placeholder still owns the tab host.')
}

if ($rootText -notmatch 'LP_PLAYERHUB_SLICES1_5_FIXTURE_20260722') {
    [void] $findings.Add('code\ui\LpPlayerHubRoot.razor:1 [positive-marker] Missing Slices 1-5 positive compiler marker.')
}

if ($rootText -notmatch 'LifePunchUiScrollPolicy\.Apply\s*\(\s*Panel\s*\)') {
    [void] $findings.Add('code\ui\LpPlayerHubRoot.razor:1 [scroll-policy] Root must apply the Razor-owned scroll policy.')
}

if ($rootScssText -notmatch '\.lp-playerhub\s+\.material-icons\s*\{' -or $rootScssText -notmatch 'font-family\s*:\s*Material Icons\s*;') {
	[void] $findings.Add('code\ui\LpPlayerHubRoot.razor.scss:1 [material-icon-font] Root must reset inherited body fonts for Material Icons ligatures.')
}

$confirmPath = Join-Path $uiRoot 'Shared\LpPlayerHubConfirm.razor'
$confirmScssPath = Join-Path $uiRoot 'Shared\LpPlayerHubConfirm.razor.scss'
if ((Test-Path -LiteralPath $confirmPath) -or (Test-Path -LiteralPath $confirmScssPath)) {
    [void] $findings.Add('code\ui\Shared\LpPlayerHubConfirm:1 [slice6-gate] Confirm belongs to Slice 6 and must not ship in this candidate.')
}

$modelText = Get-Content -Raw -LiteralPath $modelPath
$requiredModelTokens = @(
    'LpOverviewVm',
    'LpEarnRouteVm',
    'LpStatsVm',
    'LpSkillsVm',
    'LpStoreVm'
)

foreach ($token in $requiredModelTokens) {
    if ($modelText -notmatch ('\b' + [regex]::Escape($token) + '\b')) {
        [void] $findings.Add(('code\data\LpPlayerHubModels.cs:1 [fixture-contract] Missing {0}.' -f $token))
    }
}

$fixtureMethods = @('Overview', 'Stats', 'Skills', 'Store')
foreach ($method in $fixtureMethods) {
    if ($modelText -notmatch ('\b' + $method + '\s*\(')) {
        [void] $findings.Add(('code\data\LpPlayerHubModels.cs:1 [fixture-factory] Missing {0}(...) fixture factory.' -f $method))
    }
}

$storePath = Join-Path $uiRoot 'Store\LpPlayerHubStore.razor'
if (Test-Path -LiteralPath $storePath) {
    $storeText = Get-Content -Raw -LiteralPath $storePath
    $transactionPatterns = @(
        '\bOnItemPurchase\b',
        '\bTryPurchase\b',
        '\bPurchaseAsync\b',
        '\bRpc\.',
        '\bInventory\.'
    )

    foreach ($pattern in $transactionPatterns) {
        if ($storeText -match $pattern) {
            [void] $findings.Add(('code\ui\Store\LpPlayerHubStore.razor:1 [slice6-gate] Transaction seam matched {0}.' -f $pattern))
        }
    }
}

$skillsPath = Join-Path $uiRoot 'Skills\LpPlayerHubSkills.razor'
if (Test-Path -LiteralPath $skillsPath) {
    $skillsText = Get-Content -Raw -LiteralPath $skillsPath
    $mutationPatterns = @('\bTryUnlock\b', '\bSpendSkill', '\bRpc\.')
    foreach ($pattern in $mutationPatterns) {
        if ($skillsText -match $pattern) {
            [void] $findings.Add(('code\ui\Skills\LpPlayerHubSkills.razor:1 [slice7-gate] Mutation seam matched {0}.' -f $pattern))
        }
    }
}

Write-Host "Player Hub s&box contract: $playerHubRoot" -ForegroundColor Cyan
Write-Host "Razor files: $($razorFiles.Count); SCSS files: $($scssFiles.Count)" -ForegroundColor DarkGray

if ($findings.Count -gt 0) {
    foreach ($finding in $findings) {
        Write-Host $finding -ForegroundColor Red
    }

    Write-Host ("FAIL - {0} contract finding(s)." -f $findings.Count) -ForegroundColor Red
    exit 1
}

Write-Host 'PASS - Player Hub static s&box compatibility contract is clean.' -ForegroundColor Green
exit 0
