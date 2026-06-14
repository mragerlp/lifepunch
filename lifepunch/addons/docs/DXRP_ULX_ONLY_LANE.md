# DXRP editor — ULX-only lane

**June 2026** — Clean editor install for **lifepunchulx** only. Bitcoin greenfield and other addons stay in the monorepo; they do not mount in this DXRP tree until promoted.

---

## One command (VENGEANCE)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File lifepunch\scripts\Set-DxrpLifepunchUlxOnly.ps1
```

Then **restart the s&box editor** (rp.sbproj Resources changed).

---

## Result

| Path | Contents |
|------|----------|
| `Assets/addons/lifepunch/lifepunchulx/` | ULX only (code-only today; no assets) |
| `Code/Addons/lifepunch/lifepunchulx/` | Synced from repo `adminmenu` |
| `Assets/addons/lifepunch._quarantine/` | Former bitcoinmining, hackerjob, ak47, … |
| `Code/Addons/lifepunch._quarantine/` | Former code trees + `_dev` + shared root files |

**rp.sbproj Resources:** `addons/lifepunch/lifepunchulx/**` only (no other `addons/lifepunch/*` globs).

---

## Mapping

| packageSlug | repo ident | DXRP folder |
|-------------|------------|-------------|
| `lifepunchulx` | `adminmenu` | `lifepunchulx` |

Monorepo paths unchanged (`Code/Addons/lifepunch/adminmenu/`).

---

## Bitcoin / other addons later

When promoting `lifepunchbitcoin` or another package:

1. Extend `Sync-LifePunchAddonsToDxrp.ps1` with explicit `-Addon` list
2. Add resource glob to `rp.sbproj` via `Ensure-DxrpLifepunchResources.ps1`
3. Or restore one folder from `lifepunch._quarantine/`

Do **not** run `-SyncAllAddons` on the ULX lane without owner sign-off.

---

## Related

- `config/packages.json` — packageSlug law
- `Set-DxrpLifepunchUlxOnly.ps1` — quarantine + sync script
- `portfolio.json` — publish-ready: lifepunchulx
