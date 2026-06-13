# Runs ON VENGEANCE. Emits one JSON line (or human-readable when -Pretty).
[CmdletBinding()]
param([switch] $Pretty)

$ErrorActionPreference = 'SilentlyContinue'

$os = Get-CimInstance Win32_OperatingSystem
$ramTotalGb = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
$ramFreeGb = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
$ramUsedPct = if ($ramTotalGb -gt 0) { [math]::Round((1 - ($ramFreeGb / $ramTotalGb)) * 100, 0) } else { 0 }

# Wrong-node on Red: belong on lifepunchnet (Blue) or Cornerman (Green Tier-3).
$bloatHints = @(
    @{ Name = 'Discord'; Match = '(?i)^Discord$'; Why = 'Use lifepunchnet RDP Discord, not local on VENGEANCE' }
    @{ Name = 'Spotify'; Match = '(?i)^Spotify$'; Why = 'Run on lifepunchnet RDP or quit during s&box work' }
    @{ Name = 'Slack'; Match = '(?i)^slack$'; Why = 'Run on lifepunchnet if needed' }
    @{ Name = 'iTunes'; Match = '(?i)^iTunes$'; Why = 'Run on lifepunchnet if needed' }
    @{ Name = 'LM Studio GUI'; Match = '(?i)LM Studio'; Why = 'Tier-3 LM lives on Cornerman headless, not Red' }
    @{ Name = 'Ollama'; Match = '(?i)^ollama$'; Why = 'Local LLM on Cornerman/lifepunchnet, not VENGEANCE' }
    @{ Name = 'Odysseus'; Match = '(?i)odysseus'; Why = 'Experimental Tier-3 belongs off Red' }
)

$allowProc = '(?i)^(System|Idle|Registry|csrss|wininit|services|lsass|svchost|dwm|explorer|powershell|pwsh|conhost|Cursor|sbox|steam|steamservice|steamwebhelper|SearchHost|RuntimeBroker|WmiPrvSE|fontdrvhost|audiodg|nvcontainer|NVDisplay|amd|RadeonSoftware|MsMpEng|SecurityHealth|ShellExperienceHost|StartMenuExperienceHost|TextInputHost|ApplicationFrameHost|SystemSettings|taskhostw|dllhost|smartscreen|chrome|msedge|msedgewebview2|node|git|ssh|Code|devenv)$'

$bloat = [System.Collections.Generic.List[string]]::new()
$topProcs = [System.Collections.Generic.List[string]]::new()

Get-Process -ErrorAction SilentlyContinue |
    Where-Object { $_.WorkingSet64 -gt 350MB } |
    Sort-Object WorkingSet64 -Descending |
    Select-Object -First 12 |
    ForEach-Object {
        $mb = [math]::Round($_.WorkingSet64 / 1MB, 0)
        if ($_.ProcessName -notmatch $allowProc) {
            $topProcs.Add("$($_.ProcessName):${mb}MB")
        }
        foreach ($hint in $bloatHints) {
            if ($_.ProcessName -match $hint.Match) {
                $msg = "$($hint.Name) (${mb}MB) - $($hint.Why)"
                if (-not ($bloat | Where-Object { $_ -eq $msg })) { $bloat.Add($msg) }
            }
        }
    }

$sboxCount = @(Get-Process -Name 'sbox' -ErrorAction SilentlyContinue).Count
$staleSbox = ($sboxCount -gt 1)

$optionalServices = @(
    'DiagTrack', 'XblGameSave', 'XboxGipSvc', 'XboxNetApiSvc', 'MapsBroker', 'WSearch'
)
$runningOptional = @()
foreach ($svcName in $optionalServices) {
    $svc = Get-Service -Name $svcName -ErrorAction SilentlyContinue
    if ($svc -and $svc.Status -eq 'Running') {
        $runningOptional += $svcName
    }
}

$powerPlan = 'unknown'
try { $powerPlan = (powercfg /getactivescheme 2>$null) -replace '.*: ', '' } catch { }

$payload = [ordered]@{
    node              = 'vengeance'
    hostname          = $env:COMPUTERNAME
    ramTotalGb        = $ramTotalGb
    ramFreeGb         = $ramFreeGb
    ramUsedPct        = $ramUsedPct
    bloat             = @($bloat)
    topMemoryMb       = @($topProcs)
    sboxProcessCount  = $sboxCount
    staleSbox         = $staleSbox
    optionalServices  = @($runningOptional)
    powerPlan         = $powerPlan
    healthOk          = ($ramFreeGb -ge 4) -and ($bloat.Count -eq 0) -and (-not $staleSbox)
}

if ($Pretty) {
    $payload | Format-List
}
else {
    $payload | ConvertTo-Json -Compress
}
