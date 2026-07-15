<#
.SYNOPSIS
  Focused, dependency-free contract tests for the CI regression sensors.

.DESCRIPTION
  Run with PowerShell 7 from the repository root:
    pwsh -NoProfile -File lifepunch/scripts/tests/Assert-CiteCensusRegression.Tests.ps1
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$gatePath = Join-Path $repoRoot 'lifepunch/scripts/Assert-CiteCensusRegression.ps1'
$censusPath = Join-Path $repoRoot 'lifepunch/scripts/Invoke-CiteCensus.ps1'
$workflowPath = Join-Path $repoRoot '.github/workflows/regression-sensors.yml'
$pwshCommand = Get-Command pwsh -ErrorAction SilentlyContinue
if (-not $pwshCommand) { $pwshCommand = Get-Command powershell -ErrorAction Stop }
$pwsh = $pwshCommand.Source
$failures = [System.Collections.Generic.List[string]]::new()

function Assert-True {
    param([bool] $Condition, [string] $Message)
    if (-not $Condition) { $script:failures.Add($Message) }
}

function Invoke-ChildScript {
    param([string] $Path, [string[]] $Arguments)

    $output = & $pwsh -NoLogo -NoProfile -File $Path @Arguments 2>&1 | ForEach-Object { $_.ToString() }
    [pscustomobject]@{
        ExitCode = $LASTEXITCODE
        Output = ($output -join "`n")
    }
}

Assert-True (Test-Path -LiteralPath $gatePath -PathType Leaf) 'regression gate script must exist'
Assert-True (Test-Path -LiteralPath $censusPath -PathType Leaf) 'graduated cite-census script must exist'
Assert-True (Test-Path -LiteralPath $workflowPath -PathType Leaf) 'regression-sensors workflow must exist'

if ((Test-Path -LiteralPath $gatePath) -and (Test-Path -LiteralPath $censusPath)) {
    $tempRoot = Join-Path ([IO.Path]::GetTempPath()) ("lifepunch-census-tests-{0}" -f [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path (Join-Path $tempRoot 'base') -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $tempRoot 'head') -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $tempRoot 'dxrp') -Force | Out-Null
    $fakeCensus = Join-Path $tempRoot 'Fake-CiteCensus.ps1'

    @'
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string] $ExpectedSha,
    [Parameter(Mandatory)][string] $RepoRoot,
    [string[]] $SourceRoots,
    [string] $DxrpRoot,
    [string] $ExpectedDxrpSha
)

$baseSha = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
$isBase = $ExpectedSha -eq $baseSha
$scenario = $env:CITE_CENSUS_TEST_SCENARIO

if ($scenario -eq 'detector-failure' -and -not $isBase) {
    [Console]::Error.WriteLine('INPUT-FAULT: synthetic detector failure on stderr')
    exit 3
}

$rows = @(
    [pscustomobject]@{ Verdict='HOLD'; Form='BARE-PATH'; File='docs/h.md'; Line=1; Cite='docs/h.md'; Target='docs/h.md'; New='-'; Reason='resolved path' },
    [pscustomobject]@{ Verdict='HOLD'; Form='FILE-LINE'; File='docs/h.md'; Line=2; Cite='docs/h.md:1'; Target='docs/h.md'; New='1'; Reason='resolved line' },
    [pscustomobject]@{ Verdict='HOLD'; Form='SYMBOL'; File='docs/h.md'; Line=3; Cite='`Known.Symbol`'; Target='code.cs'; New='10'; Reason='resolved symbol' }
)

if (-not ($scenario -eq 'removed-finding' -and -not $isBase)) {
    $line = if ($isBase) { 12 } else { 912 }
    $rows += [pscustomobject]@{ Verdict='DRIFT'; Form='FILE-LINE'; File='docs/a.md'; Line=$line; Cite='docs/missing.md:7'; Target='-'; New='-'; Reason='target missing' }
}
if ($scenario -eq 'new-finding' -and -not $isBase) {
    $rows += [pscustomobject]@{ Verdict='PHANTOM'; Form='SYMBOL'; File='docs/b.md'; Line=30; Cite='`Missing.Symbol`'; Target='-'; New='-'; Reason='symbol missing' }
}
if ($scenario -eq 'duplicate-finding' -and -not $isBase) {
    $rows += [pscustomobject]@{ Verdict='DRIFT'; Form='FILE-LINE'; File='docs/a.md'; Line=913; Cite='docs/missing.md:7'; Target='-'; New='-'; Reason='duplicate target missing' }
}

Write-Output '| Verdict | Form | Citing file | Line | Cite | Resolved target | New line/path | Reason |'
Write-Output '|---|---|---|---:|---|---|---|---|'
foreach ($row in $rows) {
    Write-Output ('| {0} | {1} | {2} | {3} | {4} | {5} | {6} | {7} |' -f $row.Verdict, $row.Form, $row.File, $row.Line, $row.Cite, $row.Target, $row.New, $row.Reason)
}

$hold = @($rows | Where-Object Verdict -eq 'HOLD').Count
$drift = @($rows | Where-Object Verdict -eq 'DRIFT').Count
$phantom = @($rows | Where-Object Verdict -eq 'PHANTOM').Count
$bare = @($rows | Where-Object Form -eq 'BARE-PATH').Count
$fileLine = @($rows | Where-Object Form -eq 'FILE-LINE').Count
$symbol = @($rows | Where-Object Form -eq 'SYMBOL').Count
$total = $rows.Count
if ($scenario -eq 'summary-mismatch' -and -not $isBase) { $total++ }

Write-Output 'CENSUS pin=synthetic sources=1 targets=1 fencedLinesSkipped=0'
Write-Output "DENOMINATOR total=$total barePath=$bare fileLine=$fileLine symbol=$symbol"
Write-Output "VERDICT HOLD=$hold DRIFT=$drift PHANTOM=$phantom"
if ($scenario -eq 'gate-mismatch' -and -not $isBase) {
    Write-Output 'GATE: PASS - synthetic contradiction'
    exit 0
}
if (($drift + $phantom) -gt 0) {
    Write-Output 'GATE: FAIL - synthetic unresolved finding'
    exit 2
}
Write-Output 'GATE: PASS - synthetic all-HOLD census'
exit 0
'@ | Set-Content -LiteralPath $fakeCensus -Encoding utf8

    $common = @(
        '-BaseRepoRoot', (Join-Path $tempRoot 'base'),
        '-HeadRepoRoot', (Join-Path $tempRoot 'head'),
        '-BaseSha', 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
        '-HeadSha', 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
        '-DxrpRoot', (Join-Path $tempRoot 'dxrp'),
        '-ExpectedDxrpSha', 'cccccccccccccccccccccccccccccccccccccccc',
        '-CensusScriptPath', $fakeCensus
    )

    try {
        $defaultPathProbe = Invoke-ChildScript -Path $gatePath -Arguments @(
            '-BaseRepoRoot', (Join-Path $tempRoot 'absent'),
            '-HeadRepoRoot', (Join-Path $tempRoot 'head'),
            '-BaseSha', 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
            '-HeadSha', 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
            '-DxrpRoot', (Join-Path $tempRoot 'dxrp'),
            '-ExpectedDxrpSha', 'cccccccccccccccccccccccccccccccccccccccc'
        )
        Assert-True ($defaultPathProbe.ExitCode -eq 3 -and $defaultPathProbe.Output -match 'required checkout root') "default detector path must bind before input validation: $($defaultPathProbe.Output)"

        $env:CITE_CENSUS_TEST_SCENARIO = 'unchanged'
        $result = Invoke-ChildScript -Path $gatePath -Arguments $common
        Assert-True ($result.ExitCode -eq 0) "unchanged finding with a shifted line must pass (exit=$($result.ExitCode)): $($result.Output)"

        $env:CITE_CENSUS_TEST_SCENARIO = 'removed-finding'
        $result = Invoke-ChildScript -Path $gatePath -Arguments $common
        Assert-True ($result.ExitCode -eq 0) "removed finding must pass (exit=$($result.ExitCode)): $($result.Output)"

        $env:CITE_CENSUS_TEST_SCENARIO = 'new-finding'
        $result = Invoke-ChildScript -Path $gatePath -Arguments $common
        Assert-True ($result.ExitCode -eq 2) "new non-HOLD identity must fail with exit 2 (exit=$($result.ExitCode)): $($result.Output)"
        Assert-True ($result.Output -match 'docs/b\.md') 'new-finding failure must identify the citing file'

        $env:CITE_CENSUS_TEST_SCENARIO = 'duplicate-finding'
        $result = Invoke-ChildScript -Path $gatePath -Arguments $common
        Assert-True ($result.ExitCode -eq 2) "an added duplicate identity must fail the multiset comparison (exit=$($result.ExitCode)): $($result.Output)"

        $env:CITE_CENSUS_TEST_SCENARIO = 'detector-failure'
        $result = Invoke-ChildScript -Path $gatePath -Arguments $common
        Assert-True ($result.ExitCode -eq 3 -and $result.Output -match 'synthetic detector failure on stderr') "detector stderr failure must remain an infrastructure failure (exit=$($result.ExitCode)): $($result.Output)"

        $env:CITE_CENSUS_TEST_SCENARIO = 'summary-mismatch'
        $result = Invoke-ChildScript -Path $gatePath -Arguments $common
        Assert-True ($result.ExitCode -eq 3) "summary/row mismatch must fail closed with exit 3 (exit=$($result.ExitCode)): $($result.Output)"

        $env:CITE_CENSUS_TEST_SCENARIO = 'gate-mismatch'
        $result = Invoke-ChildScript -Path $gatePath -Arguments $common
        Assert-True ($result.ExitCode -eq 3) "exit/gate/non-HOLD contradiction must fail closed with exit 3 (exit=$($result.ExitCode)): $($result.Output)"
    }
    finally {
        $tempBase = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
        $resolvedTemp = [IO.Path]::GetFullPath($tempRoot)
        if (-not $resolvedTemp.StartsWith($tempBase, [StringComparison]::OrdinalIgnoreCase)) {
            throw "refusing test cleanup outside the temp root: $resolvedTemp"
        }
        Remove-Item -LiteralPath $resolvedTemp -Recurse -Force
        Remove-Item Env:CITE_CENSUS_TEST_SCENARIO -ErrorAction SilentlyContinue
    }
}

if (Test-Path -LiteralPath $censusPath) {
    $censusText = Get-Content -LiteralPath $censusPath -Raw
    Assert-True ($censusText -match '0049_CODEX_UNIFIED-CITE-CENSUS-GATE_2026-07-14') 'graduated script header must name its 0049 origin'
}

if (Test-Path -LiteralPath $workflowPath) {
    $workflowText = Get-Content -LiteralPath $workflowPath -Raw
    Assert-True ($workflowText -match '(?ms)^on:\r?\n  pull_request:\r?\n    branches: \[develop\]\r?\n\r?\npermissions:') 'workflow must have only the pull_request/develop trigger'
    Assert-True ($workflowText -notmatch '(?m)^\s+(push|workflow_dispatch|workflow_call|schedule):') 'workflow must have no trigger other than pull_request'
    Assert-True ($workflowText -match '(?ms)^permissions:\s*\r?\n  contents: read\s*\r?\n\s*concurrency:') 'workflow permissions must be exactly contents: read'
    $uses = @([regex]::Matches($workflowText, '(?m)^\s*(?:-\s*)?uses:\s*([^\s#]+)') | ForEach-Object { $_.Groups[1].Value })
    Assert-True ($uses.Count -gt 0 -and @($uses | Where-Object { $_ -notmatch '@[0-9a-f]{40}$' }).Count -eq 0) 'every workflow action reference must be pinned to a 40-hex SHA'
    $checkoutCount = @($uses | Where-Object { $_ -match '^actions/checkout@' }).Count
    $noCredentialCount = [regex]::Matches($workflowText, '(?m)^\s+persist-credentials:\s+false\s*$').Count
    Assert-True ($checkoutCount -gt 0 -and $checkoutCount -eq $noCredentialCount) 'every checkout must set persist-credentials: false'
    Assert-True ($workflowText -match 'mragerlp/dxrp-public') 'workflow must check out the public DXRP corpus'
    Assert-True ($workflowText -match 'e6d3026a52a42045a56db44aa9db9b75ab93d2cc') 'workflow must pin the ruled DXRP corpus SHA'
    Assert-True ($workflowText -match 'Assert-CiteCensusRegression\.ps1') 'workflow must invoke the cite-census regression gate'
    $citeJobMatch = [regex]::Match($workflowText, '(?ms)^  cite-census:\s*\r?\n(.*?)(?=^  bridge-version-contract:)')
    Assert-True $citeJobMatch.Success 'workflow must contain the cite-census job'
    if ($citeJobMatch.Success) {
        $citeJob = $citeJobMatch.Value
        foreach ($checkoutShape in @(
            '(?ms)- name: Check out PR merge candidate.*?ref: \$\{\{ github\.sha \}\}.*?path: repo',
            '(?ms)- name: Check out PR base.*?ref: \$\{\{ github\.event\.pull_request\.base\.sha \}\}.*?path: repo',
            '(?ms)- name: Check out pinned public DXRP corpus.*?path: dxrp'
        )) {
            Assert-True ($citeJob -match $checkoutShape) "cite job is missing storage-bounded checkout shape: $checkoutShape"
        }
        Assert-True ($citeJob -match 'git -C "\$env:GITHUB_WORKSPACE/repo" worktree add --detach "\$env:GITHUB_WORKSPACE/head" \$env:CANDIDATE_SHA') 'cite job must preserve the merge candidate as a linked worktree before switching the shared checkout to base'
        Assert-True ([regex]::Matches($citeJob, '(?m)^\s+path: repo\s*$').Count -eq 2) 'cite job must reuse one LifePunch checkout path/object store for candidate and base'
        foreach ($selectionShape in @('\$baseComparator\s*=', '\$baseDetector\s*=', 'Test-Path -LiteralPath \$baseComparator', 'Test-Path -LiteralPath \$baseDetector', 'ENFORCEMENT_ROOT=\$env:GITHUB_WORKSPACE/repo', 'BOOTSTRAP FALLBACK:.+using head', 'ENFORCEMENT_ROOT=\$env:GITHUB_WORKSPACE/head')) {
            Assert-True ($citeJob -match $selectionShape) "workflow base-first enforcement selection is missing shape: $selectionShape"
        }
        Assert-True ($citeJob -match 'HEAD_SHA: \$\{\{ github\.sha \}\}') 'cite job must label and compare the tested PR merge candidate SHA'
        Assert-True ($citeJob -match '-BaseRepoRoot "\$env:GITHUB_WORKSPACE/repo"') 'cite comparator must use the shared checkout after it is switched to base'
        Assert-True ($citeJob -match '-HeadRepoRoot "\$env:GITHUB_WORKSPACE/head"') 'cite comparator must use the preserved candidate worktree as head'
    }
    Assert-True ($workflowText -match 'Assert-BridgeVersion\.ps1') 'workflow must invoke the bridge version assertion'
    foreach ($fixtureShape in @('bridgeVersion\s*=\s*\$null', 'mcpServerVersion\s*=\s*\$null', 'connected\s*=\s*\$false', 'roundTripOk\s*=\s*\$false', 'versionsAligned\s*=\s*\$true')) {
        Assert-True ($workflowText -match $fixtureShape) "workflow false-green fixture is missing shape: $fixtureShape"
    }
    $bridgeJobMatch = [regex]::Match($workflowText, '(?ms)^  bridge-version-contract:\s*\r?\n.*\z')
    Assert-True $bridgeJobMatch.Success 'workflow must contain the bridge-version-contract job'
    if ($bridgeJobMatch.Success) {
        $bridgeJob = $bridgeJobMatch.Value
        Assert-True ([regex]::Matches($bridgeJob, '(?m)^\s+(?:-\s+)?uses:\s+actions/checkout@').Count -eq 1) 'bridge job must use exactly one checkout'
        Assert-True ($bridgeJob -match '(?ms)- name: Check out trusted PR base.*?ref: \$\{\{ github\.event\.pull_request\.base\.sha \}\}.*?path: base') 'bridge job must check out only the exact trusted base'
        Assert-True ($bridgeJob -notmatch 'PR head|BOOTSTRAP FALLBACK|BRIDGE_ASSERTION_ROOT') 'bridge job must not execute a candidate-controlled assertion fallback'
        Assert-True ($bridgeJob -match "(?ms)BRIDGE-CONTRACT: PASS.+?^\s+exit 0\s*$") 'bridge job must explicitly clear the expected negative fixture exit code after success'
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output "FAIL: $_" }
    exit 1
}

Write-Output 'PASS: cite-census regression and workflow contract tests'
exit 0
