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
$catalogPath = Join-Path $playerHubRoot 'code\data\LpPlayerHubCatalog.cs'
$hostPath = Join-Path $uiRoot 'LpPlayerHubHost.cs'
$statsPath = Join-Path $uiRoot 'Stats\LpPlayerHubStats.razor'
$statsScssPath = Join-Path $uiRoot 'Stats\LpPlayerHubStats.razor.scss'
$skillsPath = Join-Path $uiRoot 'Skills\LpPlayerHubSkills.razor'
$skillsScssPath = Join-Path $uiRoot 'Skills\LpPlayerHubSkills.razor.scss'
$rootPath = Join-Path $uiRoot 'LpPlayerHubRoot.razor'
$rootScssPath = Join-Path $uiRoot 'LpPlayerHubRoot.razor.scss'
$tokenPath = Join-Path $uiRoot 'LpPlayerHubTokens.scss'
$findings = [System.Collections.Generic.List[string]]::new()
$contractAssertions = 0
$catalogTrackCount = 0
$catalogSkillCount = 0
$catalogTierCount = 0

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

function Assert-Contract {
    param(
        [bool] $Condition,
        [string] $File,
        [string] $Rule,
        [string] $Message
    )

    $script:contractAssertions++
    if (-not $Condition) {
        [void] $findings.Add(('{0}:1 [{1}] {2}' -f $File, $Rule, $Message))
    }
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
$hostText = Get-Content -Raw -LiteralPath $hostPath
$statsText = Get-Content -Raw -LiteralPath $statsPath
$statsScssText = Get-Content -Raw -LiteralPath $statsScssPath
$skillsText = Get-Content -Raw -LiteralPath $skillsPath
$skillsScssText = Get-Content -Raw -LiteralPath $skillsScssPath

$catalogExists = Test-Path -LiteralPath $catalogPath
Assert-Contract -Condition $catalogExists `
    -File 'code\data\LpPlayerHubCatalog.cs' `
    -Rule 'catalog-file' `
    -Message 'Missing the fixture-v0 Player Hub catalog.'

$catalogText = if ($catalogExists) {
    Get-Content -Raw -LiteralPath $catalogPath
}
else {
    ''
}

$expectedTracks = @(
    [pscustomobject]@{ Id = 'resilience'; Label = 'Resilience' },
    [pscustomobject]@{ Id = 'recovery'; Label = 'Recovery' },
    [pscustomobject]@{ Id = 'enterprise'; Label = 'Enterprise' },
    [pscustomobject]@{ Id = 'infiltration'; Label = 'Infiltration' },
    [pscustomobject]@{ Id = 'enforcement'; Label = 'Enforcement' }
)

$expectedSkills = [System.Collections.Generic.List[object]]::new()
foreach ($track in $expectedTracks) {
    foreach ($slot in 1..5) {
        [void] $expectedSkills.Add([pscustomobject]@{
            Id = ('{0}-slot-{1}' -f $track.Id, $slot)
            TrackId = $track.Id
            Title = ('Catalogue Slot {0}' -f $slot)
        })
    }
}

$singleline = [System.Text.RegularExpressions.RegexOptions]::Singleline
$trackMatches = [regex]::Matches(
    $catalogText,
    'CreateTrack\s*\(\s*id:\s*"(?<id>[^"]+)"\s*,\s*label:\s*"(?<label>[^"]+)"',
    $singleline
)
$skillMatches = [regex]::Matches(
    $catalogText,
    'CreateSkill\s*\(\s*id:\s*"(?<id>[^"]+)"\s*,\s*trackId:\s*"(?<track>[^"]+)"\s*,\s*title:\s*"(?<title>[^"]+)"',
    $singleline
)
$tierMatches = [regex]::Matches(
    $catalogText,
    'new\s+LpPlayerHubCatalogTier\s*\(\s*Rank:\s*(?<rank>[1-5])\s*,\s*Label:\s*"(?<label>I|II|III|IV|V)"\s*,\s*State:\s*TierPendingState\s*,\s*EffectState:\s*OwnerHeldState\s*\)',
    $singleline
)

$catalogTrackCount = $trackMatches.Count
$catalogSkillCount = $skillMatches.Count
$catalogTierCount = $catalogSkillCount * $tierMatches.Count

Assert-Contract -Condition ($catalogText -match 'public\s+const\s+string\s+Version\s*=\s*"fixture-v0"\s*;') `
    -File 'code\data\LpPlayerHubCatalog.cs' `
    -Rule 'catalog-version' `
    -Message 'Catalog version must be fixture-v0.'

Assert-Contract -Condition ($catalogTrackCount -eq 5) `
    -File 'code\data\LpPlayerHubCatalog.cs' `
    -Rule 'catalog-track-count' `
    -Message ('Expected 5 catalog tracks; found {0}.' -f $catalogTrackCount)

$actualTrackRows = @($trackMatches | ForEach-Object {
    '{0}|{1}' -f $_.Groups['id'].Value, $_.Groups['label'].Value
})
$expectedTrackRows = @($expectedTracks | ForEach-Object { '{0}|{1}' -f $_.Id, $_.Label })
Assert-Contract -Condition (($actualTrackRows -join "`n") -ceq ($expectedTrackRows -join "`n")) `
    -File 'code\data\LpPlayerHubCatalog.cs' `
    -Rule 'catalog-track-order' `
    -Message 'Catalog tracks must retain the approved IDs, names, and order.'

Assert-Contract -Condition ($catalogSkillCount -eq 25) `
    -File 'code\data\LpPlayerHubCatalog.cs' `
    -Rule 'catalog-skill-count' `
    -Message ('Expected 25 catalog skills; found {0}.' -f $catalogSkillCount)

$actualSkillRows = @($skillMatches | ForEach-Object {
    '{0}|{1}|{2}' -f $_.Groups['id'].Value, $_.Groups['track'].Value, $_.Groups['title'].Value
})
$expectedSkillRows = @($expectedSkills | ForEach-Object { '{0}|{1}|{2}' -f $_.Id, $_.TrackId, $_.Title })
Assert-Contract -Condition (($actualSkillRows -join "`n") -ceq ($expectedSkillRows -join "`n")) `
    -File 'code\data\LpPlayerHubCatalog.cs' `
    -Rule 'catalog-skill-matrix' `
    -Message 'Catalog skill IDs, track ownership, titles, or ordering drifted from the 25-row fixture matrix.'

$duplicateSkillIds = @(
    $skillMatches |
        ForEach-Object { $_.Groups['id'].Value } |
        Group-Object |
        Where-Object Count -gt 1
)
Assert-Contract -Condition ($duplicateSkillIds.Count -eq 0) `
    -File 'code\data\LpPlayerHubCatalog.cs' `
    -Rule 'catalog-stable-id-unique' `
    -Message 'Catalog stable IDs must be unique.'

$actualTierRows = @($tierMatches | ForEach-Object {
    '{0}|{1}' -f $_.Groups['rank'].Value, $_.Groups['label'].Value
})
$expectedTierRows = @('1|I', '2|II', '3|III', '4|IV', '5|V')
Assert-Contract -Condition (($actualTierRows -join "`n") -ceq ($expectedTierRows -join "`n")) `
    -File 'code\data\LpPlayerHubCatalog.cs' `
    -Rule 'catalog-tier-order' `
    -Message 'Every skill must receive the ordered I-V pending tier template.'

Assert-Contract -Condition ($catalogTierCount -eq 125) `
    -File 'code\data\LpPlayerHubCatalog.cs' `
    -Rule 'catalog-tier-count' `
    -Message ('Expected 125 ordered catalog tiers; found {0}.' -f $catalogTierCount)

$catalogStatePatterns = @(
    'public\s+const\s+string\s+TierPendingState\s*=\s*"pending"\s*;',
    'public\s+const\s+string\s+KeystonePlaceholderState\s*=\s*"placeholder"\s*;',
    'public\s+const\s+string\s+SeamUnmappedState\s*=\s*"unmapped"\s*;',
    'public\s+const\s+string\s+OwnerHeldState\s*=\s*"HELD-ruling-7"\s*;',
    'Tiers:\s*PendingTiers\s*\(\s*\)',
    'EffectState:\s*OwnerHeldState',
    'CategoryCapState:\s*OwnerHeldState',
    'SeamState:\s*SeamUnmappedState',
    'OwnerState:\s*OwnerHeldState'
)
foreach ($pattern in $catalogStatePatterns) {
    Assert-Contract -Condition ($catalogText -match $pattern) `
        -File 'code\data\LpPlayerHubCatalog.cs' `
        -Rule 'catalog-held-state' `
        -Message ('Missing fixture-held catalog state contract: {0}' -f $pattern)
}

Assert-Contract -Condition (
    $catalogText -match 'Title:\s*"Keystone"' -and
    $catalogText -match 'State:\s*KeystonePlaceholderState' -and
    $catalogText -match 'EffectState:\s*OwnerHeldState' -and
    $catalogText -match 'SeamState:\s*SeamUnmappedState' -and
    $catalogText -match 'OwnerState:\s*OwnerHeldState'
) `
    -File 'code\data\LpPlayerHubCatalog.cs' `
    -Rule 'catalog-keystone-placeholder' `
    -Message 'Tracks must carry an owner-held keystone placeholder.'

Assert-Contract -Condition (
    $catalogText -match 'MaxHealthContractNote\s*=\s*"MaxHealth is \[Property\]; no host-sync contract exists\."\s*;'
) `
    -File 'code\data\LpPlayerHubCatalog.cs' `
    -Rule 'max-health-contract' `
    -Message 'MaxHealth must be documented as a Property with no host-sync assumption.'

Assert-Contract -Condition (
    $modelText -match '\bLpPlayerHubCatalog\.Tracks\b' -and
    $modelText -match '\bLpPlayerHubCatalog\.Version\b' -and
    $modelText -notmatch '\bAddTrackSkills\b|\bBuildSkillTiers\b'
) `
    -File 'code\data\LpPlayerHubModels.cs' `
    -Rule 'catalog-consumer' `
    -Message 'Fixture models must project the shared catalog rather than regenerate tracks and tiers.'

Assert-Contract -Condition ($skillsText -match '\bModel\.CatalogVersion\b') `
    -File 'code\ui\Skills\LpPlayerHubSkills.razor' `
    -Rule 'catalog-consumer' `
    -Message 'Skills must expose the projected catalog version.'

Assert-Contract -Condition (
    $skillsText -match 'private\s+const\s+bool\s+UnlockEnabled\s*=\s*false\s*;' -and
    $skillsText -match '<button\s+class="skills-unlock"\s+disabled="@\(!UnlockEnabled\)"\s*>' -and
    $skillsText -notmatch '<button\s+class="skills-unlock"[^>]*\bonclick\s*=' -and
    $modelText -match 'CanUnlock:\s*false'
) `
    -File 'code\ui\Skills\LpPlayerHubSkills.razor' `
    -Rule 'catalog-disabled-state' `
    -Message 'Fixture unlock controls must remain explicitly disabled and non-mutating.'

Assert-Contract -Condition ($catalogText -notmatch '\bRpc\.|\[\s*Sync\b|\bSpend(?:Skill)?\b|\bPersistence\b') `
    -File 'code\data\LpPlayerHubCatalog.cs' `
    -Rule 'catalog-no-live-seam' `
    -Message 'The fixture catalog cannot introduce RPC, synchronization, spending, or persistence code.'

$batch1WallPaths = @(
    $modelPath,
    $catalogPath,
    $skillsPath,
    $skillsScssPath,
    $PSCommandPath
)
$batch1WallText = @(
    $batch1WallPaths |
        Where-Object { Test-Path -LiteralPath $_ } |
        ForEach-Object { Get-Content -Raw -LiteralPath $_ }
) -join "`n"

$deadBreachCooldownToken = ('DoorBreach' + 'UseCooldown')
Assert-Contract -Condition ($batch1WallText -notmatch [regex]::Escape($deadBreachCooldownToken)) `
    -File 'code\data\LpPlayerHubCatalog.cs' `
    -Rule 'dead-breach-cooldown-absent' `
    -Message 'The dead breach cooldown token must be absent from the complete Batch-1 wall.'

$syncAttributePattern = ('\[' + 'Sync' + '(?:\s*\([^]]*\))?\][^\r\n]*MaxHealth|MaxHealth[^\r\n]*\[' + 'Sync')
Assert-Contract -Condition ($batch1WallText -notmatch $syncAttributePattern) `
    -File 'code\data\LpPlayerHubCatalog.cs' `
    -Rule 'max-health-not-synchronized' `
    -Message 'No Batch-1 file may describe MaxHealth as synchronized.'

# Batch 2 additions. The preceding 28 assertions are intentionally retained
# verbatim; this block only strengthens the existing contract gate.
$batch2OverlapPreEditSha256 = '359CDBA3E3D2B4ACE444AD8D09E0009D71CD3A6B5A62AC24738642DA57CF13C9'
$progressionRoot = Join-Path $playerHubRoot 'code\progression'
$progressionDomainPath = Join-Path $progressionRoot 'LpPlayerHubProgression.cs'
$progressionStorePath = Join-Path $progressionRoot 'LpPlayerHubProgressionStore.cs'
$progressionHostPath = Join-Path $progressionRoot 'LpPlayerHubProgressionHost.cs'
$progressionHarnessPath = Join-Path $here 'Test-PlayerHubProgression.ps1'
$batch2Paths = @(
    $progressionDomainPath,
    $progressionStorePath,
    $progressionHostPath,
    $progressionHarnessPath
)

Assert-Contract -Condition ($batch2OverlapPreEditSha256 -ceq '359CDBA3E3D2B4ACE444AD8D09E0009D71CD3A6B5A62AC24738642DA57CF13C9') `
    -File '..\..\..\scripts\Test-PlayerHubSboxContracts.ps1' `
    -Rule 'batch2-overlap-prehash' `
    -Message 'Batch-2 overlap pre-edit hash evidence drifted.'

Assert-Contract -Condition (@($batch2Paths | Where-Object { -not (Test-Path -LiteralPath $_) }).Count -eq 0) `
    -File 'code\progression' `
    -Rule 'batch2-files' `
    -Message 'One or more approved Batch-2 production/harness files are missing.'

$progressionDomainText = if (Test-Path -LiteralPath $progressionDomainPath) {
    Get-Content -Raw -LiteralPath $progressionDomainPath
}
else {
    ''
}
$progressionStoreText = if (Test-Path -LiteralPath $progressionStorePath) {
    Get-Content -Raw -LiteralPath $progressionStorePath
}
else {
    ''
}
$progressionHostText = if (Test-Path -LiteralPath $progressionHostPath) {
    Get-Content -Raw -LiteralPath $progressionHostPath
}
else {
    ''
}
$progressionHarnessText = if (Test-Path -LiteralPath $progressionHarnessPath) {
    Get-Content -Raw -LiteralPath $progressionHarnessPath
}
else {
    ''
}
$batch2ProductionText = @(
    $progressionDomainText,
    $progressionStoreText,
    $progressionHostText
) -join "`n"

$catalogSkillConstructors = [regex]::Matches(
    $catalogText,
    'new\s+LpPlayerHubCatalogSkill\s*\(',
    $singleline
).Count
$catalogSkillFactoryOwnsTiers = $catalogText -match (
    'private\s+static\s+LpPlayerHubCatalogSkill\s+CreateSkill\s*\(' +
    '[\s\S]*?return\s+new\s+LpPlayerHubCatalogSkill\s*\(' +
    '[\s\S]*?Tiers:\s*PendingTiers\s*\(\s*\)'
)
Assert-Contract -Condition (
    $catalogSkillCount -eq 25 -and
    $catalogSkillConstructors -eq 1 -and
    $catalogSkillFactoryOwnsTiers
) `
    -File 'code\data\LpPlayerHubCatalog.cs' `
    -Rule 'catalog-per-skill-tier-structure' `
    -Message 'Every one of the 25 skills must flow through the sole factory that assigns the ordered I-V tier structure.'

$progressionRpcMatches = [regex]::Matches(
    $progressionHostText,
    '\[Rpc\.(?:Host|Broadcast)[^\]]*\]',
    $singleline
)
$pinnedSpendRpcPattern = (
    '\[Rpc\.Host\]\s*public\s+void\s+RequestSpend\s*\(' +
    '\s*string\s+operationId\s*,\s*string\s+catalogVersion\s*,' +
    '\s*string\s+skillId\s*,\s*int\s+tier\s*\)'
)
Assert-Contract -Condition (
    $progressionRpcMatches.Count -eq 1 -and
    $progressionRpcMatches[0].Value -ceq '[Rpc.Host]' -and
    $progressionHostText -match $pinnedSpendRpcPattern
) `
    -File 'code\progression\LpPlayerHubProgressionHost.cs' `
    -Rule 'progression-rpc-surface' `
    -Message 'Batch 2 must expose only the pinned void RequestSpend(string,string,string,int) host RPC.'

Assert-Contract -Condition (
    $progressionHostText -notmatch '\[Rpc\.(?:Host|Broadcast)[^\]]*\]\s*(?:public|private|internal|protected)\s+\S+\s+(?:Get|Read|State)\w*\s*\(' -and
    $progressionHostText -notmatch '\bRpc\.Broadcast\b|\bRpc\.Owner\b'
) `
    -File 'code\progression\LpPlayerHubProgressionHost.cs' `
    -Rule 'progression-no-read-response-rpc' `
    -Message 'Batch 2 cannot add a client read or response RPC.'

Assert-Contract -Condition (
    $progressionHostText -match 'GameUtils\.GetPlayerByConnectionId\s*\(\s*Rpc\.CallerId\s*\)' -and
    $progressionHostText -match 'checked\s*\(\s*\(ulong\)player\.SteamId\s*\)' -and
    $progressionHostText -notmatch 'RequestSpend\s*\([^)]*\bSteamId\b'
) `
    -File 'code\progression\LpPlayerHubProgressionHost.cs' `
    -Rule 'progression-caller-identity' `
    -Message 'The spend identity must derive solely from Rpc.CallerId and never from request data.'

Assert-Contract -Condition (
    $progressionHostText -notmatch '\bExecuteEarnFor\b|\bRequestEarn\b|\bGrantPoints\b' -and
    $progressionDomainText -match 'internal\s+LpPlayerHubSpendResult\s+ExecuteEarnFor\s*\('
) `
    -File 'code\progression\LpPlayerHubProgressionHost.cs' `
    -Rule 'progression-no-client-earn' `
    -Message 'Trusted harness earn injection must remain internal and have no host/client callsite.'

Assert-Contract -Condition (
    $progressionHostText -match '\bLpPlayerHubCatalog\.Version\b' -and
    $progressionHostText -match '\bLpPlayerHubCatalog\.Skills\b' -and
    $progressionHostText -match '\bLpPlayerHubDenyAllCostPolicy\b'
) `
    -File 'code\progression\LpPlayerHubProgressionHost.cs' `
    -Rule 'progression-shipping-bindings' `
    -Message 'Shipping must bind the shared fixture catalog and DenyAll cost policy.'

Assert-Contract -Condition (
    $progressionDomainText -match 'Guid\.TryParseExact\s*\(\s*operationId\s*,\s*"D"' -and
    $progressionDomainText -match 'ToString\s*\(\s*"D"\s*\)\.ToLowerInvariant\s*\(\s*\)' -and
    $progressionDomainText -match '\$"spend:\{operationId\}"' -and
    $progressionStoreText -match [regex]::Escape('6E1FD3A4-4B6C-5A2E-9F0B-8C7D1A2E4B60')
) `
    -File 'code\progression\LpPlayerHubProgression.cs' `
    -Rule 'progression-operation-identity' `
    -Message 'Canonical D-format IDs, host-derived spend source IDs, and the pinned migration namespace must remain present.'

Assert-Contract -Condition (
    $progressionHostText -match 'FileSystem\.Data\.FileExists' -and
    $progressionHostText -match 'FileSystem\.Data\.ReadAllText' -and
    $progressionHostText -match 'FileSystem\.Data\.WriteAllText' -and
    $batch2ProductionText -notmatch '\b(?:Move|Rename|Copy|Delete)File\s*\('
) `
    -File 'code\progression\LpPlayerHubProgressionHost.cs' `
    -Rule 'progression-file-primitives' `
    -Message 'Progression storage must use only the approved direct FileSystem.Data read/write primitives.'

Assert-Contract -Condition (
    $progressionStoreText -match 'public\s+const\s+int\s+StoreVersion\s*=\s*1\s*;' -and
    $progressionStoreText -match '\bSHA256\.HashData\b' -and
    $progressionStoreText -match '\bcommitMarker\b' -and
    $progressionStoreText -match '\bOperationRecords\b'
) `
    -File 'code\progression\LpPlayerHubProgressionStore.cs' `
    -Rule 'progression-wal-contract' `
    -Message 'The v1 checksum-covered journal candidate contract is incomplete.'

$forbiddenValueToken = ('$' + 'LP')
Assert-Contract -Condition (
    $batch2ProductionText -notmatch [regex]::Escape($forbiddenValueToken) -and
    $batch2ProductionText -notmatch '\b(?:wallet|sats|BTC|P2P|VIP|EVIP|AK47)\b' -and
    $batch2ProductionText -notmatch '\[\s*Sync\b' -and
    $progressionHarnessText -match '10\.0\.300'
) `
    -File 'code\progression' `
    -Rule 'progression-scope-fence' `
    -Message 'Batch 2 crossed a forbidden value/effect/sync surface or lost its pinned SDK harness.'

foreach ($commandName in @('lp', 'hub', 'playerhub')) {
    $conCmdCount = [regex]::Matches(
        $hostText,
        ('\[ConCmd\(\s*"' + [regex]::Escape($commandName) + '"\s*\)\]'),
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    ).Count

    if ($conCmdCount -ne 1) {
        [void] $findings.Add(('code\ui\LpPlayerHubHost.cs:1 [command-contract] Expected exactly one ConCmd owner for {0}; found {1}.' -f $commandName, $conCmdCount))
    }
}

$thinConCmdPatterns = @(
    '\[ConCmd\(\s*"lp"\s*\)\]\s*public\s+static\s+void\s+\w+\s*\(\s*\)\s*=>\s*Toggle\s*\(\s*\)\s*;',
    '\[ConCmd\(\s*"hub"\s*\)\]\s*public\s+static\s+void\s+\w+\s*\(\s*\)\s*=>\s*Toggle\s*\(\s*\)\s*;',
    '\[ConCmd\(\s*"playerhub"\s*\)\]\s*public\s+static\s+void\s+\w+\s*\(\s*\)\s*=>\s*Toggle\s*\(\s*\)\s*;'
)
foreach ($pattern in $thinConCmdPatterns) {
    if ($hostText -notmatch $pattern) {
        [void] $findings.Add('code\ui\LpPlayerHubHost.cs:1 [command-contract] Every Player Hub ConCmd wrapper must be a thin Toggle() call.')
    }
}

$chatCommandPatterns = @(
    '#if\s+!LIFEPUNCH_LOCAL[\s\S]*?class\s+PlayerHubChatCommand\s*:\s*ICommand',
    'Command\s*=>\s*"lp"\s*;',
    'Aliases\s*=>\s*\[\s*"hub"\s*,\s*"playerhub"\s*\]\s*;',
    'ExecuteLocal\s*\([^)]*\)\s*\{\s*LpPlayerHubHost\.Toggle\s*\(\s*\)\s*;\s*return\s+true\s*;\s*\}',
    'ExecuteHost\s*\([^)]*\)\s*=>\s*true\s*;'
)
foreach ($pattern in $chatCommandPatterns) {
    if ($hostText -notmatch $pattern) {
        [void] $findings.Add(('code\ui\LpPlayerHubHost.cs:1 [chat-command-contract] Missing required PlayerHubChatCommand shape: {0}' -f $pattern))
    }
}

foreach ($pattern in @('\bRpc\.', '\bSync\b', '\bExecuteCommandHost\b', '\bbackend\b', '\beconomy\b', '\bpersistence\b')) {
    if ($hostText -match $pattern) {
        [void] $findings.Add(('code\ui\LpPlayerHubHost.cs:1 [command-locality] Forbidden command-path seam matched {0}.' -f $pattern))
    }
}

$statsRequiredTokens = @(
    'LpStatsIdentityVm',
    'LpStatsTrackProgressVm',
    'PLAYER IDENTITY',
    'TRACK PROGRESSION',
    'model.Identity.Tracks',
    'track.RanksPurchased',
    'track.TotalRanks',
    'stats-track-meter',
    'stats-track-fill'
)
foreach ($token in $statsRequiredTokens) {
    if (($modelText + "`n" + $statsText + "`n" + $statsScssText) -notmatch [regex]::Escape($token)) {
        [void] $findings.Add(('code\ui\Stats\LpPlayerHubStats:1 [stats-identity-contract] Missing {0}.' -f $token))
    }
}

if ($modelText -match '\bActivityTrend\b|\bActivitySummary\b|\bLpActivityBarVm\b' -or $statsText -match 'ACTIVITY TREND|ActivityTrend|ActivitySummary') {
    [void] $findings.Add('code\ui\Stats\LpPlayerHubStats:1 [stats-identity-contract] Activity Trend contract must be fully replaced.')
}

Assert-Contract -Condition (
    $modelText -match 'Tracks:\s*BuildStatsTracks\s*\(\s*\)' -and
    $modelText -match 'catalogTracks\s*=\s*LpPlayerHubCatalog\.Tracks' -and
    $modelText -match 'trackIndex\s*<\s*catalogTracks\.Count'
) `
    -File 'code\data\LpPlayerHubModels.cs' `
    -Rule 'stats-track-source' `
    -Message 'Stats track identity must project all five shared catalog tracks.'

Assert-Contract -Condition ($modelText -match 'totalRanks\s*\+=\s*skill\.Tiers\.Count\s*;') `
    -File 'code\data\LpPlayerHubModels.cs' `
    -Rule 'stats-track-denominator' `
    -Message 'Stats track rank totals must derive from the catalog tier structures.'
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
Write-Host ("Batch-1 catalog assertions: {0}; tracks: {1}; skills: {2}; ordered tiers: {3}" -f `
    $contractAssertions, $catalogTrackCount, $catalogSkillCount, $catalogTierCount) -ForegroundColor DarkGray

if ($findings.Count -gt 0) {
    foreach ($finding in $findings) {
        Write-Host $finding -ForegroundColor Red
    }

    Write-Host ("FAIL - {0} contract finding(s)." -f $findings.Count) -ForegroundColor Red
    exit 1
}

Write-Host 'PASS - Player Hub static s&box compatibility contract is clean.' -ForegroundColor Green
exit 0
