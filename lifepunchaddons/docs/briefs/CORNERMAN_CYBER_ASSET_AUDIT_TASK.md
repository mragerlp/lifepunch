# Cornerman — Cyber ecosystem asset audit (P0b)

**Issued:** 2026-06-11 · **Lane:** Green distill · **Warm:** `WarmDistill`  
**Owner:** on legal — Red pre-seeded `cornerman-outbox/*_2026-06-11.md`; Green validates + extends.

## Scope

| Addon | Audit |
|-------|--------|
| `hackerjob` | Intake vs ship tree · ModelDoc blockers · Phase 1 vs 2 |
| `bitcoinmining` | `_c` parity · hub compile · sounds pre-intake |
| `governmentdatacenter` | empty assets · code-only scaffold |

## Deliverables (outbox)

1. `CYBER_ASSET_AUDIT_2026-06-11.md` — intaken / missing / owner / Red / editor
2. `MODELDOC_CHECKLIST_CYBER_2026-06-11.md` — per-vmdl steps for owner return
3. `PROTECTION_GREP_CYBER_2026-06-11.md` — identity grep results (no forbidden strings)
4. `PUBLISH_STAGING_DRYRUN_2026-06-11.md` — missing `_c` until ModelDoc

Red draft lives in `lifepunch/docs/handoff/cornerman-outbox/` — diff against repo after `git pull` and append Green notes only.

## Commands (Green box)

```powershell
cd C:\Users\jared\Projects\lifepunchdxrp
git pull --rebase origin main

# Protection (identity + study-tree absent — no legacy third-party name greps)
rg -i "LIFEPUNCH|lifepunch\.co" lifepunchaddons/Code/Addons/lifepunch/hackerjob lifepunchaddons/Code/Addons/lifepunch/bitcoinmining lifepunchaddons/Code/Addons/lifepunch/governmentdatacenter --glob "*.{cs,razor,scss}"
Get-ChildItem reference -Recurse -Directory -Filter 'third-party-bitcoin-mining-study' -ErrorAction SilentlyContinue

# Compile inventory
Get-ChildItem lifepunchaddons\Assets\addons\lifepunch\hackerjob,bitcoinmining,governmentdatacenter -Recurse -Include *.vmdl,*.vmdl_c,*.prefab,*.prefab_c -ErrorAction SilentlyContinue
```

## Ping Red (one line)

```text
OK cornerman cyber-asset-audit @<sha> — hacker BLOCKED _c · bitcoin PARTIAL · gov EMPTY
```
