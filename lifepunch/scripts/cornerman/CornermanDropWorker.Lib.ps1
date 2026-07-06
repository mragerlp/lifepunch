# =====================================================================
# RISK: READ-ONLY on repos; localhost-only model HTTP  |  Slice 2
# NODE: Green (Cornerman) -- testable on Red with scratch dirs
# WHAT: Shared functions for the Cornerman headless drop worker.
#       Packet schema validation, repo-profile registry, clone identity,
#       dirty-tree gate, input path safety, no-IP / AI-trailer scan,
#       lock handling, outbox/ack/history/log writers.
#       Slice 2 adds: model-call opt-in policy, model endpoint config,
#       localhost-only HTTP (probe + chat), routeTag -> model resolution,
#       glob expansion, input packing, format-aware output validation.
# LAW:  lifepunch/docs/handoff/CORNERMAN_HEADLESS_DROP_WORKER_OPUS_V2_PLAN_2026-07-06.md
#       lifepunch/docs/handoff/CORNERMAN_DROP_WORKER_SLICE2_MODEL_CALL_PLAN_2026-07-06.md
#       Still NO scheduler, NO patches, NO commit/push, NO git mutation,
#       NO network egress beyond localhost. Model calls require BOTH the
#       -EnableModelCall switch AND packet modelCall.enabled=true.
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

    # modelCall (optional; Slice 2). Absent object = enabled:false (dry-run).
    if ($Packet.PSObject.Properties.Name -contains 'modelCall' -and $null -ne $Packet.modelCall) {
        $mc = $Packet.modelCall
        if (-not ($mc.PSObject.Properties.Name -contains 'enabled') -or ($mc.enabled -isnot [bool])) {
            $errors.Add('modelCall.enabled must be present and boolean when modelCall is supplied')
        }
        if ($mc.PSObject.Properties.Name -contains 'requiredModel' -and $null -ne $mc.requiredModel -and
            ($mc.requiredModel -isnot [string] -or [string]::IsNullOrWhiteSpace([string]$mc.requiredModel))) {
            $errors.Add('modelCall.requiredModel must be null or a non-empty string')
        }
        if ($mc.PSObject.Properties.Name -contains 'allowFallback' -and $null -ne $mc.allowFallback -and
            ($mc.allowFallback -isnot [bool])) {
            $errors.Add('modelCall.allowFallback must be boolean')
        }
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
        return @{ Ok = $true; Warning = "base ref '$ref' not resolvable locally (the worker never fetches; sync the clone out-of-band)" }
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
    # requiredDocs (canon) get BYTE-IDENTICAL treatment to readFiles: same repo-relative
    # / no-'..' / forbid-prefix rules -- closes the dxrp-official private-canon smuggle hole.
    $requiredDocs = @()
    if ($Packet.inputs.PSObject.Properties.Name -contains 'requiredDocs' -and $Packet.inputs.requiredDocs) {
        $requiredDocs = @($Packet.inputs.requiredDocs)
    }

    foreach ($rel in ($readFiles + $readGlobs + $requiredDocs)) {
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
        foreach ($rel in ($readFiles + $requiredDocs)) {
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
      Scan CITED input file contents for a dxrp-official packet: every file in
      inputs.readFiles PLUS every glob-expanded file passed via -GlobFiles
      (Slice 2 closes the Slice 1 "globs not scanned" gap). Only files the
      packet explicitly cites (directly or via its own globs) are loaded and
      scanned -- never the whole repo.
      Returns @{ Ok; ScannedFiles[]; UnscannedGlobs[]; Failures[] } where each
      failure carries the blocked token detail and the offending file path.
      UnscannedGlobs is non-empty only when the caller did not supply expansion
      results (legacy dry-run path without glob support).
    #>
    param(
        [Parameter(Mandatory)] $Packet,
        [Parameter(Mandatory)] $Profile,
        [string[]] $GlobFiles = @(),
        [bool] $GlobsExpanded = $false
    )
    $scanned = New-Object System.Collections.Generic.List[string]
    $failures = New-Object System.Collections.Generic.List[string]
    $clone = [string]$Profile.cloneWindows

    $readFiles = @()
    if ($Packet.inputs.PSObject.Properties.Name -contains 'readFiles' -and $Packet.inputs.readFiles) {
        $readFiles = @($Packet.inputs.readFiles)
    }
    # requiredDocs (canon) contents are scanned identically to readFiles for dxrp-official.
    $requiredDocs = @()
    if ($Packet.inputs.PSObject.Properties.Name -contains 'requiredDocs' -and $Packet.inputs.requiredDocs) {
        $requiredDocs = @($Packet.inputs.requiredDocs)
    }
    $unscannedGlobs = @()
    if (-not $GlobsExpanded -and
        $Packet.inputs.PSObject.Properties.Name -contains 'readGlobs' -and $Packet.inputs.readGlobs) {
        $unscannedGlobs = @($Packet.inputs.readGlobs)
    }

    $targets = New-Object System.Collections.Generic.List[string]
    foreach ($rel in $readFiles) {
        $norm = ([string]$rel) -replace '\\', '/'
        if (-not $targets.Contains($norm)) { $targets.Add($norm) }
    }
    foreach ($rel in $requiredDocs) {
        $norm = ([string]$rel) -replace '\\', '/'
        if (-not $targets.Contains($norm)) { $targets.Add($norm) }
    }
    foreach ($rel in $GlobFiles) {
        $norm = ([string]$rel) -replace '\\', '/'
        if (-not $targets.Contains($norm)) { $targets.Add($norm) }
    }

    foreach ($rel in $targets) {
        $full = Join-Path $clone ($rel -replace '/', '\')
        if (-not (Test-Path -LiteralPath $full -PathType Leaf)) {
            # Existence is enforced earlier by Test-CdwInputPaths; skip defensively.
            continue
        }
        $content = [IO.File]::ReadAllText($full)
        $scan = Invoke-CdwNoIpScan -Text $content
        $scanned.Add($rel)
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

# =====================================================================
# Slice 2 -- local model call support (LM Studio, localhost only)
# =====================================================================
# HARD LAW: no HTTP request of any kind (including the /v1/models probe)
# until every pre-call gate has passed in the orchestrator. Functions in
# this section that perform HTTP say so explicitly; everything else is
# pure validation/packing and network-silent.

function Test-CdwModelCallPolicy {
    <#
    .SYNOPSIS
      Double opt-in decision table (canonical: SLICE2_MODEL_CALL_PLAN section 1).
      Returns @{ Action = 'dry-run' | 'model-call' | 'fail'; Error;
                 PacketRequested (bool) }. Never performs HTTP.
    #>
    param(
        [Parameter(Mandatory)] $Packet,
        [Parameter(Mandatory)][bool] $EnableModelCall
    )
    $requested = $false
    if ($Packet.PSObject.Properties.Name -contains 'modelCall' -and $null -ne $Packet.modelCall -and
        ($Packet.modelCall.PSObject.Properties.Name -contains 'enabled')) {
        $requested = [bool]$Packet.modelCall.enabled
    }
    $noModelCall = $false
    if ($Packet.PSObject.Properties.Name -contains 'constraints' -and $null -ne $Packet.constraints -and
        ($Packet.constraints.PSObject.Properties.Name -contains 'noModelCall')) {
        $noModelCall = [bool]$Packet.constraints.noModelCall
    }

    if (-not $requested) {
        # Legacy Slice 1 packets and non-opted packets always dry-run,
        # regardless of the worker switch.
        return @{ Action = 'dry-run'; Error = $null; PacketRequested = $false }
    }
    if (-not $EnableModelCall) {
        return @{
            Action = 'fail'
            Error  = 'model-call-requested-but-worker-not-enabled: packet sets modelCall.enabled=true but the worker was not started with -EnableModelCall'
            PacketRequested = $true
        }
    }
    if ($noModelCall) {
        return @{
            Action = 'fail'
            Error  = 'packet self-contradiction: modelCall.enabled=true AND constraints.noModelCall=true -- resolve the packet intent'
            PacketRequested = $true
        }
    }
    return @{ Action = 'model-call'; Error = $null; PacketRequested = $true }
}

function Read-CdwModelConfig {
    <#
    .SYNOPSIS
      Read model-endpoints.json. Returns @{Ok; Error; Config}. No HTTP.
    #>
    param([Parameter(Mandatory)][string] $Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        return @{ Ok = $false; Error = "model config missing: $Path"; Config = $null }
    }
    try {
        $cfg = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    }
    catch {
        return @{ Ok = $false; Error = "model config unreadable: $($_.Exception.Message)"; Config = $null }
    }
    foreach ($f in @('endpoint', 'routes', 'request')) {
        if (-not ($cfg.PSObject.Properties.Name -contains $f)) {
            return @{ Ok = $false; Error = "model config missing '$f' object"; Config = $null }
        }
    }
    foreach ($f in @('probeUrl', 'chatUrl')) {
        if (-not ($cfg.endpoint.PSObject.Properties.Name -contains $f) -or
            [string]::IsNullOrWhiteSpace([string]$cfg.endpoint.$f)) {
            return @{ Ok = $false; Error = "model config endpoint.$f required"; Config = $null }
        }
    }
    return @{ Ok = $true; Error = $null; Config = $cfg }
}

function Test-CdwModelEndpointLocal {
    <#
    .SYNOPSIS
      Localhost-only enforcement IN CODE (not config trust). Both probe and
      chat URLs must start with http://127.0.0.1: or http://localhost:.
      Returns @{Ok; Error}. No HTTP.
    #>
    param([Parameter(Mandatory)] $Config)
    foreach ($u in @([string]$Config.endpoint.probeUrl, [string]$Config.endpoint.chatUrl)) {
        $isLocal = $u.StartsWith('http://127.0.0.1:', [System.StringComparison]::OrdinalIgnoreCase) -or
                   $u.StartsWith('http://localhost:', [System.StringComparison]::OrdinalIgnoreCase)
        if (-not $isLocal) {
            return @{ Ok = $false; Error = "model endpoint is not localhost -- refused (no egress beyond localhost): $u" }
        }
    }
    return @{ Ok = $true; Error = $null }
}

function Resolve-CdwModelRoute {
    <#
    .SYNOPSIS
      routeTag -> configured model id. AUTO OK is rejected (belongs on Red).
      If packet modelCall.requiredModel is set it must agree with the routed
      model (model-route-conflict otherwise). Returns @{Ok; Error; ModelId;
      AllowFallbackIgnoredWarning}. No HTTP.
    #>
    param(
        [Parameter(Mandatory)] $Packet,
        [Parameter(Mandatory)] $Config
    )
    $route = [string]$Packet.routeTag
    if ($route -eq 'AUTO OK') {
        return @{ Ok = $false; Error = "routeTag 'AUTO OK' is not routed to a Green model -- rejected"; ModelId = $null; AllowFallbackIgnoredWarning = $null }
    }
    $entry = $Config.routes.PSObject.Properties | Where-Object { $_.Name -eq $route } | Select-Object -First 1
    if (-not $entry -or [string]::IsNullOrWhiteSpace([string]$entry.Value)) {
        return @{ Ok = $false; Error = "routeTag '$route' has no configured model in model-endpoints config"; ModelId = $null; AllowFallbackIgnoredWarning = $null }
    }
    $modelId = [string]$entry.Value

    $warning = $null
    if ($Packet.PSObject.Properties.Name -contains 'modelCall' -and $null -ne $Packet.modelCall) {
        $mc = $Packet.modelCall
        if ($mc.PSObject.Properties.Name -contains 'requiredModel' -and $mc.requiredModel) {
            $req = [string]$mc.requiredModel
            if ($req -ne $modelId) {
                return @{ Ok = $false; Error = "model-route-conflict: packet requiredModel '$req' disagrees with routeTag '$route' configured model '$modelId'"; ModelId = $null; AllowFallbackIgnoredWarning = $null }
            }
        }
        if ($mc.PSObject.Properties.Name -contains 'allowFallback' -and $mc.allowFallback -eq $true) {
            $warning = 'modelCall.allowFallback=true is ignored in Slice 2 (fallback not implemented; missing model still fails closed)'
        }
    }
    return @{ Ok = $true; Error = $null; ModelId = $modelId; AllowFallbackIgnoredWarning = $warning }
}

function Expand-CdwReadGlobs {
    <#
    .SYNOPSIS
      Expand inputs.readGlobs inside the resolved clone. Glob language:
      ** = any path segments, * = within one segment, ? = one char.
      Enumeration is rooted at the glob's fixed prefix directory; results
      are repo-relative, verified against profile forbid-prefixes.
      Returns @{Ok; Errors[]; Files[]}. No HTTP. Read-only.
    #>
    param(
        [Parameter(Mandatory)] $Packet,
        [Parameter(Mandatory)] $Profile
    )
    $errors = New-Object System.Collections.Generic.List[string]
    $files = New-Object System.Collections.Generic.List[string]
    $clone = [string]$Profile.cloneWindows

    $readGlobs = @()
    if ($Packet.inputs.PSObject.Properties.Name -contains 'readGlobs' -and $Packet.inputs.readGlobs) {
        $readGlobs = @($Packet.inputs.readGlobs)
    }
    if ($readGlobs.Count -eq 0) {
        return @{ Ok = $true; Errors = @(); Files = @() }
    }

    $forbidPrefixes = @()
    if ($Profile.PSObject.Properties.Name -contains 'forbidInputPrefixes' -and $Profile.forbidInputPrefixes) {
        $forbidPrefixes = @($Profile.forbidInputPrefixes)
    }

    $cloneFull = (Resolve-Path -LiteralPath $clone).Path.TrimEnd('\')

    foreach ($glob in $readGlobs) {
        $g = ([string]$glob) -replace '\\', '/'

        # fixed prefix = segments before the first wildcard segment
        $segments = $g -split '/'
        $fixed = New-Object System.Collections.Generic.List[string]
        foreach ($seg in $segments) {
            if ($seg -match '[\*\?]') { break }
            $fixed.Add($seg)
        }
        $baseRel = ($fixed -join '\')
        $baseDir = if ($baseRel) { Join-Path $cloneFull $baseRel } else { $cloneFull }
        if (-not (Test-Path -LiteralPath $baseDir -PathType Container)) {
            # No matching directory -> zero matches (not an error by itself)
            continue
        }

        # glob -> anchored regex on the repo-relative forward-slash path
        $rx = [regex]::Escape($g)
        $rx = $rx -replace '\\\*\\\*/', '(?:[^/]+/)*'   # '**/' = zero or more segments
        $rx = $rx -replace '\\\*\\\*', '.*'             # bare '**'
        $rx = $rx -replace '\\\*', '[^/]*'
        $rx = $rx -replace '\\\?', '[^/]'
        $rx = '^' + $rx + '$'

        $candidates = Get-ChildItem -LiteralPath $baseDir -Recurse -File -Force -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -notmatch '\\\.git\\' }
        foreach ($c in $candidates) {
            $rel = $c.FullName.Substring($cloneFull.Length).TrimStart('\') -replace '\\', '/'
            if ($rel -notmatch $rx) { continue }
            $blocked = $false
            foreach ($prefix in $forbidPrefixes) {
                $pNorm = ([string]$prefix) -replace '\\', '/'
                if ($rel.StartsWith($pNorm, [System.StringComparison]::OrdinalIgnoreCase)) {
                    $errors.Add("glob '$glob' expanded to '$rel' which is under forbidden prefix '$prefix'")
                    $blocked = $true
                    break
                }
            }
            if (-not $blocked) { $files.Add($rel) }
        }
    }

    return @{ Ok = ($errors.Count -eq 0); Errors = @($errors); Files = @($files | Sort-Object -Unique) }
}

function Get-CdwPackedInputs {
    <#
    .SYNOPSIS
      Load readFiles + expanded glob files (deduped, packet order first),
      enforce inputs.maxBytes over the COMBINED set and the prompt context
      ceiling (config request.maxPromptChars). Returns @{Ok; Errors[];
      Files[]; TotalBytes; PackedText}. No HTTP. Read-only. No truncation:
      over-cap fails closed.
    #>
    param(
        [Parameter(Mandatory)] $Packet,
        [Parameter(Mandatory)] $Profile,
        [Parameter(Mandatory)][AllowEmptyCollection()][string[]] $GlobFiles,
        [long] $MaxPromptChars = 120000
    )
    $errors = New-Object System.Collections.Generic.List[string]
    $clone = [string]$Profile.cloneWindows
    $maxBytes = [long]$Packet.inputs.maxBytes

    $readFiles = @()
    if ($Packet.inputs.PSObject.Properties.Name -contains 'readFiles' -and $Packet.inputs.readFiles) {
        $readFiles = @($Packet.inputs.readFiles | ForEach-Object { ([string]$_) -replace '\\', '/' })
    }
    $ordered = New-Object System.Collections.Generic.List[string]
    foreach ($f in ($readFiles + @($GlobFiles))) {
        if (-not $ordered.Contains($f)) { $ordered.Add($f) }
    }

    $totalBytes = [long]0

    # canon/reference docs (inputs.requiredDocs) -- packed SEPARATELY from the drift
    # targets, but counted toward the SAME maxBytes + maxPromptChars caps (fail-closed
    # over-cap, no truncation). Path safety/existence enforced in Test-CdwInputPaths.
    $requiredDocs = @()
    if ($Packet.inputs.PSObject.Properties.Name -contains 'requiredDocs' -and $Packet.inputs.requiredDocs) {
        $requiredDocs = @($Packet.inputs.requiredDocs | ForEach-Object { ([string]$_) -replace '\\', '/' })
    }
    $refOrdered = New-Object System.Collections.Generic.List[string]
    foreach ($f in $requiredDocs) {
        if (-not $refOrdered.Contains($f) -and -not $ordered.Contains($f)) { $refOrdered.Add($f) }
    }
    $refSb = New-Object System.Text.StringBuilder
    foreach ($rel in $refOrdered) {
        $full = Join-Path $clone ($rel -replace '/', '\')
        if (-not (Test-Path -LiteralPath $full -PathType Leaf)) {
            $errors.Add("required canon doc not found in clone: $rel")
            continue
        }
        $len = (Get-Item -LiteralPath $full).Length
        $totalBytes += $len
        $content = [IO.File]::ReadAllText($full)
        [void]$refSb.AppendLine("=== CANON/REFERENCE: $rel ($len bytes) ===")
        [void]$refSb.AppendLine($content)
        [void]$refSb.AppendLine("=== END CANON/REFERENCE: $rel ===")
        [void]$refSb.AppendLine('')
    }
    $reference = $refSb.ToString()

    $sb = New-Object System.Text.StringBuilder
    foreach ($rel in $ordered) {
        $full = Join-Path $clone ($rel -replace '/', '\')
        if (-not (Test-Path -LiteralPath $full -PathType Leaf)) {
            $errors.Add("packed input not found in clone: $rel")
            continue
        }
        $len = (Get-Item -LiteralPath $full).Length
        $totalBytes += $len
        $content = [IO.File]::ReadAllText($full)
        [void]$sb.AppendLine("=== FILE: $rel ($len bytes) ===")
        [void]$sb.AppendLine($content)
        [void]$sb.AppendLine("=== END FILE: $rel ===")
        [void]$sb.AppendLine('')
    }

    if ($totalBytes -gt $maxBytes) {
        $errors.Add("combined input bytes $totalBytes (requiredDocs + readFiles + expanded globs) exceed inputs.maxBytes $maxBytes")
    }
    $packed = $sb.ToString()
    $combinedLen = $reference.Length + $packed.Length
    if ($errors.Count -eq 0 -and $combinedLen -gt $MaxPromptChars) {
        $errors.Add("packed input length $combinedLen chars (canon + drift-targets) exceeds prompt context ceiling $MaxPromptChars -- reduce inputs or raise the ceiling deliberately (no silent truncation)")
    }

    return @{
        Ok            = ($errors.Count -eq 0)
        Errors        = @($errors)
        Files         = @($ordered)
        ReferenceDocs = @($refOrdered)
        TotalBytes    = $totalBytes
        PackedText    = $packed
        ReferenceText = $reference
    }
}

function Build-CdwModelRequest {
    <#
    .SYNOPSIS
      Build the OpenAI-compatible chat request body. Worker-owned system
      prompt (packets cannot override). Returns @{Body (hashtable);
      SystemPrompt; UserPrompt}. No HTTP.
    #>
    param(
        [Parameter(Mandatory)] $Packet,
        [Parameter(Mandatory)][string] $ProfileName,
        [Parameter(Mandatory)][string] $ModelId,
        [Parameter(Mandatory)][AllowEmptyString()][string] $PackedInputs,
        [AllowEmptyString()][string] $ReferenceInputs = '',
        [Parameter(Mandatory)] $Config
    )
    $d = $Packet.deliverable
    $format = [string]$d.format
    $sections = @()
    if ($d.PSObject.Properties.Name -contains 'expectedSections' -and $d.expectedSections) {
        $sections = @($d.expectedSections)
    }

    $sys = New-Object System.Collections.Generic.List[string]
    $sys.Add('You are a headless audit/distill worker running on an offline workstation (Green).')
    $sys.Add('Your eyes are covered: you have NO runtime, editor, or game access. Never claim runtime proof, playtest results, or visual verification.')
    $sys.Add('Respond ONLY from the provided input files and instruction. Never fabricate file contents, paths, commits, or quotes.')
    $sys.Add('Never include commit or push instructions beyond restating any handoff hints already present in the task.')
    $sys.Add("Output format: $format.")
    if ($format -eq 'markdown' -and $sections.Count -gt 0) {
        $sys.Add("Your markdown output MUST contain these sections as headings, in order: $($sections -join ' | ').")
    }
    elseif ($format -eq 'json') {
        $sys.Add('Your ENTIRE output must be a single valid JSON document. No prose before or after.')
    }
    if ($ProfileName -eq 'dxrp-official') {
        $sys.Add('This output is for a PUBLIC upstream repository. Never mention private LifePunch branding, private repository paths, proprietary headers, or any AI attribution trailers.')
    }
    if ($ReferenceInputs) {
        $sys.Add('Some inputs are marked CANON/REFERENCE and are authoritative. Treat canon as the source of truth; report where the other INPUT FILES disagree with it. Never flag the canon itself as drift.')
    }

    $usr = New-Object System.Collections.Generic.List[string]
    $usr.Add("TASK: $($Packet.instruction)")
    if ($Packet.inputs.PSObject.Properties.Name -contains 'contextNotes' -and $Packet.inputs.contextNotes) {
        $usr.Add('')
        $usr.Add("CONTEXT NOTES: $($Packet.inputs.contextNotes)")
    }
    $usr.Add('')
    $usr.Add("DELIVERABLE: name=$($d.outboxName) format=$format")
    if ($sections.Count -gt 0) { $usr.Add("EXPECTED SECTIONS: $($sections -join ' | ')") }
    if ($d.PSObject.Properties.Name -contains 'audience' -and $d.audience) { $usr.Add("AUDIENCE: $($d.audience)") }
    $usr.Add('')
    if ($ReferenceInputs) {
        $usr.Add('CANON / REFERENCE (authoritative source of truth -- compare the drift targets against this):')
        $usr.Add($ReferenceInputs)
        $usr.Add('')
        $usr.Add('INPUT FILES (drift targets -- check each against the CANON / REFERENCE above):')
    }
    else {
        $usr.Add('INPUT FILES:')
    }
    $usr.Add($PackedInputs)

    $temperature = 0.2
    $maxTokens = 4096
    if ($Config.request.PSObject.Properties.Name -contains 'temperature' -and $null -ne $Config.request.temperature) {
        $temperature = [double]$Config.request.temperature
    }
    if ($Config.request.PSObject.Properties.Name -contains 'maxTokens' -and $null -ne $Config.request.maxTokens) {
        $maxTokens = [int]$Config.request.maxTokens
    }

    $systemPrompt = ($sys -join ' ')
    $userPrompt = ($usr -join [Environment]::NewLine)
    $body = @{
        model       = $ModelId
        messages    = @(
            @{ role = 'system'; content = $systemPrompt },
            @{ role = 'user'; content = $userPrompt }
        )
        temperature = $temperature
        max_tokens  = $maxTokens
        stream      = $false
    }
    return @{ Body = $body; SystemPrompt = $systemPrompt; UserPrompt = $userPrompt }
}

function Invoke-CdwHttpGet {
    # PERFORMS HTTP (localhost only; caller must have passed all gates).
    param(
        [Parameter(Mandatory)][string] $Url,
        [int] $TimeoutSec = 5
    )
    $req = [System.Net.HttpWebRequest]::Create($Url)
    $req.Method = 'GET'
    $req.Timeout = $TimeoutSec * 1000
    $req.ReadWriteTimeout = $TimeoutSec * 1000
    $resp = $req.GetResponse()
    try {
        $reader = New-Object IO.StreamReader($resp.GetResponseStream())
        return $reader.ReadToEnd()
    }
    finally { $resp.Dispose() }
}

function Invoke-CdwModelProbe {
    <#
    .SYNOPSIS
      PERFORMS HTTP: GET the /v1/models probe URL. First permitted network
      action of a run. Returns @{Ok; Error; Models[]}.
    #>
    param([Parameter(Mandatory)] $Config)
    $url = [string]$Config.endpoint.probeUrl
    $timeout = 5
    if ($Config.endpoint.PSObject.Properties.Name -contains 'probeTimeoutSec' -and $Config.endpoint.probeTimeoutSec) {
        $timeout = [int]$Config.endpoint.probeTimeoutSec
    }
    try {
        $raw = Invoke-CdwHttpGet -Url $url -TimeoutSec $timeout
        $parsed = $raw | ConvertFrom-Json
        $models = @()
        if ($parsed.PSObject.Properties.Name -contains 'data' -and $parsed.data) {
            $models = @($parsed.data | ForEach-Object { [string]$_.id })
        }
        return @{ Ok = $true; Error = $null; Models = $models }
    }
    catch {
        return @{ Ok = $false; Error = "endpoint probe failed ($url): $($_.Exception.Message)"; Models = @() }
    }
}

function Invoke-CdwModelCall {
    <#
    .SYNOPSIS
      PERFORMS HTTP: POST the chat completion. Returns @{Ok; Stage; Error;
      Content; FinishReason; DurationSeconds; HttpStatus}. Stage on failure:
      model-timeout | model-invalid | endpoint-down. One retry ONLY for
      transient connect failures (never for timeout).
    #>
    param(
        [Parameter(Mandatory)] $Config,
        [Parameter(Mandatory)] $Body
    )
    $url = [string]$Config.endpoint.chatUrl
    $timeout = 300
    if ($Config.endpoint.PSObject.Properties.Name -contains 'callTimeoutSec' -and $Config.endpoint.callTimeoutSec) {
        $timeout = [int]$Config.endpoint.callTimeoutSec
    }
    $json = $Body | ConvertTo-Json -Depth 10
    $bytes = [Text.Encoding]::UTF8.GetBytes($json)

    $attempt = 0
    $maxAttempts = 2   # 2nd attempt only on transient connect failure
    while ($true) {
        $attempt++
        $sw = [Diagnostics.Stopwatch]::StartNew()
        try {
            $req = [System.Net.HttpWebRequest]::Create($url)
            $req.Method = 'POST'
            $req.ContentType = 'application/json'
            $req.Timeout = $timeout * 1000
            $req.ReadWriteTimeout = $timeout * 1000
            $reqStream = $req.GetRequestStream()
            try { $reqStream.Write($bytes, 0, $bytes.Length) } finally { $reqStream.Dispose() }
            $resp = $req.GetResponse()
            try {
                $reader = New-Object IO.StreamReader($resp.GetResponseStream())
                $raw = $reader.ReadToEnd()
            }
            finally { $resp.Dispose() }
            $sw.Stop()

            try { $parsed = $raw | ConvertFrom-Json }
            catch {
                return @{ Ok = $false; Stage = 'model-invalid'; Error = "response body is not valid JSON: $($_.Exception.Message)"; Content = $null; FinishReason = $null; DurationSeconds = [math]::Round($sw.Elapsed.TotalSeconds, 1); HttpStatus = 200 }
            }
            if (-not ($parsed.PSObject.Properties.Name -contains 'choices') -or -not $parsed.choices -or @($parsed.choices).Count -lt 1) {
                return @{ Ok = $false; Stage = 'model-invalid'; Error = 'response JSON has no choices'; Content = $null; FinishReason = $null; DurationSeconds = [math]::Round($sw.Elapsed.TotalSeconds, 1); HttpStatus = 200 }
            }
            $choice = @($parsed.choices)[0]
            $content = $null
            if ($choice.PSObject.Properties.Name -contains 'message' -and $choice.message -and
                ($choice.message.PSObject.Properties.Name -contains 'content')) {
                $content = [string]$choice.message.content
            }
            $finish = ''
            if ($choice.PSObject.Properties.Name -contains 'finish_reason') { $finish = [string]$choice.finish_reason }
            if ([string]::IsNullOrWhiteSpace($content)) {
                return @{ Ok = $false; Stage = 'model-empty'; Error = "model returned empty content (finish_reason: $finish)"; Content = $null; FinishReason = $finish; DurationSeconds = [math]::Round($sw.Elapsed.TotalSeconds, 1); HttpStatus = 200 }
            }
            return @{ Ok = $true; Stage = $null; Error = $null; Content = $content; FinishReason = $finish; DurationSeconds = [math]::Round($sw.Elapsed.TotalSeconds, 1); HttpStatus = 200 }
        }
        catch [System.Net.WebException] {
            $sw.Stop()
            $we = $_.Exception
            if ($we.Status -eq [System.Net.WebExceptionStatus]::Timeout) {
                return @{ Ok = $false; Stage = 'model-timeout'; Error = "model call exceeded timeout ${timeout}s (elapsed $([math]::Round($sw.Elapsed.TotalSeconds,1))s)"; Content = $null; FinishReason = $null; DurationSeconds = [math]::Round($sw.Elapsed.TotalSeconds, 1); HttpStatus = $null }
            }
            $transient = $we.Status -in @([System.Net.WebExceptionStatus]::ConnectFailure, [System.Net.WebExceptionStatus]::NameResolutionFailure)
            if ($transient -and $attempt -lt $maxAttempts) {
                Start-Sleep -Seconds 2
                continue
            }
            return @{ Ok = $false; Stage = 'endpoint-down'; Error = "model call failed ($url): $($we.Message)"; Content = $null; FinishReason = $null; DurationSeconds = [math]::Round($sw.Elapsed.TotalSeconds, 1); HttpStatus = $null }
        }
        catch {
            $sw.Stop()
            return @{ Ok = $false; Stage = 'endpoint-down'; Error = "model call failed ($url): $($_.Exception.Message)"; Content = $null; FinishReason = $null; DurationSeconds = [math]::Round($sw.Elapsed.TotalSeconds, 1); HttpStatus = $null }
        }
    }
}

function Test-CdwModelOutput {
    <#
    .SYNOPSIS
      Format-aware output validation (deliverable.format dispatch).
      markdown: non-empty; expectedSections best-effort (missing = warning,
                ALL missing = fail model-invalid).
      json:     full body must parse after optional outer code-fence strip.
      text:     non-empty (non-whitespace).
      Unknown format: fail closed (defense-in-depth; schema catches earlier).
      Scan is the caller's job and runs BEFORE this on raw output for
      dxrp-official. Returns @{Ok; Stage; Errors[]; Warnings[];
      MissingSections[]; OutputText}. No HTTP.
    #>
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $OutputText,
        [Parameter(Mandatory)][string] $Format,
        [string[]] $ExpectedSections = @()
    )
    $warnings = New-Object System.Collections.Generic.List[string]
    $missing = New-Object System.Collections.Generic.List[string]

    if ([string]::IsNullOrWhiteSpace($OutputText)) {
        return @{ Ok = $false; Stage = 'model-empty'; Errors = @('model output is empty or whitespace'); Warnings = @(); MissingSections = @(); OutputText = $OutputText }
    }

    switch ($Format) {
        'markdown' {
            if ($ExpectedSections.Count -gt 0) {
                $matched = 0
                foreach ($s in $ExpectedSections) {
                    $needle = [regex]::Escape([string]$s)
                    # heading line or bold pseudo-heading containing the label
                    if ($OutputText -match "(?im)^\s{0,3}(#{1,6}\s.*$needle|\*\*.*$needle.*\*\*\s*$)") {
                        $matched++
                    }
                    else {
                        $missing.Add([string]$s)
                    }
                }
                if ($matched -eq 0) {
                    return @{ Ok = $false; Stage = 'model-invalid'; Errors = @("output contains none of the $($ExpectedSections.Count) expected sections -- contract ignored"); Warnings = @(); MissingSections = @($missing); OutputText = $OutputText }
                }
                foreach ($m in $missing) {
                    $warnings.Add("expected section not found (best-effort match): $m")
                }
            }
            return @{ Ok = $true; Stage = $null; Errors = @(); Warnings = @($warnings); MissingSections = @($missing); OutputText = $OutputText }
        }
        'json' {
            $candidate = $OutputText.Trim()
            # strip ONE outer code fence if present
            if ($candidate -match '(?s)^```[a-zA-Z]*\r?\n(.*)\r?\n```$') {
                $candidate = $Matches[1]
            }
            try {
                $null = $candidate | ConvertFrom-Json
            }
            catch {
                return @{ Ok = $false; Stage = 'model-invalid'; Errors = @("output is not valid JSON for a json deliverable: $($_.Exception.Message)"); Warnings = @(); MissingSections = @(); OutputText = $OutputText }
            }
            return @{ Ok = $true; Stage = $null; Errors = @(); Warnings = @(); MissingSections = @(); OutputText = $candidate }
        }
        'text' {
            return @{ Ok = $true; Stage = $null; Errors = @(); Warnings = @(); MissingSections = @(); OutputText = $OutputText }
        }
        default {
            return @{ Ok = $false; Stage = 'model-invalid'; Errors = @("unsupported deliverable.format '$Format' reached output validation (should have failed at schema)"); Warnings = @(); MissingSections = @(); OutputText = $OutputText }
        }
    }
}
