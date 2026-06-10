# Pull the latest Cornerman voice relay transcript onto VENGEANCE clipboard.
# Pair with watch-cornerman-voice.ps1 for hands-free new-utterance -> clipboard + toast.
# Cornerman: C:\Projects\cornerman-rag\outbox\to-vengeance.txt (relay.ps1)

param(
    [switch] $Notify,
    [switch] $Quiet
)

$ErrorActionPreference = 'Stop'

$RemotePath = 'C:\Projects\cornerman-rag\outbox\to-vengeance.txt'
$SshTarget  = if ($env:CORNERMAN_SSH) { $env:CORNERMAN_SSH } else { 'cornerman' }

function Write-Info([string]$m) {
    if (-not $Quiet) { Write-Host $m }
}

function Show-Toast([string]$Title, [string]$Message) {
    if (-not $Notify) { return }
    Write-Info "[$Title] $Message"
}

$text = & ssh -o BatchMode=yes -o ConnectTimeout=10 $SshTarget "type `"$RemotePath`"" 2>&1
if ($LASTEXITCODE -ne 0) {
    throw ('Could not read relay file on ' + $SshTarget + ' at ' + $RemotePath + '. Run relay.ps1 on Cornerman first.')
}
if ([string]::IsNullOrWhiteSpace($text)) {
    throw 'Relay file is empty. Run Relay to VENGEANCE on Cornerman and speak first.'
}

Set-Clipboard -Value $text.TrimEnd()
Write-Info 'Copied Cornerman transcript to clipboard.'
$trim = $text.Trim()
$previewLen = [Math]::Min(120, $trim.Length)
Write-Info ('Preview: ' + $trim.Substring(0, $previewLen) + $(if ($trim.Length -gt 120) { '...' } else { '' }))

if ($Notify) {
    Show-Toast 'Cornerman voice ready' 'Paste into Cursor (Ctrl+V)'
}
