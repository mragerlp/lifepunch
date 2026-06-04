# Sync LifePunch Cloudflare worker / rules between OneDrive and the repo.
# Canonical OneDrive folder: %USERPROFILE%\OneDrive\Lifepunch\Rules
#
# Workflow:
#   Push    — repo worker -> Rules-Test1 only (sandbox / in-game test deploy)
#   Pull    — Rules-Test1 -> repo worker + repo mirror (after editing Test1 on OneDrive)
#   Promote — Rules-Test1 -> Rules-V1 (production paste) — run only when you intend to ship V1
param(
    [ValidateSet("Pull", "Push", "Promote")]
    [string]$Direction = "Pull"
)

$ErrorActionPreference = "Stop"

function Get-OneDriveRulesDir {
    $candidates = @(
        (Join-Path $env:USERPROFILE "OneDrive\Lifepunch\Rules"),
        (Join-Path $env:USERPROFILE "OneDrive\Documents\Lifepunch\Rules")
    )
    foreach ($dir in $candidates) {
        if (Test-Path $dir) {
            return $dir
        }
    }
    throw "OneDrive rules folder not found. Expected OneDrive\Lifepunch\Rules (or legacy OneDrive\Documents\Lifepunch\Rules)."
}

function Copy-RequiredRuleFile {
    param(
        [string]$Name,
        [string]$SourceRoot,
        [string]$TargetRoot
    )

    $source = Join-Path $SourceRoot $Name
    $target = Join-Path $TargetRoot $Name

    if (-not (Test-Path $source)) {
        throw "Required file not found: $source"
    }

    Copy-Item $source $target -Force
    Write-Host "Synced $Name"
    Write-Host "  $source"
    Write-Host "  -> $target"
}

$oneDriveRules = Get-OneDriveRulesDir
$repoRules = (Join-Path $PSScriptRoot "..\Rules" | Resolve-Path).Path
$workerPath = (Join-Path $PSScriptRoot "..\cloudflare-worker.mjs" | Resolve-Path).Path
$oneDriveTest1 = Join-Path $oneDriveRules "Rules-Test1.txt"
$oneDriveV1 = Join-Path $oneDriveRules "Rules-V1.txt"
$repoTest1 = Join-Path $repoRules "Rules-Test1.txt"
$repoV1 = Join-Path $repoRules "Rules-V1.txt"

Write-Host "OneDrive rules: $oneDriveRules"
Write-Host "Repo rules:     $repoRules"
Write-Host "Worker:         $workerPath"
Write-Host "Direction:      $Direction"
Write-Host ""

if ($Direction -eq "Pull") {
    Copy-RequiredRuleFile "Rules-Test1.txt" $oneDriveRules $repoRules

    if (Test-Path $oneDriveV1) {
        Copy-RequiredRuleFile "Rules-V1.txt" $oneDriveRules $repoRules
    }

    Copy-Item $oneDriveTest1 $workerPath -Force
    Write-Host "Synced Rules-Test1.txt -> cloudflare-worker.mjs"

    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "  Paste $oneDriveTest1 into Cloudflare to test in-game"
    Write-Host "  node lifepunch/website/deployments/scripts/build-current-rules-md.mjs"
}
elseif ($Direction -eq "Push") {
    if (-not (Test-Path $workerPath)) {
        throw "Repo worker not found: $workerPath"
    }

    Copy-Item $workerPath $oneDriveTest1 -Force
    Copy-Item $workerPath $repoTest1 -Force
    Write-Host "Synced cloudflare-worker.mjs -> Rules-Test1.txt (OneDrive + repo)"
    Write-Host "Rules-V1.txt was NOT changed."

    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "  Paste $oneDriveTest1 into Cloudflare to test in-game"
    Write-Host "  When ready for production, run: sync-rules-from-onedrive.ps1 -Direction Promote"
}
else {
    if (-not (Test-Path $oneDriveTest1)) {
        throw "Rules-Test1.txt not found on OneDrive: $oneDriveTest1"
    }

    Copy-Item $oneDriveTest1 $oneDriveV1 -Force
    Copy-Item $oneDriveTest1 $repoV1 -Force
    Copy-Item $oneDriveTest1 $workerPath -Force
    Write-Host "Promoted Rules-Test1.txt -> Rules-V1.txt (OneDrive + repo + worker)"

    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "  Paste $oneDriveV1 into Cloudflare for production deploy"
    Write-Host "  node lifepunch/website/deployments/scripts/build-current-rules-md.mjs"
}
