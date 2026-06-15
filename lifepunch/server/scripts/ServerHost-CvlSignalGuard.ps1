# Shared CVL signal guards for lifepunchnet HTTP listeners (anti-tumble + no secrets in hub).

$script:CvlValidTiers = @('universal', 'vengeance', 'cornerman', 'lifepunchnet')
$script:CvlForbiddenKeys = @('token', 'password', 'secret', 'apikey', 'api_key', 'bearer', 'authorization', 'private_key', 'ssh_key')

function Get-CvlAllowlistIps {
    param([string]$StatusDir = 'C:\lifepunch\status')
    $file = Join-Path $StatusDir 'hub-ingest-allowlist.txt'
    if (-not (Test-Path -LiteralPath $file)) { return $null }
    $ips = @(Get-Content -LiteralPath $file -ErrorAction SilentlyContinue | ForEach-Object { $_.Trim() } | Where-Object { $_ -and $_ -notmatch '^#' })
    if ($ips.Count -eq 0) { return $null }
    return $ips
}

function Test-CvlClientIp {
    param($Request, [string[]]$Allowlist)
    if (-not $Allowlist -or $Allowlist.Count -eq 0) { return $true }
    if (-not $Request.RemoteEndPoint) { return $false }
    $ip = $Request.RemoteEndPoint.Address.ToString()
    return ($Allowlist -contains $ip)
}

function Test-CvlBenignClientAbort {
    param($ErrorRecord)
    $ex = if ($ErrorRecord.Exception) { $ErrorRecord.Exception } else { $ErrorRecord }
    $msg = [string]$ex.Message
    if ($ex.InnerException) { $msg += ' ' + [string]$ex.InnerException.Message }
    if (-not $msg.Trim()) { return $false }
    $needles = @(
        'network name is no longer available'
        'forcibly closed'
        'connection was aborted'
        'existing connection was forcibly closed'
        'I/O operation has been aborted'
        'transport connection'
    )
    foreach ($n in $needles) {
        if ($msg -match [regex]::Escape($n)) { return $true }
    }
    return $false
}

function Test-CvlIngestEntry {
    param([hashtable]$Entry, [int]$MaxTextLen = 32000, [int]$MaxBodyLen = 512000)
    foreach ($key in $Entry.Keys) {
        $k = $key.ToString().ToLowerInvariant()
        foreach ($bad in $script:CvlForbiddenKeys) {
            if ($k -eq $bad -or $k -like "*$bad*") {
                return @{ ok = $false; error = "forbidden field: $key" }
            }
        }
    }
    if ($Entry.Contains('tier')) {
        $t = [string]$Entry.tier
        if ($t -and ($script:CvlValidTiers -notcontains $t)) {
            return @{ ok = $false; error = "invalid tier: $t" }
        }
    }
    if ($Entry.Contains('type')) {
        $ty = [string]$Entry.type
        if ($ty -match '^(probe|ping|echo|relay-back)$') {
            return @{ ok = $false; error = 'tumble type blocked' }
        }
    }
    if ($Entry.Contains('text')) {
        $txt = [string]$Entry.text
        if ($txt.Length -gt $MaxTextLen) {
            return @{ ok = $false; error = 'text too long' }
        }
    }
    return @{ ok = $true }
}

function Write-CvlAllowlistFile {
    param(
        [Parameter(Mandatory)]
        [string]$RemoteAddress,
        [string]$StatusDir = 'C:\lifepunch\status'
    )
    New-Item -ItemType Directory -Force -Path $StatusDir | Out-Null
    $file = Join-Path $StatusDir 'hub-ingest-allowlist.txt'
    $ip = $RemoteAddress.Trim()
    @(
        "# CVL hub/status client IPs (one per line). VENGEANCE home public IP."
        "# Re-run Secure-LifepunchnetCvlPorts.ps1 when this changes."
        $ip
    ) | Set-Content -LiteralPath $file -Encoding UTF8
}
