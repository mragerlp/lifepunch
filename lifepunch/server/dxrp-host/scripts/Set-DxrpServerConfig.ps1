# Write dxrp-server-config.json for ONE portal server before dotnet run.
# Upstream dxrp-server.cs reads only "dxrp-server-config.json" — Dev and Official share
# the install root, so each start must stamp the correct port/extraArgs for that profile.
# Gamemode is NOT set here — portal assigns addons/gamemode via --token +authorize.

function Set-DxrpServerConfigForProfile {
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Development', 'Official')]
        [string] $Profile,

        [string] $InstallRoot = 'C:\S&BOX DXRP Server'
    )

    $profiles = @{
        Development = @{
            GamePort  = 27016
            QueryPort = 27017
            Hostname  = 'LifePunch Official | DEVELOPMENT SERVER'
        }
        Official = @{
            GamePort  = 27015
            QueryPort = 27016
            Hostname  = 'LIFEPUNCH™ Official | 70p | ₿'
        }
    }

    $p = $profiles[$Profile]
    $extraArgs = "+port $($p.GamePort) +net_query_port $($p.QueryPort) +hostname `"$($p.Hostname)`""

    $config = [ordered]@{
        token        = ''
        repoUrl      = 'https://github.com/dxura/dxrp.git'
        branch       = 'main'
        apiEndpoint  = 'https://api.dxrp.net'
        verifyAddons = $false
        map          = ''
        extraArgs    = $extraArgs
    }

    $configPath = Join-Path $InstallRoot 'dxrp-server-config.json'
    $json = ($config | ConvertTo-Json -Depth 5)
    Set-Content -LiteralPath $configPath -Value $json -Encoding UTF8

    Write-Host "Config: $Profile -> port $($p.GamePort), query $($p.QueryPort)" -ForegroundColor DarkGray
    Write-Host "        gamemode/map NOT overridden (portal token controls addons)" -ForegroundColor DarkGray

    return @{
        GamePort  = $p.GamePort
        QueryPort = $p.QueryPort
        ExtraArgs = $extraArgs
    }
}

function Test-DxrpServerConfigForProfile {
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Development', 'Official')]
        [string] $Profile,

        [string] $InstallRoot = 'C:\S&BOX DXRP Server'
    )

    $expectedPort = if ($Profile -eq 'Development') { 27016 } else { 27015 }
    $configPath = Join-Path $InstallRoot 'dxrp-server-config.json'
    if (-not (Test-Path -LiteralPath $configPath)) {
        throw "Missing $configPath — run Set-DxrpServerConfigForProfile first."
    }

    $raw = Get-Content -LiteralPath $configPath -Raw
    if ($raw -match '\+map\s') {
        throw 'dxrp-server-config.json must not set +map — gamemode/map come from portal assignment.'
    }
    if ($raw -match '\+game\s') {
        throw 'dxrp-server-config.json must not set +game — dxrp-server.cs owns +game rp.sbproj.'
    }
    if ($raw -notmatch "\+port\s+$expectedPort\b") {
        throw "dxrp-server-config.json has wrong +port for $Profile (expected $expectedPort). Shared config was likely stamped by the other server."
    }
}
