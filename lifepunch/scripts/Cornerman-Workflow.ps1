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
    $tmpEsc = ('C:\lifepunch\cornerman\.p-{0}.b64' -f [Guid]::NewGuid().ToString('n').Substring(0, 8))

    $init = @"
New-Item -ItemType Directory -Force -LiteralPath '$parent' | Out-Null
Set-Content -LiteralPath '$tmpEsc' -Value '' -NoNewline -Encoding ASCII
Write-Output 'chunk_init_ok'
"@
    $r = Invoke-CornermanEncoded -ScriptBlock $init -SshTarget $SshTarget
    if ($r.ExitCode -ne 0 -or ($r.Output -join "`n") -notmatch 'chunk_init_ok') {
        throw "SSH write init failed: $Path ($($r.Output -join '; '))"
    }

    $chunkSize = 2000
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

function Get-VengeanceSmbSecretsDir {
    foreach ($path in @(
            (Join-Path $env:USERPROFILE 'OneDrive\Lifepunch\Secrets')
            (Join-Path $env:USERPROFILE 'OneDrive\Documents\Lifepunch\Secrets')
        )) {
        if (Test-Path -LiteralPath $path) { return $path }
    }
    return (Join-Path $env:USERPROFILE 'OneDrive\Lifepunch\Secrets')
}

function Get-VengeanceSmbPasswordPath {
    Join-Path (Get-VengeanceSmbSecretsDir) 'vengeance-smb.password'
}

function Get-VengeanceSmbUserPath {
    Join-Path (Get-VengeanceSmbSecretsDir) 'vengeance-smb.user'
}

function Read-VengeanceSmbTextFile {
    param([Parameter(Mandatory)][string] $Path)
    if (-not (Test-Path -LiteralPath $Path)) { return $null }
    $bytes = [IO.File]::ReadAllBytes($Path)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $bytes = $bytes[3..($bytes.Length - 1)]
    }
    $utf8 = New-Object System.Text.UTF8Encoding $false
    $text = $utf8.GetString($bytes).Trim()
    if ($text) { return $text }
    return $null
}

function Write-VengeanceSmbTextFile {
    param(
        [Parameter(Mandatory)][string] $Path,
        [Parameter(Mandatory)][string] $Text
    )
    $parent = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [IO.File]::WriteAllText($Path, $Text.Trim(), $utf8)
}

function Read-VengeanceSmbPasswordFile {
    param([Parameter(Mandatory)][string] $Path)
    Read-VengeanceSmbTextFile -Path $Path
}

function Get-VengeanceSmbPassword {
    if ($env:LIFEPUNCH_VENGEANCE_SMB_PASSWORD) {
        return [string]$env:LIFEPUNCH_VENGEANCE_SMB_PASSWORD.Trim()
    }
    $text = Read-VengeanceSmbTextFile -Path (Get-VengeanceSmbPasswordPath)
    if ($text) { return $text }
    return $null
}

function Get-VengeanceSmbUser {
    if ($env:LIFEPUNCH_VENGEANCE_SMB_USER) {
        return [string]$env:LIFEPUNCH_VENGEANCE_SMB_USER.Trim()
    }
    $text = Read-VengeanceSmbTextFile -Path (Get-VengeanceSmbUserPath)
    if ($text) { return $text }
    $hostName = $env:COMPUTERNAME
    if (Get-LocalUser -Name 'lpbridge' -ErrorAction SilentlyContinue) {
        return "$hostName\lpbridge"
    }
    return "$hostName\jared"
}

function Set-VengeanceSmbCredential {
    param(
        [Parameter(Mandatory)][string] $User,
        [Parameter(Mandatory)][SecureString] $Password
    )
    Write-VengeanceSmbTextFile -Path (Get-VengeanceSmbUserPath) -Text $User
    Set-VengeanceSmbPassword -Password $Password | Out-Null
    return @{
        UserPath     = (Get-VengeanceSmbUserPath)
        PasswordPath = (Get-VengeanceSmbPasswordPath)
        User         = $User
    }
}

function Clear-VengeanceNetUse {
    param([string] $Unc)
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    net use $Unc /delete /y 2>$null | Out-Null
    $ErrorActionPreference = $prev
}

function Test-VengeanceSmbCredential {
    param(
        [string] $User = $(Get-VengeanceSmbUser),
        [string] $PlainPassword = $(Get-VengeanceSmbPassword),
        [string] $ShareUnc = "\\$($env:COMPUTERNAME)\SboxBridgeIpc",
        [string] $ShareUncIp = '\\192.168.1.236\SboxBridgeIpc'
    )
    if (-not $PlainPassword) { return @{ Ok = $false; Detail = 'no password on file' } }

    $targets = @($ShareUnc)
    if ($ShareUncIp -and $ShareUncIp -ne $ShareUnc) { $targets += $ShareUncIp }

    foreach ($unc in $targets) {
        Clear-VengeanceNetUse -Unc $unc
        $prev = $ErrorActionPreference
        $ErrorActionPreference = 'SilentlyContinue'
        net use $unc /user:$User $PlainPassword /persistent:no 2>$null | Out-Null
        $code = $LASTEXITCODE
        $ErrorActionPreference = $prev
        $statusOk = Test-Path -LiteralPath (Join-Path $unc 'status.json')
        Clear-VengeanceNetUse -Unc $unc
        if ($code -eq 0 -and $statusOk) {
            return @{
                Ok     = $true
                Detail = "net use exit=0 status.json=True user=$User unc=$unc"
            }
        }
    }

    return @{
        Ok     = $false
        Detail = "net use failed for user=$User (tried $($targets -join ', '))"
    }
}

function Set-VengeanceSmbPassword {
    param(
        [Parameter(Mandatory)]
        [SecureString] $Password
    )
    $path = Get-VengeanceSmbPasswordPath
    $parent = Split-Path -Parent $path
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
    try {
        $plain = [Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr).Trim()
    }
    finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    }
    if (-not $plain) { throw 'Empty SMB password refused.' }
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [IO.File]::WriteAllText($path, $plain, $utf8)
    return $path
}

function Repair-VengeanceSmbPasswordFile {
    $path = Get-VengeanceSmbPasswordPath
    if (-not (Test-Path -LiteralPath $path)) { return $false }
    $bytes = [IO.File]::ReadAllBytes($path)
    if ($bytes.Length -lt 3 -or $bytes[0] -ne 0xEF -or $bytes[1] -ne 0xBB -or $bytes[2] -ne 0xBF) {
        return $false
    }
    $plain = Read-VengeanceSmbPasswordFile -Path $path
    if (-not $plain) { return $false }
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [IO.File]::WriteAllText($path, $plain, $utf8)
    return $true
}

function Test-CornermanBridgeShareReachable {
    param([string] $SshTarget = $(Get-CornermanSshTarget))
    $vengeanceHost = $env:COMPUTERNAME
    $uncIpc = "\\$vengeanceHost\SboxBridgeIpc"
    $r = Invoke-CornermanSshExec -SshTarget $SshTarget -ScriptBlock @"
`$statusPath = Join-Path '$uncIpc' 'status.json'
`$shareOk = Test-Path -LiteralPath '$uncIpc'
`$statusOk = Test-Path -LiteralPath `$statusPath
Write-Output "share=`$shareOk status=`$statusOk"
"@ -ConnectTimeout 20
    $text = [string]$r.Output
    return ($r.ExitCode -eq 0 -and $text -match 'status=True')
}

function Sync-VengeanceSmbPasswordToCornerman {
    param([string] $SshTarget = $(Get-CornermanSshTarget))
    $plain = Get-VengeanceSmbPassword
    if (-not $plain) { return $false }
    $user = Get-VengeanceSmbUser
    Push-CornermanText -Path 'C:\lifepunch\cornerman\config\vengeance-smb.password' -Text $plain -SshTarget $SshTarget | Out-Null
    Push-CornermanText -Path 'C:\lifepunch\cornerman\config\vengeance-smb.user' -Text $user -SshTarget $SshTarget | Out-Null
    return $true
}

function Invoke-CornermanEnsureBridgeShare {
    param([string] $SshTarget = $(Get-CornermanSshTarget))
    $ensure = 'C:\lifepunch\cornerman\Ensure-CornermanBridgeShare.ps1'
    $r = Invoke-CornermanSshExec -SshTarget $SshTarget -ScriptBlock @"
if (-not (Test-Path -LiteralPath '$ensure')) { throw 'Missing $ensure' }
& '$ensure' *>&1 | ForEach-Object { Write-Output `$_ }
exit `$LASTEXITCODE
"@ -ConnectTimeout 45
    $ok = ($r.ExitCode -eq 0) -or (Test-CornermanBridgeShareReachable -SshTarget $SshTarget)
    return @{ Ok = $ok; Output = ($r.Output -join "`n") }
}

function Invoke-CornermanMapBridgeShare {
    param(
        [string] $SshTarget = $(Get-CornermanSshTarget),
        [SecureString] $PlainPassword
    )
    if (Test-CornermanBridgeShareReachable -SshTarget $SshTarget) {
        return @{ Ok = $true; Output = 'OK bridge share already mapped' }
    }
    if (-not $PlainPassword) {
        $plain = Get-VengeanceSmbPassword
        if (-not $plain) { return @{ Ok = $false; Output = 'no password — run Initialize-VengeanceSmbSecret.ps1 on VENGEANCE' } }
        if (-not (Sync-VengeanceSmbPasswordToCornerman -SshTarget $SshTarget)) {
            return @{ Ok = $false; Output = 'failed to sync password to Green' }
        }
    }
    $mapScript = 'C:\lifepunch\cornerman\Map-CornermanBridgeShare.ps1'
    $smbUser = (Get-VengeanceSmbUser) -replace "'", "''"
    $r = Invoke-CornermanSshExec -SshTarget $SshTarget -ScriptBlock @"
if (-not (Test-Path -LiteralPath '$mapScript')) { throw 'Missing $mapScript' }
`$passFile = 'C:\lifepunch\cornerman\config\vengeance-smb.password'
`$userFile = 'C:\lifepunch\cornerman\config\vengeance-smb.user'
if (-not (Test-Path -LiteralPath `$passFile)) { throw 'Missing password file on Green' }
`$plain = (Get-Content -LiteralPath `$passFile -Raw).Trim()
`$user = if (Test-Path -LiteralPath `$userFile) { (Get-Content -LiteralPath `$userFile -Raw).Trim() } else { '$smbUser' }
`$sec = ConvertTo-SecureString `$plain -AsPlainText -Force
& '$mapScript' -Password `$sec -User `$user *>&1 | ForEach-Object { Write-Output `$_ }
if (`$LASTEXITCODE -ne 0) { exit `$LASTEXITCODE }
"@ -ConnectTimeout 45
    $ok = (Test-CornermanBridgeShareReachable -SshTarget $SshTarget)
    if (-not $ok) { $ok = ($r.ExitCode -eq 0 -and [string]$r.Output -match 'OK - Cornerman can read bridge IPC') }
    return @{ Ok = $ok; Output = ($r.Output -join "`n") }
}
