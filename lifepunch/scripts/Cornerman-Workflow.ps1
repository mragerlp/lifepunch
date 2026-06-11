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

function Push-CornermanFile {
    <#
    .SYNOPSIS
      Write a file on Cornerman via base64 (scp often fails over Cornerman SSH profile).
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
    $remote = @"
New-Item -ItemType Directory -Force -LiteralPath '$parent' | Out-Null
[IO.File]::WriteAllBytes('$pathEsc', [Convert]::FromBase64String('$b64'))
if (-not (Test-Path -LiteralPath '$pathEsc')) { throw 'write verify failed' }
Write-Output 'write_ok'
"@
    $enc = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($remote))
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    $out = & ssh -o BatchMode=yes $SshTarget "powershell -NoProfile -NonInteractive -EncodedCommand $enc" 2>$null
    $code = $LASTEXITCODE
    $ErrorActionPreference = $prev
    if ($code -ne 0 -or ($out -join "`n") -notmatch 'write_ok') {
        throw "SSH write failed: $Path ($($out -join '; '))"
    }
    return $out
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
            $_ -notmatch 'Microsoft\.PowerShell_profile|Execution_Policies|UnauthorizedAccess|#< CLIXML'
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
