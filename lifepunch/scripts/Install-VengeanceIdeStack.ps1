<#
.SYNOPSIS
  Idempotent VENGEANCE Cursor + s&box IDE stack installer.

.DESCRIPTION
  Installs Cursor extensions (C#, S&box API Tools via VSIX, Slang), sets SBOX_LOG_PATH
  for Claude Bridge MCP, and verifies dotnet + s&box paths.

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File lifepunch\scripts\Install-VengeanceIdeStack.ps1
#>
[CmdletBinding()]
param(
	[string] $SboxRoot = 'D:\Steam\steamapps\common\sbox',
	[string] $AddonsRoot = '',
	[switch] $SkipEnv
)

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $here '..\..')
if ( -not $AddonsRoot ) {
	$AddonsRoot = Join-Path $repoRoot 'lifepunch\addons'
}

$script:CursorExe = $null

function Resolve-CursorExe {
	if ( $script:CursorExe ) { return $script:CursorExe }
	$cmd = Get-Command cursor -ErrorAction SilentlyContinue
	if ( $cmd ) {
		$script:CursorExe = $cmd.Source
		return $script:CursorExe
	}
	$candidates = @(
		(Join-Path $env:LOCALAPPDATA 'Programs\cursor\resources\app\bin\cursor.cmd'),
		(Join-Path $env:LOCALAPPDATA 'Programs\cursor\Cursor.exe')
	)
	foreach ( $path in $candidates ) {
		if ( Test-Path -LiteralPath $path ) {
			$script:CursorExe = $path
			return $script:CursorExe
		}
	}
	return $null
}

function Invoke-Cursor {
	param( [Parameter( ValueFromRemainingArguments = $true )][string[]] $Args )
	$exe = Resolve-CursorExe
	if ( -not $exe ) { throw 'cursor CLI not found. Install Cursor or add cursor to PATH.' }
	$prev = $ErrorActionPreference
	$ErrorActionPreference = 'Continue'
	try {
		& $exe @Args 2>&1 | Where-Object { $_ -isnot [System.Management.Automation.ErrorRecord] -or $_.Exception.Message -notmatch 'DeprecationWarning' }
	}
	finally {
		$ErrorActionPreference = $prev
	}
}

function Install-CursorExtension {
	param( [string] $Id, [string] $VsixUrl = '' )
	$installed = @( Invoke-Cursor --list-extensions 2>$null )
	if ( $installed -contains $Id ) {
		Write-Host "  OK  $Id" -ForegroundColor Green
		return
	}
	if ( $VsixUrl ) {
		$vsix = Join-Path $env:TEMP "$($Id -replace '\.','-').vsix"
		Write-Host "  GET $VsixUrl" -ForegroundColor DarkGray
		Invoke-WebRequest -Uri $VsixUrl -OutFile $vsix -UseBasicParsing
		Invoke-Cursor --install-extension $vsix --force | Out-Null
	}
	else {
		Invoke-Cursor --install-extension $Id --force | Out-Null
	}
	if ( ( Invoke-Cursor --list-extensions 2>$null ) -contains $Id ) {
		Write-Host "  OK  $Id" -ForegroundColor Green
	}
	else {
		Write-Warning "  FAIL $Id"
	}
}

Write-Host 'VENGEANCE IDE stack' -ForegroundColor Cyan
Write-Host "Addons root: $AddonsRoot"

if ( -not ( Resolve-CursorExe ) ) {
	throw 'cursor CLI not found. Install Cursor and ensure cursor is on PATH.'
}

Write-Host "`nExtensions:" -ForegroundColor Yellow
Install-CursorExtension -Id 'anysphere.csharp'
Install-CursorExtension -Id 'alexistb2904.sbox-api-tools' -VsixUrl 'https://marketplace.visualstudio.com/_apis/public/gallery/publishers/alexistb2904/vsextensions/sbox-api-tools/0.1.0/vspackage'
Install-CursorExtension -Id 'shader-slang.slang-language-extension'

if ( -not $SkipEnv ) {
	$logPath = Join-Path $SboxRoot 'logs\sbox-dev.log'
	if ( Test-Path -LiteralPath $logPath ) {
		$current = [Environment]::GetEnvironmentVariable( 'SBOX_LOG_PATH', 'User' )
		if ( $current -ne $logPath ) {
			[Environment]::SetEnvironmentVariable( 'SBOX_LOG_PATH', $logPath, 'User' )
			Write-Host "`nSBOX_LOG_PATH -> $logPath (User)" -ForegroundColor Green
		}
		else {
			Write-Host "`nSBOX_LOG_PATH already set" -ForegroundColor Green
		}
	}
	else {
		Write-Warning "sbox log not found: $logPath"
	}
}

Write-Host "`nPrerequisites:" -ForegroundColor Yellow
try {
	$dotnet = dotnet --version
	Write-Host "  OK  dotnet $dotnet" -ForegroundColor Green
}
catch {
	Write-Warning '  FAIL dotnet SDK'
}

$engineDll = Join-Path $SboxRoot 'bin\managed\Sandbox.Engine.dll'
if ( Test-Path -LiteralPath $engineDll ) {
	Write-Host "  OK  Sandbox.Engine.dll" -ForegroundColor Green
}
else {
	Write-Warning "  FAIL missing $engineDll"
}

$workspaceSettings = Join-Path $AddonsRoot '.vscode\settings.json'
if ( Test-Path -LiteralPath $workspaceSettings ) {
	Write-Host "  OK  $workspaceSettings" -ForegroundColor Green
}
else {
	Write-Warning "  FAIL missing workspace settings"
}

Write-Host "`nManual steps:" -ForegroundColor Yellow
Write-Host "  1. Reload Cursor"
Write-Host "  2. File -> Open Folder -> $AddonsRoot"
Write-Host "  3. Open addons.slnx"
Write-Host "  4. Palette -> S&box: Validate Workspace"
Write-Host "  5. dotnet build Code\addons.csproj (from addons root)"

Write-Host "`nSboxShare: mount in s&box editor Library Manager (not Cursor)." -ForegroundColor DarkGray
