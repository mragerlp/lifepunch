# lpbitcoin — Bitcoin mining package (staging)

**Package slug:** `lifepunchbitcoin` · **Repo ident (DXRP playtest):** `bitcoinmining`

**Publish law:** `addons/docs/DXRP_ADDON_PUBLISH_DOCTRINE.md` — folder name = entity slug; PLACEHOLDER hands-off.

## Entity slots

| Folder | Entity slug | Hub mesh (Phase A) |
|--------|-------------|-------------------|
| `bitcoinhub/` | `bitcoinhub` | Steam Machine (promote from dev `bitcoin-miner` when signed off) |
| `hashdterminal/` | `hashdterminal` | `hashd-terminal.vmdl` |
| `gpurack/` | `gpurack` | `gpu-rack.vmdl` |
| `advancedgpurack/` | `advancedgpurack` | `gpu-rack-stacked.vmdl` |

Each entity folder:

```text
bitcoinhub/
  assets/source|textures|models|entities|sounds|ui/
  code/components|ui|docs/   + manifest.json (legacy file map)
  audit/manifest.json
```

See `addons/docs/PACKAGE_STAGING_LAYOUT.md`.
