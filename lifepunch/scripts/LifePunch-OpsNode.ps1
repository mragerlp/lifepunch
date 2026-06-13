<#
.SYNOPSIS
  Shared ops-node tier helpers (VENGEANCE / Cornerman / lifepunchnet).
#>
function Get-LifePunchOpsTier {
    $cfgPath = Join-Path $env:LOCALAPPDATA 'LifePunch\ops-node.json'
    if (Test-Path -LiteralPath $cfgPath) {
        try {
            $tier = [string](Get-Content -LiteralPath $cfgPath -Raw | ConvertFrom-Json).tier
            if ($tier) { return $tier.ToLowerInvariant() }
        }
        catch { }
    }

    $hn = $env:COMPUTERNAME.ToUpperInvariant()
    if ($hn -like '*VENGEANCE*') { return 'vengeance' }
    if ($hn -like '*CORNERMAN*') { return 'cornerman' }
    if ($hn -like '*LIFEPUNCHNET*') { return 'lifepunchnet' }
    return ''
}

function Test-IsVengeanceWorkstation {
    return (Get-LifePunchOpsTier) -eq 'vengeance'
}
