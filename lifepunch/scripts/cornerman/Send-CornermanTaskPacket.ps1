# =====================================================================
# RISK: WRITES ONE FILE INTO THE CORNERMAN INBOX (local or via SSH)  |  Slice 3
# NODE: Red (VENGEANCE) -> Green (Cornerman) inbox
# WHAT: Operator helper. Transports ONE task-*.json packet into the
#       Cornerman drop-worker inbox. Local mode copies the file;
#       remote mode transfers it over ssh exec as base64 chunks
#       (Green's remote shell prints a banner on non-interactive
#       sessions, which corrupts scp/sftp -- chunked ssh exec is the
#       proven transport). The transfer is SHA256-verified.
# NOT:  Never runs the worker. Never touches any git clone. Never
#       deletes or rewrites existing inbox packets unless -Force.
# LAW:  lifepunch/docs/CORNERMAN_HEADLESS_DROP_WORKER.md (runbook)
# USAGE:
#   # to live Green inbox over ssh:
#   powershell -NoProfile -File Send-CornermanTaskPacket.ps1 -PacketFile C:\path\task-...json
#   # to a local inbox (scratch testing / already on Green):
#   powershell -NoProfile -File Send-CornermanTaskPacket.ps1 -PacketFile ... -LocalInboxPath C:\tmp\cdw\inbox
# =====================================================================

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string] $PacketFile,

    # SSH host alias for Green.
    [string] $GreenHost = 'cornerman',

    # Remote inbox path on Green.
    [string] $InboxPath = 'C:\lifepunch\cornerman\inbox',

    # Local mode: copy into this inbox directory instead of using SSH.
    [string] $LocalInboxPath = '',

    # Overwrite an existing packet with the same name in the inbox.
    [switch] $Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'CornermanDropWorker.Lib.ps1')

# ------------------------------------------------------------- guards
if (-not (Test-Path -LiteralPath $PacketFile -PathType Leaf)) {
    Write-Output "ERROR: packet file not found: $PacketFile"
    exit 1
}
$PacketFile = (Resolve-Path -LiteralPath $PacketFile).Path
$fileName = [IO.Path]::GetFileName($PacketFile)
$taskId = [IO.Path]::GetFileNameWithoutExtension($PacketFile)

if ($fileName -notmatch '^task-\d{8}-\d{6}-[a-z0-9][a-z0-9-]*\.json$') {
    Write-Output "ERROR: packet filename must be task-YYYYMMDD-HHmmss-<slug>.json (got '$fileName')."
    exit 1
}

# Parse + minimally validate before transporting anything.
try {
    $packet = Get-Content -LiteralPath $PacketFile -Raw | ConvertFrom-Json
}
catch {
    Write-Output "ERROR: packet is not valid JSON: $($_.Exception.Message)"
    exit 1
}
if ([string]$packet.id -ne $taskId) {
    Write-Output "ERROR: packet id '$($packet.id)' does not match filename '$taskId' -- the worker requires them to agree."
    exit 1
}
$schema = Test-CdwPacketSchema -Packet $packet
if (-not $schema.Ok) {
    Write-Output 'ERROR: packet fails worker schema validation -- refusing to send a packet that would fail closed:'
    foreach ($e in $schema.Errors) { Write-Output "  - $e" }
    exit 1
}

$localHash = (Get-FileHash -LiteralPath $PacketFile -Algorithm SHA256).Hash

# --------------------------------------------------------- local mode
if ($LocalInboxPath) {
    if (-not (Test-Path -LiteralPath $LocalInboxPath)) {
        New-Item -ItemType Directory -Force -Path $LocalInboxPath | Out-Null
    }
    $dest = Join-Path $LocalInboxPath $fileName
    if ((Test-Path -LiteralPath $dest) -and -not $Force) {
        Write-Output "ERROR: packet already in inbox (use -Force to overwrite): $dest"
        exit 1
    }
    Copy-Item -LiteralPath $PacketFile -Destination $dest -Force
    $destHash = (Get-FileHash -LiteralPath $dest -Algorithm SHA256).Hash
    if ($destHash -ne $localHash) {
        Write-Output 'ERROR: hash mismatch after local copy -- inbox copy removed.'
        Remove-Item -LiteralPath $dest -Force -ErrorAction SilentlyContinue
        exit 1
    }
    Write-Output "OK: packet dropped (local): $dest"
    Write-Output "    sha256=$localHash"
    Write-Output '    Next: run the worker once on that node (Invoke-CornermanWorkerOnce.ps1).'
    exit 0
}

# -------------------------------------------------------- remote mode
function Invoke-GreenPs {
    # Run a PowerShell script block text on Green via ssh exec.
    # -EncodedCommand sidesteps all quoting; output is filtered of the
    # banner/CLIXML noise the remote shell emits.
    param([Parameter(Mandatory)][string] $ScriptText)
    $enc = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($ScriptText))
    $raw = ssh $GreenHost "powershell -NoProfile -EncodedCommand $enc" 2>&1 | Out-String -Stream
    return @($raw | Where-Object {
        $_ -match '\S' -and
        $_ -notmatch '^#< CLIXML|^<Objs|Microsoft Windows \[Version|Microsoft Corporation'
    })
}

# Preflight: reachable + inbox exists + collision check.
$destPath = Join-Path $InboxPath $fileName
$preflight = Invoke-GreenPs @"
if (-not (Test-Path -LiteralPath '$InboxPath')) { Write-Output 'PRE:NO-INBOX' }
elseif (Test-Path -LiteralPath '$destPath') { Write-Output 'PRE:EXISTS' }
else { Write-Output 'PRE:CLEAR' }
"@
if ($preflight -notmatch 'PRE:') {
    Write-Output "ERROR: Green unreachable or no usable response over ssh ($GreenHost)."
    Write-Output ($preflight -join [Environment]::NewLine)
    exit 1
}
if ($preflight -match 'PRE:NO-INBOX') {
    Write-Output "ERROR: inbox path does not exist on Green: $InboxPath (run Test-CornermanWorkerConfig.ps1 there)."
    exit 1
}
if (($preflight -match 'PRE:EXISTS') -and -not $Force) {
    Write-Output "ERROR: packet already in Green inbox (use -Force to overwrite): $destPath"
    exit 1
}

# Transfer as base64 chunks; assemble to a temp name, verify, then rename.
$b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($PacketFile))
$chunkSize = 4000
$chunks = [math]::Ceiling($b64.Length / $chunkSize)
$tmpB64 = Join-Path $InboxPath ($taskId + '.b64.partial')

$null = Invoke-GreenPs "Remove-Item -LiteralPath '$tmpB64' -ErrorAction SilentlyContinue; Write-Output RESET-OK"
for ($i = 0; $i -lt $chunks; $i++) {
    $part = $b64.Substring($i * $chunkSize, [math]::Min($chunkSize, $b64.Length - $i * $chunkSize))
    $out = Invoke-GreenPs "Add-Content -LiteralPath '$tmpB64' -Value '$part' -Encoding ASCII; Write-Output CHUNK-$i-OK"
    if ($out -notmatch "CHUNK-$i-OK") {
        Write-Output "ERROR: chunk $($i + 1)/$chunks failed to transfer; partial file removed."
        $null = Invoke-GreenPs "Remove-Item -LiteralPath '$tmpB64' -ErrorAction SilentlyContinue; Write-Output CLEAN"
        exit 1
    }
}

$final = Invoke-GreenPs @"
`$t = (Get-Content -LiteralPath '$tmpB64' -Raw) -replace '\s', ''
`$bytes = [Convert]::FromBase64String(`$t)
[IO.File]::WriteAllBytes('$destPath', `$bytes)
Remove-Item -LiteralPath '$tmpB64' -Force
`$h = (Get-FileHash -LiteralPath '$destPath' -Algorithm SHA256).Hash
Write-Output ('REMOTE-SHA256=' + `$h)
"@
$remoteHash = ($final | Where-Object { $_ -match '^REMOTE-SHA256=' }) -replace '^REMOTE-SHA256=', ''
if (-not $remoteHash) {
    Write-Output 'ERROR: could not assemble/verify the packet on Green:'
    Write-Output ($final -join [Environment]::NewLine)
    exit 1
}
if ($remoteHash -ne $localHash) {
    Write-Output "ERROR: SHA256 mismatch (local $localHash vs green $remoteHash) -- removing bad inbox copy."
    $null = Invoke-GreenPs "Remove-Item -LiteralPath '$destPath' -Force -ErrorAction SilentlyContinue; Write-Output CLEAN"
    exit 1
}

Write-Output "OK: packet dropped in Green inbox: $destPath"
Write-Output "    sha256=$localHash (verified)"
Write-Output '    Next: run the worker once on Green (Invoke-CornermanWorkerOnce.ps1). This helper never runs it for you.'
exit 0
