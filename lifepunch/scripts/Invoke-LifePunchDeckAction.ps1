[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet(
        'OpenRepo',
        'OpenLpBitcoinFiles',
        'StartSboxEditor',
        'SyncAddons',
        'OpenDxrpPortalChrome',
        'McpHealth',
        'GitStatus',
        'GitPullRebase',
        'CvlObservability',
        'StartLifePunchDay',
        'CvlConnectivity',
        'PreLaunchCheckup',
        'OpenCursor',
        'ValidateWorkspace'
    )]
    [string] $Action
)

$ErrorActionPreference = 'Stop'
$scriptsRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$repoRoot = (Resolve-Path (Join-Path $scriptsRoot '..')).Path
$monoRoot = (Resolve-Path (Join-Path $repoRoot '..')).Path

function Get-ChromePath {
    $candidates = @(
        'C:\Program Files\Google\Chrome\Application\chrome.exe'
        'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe'
        (Join-Path $env:LOCALAPPDATA 'Google\Chrome\Application\chrome.exe')
    )
    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate) { return $candidate }
    }
    return $null
}

function Get-PreferredCodeEditor {
    $preferred = @(
        'C:\Users\jared\AppData\Local\Programs\Microsoft VS Code\bin\code.cmd',
        'C:\Users\jared\AppData\Local\Programs\Microsoft VS Code\Code.exe',
        'C:\Users\jared\AppData\Local\Programs\Microsoft VS Code Insiders\bin\code-insiders.cmd',
        'C:\Users\jared\AppData\Local\Programs\Microsoft VS Code Insiders\Code - Insiders.exe'
    )

    foreach ($candidate in $preferred) {
        if (Test-Path -LiteralPath $candidate) {
            return $candidate
        }
    }

    $codeCmd = Get-Command code -ErrorAction SilentlyContinue
    if ($codeCmd -and $codeCmd.Source -notmatch '\\cursor\\') {
        return $codeCmd.Source
    }

    return $null
}

function Invoke-RepoScript {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [string[]]$Arguments = @()
    )
    $path = Join-Path $scriptsRoot $Name
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Missing script: $path"
    }
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $path @Arguments
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

function Test-McpEndpoint {
    param(
        [Parameter(Mandatory = $true)][string]$Url,
        [switch]$OpenAiModels
    )
    try {
        if ($OpenAiModels) {
            $r = Invoke-RestMethod -Uri $Url -Method Get -TimeoutSec 4
            return [bool]($r.data)
        }

        $body = '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"deck-probe","version":"1"}}}'
        $null = Invoke-WebRequest -Uri $Url -Method Post -ContentType 'application/json' -Body $body -TimeoutSec 4 -UseBasicParsing
        return $true
    }
    catch {
        return $false
    }
}

switch ($Action) {
    'OpenRepo' {
        Start-Process explorer.exe $repoRoot
        break
    }
    'OpenLpBitcoinFiles' {
        $editor = Get-PreferredCodeEditor
        if (-not $editor) {
            throw 'No VS Code executable found. Install VS Code or update Get-PreferredCodeEditor in Invoke-LifePunchDeckAction.ps1.'
        }

        $files = @(
            (Join-Path $repoRoot 'addons\Code\Addons\lifepunch\lpbitcoin\bitcoinhub\code\ui\LpHashdPanel.razor')
            (Join-Path $repoRoot 'addons\Code\Addons\lifepunch\lpbitcoin\bitcoinhub\code\ui\LpHashdPanel.razor.scss')
            (Join-Path $repoRoot 'addons\Code\Addons\lifepunch\bitcoinmining\LpBitcoinTerminalPanel.razor')
            (Join-Path $repoRoot 'addons\Code\Addons\lifepunch\bitcoinmining\LpUiMenuLayout.scss')
        )

        foreach ($file in $files) {
            if (Test-Path -LiteralPath $file) {
                Start-Process -FilePath $editor -ArgumentList @('-g', $file)
            }
        }
        break
    }
    'StartSboxEditor' {
        Invoke-RepoScript -Name 'Start-SboxDxrpEditor.ps1'
        break
    }
    'SyncAddons' {
        Invoke-RepoScript -Name 'Sync-LifePunchAddonsToDxrp.ps1' -Arguments @('-Addon', 'lpbitcoin,adminmenu')
        break
    }
    'OpenDxrpPortalChrome' {
        $url = 'https://dxrp.net/portal'
        $chrome = Get-ChromePath
        if ($chrome) {
            Start-Process -FilePath $chrome -ArgumentList @('--new-tab', $url)
        }
        else {
            throw 'Chrome not found. Install Chrome or update Get-ChromePath candidates.'
        }
        break
    }
    'McpHealth' {
        $checks = @(
            @{ Name = 'sbox-editor'; Url = 'http://127.0.0.1:9090/sbox-mcp'; OpenAi = $false }
            @{ Name = 'jtc'; Url = 'http://localhost:29015/mcp'; OpenAi = $false }
            @{ Name = 'cornerman-lm'; Url = 'http://192.168.1.229:1234/v1/models'; OpenAi = $true }
        )

        foreach ($check in $checks) {
            $ok = Test-McpEndpoint -Url $check.Url -OpenAiModels:([bool]$check.OpenAi)
            if ($ok) {
                Write-Host ("OK   {0}  {1}" -f $check.Name, $check.Url) -ForegroundColor Green
            }
            else {
                Write-Host ("FAIL {0}  {1}" -f $check.Name, $check.Url) -ForegroundColor Red
            }
        }
        break
    }
    'GitStatus' {
        Push-Location $repoRoot
        try {
            git --no-pager status --short --branch
            git --no-pager diff --staged --stat
        }
        finally {
            Pop-Location
        }
        break
    }
    'GitPullRebase' {
        Push-Location $repoRoot
        try {
            git pull --rebase
        }
        finally {
            Pop-Location
        }
        break
    }
    'CvlObservability' {
        Invoke-RepoScript -Name 'Get-VengeanceHealthProbe.ps1' -Arguments @('-Pretty')
        Invoke-RepoScript -Name 'Get-CvlConnectivityStatus.ps1' -Arguments @('-Pretty')
        break
    }
    'StartLifePunchDay' {
        Invoke-RepoScript -Name 'Start-LifePunchDay.ps1'
        break
    }
    'CvlConnectivity' {
        Invoke-RepoScript -Name 'Get-CvlConnectivityStatus.ps1' -Arguments @('-Pretty')
        break
    }
    'PreLaunchCheckup' {
        Invoke-RepoScript -Name 'Test-PreLaunchCheckup.ps1' -Arguments @('-Fix')
        break
    }
    'OpenCursor' {
        $cursor = 'C:\Users\jared\AppData\Local\Programs\cursor\Cursor.exe'
        if (-not (Test-Path -LiteralPath $cursor)) {
            $cursorCmd = Get-Command cursor -ErrorAction SilentlyContinue
            if ($cursorCmd) { $cursor = $cursorCmd.Source }
        }
        if (Test-Path -LiteralPath $cursor) {
            Start-Process -FilePath $cursor -ArgumentList @($monoRoot)
        }
        else {
            throw 'Cursor executable not found. Update the OpenCursor case in Invoke-LifePunchDeckAction.ps1.'
        }
        break
    }
    'ValidateWorkspace' {
        $workspaceValidator = Join-Path $monoRoot 'scripts\validate-workspace.ps1'
        if (Test-Path -LiteralPath $workspaceValidator) {
            & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $workspaceValidator
        }
        else {
            Write-Host ("SKIP  missing {0}" -f $workspaceValidator) -ForegroundColor Yellow
        }

        $layoutValidator = Join-Path $monoRoot 'lifepunchaddons\scripts\validate-layout.ps1'
        if (Test-Path -LiteralPath $layoutValidator) {
            & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $layoutValidator
        }
        else {
            Write-Host ("SKIP  missing {0}" -f $layoutValidator) -ForegroundColor Yellow
        }
        break
    }
}
