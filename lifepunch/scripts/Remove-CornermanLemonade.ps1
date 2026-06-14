<#
.SYNOPSIS
  Remove AMD Lemonade from Cornerman — we use LM Studio :1234 + lifepunchnet Whisper only.

.DESCRIPTION
  Run from VENGEANCE (SSH to Green) or on Cornerman directly.
  - Stops Lemonade processes
  - Removes Startup shortcut
  - Clears CORNERMAN_LEMONADE_* env vars
  - Strips --lemonade from cornerman-rag relay.ps1 if present

.EXAMPLE
  powershell -File lifepunch\scripts\Remove-CornermanLemonade.ps1
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string] $SshTarget = '',
    [switch] $LocalOnly
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }

$removeScript = @'
$ErrorActionPreference = 'Continue'
$removed = [System.Collections.Generic.List[string]]::new()

$procMatch = '(?i)^(Lemonade|LemonadeServer|lemonade|RyzenAI|ryzen-ai)$'
Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -match $procMatch } | ForEach-Object {
    try {
        Stop-Process -Id $_.Id -Force -ErrorAction Stop
        $removed.Add("stopped $($_.ProcessName) pid $($_.Id)")
    }
    catch {
        $removed.Add("skip stop $($_.ProcessName): $($_.Exception.Message)")
    }
}

$startup = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Startup'
$lnk = Join-Path $startup 'Lemonade Server.lnk'
if (Test-Path -LiteralPath $lnk) {
    Remove-Item -LiteralPath $lnk -Force
    $removed.Add('removed Startup\Lemonade Server.lnk')
}

Get-ScheduledTask -ErrorAction SilentlyContinue |
    Where-Object { $_.TaskName -match '(?i)lemonade' } |
    ForEach-Object {
        try {
            Unregister-ScheduledTask -TaskName $_.TaskName -Confirm:$false -ErrorAction Stop
            $removed.Add("unregistered task $($_.TaskName)")
        }
        catch {
            $removed.Add("skip task $($_.TaskName): $($_.Exception.Message)")
        }
    }

foreach ($name in @('CORNERMAN_LEMONADE_MODEL', 'CORNERMAN_LEMONADE_URL')) {
    if ([Environment]::GetEnvironmentVariable($name, 'User')) {
        [Environment]::SetEnvironmentVariable($name, $null, 'User')
        $removed.Add("cleared env $name")
    }
}

$relayPs1 = 'C:\Projects\cornerman-rag\relay.ps1'
if (Test-Path -LiteralPath $relayPs1) {
    $ps1 = Get-Content -LiteralPath $relayPs1 -Raw -Encoding UTF8
    $changed = $false
    if ($ps1 -match '\[switch\]\s*\$Lemonade') {
        $ps1 = $ps1 -replace '\s*\[switch\]\s*\$Lemonade,?\r?\n', "`r`n"
        $changed = $true
    }
    if ($ps1 -match 'if \(\$Lemonade\)') {
        $ps1 = $ps1 -replace '\s*if \(\$Lemonade\)\s*\{\s*\$pyArgs \+= ''--lemonade''\s*\}\r?\n', "`r`n"
        $changed = $true
    }
    if ($changed) {
        Set-Content -LiteralPath $relayPs1 -Value $ps1 -Encoding UTF8 -NoNewline
        $removed.Add('patched cornerman-rag\relay.ps1 (removed -Lemonade)')
    }
}

$markerDir = 'C:\lifepunch\cornerman'
New-Item -ItemType Directory -Force -Path $markerDir | Out-Null
@(
    "lemonade-removed $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
    'STT: lifepunchnet :9000 only',
    'LLM: LM Studio headless :1234 only'
) | Set-Content -LiteralPath (Join-Path $markerDir 'LEMONADE_REMOVED.txt') -Encoding UTF8

if ($removed.Count -eq 0) { Write-Output 'OK nothing to remove (already clean)' }
else { $removed | ForEach-Object { Write-Output "OK $_" } }

$relayPy = 'C:\Projects\cornerman-rag\relay.py'
$patchPy = 'C:\Projects\cornerman-rag\remove_lemonade_from_relay.py'
if ((Test-Path -LiteralPath $relayPy) -and (Test-Path -LiteralPath $patchPy)) {
    Push-Location -LiteralPath (Split-Path -Parent $relayPy)
    try {
        & .\.venv\Scripts\python.exe .\remove_lemonade_from_relay.py
        if ($LASTEXITCODE -eq 0) { Write-Output 'OK relay.py lemonade code stripped' }
    }
    finally { Pop-Location }
}
'@

if ($LocalOnly -or $env:COMPUTERNAME -match '(?i)CORNERMAN') {
    Invoke-Expression $removeScript
    exit 0
}

. (Join-Path $Here 'Cornerman-Workflow.ps1')
if (-not $SshTarget) { $SshTarget = Get-CornermanSshTarget }
if (-not (Test-CornermanSshReady -SshTarget $SshTarget)) {
    throw "Cornerman SSH not ready ($SshTarget)"
}

$patchLocal = Join-Path $Here 'cornerman-relay\remove_lemonade_from_relay.py'
if (Test-Path -LiteralPath $patchLocal) {
    Push-CornermanText -Path 'C:\Projects\cornerman-rag\remove_lemonade_from_relay.py' `
        -Text (Get-Content -LiteralPath $patchLocal -Raw) -SshTarget $SshTarget | Out-Null
}

$r = Invoke-CornermanSshExec -ScriptBlock $removeScript -SshTarget $SshTarget
Write-Host $r.Output
if ($r.ExitCode -ne 0) { exit $r.ExitCode }
