<#
.SYNOPSIS
  Batch-compile LifePunch cyber assets via s&box bridge recompile_asset (run from agent with MCP).

  Agent: dot-source paths and call Compile-LifePunchAsset for each path after editor sync.
#>
$script:LifePunchCompileQueue = @(
    # hackerjob racks
    'addons/lifepunch/hackerjob/models/lifepunch/hackerjob/server-rack/materials/server-rack-trim.vmat'
    'addons/lifepunch/hackerjob/models/lifepunch/hackerjob/server-rack/materials/server-rack-glass.vmat'
    'addons/lifepunch/hackerjob/models/lifepunch/hackerjob/server-rack/server-rack.vmdl'
    'addons/lifepunch/hackerjob/models/lifepunch/hackerjob/advanced-server-rack/advanced-server-rack.vmdl'
    'addons/lifepunch/hackerjob/entities/server-rack/server-rack.prefab'
    'addons/lifepunch/hackerjob/entities/advanced-server-rack/advanced-server-rack.prefab'
    'addons/lifepunch/hackerjob/entities/hacker-terminal/hacker-terminal.prefab'
    # governmentdatacenter
    'addons/lifepunch/governmentdatacenter/models/lifepunch/governmentdatacenter/government-server-rack/materials/government-server-rack-trim.vmat'
    'addons/lifepunch/governmentdatacenter/models/lifepunch/governmentdatacenter/government-server-rack/materials/government-server-rack-glass.vmat'
    'addons/lifepunch/governmentdatacenter/models/lifepunch/governmentdatacenter/government-server-rack/government-server-rack.vmdl'
    'addons/lifepunch/governmentdatacenter/entities/government-server-rack/government-server-rack.prefab'
    'addons/lifepunch/governmentdatacenter/models/lifepunch/governmentdatacenter/police-terminal/materials/police-terminal-table.vmat'
    'addons/lifepunch/governmentdatacenter/models/lifepunch/governmentdatacenter/police-terminal/materials/police-terminal-hologram.vmat'
    'addons/lifepunch/governmentdatacenter/models/lifepunch/governmentdatacenter/police-terminal/police-terminal.vmdl'
    'addons/lifepunch/governmentdatacenter/entities/police-terminal/police-terminal.prefab'
    # bitcoinmining hub + racks
    'addons/lifepunch/bitcoinmining/models/lifepunch/bitcoinmining/bitcoin-miner/materials/bitcoin-miner-sm-body.vmat'
    'addons/lifepunch/bitcoinmining/models/lifepunch/bitcoinmining/bitcoin-miner/materials/bitcoin-miner-sm-details-one.vmat'
    'addons/lifepunch/bitcoinmining/models/lifepunch/bitcoinmining/bitcoin-miner/materials/bitcoin-miner-sm-details-two.vmat'
    'addons/lifepunch/bitcoinmining/models/lifepunch/bitcoinmining/bitcoin-miner/materials/bitcoin-miner-sm-panel.vmat'
    'addons/lifepunch/bitcoinmining/models/lifepunch/bitcoinmining/bitcoin-miner/materials/bitcoin-miner-sm-fence-led.vmat'
    'addons/lifepunch/bitcoinmining/models/lifepunch/bitcoinmining/bitcoin-miner/bitcoin-miner.vmdl'
    'addons/lifepunch/bitcoinmining/models/lifepunch/bitcoinmining/gpu-rack/materials/gpu-rack-cord.vmat'
    'addons/lifepunch/bitcoinmining/models/lifepunch/bitcoinmining/gpu-rack/materials/gpu-rack-psu.vmat'
    'addons/lifepunch/bitcoinmining/models/lifepunch/bitcoinmining/gpu-rack/materials/gpu-rack-rack.vmat'
    'addons/lifepunch/bitcoinmining/models/lifepunch/bitcoinmining/gpu-rack/materials/gpu-rack-motherboard.vmat'
    'addons/lifepunch/bitcoinmining/models/lifepunch/bitcoinmining/gpu-rack/materials/gpu-rack-gpu.vmat'
    'addons/lifepunch/bitcoinmining/models/lifepunch/bitcoinmining/gpu-rack/gpu-rack.vmdl'
    'addons/lifepunch/bitcoinmining/models/lifepunch/bitcoinmining/gpu-rack/gpu-rack-stacked.vmdl'
    # blackmarketdealer
    'addons/lifepunch/blackmarketdealer/models/lifepunch/blackmarketdealer/black-market-hub/materials/black-market-vault.vmat'
    'addons/lifepunch/blackmarketdealer/models/lifepunch/blackmarketdealer/black-market-hub/materials/black-market-bullion.vmat'
    'addons/lifepunch/blackmarketdealer/models/lifepunch/blackmarketdealer/black-market-hub/black-market-hub.vmdl'
)

Write-Host "Compile queue: $($script:LifePunchCompileQueue.Count) assets (invoke via MCP recompile_asset)"
