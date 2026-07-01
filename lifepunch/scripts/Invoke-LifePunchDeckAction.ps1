[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet(
        'OpenRepo',
        'OpenLpBitcoinFiles',
        'StartSboxEditor',
        'SyncAddons',
        'McpHealth',
        'GitStatus',
        'GitPullRebase',
        'CvlObservability'
    )]
    [string] $Action
)

$ErrorActionPreference = 'Stop'
$scriptsRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$repoRoot = (Resolve-Path (Join-Path $scriptsRoot '..')).Path

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
        $codeCmd = Get-Command code -ErrorAction SilentlyContinue
        if (-not $codeCmd) {
            throw 'VS Code CLI (code) is not on PATH. Run "Shell Command: Install code command in PATH" from VS Code once.'
        }

        $files = @(
            (Join-Path $repoRoot 'addons\Code\Addons\lifepunch\lpbitcoin\bitcoinhub\code\ui\LpHashdPanel.razor')
            (Join-Path $repoRoot 'addons\Code\Addons\lifepunch\lpbitcoin\bitcoinhub\code\ui\LpHashdPanel.razor.scss')
            (Join-Path $repoRoot 'addons\Code\Addons\lifepunch\bitcoinmining\LpBitcoinTerminalPanel.razor')
            (Join-Path $repoRoot 'addons\Code\Addons\lifepunch\bitcoinmining\LpUiMenuLayout.scss')
        )

        foreach ($file in $files) {
            if (Test-Path -LiteralPath $file) {
                Start-Process $codeCmd.Source -ArgumentList @('-g', $file)
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
    'McpHealth' {
        $checks = @(
            @{ Name = 'sbox-editor'; Url = 'http://127.0.0.1:9090/sbox-mcp'; OpenAi = $false }
            @{ Name = 'jtc'; Url = 'http://127.0.0.1:29015/mcp'; OpenAi = $false }
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
}
