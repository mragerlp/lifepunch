# lpbitcoin — Bitcoin mining package (staging)

**Package slug:** `lifepunchbitcoin` · **Repo ident (ship today):** `bitcoinmining`

## Entity slots

| Folder | Ship entity | ModelDoc |
|--------|-------------|----------|
| `bitcoinhub/` | bitcoin-miner | `assets/models/bitcoin-hub.vmdl` |
| `hashdterminal/` | bitcoin-terminal | `assets/models/hashd-terminal.vmdl` |
| `gpurack/` | gpu-rack | `assets/models/gpu-rack.vmdl` |
| `advancedgpurack/` | advanced-gpu-rack | `assets/models/gpu-rack-stacked.vmdl` |

Each entity folder:

```text
bitcoinhub/
  assets/source|textures|models|entities|sounds|ui/
  code/components|ui|docs/   + manifest.json (legacy file map)
  audit/manifest.json
```

See `addons/docs/PACKAGE_STAGING_LAYOUT.md`.
