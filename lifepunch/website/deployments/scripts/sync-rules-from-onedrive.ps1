# Sync LifePunch Cloudflare worker / rules between OneDrive and the repo.
# Canonical OneDrive folder: %USERPROFILE%\OneDrive\Lifepunch\Rules
#
# Workflow:
#   Push    — repo worker -> sandbox .txt only (default Rules-Test1.txt)
#   Pull    — sandbox .txt -> repo worker + repo mirror (after editing on OneDrive)
#   Promote — Rules-Test1.txt -> Rules-V1 (production paste) — unchanged by -SandboxFile
param(
    [ValidateSet("Pull", "Push", "Promote")]
    [string]$Direction = "Pull",
    [string]$SandboxFile = "Rules-Test1.txt"
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
$oneDriveSandbox = Join-Path $oneDriveRules $SandboxFile
$repoSandbox = Join-Path $repoRules $SandboxFile
$oneDriveTest1 = Join-Path $oneDriveRules "Rules-Test1.txt"
$oneDriveV1 = Join-Path $oneDriveRules "Rules-V1.txt"
$repoTest1 = Join-Path $repoRules "Rules-Test1.txt"
$repoV1 = Join-Path $repoRules "Rules-V1.txt"

Write-Host "OneDrive rules: $oneDriveRules"
Write-Host "Sandbox file:   $SandboxFile"
Write-Host "Repo rules:     $repoRules"
Write-Host "Worker:         $workerPath"
Write-Host "Direction:      $Direction"
Write-Host ""

if ($Direction -eq "Pull") {
    if (-not (Test-Path $oneDriveSandbox)) {
        throw "Sandbox file not found on OneDrive: $oneDriveSandbox"
    }

    Copy-Item $oneDriveSandbox $repoSandbox -Force
    Write-Host "Synced $SandboxFile (OneDrive -> repo mirror)"

    if (Test-Path $oneDriveV1) {
        Copy-RequiredRuleFile "Rules-V1.txt" $oneDriveRules $repoRules
    }

    Copy-Item $oneDriveSandbox $workerPath -Force
    Write-Host "Synced $SandboxFile -> cloudflare-worker.mjs"

    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "  Paste $oneDriveSandbox into Cloudflare to test in-game"
    Write-Host "  node lifepunch/website/deployments/scripts/build-current-rules-md.mjs"
}
elseif ($Direction -eq "Push") {
    if (-not (Test-Path $workerPath)) {
        throw "Repo worker not found: $workerPath"
    }

    Copy-Item $workerPath $oneDriveSandbox -Force
    Copy-Item $workerPath $repoSandbox -Force
    Write-Host "Synced cloudflare-worker.mjs -> $SandboxFile (OneDrive + repo)"
    if ($SandboxFile -ne "Rules-Test1.txt") {
        Write-Host "Rules-Test1.txt was NOT changed."
    }
    Write-Host "Rules-V1.txt was NOT changed."

    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "  Paste $oneDriveSandbox into Cloudflare to test in-game"
    if ($SandboxFile -ne "Rules-Test1.txt") {
        Write-Host "  Promote still uses Rules-Test1.txt -> Rules-V1.txt when you are ready for production"
    } else {
        Write-Host "  When ready for production, run: sync-rules-from-onedrive.ps1 -Direction Promote"
    }
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
