<#
  Graduated from the read-only census gate filed as
  comms\codex\0049_CODEX_UNIFIED-CITE-CENSUS-GATE_2026-07-14.ps1.
  The detector and its exit contract are preserved here for CI use.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^[0-9a-fA-F]{40}$')]
    [string] $ExpectedSha,

    [Parameter(Mandatory)]
    [string] $RepoRoot,

    [string[]] $SourceRoots = @(
        '.claude/skills',
        '.agents/skills',
        'lifepunch/docs/cvl'
    ),

    # The private DXRP mirror is gitignored by the parent repository. If it is
    # present or referenced, it needs its own pin; the parent SHA cannot attest it.
    [string] $DxrpRoot = '',

    [ValidatePattern('^$|^[0-9a-fA-F]{40}$')]
    [string] $ExpectedDxrpSha = '',

    [switch] $IncludeFencedCode
)

# RISK: READ-ONLY. This script reads files and Git metadata only. It writes no
# cache, report, temporary file, ref, index entry, or worktree byte.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:ExitInput = 3
$script:ExitInternal = 4
$script:Results = New-Object System.Collections.ArrayList
$script:FormCounts = @{ 'BARE-PATH' = 0; 'FILE-LINE' = 0; 'SYMBOL' = 0 }
$script:FencedLinesSkipped = 0

function Stop-Input {
    param([Parameter(Mandatory)][string] $Message)
    [Console]::Error.WriteLine("INPUT-UNRESOLVABLE: $Message")
    exit $script:ExitInput
}

function Stop-Internal {
    param([Parameter(Mandatory)][string] $Message)
    [Console]::Error.WriteLine("INTERNAL-CENSUS-ERROR: $Message")
    exit $script:ExitInternal
}

function Invoke-GitRead {
    param(
        [Parameter(Mandatory)][string] $WorkingRoot,
        [Parameter(Mandatory)][string[]] $Arguments
    )

    $prior = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = @(& git -C $WorkingRoot @Arguments 2>&1)
        $code = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $prior
    }
    if ($code -ne 0) {
        Stop-Input "git -C '$WorkingRoot' $($Arguments -join ' ') failed (exit=$code): $($output -join ' | ')"
    }
    return @($output)
}

function Get-NormalPath {
    param([Parameter(Mandatory)][string] $Path)
    return (($Path -replace '\\', '/').Trim().Trim('`', '"', "'", '(', ')', '[', ']', '{', '}', ',', ';', '.'))
}

function Get-LogicalRelativePath {
    param(
        [Parameter(Mandatory)][string] $Root,
        [Parameter(Mandatory)][string] $FullName
    )
    $rootFull = [IO.Path]::GetFullPath($Root).TrimEnd('\', '/')
    $fileFull = [IO.Path]::GetFullPath($FullName)
    if (-not $fileFull.StartsWith($rootFull + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
        Stop-Internal "'$fileFull' is outside indexed root '$rootFull'"
    }
    return (($fileFull.Substring($rootFull.Length).TrimStart('\', '/')) -replace '\\', '/')
}

function Add-CensusRow {
    param(
        [Parameter(Mandatory)][ValidateSet('HOLD', 'DRIFT', 'PHANTOM')][string] $Verdict,
        [Parameter(Mandatory)][ValidateSet('BARE-PATH', 'FILE-LINE', 'SYMBOL')][string] $Form,
        [Parameter(Mandatory)][string] $SourceFile,
        [Parameter(Mandatory)][int] $SourceLine,
        [Parameter(Mandatory)][string] $Cite,
        [string] $ResolvedTarget = '',
        [string] $NewLine = '',
        [Parameter(Mandatory)][string] $Reason
    )

    [void]$script:Results.Add([pscustomobject][ordered]@{
        Verdict        = $Verdict
        Form           = $Form
        CitingFile     = $SourceFile
        CitingLine     = $SourceLine
        Cite           = $Cite
        ResolvedTarget = $ResolvedTarget
        NewLine        = $NewLine
        Reason         = $Reason
    })
    $script:FormCounts[$Form]++
}

function Get-WordStem {
    param([string] $Word)
    $w = ($Word.ToLowerInvariant() -replace '[^a-z0-9]', '')
    if ($w.Length -gt 3 -and $w.EndsWith('s')) { $w = $w.Substring(0, $w.Length - 1) }
    return $w
}

$stopWords = @{}
@(
    'about','after','against','also','and','are','before','between','body','check','cited','cites',
    'code','does','each','example','false','file','from','here','into','line','lines','lives','most',
    'never','only','path','read','repo','same','sentence','source','target','that','the','their','them',
    'this','through','true','used','using','where','which','with','your','plus','current','wrong','right'
) | ForEach-Object { $stopWords[$_] = $true }

function Get-StrongWords {
    param([string] $Text)
    $seen = @{}
    $words = New-Object System.Collections.ArrayList
    foreach ($m in [regex]::Matches($Text, '[A-Za-z][A-Za-z0-9_-]{2,}')) {
        $stem = Get-WordStem $m.Value
        if ($stem.Length -lt 3 -or $stopWords.ContainsKey($stem) -or $seen.ContainsKey($stem)) { continue }
        $seen[$stem] = $true
        [void]$words.Add($stem)
    }
    return @($words)
}

function Get-ContextWindow {
    param(
        [Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]] $Lines,
        [Parameter(Mandatory)][int] $ZeroIndex
    )
    $parts = New-Object System.Collections.ArrayList
    $start = [Math]::Max(0, $ZeroIndex - 2)
    $end = [Math]::Min($Lines.Count - 1, $ZeroIndex + 2)
    for ($i = $start; $i -le $end; $i++) {
        if (-not [string]::IsNullOrWhiteSpace($Lines[$i])) { [void]$parts.Add($Lines[$i]) }
    }
    return ($parts -join ' ')
}

function Get-MarkdownHeadings {
    param([Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]] $Lines)
    $heads = New-Object System.Collections.ArrayList
    for ($i = 0; $i -lt $Lines.Count; $i++) {
        $m = [regex]::Match($Lines[$i], '^\s*(?<hash>#{1,6})\s+(?<title>.+?)\s*$')
        if (-not $m.Success) { continue }
        [void]$heads.Add([pscustomobject]@{
            Line  = $i + 1
            Level = $m.Groups['hash'].Value.Length
            Title = $m.Groups['title'].Value
            Words = @(Get-StrongWords $m.Groups['title'].Value)
        })
    }
    for ($h = 0; $h -lt $heads.Count; $h++) {
        $end = $Lines.Count
        for ($n = $h + 1; $n -lt $heads.Count; $n++) {
            if ($heads[$n].Level -le $heads[$h].Level) {
                $end = $heads[$n].Line - 1
                break
            }
        }
        while ($end -gt $heads[$h].Line -and [string]::IsNullOrWhiteSpace($Lines[$end - 1])) { $end-- }
        Add-Member -InputObject $heads[$h] -NotePropertyName EndLine -NotePropertyValue $end
    }
    return @($heads)
}

function Test-IntervalsContainLine {
    param([Parameter(Mandatory)][object[]] $Intervals, [Parameter(Mandatory)][int] $Line)
    foreach ($i in $Intervals) {
        if ($Line -ge $i.Start -and $Line -le $i.End) { return $true }
    }
    return $false
}

function Convert-LocationToIntervals {
    param(
        [Parameter(Mandatory)][string] $Location,
        [Parameter(Mandatory)][int] $LineCount
    )
    $intervals = New-Object System.Collections.ArrayList
    $openEnded = $Location.EndsWith('+')
    $raw = $Location.TrimEnd('+')
    foreach ($piece in ($raw -split '[,/]')) {
        if ($piece -match '^(?<a>\d+)-(?<b>\d+)$') {
            $a = [int]$matches.a; $b = [int]$matches.b
        }
        elseif ($piece -match '^\d+$') {
            $a = [int]$piece; $b = if ($openEnded) { $a } else { $a }
        }
        else { Stop-Internal "unsupported location grammar '$Location'" }
        if ($a -lt 1 -or $b -lt $a -or $b -gt $LineCount) { return @() }
        [void]$intervals.Add([pscustomobject]@{ Start = $a; End = $b })
    }
    return @($intervals)
}

function Get-ExpectedHeadingLocation {
    param(
        [Parameter(Mandatory)][string] $Context,
        [Parameter(Mandatory)][AllowEmptyCollection()][object[]] $Headings,
        [Parameter(Mandatory)][string] $CurrentLocation
    )
    $sourceWords = @(Get-StrongWords $Context)
    if ($sourceWords.Count -eq 0 -or $Headings.Count -eq 0) { return $null }
    $matches = New-Object System.Collections.ArrayList
    foreach ($h in $Headings) {
        $hit = $false
        foreach ($w in $h.Words) {
            if ($sourceWords -contains $w) { $hit = $true; break }
        }
        if ($hit) { [void]$matches.Add($h) }
    }
    if ($matches.Count -eq 0) { return $null }

    # Require a focused match. Generic prose should not claim a whole section.
    $focused = @($matches | Where-Object {
        $h = $_
        @($h.Words | Where-Object { $sourceWords -contains $_ }).Count -ge 1
    })
    if ($focused.Count -eq 0 -or $focused.Count -gt 8) { return $null }

    if ($CurrentLocation.EndsWith('+') -and $focused.Count -eq 1) {
        return ('{0}+' -f $focused[0].Line)
    }
    return (($focused | ForEach-Object {
        if ($_.Line -eq $_.EndLine) { [string]$_.Line } else { '{0}-{1}' -f $_.Line, $_.EndLine }
    }) -join ',')
}

function Get-InlineAnchors {
    param(
        [Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]] $Lines,
        [Parameter(Mandatory)][int] $ZeroIndex,
        [Parameter(Mandatory)][string] $Cite
    )
    $anchors = New-Object System.Collections.ArrayList
    $start = [Math]::Max(0, $ZeroIndex - 2)
    $end = [Math]::Min($Lines.Count - 1, $ZeroIndex + 2)
    for ($i = $start; $i -le $end; $i++) {
        foreach ($m in [regex]::Matches($Lines[$i], '`(?<body>[^`\r\n]+)`')) {
            $body = $m.Groups['body'].Value.Trim()
            if ($body -eq $Cite -or $body -match '\.(?:cs|razor|scss|md|mdc|ps1|json|yml|yaml|txt|ts|tsx|js|go):\d') { continue }
            $ids = @([regex]::Matches($body, '[A-Za-z_][A-Za-z0-9_]*') | ForEach-Object { $_.Value } |
                Where-Object { $_.Length -ge 3 -and -not $stopWords.ContainsKey((Get-WordStem $_)) -and $_ -ne 'new' })
            if ($ids.Count -eq 0) { continue }
            [void]$anchors.Add([pscustomobject]@{
                Body      = $body
                Ids       = $ids
                Distance  = [Math]::Abs($i - $ZeroIndex)
                Direction = if ($i -le $ZeroIndex) { 0 } else { 1 }
            })
        }
    }
    return @($anchors | Sort-Object Distance, Direction, @{ Expression = { -1 * $_.Ids.Count } })
}

function Find-AnchorLines {
    param(
        [Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]] $TargetLines,
        [Parameter(Mandatory)][AllowEmptyCollection()][object[]] $Anchors
    )
    foreach ($a in $Anchors) {
        $hits = New-Object System.Collections.ArrayList
        for ($i = 0; $i -lt $TargetLines.Count; $i++) {
            $ok = $true
            foreach ($id in $a.Ids) {
                if ($TargetLines[$i].IndexOf($id, [StringComparison]::OrdinalIgnoreCase) -lt 0) { $ok = $false; break }
            }
            if ($ok) { [void]$hits.Add($i + 1) }
        }
        if ($hits.Count -gt 0) {
            return [pscustomobject]@{ Anchor = $a.Body; Lines = @($hits) }
        }
    }
    return $null
}

function Test-IsProjectSymbolCandidate {
    param([Parameter(Mandatory)][string] $Symbol, [Parameter(Mandatory)][string] $Context)
    if ($Symbol -notmatch '^[A-Za-z_][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*)*$') { return $false }
    if ($Symbol -cmatch '^[A-Z0-9_]+$') { return $false }
    $caps = ([regex]::Matches($Symbol, '[A-Z]')).Count
    $predicate = $Context -match '(?i)\b(class|struct|interface|record|enum|method|property|field|symbol|exist|exists|implemented|implementation|built|unbuilt|declared|defined|planned)\b'
    $owned = $Symbol -match '^(Lp|LifePunch|Dxura)[A-Z]' -or $Symbol -match '^Lp[A-Za-z0-9_]+\.'
    return ($caps -ge 2 -and ($owned -or $predicate))
}

function Test-NegativeSymbolClaim {
    param([Parameter(Mandatory)][string] $Context)
    return ($Context -match '(?i)\b(does\s+not\s+exist|doesn''t\s+exist|not\s+implemented|not\s+built|unbuilt|absent|never\s+built|zero\s+hits\s+in\s+code)\b')
}

function Find-SymbolDeclarations {
    param([Parameter(Mandatory)][string] $Symbol)
    $parts = @($Symbol -split '\.')
    $name = $parts[$parts.Count - 1]
    $owner = if ($parts.Count -gt 1) { $parts[0] } else { '' }
    if (-not $script:DeclarationIndex.ContainsKey($name)) { return @() }
    $hits = @($script:DeclarationIndex[$name])
    if ($owner) { $hits = @($hits | Where-Object { $_.Owners -contains $owner }) }
    return @($hits | ForEach-Object {
        [pscustomobject]@{ Logical = $_.Logical; Line = $_.Line; Text = $_.Text }
    })
}

function New-DeclarationIndex {
    param(
        [Parameter(Mandatory)][object[]] $CodeFiles,
        [Parameter(Mandatory)][string[]] $RelevantNames
    )
    $index = @{}
    $relevant = @{}
    foreach ($n in $RelevantNames) { $relevant[$n] = $true }
    if ($relevant.Count -eq 0) { return $index }
    $relevantPattern = '\b(?:' + (($RelevantNames | ForEach-Object { [regex]::Escape($_) }) -join '|') + ')\b'
    foreach ($f in $CodeFiles) {
        $lines = @(Get-Content -LiteralPath $f.Physical)
        $owners = New-Object System.Collections.ArrayList
        $pending = New-Object System.Collections.ArrayList
        for ($i = 0; $i -lt $lines.Count; $i++) {
            $line = [string]$lines[$i]
            $trim = $line.TrimStart()
            if ($trim.StartsWith('//') -or $trim.StartsWith('*') -or $trim.StartsWith('/*')) { continue }
            $names = New-Object System.Collections.ArrayList
            foreach ($m in [regex]::Matches($line, '\b(?:class|struct|interface|record|enum)\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)\b')) {
                $typeName = $m.Groups['name'].Value
                if (-not ($owners -contains $typeName)) { [void]$owners.Add($typeName) }
                if ($relevant.ContainsKey($typeName)) { [void]$names.Add($typeName) }
            }
            if ($line -match $relevantPattern) {
                $ps = [regex]::Match($line, '^\s*function\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)\b')
                if ($ps.Success -and $relevant.ContainsKey($ps.Groups['name'].Value)) { [void]$names.Add($ps.Groups['name'].Value) }
                $member = [regex]::Match($line, '^\s*(?:\[[^\]]+\]\s*)*(?:(?:public|private|protected|internal|static|sealed|virtual|override|abstract|partial|readonly|const|async|new|required)\s+)+(?:[A-Za-z_][A-Za-z0-9_<>,?.\[\]]*\s+)+(?<name>[A-Za-z_][A-Za-z0-9_]*)\s*(?:\(|\{|=>|=|;)')
                if ($member.Success -and $relevant.ContainsKey($member.Groups['name'].Value)) { [void]$names.Add($member.Groups['name'].Value) }
            }
            foreach ($name in @($names | Select-Object -Unique)) {
                [void]$pending.Add([pscustomobject]@{
                    Name    = $name
                    Logical = $f.Logical
                    Line    = $i + 1
                    Text    = $line.Trim()
                })
            }
        }
        foreach ($hit in $pending) {
            if (-not $index.ContainsKey($hit.Name)) { $index[$hit.Name] = New-Object System.Collections.ArrayList }
            [void]$index[$hit.Name].Add([pscustomobject]@{
                Logical = $hit.Logical
                Line    = $hit.Line
                Text    = $hit.Text
                Owners  = @($owners)
            })
        }
    }
    return $index
}

# ---------------------------------------------------------------- pin and roots
$repo = if (Test-Path -LiteralPath $RepoRoot -PathType Container) {
    (Resolve-Path -LiteralPath $RepoRoot).Path
} else { Stop-Input "RepoRoot does not resolve to a directory: $RepoRoot" }

$top = ((Invoke-GitRead -WorkingRoot $repo -Arguments @('rev-parse', '--show-toplevel')) -join '').Trim()
if ([IO.Path]::GetFullPath($top).TrimEnd('\', '/') -ne [IO.Path]::GetFullPath($repo).TrimEnd('\', '/')) {
    Stop-Input "RepoRoot is not the Git top level: requested='$repo' actual='$top'"
}
$head = ((Invoke-GitRead -WorkingRoot $repo -Arguments @('rev-parse', 'HEAD')) -join '').Trim().ToLowerInvariant()
if ($head -ne $ExpectedSha.ToLowerInvariant()) {
    Stop-Input "parent pin mismatch: expected=$ExpectedSha actual=$head"
}
$dirty = @((Invoke-GitRead -WorkingRoot $repo -Arguments @('status', '--porcelain=v1', '--untracked-files=all')) | Where-Object { $_ })
if ($dirty.Count -gt 0) {
    Stop-Input "parent worktree is dirty; pin does not attest working bytes: $($dirty -join ' | ')"
}

$resolvedSources = New-Object System.Collections.ArrayList
foreach ($root in $SourceRoots) {
    $candidate = Join-Path $repo ($root -replace '/', '\')
    if (-not (Test-Path -LiteralPath $candidate -PathType Container)) {
        Stop-Input "source root missing: $root ($candidate)"
    }
    [void]$resolvedSources.Add([pscustomobject]@{ Logical = (Get-NormalPath $root); Physical = (Resolve-Path -LiteralPath $candidate).Path })
}

$nestedDefault = Join-Path $repo 'lifepunchdxrp'
if (-not $DxrpRoot -and (Test-Path -LiteralPath $nestedDefault -PathType Container)) { $DxrpRoot = $nestedDefault }
if ($DxrpRoot) {
    if (-not (Test-Path -LiteralPath $DxrpRoot -PathType Container)) { Stop-Input "DxrpRoot missing: $DxrpRoot" }
    if (-not $ExpectedDxrpSha) { Stop-Input 'DxrpRoot is present but -ExpectedDxrpSha was not supplied' }
    $DxrpRoot = (Resolve-Path -LiteralPath $DxrpRoot).Path
    $dxHead = ((Invoke-GitRead -WorkingRoot $DxrpRoot -Arguments @('rev-parse', 'HEAD')) -join '').Trim().ToLowerInvariant()
    if ($dxHead -ne $ExpectedDxrpSha.ToLowerInvariant()) {
        Stop-Input "DXRP pin mismatch: expected=$ExpectedDxrpSha actual=$dxHead"
    }
    $dxDirty = @((Invoke-GitRead -WorkingRoot $DxrpRoot -Arguments @('status', '--porcelain=v1', '--untracked-files=all')) | Where-Object { $_ })
    if ($dxDirty.Count -gt 0) { Stop-Input "DXRP target tree is dirty: $($dxDirty -join ' | ')" }
}
elseif ($ExpectedDxrpSha) { Stop-Input '-ExpectedDxrpSha was supplied without -DxrpRoot' }

# --------------------------------------------------------------- file indexes
$logicalToFile = @{}
$basenameToFiles = @{}
$allIndexed = New-Object System.Collections.ArrayList

function Add-IndexedTree {
    param(
        [Parameter(Mandatory)][string] $PhysicalRoot,
        [Parameter(Mandatory)][AllowEmptyString()][string] $LogicalPrefix,
        [string] $ExcludePhysicalRoot = ''
    )
    foreach ($f in Get-ChildItem -LiteralPath $PhysicalRoot -Recurse -File -Force) {
        if ($f.FullName -match '[\\/]\.git[\\/]' -or $f.Name -eq '.git') { continue }
        if ($ExcludePhysicalRoot -and $f.FullName.StartsWith($ExcludePhysicalRoot.TrimEnd('\') + '\', [StringComparison]::OrdinalIgnoreCase)) { continue }
        $rel = Get-LogicalRelativePath -Root $PhysicalRoot -FullName $f.FullName
        $logical = if ($LogicalPrefix) { (Get-NormalPath ($LogicalPrefix.TrimEnd('/') + '/' + $rel)) } else { Get-NormalPath $rel }
        if ($logicalToFile.ContainsKey($logical)) { Stop-Input "duplicate logical target path: $logical" }
        $entry = [pscustomobject]@{ Logical = $logical; Physical = $f.FullName; Name = $f.Name; Extension = $f.Extension.ToLowerInvariant() }
        $logicalToFile[$logical] = $entry
        if (-not $basenameToFiles.ContainsKey($f.Name)) { $basenameToFiles[$f.Name] = New-Object System.Collections.ArrayList }
        [void]$basenameToFiles[$f.Name].Add($entry)
        [void]$allIndexed.Add($entry)
    }
}

Add-IndexedTree -PhysicalRoot $repo -LogicalPrefix '' -ExcludePhysicalRoot $DxrpRoot
if ($DxrpRoot) { Add-IndexedTree -PhysicalRoot $DxrpRoot -LogicalPrefix 'lifepunchdxrp' }
if ($allIndexed.Count -eq 0) { Stop-Input 'target index is empty' }

$sourceFiles = New-Object System.Collections.ArrayList
foreach ($root in $resolvedSources) {
    foreach ($f in Get-ChildItem -LiteralPath $root.Physical -Recurse -File) {
        if ($f.Extension.ToLowerInvariant() -notin @('.md', '.mdc', '.txt')) { continue }
        [void]$sourceFiles.Add([pscustomobject]@{
            Logical  = Get-LogicalRelativePath -Root $repo -FullName $f.FullName
            Physical = $f.FullName
        })
    }
}
if ($sourceFiles.Count -eq 0) { Stop-Input 'source roots resolved but contain zero .md/.mdc/.txt files' }

$codeFiles = @($allIndexed | Where-Object { $_.Extension -in @('.cs', '.razor', '.ps1') })
if ($codeFiles.Count -eq 0) { Stop-Input 'symbol corpus contains zero .cs/.razor/.ps1 files' }
$relevantSymbolNames = @{}
foreach ($source in $sourceFiles) {
    $preLines = @(Get-Content -LiteralPath $source.Physical)
    $preFence = $false
    for ($pre = 0; $pre -lt $preLines.Count; $pre++) {
        $preLine = [string]$preLines[$pre]
        if ($preLine -match '^\s*(```|~~~)') { $preFence = -not $preFence; if (-not $IncludeFencedCode) { continue } }
        if ($preFence -and -not $IncludeFencedCode) { continue }
        $preContext = Get-ContextWindow -Lines $preLines -ZeroIndex $pre
        foreach ($m in [regex]::Matches($preLine, '`(?<symbol>[A-Za-z_][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*)*)`')) {
            $candidateSymbol = $m.Groups['symbol'].Value
            if (-not (Test-IsProjectSymbolCandidate -Symbol $candidateSymbol -Context $preContext)) { continue }
            $parts = @($candidateSymbol -split '\.')
            $relevantSymbolNames[$parts[$parts.Count - 1]] = $true
            if ($parts.Count -gt 1) { $relevantSymbolNames[$parts[0]] = $true }
        }
    }
}
if ($relevantSymbolNames.Count -eq 0) { Stop-Input "detector 'SYMBOL' extracted zero candidates during declaration preflight" }
$script:DeclarationIndex = New-DeclarationIndex -CodeFiles $codeFiles -RelevantNames @($relevantSymbolNames.Keys)

$pathExt = '(?:cs|razor|scss|md|mdc|ps1|json|yml|yaml|txt|ts|tsx|js|go)'
$fileLineRegex = [regex]::new("(?<path>(?:[A-Za-z]:[\\/])?(?:[A-Za-z0-9_.@()$+\-…]+[\\/])*[A-Za-z0-9_.@()$+\-…]+\.$pathExt):(?<loc>\d+(?:(?:-|,|/)\d+)*\+?)", [Text.RegularExpressions.RegexOptions]::IgnoreCase)
$barePathRegex = [regex]::new("(?<path>(?:[A-Za-z]:[\\/])?(?:[A-Za-z0-9_.@()$+\-…]+[\\/])*[A-Za-z0-9_.@()$+\-…]+\.$pathExt)", [Text.RegularExpressions.RegexOptions]::IgnoreCase)

function Resolve-CitedPath {
    param(
        [Parameter(Mandatory)][string] $CitedPath,
        [Parameter(Mandatory)][string] $SourceLogical
    )
    $raw = Get-NormalPath $CitedPath
    $firstRawSegment = @($raw -split '/')[0]
    $isEllipsis = $raw.StartsWith('…/') -or $firstRawSegment -eq '...' -or $firstRawSegment -match '[^\x00-\x7F]'
    if ($isEllipsis -and $raw.Contains('/')) { $raw = $raw.Substring($raw.IndexOf('/') + 1) }

    if ($raw -match '^[A-Za-z]:/') {
        $full = [IO.Path]::GetFullPath(($raw -replace '/', '\'))
        foreach ($entry in $allIndexed) {
            if ([IO.Path]::GetFullPath($entry.Physical) -eq $full) {
                return [pscustomobject]@{ Status = 'EXACT'; Entry = $entry; NewPath = '' }
            }
        }
        return [pscustomobject]@{ Status = 'OUTSIDE'; Entry = $null; NewPath = '' }
    }

    if (-not $isEllipsis -and $logicalToFile.ContainsKey($raw)) {
        return [pscustomobject]@{ Status = 'EXACT'; Entry = $logicalToFile[$raw]; NewPath = '' }
    }

    $sourceDir = Split-Path ($SourceLogical -replace '/', '\') -Parent
    if ($sourceDir) {
        $relativeCandidate = Get-NormalPath (Join-Path $sourceDir ($raw -replace '/', '\'))
        while ($relativeCandidate.StartsWith('../')) { $relativeCandidate = $relativeCandidate.Substring(3) }
        if ($logicalToFile.ContainsKey($relativeCandidate)) {
            return [pscustomobject]@{ Status = 'EXACT'; Entry = $logicalToFile[$relativeCandidate]; NewPath = '' }
        }
    }

    $suffix = '/' + $raw.TrimStart('/')
    $suffixHits = @($allIndexed | Where-Object { ('/' + $_.Logical).EndsWith($suffix, [StringComparison]::OrdinalIgnoreCase) })
    if ($suffixHits.Count -eq 1) {
        $firstSegment = @($raw -split '/')[0]
        $looksAbbreviated = $isEllipsis -or ($raw -notmatch '/') -or ($firstSegment -match '[^\x00-\x7F]') -or $firstSegment -eq '...'
        return [pscustomobject]@{ Status = $(if ($looksAbbreviated) { 'ABBREVIATED' } else { 'MOVED' }); Entry = $suffixHits[0]; NewPath = $suffixHits[0].Logical }
    }

    $base = Split-Path ($raw -replace '/', '\') -Leaf
    $nameHits = @(if ($basenameToFiles.ContainsKey($base)) { @($basenameToFiles[$base]) } else { @() })
    if ($nameHits.Count -eq 1) {
        return [pscustomobject]@{ Status = $(if ($raw -notmatch '/') { 'ABBREVIATED' } else { 'MOVED' }); Entry = $nameHits[0]; NewPath = $nameHits[0].Logical }
    }
    if ($suffixHits.Count -gt 1 -or $nameHits.Count -gt 1) {
        return [pscustomobject]@{ Status = 'AMBIGUOUS'; Entry = $null; NewPath = '' }
    }
    return [pscustomobject]@{ Status = 'MISSING'; Entry = $null; NewPath = '' }
}

# ---------------------------------------------------------------------- scan
foreach ($source in ($sourceFiles | Sort-Object Logical)) {
    $lines = @(Get-Content -LiteralPath $source.Physical)
    $inFence = $false
    for ($zero = 0; $zero -lt $lines.Count; $zero++) {
        $line = [string]$lines[$zero]
        if ($line -match '^\s*(```|~~~)') {
            $inFence = -not $inFence
            if (-not $IncludeFencedCode) { $script:FencedLinesSkipped++; continue }
        }
        if ($inFence -and -not $IncludeFencedCode) { $script:FencedLinesSkipped++; continue }

        $lineNumber = $zero + 1
        $context = Get-ContextWindow -Lines $lines -ZeroIndex $zero
        $masked = $line

        # FILE:LINE cites are resolved before bare paths so one occurrence cannot
        # quietly count in two universes.
        $fileLineMatches = @($fileLineRegex.Matches($line))
        foreach ($m in $fileLineMatches) {
            $citePath = $m.Groups['path'].Value
            $loc = $m.Groups['loc'].Value
            $citeText = $m.Value
            $resolved = Resolve-CitedPath -CitedPath $citePath -SourceLogical $source.Logical
            if ($resolved.Status -eq 'OUTSIDE') {
                Add-CensusRow PHANTOM FILE-LINE $source.Logical $lineNumber $citeText '' '' 'absolute target is outside every pinned root'
                continue
            }
            if ($resolved.Status -eq 'AMBIGUOUS') {
                Add-CensusRow PHANTOM FILE-LINE $source.Logical $lineNumber $citeText '' '' 'target path is ambiguous; basename-only resolution refused'
                continue
            }
            if ($resolved.Status -eq 'MISSING') {
                if ((Get-NormalPath $citePath).StartsWith('lifepunchdxrp/') -and -not $DxrpRoot) {
                    Stop-Input "cite '$citeText' requires the gitignored DXRP corpus; supply -DxrpRoot and -ExpectedDxrpSha"
                }
                Add-CensusRow PHANTOM FILE-LINE $source.Logical $lineNumber $citeText '' '' 'target file does not exist in the pinned corpus'
                continue
            }
            if ($resolved.Status -eq 'MOVED') {
                Add-CensusRow DRIFT FILE-LINE $source.Logical $lineNumber $citeText $resolved.Entry.Logical ($resolved.NewPath + ':' + $loc) 'target exists only at a different unique path'
                continue
            }

            $targetLines = @(Get-Content -LiteralPath $resolved.Entry.Physical)
            $intervals = @(Convert-LocationToIntervals -Location $loc -LineCount $targetLines.Count)
            if ($intervals.Count -eq 0) {
                Add-CensusRow PHANTOM FILE-LINE $source.Logical $lineNumber $citeText $resolved.Entry.Logical '' "line/range is outside target bounds (lines=$($targetLines.Count))"
                continue
            }

            $contextWithoutCites = $fileLineRegex.Replace($context, ' ')
            if ($resolved.Entry.Extension -in @('.md', '.mdc')) {
                $headings = @(Get-MarkdownHeadings -Lines $targetLines)
                $expectedLoc = Get-ExpectedHeadingLocation -Context $contextWithoutCites -Headings $headings -CurrentLocation $loc
                if ($expectedLoc) {
                    if ($expectedLoc -eq $loc) {
                        Add-CensusRow HOLD FILE-LINE $source.Logical $lineNumber $citeText $resolved.Entry.Logical '' "markdown heading span verified at :$expectedLoc"
                    }
                    else {
                        Add-CensusRow DRIFT FILE-LINE $source.Logical $lineNumber $citeText $resolved.Entry.Logical $expectedLoc "markdown heading span resolves at :$expectedLoc"
                    }
                    continue
                }
            }

            $anchors = @(Get-InlineAnchors -Lines $lines -ZeroIndex $zero -Cite $citeText)
            $anchorHit = Find-AnchorLines -TargetLines $targetLines -Anchors $anchors
            if ($null -eq $anchorHit) {
                Add-CensusRow PHANTOM FILE-LINE $source.Logical $lineNumber $citeText $resolved.Entry.Logical '' 'no deterministic nearby content anchor resolves in target; HOLD refused'
                continue
            }
            $inside = @($anchorHit.Lines | Where-Object { Test-IntervalsContainLine -Intervals $intervals -Line $_ })
            if ($inside.Count -gt 0) {
                Add-CensusRow HOLD FILE-LINE $source.Logical $lineNumber $citeText $resolved.Entry.Logical '' "content anchor '$($anchorHit.Anchor)' verified in cited bytes"
            }
            elseif ($anchorHit.Lines.Count -eq 1) {
                Add-CensusRow DRIFT FILE-LINE $source.Logical $lineNumber $citeText $resolved.Entry.Logical ([string]$anchorHit.Lines[0]) "content anchor '$($anchorHit.Anchor)' resolves uniquely at new line"
            }
            else {
                # A repeated short anchor can still resolve deterministically when
                # exactly one occurrence is nearest the cited interval. Ties stay
                # PHANTOM: proximity is a disambiguator, never a license to guess.
                $ranked = @($anchorHit.Lines | ForEach-Object {
                    $candidate = [int]$_
                    $distance = ($intervals | ForEach-Object {
                        if ($candidate -lt $_.Start) { $_.Start - $candidate }
                        elseif ($candidate -gt $_.End) { $candidate - $_.End }
                        else { 0 }
                    } | Measure-Object -Minimum).Minimum
                    [pscustomobject]@{ Line = $candidate; Distance = [int]$distance }
                } | Sort-Object Distance, Line)
                $nearest = @($ranked | Where-Object Distance -eq $ranked[0].Distance)
                if ($nearest.Count -eq 1) {
                    Add-CensusRow DRIFT FILE-LINE $source.Logical $lineNumber $citeText $resolved.Entry.Logical ([string]$nearest[0].Line) "content anchor '$($anchorHit.Anchor)' repeats; unique nearest occurrence resolves at new line"
                }
                else {
                    Add-CensusRow PHANTOM FILE-LINE $source.Logical $lineNumber $citeText $resolved.Entry.Logical '' "content anchor '$($anchorHit.Anchor)' is ambiguous at lines $($anchorHit.Lines -join ','); nearest-distance tie; HOLD refused"
                }
            }
        }
        for ($mi = $fileLineMatches.Count - 1; $mi -ge 0; $mi--) {
            $m = $fileLineMatches[$mi]
            $masked = $masked.Remove($m.Index, $m.Length).Insert($m.Index, (' ' * $m.Length))
        }

        # Bare path cites.
        $bareMatches = @($barePathRegex.Matches($masked))
        foreach ($m in $bareMatches) {
            $citePath = $m.Groups['path'].Value
            $resolved = Resolve-CitedPath -CitedPath $citePath -SourceLogical $source.Logical
            switch ($resolved.Status) {
                'EXACT'       { Add-CensusRow HOLD BARE-PATH $source.Logical $lineNumber $citePath $resolved.Entry.Logical '' 'exact pinned path exists' }
                'ABBREVIATED' { Add-CensusRow HOLD BARE-PATH $source.Logical $lineNumber $citePath $resolved.Entry.Logical '' 'ellipsis suffix resolves uniquely in pinned corpus' }
                'MOVED'       { Add-CensusRow DRIFT BARE-PATH $source.Logical $lineNumber $citePath $resolved.Entry.Logical $resolved.NewPath 'cited path is absent; unique moved target found' }
                'OUTSIDE'     { Add-CensusRow PHANTOM BARE-PATH $source.Logical $lineNumber $citePath '' '' 'absolute target is outside every pinned root' }
                'AMBIGUOUS'   { Add-CensusRow PHANTOM BARE-PATH $source.Logical $lineNumber $citePath '' '' 'target path is ambiguous; basename-only HOLD refused' }
                default {
                    if ((Get-NormalPath $citePath).StartsWith('lifepunchdxrp/') -and -not $DxrpRoot) {
                        Stop-Input "cite '$citePath' requires the gitignored DXRP corpus; supply -DxrpRoot and -ExpectedDxrpSha"
                    }
                    Add-CensusRow PHANTOM BARE-PATH $source.Logical $lineNumber $citePath '' '' 'target file does not exist in the pinned corpus'
                }
            }
        }
        for ($mi = $bareMatches.Count - 1; $mi -ge 0; $mi--) {
            $m = $bareMatches[$mi]
            $masked = $masked.Remove($m.Index, $m.Length).Insert($m.Index, (' ' * $m.Length))
        }

        # Project symbol cites: exact inline-code tokens only. This deliberately
        # excludes platform/BCL symbols such as MathF; those require compile-class
        # resolution and are named as a tradeoff in the design note.
        foreach ($m in [regex]::Matches($masked, '`(?<symbol>[A-Za-z_][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*)*)`')) {
            $symbol = $m.Groups['symbol'].Value
            if (-not (Test-IsProjectSymbolCandidate -Symbol $symbol -Context $context)) { continue }
            $negative = Test-NegativeSymbolClaim -Context $context
            $decls = @(Find-SymbolDeclarations -Symbol $symbol)
            if ($negative) {
                if ($decls.Count -eq 0) {
                    Add-CensusRow HOLD SYMBOL $source.Logical $lineNumber $symbol '' '' 'negative symbol assertion verified: no declaration in pinned code corpus'
                }
                else {
                    $where = ($decls | ForEach-Object { "$($_.Logical):$($_.Line)" }) -join ','
                    Add-CensusRow DRIFT SYMBOL $source.Logical $lineNumber $symbol $where $where 'negative symbol assertion is stale; declaration now exists'
                }
            }
            elseif ($decls.Count -eq 0) {
                Add-CensusRow PHANTOM SYMBOL $source.Logical $lineNumber $symbol '' '' 'positive project-symbol assertion has no declaration in pinned code corpus'
            }
            else {
                $where = ($decls | ForEach-Object { "$($_.Logical):$($_.Line)" }) -join ','
                Add-CensusRow HOLD SYMBOL $source.Logical $lineNumber $symbol $where '' 'declaration-aware grep resolved project symbol'
            }
        }
    }
}

# ------------------------------------------------------------ denominator gate
if ($script:Results.Count -eq 0) { Stop-Input 'zero citations extracted; vacuous PASS refused' }
foreach ($form in @('BARE-PATH', 'FILE-LINE', 'SYMBOL')) {
    if ($script:FormCounts[$form] -eq 0) { Stop-Input "detector '$form' extracted zero cites; partial/vacuous census refused" }
}
$sum = ($script:FormCounts.Values | Measure-Object -Sum).Sum
if ($sum -ne $script:Results.Count) { Stop-Internal "denominator mismatch: forms=$sum rows=$($script:Results.Count)" }

$ordered = @($script:Results | Sort-Object CitingFile, CitingLine, Form, Cite)
function Convert-TableCell {
    param([AllowEmptyString()][string] $Value)
    return (($Value -replace '\r?\n', ' ') -replace '\|', '\|').Trim()
}
Write-Output '| Verdict | Form | Citing file | Line | Cite | Resolved target | New line/path | Reason |'
Write-Output '|---|---|---|---:|---|---|---|---|'
foreach ($row in $ordered) {
    Write-Output ('| {0} | {1} | {2} | {3} | {4} | {5} | {6} | {7} |' -f
        (Convert-TableCell $row.Verdict),
        (Convert-TableCell $row.Form),
        (Convert-TableCell $row.CitingFile),
        $row.CitingLine,
        (Convert-TableCell $row.Cite),
        (Convert-TableCell $row.ResolvedTarget),
        (Convert-TableCell $row.NewLine),
        (Convert-TableCell $row.Reason))
}

$hold = @($ordered | Where-Object Verdict -eq 'HOLD').Count
$drift = @($ordered | Where-Object Verdict -eq 'DRIFT').Count
$phantom = @($ordered | Where-Object Verdict -eq 'PHANTOM').Count
Write-Output ''
Write-Output ("CENSUS pin={0} sources={1} targets={2} fencedLinesSkipped={3}" -f $head, $sourceFiles.Count, $allIndexed.Count, $script:FencedLinesSkipped)
Write-Output ("DENOMINATOR total={0} barePath={1} fileLine={2} symbol={3}" -f $ordered.Count, $script:FormCounts['BARE-PATH'], $script:FormCounts['FILE-LINE'], $script:FormCounts['SYMBOL'])
Write-Output ("VERDICT HOLD={0} DRIFT={1} PHANTOM={2}" -f $hold, $drift, $phantom)

if ($drift -gt 0 -or $phantom -gt 0) {
    Write-Output 'GATE: FAIL - every DRIFT/PHANTOM must be corrected or explicitly ruled; no silent exemption exists.'
    exit 2
}
Write-Output 'GATE: PASS - all three non-zero cite-form denominators resolved HOLD.'
exit 0
