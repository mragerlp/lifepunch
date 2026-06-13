<#
.SYNOPSIS
  Map VENGEANCE Claude Bridge SMB share on Cornerman (run ON Green, interactive).

.DESCRIPTION
  Cornerman cannot use anonymous SMB to \\VENGEANCE\SboxBridgeIpc even with Everyone
  share ACLs. Map once with your VENGEANCE account (same jared password on LAN).

.EXAMPLE
  # On Cornerman (desktop PowerShell):
  powershell -File C:\lifepunch\cornerman\Map-CornermanBridgeShare.ps1

  # From VENGEANCE via SSH (prompts for password on Green console if RDP open):
  ssh -t cornerman "powershell -File C:\lifepunch\cornerman\Map-CornermanBridgeShare.ps1"
#>
[CmdletBinding()]
param(
    [string] $VengeanceHost = 'VENGEANCE',
    [string] $VengeanceIp = '192.168.1.236',
    [string] $ShareName = 'SboxBridgeIpc',
    [string] $User = 'VENGEANCE\jared',
    [SecureString] $Password
)

$uncHost = "\\$VengeanceHost\$ShareName"
$uncIp = "\\$VengeanceIp\$ShareName"

Write-Host "Mapping bridge share (VENGEANCE Claude Bridge IPC)..." -ForegroundColor Cyan
Write-Host "User: $User" -ForegroundColor DarkGray

net use $uncHost /delete /y 2>$null | Out-Null
net use $uncIp /delete /y 2>$null | Out-Null

function Invoke-BridgeNetUse([string]$Unc) {
    if ($Password) {
        $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
        try {
            $plain = [Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
            cmdkey /add:$VengeanceHost /user:$User /pass:$plain 2>$null | Out-Null
            net use $Unc /user:$User $plain /persistent:yes | Out-Null
        }
        finally {
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        }
        return $LASTEXITCODE -eq 0
    }
    # Interactive password prompt (do not pass password on command line).
    net use $Unc /user:$User /persistent:yes
    return $LASTEXITCODE -eq 0
}

$mapped = Invoke-BridgeNetUse -Unc $uncHost
if (-not $mapped) {
    Write-Host "Hostname map failed; trying IP $uncIp ..." -ForegroundColor Yellow
    $mapped = Invoke-BridgeNetUse -Unc $uncIp
}

$ok = (Test-Path -LiteralPath (Join-Path $uncHost 'status.json')) -or (Test-Path -LiteralPath (Join-Path $uncIp 'status.json'))
if ($ok) {
    if ($Password) {
        $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
        try {
            $plain = [Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
            cmdkey /generic:LifePunch/VengeanceSmb /user:$User /pass:$plain 2>$null | Out-Null
            cmdkey /add:$VengeanceHost /user:$User /pass:$plain 2>$null | Out-Null
        }
        finally {
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        }
    }
    Write-Host 'OK — Cornerman can read bridge IPC. Restart Cursor -> MCP sbox should go green when editor runs on VENGEANCE.' -ForegroundColor Green
}
else {
    Write-Host 'FAIL — still cannot read status.json. Confirm share exists on VENGEANCE and password is correct.' -ForegroundColor Red
    exit 1
}
