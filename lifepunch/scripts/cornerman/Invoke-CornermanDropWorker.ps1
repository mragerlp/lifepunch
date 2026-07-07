# =====================================================================
# RISK: READ-ONLY on repos; localhost-only model HTTP  |  Slice 2
# NODE: Green (Cornerman) -- testable anywhere with -BaseDir scratch dirs
# WHAT: Headless drop-worker orchestrator. Processes ONE task-*.json packet
#       from the inbox per run: validate schema v2 -> resolve repoProfile ->
#       verify clone identity + clean tree -> validate lane/branch/input/
#       output rules -> expand globs -> no-IP / AI-trailer scan
#       (dxrp-official) -> EITHER dry-run report (default) OR, with double
#       opt-in (-EnableModelCall + packet modelCall.enabled=true), a local
#       LM Studio model call that generates the real report.
# NOT:  No scheduler. No patches. No commit/push/PR. No git mutation
#       (fetch/checkout/pull/reset/clean/stash) -- ever. No network egress
#       beyond localhost. NO HTTP of any kind (not even the model probe)
#       until every pre-call gate passes.
# LAW:  lifepunch/docs/CORNERMAN_HEADLESS_DROP_WORKER.md (runbook)
#       lifepunch/docs/handoff/CORNERMAN_HEADLESS_DROP_WORKER_OPUS_V2_PLAN_2026-07-06.md
#       lifepunch/docs/handoff/CORNERMAN_DROP_WORKER_SLICE2_MODEL_CALL_PLAN_2026-07-06.md
# USAGE:
#   powershell -NoProfile -File Invoke-CornermanDropWorker.ps1
#   powershell -NoProfile -File Invoke-CornermanDropWorker.ps1 -EnableModelCall
#   powershell -NoProfile -File Invoke-CornermanDropWorker.ps1 -BaseDir C:\tmp\cdw-test -RegistryPath C:\tmp\cdw-test\repo-profiles.json
# =====================================================================

[CmdletBinding()]
param(
    # Worker root. Live Green default: C:\lifepunch\cornerman
    [string] $BaseDir = 'C:\lifepunch\cornerman',

    # Profile registry override (default: <BaseDir>\config\repo-profiles.json)
    [string] $RegistryPath = '',

    # Model endpoint config override (default: <BaseDir>\config\model-endpoints.json)
    [string] $ModelConfigPath = '',

    # Process a specific packet instead of the oldest inbox packet
    [string] $PacketFile = '',

    # Minutes before a lock from a dead/hung run is reclaimed
    [int] $StaleLockMinutes = 30,

    # Operator-side model-call opt-in. Without this switch the worker NEVER
    # performs HTTP; packets requesting a model call fail closed.
    [switch] $EnableModelCall
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'CornermanDropWorker.Lib.ps1')

$paths = Get-CdwDefaultPaths -BaseDir $BaseDir
if ($RegistryPath) { $paths.Registry = $RegistryPath }
$modelConfigFile = Join-Path $BaseDir 'config\model-endpoints.json'
if ($ModelConfigPath) { $modelConfigFile = $ModelConfigPath }
Initialize-CdwFolders -Paths $paths

$workerEnabled = [bool]$EnableModelCall.IsPresent
Write-CdwLog -LogDir $paths.Logs -Message "worker start (slice 2) base=$BaseDir modelCallEnabled=$workerEnabled"

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
    $failureStage = ''             # first failing stage label for meta.json
    $inputContentScan = $null      # dxrp-official cited-input scan result (null = not applicable)
    $globFiles = @()               # expanded readGlobs (repo-relative)
    $packetRequestedModel = $false
    $runAction = 'dry-run'         # dry-run | model-call (decided by policy gate)
    $modelConfig = $null
    $modelId = ''
    $modelMeta = $null             # model call metadata for meta.json
    $outputScanStatus = 'not-applicable'
    $missingSections = @()

    $script:failureStageSet = $false

    # ------------------------------------------- gate 1: parse JSON
    try {
        $packet = Get-Content -LiteralPath $packetPath -Raw | ConvertFrom-Json
    }
    catch {
        $failures.Add("packet JSON unparseable: $($_.Exception.Message)")
        $failureStage = 'pre-model-validation'; $script:failureStageSet = $true
    }

    # ------------------------------------------- gate 2: schema checks
    if ($packet) {
        $schema = Test-CdwPacketSchema -Packet $packet
        if (-not $schema.Ok) {
            foreach ($e in $schema.Errors) { $failures.Add($e) }
            if (-not $script:failureStageSet) { $failureStage = 'pre-model-validation'; $script:failureStageSet = $true }
        }

        if ($packet.PSObject.Properties.Name -contains 'id' -and $packet.id -and ([string]$packet.id -ne $taskId)) {
            $failures.Add("packet id '$($packet.id)' does not match filename '$taskId'")
            if (-not $script:failureStageSet) { $failureStage = 'pre-model-validation'; $script:failureStageSet = $true }
        }
    }

    # --------------------------- gates 3-5: profile + registry + clone
    $profile = $null
    if ($packet -and $failures.Count -eq 0) {
        $regRead = Read-CdwProfileRegistry -Path $paths.Registry
        if (-not $regRead.Ok) {
            $failures.Add($regRead.Error)
            $failureStage = 'pre-model-validation'; $script:failureStageSet = $true
        }
        else {
            $res = Resolve-CdwProfile -Packet $packet -Registry $regRead.Registry
            if (-not $res.Ok) {
                $failures.Add($res.Error)
                $failureStage = 'pre-model-validation'; $script:failureStageSet = $true
            }
            else {
                $profile = $res.Profile
                $profileName = $res.Name
            }
        }
    }

    if ($profile) {
        # ------------------------------- gates 6-9 + 11-12 (profile law)
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

            # ------------------- gate 10: glob expansion + combined size
            if ($inputCheck.Ok -and $failures.Count -eq 0) {
                $globExp = Expand-CdwReadGlobs -Packet $packet -Profile $profile
                if (-not $globExp.Ok) {
                    foreach ($e in $globExp.Errors) { $failures.Add($e) }
                }
                else {
                    $globFiles = @($globExp.Files)
                    if ($globFiles.Count -gt 0) {
                        $globBytes = [long]0
                        foreach ($rel in $globFiles) {
                            $full = Join-Path ([string]$profile.cloneWindows) (([string]$rel) -replace '/', '\')
                            if (Test-Path -LiteralPath $full -PathType Leaf) {
                                $globBytes += (Get-Item -LiteralPath $full).Length
                            }
                        }
                        $combined = [long]$inputCheck.TotalBytes + $globBytes
                        if ($combined -gt [long]$packet.inputs.maxBytes) {
                            $failures.Add("combined input bytes $combined (readFiles + expanded globs) exceed inputs.maxBytes $($packet.inputs.maxBytes)")
                        }
                    }
                }
            }

            # -------- gate 16 (part 1): dxrp cited-input content scan
            # (covers readFiles AND expanded glob files in Slice 2)
            if ($profileName -eq 'dxrp-official' -and $inputCheck.Ok -and $failures.Count -eq 0) {
                $inputContentScan = Invoke-CdwInputContentScan -Packet $packet -Profile $profile -GlobFiles $globFiles -GlobsExpanded $true
                if (-not $inputContentScan.Ok) {
                    foreach ($e in $inputContentScan.Failures) { $failures.Add("no-IP/trailer scan: $e") }
                }
            }
        }

        $scope = Test-CdwForbiddenScope -Packet $packet
        if (-not $scope.Ok) { $failures.Add($scope.Error) }
    }
    if ($failures.Count -gt 0 -and -not $script:failureStageSet) {
        $failureStage = 'pre-model-validation'; $script:failureStageSet = $true
    }

    # -------------------- gate 15: modelCall double opt-in policy
    # (network-silent; evaluated for every parsed packet)
    if ($packet) {
        $policy = Test-CdwModelCallPolicy -Packet $packet -EnableModelCall $workerEnabled
        $packetRequestedModel = [bool]$policy.PacketRequested
        if ($policy.Action -eq 'fail') {
            $failures.Add($policy.Error)
            if (-not $script:failureStageSet) {
                if ($policy.Error -like 'model-call-requested-but-worker-not-enabled*') {
                    $failureStage = 'model-call-requested-but-worker-not-enabled'
                }
                else {
                    $failureStage = 'packet-self-contradiction'
                }
                $script:failureStageSet = $true
            }
        }
        elseif ($policy.Action -eq 'model-call' -and $failures.Count -eq 0) {
            $runAction = 'model-call'
        }
    }

    # ---- gates 13-14: model route + localhost endpoint (model runs only)
    $packedInputs = $null
    if ($runAction -eq 'model-call' -and $failures.Count -eq 0) {
        $cfgRead = Read-CdwModelConfig -Path $modelConfigFile
        if (-not $cfgRead.Ok) {
            $failures.Add($cfgRead.Error)
            if (-not $script:failureStageSet) { $failureStage = 'pre-model-validation'; $script:failureStageSet = $true }
        }
        else {
            $modelConfig = $cfgRead.Config

            # lock lifetime must exceed the model call timeout (plan risk guard)
            $cfgTimeout = 300
            if ($modelConfig.endpoint.PSObject.Properties.Name -contains 'callTimeoutSec' -and $modelConfig.endpoint.callTimeoutSec) {
                $cfgTimeout = [int]$modelConfig.endpoint.callTimeoutSec
            }
            if (($StaleLockMinutes * 60) -le $cfgTimeout) {
                $failures.Add("StaleLockMinutes ($StaleLockMinutes min) must exceed model callTimeoutSec ($cfgTimeout s) -- raise -StaleLockMinutes or lower the timeout")
                if (-not $script:failureStageSet) { $failureStage = 'pre-model-validation'; $script:failureStageSet = $true }
            }

            $local = Test-CdwModelEndpointLocal -Config $modelConfig
            if (-not $local.Ok) {
                $failures.Add($local.Error)
                if (-not $script:failureStageSet) { $failureStage = 'endpoint-not-localhost'; $script:failureStageSet = $true }
            }

            if ($failures.Count -eq 0) {
                $route = Resolve-CdwModelRoute -Packet $packet -Config $modelConfig
                if (-not $route.Ok) {
                    $failures.Add($route.Error)
                    if (-not $script:failureStageSet) {
                        if ($route.Error -like 'model-route-conflict*') { $failureStage = 'model-route-conflict' }
                        else { $failureStage = 'pre-model-validation' }
                        $script:failureStageSet = $true
                    }
                }
                else {
                    $modelId = [string]$route.ModelId
                    if ($route.AllowFallbackIgnoredWarning) { $warnings.Add($route.AllowFallbackIgnoredWarning) }
                }
            }

            # gate 10 (context cap) -- pack inputs BEFORE any HTTP
            if ($failures.Count -eq 0) {
                $maxPromptChars = [long]120000
                if ($modelConfig.request.PSObject.Properties.Name -contains 'maxPromptChars' -and $modelConfig.request.maxPromptChars) {
                    $maxPromptChars = [long]$modelConfig.request.maxPromptChars
                }
                $packedInputs = Get-CdwPackedInputs -Packet $packet -Profile $profile -GlobFiles $globFiles -MaxPromptChars $maxPromptChars
                if (-not $packedInputs.Ok) {
                    foreach ($e in $packedInputs.Errors) { $failures.Add($e) }
                    if (-not $script:failureStageSet) { $failureStage = 'pre-model-validation'; $script:failureStageSet = $true }
                }
            }

            # gate 16 (part 2): dxrp pre-call scan of instruction + contextNotes
            if ($failures.Count -eq 0 -and $profileName -eq 'dxrp-official') {
                $preTargets = @([string]$packet.instruction)
                if ($packet.inputs.PSObject.Properties.Name -contains 'contextNotes' -and $packet.inputs.contextNotes) {
                    $preTargets += [string]$packet.inputs.contextNotes
                }
                foreach ($t in $preTargets) {
                    $scan = Invoke-CdwNoIpScan -Text $t
                    if (-not $scan.Ok) {
                        foreach ($m in $scan.Matches) { $failures.Add("no-IP/trailer scan (pre-call): $m") }
                    }
                }
                if ($failures.Count -gt 0 -and -not $script:failureStageSet) {
                    $failureStage = 'pre-model-validation'; $script:failureStageSet = $true
                }
            }
        }
    }

    # =====================================================================
    # ALL PRE-CALL GATES COMPLETE. HTTP is permitted beyond this point ONLY
    # for runAction='model-call' with zero failures.
    # =====================================================================

    $nowUtc = (Get-Date).ToUniversalTime().ToString('o')
    $reportText = ''
    $reportFileName = 'report.md'
    $modelCallPerformed = $false

    if ($runAction -eq 'model-call' -and $failures.Count -eq 0) {
        # ------------------------------------------------ model probe
        $probe = Invoke-CdwModelProbe -Config $modelConfig
        $modelMeta = [ordered]@{
            endpoint       = [string]$modelConfig.endpoint.chatUrl
            requestedRoute = [string]$packet.routeTag
            modelId        = $modelId
            probeOk        = [bool]$probe.Ok
            loadedModels   = @($probe.Models)
        }
        if (-not $probe.Ok) {
            $failures.Add($probe.Error)
            if (-not $script:failureStageSet) { $failureStage = 'endpoint-down'; $script:failureStageSet = $true }
        }
        elseif (@($probe.Models) -notcontains $modelId) {
            $failures.Add("model '$modelId' not available at endpoint (loaded: $(@($probe.Models) -join ', '))")
            if (-not $script:failureStageSet) { $failureStage = 'model-unavailable'; $script:failureStageSet = $true }
        }
        else {
            # -------------------------------------------- model call
            $reqBuild = Build-CdwModelRequest -Packet $packet -ProfileName $profileName -ModelId $modelId `
                -PackedInputs ([string]$packedInputs.PackedText) `
                -ReferenceInputs ([string]$packedInputs.ReferenceText) -Config $modelConfig
            $callStart = (Get-Date).ToUniversalTime().ToString('o')
            $call = Invoke-CdwModelCall -Config $modelConfig -Body $reqBuild.Body
            $callEnd = (Get-Date).ToUniversalTime().ToString('o')
            $modelCallPerformed = $true

            $modelMeta.callStartedUtc = $callStart
            $modelMeta.callFinishedUtc = $callEnd
            $modelMeta.durationSeconds = $call.DurationSeconds
            $modelMeta.promptChars = ([string]$reqBuild.UserPrompt).Length
            $modelMeta.inputFilesPacked = @($packedInputs.Files)
            $modelMeta.globExpandedFiles = @($globFiles)
            $modelMeta.finishReason = $call.FinishReason
            $modelMeta.temperature = $reqBuild.Body.temperature
            $modelMeta.maxTokens = $reqBuild.Body.max_tokens

            if (-not $call.Ok) {
                $failures.Add($call.Error)
                if (-not $script:failureStageSet) { $failureStage = [string]$call.Stage; $script:failureStageSet = $true }
            }
            else {
                $rawOutput = [string]$call.Content
                $modelMeta.outputChars = $rawOutput.Length

                # ------------- gate: post-call output scan (dxrp-official)
                # Runs on RAW output BEFORE any validation or write. Blocked
                # output text is discarded and never written anywhere
                # (including logs) -- only token names are recorded.
                if ($profileName -eq 'dxrp-official') {
                    $outScan = Invoke-CdwNoIpScan -Text $rawOutput
                    if (-not $outScan.Ok) {
                        $outputScanStatus = 'fail'
                        foreach ($m in $outScan.Matches) { $failures.Add("output scan blocked generated text: $m") }
                        if (-not $script:failureStageSet) { $failureStage = 'output-scan-blocked'; $script:failureStageSet = $true }
                        $rawOutput = ''
                    }
                    else {
                        $outputScanStatus = 'pass'
                    }
                }

                # --------------------- format-aware output validation
                if ($failures.Count -eq 0) {
                    $expected = @()
                    if ($packet.deliverable.PSObject.Properties.Name -contains 'expectedSections' -and $packet.deliverable.expectedSections) {
                        $expected = @($packet.deliverable.expectedSections | ForEach-Object { [string]$_ })
                    }
                    $outCheck = Test-CdwModelOutput -OutputText $rawOutput -Format ([string]$packet.deliverable.format) -ExpectedSections $expected
                    foreach ($w in $outCheck.Warnings) { $warnings.Add($w) }
                    $missingSections = @($outCheck.MissingSections)
                    if (-not $outCheck.Ok) {
                        foreach ($e in $outCheck.Errors) { $failures.Add($e) }
                        if (-not $script:failureStageSet) { $failureStage = [string]$outCheck.Stage; $script:failureStageSet = $true }
                    }
                    else {
                        $reportText = [string]$outCheck.OutputText
                        switch ([string]$packet.deliverable.format) {
                            'json' { $reportFileName = 'report.json' }
                            'text' { $reportFileName = 'report.txt' }
                            default { $reportFileName = 'report.md' }
                        }
                    }
                }
            }
        }
    }
    elseif ($failures.Count -eq 0) {
        # ------------------------------------------------ dry-run report
        $lines = New-Object System.Collections.Generic.List[string]
        $lines.Add("# DRY-RUN VALIDATION REPORT - $taskId")
        $lines.Add('')
        $lines.Add('Dry-run: packet validated only. No model call was made; no artifact')
        $lines.Add('content was generated; no git mutation, commit, push, PR, patch, scheduler,')
        $lines.Add('or proof action was performed.')
        if ($workerEnabled -and -not $packetRequestedModel) {
            $lines.Add('')
            $lines.Add('Worker was started with -EnableModelCall, but this packet does not set')
            $lines.Add('modelCall.enabled=true -- dry-run by packet choice (double opt-in).')
        }
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
        if ($globFiles.Count -gt 0) {
            $lines.Add("- glob expansion: $($globFiles.Count) file(s) matched readGlobs")
        }
        if ($profileName -eq 'dxrp-official') {
            $scannedCount = 0
            if ($inputContentScan) { $scannedCount = @($inputContentScan.ScannedFiles).Count }
            $lines.Add("- cited input content scan (readFiles + expanded globs): PASS ($scannedCount file(s) scanned)")
            if ($inputContentScan -and @($inputContentScan.ScannedFiles).Count -gt 0) {
                foreach ($sf in @($inputContentScan.ScannedFiles)) { $lines.Add("  - scanned: $sf") }
            }
        }
        else {
            $lines.Add('- cited input content scan: not applicable (lifepunch-private)')
        }
        $lines.Add('- allowedOutputTypes / forbiddenScope: PASS')
        $lines.Add("- modelCall opt-in: worker=$workerEnabled packet=$packetRequestedModel -> dry-run")
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
            $lines.Add('- PR: pr-body drafting is permitted by allowedOutputTypes (model runs only; not generated in dry-run).')
        }
        elseif ($prAllowed) {
            $lines.Add("- PR: pr.allowed is true but 'pr-body' is not in allowedOutputTypes -- PR text may NOT be drafted.")
        }
        else {
            $lines.Add('- PR: not permitted for this task.')
        }
        $lines.Add('')
        $lines.Add("Generated: $nowUtc (worker Slice 2, dry-run mode)")
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
            if ($failures.Count -gt 0) {
                $reportText = ''  # blocked output is never written
                if (-not $script:failureStageSet) { $failureStage = 'pre-model-validation'; $script:failureStageSet = $true }
            }
        }
    }

    # ----------------------------------------------------- write results
    $ok = ($failures.Count -eq 0)
    $inputScanStatus = 'not-applicable'
    $scannedInputFiles = @()
    if ($profileName -eq 'dxrp-official') {
        if ($inputContentScan) {
            if ($inputContentScan.Ok) { $inputScanStatus = 'pass' } else { $inputScanStatus = 'fail' }
            $scannedInputFiles = @($inputContentScan.ScannedFiles)
        }
        else {
            # earlier validation failed before the content scan could run
            $inputScanStatus = 'not-run'
        }
    }

    $isModelRun = ($runAction -eq 'model-call')
    $ackAction = if ($isModelRun) { 'drop-worker-live' } else { 'drop-worker-dryrun' }
    $status = 'failed'
    if ($ok) {
        if ($isModelRun) { $status = 'ok' } else { $status = 'dry-run-ok' }
    }
    $actionsNotPerformed = New-Object System.Collections.Generic.List[string]
    if (-not $modelCallPerformed) { $actionsNotPerformed.Add('model-call') }
    foreach ($a in @('scheduler-install', 'patch', 'commit', 'push', 'pr', 'proof', 'git-mutation')) {
        $actionsNotPerformed.Add($a)
    }

    $meta = [ordered]@{
        id          = $taskId
        status      = $status
        dryRun      = (-not $isModelRun)
        slice       = 2
        repoProfile = $profileName
        startedUtc  = $nowUtc
        finishedUtc = (Get-Date).ToUniversalTime().ToString('o')
        workerModelCallEnabled   = $workerEnabled
        packetModelCallRequested = $packetRequestedModel
        scannedInputFiles = $scannedInputFiles
        inputContentScan  = $inputScanStatus
        outputScan  = $outputScanStatus
        failureStage = $failureStage
        missingExpectedSections = @($missingSections)
        warnings    = @($warnings)
        failures    = @($failures)
        worker      = @{ host = $env:COMPUTERNAME; pid = $PID; script = 'Invoke-CornermanDropWorker.ps1' }
        actionsNotPerformed = @($actionsNotPerformed)
    }
    if ($modelMeta) { $meta.model = $modelMeta }

    if ($ok) {
        $outDir = Join-Path $paths.Outbox $taskId
        if (-not (Test-Path -LiteralPath $outDir)) { New-Item -ItemType Directory -Force -Path $outDir | Out-Null }
        Write-CdwUtf8NoBom -Path (Join-Path $outDir $reportFileName) -Text $reportText
        Write-CdwUtf8NoBom -Path (Join-Path $outDir 'meta.json') -Text (($meta | ConvertTo-Json -Depth 8))
        $detail = 'dry-run validation passed'
        if ($isModelRun) { $detail = "model report generated ($modelId)" }
        Add-CdwAck -Paths $paths -TaskId $taskId -Ok $true -Detail $detail -Action $ackAction
        $hist = Move-CdwPacketToHistory -Paths $paths -PacketFile $packetPath -Status 'ok'
        Write-CdwLog -LogDir $paths.Logs -Message "OK: $taskId -> $outDir (history: $hist)"
        Write-Output "OK: $taskId $detail. Report: $outDir\$reportFileName"
    }
    else {
        $errLines = @("# TASK FAILED - $taskId", '')
        if ($failureStage) { $errLines += @("failureStage: $failureStage", '') }
        $errLines += @($failures | ForEach-Object { "- $_" })
        $errText = ($errLines -join [Environment]::NewLine)
        $outDir = Write-CdwOutboxArtifacts -Paths $paths -TaskId $taskId -ReportText '' -Meta $meta -ErrorText $errText
        Add-CdwAck -Paths $paths -TaskId $taskId -Ok $false -Detail ($failures -join ' | ') -Action $ackAction
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
