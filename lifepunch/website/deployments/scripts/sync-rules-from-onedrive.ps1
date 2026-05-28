# Copy LifePunch rules from OneDrive (canonical edit location) into the repo.
$ErrorActionPreference = "Stop"

$oneDriveRules = Join-Path $env:USERPROFILE "OneDrive\Documents\Lifepunch\Rules"
$repoRules = Join-Path $PSScriptRoot "..\Rules" | Resolve-Path
$workerPath = Join-Path $PSScriptRoot "..\cloudflare-worker.mjs" | Resolve-Path

function Copy-RequiredRuleFile {
    param(
        [string]$Name
    )

    $source = Join-Path $oneDriveRules $Name
    $target = Join-Path $repoRules $Name

    if (-not (Test-Path $source)) {
        throw "OneDrive rules file not found: $source"
    }

    Copy-Item $source $target -Force
    Write-Host "Synced $Name -> $target"
}

Copy-RequiredRuleFile "Rules-V1.txt"
Copy-RequiredRuleFile "Rules-Test1.txt"

$v1Source = Join-Path $oneDriveRules "Rules-V1.txt"
Copy-Item $v1Source $workerPath -Force
Write-Host "Synced Rules-V1.txt -> $workerPath"

Write-Host ""
Write-Host "Next steps:"
Write-Host "  node lifepunch/website/deployments/scripts/build-current-rules-md.mjs"
Write-Host "  git diff lifepunch/website/deployments/Rules lifepunch/website/deployments/cloudflare-worker.mjs"
