<#
.SYNOPSIS
  Create OneDrive secret file for headless Green SMB map to \\VENGEANCE\SboxBridgeIpc.
.EXAMPLE
  powershell -ExecutionPolicy Bypass -File lifepunch\scripts\Initialize-VengeanceSmbSecret.ps1
#>
[CmdletBinding()] param([switch]$Force)
$ErrorActionPreference = 'Stop'
$secretDir = Join-Path $env:USERPROFILE 'OneDrive\Lifepunch\Secrets'
$secretPath = Join-Path $secretDir 'vengeance-smb.password'
New-Item -ItemType Directory -Force -Path $secretDir | Out-Null
if ((Test-Path -LiteralPath $secretPath) -and -not $Force) {
  Write-Host "Already exists: $secretPath" -ForegroundColor Yellow
  Write-Host 'Re-run with -Force to overwrite.' -ForegroundColor DarkGray
  exit 0
}
Write-Host 'Create VENGEANCE SMB secret for Cornerman bridge map' -ForegroundColor Cyan
Write-Host '  Account: VENGEANCE\jared' -ForegroundColor DarkGray
Write-Host "  File:    $secretPath" -ForegroundColor White
$sec1 = Read-Host 'Enter password' -AsSecureString
$sec2 = Read-Host 'Confirm password' -AsSecureString
function Test-SecureEqual([SecureString]$A,[SecureString]$B) {
  $bstrA=[Runtime.InteropServices.Marshal]::SecureStringToBSTR($A)
  $bstrB=[Runtime.InteropServices.Marshal]::SecureStringToBSTR($B)
  try { [Runtime.InteropServices.Marshal]::PtrToStringAuto($bstrA) -ceq [Runtime.InteropServices.Marshal]::PtrToStringAuto($bstrB) }
  finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstrA); [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstrB) }
}
if (-not (Test-SecureEqual $sec1 $sec2)) { throw 'Passwords did not match.' }
$bstr=[Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec1)
try {
  $plain=[Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
  if ([string]::IsNullOrWhiteSpace($plain)) { throw 'Password cannot be empty.' }
  $utf8=New-Object System.Text.UTF8Encoding $false
  [IO.File]::WriteAllText($secretPath,$plain.Trim(),$utf8)
} finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
$acl=Get-Acl -LiteralPath $secretPath
$acl.SetAccessRuleProtection($true,$false)
$acl.SetAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($env:USERNAME,'FullControl','Allow')))
$acl | Set-Acl -LiteralPath $secretPath
Write-Host "OK wrote $secretPath" -ForegroundColor Green
Write-Host 'Next: powershell -File lifepunch\scripts\Connect-CornermanBridge.ps1' -ForegroundColor Cyan
