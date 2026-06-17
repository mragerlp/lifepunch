# Sync workflow law - 2026-06-17

1. Never run `Sync-LifepunchDesktopToStaging.ps1` until Desktop entity has real assets OR vmdl work is committed.
2. Morning order on VENGEANCE: Desktop sync ├óΓÇáΓÇÖ ModelDoc in repo ├óΓÇáΓÇÖ `Set-DxrpLifepunchModelDocLane.ps1` ├óΓÇáΓÇÖ bridge recompile.
3. MIR hazard: placeholder Desktop dirs can wipe uncommitted repo vmdl files.
