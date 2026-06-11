# Pull only Green's latest commit (HEAD) as a single patch and git am on VENGEANCE.
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
. (Join-Path $Here 'Cornerman-Workflow.ps1')

$PatchDir = Join-Path $RepoRoot '.cornerman-patches'
$remotePatchDir = 'C:\lifepunch\cornerman\outbox\patches-latest'
$SshTarget = Get-CornermanSshTarget

if (-not (Test-CornermanSshReady -SshTarget $SshTarget)) {
    throw "Cornerman SSH not ready ($SshTarget)"
}

$dirty = git -C $RepoRoot status --porcelain | Where-Object { $_ -notmatch '^\?\?' }
if ($dirty) {
    throw "VENGEANCE has tracked changes - stash first. Dirty:`n$($dirty -join "`n")"
}

$gen = Invoke-CornermanSshExec -SshTarget $SshTarget -ConnectTimeout 60 -ScriptBlock @"
New-Item -ItemType Directory -Force -Path '$remotePatchDir' | Out-Null
Get-ChildItem -LiteralPath '$remotePatchDir' -Filter '*.patch' -ErrorAction SilentlyContinue | Remove-Item -Force
Push-Location C:\Projects\lifepunch
git format-patch -1 HEAD -o '$remotePatchDir' 2>&1
Get-ChildItem -LiteralPath '$remotePatchDir' -Filter '*.patch' | ForEach-Object { Write-Output `$_.Name }
Pop-Location
"@

Write-Host $gen.Output
if ($gen.ExitCode -ne 0) { throw "format-patch failed (exit $($gen.ExitCode))" }

$name = @($gen.Output -split "`n" | Where-Object { $_ -match '\.patch$' } | Select-Object -Last 1).Trim()
if (-not $name) { throw 'No patch name from Green' }

New-Item -ItemType Directory -Force -Path $PatchDir | Out-Null
$remotePath = "$remotePatchDir\$name"
$localPath = Join-Path $PatchDir $name

$pathEsc = $remotePath -replace "'", "''"
$remote = "[Convert]::ToBase64String([IO.File]::ReadAllBytes('$pathEsc'))"
$enc = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($remote))
$prev = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'
$b64 = & ssh -o BatchMode=yes -o ConnectTimeout=30 $SshTarget "powershell -NoProfile -NonInteractive -EncodedCommand $enc" 2>$null
$ErrorActionPreference = $prev
$line = ($b64 | Where-Object { $_ -and $_ -notmatch 'Microsoft\.Windows|PowerShell_profile|CLIXML|Objs Version' } | Select-Object -Last 1)
if (-not $line) { throw 'empty base64 payload' }
[IO.File]::WriteAllBytes($localPath, [Convert]::FromBase64String($line.Trim()))
Write-Host "Pulled $name" -ForegroundColor Green

Push-Location $RepoRoot
try {
    git am $localPath 2>&1 | Write-Host
    if ($LASTEXITCODE -ne 0) { throw 'git am failed' }
    Write-Host 'Applied:' -ForegroundColor Green
    git log -1 --oneline
}
finally { Pop-Location }
