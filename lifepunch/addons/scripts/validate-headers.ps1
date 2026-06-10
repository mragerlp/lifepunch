$ErrorActionPreference = 'Stop'

# Source tree to scan = the LifePunch root (lifepunch/**); this script lives at
# lifepunch/addons/scripts/, so ..\.. is lifepunch/ and ..\..\.. is the repo root
# (used only to print repo-relative paths).
$SourceRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path

$SourceExtensions = @('.cs', '.razor', '.scss')
$ExcludeSegments = @('reference', '.dxrp-publish', 'obj', 'bin', 'node_modules')
$Marker = 'PROPRIETARY & CONFIDENTIAL'
$Dash = [char]0x2014   # em dash, kept as a code point so the file stays ASCII

$Violations = New-Object System.Collections.Generic.List[string]

function Get-HeaderViolation {
    <#
      Returns $null if the file carries the proprietary header correctly, otherwise
      a reason string. PASS = a comment line containing the marker appears in the
      preamble (only blank/comment lines before it); FAIL = marker missing, or it
      only appears after real code has started.
    #>
    param(
        [string]$Path,
        [string]$Extension
    )

    if ($Extension -eq '.razor') {
        $LineToken = $null            # razor has no line-comment form we rely on
        $BlockOpen = '@*'
        $BlockClose = '*@'
    } else {
        $LineToken = '//'             # .cs, .scss
        $BlockOpen = '/*'
        $BlockClose = '*/'
    }

    $InBlock = $false
    $PreambleMarker = $false
    $CodeStarted = $false

    foreach ($Raw in (Get-Content -LiteralPath $Path)) {
        $Line = $Raw.TrimStart([char]0xFEFF).Trim()   # strip BOM + surrounding space

        if ($InBlock) {
            if ($Line -like "*$Marker*") { $PreambleMarker = $true }
            $CloseIndex = $Line.IndexOf($BlockClose)
            if ($CloseIndex -ge 0) {
                $InBlock = $false
                $After = $Line.Substring($CloseIndex + $BlockClose.Length).Trim()
                if ($After -ne '') { $CodeStarted = $true; break }
            }
            continue
        }

        if ($Line -eq '') { continue }   # blank lines are allowed before the marker

        if ($null -ne $LineToken -and $Line.StartsWith($LineToken)) {
            if ($Line -like "*$Marker*") { $PreambleMarker = $true }
            continue
        }

        if ($Line.StartsWith($BlockOpen)) {
            if ($Line -like "*$Marker*") { $PreambleMarker = $true }
            $CloseIndex = $Line.IndexOf($BlockClose, $BlockOpen.Length)
            if ($CloseIndex -ge 0) {
                $After = $Line.Substring($CloseIndex + $BlockClose.Length).Trim()
                if ($After -ne '') { $CodeStarted = $true; break }
            } else {
                $InBlock = $true
            }
            continue
        }

        # Anything else is real code (using/namespace/#if, @-directive/markup, style rule).
        $CodeStarted = $true
        break
    }

    if ($PreambleMarker) { return $null }

    if ((Get-Content -LiteralPath $Path -Raw) -like "*$Marker*") {
        return 'PROPRIETARY header present but appears after code starts'
    }
    return 'missing PROPRIETARY & CONFIDENTIAL header'
}

$Files = Get-ChildItem -LiteralPath $SourceRoot -Recurse -File -Force -ErrorAction SilentlyContinue |
    Where-Object { $SourceExtensions -contains $_.Extension.ToLowerInvariant() }

$Scanned = 0
foreach ($File in $Files) {
    $Relative = $File.FullName.Substring($RepoRoot.Length).TrimStart('\') -replace '\\', '/'
    $Segments = $Relative -split '/'
    if (($Segments | Where-Object { $ExcludeSegments -contains $_ })) { continue }

    $Scanned++
    $Reason = Get-HeaderViolation -Path $File.FullName -Extension $File.Extension.ToLowerInvariant()
    if ($null -ne $Reason) {
        $Violations.Add("$Relative $Dash $Reason") | Out-Null
    }
}

Write-Host "Scanned $Scanned source file(s) (.cs/.razor/.scss) under lifepunch/."

if ($Violations.Count -gt 0) {
    foreach ($Violation in $Violations) {
        Write-Host " - $Violation" -ForegroundColor Red
    }
    Write-Host "Header validation FAILED: $($Violations.Count) file(s)." -ForegroundColor Red
    exit 1
}

Write-Host 'Header validation passed.' -ForegroundColor Green
exit 0
