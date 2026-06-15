<#
.SYNOPSIS
  Disable chomnr MCP tools whose Cursor-qualified name exceeds 60 characters.

.DESCRIPTION
  Cursor filters MCP tools when len("sbox-editor:" + toolName) > 60.
  chomnr stores per-tool overrides in s&box config tools.json (SboxMcp.ToolOverrides).

  Disables known offenders (moviemaker motion-edit imports) and any extra names
  passed via -AlsoDisable. Safe to re-run (idempotent).

.EXAMPLE
  powershell -File lifepunch\scripts\Fix-SboxEditorMcpCursorToolNames.ps1
  powershell -File lifepunch\scripts\Fix-SboxEditorMcpCursorToolNames.ps1 -ServerName sbox-editor
#>
[CmdletBinding()]
param(
    [string] $ToolsJsonPath = 'D:\Steam\steamapps\common\sbox\config\tools.json',
    [string] $ServerName = 'sbox-editor',
    [int] $MaxQualifiedLength = 60,
    [int] $EditorMcpPort = 9090,
    [switch] $ProbeEditorMcp,
    [string[]] $AlsoDisable = @()
)

$ErrorActionPreference = 'Stop'

$prefixLen = $ServerName.Length + 1

# Known imported moviemaker shortcuts that trip Cursor's name limit.
$knownLong = @(
    'lib_motioneditmode_shortcut_setinterpolationlinear'
    'lib_motioneditmode_shortcut_setinterpolationinout'
)

function Get-OverrideMap([string]$raw) {
    $map = [ordered]@{}
    if ([string]::IsNullOrWhiteSpace( $raw )) { return $map }
    foreach ($pair in $raw.Split( ';', [StringSplitOptions]::RemoveEmptyEntries )) {
        $parts = $pair.Split( '=', 2 )
        if ($parts.Length -eq 2) {
            $map[$parts[0].Trim()] = $parts[1].Trim() -eq '1'
        }
    }
    return $map
}

function Format-OverrideMap([System.Collections.IDictionary]$map) {
    ($map.GetEnumerator() | ForEach-Object { "{0}={1}" -f $_.Key, ($(if ($_.Value) { 1 } else { 0 })) }) -join ';'
}

if (-not (Test-Path -LiteralPath $ToolsJsonPath)) {
    throw "Missing tools.json: $ToolsJsonPath"
}

$doc = Get-Content -LiteralPath $ToolsJsonPath -Raw | ConvertFrom-Json
if (-not $doc.'SboxMcp.ToolOverrides') {
    $doc | Add-Member -NotePropertyName 'SboxMcp.ToolOverrides' -NotePropertyValue ([pscustomobject]@{
            Value    = '""'
            Timeout  = 0
            DeleteAt = 0
        })
}

$currentRaw = [string]$doc.'SboxMcp.ToolOverrides'.Value
$currentRaw = $currentRaw.Trim( '"' )
$overrides = Get-OverrideMap $currentRaw

$toDisable = [System.Collections.Generic.HashSet[string]]::new( [StringComparer]::OrdinalIgnoreCase )
foreach ($name in ($knownLong + $AlsoDisable)) {
    if ($name) { [void]$toDisable.Add( $name ) }
}

if ($ProbeEditorMcp) {
    $url = "http://127.0.0.1:$EditorMcpPort/sbox-mcp"
    try {
        $listBody = '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}'
        $resp = Invoke-WebRequest -Uri $url -Method Post -ContentType 'application/json' -Body $listBody -TimeoutSec 8 -UseBasicParsing
        $parsed = $resp.Content | ConvertFrom-Json
        if ($parsed.result.tools) {
            foreach ($t in $parsed.result.tools) {
                $toolName = [string]$t.name
                if (($prefixLen + $toolName.Length) -gt $MaxQualifiedLength) {
                    [void]$toDisable.Add( $toolName )
                }
            }
        }
    }
    catch {
        Write-Host "  WARN tools/list probe failed (editor MCP offline?): $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Also disable any existing override keys that already exceed the limit.
foreach ($key in @($overrides.Keys)) {
    if (($prefixLen + $key.Length) -gt $MaxQualifiedLength) {
        [void]$toDisable.Add( $key )
    }
}

$changed = 0
foreach ($name in $toDisable) {
    $qualified = "$ServerName`:$name"
    $len = $qualified.Length
    if ($len -le $MaxQualifiedLength) { continue }
    if ($overrides.Contains( $name ) -and $overrides[$name] -eq $true) { continue }
    $overrides[$name] = $true
    $changed++
    Write-Host "  disable $name ($len chars qualified)" -ForegroundColor Yellow
}

if ($changed -eq 0) {
    Write-Host 'OK no new Cursor MCP name fixes needed.' -ForegroundColor Green
    exit 0
}

$newValue = Format-OverrideMap $overrides
$doc.'SboxMcp.ToolOverrides'.Value = "`"$newValue`""
$doc.'SboxMcp.ToolOverrides'.Timeout = [int][double]::Parse( (Get-Date).AddYears( 2 ).ToUniversalTime().Subtract( [datetime]'1970-01-01' ).TotalSeconds )

$utf8 = New-Object System.Text.UTF8Encoding $false
[IO.File]::WriteAllText( $ToolsJsonPath, ($doc | ConvertTo-Json -Depth 20), $utf8 )

Write-Host "OK updated SboxMcp.ToolOverrides ($changed tool(s))." -ForegroundColor Green
Write-Host '  Restart Cursor (Reload Window) so MCP re-lists tools without the warning.' -ForegroundColor Cyan
