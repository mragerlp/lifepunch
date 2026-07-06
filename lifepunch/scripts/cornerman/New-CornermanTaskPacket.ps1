# =====================================================================
# RISK: LOCAL FILE WRITE ONLY (one packet JSON)  |  Slice 3
# NODE: Red (VENGEANCE) -- works anywhere the repo is checked out
# WHAT: Operator helper. Builds a schema-valid v2 task packet for the
#       Cornerman headless drop worker from parameters, validates it
#       with the worker's own Test-CdwPacketSchema, and writes
#       <id>.json to -OutputDir. It does NOT send the packet and does
#       NOT run the worker.
# SAFE DEFAULTS:
#       - no model call unless -RequestModelCall is given explicitly
#         (default packets carry constraints.noModelCall=true)
#       - mode is always 'report' (never candidate-patch)
#       - no commit/pr authority fields are ever emitted
#       - constraints noCommit/noPush/noProof/noPatch/noScheduler/
#         noSourceEdit are always true
# LAW:  lifepunch/docs/CORNERMAN_HEADLESS_DROP_WORKER.md (runbook)
#       lifepunch/docs/schemas/cornerman-task-packet.schema.json
# USAGE:
#   powershell -NoProfile -File New-CornermanTaskPacket.ps1 `
#       -RepoProfile lifepunch-private -RouteTag 'GREEN DEEP REQUIRED' `
#       -Title 'Runbook drift check' `
#       -Instruction 'Compare the drop workflow doc against the headless worker runbook and list drift.' `
#       -ReadFiles lifepunch/docs/CORNERMAN_HEADLESS_DROP_WORKER.md `
#       -OutputDir C:\Users\jared\Projects\lifepunch-packets
#   # model-call packet (still requires -EnableModelCall on the worker):
#   ... -RequestModelCall
# =====================================================================

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('lifepunch-private', 'dxrp-official')]
    [string] $RepoProfile,

    [Parameter(Mandatory)]
    [ValidateSet('GREEN DEEP REQUIRED', 'GREEN CODE REQUIRED', 'AUTO OK')]
    [string] $RouteTag,

    # What the task asks for (schema: 10..8000 chars).
    [Parameter(Mandatory)]
    [ValidateLength(10, 8000)]
    [string] $Instruction,

    # Human-readable title; also the default source for the id slug.
    [string] $Title = '',

    # Explicit id slug (lowercase letters/digits/hyphens). Default: from Title.
    [string] $Slug = '',

    [ValidateSet('distill', 'audit', 'summarize', 'pr-review', 'style-check', 'ip-scan', 'file-map')]
    [string] $Type = 'distill',

    [ValidateSet('markdown', 'json', 'text')]
    [string] $Format = 'markdown',

    [string[]] $ReadFiles = @(),
    [string[]] $ReadGlobs = @(),

    # Canon/reference docs (inputs.requiredDocs): loaded as authoritative reference
    # context, packed separately from the readFiles/readGlobs drift targets. Additive
    # only -- does NOT satisfy the readFiles/readGlobs requirement.
    [string[]] $RequiredDocs = @(),

    # Packet-side model-call opt-in (modelCall.enabled=true). The worker
    # additionally requires its own -EnableModelCall switch (double opt-in).
    [switch] $RequestModelCall,

    # Force constraints.noModelCall=true explicitly. This is already the
    # default for packets that do not request a model call.
    [switch] $NoModelCall,

    # Optional exact model id (must agree with the routeTag's configured model).
    [string] $RequiredModel = '',

    [string] $OutboxName = '',
    [string[]] $ExpectedSections = @(),
    [ValidateLength(0, 8000)]
    [string] $ContextNotes = '',
    [string[]] $AllowedOutputTypes = @(),
    [string[]] $ForbiddenScope = @('portal', 'permissions-backend'),

    [ValidateRange(1, 10000000)]
    [long] $MaxBytes = 400000,

    # Base branch override. Default: profile branch law default
    # (lifepunch-private -> main; dxrp-official -> develop).
    [ValidateSet('', 'main', 'develop')]
    [string] $BaseBranch = '',

    # Where the packet JSON is written. Created if missing.
    [string] $OutputDir = '.',

    # Overwrite an existing packet file with the same name.
    [switch] $Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'CornermanDropWorker.Lib.ps1')

# ------------------------------------------------------------- guards
if ($RequestModelCall -and $NoModelCall) {
    Write-Output 'ERROR: -RequestModelCall and -NoModelCall contradict each other. The worker would fail this packet closed (packet self-contradiction). Pick one.'
    exit 1
}
if ($RequestModelCall -and $RouteTag -eq 'AUTO OK') {
    Write-Output "ERROR: routeTag 'AUTO OK' is never routed to a Green model -- a model-call packet with this route always fails closed. Use GREEN DEEP REQUIRED or GREEN CODE REQUIRED."
    exit 1
}
if (@($ReadFiles).Count -eq 0 -and @($ReadGlobs).Count -eq 0) {
    Write-Output 'ERROR: at least one of -ReadFiles / -ReadGlobs is required (schema: inputs anyOf).'
    exit 1
}
foreach ($p in @($ReadFiles) + @($ReadGlobs) + @($RequiredDocs)) {
    if ([IO.Path]::IsPathRooted($p) -or $p -match '\.\.') {
        Write-Output "ERROR: input path must be repo-relative with no '..' traversal: $p"
        exit 1
    }
    if ($RepoProfile -eq 'dxrp-official') {
        foreach ($prefix in @('lifepunch/', 'lifepunchaddons/', 'lifepunchdxrp/')) {
            if (($p -replace '\\', '/').StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
                Write-Output "ERROR: dxrp-official packets must not cite private inputs ($prefix): $p"
                exit 1
            }
        }
    }
}

# --------------------------------------------------------- derivations
if (-not $Slug) {
    $source = if ($Title) { $Title } else { $Type }
    $Slug = ($source.ToLowerInvariant() -replace '[^a-z0-9]+', '-').Trim('-')
}
if ($Slug -notmatch '^[a-z0-9][a-z0-9-]*$') {
    Write-Output "ERROR: slug must match ^[a-z0-9][a-z0-9-]*$ (got '$Slug'). Pass -Slug explicitly."
    exit 1
}

$nowUtc = (Get-Date).ToUniversalTime()
$id = 'task-{0}-{1}' -f $nowUtc.ToString('yyyyMMdd-HHmmss'), $Slug

if (-not $OutboxName) {
    $OutboxName = ($Slug -replace '-', '_').ToUpperInvariant()
}

$profileDefaults = @{
    'lifepunch-private' = @{
        focus      = 'LifePunch'
        baseRemote = 'origin'
        baseBranch = 'main'
        repoPath   = 'C:\Users\jared\Projects\lifepunch'
    }
    'dxrp-official' = @{
        focus      = 'DXRP'
        baseRemote = 'upstream'
        baseBranch = 'develop'
        repoPath   = 'C:\Users\jared\Projects\dxrp-public'
    }
}
$defaults = $profileDefaults[$RepoProfile]
if (-not $BaseBranch) { $BaseBranch = $defaults.baseBranch }
if ($RepoProfile -eq 'dxrp-official' -and $BaseBranch -ne 'develop') {
    Write-Output "ERROR: dxrp-official base is always upstream/develop (got baseBranch '$BaseBranch')."
    exit 1
}

if (@($AllowedOutputTypes).Count -eq 0) {
    $typeToOutput = @{
        'distill'     = 'distill'
        'audit'       = 'audit'
        'summarize'   = 'summary'
        'pr-review'   = 'pr-review'
        'style-check' = 'style-check'
        'ip-scan'     = 'ip-scan'
        'file-map'    = 'file-map'
    }
    $AllowedOutputTypes = @($typeToOutput[$Type], 'checklist')
}

# ------------------------------------------------------- build packet
$inputs = [ordered]@{}
if (@($ReadFiles).Count -gt 0) { $inputs.readFiles = @($ReadFiles | ForEach-Object { $_ -replace '\\', '/' }) }
if (@($ReadGlobs).Count -gt 0) { $inputs.readGlobs = @($ReadGlobs | ForEach-Object { $_ -replace '\\', '/' }) }
if (@($RequiredDocs).Count -gt 0) { $inputs.requiredDocs = @($RequiredDocs | ForEach-Object { $_ -replace '\\', '/' }) }
$inputs.maxBytes = $MaxBytes
if ($ContextNotes) { $inputs.contextNotes = $ContextNotes }

$constraints = [ordered]@{
    noCommit     = $true
    noPush       = $true
    noProof      = $true
    noPatch      = $true
    noScheduler  = $true
    noSourceEdit = $true
}
if (-not $RequestModelCall) {
    # Safe default: default packets can never trigger a model call,
    # even against a worker running with -EnableModelCall.
    $constraints.noModelCall = $true
}
elseif ($NoModelCall) {
    $constraints.noModelCall = $true
}

$deliverable = [ordered]@{
    outboxName = $OutboxName
    format     = $Format
}
if (@($ExpectedSections).Count -gt 0) { $deliverable.expectedSections = @($ExpectedSections) }
$deliverable.audience = 'vengeance-cursor'

$packet = [ordered]@{
    schemaVersion = 2
    id            = $id
    type          = $Type
    createdBy     = ($env:COMPUTERNAME + '').ToLowerInvariant()
    createdTs     = $nowUtc.ToString('yyyy-MM-ddTHH:mm:ssZ')
    owner         = 'Bloodwave'
    repoProfile   = $RepoProfile
    repoPath      = $defaults.repoPath
    baseRemote    = $defaults.baseRemote
    baseBranch    = $BaseBranch
    routeTag      = $RouteTag
    focus         = $defaults.focus
    inputs        = $inputs
    instruction   = $Instruction
    allowedOutputTypes = @($AllowedOutputTypes)
    forbiddenScope     = @($ForbiddenScope)
    requiresMaintainerApproval = ($RepoProfile -eq 'dxrp-official')
    mode          = 'report'
    deliverable   = $deliverable
    constraints   = $constraints
}
if ($Title) { $packet.title = $Title }
if ($RequestModelCall) {
    $mc = [ordered]@{ enabled = $true }
    if ($RequiredModel) { $mc.requiredModel = $RequiredModel }
    $mc.allowFallback = $false
    $packet.modelCall = $mc
}

# ---------------------------------------------- validate with worker law
$asJson = $packet | ConvertTo-Json -Depth 8
$roundTrip = $asJson | ConvertFrom-Json
$schema = Test-CdwPacketSchema -Packet $roundTrip
if (-not $schema.Ok) {
    Write-Output 'ERROR: generated packet failed worker schema validation (bug or bad parameters):'
    foreach ($e in $schema.Errors) { Write-Output "  - $e" }
    exit 1
}

# --------------------------------------------------------------- write
if (-not (Test-Path -LiteralPath $OutputDir)) {
    New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
}
$outFile = Join-Path (Resolve-Path -LiteralPath $OutputDir).Path ($id + '.json')
if ((Test-Path -LiteralPath $outFile) -and -not $Force) {
    Write-Output "ERROR: packet file already exists (use -Force to overwrite): $outFile"
    exit 1
}
Write-CdwUtf8NoBom -Path $outFile -Text $asJson

$modelNote = if ($RequestModelCall) { 'MODEL CALL REQUESTED (worker must also run with -EnableModelCall)' } else { 'dry-run only (constraints.noModelCall=true)' }
Write-Output "OK: packet written: $outFile"
Write-Output "    id=$id profile=$RepoProfile route=$RouteTag format=$Format"
Write-Output "    $modelNote"
Write-Output '    Next: Send-CornermanTaskPacket.ps1 to drop it into the Green inbox.'
exit 0
