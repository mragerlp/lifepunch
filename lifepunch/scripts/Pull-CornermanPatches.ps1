# VENGEANCE (Red): pull Cornerman local commits via SSH format-patch + scp, git am, optional push.
[CmdletBinding()]
param(
    [switch] $Push,
    [string] $PatchDir = '',
    [string] $SshTarget = ''
)

$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
. (Join-Path $Here 'Cornerman-Workflow.ps1')

if (-not $PatchDir) {
    $PatchDir = Join-Path $RepoRoot '.cornerman-patches'
}
if (-not $SshTarget) { $SshTarget = Get-CornermanSshTarget }

if (-not (Test-CornermanSshReady -SshTarget $SshTarget)) {
    throw "Cornerman SSH not ready ($SshTarget). Use SMB/USB copy of patches or run Fix-CornermanRemoteNow.ps1 on Green."
}

Write-Host 'Cornerman patch handoff (VENGEANCE block)' -ForegroundColor Cyan
Write-Host "  SSH: $SshTarget"
Write-Host "  Repo: $RepoRoot"
Write-Host "  Patches: $PatchDir"

$status = Invoke-CornermanSshExec -SshTarget $SshTarget -ConnectTimeout 30 -ScriptBlock @'
Push-Location C:\Projects\lifepunch
git fetch origin 2>&1
$ahead = git rev-list --count origin/main..HEAD 2>&1
$subjects = git log origin/main..HEAD --format=%s 2>&1
Write-Output "AHEAD=$ahead"
Write-Output "SUBJECTS_BEGIN"
Write-Output $subjects
Write-Output "SUBJECTS_END"
git status -sb
Pop-Location
'@

Write-Host $status.Output
if ($status.ExitCode -ne 0) { throw "Cornerman status failed (exit $($status.ExitCode))" }

if ($status.Output -notmatch 'AHEAD=(\d+)') { throw 'Could not parse AHEAD count from Cornerman' }
$aheadCount = [int]$Matches[1]
if ($aheadCount -eq 0) {
    Write-Host 'No commits on Green ahead of origin/main - nothing to pull.' -ForegroundColor Yellow
    exit 0
}

Write-Host "Green has $aheadCount commit(s) to publish." -ForegroundColor Green

New-Item -ItemType Directory -Force -Path $PatchDir | Out-Null
Get-ChildItem -LiteralPath $PatchDir -Filter '*.patch' -ErrorAction SilentlyContinue | Remove-Item -Force

$remotePatchDir = 'C:\lifepunch\cornerman\outbox\patches'
$gen = Invoke-CornermanSshExec -SshTarget $SshTarget -ConnectTimeout 60 -ScriptBlock @"
New-Item -ItemType Directory -Force -Path '$remotePatchDir' | Out-Null
Get-ChildItem -LiteralPath '$remotePatchDir' -Filter '*.patch' -ErrorAction SilentlyContinue | Remove-Item -Force
Push-Location C:\Projects\lifepunch
git format-patch -o '$remotePatchDir' origin/main..HEAD 2>&1
Get-ChildItem -LiteralPath '$remotePatchDir' -Filter '*.patch' | ForEach-Object { Write-Output \$_.Name }
Pop-Location
"@

Write-Host $gen.Output
if ($gen.ExitCode -ne 0) { throw "format-patch on Green failed (exit $($gen.ExitCode))" }

function Pull-CornermanPatchFile {
    param(
        [string] $RemotePath,
        [string] $LocalPath,
        [string] $Target
    )
    $pathEsc = $RemotePath -replace "'", "''"
    $remote = "[Convert]::ToBase64String([IO.File]::ReadAllBytes('$pathEsc'))"
    $enc = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($remote))
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    $b64 = & ssh -o BatchMode=yes -o ConnectTimeout=30 $Target `
        "powershell -NoProfile -NonInteractive -EncodedCommand $enc" 2>$null
    $code = $LASTEXITCODE
    $ErrorActionPreference = $prev
    if ($code -ne 0 -or -not $b64) {
        throw "base64 pull failed for $RemotePath (exit $code)"
    }
    $line = ($b64 | Where-Object { $_ -and $_ -notmatch 'Microsoft\.Windows|PowerShell_profile|CLIXML' } | Select-Object -Last 1)
    if (-not $line) { throw "empty base64 payload for $RemotePath" }
    $bytes = [Convert]::FromBase64String($line.Trim())
    $parent = Split-Path -Parent $LocalPath
    if ($parent) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
    [IO.File]::WriteAllBytes($LocalPath, $bytes)
}

$remoteNames = @($gen.Output -split "`n" | Where-Object { $_ -match '\.patch$' } | ForEach-Object { Split-Path $_ -Leaf })
if (-not $remoteNames) {
    throw "No .patch names parsed from Green format-patch output"
}

foreach ($name in $remoteNames) {
    $remotePath = Join-Path $remotePatchDir $name
    $localPath = Join-Path $PatchDir $name
    Write-Host "Pulling $name (base64)..." -ForegroundColor DarkGray
    Pull-CornermanPatchFile -RemotePath $remotePath -LocalPath $localPath -Target $SshTarget
}

$patchFiles = Get-ChildItem -LiteralPath $PatchDir -Filter '*.patch' | Sort-Object Name
if (-not $patchFiles) { throw "No patch files landed in $PatchDir" }
Write-Host "Pulled $($patchFiles.Count) patch file(s)." -ForegroundColor Green

Push-Location $RepoRoot
try {
    git fetch origin 2>&1 | Write-Host
    $dirty = git status --porcelain | Where-Object { $_ -notmatch '^\?\?' }
    if ($dirty) {
        throw "VENGEANCE has staged/unstaged tracked changes - commit or stash before git am. Dirty:`n$($dirty -join "`n")"
    }

    foreach ($p in $patchFiles) {
        Write-Host "Applying $($p.Name)..." -ForegroundColor DarkGray
        git am $p.FullName 2>&1 | Write-Host
        if ($LASTEXITCODE -ne 0) { throw "git am failed on $($p.Name)" }
    }

    Write-Host 'git am OK' -ForegroundColor Green
    git log -$aheadCount --oneline

    if ($Push) {
        git push origin main 2>&1 | Write-Host
        if ($LASTEXITCODE -ne 0) { throw 'git push failed' }
        Write-Host 'Pushed to origin/main.' -ForegroundColor Green
    }
    else {
        Write-Host 'Skipped push (pass -Push to publish).' -ForegroundColor Yellow
    }
}
finally {
    Pop-Location
}

Write-Host ''
Write-Host 'Green reconcile (owner on Cornerman or via Invoke-CornermanMonorepoSync.ps1):' -ForegroundColor Cyan
Write-Host '  git fetch && git pull --rebase'
