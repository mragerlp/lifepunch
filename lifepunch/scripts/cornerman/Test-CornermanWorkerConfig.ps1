# =====================================================================
# RISK: READ-ONLY (no writes, no HTTP -- offline validation only)  |  Slice 3
# NODE: Green (Cornerman) -- testable anywhere with -BaseDir scratch dirs
# WHAT: Operator helper. Validates the drop-worker deployment before a
#       run: worker script + lib present, BaseDir folders exist, repo
#       profile registry parses and carries the required fields, model
#       endpoint config parses, endpoints are localhost-only, and the
#       model-routable routeTags are configured. Prints PASS/FAIL per
#       check; exit 0 = all pass, exit 1 = at least one failure.
# NOT:  Never creates folders. Never fixes anything. NO HTTP -- it does
#       not probe the model endpoint (run the worker for that).
# LAW:  lifepunch/docs/CORNERMAN_HEADLESS_DROP_WORKER.md (runbook)
# USAGE:
#   powershell -NoProfile -File Test-CornermanWorkerConfig.ps1
#   powershell -NoProfile -File Test-CornermanWorkerConfig.ps1 -BaseDir C:\tmp\cdw -RegistryPath C:\tmp\cdw\repo-profiles.json
# =====================================================================

[CmdletBinding()]
param(
    [string] $BaseDir = 'C:\lifepunch\cornerman',
    [string] $RegistryPath = '',
    [string] $ModelConfigPath = '',

    # Also verify each profile's clone path exists and is a git repo.
    # Off by default because Red does not have the Green clone paths.
    [switch] $CheckClones
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'CornermanDropWorker.Lib.ps1')

if (-not $RegistryPath)    { $RegistryPath = Join-Path $BaseDir 'config\repo-profiles.json' }
if (-not $ModelConfigPath) { $ModelConfigPath = Join-Path $BaseDir 'config\model-endpoints.json' }

$script:failCount = 0
function Write-Check {
    param(
        [Parameter(Mandatory)][bool] $Ok,
        [Parameter(Mandatory)][string] $Label,
        [string] $Detail = ''
    )
    $mark = if ($Ok) { 'PASS' } else { 'FAIL' }
    if (-not $Ok) { $script:failCount++ }
    $line = "[{0}] {1}" -f $mark, $Label
    if ($Detail) { $line += " -- $Detail" }
    Write-Output $line
}

Write-Output "== Cornerman drop-worker config check (BaseDir: $BaseDir) =="

# ------------------------------------------------------- worker files
$workerScript = Join-Path $PSScriptRoot 'Invoke-CornermanDropWorker.ps1'
$libScript = Join-Path $PSScriptRoot 'CornermanDropWorker.Lib.ps1'
Write-Check (Test-Path -LiteralPath $workerScript) 'worker script exists' $workerScript
Write-Check (Test-Path -LiteralPath $libScript) 'worker library exists' $libScript

# ---------------------------------------------------- BaseDir folders
foreach ($sub in @('inbox', 'outbox', 'history', 'logs', 'lock')) {
    $p = Join-Path $BaseDir $sub
    Write-Check (Test-Path -LiteralPath $p -PathType Container) "folder exists: $sub" $p
}

# ---------------------------------------------------- profile registry
$reg = Read-CdwProfileRegistry -Path $RegistryPath
Write-Check $reg.Ok 'repo profile registry parses' ($(if ($reg.Ok) { $RegistryPath } else { $reg.Error }))
if ($reg.Ok) {
    foreach ($required in @('lifepunch-private', 'dxrp-official')) {
        $entry = $reg.Registry.profiles.PSObject.Properties |
            Where-Object { $_.Name -eq $required } | Select-Object -First 1
        Write-Check ([bool]$entry) "profile registered: $required"
        if ($entry) {
            $prof = $entry.Value
            $hasClone = ($prof.PSObject.Properties.Name -contains 'cloneWindows') -and
                        -not [string]::IsNullOrWhiteSpace([string]$prof.cloneWindows)
            $hasRemotes = ($prof.PSObject.Properties.Name -contains 'expectedRemotes') -and ($null -ne $prof.expectedRemotes)
            Write-Check $hasClone "profile has cloneWindows: $required"
            Write-Check $hasRemotes "profile has expectedRemotes: $required"
            if ($CheckClones -and $hasClone) {
                $clonePath = [string]$prof.cloneWindows
                $cloneOk = (Test-Path -LiteralPath $clonePath -PathType Container) -and
                           (Test-Path -LiteralPath (Join-Path $clonePath '.git'))
                Write-Check $cloneOk "clone exists + is a git repo: $required" $clonePath
            }
        }
    }
}

# -------------------------------------------------- model endpoint config
$cfg = Read-CdwModelConfig -Path $ModelConfigPath
Write-Check $cfg.Ok 'model endpoint config parses' ($(if ($cfg.Ok) { $ModelConfigPath } else { $cfg.Error }))
if ($cfg.Ok) {
    $local = Test-CdwModelEndpointLocal -Config $cfg.Config
    Write-Check $local.Ok 'endpoints are localhost-only' ($(if ($local.Ok) { [string]$cfg.Config.endpoint.chatUrl } else { $local.Error }))

    foreach ($route in @('GREEN DEEP REQUIRED', 'GREEN DAILY REQUIRED', 'GREEN CODE REQUIRED')) {
        $entry = $cfg.Config.routes.PSObject.Properties |
            Where-Object { $_.Name -eq $route } | Select-Object -First 1
        $routed = [bool]($entry -and -not [string]::IsNullOrWhiteSpace([string]$entry.Value))
        Write-Check $routed "routeTag has a configured model: $route" ($(if ($routed) { [string]$entry.Value } else { 'missing/empty in routes' }))
    }

    $autoOk = $cfg.Config.routes.PSObject.Properties |
        Where-Object { $_.Name -eq 'AUTO OK' } | Select-Object -First 1
    Write-Check (-not $autoOk) "'AUTO OK' is NOT routed to a Green model" ($(if ($autoOk) { 'remove AUTO OK from routes -- it belongs on Red' } else { '' }))

    $hasRequest = ($cfg.Config.PSObject.Properties.Name -contains 'request') -and ($null -ne $cfg.Config.request)
    Write-Check $hasRequest 'request tuning object present'
    if ($hasRequest -and ($cfg.Config.endpoint.PSObject.Properties.Name -contains 'callTimeoutSec')) {
        $timeoutOk = ([int]$cfg.Config.endpoint.callTimeoutSec) -lt (30 * 60)
        Write-Check $timeoutOk 'callTimeoutSec below default stale-lock window (30 min)' ("callTimeoutSec=" + $cfg.Config.endpoint.callTimeoutSec)
    }
}

# ---------------------------------------------------------------- result
Write-Output ''
if ($script:failCount -eq 0) {
    Write-Output 'RESULT: PASS -- worker deployment looks runnable. (This check performs no HTTP; endpoint liveness is proven by an actual run.)'
    exit 0
}
Write-Output ("RESULT: FAIL -- {0} check(s) failed. Fix the deployment before running the worker." -f $script:failCount)
exit 1
