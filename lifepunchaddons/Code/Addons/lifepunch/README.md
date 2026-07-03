# LifePunch code in DXRP — what belongs here

| Path | Purpose |
|------|---------|
| `bitcoinmining/` | **Active C# + Razor** — hub, terminal, racks, economy, UI hosts |
| `_dev/` | Dev ConCmd playtest helpers |
| `LifePunch*.cs` / `*.scss` at this root | **Shared** across cyber entities (menu gate, ground contact, UI shell) |
| `lifepunchulx/` | ULX admin menu (when mounted) |

**Not here:**

| Path | Action |
|------|--------|
| `lpbitcoin/` under **Code** | **Stale** — delete on sync; hub **assets** live under `Assets/addons/lifepunch/lpbitcoin/` |
| `lifepunch._quarantine/` | Purged each sync — reference only in monorepo |

**Hub prefab / vmdl:** `Assets/addons/lifepunch/lpbitcoin/bitcoinhub/assets/` — see `NAV.md` there.
