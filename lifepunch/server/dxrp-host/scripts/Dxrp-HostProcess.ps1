# Shared helpers — stop ONE dxrp-server instance without killing the other server.
# Dev (27016) and Official (27015) share C:\S&BOX DXRP Server but use different portal tokens.

function Stop-DxrpServerForToken {
    param(
        [Parameter(Mandatory)]
        [string] $Token
    )
    if (-not $Token) { return }

    Get-CimInstance Win32_Process -Filter "Name='dotnet.exe'" -ErrorAction SilentlyContinue |
        Where-Object { $_.CommandLine -and $_.CommandLine.Contains($Token) } |
        ForEach-Object {
            Write-Host "  Stop dotnet pid $($_.ProcessId) (matched token)" -ForegroundColor DarkGray
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
                if ($p -and $p.Name -eq 'sbox-server') {
                    Write-Host "  Stop sbox-server pid $_ (port $Port)" -ForegroundColor DarkGray
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
        [string] $InstallRoot = 'C:\S&BOX DXRP Server',
        [int] $GamePort = 27016
    )
    $envFile = Join-Path $InstallRoot 'secure\development.local.env'
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
        Stop-DxrpServerForToken -Token $token
    }
    else {
        Write-Host 'WARN: No DXRP_TOKEN_DEVELOPMENT — skip dotnet kill (will not touch Official).' -ForegroundColor Yellow
    }
    Stop-SboxServerOnPort -Port $GamePort
}

function Stop-OfficialDxrpServer {
    param(
        [string] $InstallRoot = 'C:\S&BOX DXRP Server',
        [int] $GamePort = 27015
    )
    $envFile = Join-Path $InstallRoot 'secure\official.local.env'
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
        Stop-DxrpServerForToken -Token $token
    }
    Stop-SboxServerOnPort -Port $GamePort
}
