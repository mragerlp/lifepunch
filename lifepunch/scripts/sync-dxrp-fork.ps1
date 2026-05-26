param(
    [string]$DxrpPath = (Join-Path $PSScriptRoot '..\..\..\dxrp-public'),
    [switch]$PushOrigin
)

$ErrorActionPreference = 'Stop'

$ResolvedDxrpPath = (Resolve-Path -LiteralPath $DxrpPath).Path

function Invoke-Git {
    param([string[]]$Arguments)

    & git -C $ResolvedDxrpPath @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Arguments -join ' ') failed with exit code $LASTEXITCODE"
    }
}

$Status = (& git -C $ResolvedDxrpPath status --porcelain)
if ($LASTEXITCODE -ne 0) {
    throw "Unable to read git status in $ResolvedDxrpPath"
}

if ($Status) {
    throw "DXRP fork checkout has uncommitted changes. Commit or stash them before syncing."
}

$Origin = (& git -C $ResolvedDxrpPath remote get-url origin).Trim()
$Upstream = (& git -C $ResolvedDxrpPath remote get-url upstream).Trim()

if ($Origin -ne 'https://github.com/mragerlp/dxrp-public.git') {
    throw "Unexpected origin remote: $Origin"
}

if ($Upstream -ne 'https://github.com/dxura/dxrp.git') {
    throw "Unexpected upstream remote: $Upstream"
}

Invoke-Git @('fetch', 'upstream')
Invoke-Git @('switch', 'develop')
Invoke-Git @('pull', '--ff-only', 'upstream', 'develop')

if ($PushOrigin) {
    Invoke-Git @('push', 'origin', 'develop')
}

Invoke-Git @('status', '--short', '--branch')
