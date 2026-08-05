<#
.SYNOPSIS
  Assert the ratified native-7269 bridge contract through a fresh cavelux gateway.

.DESCRIPTION
  PRODUCER SPLIT: Assert-BridgeVersion.ps1 validates the standalone
  sbox-mcp-server / Claude Bridge file-IPC producer. This script validates the
  native 7269 HTTP producer mounted through cavelux. It does not synthesize or
  require standalone-only bridgeVersion, mcpServerVersion, or roundTripOk fields.

  A pass requires: the LIFEPUNCH/DXRP identity guard; connected/running/non-empty
  version/positive handlerCount from get_bridge_status; and a successful guarded
  editor_status result containing EngineVersion. The result-bearing call is the
  round-trip proof.

.OUTPUTS
  Exit 0 = BRIDGE-CONTRACT-OK with positive sensor values.
  Exit 1 = BRIDGE-CONTRACT-FAULT with every failed criterion.
#>
[CmdletBinding()]
param(
    [string] $GatewayLauncher = 'C:\cavelux\comms\cavelux-mcp-launch-branch.cmd',
    [string] $ClientPython = 'C:\Users\jared\Projects\cavelux\mcp\.venv\Scripts\python.exe'
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $GatewayLauncher -PathType Leaf)) {
    Write-Output "BRIDGE-CONTRACT-FAULT: gateway launcher absent: $GatewayLauncher"
    exit 1
}
if (-not (Test-Path -LiteralPath $ClientPython -PathType Leaf)) {
    Write-Output "BRIDGE-CONTRACT-FAULT: MCP client Python absent: $ClientPython"
    exit 1
}

$probe = @'
import asyncio
import json
import os
import sys

from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client


def text(result):
    return "\n".join(
        block.text for block in (getattr(result, "content", None) or [])
        if getattr(block, "text", None)
    )


async def main():
    launcher = sys.argv[1]
    params = StdioServerParameters(
        command=os.environ.get("COMSPEC", r"C:\Windows\System32\cmd.exe"),
        args=["/d", "/c", launcher],
        env=dict(os.environ),
    )
    async with stdio_client(params) as (read, write):
        async with ClientSession(read, write) as session:
            await session.initialize()

            identity_resource = await session.read_resource(
                "cavelux://upstream/sbox-native"
            )
            identity = json.loads(identity_resource.contents[0].text)

            status_result = await session.call_tool(
                "call_tool",
                {"arguments": {"name": "get_bridge_status", "arguments": {}}},
            )
            status = json.loads(text(status_result))

            round_trip = await session.call_tool("editor_status", {"arguments": {}})
            live = round_trip.structuredContent
            if live is None:
                live = json.loads(text(round_trip))

            print(json.dumps({
                "identity": identity,
                "status": status,
                "roundTrip": live,
                "roundTripIsError": bool(round_trip.isError),
            }, separators=(",", ":")))


asyncio.run(main())
'@

try {
    $env:CAVELUX_BRIDGE_CONTRACT_PROBE = $probe
    $json = & $ClientPython -c "import os; exec(os.environ['CAVELUX_BRIDGE_CONTRACT_PROBE'])" $GatewayLauncher
    if ($LASTEXITCODE -ne 0) {
        throw "cavelux probe exited $LASTEXITCODE"
    }
    $sensor = $json | ConvertFrom-Json
}
catch {
    Write-Output "BRIDGE-CONTRACT-FAULT: cavelux probe failed: $($_.Exception.Message)"
    exit 1
}
finally {
    Remove-Item Env:CAVELUX_BRIDGE_CONTRACT_PROBE -ErrorAction SilentlyContinue
}

$fail = @()
if ($sensor.identity.identity_ok -ne $true) {
    $fail += 'identity guard did not return identity_ok=true for lifepunch/DXRP.'
}
if ($sensor.status.connected -ne $true) { $fail += 'connected is not true.' }
if ($sensor.status.running -ne $true) { $fail += 'running is not true.' }
if ([string]::IsNullOrWhiteSpace([string] $sensor.status.version)) {
    $fail += 'native bridge version is absent.'
}
if ($null -eq $sensor.status.handlerCount -or [int64] $sensor.status.handlerCount -le 0) {
    $fail += 'handlerCount is absent or not greater than zero.'
}
if ($sensor.roundTripIsError -eq $true) { $fail += 'editor_status returned isError=true.' }
if ([string]::IsNullOrWhiteSpace([string] $sensor.roundTrip.EngineVersion)) {
    $fail += 'editor_status live payload has no EngineVersion.'
}

if ($fail.Count -gt 0) {
    Write-Output 'BRIDGE-CONTRACT-FAULT:'
    $fail | ForEach-Object { Write-Output "  - $_" }
    exit 1
}

Write-Output (
    "BRIDGE-CONTRACT-OK: identity_ok=true connected=true running=true " +
    "version='$($sensor.status.version)' handlerCount=$($sensor.status.handlerCount) " +
    "editor_status.EngineVersion='$($sensor.roundTrip.EngineVersion)'"
)
Write-Output 'ROUND-TRIP PROOF: guarded editor_status returned the live EngineVersion through cavelux.'
exit 0
