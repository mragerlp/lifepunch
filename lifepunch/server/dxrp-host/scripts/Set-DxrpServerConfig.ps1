# Write dxrp-server-config.json for ONE portal server (optional dxrp-server.cs launcher path).
# Primary lifepunchnet launch: server1_start.bat / server2_start.bat — dotnet run dxrp-server.cs --token.

function Get-DxrpOfficialInstallRoot {
    return 'C:\SBOX-DXRP-Server'
}

function Get-DxrpDevelopmentInstallRoot {
    return 'C:\Program Files (x86)\Steam\steamapps\common\sbox'
}

function Set-DxrpServerConfigForProfile {
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Development', 'Official')]
        [string] $Profile,

        [string] $InstallRoot = '',
        [string] $Token = ''
    )

    if (-not $InstallRoot) {
        $InstallRoot = if ($Profile -eq 'Development') { Get-DxrpDevelopmentInstallRoot } else { Get-DxrpOfficialInstallRoot }
    }

    $profiles = @{
        Development = @{
            GamePort  = 27016
            QueryPort = 27017
        }
        Official = @{
            GamePort  = 27015
            QueryPort = 27018
        }
    }

    $p = $profiles[$Profile]
    $extraArgs = '+port ' + $p.GamePort + ' +net_query_port ' + $p.QueryPort

    $configPath = Join-Path $InstallRoot 'dxrp-server-config.json'
    if (-not $Token -and (Test-Path -LiteralPath $configPath)) {
        try {
            $existing = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
            if ($existing.token) { $Token = [string]$existing.token }
        }
        catch { }
    }

    $config = [ordered]@{
        token        = $Token
        repoUrl      = 'https://github.com/dxura/dxrp.git'
        branch       = 'main'
        apiEndpoint  = 'https://api.dxrp.net'
        verifyAddons = $false
        map          = ''
        extraArgs    = $extraArgs
    }

    $json = ($config | ConvertTo-Json -Depth 5)
    Set-Content -LiteralPath $configPath -Value $json -Encoding UTF8

    Write-Host ('Config: ' + $Profile + ' -> port ' + $p.GamePort + ', query ' + $p.QueryPort + ', verifyAddons=false (dedicated host)') -ForegroundColor DarkGray

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

        [string] $InstallRoot = ''
    )

    if (-not $InstallRoot) {
        $InstallRoot = if ($Profile -eq 'Development') { Get-DxrpDevelopmentInstallRoot } else { Get-DxrpOfficialInstallRoot }
    }

    $expectedPort = if ($Profile -eq 'Development') { 27016 } else { 27015 }
    $expectedQueryPort = if ($Profile -eq 'Development') { 27017 } else { 27018 }
    $configPath = Join-Path $InstallRoot 'dxrp-server-config.json'
    if (-not (Test-Path -LiteralPath $configPath)) {
        throw ('Missing ' + $configPath)
    }

    $raw = Get-Content -LiteralPath $configPath -Raw
    if ($raw -match '\+game\b') {
        throw 'dxrp-server-config.json must not include +game in extraArgs — dxrp-server.cs sets the local game path.'
    }
    if ($raw -match '"verifyAddons"\s*:\s*true') {
        throw 'dxrp-server-config.json must not set verifyAddons true on lifepunchnet — dedicated install lacks rp.csproj / full sbox SDK; compile is validated at sbox-server launch.'
    }
    if ($raw -notmatch ('\+port\s+' + $expectedPort + '\b')) {
        throw ('dxrp-server-config.json has wrong +port for ' + $Profile + ' (expected ' + $expectedPort + ').')
    }
    if ($raw -notmatch ('\+net_query_port\s+' + $expectedQueryPort + '\b')) {
        throw ('dxrp-server-config.json has wrong +net_query_port for ' + $Profile + ' (expected ' + $expectedQueryPort + ').')
    }
}
