# Runs ON Cornerman (via SSH from VENGEANCE). Emits one JSON line.
$ErrorActionPreference = 'SilentlyContinue'

function Get-LmsExe {
    $candidates = @(
        (Join-Path $env:USERPROFILE '.lmstudio\bin\lms.exe')
        (Join-Path $env:LOCALAPPDATA 'LM Studio\bin\lms.exe')
    )
    foreach ($c in $candidates) {
        if (Test-Path -LiteralPath $c) { return $c }
    }
    return $null
}

function Get-LmsLoadedIds {
    $lms = Get-LmsExe
    if (-not $lms) { return @() }
    $psText = (& $lms ps 2>&1 | ForEach-Object { "$_" }) -join "`n"
    return @([regex]::Matches($psText, '(?m)^(\S+)\s+\S+\s+(?:IDLE|RUNNING)\s') |
        ForEach-Object { $_.Groups[1].Value } |
        Select-Object -Unique)
}

function Test-IdPresent($req, $ids) {
    if ($ids -contains $req) { return $true }
    if ($req -like '*embed*') {
        return @($ids | Where-Object { $_ -like '*embed*' -or $_ -eq 'lp-embed' }).Count -gt 0
    }
    return $false
}

$requiredServe = @('qwen/qwen3.6-35b-a3b', 'text-embedding-nomic-embed-text-v1.5')
$requiredCatalog = @(
    'qwen/qwen3.6-35b-a3b'
    'qwen2.5-coder-32b-instruct'
    'text-embedding-nomic-embed-text-v1.5'
)

$os = Get-CimInstance Win32_OperatingSystem
$ramTotalGb = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
$ramFreeGb = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
$ramUsedPct = if ($ramTotalGb -gt 0) { [math]::Round((1 - ($ramFreeGb / $ramTotalGb)) * 100, 0) } else { 0 }

$lmGuiProcs = @(Get-Process -ErrorAction SilentlyContinue |
    Where-Object { $_.ProcessName -match 'LM Studio' -or $_.MainWindowTitle -match 'LM Studio' })
$lmGuiRunning = ($lmGuiProcs.Count -gt 0)
$lmGuiRamMb = [math]::Round(($lmGuiProcs | Measure-Object WorkingSet64 -Sum).Sum / 1MB, 0)

$lmStudioOk = $false
$lmCatalogOk = $false
$lmServeOk = $false
$lmVramCount = 0
$lmVramLoaded = ''
$vramIds = @(Get-LmsLoadedIds)
$lmVramCount = $vramIds.Count
$lmVramLoaded = ($vramIds -join ',')
if ($lmVramLoaded.Length -gt 100) { $lmVramLoaded = $lmVramLoaded.Substring(0, 100) }

foreach ($probeHost in @('127.0.0.1')) {
    try {
        $r = Invoke-WebRequest -Uri "http://${probeHost}:1234/v1/models" -TimeoutSec 4 -UseBasicParsing
        if ($r.StatusCode -ne 200) { continue }
        $lmStudioOk = $true
        $ids = @(($r.Content | ConvertFrom-Json).data | ForEach-Object { $_.id })
        $catalogMissing = @($requiredCatalog | Where-Object { -not (Test-IdPresent $_ $ids) })
        $lmCatalogOk = ($catalogMissing.Count -eq 0)
        break
    }
    catch { }
}

if ($lmStudioOk) {
    $serveMissing = @($requiredServe | Where-Object { -not (Test-IdPresent $_ $vramIds) })
    $lmServeOk = ($serveMissing.Count -eq 0) -and ($lmVramCount -gt 0)
}

$lmWatchdogOk = $false
$wd = schtasks /Query /TN LifePunch-Cornerman-LM-Watchdog /FO LIST 2>$null
if ($wd -match 'Ready|Running') { $lmWatchdogOk = $true }

$tunnelWatchdogOk = $false
$twd = schtasks /Query /TN LifePunch-Cornerman-SboxEditor-Tunnel /FO LIST 2>$null
if ($twd -match 'Ready|Running') { $tunnelWatchdogOk = $true }

$allowProc = '(?i)^(System|Idle|Registry|csrss|wininit|services|lsass|svchost|dwm|explorer|powershell|pwsh|conhost|sshd|OpenSSH|python|node|lms|Cursor|SearchHost|RuntimeBroker|WmiPrvSE|fontdrvhost)$'
$bloatHints = @(
    @{ Name = 'LM Studio GUI'; Match = '(?i)LM Studio'; Why = 'Close window -  use headless lms server + watchdog' }
    @{ Name = 'Discord'; Match = '(?i)^Discord$'; Why = 'Run Discord on lifepunchnet RDP, not Green' }
    @{ Name = 'Chrome'; Match = '(?i)^(chrome|msedge)$'; Why = 'Browser RAM on Green competes with Tier-3 VRAM' }
    @{ Name = 'Spotify'; Match = '(?i)^Spotify$'; Why = 'Optional -  quit if distill loads are slow' }
    @{ Name = 'Steam'; Match = '(?i)^steam'; Why = 'OK if idle; quit if not needed on Green' }
    @{ Name = 'Lemonade'; Match = '(?i)^Lemonade'; Why = 'Deprecated — Remove-CornermanLemonade.ps1; use LM Studio :1234 only' }
)

$bloat = [System.Collections.Generic.List[string]]::new()
$topProcs = @(Get-Process -ErrorAction SilentlyContinue |
    Where-Object { $_.WorkingSet64 -gt 400MB } |
    Sort-Object WorkingSet64 -Descending |
    Select-Object -First 8 |
    ForEach-Object {
        $mb = [math]::Round($_.WorkingSet64 / 1MB, 0)
        $line = "$($_.ProcessName):${mb}MB"
        foreach ($hint in $bloatHints) {
            if ($hint.Name -eq 'LM Studio GUI' -and $lmGuiRunning) { continue }
            if ($_.ProcessName -match $hint.Match -and $bloat -notcontains $hint.Name) {
                $bloat.Add("$($hint.Name) (${mb}MB) - $($hint.Why)")
            }
        }
        if ($_.ProcessName -notmatch $allowProc) { $line }
    })

if ($lmGuiRunning) {
    $bloat.Add("LM Studio GUI (${lmGuiRamMb}MB) -  close window; server stays via lms CLI + watchdog")
}

$powerPlan = 'unknown'
try {
    $powerPlan = (powercfg /getactivescheme 2>$null) -replace '.*: ', ''
}
catch { }

$tunnel9090Ok = $false
try {
    $null = Invoke-WebRequest -Uri 'http://127.0.0.1:9090/sbox-mcp' -Method Post `
        -ContentType 'application/json' `
        -Body '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"probe","version":"1"}}}' `
        -TimeoutSec 3 -UseBasicParsing
    $tunnel9090Ok = $true
}
catch { }

$smbShareOk = $false
$vengeanceName = $env:VENGEANCE_HOST
if (-not $vengeanceName) { $vengeanceName = 'VENGEANCE' }
$uncIpc = "\\$vengeanceName\SboxBridgeIpc"
$smbShareOk = Test-Path -LiteralPath $uncIpc

$mcpKeys = @()
$mcpPath = Join-Path $env:USERPROFILE '.cursor\mcp.json'
if (Test-Path -LiteralPath $mcpPath) {
    $mj = Get-Content -LiteralPath $mcpPath -Raw | ConvertFrom-Json
    if ($mj.mcpServers) {
        $mcpKeys = @($mj.mcpServers.PSObject.Properties.Name)
    }
}

$mcpTripleOk = @('sbox', 'sbox-editor', 'cornerman-lm') | ForEach-Object { $_ -in $mcpKeys } | Where-Object { $_ -eq $false } | Measure-Object | Select-Object -ExpandProperty Count
$mcpTripleOk = ($mcpTripleOk -eq 0)

$payload = [ordered]@{
    node           = 'cornerman'
    hostname       = $env:COMPUTERNAME
    ramTotalGb     = $ramTotalGb
    ramFreeGb      = $ramFreeGb
    ramUsedPct     = $ramUsedPct
    lmGuiRunning   = $lmGuiRunning
    lmGuiRamMb      = $lmGuiRamMb
    lmStudioOk     = $lmStudioOk
    lmCatalogOk    = $lmCatalogOk
    lmServeOk      = $lmServeOk
    lmVramCount    = $lmVramCount
    lmVramLoaded   = $lmVramLoaded
    lmWatchdogOk   = $lmWatchdogOk
    tunnelWatchdogOk = $tunnelWatchdogOk
    bloat          = @($bloat)
    topMemoryMb    = @($topProcs)
    powerPlan      = $powerPlan
    tunnel9090Ok   = $tunnel9090Ok
    smbShareOk     = $smbShareOk
    mcpKeys        = ($mcpKeys -join ',')
    mcpTripleOk    = $mcpTripleOk
    healthOk       = ($ramFreeGb -ge 8) -and (-not $lmGuiRunning) -and $lmServeOk -and $lmWatchdogOk
}
$payload | ConvertTo-Json -Compress
