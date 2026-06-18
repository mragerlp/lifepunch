# DXRP disk layout: virtual path addons/lifepunch/... -> Assets/addons/lifepunch/...
# (Same as Sync-LifePunchAddonsToDxrp.ps1 — NOT game/addons/lifepunch.)

function Get-DxrpGameRootFromConfig {
    param([string] $ConfigPath)
    if (-not (Test-Path -LiteralPath $ConfigPath)) { throw "Missing $ConfigPath" }
    $cfg = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
    return Split-Path -Parent ([string]$cfg.projectPath)
}

function Get-DxrpLifepunchAddonsDiskRoot {
    param([string] $DxrpGameRoot)
    return Join-Path $DxrpGameRoot 'Assets\addons\lifepunch'
}
