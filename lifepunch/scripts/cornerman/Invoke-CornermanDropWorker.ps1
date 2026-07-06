# =====================================================================
# RISK: READ-ONLY on repos (validation + report only)  |  Slice 1 -- DRY-RUN
# NODE: Green (Cornerman) -- testable anywhere with -BaseDir scratch dirs
# WHAT: Headless drop-worker orchestrator. Processes ONE task-*.json packet
#       from the inbox per run: validate schema v2 -> resolve repoProfile ->
#       verify clone identity + clean tree -> validate lane/branch/input/
#       output rules -> no-IP / AI-trailer scan (dxrp-official) -> write a
#       DRY-RUN report + meta.json + ack -> move packet to history.
# NOT:  No model calls. No scheduler. No patches. No commit/push/PR.
#       No git mutation (fetch/checkout/pull/reset/clean/stash) -- ever.
# LAW:  lifepunch/docs/CORNERMAN_HEADLESS_DROP_WORKER.md (runbook)
#       lifepunch/docs/handoff/CORNERMAN_HEADLESS_DROP_WORKER_OPUS_V2_PLAN_2026-07-06.md
# USAGE:
#   powershell -NoProfile -File Invoke-CornermanDropWorker.ps1
#   powershell -NoProfile -File Invoke-CornermanDropWorker.ps1 -BaseDir C:\tmp\cdw-test -RegistryPath C:\tmp\cdw-test\repo-profiles.json
# =====================================================================

[CmdletBinding()]
param(
    # Worker root. Live Green default: C:\lifepunch\cornerman
    [string] $BaseDir = 'C:\lifepunch\cornerman',

    # Profile registry override (default: <BaseDir>\config\repo-profiles.json)
    [string] $RegistryPath = '',

    # Process a specific packet instead of the oldest inbox packet
    [string] $PacketFile = '',

    # Minutes before a lock from a dead/hung run is reclaimed
    [int] $StaleLockMinutes = 30
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'CornermanDropWorker.Lib.ps1')

$paths = Get-CdwDefaultPaths -BaseDir $BaseDir
if ($RegistryPath) { $paths.Registry = $RegistryPath }
Initialize-CdwFolders -Paths $paths

Write-CdwLog -LogDir $paths.Logs -Message "worker start (dry-run, slice 1) base=$BaseDir"

# ---------------------------------------------------------------- lock
$script:CdwLockReclaimNote = $null
$lock = Lock-CdwWorker -LockDir $paths.Lock -StaleMinutes $StaleLockMinutes
if (-not $lock.Ok) {
    Write-CdwLog -LogDir $paths.Logs -Message "exit: $($lock.Reason)"
    Write-Output "SKIP: $($lock.Reason)"
    exit 0
}
if ($script:CdwLockReclaimNote) {
    Write-CdwLog -LogDir $paths.Logs -Message $script:CdwLockReclaimNote
}

try {
    # ------------------------------------------------------- pick packet
    if ($PacketFile) {
        if (-not (Test-Path -LiteralPath $PacketFile)) {
            Write-Output "ERROR: packet file not found: $PacketFile"
            exit 1
        }
        $packetPath = (Resolve-Path -LiteralPath $PacketFile).Path
    }
    else {
        $candidate = Get-ChildItem -LiteralPath $paths.Inbox -Filter 'task-*.json' -File -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTimeUtc |
            Select-Object -First 1
        if (-not $candidate) {
            Write-CdwLog -LogDir $paths.Logs -Message 'no task packets in inbox'
            Write-Output 'IDLE: no task-*.json packets in inbox.'
            exit 0
        }
        $packetPath = $candidate.FullName
    }

    $taskId = [IO.Path]::GetFileNameWithoutExtension($packetPath)
    Write-CdwLog -LogDir $paths.Logs -Message "processing packet: $packetPath"

    $failures = New-Object System.Collections.Generic.List[string]
    $warnings = New-Object System.Collections.Generic.List[string]
    $packet = $null
    $profileName = ''
    $inputContentScan = $null   # dxrp-official cited-input scan result (null = not applicable)

    # ------------------------------------------------------- parse JSON
    try {
        $packet = Get-Content -LiteralPath $packetPath -Raw | ConvertFrom-Json
    }
    catch {
        $failures.Add("packet JSON unparseable: $($_.Exception.Message)")
    }

    # ---------------------------------------------------- schema checks
    if ($packet) {
        $schema = Test-CdwPacketSchema -Packet $packet
        if (-not $schema.Ok) { foreach ($e in $schema.Errors) { $failures.Add($e) } }

        if ($packet.PSObject.Properties.Name -contains 'id' -and $packet.id -and ([string]$packet.id -ne $taskId)) {
            $failures.Add("packet id '$($packet.id)' does not match filename '$taskId'")
        }
    }

    # ------------------------------------- profile + lane law (fail closed)
    $profile = $null
    if ($packet -and $failures.Count -eq 0) {
        $regRead = Read-CdwProfileRegistry -Path $paths.Registry
        if (-not $regRead.Ok) {
            $failures.Add($regRead.Error)
        }
        else {
            $res = Resolve-CdwProfile -Packet $packet -Registry $regRead.Registry
            if (-not $res.Ok) { $failures.Add($res.Error) }
            else {
                $profile = $res.Profile
                $profileName = $res.Name
            }
        }
    }

    if ($profile) {
        $focus = Test-CdwFocusAgreement -Packet $packet
        if (-not $focus.Ok) { $failures.Add($focus.Error) }

        $branch = Test-CdwBranchLaw -Packet $packet -Profile $profile
        if (-not $branch.Ok) { $failures.Add($branch.Error) }

        if ($profileName -eq 'dxrp-official' -and [string]$packet.type -eq 'pr-review') {
            $hasReviewBranch = ($packet.PSObject.Properties.Name -contains 'reviewBranch') -and
                -not [string]::IsNullOrWhiteSpace([string]$packet.reviewBranch)
            if (-not $hasReviewBranch) {
                $failures.Add('dxrp-official pr-review requires an explicit reviewBranch')
            }
        }

        $identity = Test-CdwCloneIdentity -Profile $profile
        if (-not $identity.Ok) { $failures.Add($identity.Error) }
        else {
            $dirty = Test-CdwCloneDirty -ClonePath ([string]$profile.cloneWindows)
            if (-not $dirty.Ok) { $failures.Add($dirty.Error) }

            $baseRef = Test-CdwBaseRefReadable -Packet $packet -Profile $profile
            if ($baseRef.Warning) { $warnings.Add($baseRef.Warning) }

            $inputCheck = Test-CdwInputPaths -Packet $packet -Profile $profile
            if (-not $inputCheck.Ok) { foreach ($e in $inputCheck.Errors) { $failures.Add($e) } }

            # Cited-input content scan (dxrp-official only): scan the file contents
            # the packet explicitly asks the worker to read -- never the whole repo.
            if ($profileName -eq 'dxrp-official' -and $inputCheck.Ok) {
                $inputContentScan = Invoke-CdwInputContentScan -Packet $packet -Profile $profile
                if (-not $inputContentScan.Ok) {
                    foreach ($e in $inputContentScan.Failures) { $failures.Add("no-IP/trailer scan: $e") }
                }
                if (@($inputContentScan.UnscannedGlobs).Count -gt 0) {
                    $warnings.Add("readGlobs content NOT scanned (glob expansion not implemented in Slice 1): $(@($inputContentScan.UnscannedGlobs) -join ', ')")
                }
            }
        }

        $scope = Test-CdwForbiddenScope -Packet $packet
        if (-not $scope.Ok) { $failures.Add($scope.Error) }
    }

    # ------------------------------------------------ build dry-run report
    $nowUtc = (Get-Date).ToUniversalTime().ToString('o')
    $reportText = ''

    if ($failures.Count -eq 0) {
        $lines = New-Object System.Collections.Generic.List[string]
        $lines.Add("# DRY-RUN VALIDATION REPORT - $taskId")
        $lines.Add('')
        $lines.Add('Slice 1 dry-run: packet validated only. No model call was made; no artifact')
        $lines.Add('content was generated; no git mutation, commit, push, PR, patch, scheduler,')
        $lines.Add('or proof action was performed.')
        $lines.Add('')
        $lines.Add('## Packet')
        $lines.Add("- id: $($packet.id)")
        if ($packet.PSObject.Properties.Name -contains 'title' -and $packet.title) { $lines.Add("- title: $($packet.title)") }
        $lines.Add("- type: $($packet.type)")
        $lines.Add("- repoProfile: $profileName")
        $lines.Add("- base: $($packet.baseRemote)/$($packet.baseBranch)")
        if ($packet.PSObject.Properties.Name -contains 'reviewBranch' -and $packet.reviewBranch) { $lines.Add("- reviewBranch: $($packet.reviewBranch)") }
        $lines.Add("- focus: $($packet.focus)")
        $lines.Add("- routeTag: $($packet.routeTag)")
        $lines.Add("- mode: $($packet.mode)")
        $lines.Add("- allowedOutputTypes: $(@($packet.allowedOutputTypes) -join ', ')")
        $lines.Add('')
        $lines.Add('## Validation results')
        $lines.Add('- schema v2: PASS')
        $lines.Add('- repoProfile resolved from registry: PASS')
        $lines.Add('- clone identity (path + remotes): PASS')
        $lines.Add('- dirty-tree gate (untracked = dirty): PASS (clean)')
        $lines.Add('- focus/profile agreement: PASS')
        $lines.Add('- branch/base law: PASS')
        $lines.Add('- input path safety (repo-relative, no .., size cap): PASS')
        if ($profileName -eq 'dxrp-official') {
            $scannedCount = if ($inputContentScan) { @($inputContentScan.ScannedFiles).Count } else { 0 }
            $lines.Add("- cited input content scan (inputs.readFiles): PASS ($scannedCount file(s) scanned)")
            if ($inputContentScan -and @($inputContentScan.ScannedFiles).Count -gt 0) {
                foreach ($sf in @($inputContentScan.ScannedFiles)) { $lines.Add("  - scanned: $sf") }
            }
        }
        else {
            $lines.Add('- cited input content scan: not applicable (lifepunch-private)')
        }
        $lines.Add('- allowedOutputTypes / forbiddenScope: PASS')
        foreach ($w in $warnings) { $lines.Add("- WARNING: $w") }
        $lines.Add('')

        # proof expectations -> checklist only, never a proof claim
        $proofRequired = $false
        if ($packet.PSObject.Properties.Name -contains 'proof' -and $packet.proof -and
            ($packet.proof.PSObject.Properties.Name -contains 'required')) {
            $proofRequired = [bool]$packet.proof.required
        }
        if ($proofRequired) {
            $lines.Add('## Proof checklist (for Red -- NOT a proof claim)')
            $lines.Add('Cornerman eyes are covered: no runtime proof was or can be performed here.')
            $proofType = ''
            if ($packet.proof.PSObject.Properties.Name -contains 'type') { $proofType = [string]$packet.proof.type }
            if ($proofType) { $lines.Add("- [ ] Red runs proof type: $proofType") }
            if ($packet.proof.PSObject.Properties.Name -contains 'mapHint' -and $packet.proof.mapHint) {
                $lines.Add("- [ ] Proof map: $($packet.proof.mapHint)")
            }
            if ($packet.proof.PSObject.Properties.Name -contains 'evidenceExpected' -and $packet.proof.evidenceExpected) {
                foreach ($ev in @($packet.proof.evidenceExpected)) { $lines.Add("- [ ] Evidence: $ev") }
            }
            $lines.Add('')
        }

        # commit/PR authority -> handoff text only, never execution
        $commitAllowed = $false
        if ($packet.PSObject.Properties.Name -contains 'commit' -and $packet.commit -and
            ($packet.commit.PSObject.Properties.Name -contains 'allowed')) {
            $commitAllowed = [bool]$packet.commit.allowed
        }
        $lines.Add('## Commit / PR authority (handoff for Red -- worker never commits/pushes/PRs)')
        if ($commitAllowed) {
            $suggestion = ''
            if ($packet.commit.PSObject.Properties.Name -contains 'messageSuggestion') {
                $suggestion = [string]$packet.commit.messageSuggestion
            }
            $lines.Add('- Commit: permitted downstream on Red after Bloodwave GO.')
            if ($suggestion) { $lines.Add("- Suggested message: $suggestion") }
        }
        else {
            $lines.Add('- Commit: FORBIDDEN for this task. No commit instructions are provided.')
        }
        $prAllowed = $false
        if ($packet.PSObject.Properties.Name -contains 'pr' -and $packet.pr -and
            ($packet.pr.PSObject.Properties.Name -contains 'allowed')) {
            $prAllowed = [bool]$packet.pr.allowed
        }
        if ($prAllowed -and (@($packet.allowedOutputTypes) -contains 'pr-body')) {
            $lines.Add('- PR: pr-body drafting is permitted by allowedOutputTypes (Slice 2+; not generated in dry-run).')
        }
        elseif ($prAllowed) {
            $lines.Add("- PR: pr.allowed is true but 'pr-body' is not in allowedOutputTypes -- PR text may NOT be drafted.")
        }
        else {
            $lines.Add('- PR: not permitted for this task.')
        }
        $lines.Add('')
        $lines.Add("Generated: $nowUtc (dry-run worker, Slice 1)")
        $reportText = ($lines -join [Environment]::NewLine)

        # ---------------------------- no-IP / trailer scan (dxrp-official)
        if ($profileName -eq 'dxrp-official') {
            $scanTargets = @($reportText, [string]$packet.instruction)
            if ($packet.inputs.PSObject.Properties.Name -contains 'contextNotes' -and $packet.inputs.contextNotes) {
                $scanTargets += [string]$packet.inputs.contextNotes
            }
            foreach ($target in $scanTargets) {
                $scan = Invoke-CdwNoIpScan -Text $target
                if (-not $scan.Ok) {
                    foreach ($m in $scan.Matches) { $failures.Add("no-IP/trailer scan: $m") }
                }
            }
            if ($failures.Count -gt 0) { $reportText = '' }  # blocked output is never written
        }
    }

    # ----------------------------------------------------- write results
    $ok = ($failures.Count -eq 0)
    $inputScanStatus = 'not-applicable'
    $scannedInputFiles = @()
    if ($profileName -eq 'dxrp-official') {
        if ($inputContentScan) {
            $inputScanStatus = if ($inputContentScan.Ok) { 'pass' } else { 'fail' }
            $scannedInputFiles = @($inputContentScan.ScannedFiles)
        }
        else {
            # earlier validation failed before the content scan could run
            $inputScanStatus = 'not-run'
        }
    }
    $meta = [ordered]@{
        id          = $taskId
        status      = if ($ok) { 'dry-run-ok' } else { 'failed' }
        dryRun      = $true
        slice       = 1
        repoProfile = $profileName
        startedUtc  = $nowUtc
        finishedUtc = (Get-Date).ToUniversalTime().ToString('o')
        scannedInputFiles = $scannedInputFiles
        inputContentScan  = $inputScanStatus
        warnings    = @($warnings)
        failures    = @($failures)
        worker      = @{ host = $env:COMPUTERNAME; pid = $PID; script = 'Invoke-CornermanDropWorker.ps1' }
        actionsNotPerformed = @('model-call', 'scheduler-install', 'patch', 'commit', 'push', 'pr', 'proof', 'git-mutation')
    }

    if ($ok) {
        $outDir = Write-CdwOutboxArtifacts -Paths $paths -TaskId $taskId -ReportText $reportText -Meta $meta
        Add-CdwAck -Paths $paths -TaskId $taskId -Ok $true -Detail 'dry-run validation passed'
        $hist = Move-CdwPacketToHistory -Paths $paths -PacketFile $packetPath -Status 'ok'
        Write-CdwLog -LogDir $paths.Logs -Message "OK: $taskId -> $outDir (history: $hist)"
        Write-Output "OK: $taskId dry-run validation passed. Report: $outDir\report.md"
    }
    else {
        $errLines = @("# TASK FAILED (dry-run) - $taskId", '') + @($failures | ForEach-Object { "- $_" })
        $errText = ($errLines -join [Environment]::NewLine)
        $outDir = Write-CdwOutboxArtifacts -Paths $paths -TaskId $taskId -ReportText '' -Meta $meta -ErrorText $errText
        Add-CdwAck -Paths $paths -TaskId $taskId -Ok $false -Detail ($failures -join ' | ')
        $hist = Move-CdwPacketToHistory -Paths $paths -PacketFile $packetPath -Status 'fail'
        Write-CdwLog -LogDir $paths.Logs -Message "FAIL: $taskId -- $($failures -join ' | ')"
        Write-Output "FAIL: $taskId -- $($failures.Count) failure(s). Error report: $outDir\error.md"
        foreach ($f in $failures) { Write-Output "  - $f" }
    }
}
finally {
    Unlock-CdwWorker -LockDir $paths.Lock
    Write-CdwLog -LogDir $paths.Logs -Message 'worker end (lock released)'
}
