<#
.SYNOPSIS
  Fails when a PR introduces a new non-HOLD cite-census identity.

.DESCRIPTION
  Runs the graduated cite-census detector against exact, clean base and head
  checkouts using the same detector version and pinned DXRP corpus. Detector
  exit 0 (all HOLD) and exit 2 (complete census with unresolved findings) are
  both complete results. Exit 2 is never ignored: every DRIFT/PHANTOM row is
  parsed and compared as a multiset against the base result.

  Identity is verdict + cite form + citing file + cited text. The citing line
  is deliberately excluded so unrelated line movement does not manufacture a
  regression. Duplicate identities are counted, so adding another copy still
  fails. Removing existing debt passes.

.OUTPUTS
  Exit 0 = complete censuses and no new head DRIFT/PHANTOM identity
  Exit 2 = complete censuses but one or more new head identities
  Exit 3 = invalid input or an incomplete/failed detector run
  Exit 4 = internal comparison failure
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string] $BaseRepoRoot,
    [Parameter(Mandatory)][string] $HeadRepoRoot,
    [Parameter(Mandatory)][ValidatePattern('^[0-9a-fA-F]{40}$')][string] $BaseSha,
    [Parameter(Mandatory)][ValidatePattern('^[0-9a-fA-F]{40}$')][string] $HeadSha,
    [Parameter(Mandatory)][string] $DxrpRoot,
    [Parameter(Mandatory)][ValidatePattern('^[0-9a-fA-F]{40}$')][string] $ExpectedDxrpSha,
    [string] $CensusScriptPath = ''
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($CensusScriptPath)) {
    $CensusScriptPath = Join-Path $PSScriptRoot 'Invoke-CiteCensus.ps1'
}

function Stop-InputFault {
    param([string] $Message)
    Write-Output "CITE-CENSUS-INPUT-FAULT: $Message"
    exit 3
}

function Stop-DetectorFault {
    param(
        [string] $Label,
        [string] $Message,
        [object[]] $Lines = @()
    )
    Write-Output "CITE-CENSUS-INPUT-FAULT: $Label detector output is not trustworthy: $Message"
    $Lines | ForEach-Object { Write-Output "[$Label] $_" }
    exit 3
}

function Get-PowerShellExecutable {
    $command = Get-Command pwsh -ErrorAction SilentlyContinue
    if (-not $command) { $command = Get-Command powershell -ErrorAction SilentlyContinue }
    if (-not $command) { Stop-InputFault 'neither pwsh nor powershell is available' }
    return $command.Source
}

function Invoke-Census {
    param(
        [Parameter(Mandatory)][string] $Label,
        [Parameter(Mandatory)][string] $RepoRoot,
        [Parameter(Mandatory)][string] $ExpectedSha
    )

    $engine = Get-PowerShellExecutable
    $previousErrorActionPreference = $ErrorActionPreference
    try {
        # Windows PowerShell 5.1 turns redirected native stderr into ErrorRecord
        # objects. EAP=Stop would throw before LASTEXITCODE can be inspected.
        $ErrorActionPreference = 'Continue'
        $lines = & $engine -NoLogo -NoProfile -ExecutionPolicy Bypass -File $CensusScriptPath `
            -ExpectedSha $ExpectedSha `
            -RepoRoot $RepoRoot `
            -DxrpRoot $DxrpRoot `
            -ExpectedDxrpSha $ExpectedDxrpSha 2>&1 | ForEach-Object { $_.ToString() }
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }

    if ($exitCode -notin @(0, 2)) {
        Write-Output "CITE-CENSUS-INPUT-FAULT: $Label detector exited $exitCode; only complete exits 0 or 2 are comparable."
        $lines | ForEach-Object { Write-Output "[$Label] $_" }
        exit 3
    }

    return ConvertFrom-StrictCensusOutput -Label $Label -ExitCode $exitCode -Lines @($lines)
}

function Convert-ToCensusCount {
    param(
        [string] $Label,
        [string] $Name,
        [string] $Text,
        [object[]] $Lines
    )
    [long] $value = 0
    if (-not [long]::TryParse($Text, [ref] $value)) {
        Stop-DetectorFault -Label $Label -Message "$Name is not a valid non-negative count" -Lines $Lines
    }
    return $value
}

function ConvertFrom-StrictCensusOutput {
    param(
        [string] $Label,
        [int] $ExitCode,
        [object[]] $Lines
    )

    $censusLines = @($Lines | Where-Object { $_ -match '^\s*CENSUS ' })
    $denominatorLines = @($Lines | Where-Object { $_ -match '^\s*DENOMINATOR' })
    $verdictLines = @($Lines | Where-Object { $_ -match '^\s*VERDICT' })
    $gateLines = @($Lines | Where-Object { $_ -match '^\s*GATE:' })
    if ($censusLines.Count -ne 1 -or $censusLines[0] -notmatch '^CENSUS pin=(?:[0-9a-fA-F]{40}|synthetic) sources=\d+ targets=\d+ fencedLinesSkipped=\d+$') {
        Stop-DetectorFault -Label $Label -Message 'expected exactly one CENSUS summary' -Lines $Lines
    }
    if ($denominatorLines.Count -ne 1 -or $denominatorLines[0] -notmatch '^DENOMINATOR total=(\d+) barePath=(\d+) fileLine=(\d+) symbol=(\d+)$') {
        Stop-DetectorFault -Label $Label -Message 'expected exactly one well-formed DENOMINATOR summary' -Lines $Lines
    }
    $denominatorMatch = [regex]::Match($denominatorLines[0], '^DENOMINATOR total=(\d+) barePath=(\d+) fileLine=(\d+) symbol=(\d+)$')
    $total = Convert-ToCensusCount $Label 'DENOMINATOR total' $denominatorMatch.Groups[1].Value $Lines
    $barePath = Convert-ToCensusCount $Label 'DENOMINATOR barePath' $denominatorMatch.Groups[2].Value $Lines
    $fileLine = Convert-ToCensusCount $Label 'DENOMINATOR fileLine' $denominatorMatch.Groups[3].Value $Lines
    $symbol = Convert-ToCensusCount $Label 'DENOMINATOR symbol' $denominatorMatch.Groups[4].Value $Lines

    if ($verdictLines.Count -ne 1 -or $verdictLines[0] -notmatch '^VERDICT HOLD=(\d+) DRIFT=(\d+) PHANTOM=(\d+)$') {
        Stop-DetectorFault -Label $Label -Message 'expected exactly one well-formed VERDICT summary' -Lines $Lines
    }
    $verdictMatch = [regex]::Match($verdictLines[0], '^VERDICT HOLD=(\d+) DRIFT=(\d+) PHANTOM=(\d+)$')
    $hold = Convert-ToCensusCount $Label 'VERDICT HOLD' $verdictMatch.Groups[1].Value $Lines
    $drift = Convert-ToCensusCount $Label 'VERDICT DRIFT' $verdictMatch.Groups[2].Value $Lines
    $phantom = Convert-ToCensusCount $Label 'VERDICT PHANTOM' $verdictMatch.Groups[3].Value $Lines

    if (($barePath + $fileLine + $symbol) -ne $total) {
        Stop-DetectorFault -Label $Label -Message 'DENOMINATOR form counts do not sum to total' -Lines $Lines
    }
    if (($hold + $drift + $phantom) -ne $total) {
        Stop-DetectorFault -Label $Label -Message 'VERDICT counts do not sum to total' -Lines $Lines
    }
    if ($barePath -eq 0 -or $fileLine -eq 0 -or $symbol -eq 0) {
        Stop-DetectorFault -Label $Label -Message 'all three cite-form denominators must be non-zero' -Lines $Lines
    }
    if ($gateLines.Count -ne 1 -or $gateLines[0] -notmatch '^GATE: (PASS|FAIL)(?:\s+-.*)?$') {
        Stop-DetectorFault -Label $Label -Message 'expected exactly one well-formed GATE summary' -Lines $Lines
    }
    $gateVerdict = [regex]::Match($gateLines[0], '^GATE: (PASS|FAIL)').Groups[1].Value

    $expectedHeader = '| Verdict | Form | Citing file | Line | Cite | Resolved target | New line/path | Reason |'
    $expectedSeparator = '|---|---|---|---:|---|---|---|---|'
    if (@($Lines | Where-Object { $_ -eq $expectedHeader }).Count -ne 1 -or @($Lines | Where-Object { $_ -eq $expectedSeparator }).Count -ne 1) {
        Stop-DetectorFault -Label $Label -Message 'expected exactly one canonical eight-column table header' -Lines $Lines
    }

    $rows = [System.Collections.Generic.List[object]]::new()
    $tableLines = @($Lines | Where-Object { $_ -match '^\|' -and $_ -ne $expectedHeader -and $_ -ne $expectedSeparator })
    foreach ($line in $tableLines) {
        if ($line -notmatch '^\|.*\|$') {
            Stop-DetectorFault -Label $Label -Message "malformed table row: $line" -Lines $Lines
        }

        # Census cells escape literal pipes as \|. Split only on table delimiters.
        $cells = @($line.Trim().Trim('|') -split '(?<!\\)\|' | ForEach-Object { $_.Trim() })
        if ($cells.Count -ne 8) {
            Stop-DetectorFault -Label $Label -Message "table row does not have exactly eight columns: $line" -Lines $Lines
        }
        if ($cells[0] -notin @('HOLD', 'DRIFT', 'PHANTOM') -or $cells[1] -notin @('BARE-PATH', 'FILE-LINE', 'SYMBOL') -or $cells[2] -eq '' -or $cells[3] -notmatch '^\d+$' -or $cells[4] -eq '') {
            Stop-DetectorFault -Label $Label -Message "table row has an invalid required field: $line" -Lines $Lines
        }

        $rows.Add([pscustomobject]@{
            Verdict = $cells[0]
            Form = $cells[1]
            CitingFile = $cells[2]
            Cite = $cells[4]
            Display = $line
        })
    }

    $parsedRows = @($rows)
    if ($parsedRows.Count -ne $total) {
        Stop-DetectorFault -Label $Label -Message "parsed row count $($parsedRows.Count) does not equal DENOMINATOR total $total" -Lines $Lines
    }
    $parsedBare = @($parsedRows | Where-Object Form -eq 'BARE-PATH').Count
    $parsedFileLine = @($parsedRows | Where-Object Form -eq 'FILE-LINE').Count
    $parsedSymbol = @($parsedRows | Where-Object Form -eq 'SYMBOL').Count
    $parsedHold = @($parsedRows | Where-Object Verdict -eq 'HOLD').Count
    $parsedDrift = @($parsedRows | Where-Object Verdict -eq 'DRIFT').Count
    $parsedPhantom = @($parsedRows | Where-Object Verdict -eq 'PHANTOM').Count
    if ($parsedBare -ne $barePath -or $parsedFileLine -ne $fileLine -or $parsedSymbol -ne $symbol) {
        Stop-DetectorFault -Label $Label -Message 'parsed per-form counts do not match DENOMINATOR summary' -Lines $Lines
    }
    if ($parsedHold -ne $hold -or $parsedDrift -ne $drift -or $parsedPhantom -ne $phantom) {
        Stop-DetectorFault -Label $Label -Message 'parsed per-verdict counts do not match VERDICT summary' -Lines $Lines
    }

    $nonHold = $drift + $phantom
    if ($nonHold -eq 0 -and ($ExitCode -ne 0 -or $gateVerdict -ne 'PASS')) {
        Stop-DetectorFault -Label $Label -Message 'all-HOLD output requires detector exit 0 and GATE: PASS' -Lines $Lines
    }
    if ($nonHold -gt 0 -and ($ExitCode -ne 2 -or $gateVerdict -ne 'FAIL')) {
        Stop-DetectorFault -Label $Label -Message 'non-HOLD output requires detector exit 2 and GATE: FAIL' -Lines $Lines
    }

    return [pscustomobject]@{
        Label = $Label
        ExitCode = $ExitCode
        Lines = @($Lines)
        Rows = $parsedRows
        Summary = @($censusLines[0], $denominatorLines[0], $verdictLines[0], $gateLines[0])
    }
}

function Get-IdentityKey {
    param([Parameter(Mandatory)] $Row)
    return @($Row.Verdict, $Row.Form, $Row.CitingFile, $Row.Cite) -join [char]0x1f
}

try {
    foreach ($path in @($BaseRepoRoot, $HeadRepoRoot, $DxrpRoot)) {
        if (-not (Test-Path -LiteralPath $path -PathType Container)) {
            Stop-InputFault "required checkout root does not exist: $path"
        }
    }
    if (-not (Test-Path -LiteralPath $CensusScriptPath -PathType Leaf)) {
        Stop-InputFault "cite-census detector does not exist: $CensusScriptPath"
    }

    $base = Invoke-Census -Label 'base' -RepoRoot $BaseRepoRoot -ExpectedSha $BaseSha
    $head = Invoke-Census -Label 'head' -RepoRoot $HeadRepoRoot -ExpectedSha $HeadSha

    $base.Summary | ForEach-Object { Write-Output "[base] $_" }
    $head.Summary | ForEach-Object { Write-Output "[head] $_" }

    $baseRows = @($base.Rows | Where-Object Verdict -ne 'HOLD')
    $headRows = @($head.Rows | Where-Object Verdict -ne 'HOLD')

    $available = @{}
    foreach ($row in $baseRows) {
        $key = Get-IdentityKey -Row $row
        if (-not $available.ContainsKey($key)) { $available[$key] = 0 }
        $available[$key]++
    }

    $newRows = [System.Collections.Generic.List[object]]::new()
    foreach ($row in $headRows) {
        $key = Get-IdentityKey -Row $row
        if ($available.ContainsKey($key) -and $available[$key] -gt 0) {
            $available[$key]--
        }
        else {
            $newRows.Add($row)
        }
    }

    Write-Output "CITE-CENSUS-REGRESSION baseNonHold=$($baseRows.Count) headNonHold=$($headRows.Count) new=$($newRows.Count)"
    if ($newRows.Count -gt 0) {
        Write-Output 'CITE-CENSUS-REGRESSION: FAIL - new DRIFT/PHANTOM identities:'
        $newRows | ForEach-Object { Write-Output $_.Display }
        exit 2
    }

    Write-Output 'CITE-CENSUS-REGRESSION: PASS - no new DRIFT/PHANTOM identity; removals are allowed.'
    exit 0
}
catch {
    Write-Output "CITE-CENSUS-INTERNAL-FAULT: $($_.Exception.Message)"
    exit 4
}
