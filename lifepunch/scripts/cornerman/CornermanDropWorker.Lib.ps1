# =====================================================================
# RISK: READ-ONLY (validation + report only)  |  Slice 1 -- dry-run
# NODE: Green (Cornerman) -- testable on Red with scratch dirs
# WHAT: Shared functions for the Cornerman headless drop worker.
#       Packet schema validation, repo-profile registry, clone identity,
#       dirty-tree gate, input path safety, no-IP / AI-trailer scan,
#       lock handling, outbox/ack/history/log writers.
# LAW:  lifepunch/docs/handoff/CORNERMAN_HEADLESS_DROP_WORKER_OPUS_V2_PLAN_2026-07-06.md
#       (Part B authoritative). Slice 1: NO model calls, NO scheduler,
#       NO patches, NO commit/push, NO git mutation of any kind.
# =====================================================================

Set-StrictMode -Version Latest

# ---------------------------------------------------------------------
# Paths (worker-local defaults; LifePunch-RepoPaths.ps1 refactor = later slice)
# ---------------------------------------------------------------------

function Get-CdwDefaultPaths {
    param([string] $BaseDir = 'C:\lifepunch\cornerman')
    [pscustomobject]@{
        Inbox    = Join-Path $BaseDir 'inbox'
        Outbox   = Join-Path $BaseDir 'outbox'
        History  = Join-Path $BaseDir 'history'
        Logs     = Join-Path $BaseDir 'logs'
        Lock     = Join-Path $BaseDir 'lock'
        Registry = Join-Path $BaseDir 'config\repo-profiles.json'
        AckLog   = Join-Path $BaseDir 'outbox\workflow-ack.ndjson'
    }
}

function Initialize-CdwFolders {
    param([Parameter(Mandatory)] $Paths)
    foreach ($p in @($Paths.Inbox, $Paths.Outbox, $Paths.History, $Paths.Logs, $Paths.Lock)) {
        if (-not (Test-Path -LiteralPath $p)) {
            New-Item -ItemType Directory -Force -Path $p | Out-Null
        }
    }
}

function Write-CdwUtf8NoBom {
    param(
        [Parameter(Mandatory)][string] $Path,
        [Parameter(Mandatory)][AllowEmptyString()][string] $Text
    )
    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [IO.File]::WriteAllText($Path, $Text, $utf8)
}

function Write-CdwLog {
    param(
        [Parameter(Mandatory)][string] $LogDir,
        [Parameter(Mandatory)][string] $Message
    )
    if (-not (Test-Path -LiteralPath $LogDir)) {
        New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
    }
    $file = Join-Path $LogDir ("worker-{0}.log" -f (Get-Date -Format 'yyyyMMdd'))
    $line = "[{0}] {1}" -f ((Get-Date).ToUniversalTime().ToString('o')), $Message
    Add-Content -LiteralPath $file -Value $line -Encoding UTF8
}

# ---------------------------------------------------------------------
# Lock -- one worker run at a time
# ---------------------------------------------------------------------

function Lock-CdwWorker {
    <#
    .SYNOPSIS
      Acquire the single-run lock. Returns @{Ok; Reason; LockFile}.
      Stale lock (dead pid or age > StaleMinutes) is reclaimed with a warning.
    #>
    param(
        [Parameter(Mandatory)][string] $LockDir,
        [int] $StaleMinutes = 30
    )
    if (-not (Test-Path -LiteralPath $LockDir)) {
        New-Item -ItemType Directory -Force -Path $LockDir | Out-Null
    }
    $lockFile = Join-Path $LockDir 'worker.lock'

    if (Test-Path -LiteralPath $lockFile) {
        $stale = $false
        $why = ''
        try {
            $existing = Get-Content -LiteralPath $lockFile -Raw | ConvertFrom-Json
            $started = [datetime]::Parse($existing.startedUtc).ToUniversalTime()
            $ageMin = ((Get-Date).ToUniversalTime() - $started).TotalMinutes
            $procAlive = $false
            if ($existing.pid) {
                $procAlive = [bool](Get-Process -Id ([int]$existing.pid) -ErrorAction SilentlyContinue)
            }
            if (-not $procAlive) { $stale = $true; $why = "pid $($existing.pid) not running" }
            elseif ($ageMin -gt $StaleMinutes) { $stale = $true; $why = ("age {0:n1} min > {1}" -f $ageMin, $StaleMinutes) }
        }
        catch {
            $stale = $true
            $why = "unreadable lock file: $($_.Exception.Message)"
        }
        if (-not $stale) {
            return @{ Ok = $false; Reason = 'busy -- lock held by live worker'; LockFile = $lockFile }
        }
        Remove-Item -LiteralPath $lockFile -Force -ErrorAction SilentlyContinue
        # caller should log the reclaim
        $script:CdwLockReclaimNote = "stale lock reclaimed ($why)"
    }

    $payload = @{
        pid        = $PID
        host       = $env:COMPUTERNAME
        startedUtc = (Get-Date).ToUniversalTime().ToString('o')
    } | ConvertTo-Json -Compress
    try {
        # CreateNew = atomic exclusive create
        $fs = [IO.File]::Open($lockFile, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
        try {
            $bytes = [Text.Encoding]::UTF8.GetBytes($payload)
            $fs.Write($bytes, 0, $bytes.Length)
        }
        finally { $fs.Dispose() }
    }
    catch {
        return @{ Ok = $false; Reason = "lock create raced: $($_.Exception.Message)"; LockFile = $lockFile }
    }
    return @{ Ok = $true; Reason = 'acquired'; LockFile = $lockFile }
}

function Unlock-CdwWorker {
    param([Parameter(Mandatory)][string] $LockDir)
    $lockFile = Join-Path $LockDir 'worker.lock'
    Remove-Item -LiteralPath $lockFile -Force -ErrorAction SilentlyContinue
}

# ---------------------------------------------------------------------
# Profile registry
# ---------------------------------------------------------------------

function Read-CdwProfileRegistry {
    param([Parameter(Mandatory)][string] $Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        return @{ Ok = $false; Error = "profile registry missing: $Path"; Registry = $null }
    }
    try {
        $reg = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    }
    catch {
        return @{ Ok = $false; Error = "profile registry unreadable: $($_.Exception.Message)"; Registry = $null }
    }
    if (-not ($reg.PSObject.Properties.Name -contains 'profiles')) {
        return @{ Ok = $false; Error = 'profile registry has no "profiles" object'; Registry = $null }
    }
    return @{ Ok = $true; Error = $null; Registry = $reg }
}

function Resolve-CdwProfile {
    <#
    .SYNOPSIS
      Map packet.repoProfile -> registry profile entry. Fails closed on unknown profile.
    #>
    param(
        [Parameter(Mandatory)] $Packet,
        [Parameter(Mandatory)] $Registry
    )
    $name = [string]$Packet.repoProfile
    $entry = $Registry.profiles.PSObject.Properties |
        Where-Object { $_.Name -eq $name } |
        Select-Object -First 1
    if (-not $entry) {
        return @{ Ok = $false; Error = "unknown repoProfile '$name' -- not in registry"; Profile = $null; Name = $name }
    }
    return @{ Ok = $true; Error = $null; Profile = $entry.Value; Name = $name }
}

# ---------------------------------------------------------------------
# Packet schema validation (worker-side; mirrors cornerman-task-packet.schema.json)
# ---------------------------------------------------------------------

function Test-CdwPacketSchema {
    <#
    .SYNOPSIS
      Validate required fields + enums of a v2 task packet. Returns @{Ok; Errors[]}.
      Slice 1 additionally rejects mode=candidate-patch outright.
    #>
    param([Parameter(Mandatory)] $Packet)

    $errors = New-Object System.Collections.Generic.List[string]
    function Test-Has([object]$obj, [string]$name) {
        return ($null -ne $obj) -and ($obj.PSObject.Properties.Name -contains $name) -and ($null -ne $obj.$name)
    }

    # schemaVersion
    if (-not (Test-Has $Packet 'schemaVersion') -or [int]$Packet.schemaVersion -ne 2) {
        $errors.Add('schemaVersion must be 2')
    }

    # required scalar fields
    foreach ($f in @('id', 'type', 'createdBy', 'createdTs', 'repoProfile', 'repoPath',
            'baseRemote', 'baseBranch', 'focus', 'routeTag', 'instruction', 'mode')) {
        if (-not (Test-Has $Packet $f) -or [string]::IsNullOrWhiteSpace([string]$Packet.$f)) {
            $errors.Add("missing required field: $f")
        }
    }
    # required non-scalar fields
    foreach ($f in @('inputs', 'allowedOutputTypes', 'forbiddenScope', 'deliverable')) {
        if (-not (Test-Has $Packet $f)) { $errors.Add("missing required field: $f") }
    }
    if (-not (Test-Has $Packet 'requiresMaintainerApproval')) {
        $errors.Add('missing required field: requiresMaintainerApproval')
    }

    if ($errors.Count -gt 0) { return @{ Ok = $false; Errors = @($errors) } }

    # enums
    if ([string]$Packet.repoProfile -notin @('lifepunch-private', 'dxrp-official')) {
        $errors.Add("repoProfile must be 'lifepunch-private' or 'dxrp-official' (got '$($Packet.repoProfile)')")
    }
    if ([string]$Packet.baseRemote -notin @('origin', 'upstream')) {
        $errors.Add("baseRemote must be 'origin' or 'upstream' (got '$($Packet.baseRemote)')")
    }
    if ([string]$Packet.baseBranch -notin @('main', 'develop')) {
        $errors.Add("baseBranch must be 'main' or 'develop' (got '$($Packet.baseBranch)')")
    }
    if ([string]$Packet.focus -notin @('LifePunch', 'DXRP')) {
        $errors.Add("focus must be 'LifePunch' or 'DXRP' (got '$($Packet.focus)')")
    }
    if ([string]$Packet.routeTag -notin @('GREEN DEEP REQUIRED', 'GREEN CODE REQUIRED', 'AUTO OK')) {
        $errors.Add("routeTag invalid (got '$($Packet.routeTag)')")
    }
    if ([string]$Packet.mode -notin @('report', 'candidate-patch')) {
        $errors.Add("mode must be 'report' or 'candidate-patch' (got '$($Packet.mode)')")
    }
    elseif ([string]$Packet.mode -eq 'candidate-patch') {
        # Lifecycle contract allows the value; the Slice 1 worker refuses to run it.
        $errors.Add('mode=candidate-patch is not available in Slice 1 (report mode only; separate Bloodwave GO required)')
    }

    if ([string]$Packet.id -notmatch '^task-\d{8}-\d{6}-[a-z0-9][a-z0-9-]*$') {
        $errors.Add("id must match task-YYYYMMDD-HHmmss-<slug> (got '$($Packet.id)')")
    }

    # inputs
    $inputs = $Packet.inputs
    $hasFiles = ($inputs.PSObject.Properties.Name -contains 'readFiles') -and $inputs.readFiles -and @($inputs.readFiles).Count -gt 0
    $hasGlobs = ($inputs.PSObject.Properties.Name -contains 'readGlobs') -and $inputs.readGlobs -and @($inputs.readGlobs).Count -gt 0
    if (-not ($hasFiles -or $hasGlobs)) {
        $errors.Add('inputs must include at least one of readFiles / readGlobs')
    }
    if (-not ($inputs.PSObject.Properties.Name -contains 'maxBytes') -or [long]$inputs.maxBytes -lt 1) {
        $errors.Add('inputs.maxBytes required (>= 1)')
    }

    # allowedOutputTypes
    if (@($Packet.allowedOutputTypes).Count -lt 1) {
        $errors.Add('allowedOutputTypes must list at least one type')
    }

    # deliverable
    $d = $Packet.deliverable
    if (-not ($d.PSObject.Properties.Name -contains 'outboxName') -or [string]::IsNullOrWhiteSpace([string]$d.outboxName)) {
        $errors.Add('deliverable.outboxName required')
    }
    elseif ([string]$d.outboxName -match '[\\/\.]') {
        $errors.Add('deliverable.outboxName must not contain path separators or dots')
    }
    if (-not ($d.PSObject.Properties.Name -contains 'format') -or [string]$d.format -notin @('markdown', 'json', 'text')) {
        $errors.Add('deliverable.format must be markdown | json | text')
    }

    return @{ Ok = ($errors.Count -eq 0); Errors = @($errors) }
}

# ---------------------------------------------------------------------
# Profile-law validations
# ---------------------------------------------------------------------

function Test-CdwFocusAgreement {
    param([Parameter(Mandatory)] $Packet)
    $map = @{ 'lifepunch-private' = 'LifePunch'; 'dxrp-official' = 'DXRP' }
    $expected = $map[[string]$Packet.repoProfile]
    if ([string]$Packet.focus -ne $expected) {
        return @{ Ok = $false; Error = "focus '$($Packet.focus)' does not agree with repoProfile '$($Packet.repoProfile)' (expected '$expected')" }
    }
    return @{ Ok = $true; Error = $null }
}

function Test-CdwBranchLaw {
    param(
        [Parameter(Mandatory)] $Packet,
        [Parameter(Mandatory)] $Profile
    )
    $law = $Profile.branchLaw
    if ([string]$Packet.baseRemote -ne [string]$law.baseRemote) {
        return @{ Ok = $false; Error = "baseRemote '$($Packet.baseRemote)' violates profile law (must be '$($law.baseRemote)')" }
    }
    if ([string]$Packet.baseBranch -notin @($law.allowedBaseBranches)) {
        return @{ Ok = $false; Error = "baseBranch '$($Packet.baseBranch)' not allowed for this profile (allowed: $($law.allowedBaseBranches -join ', '))" }
    }
    return @{ Ok = $true; Error = $null }
}

function Test-CdwCloneIdentity {
    <#
    .SYNOPSIS
      Verify the resolved clone exists and its git remotes match the profile registry.
      Read-only: uses `git remote get-url` only. Tolerates https/ssh forms and .git suffix.
    #>
    param([Parameter(Mandatory)] $Profile)

    $clone = [string]$Profile.cloneWindows
    if (-not (Test-Path -LiteralPath (Join-Path $clone '.git'))) {
        return @{ Ok = $false; Error = "Green clone missing or not a git repo: $clone" }
    }
    foreach ($prop in $Profile.expectedRemotes.PSObject.Properties) {
        $remoteName = $prop.Name
        $expectedSlug = [string]$prop.Value   # e.g. mragerlp/lifepunch
        $url = (& git -C $clone remote get-url $remoteName 2>$null)
        if ($LASTEXITCODE -ne 0 -or -not $url) {
            return @{ Ok = $false; Error = "clone $clone has no remote '$remoteName' (expected $expectedSlug)" }
        }
        $urlNorm = ([string]$url).Trim().TrimEnd('/') -replace '\.git$', ''
        $urlNorm = $urlNorm -replace ':', '/'   # normalize ssh git@host:owner/repo
        if ($urlNorm -notlike "*$expectedSlug") {
            return @{ Ok = $false; Error = "clone $clone remote '$remoteName' is '$url' -- expected slug '$expectedSlug'" }
        }
    }
    return @{ Ok = $true; Error = $null }
}

function Test-CdwCloneDirty {
    <#
    .SYNOPSIS
      Dirty-tree gate. Untracked files count as dirty in v1. Read-only (git status --porcelain).
    #>
    param([Parameter(Mandatory)][string] $ClonePath)
    $out = (& git -C $ClonePath status --porcelain 2>&1)
    if ($LASTEXITCODE -ne 0) {
        return @{ Ok = $false; Dirty = $true; Error = "git status failed in ${ClonePath}: $out" }
    }
    $lines = @($out | Where-Object { $_ -and ([string]$_).Trim() })
    if ($lines.Count -gt 0) {
        $sample = ($lines | Select-Object -First 8) -join '; '
        return @{ Ok = $false; Dirty = $true; Error = "clone dirty ($($lines.Count) entr$(if($lines.Count -eq 1){'y'}else{'ies'}), untracked counts as dirty in v1): $sample" }
    }
    return @{ Ok = $true; Dirty = $false; Error = $null }
}

function Test-CdwBaseRefReadable {
    <#
    .SYNOPSIS
      SIMULATED branch-sync step for Slice 1: verify <baseRemote>/<baseBranch> resolves locally.
      NO fetch, NO checkout, NO pull. Missing ref = warning (clone may simply be un-fetched).
    #>
    param(
        [Parameter(Mandatory)] $Packet,
        [Parameter(Mandatory)] $Profile
    )
    $ref = "$($Packet.baseRemote)/$($Packet.baseBranch)"
    & git -C ([string]$Profile.cloneWindows) rev-parse --verify --quiet $ref 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        return @{ Ok = $true; Warning = "base ref '$ref' not resolvable locally (no fetch performed in Slice 1 dry-run)" }
    }
    return @{ Ok = $true; Warning = $null }
}

# ---------------------------------------------------------------------
# Input path safety
# ---------------------------------------------------------------------

function Test-CdwInputPaths {
    <#
    .SYNOPSIS
      Validate readFiles/readGlobs: repo-relative only, no absolute paths, no '..',
      profile forbid-prefixes (dxrp-official must never read lifepunch/**), existence,
      and total size <= inputs.maxBytes. Globs are validated for shape only in Slice 1.
    #>
    param(
        [Parameter(Mandatory)] $Packet,
        [Parameter(Mandatory)] $Profile
    )
    $errors = New-Object System.Collections.Generic.List[string]
    $clone = [string]$Profile.cloneWindows
    $maxBytes = [long]$Packet.inputs.maxBytes
    $totalBytes = [long]0

    $forbidPrefixes = @()
    if ($Profile.PSObject.Properties.Name -contains 'forbidInputPrefixes' -and $Profile.forbidInputPrefixes) {
        $forbidPrefixes = @($Profile.forbidInputPrefixes)
    }

    $readFiles = @()
    if ($Packet.inputs.PSObject.Properties.Name -contains 'readFiles' -and $Packet.inputs.readFiles) {
        $readFiles = @($Packet.inputs.readFiles)
    }
    $readGlobs = @()
    if ($Packet.inputs.PSObject.Properties.Name -contains 'readGlobs' -and $Packet.inputs.readGlobs) {
        $readGlobs = @($Packet.inputs.readGlobs)
    }

    foreach ($rel in ($readFiles + $readGlobs)) {
        $r = [string]$rel
        if ($r -match '^[A-Za-z]:' -or $r.StartsWith('\\') -or $r.StartsWith('/') -or $r.StartsWith('\')) {
            $errors.Add("input path must be repo-relative (absolute rejected): $r")
            continue
        }
        if ($r -match '(^|[\\/])\.\.([\\/]|$)') {
            $errors.Add("input path traversal ('..') rejected: $r")
            continue
        }
        $rNorm = $r -replace '\\', '/'
        foreach ($prefix in $forbidPrefixes) {
            $pNorm = ([string]$prefix) -replace '\\', '/'
            if ($rNorm.StartsWith($pNorm, [System.StringComparison]::OrdinalIgnoreCase)) {
                $errors.Add("input path '$r' is under forbidden prefix '$prefix' for profile '$($Packet.repoProfile)'")
            }
        }
    }

    if ($errors.Count -eq 0) {
        foreach ($rel in $readFiles) {
            $full = Join-Path $clone (([string]$rel) -replace '/', '\')
            if (-not (Test-Path -LiteralPath $full -PathType Leaf)) {
                $errors.Add("input file not found in clone: $rel")
                continue
            }
            $totalBytes += (Get-Item -LiteralPath $full).Length
        }
        if ($totalBytes -gt $maxBytes) {
            $errors.Add("total input bytes $totalBytes exceed inputs.maxBytes $maxBytes")
        }
    }

    return @{ Ok = ($errors.Count -eq 0); Errors = @($errors); TotalBytes = $totalBytes }
}

# ---------------------------------------------------------------------
# Forbidden-scope check
# ---------------------------------------------------------------------

function Test-CdwForbiddenScope {
    <#
    .SYNOPSIS
      Reject tasks whose instruction/context touches a forbiddenScope token
      (e.g. permissions-backend) without explicit approval. Slice 1 has no
      approval flag mechanism -> any hit fails closed.
    #>
    param([Parameter(Mandatory)] $Packet)
    $scopeTokens = @($Packet.forbiddenScope) | Where-Object { $_ }
    if ($scopeTokens.Count -eq 0) { return @{ Ok = $true; Error = $null } }

    $texts = @([string]$Packet.instruction)
    if ($Packet.inputs.PSObject.Properties.Name -contains 'contextNotes' -and $Packet.inputs.contextNotes) {
        $texts += [string]$Packet.inputs.contextNotes
    }
    foreach ($token in $scopeTokens) {
        # 'lifepunch-ip' style meta-tokens guard outputs, not instruction text
        if ([string]$token -eq 'lifepunch-ip') { continue }
        foreach ($t in $texts) {
            if ($t -match [regex]::Escape([string]$token)) {
                return @{ Ok = $false; Error = "task text touches forbiddenScope '$token' -- rejected (no explicit approval mechanism in Slice 1)" }
            }
        }
    }
    return @{ Ok = $true; Error = $null }
}

# ---------------------------------------------------------------------
# No-IP / AI-trailer scan (dxrp-official)
# ---------------------------------------------------------------------

# Blocked private identifiers/content. Case-sensitive where the brand casing is
# the token (bare LIFEPUNCH / LifePunch); case-insensitive for paths/domains/headers.
$script:CdwBlockedCaseSensitive = @(
    "LIFEPUNCH$([char]0x2122)",  # LIFEPUNCH(TM)
    'LIFEPUNCH',
    'LifePunch'
)
$script:CdwBlockedCaseInsensitive = @(
    'lifepunch.co',
    'C:\Users\jared\Projects\lifepunch',
    'C:\Projects\lifepunch',
    'lifepunch/',
    'lifepunchaddons/',
    'lifepunchdxrp/',
    'PROPRIETARY',
    'PRIVATE LIFEPUNCH',
    'LIFEPUNCH PRIVATE'
)
# AI attribution trailers -- always case-insensitive.
$script:CdwBlockedTrailers = @(
    'Co-authored-by: Cursor',
    'Co-authored-by: Claude',
    'Co-authored-by: Copilot',
    'Co-authored-by: AI',
    'Co-authored-by: agent',
    'cursoragent@cursor.com',
    'Generated-by:',
    'Assisted-by:',
    'AI-authored-by:'
)
# Allowed DXRP public identifiers (documented; none of these contain a blocked
# token, so they pass the scan by construction -- kept for tests + reporting).
$script:CdwAllowedDxrpIdentifiers = @(
    'mragerlp/dxrp-public',
    'github.com/mragerlp/dxrp-public',
    'mragerlp-party-*',
    'mragerlp <mragerlp@gmail.com>',
    'dxura/dxrp',
    'upstream/develop'
)

function Invoke-CdwNoIpScan {
    <#
    .SYNOPSIS
      Scan text destined for a dxrp-official artifact. Returns @{Ok; Matches[]}.
      Blocks private LIFEPUNCH branding/paths/headers and AI attribution trailers.
      Does NOT block 'mragerlp' by itself -- public fork owner / commit author
      identity (mragerlp/dxrp-public, mragerlp-party-*, mragerlp <mragerlp@gmail.com>)
      is explicitly allowed.
    #>
    param([Parameter(Mandatory)][AllowEmptyString()][string] $Text)

    $found = New-Object System.Collections.Generic.List[string]

    foreach ($token in $script:CdwBlockedCaseSensitive) {
        if ($Text.Contains($token)) { $found.Add("blocked (private brand): $token") }
    }
    foreach ($token in $script:CdwBlockedCaseInsensitive) {
        if ($Text.IndexOf($token, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
            $found.Add("blocked (private identifier/path/header): $token")
        }
    }
    foreach ($token in $script:CdwBlockedTrailers) {
        if ($Text.IndexOf($token, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
            $found.Add("blocked (AI attribution trailer): $token")
        }
    }

    return @{ Ok = ($found.Count -eq 0); Matches = @($found) }
}

function Invoke-CdwInputContentScan {
    <#
    .SYNOPSIS
      Scan CITED input file contents (inputs.readFiles) for a dxrp-official packet.
      Only files the packet explicitly asks the worker to read are loaded and
      scanned -- never the whole repo. readGlobs are NOT expanded in Slice 1,
      so their content is honestly reported as not scanned.
      Returns @{ Ok; ScannedFiles[]; UnscannedGlobs[]; Failures[] } where each
      failure carries the blocked token detail and the offending file path.
    #>
    param(
        [Parameter(Mandatory)] $Packet,
        [Parameter(Mandatory)] $Profile
    )
    $scanned = New-Object System.Collections.Generic.List[string]
    $failures = New-Object System.Collections.Generic.List[string]
    $clone = [string]$Profile.cloneWindows

    $readFiles = @()
    if ($Packet.inputs.PSObject.Properties.Name -contains 'readFiles' -and $Packet.inputs.readFiles) {
        $readFiles = @($Packet.inputs.readFiles)
    }
    $unscannedGlobs = @()
    if ($Packet.inputs.PSObject.Properties.Name -contains 'readGlobs' -and $Packet.inputs.readGlobs) {
        $unscannedGlobs = @($Packet.inputs.readGlobs)
    }

    foreach ($rel in $readFiles) {
        $full = Join-Path $clone (([string]$rel) -replace '/', '\')
        if (-not (Test-Path -LiteralPath $full -PathType Leaf)) {
            # Existence is enforced earlier by Test-CdwInputPaths; skip defensively.
            continue
        }
        $content = [IO.File]::ReadAllText($full)
        $scan = Invoke-CdwNoIpScan -Text $content
        $scanned.Add([string]$rel)
        if (-not $scan.Ok) {
            foreach ($m in $scan.Matches) {
                $failures.Add("cited input '$rel': $m")
            }
        }
    }

    return @{
        Ok             = ($failures.Count -eq 0)
        ScannedFiles   = @($scanned)
        UnscannedGlobs = @($unscannedGlobs)
        Failures       = @($failures)
    }
}

# ---------------------------------------------------------------------
# Outbox / ack / history writers
# ---------------------------------------------------------------------

function Write-CdwOutboxArtifacts {
    param(
        [Parameter(Mandatory)] $Paths,
        [Parameter(Mandatory)][string] $TaskId,
        [Parameter(Mandatory)][AllowEmptyString()][string] $ReportText,
        [Parameter(Mandatory)] $Meta,
        [string] $ErrorText = ''
    )
    $dir = Join-Path $Paths.Outbox $TaskId
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    if ($ReportText) {
        Write-CdwUtf8NoBom -Path (Join-Path $dir 'report.md') -Text $ReportText
    }
    if ($ErrorText) {
        Write-CdwUtf8NoBom -Path (Join-Path $dir 'error.md') -Text $ErrorText
    }
    Write-CdwUtf8NoBom -Path (Join-Path $dir 'meta.json') -Text (($Meta | ConvertTo-Json -Depth 8))
    return $dir
}

function Add-CdwAck {
    param(
        [Parameter(Mandatory)] $Paths,
        [Parameter(Mandatory)][string] $TaskId,
        [Parameter(Mandatory)][bool] $Ok,
        [string] $Detail = ''
    )
    $ack = @{
        ts     = (Get-Date).ToUniversalTime().ToString('o')
        id     = $TaskId
        action = 'drop-worker-dryrun'
        ok     = $Ok
        detail = $Detail
    } | ConvertTo-Json -Compress
    $parent = Split-Path -Parent $Paths.AckLog
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    Add-Content -LiteralPath $Paths.AckLog -Value $ack -Encoding UTF8
}

function Move-CdwPacketToHistory {
    param(
        [Parameter(Mandatory)] $Paths,
        [Parameter(Mandatory)][string] $PacketFile,
        [Parameter(Mandatory)][ValidateSet('ok', 'fail')][string] $Status
    )
    if (-not (Test-Path -LiteralPath $Paths.History)) {
        New-Item -ItemType Directory -Force -Path $Paths.History | Out-Null
    }
    $name = [IO.Path]::GetFileNameWithoutExtension($PacketFile)
    $dest = Join-Path $Paths.History ("{0}.{1}.json" -f $name, $Status)
    Move-Item -LiteralPath $PacketFile -Destination $dest -Force
    return $dest
}
