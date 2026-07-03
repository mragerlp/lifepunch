# Shared helpers — stop ONE dxrp-server instance without killing the other server.
# Official: C:\SBOX-DXRP-Server (27015). Development: Steam sbox folder (27016).
# Both tokens live in C:\SBOX-DXRP-Server\secure\ (canonical on lifepunchnet).

function Get-DxrpSecretsRoot {
    param([string] $InstallRoot)
    $central = 'C:\SBOX-DXRP-Server\secure'
    if (Test-Path -LiteralPath $central) { return $central }
    return Join-Path $InstallRoot 'secure'
}

function Stop-DxrpServerForToken {
    param(
        [Parameter(Mandatory)]
        [string] $Token
    )
    if (-not $Token) { return }

    Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
        Where-Object { $_.CommandLine -and $_.CommandLine.Contains($Token) } |
        ForEach-Object {
            Write-Host "  Stop $($_.Name) pid $($_.ProcessId) (matched token)" -ForegroundColor DarkGray
            Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
        }
}

function Stop-DxrpLauncherCmdWindows {
    param(
        [Parameter(Mandatory)]
        [string] $StartBatName
    )
    Get-CimInstance Win32_Process -Filter "Name='cmd.exe'" -ErrorAction SilentlyContinue |
        Where-Object { $_.CommandLine -and $_.CommandLine -match [regex]::Escape($StartBatName) } |
        ForEach-Object {
            Write-Host "  Stop cmd pid $($_.ProcessId) ($StartBatName)" -ForegroundColor DarkGray
            Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
        }
}

function Stop-SboxServerOnPort {
    param(
        [Parameter(Mandatory)]
        [int] $Port
    )
    try {
        Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue |
            Select-Object -ExpandProperty OwningProcess -Unique |
            ForEach-Object {
                $p = Get-Process -Id $_ -ErrorAction SilentlyContinue
                if ($p -and $p.Name -match '^(sbox-server|dotnet|dxrp-server)') {
                    Write-Host "  Stop $($p.Name) pid $_ (port $Port)" -ForegroundColor DarkGray
                    Stop-Process -Id $_ -Force -ErrorAction SilentlyContinue
                }
            }
    }
    catch {
        # Get-NetTCPConnection may require elevation on some hosts — token kill is enough.
    }
}

function Stop-DevelopmentDxrpServer {
    param(
        [string] $InstallRoot = 'C:\Program Files (x86)\Steam\steamapps\common\sbox',
        [int] $GamePort = 27016
    )
    $envFile = Join-Path (Get-DxrpSecretsRoot -InstallRoot $InstallRoot) 'development.local.env'
    $token = $null
    if (Test-Path -LiteralPath $envFile) {
        Get-Content -LiteralPath $envFile | ForEach-Object {
            if ($_ -match '^\s*DXRP_TOKEN_DEVELOPMENT\s*=\s*(.+)\s*$') {
                $token = $Matches[1].Trim().Trim('"')
            }
        }
    }
    if ($token) {
        Write-Host "Stopping Development dxrp-server only (token match)..." -ForegroundColor Cyan
        Stop-DxrpLauncherCmdWindows -StartBatName 'server2_start.bat'
        Stop-DxrpServerForToken -Token $token
    }
    else {
        Write-Host 'WARN: No DXRP_TOKEN_DEVELOPMENT — skip dotnet kill (will not touch Official).' -ForegroundColor Yellow
    }
    Stop-SboxServerOnPort -Port $GamePort
    Start-Sleep -Seconds 2
}

function Stop-OfficialDxrpServer {
    param(
        [string] $InstallRoot = 'C:\SBOX-DXRP-Server',
        [int] $GamePort = 27015
    )
    $envFile = Join-Path (Get-DxrpSecretsRoot -InstallRoot $InstallRoot) 'official.local.env'
    $token = $null
    if (Test-Path -LiteralPath $envFile) {
        Get-Content -LiteralPath $envFile | ForEach-Object {
            if ($_ -match '^\s*DXRP_TOKEN_OFFICIAL\s*=\s*(.+)\s*$') {
                $token = $Matches[1].Trim().Trim('"')
            }
        }
    }
    if ($token) {
        Write-Host "Stopping Official dxrp-server only (token match)..." -ForegroundColor Cyan
        Stop-DxrpLauncherCmdWindows -StartBatName 'server1_start.bat'
        Stop-DxrpServerForToken -Token $token
    }
    Stop-SboxServerOnPort -Port $GamePort
    Start-Sleep -Seconds 2
}
