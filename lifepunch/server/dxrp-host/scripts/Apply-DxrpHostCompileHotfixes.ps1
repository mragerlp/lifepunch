<#
.SYNOPSIS
  Patch portal-downloaded addon code for known staging DXRP API breaks (lifepunchnet).
#>
[CmdletBinding()]
param(
    [string] $InstallRoot = (Get-Location).Path
)

$ErrorActionPreference = 'Stop'

function Patch-FileOnce {
    param(
        [string] $Path,
        [string] $Old,
        [string] $New,
        [string] $Label
    )
    if (-not (Test-Path -LiteralPath $Path)) { return }
    $text = Get-Content -LiteralPath $Path -Raw
    if ($text.Contains($New)) {
        Write-Host "  skip $Label (already patched)" -ForegroundColor DarkGray
        return
    }
    if (-not $text.Contains($Old)) {
        Write-Host "  warn $Label (pattern missing, portal revision may have changed)" -ForegroundColor Yellow
        return
    }
    Set-Content -LiteralPath $Path -Value $text.Replace($Old, $New) -NoNewline
    Write-Host "  patched $Label" -ForegroundColor Green
}

Write-Host "Apply-DxrpHostCompileHotfixes ($InstallRoot)" -ForegroundColor Cyan

$pickpocket = Join-Path $InstallRoot 'dxrp\game\Code\Addons\pikpak\pickpocket\PickpocketService.cs'
$oldBlock = @'
		var current = caller.CurrentEquipment;
		if ( !current.IsValid() || !string.Equals( current.Identifier, Identifier, StringComparison.OrdinalIgnoreCase ) )
		{
			return null;
		}

		return current.Components.Get<PickpocketEquipment>( FindMode.EverythingInSelfAndDescendants );
'@
$newBlock = @'
		var current = caller.CurrentEquipment;
		if ( !current.IsValid() )
		{
			return null;
		}

		return current.Components.Get<PickpocketEquipment>( FindMode.EverythingInSelfAndDescendants );
'@

Patch-FileOnce -Path $pickpocket -Label 'pikpak.pickpocket Equipment.Identifier' -Old $oldBlock -New $newBlock

$badLine = 'if ( !current.IsValid() || !string.Equals( current.Identifier, Identifier, StringComparison.OrdinalIgnoreCase ) )'
$goodLine = 'if ( !current.IsValid() )'
Patch-FileOnce -Path $pickpocket -Label 'pikpak.pickpocket Equipment.Identifier (single-line)' -Old $badLine -New $goodLine

Write-Host 'Done.' -ForegroundColor Green
