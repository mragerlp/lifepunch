<#
.SYNOPSIS
  Stage LifePunch-owned GPU Farm source for the in-house BitcoinMiningAddon on Cornerman + repo mirror.

.PARAMETER SourceRoot
  Desktop export folder (GPU_Farm root with OBJ/FBX/textures).

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File Deploy-CornermanBitcoinMiningIntake.ps1
#>
[CmdletBinding()]
param(
    [string] $SourceRoot = 'C:\Users\jared\Downloads\bitcoinmining\GPU_Farm',
    [string] $SshTarget = '',
    [switch] $RepoOnly,
    [switch] $GreenOnly
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
$AddonsRoot = Join-Path $RepoRoot 'lifepunchaddons'
$ReorganizeScript = Join-Path $AddonsRoot 'scripts\Reorganize-BitcoinMinerGpuRack.ps1'
$ArchiveRoot = 'C:\lifepunch\reference-intake\bitcoinmining\gpu-rack-export'
$GreenIntake = 'C:\lifepunch\reference-intake\bitcoinmining\gpu-rack-export'

if (-not (Test-Path -LiteralPath $SourceRoot)) {
    throw "Source not found: $SourceRoot"
}

. (Join-Path $Here 'Cornerman-Workflow.ps1')
if (-not $SshTarget) { $SshTarget = Get-CornermanSshTarget }

function Copy-Tree([string]$From, [string]$To) {
    New-Item -ItemType Directory -Force -Path $To | Out-Null
    & robocopy $From $To /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "robocopy failed ($LASTEXITCODE): $From -> $To" }
}

Write-Host 'Bitcoin miner GPU Farm intake' -ForegroundColor Cyan
Write-Host "  Source: $SourceRoot"

if (-not $GreenOnly) {
    Write-Host '  Repo publish: gpu-rack/ + entities/bitcoin-miner/' -ForegroundColor DarkGray
    & $ReorganizeScript -SourceRoot $SourceRoot -ArchiveRoot $ArchiveRoot
    Write-Host 'Repo publish tree OK' -ForegroundColor Green
}

function Push-CornermanFileChunked {
    param(
        [Parameter(Mandatory)][string] $Path,
        [Parameter(Mandatory)][byte[]] $FileBytes,
        [string] $SshTarget,
        [int] $ChunkSize = 1536
    )
    $pathEsc = $Path -replace "'", "''"
    $parent = (Split-Path -Path $Path -Parent) -replace "'", "''"
    $total = $FileBytes.Length
    $offset = 0
    $first = $true
    $chunkNum = 0
    $chunkTotal = [int][Math]::Ceiling($total / [double]$ChunkSize)
    while ($offset -lt $total) {
        $chunkNum++
        $len = [Math]::Min($ChunkSize, $total - $offset)
        $slice = New-Object byte[] $len
        [Array]::Copy($FileBytes, $offset, $slice, 0, $len)
        $b64 = [Convert]::ToBase64String($slice)
        if ($first) {
            $remote = @"
New-Item -ItemType Directory -Force -LiteralPath '$parent' | Out-Null
[IO.File]::WriteAllBytes('$pathEsc', [Convert]::FromBase64String('$b64'))
Write-Output 'chunk_ok'
"@
            $first = $false
        }
        else {
            $remote = @"
`$s = [IO.File]::Open('$pathEsc', [IO.FileMode]::Open, [IO.FileAccess]::Write)
`$s.Seek(0, [IO.SeekOrigin]::End) | Out-Null
`$b = [Convert]::FromBase64String('$b64')
`$s.Write(`$b, 0, `$b.Length)
`$s.Close()
Write-Output 'chunk_ok'
"@
        }
        $enc = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($remote))
        $prev = $ErrorActionPreference
        $ErrorActionPreference = 'SilentlyContinue'
        $out = & ssh -o BatchMode=yes $SshTarget "powershell -NoProfile -NonInteractive -EncodedCommand $enc" 2>$null
        $code = $LASTEXITCODE
        $ErrorActionPreference = $prev
        $tail = ($out -split "`r?`n" | Where-Object { $_.Trim() } | Select-Object -Last 1)
        if ($code -ne 0 -or $tail -ne 'chunk_ok') {
            throw "Chunk upload failed at offset $offset for $Path (exit=$code tail=$tail)"
        }
        $offset += $len
        if ($chunkNum % 200 -eq 0) {
            Write-Host "    chunk $chunkNum / $chunkTotal" -ForegroundColor DarkGray
        }
    }
}

if (-not $RepoOnly) {
    if (-not (Test-CornermanSshReady -SshTarget $SshTarget)) {
        throw "Cornerman SSH not ready ($SshTarget)"
    }
    $stageZip = Join-Path $env:TEMP ('lp-gpu-farm-stage-' + [guid]::NewGuid().ToString('n'))
    Copy-Tree -From $SourceRoot -To $stageZip
    $readme = @"
LifePunch BitcoinMiningAddon - GPU Farm source (owner-authored, shippable).
Staged from VENGEANCE.

Meshes:
  gpu-rack-static.obj     - static world prop (primary for gpu-rack.vmdl)
  GPU_Farm_Anim.fbx       - animated variant
  GPU_Farm_Stacked_Anim.fbx

Textures: GPU_GraphicsCard, GPU_Rack, Motherboard, Power_Supply, Wires

Tier-3 prep (Green):
  - Compare layout vs BITCOINMINING_UX_SPEC.md (LifePunch-owned meshes only)
  - Blender: verify scale, apply transforms; ship via Reorganize-BitcoinMinerGpuRack.ps1
  - Note: OBJ references GPU_Farm_Static.mtl (not in export); use texture folders

Publish tree (git):
  models/.../gpu-rack/  +  entities/bitcoin-miner/

Archive (reference-intake):
  C:/lifepunch/reference-intake/bitcoinmining/gpu-rack-export/
"@
    Set-Content -LiteralPath (Join-Path $stageZip 'README.txt') -Value $readme -Encoding UTF8
    $zipLocal = Join-Path $env:TEMP 'lp-gpu-farm-intake.zip'
    if (Test-Path -LiteralPath $zipLocal) { Remove-Item -LiteralPath $zipLocal -Force }
    Compress-Archive -Path (Join-Path $stageZip '*') -DestinationPath $zipLocal -Force
    Remove-Item -LiteralPath $stageZip -Recurse -Force

    $zipBytes = [IO.File]::ReadAllBytes($zipLocal)
    $zipRemote = Join-Path $GreenIntake 'gpu-farm-intake.zip'
    Write-Host "  Green intake: $zipRemote ($([Math]::Round($zipBytes.Length / 1MB, 2)) MB zip, chunked)" -ForegroundColor DarkGray
    Push-CornermanFileChunked -Path $zipRemote -FileBytes $zipBytes -SshTarget $SshTarget

    $extract = @"
`$dest = '$($GreenIntake -replace "'", "''")'
`$zip = Join-Path `$dest 'gpu-farm-intake.zip'
if (-not (Test-Path -LiteralPath `$zip)) { throw 'missing zip' }
Expand-Archive -LiteralPath `$zip -DestinationPath `$dest -Force
Write-Output 'extract_ok'
"@
    $r = Invoke-CornermanSshExec -SshTarget $SshTarget -ScriptBlock $extract -ConnectTimeout 120
    $extractTail = ($r.Output -split "`r?`n" | Where-Object { $_.Trim() } | Select-Object -Last 1)
    if ($r.ExitCode -ne 0 -or $extractTail -ne 'extract_ok') {
        throw "Green extract failed: $($r.Output)"
    }
    Write-Host 'Green intake OK (zip extracted)' -ForegroundColor Green
}

Write-Host ''
Write-Host 'Done. Cornerman: C:\lifepunch\reference-intake\bitcoinmining\gpu-farm' -ForegroundColor Cyan
