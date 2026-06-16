# Red -> Green workflow transport (VENGEANCE). Dot-source from Send-CornermanWorkflow.ps1.
# Green has no Cursor — Red drops inbox records and runs whitelisted actions over SSH.

$script:CornermanInboxRoot = 'C:\lifepunch\cornerman\inbox'
$script:CornermanWorkflowAckLog = 'C:\lifepunch\cornerman\outbox\workflow-ack.ndjson'
$script:CornermanRagRoot = 'C:\Projects\cornerman-rag'
$script:CornermanMonorepoRoot = 'C:\Projects\lifepunch'

function Get-CornermanSshTarget {
    if ($env:CORNERMAN_SSH) { return $env:CORNERMAN_SSH.Trim() }
    return 'cornerman'
}

function Test-CornermanSshReady {
    param(
        [string] $SshTarget = $(Get-CornermanSshTarget),
        [int] $ConnectTimeout = 8
    )
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    & ssh -o BatchMode=yes -o ConnectTimeout=$ConnectTimeout $SshTarget 'echo ok' 2>$null | Out-Null
    $ok = ($LASTEXITCODE -eq 0)
    $ErrorActionPreference = $prev
    return $ok
}

function Invoke-CornermanEncoded {
    param(
        [string] $ScriptBlock,
        [string] $SshTarget = $(Get-CornermanSshTarget)
    )
    $enc = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($ScriptBlock))
    if ($enc.Length -gt 7800) {
        throw 'Cornerman SSH encoded command too long — use chunked file push.'
    }
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    $out = & ssh -o BatchMode=yes $SshTarget "powershell -NoProfile -NonInteractive -EncodedCommand $enc" 2>$null
    $code = $LASTEXITCODE
    $ErrorActionPreference = $prev
    return @{ ExitCode = $code; Output = $out }
}

function Push-CornermanFile {
    <#
    .SYNOPSIS
      Write a file on Cornerman via chunked base64 (scp often fails; single-shot SSH hits cmdline limit).
    #>
    param(
        [Parameter(Mandatory, Position = 0)]
        [string] $Path,
        [Parameter(Mandatory, Position = 1)]
        [byte[]] $FileBytes,
        [string] $SshTarget = $(Get-CornermanSshTarget)
    )
    $b64 = [Convert]::ToBase64String($FileBytes)
    $parent = (Split-Path -Path $Path -Parent) -replace "'", "''"
    $pathEsc = $Path -replace "'", "''"
    $tmpEsc = 'C:\lifepunch\cornerman\.push-tmp.b64'

    $init = @"
New-Item -ItemType Directory -Force -LiteralPath '$parent' | Out-Null
Set-Content -LiteralPath '$tmpEsc' -Value '' -NoNewline -Encoding ASCII
Write-Output 'chunk_init_ok'
"@
    $r = Invoke-CornermanEncoded -ScriptBlock $init -SshTarget $SshTarget
    if ($r.ExitCode -ne 0 -or ($r.Output -join "`n") -notmatch 'chunk_init_ok') {
        throw "SSH write init failed: $Path ($($r.Output -join '; '))"
    }

    $chunkSize = 2800
    for ($i = 0; $i -lt $b64.Length; $i += $chunkSize) {
        $len = [Math]::Min($chunkSize, $b64.Length - $i)
        $part = $b64.Substring($i, $len) -replace "'", "''"
        $append = @"
Add-Content -LiteralPath '$tmpEsc' -Value '$part' -NoNewline -Encoding ASCII
Write-Output 'chunk_ok'
"@
        $r = Invoke-CornermanEncoded -ScriptBlock $append -SshTarget $SshTarget
        if ($r.ExitCode -ne 0 -or ($r.Output -join "`n") -notmatch 'chunk_ok') {
            throw "SSH write chunk failed: $Path at $i ($($r.Output -join '; '))"
        }
    }

    $finalize = @"
`$raw = Get-Content -LiteralPath '$tmpEsc' -Raw -Encoding ASCII
[IO.File]::WriteAllBytes('$pathEsc', [Convert]::FromBase64String(`$raw))
Remove-Item -LiteralPath '$tmpEsc' -Force -ErrorAction SilentlyContinue
if (-not (Test-Path -LiteralPath '$pathEsc')) { throw 'write verify failed' }
Write-Output 'write_ok'
"@
    $r = Invoke-CornermanEncoded -ScriptBlock $finalize -SshTarget $SshTarget
    if ($r.ExitCode -ne 0 -or ($r.Output -join "`n") -notmatch 'write_ok') {
        throw "SSH write finalize failed: $Path ($($r.Output -join '; '))"
    }
    return $r.Output
}

function Push-CornermanText {
    param(
        [Parameter(Mandatory)]
        [string] $Path,
        [Parameter(Mandatory)]
        [string] $Text,
        [string] $SshTarget = $(Get-CornermanSshTarget)
    )
    $utf8 = New-Object System.Text.UTF8Encoding $false
    Push-CornermanFile -Path $Path -FileBytes ($utf8.GetBytes($Text)) -SshTarget $SshTarget | Out-Null
}

function Invoke-CornermanSshExec {
    param(
        [Parameter(Mandatory)]
        [string] $ScriptBlock,
        [string] $SshTarget = $(Get-CornermanSshTarget),
        [int] $ConnectTimeout = 20
    )
    $enc = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($ScriptBlock))
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    $raw = & ssh -o BatchMode=yes -o ConnectTimeout=$ConnectTimeout $SshTarget `
        "powershell -NoProfile -NonInteractive -EncodedCommand $enc" 2>&1
    $code = $LASTEXITCODE
    $ErrorActionPreference = $prev
    $lines = @($raw | Where-Object {
            $_ -notmatch 'Microsoft\.PowerShell_profile|Execution_Policies|UnauthorizedAccess|#< CLIXML' -and
            $_ -notmatch '^Microsoft Windows \[Version' -and
            $_ -notmatch '^\(c\) Microsoft Corporation' -and
            $_ -notmatch '^All rights reserved\.$'
        })
    return [pscustomobject]@{
        ExitCode = $code
        Output   = ($lines -join "`n").Trim()
    }
}

function New-CornermanWorkflowId {
    'wf-' + (Get-Date).ToUniversalTime().ToString('yyyyMMdd-HHmmss')
}

function Write-CornermanWorkflowInbox {
    param(
        [Parameter(Mandatory)]
        [hashtable] $Record,
        [string] $SshTarget = $(Get-CornermanSshTarget)
    )
    if (-not $Record.id) { $Record.id = New-CornermanWorkflowId }
    if (-not $Record.ts) { $Record.ts = (Get-Date).ToUniversalTime().ToString('o') }
    if (-not $Record.from) { $Record.from = 'vengeance' }
    $json = ($Record | ConvertTo-Json -Compress -Depth 8)
    $path = Join-Path $script:CornermanInboxRoot ($Record.id + '.json')
    Push-CornermanText -Path $path -Text $json -SshTarget $SshTarget
    return [pscustomobject]$Record
}

function Add-CornermanWorkflowAck {
    param(
        [Parameter(Mandatory)]
        [string] $WorkflowId,
        [Parameter(Mandatory)]
        [string] $Action,
        [bool] $Ok,
        [string] $Detail = '',
        [string] $SshTarget = $(Get-CornermanSshTarget)
    )
    $ack = @{
        ts     = (Get-Date).ToUniversalTime().ToString('o')
        id     = $WorkflowId
        action = $Action
        ok     = $Ok
        detail = $Detail
    } | ConvertTo-Json -Compress
    $ackPath = Join-Path $script:CornermanInboxRoot ("ack-$WorkflowId.json")
    Push-CornermanText -Path $ackPath -Text $ack -SshTarget $SshTarget
}

function Get-VengeanceSmbPassword {
    if ($env:LIFEPUNCH_VENGEANCE_SMB_PASSWORD) {
        return [string]$env:LIFEPUNCH_VENGEANCE_SMB_PASSWORD.Trim()
    }
    foreach ($path in @(
            (Join-Path $env:USERPROFILE 'OneDrive\Lifepunch\Secrets\vengeance-smb.password')
            (Join-Path $env:USERPROFILE 'OneDrive\Documents\Lifepunch\Secrets\vengeance-smb.password')
        )) {
        if (-not (Test-Path -LiteralPath $path)) { continue }
        $text = (Get-Content -LiteralPath $path -Raw).Trim()
        if ($text) { return $text }
    }
    return $null
}
