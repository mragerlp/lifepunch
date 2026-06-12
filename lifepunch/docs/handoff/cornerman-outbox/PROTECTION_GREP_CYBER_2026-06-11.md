# Protection grep — cyber addons (2026-06-11)

**Policy:** LIFEPUNCH identity present in ship code; **zero** forbidden third-party strings in repo docs/code grep paths.

## Identity grep (must have hits)

```powershell
rg -i "LIFEPUNCH|lifepunch\.co" `
  lifepunch/addons/Code/Addons/lifepunch/hackerjob `
  lifepunch/addons/Code/Addons/lifepunch/bitcoinmining `
  lifepunch/addons/Code/Addons/lifepunch/governmentdatacenter `
  --glob "*.{cs,razor,scss}"
```

| Result | Status |
|--------|--------|
| **38 files** with LIFEPUNCH / lifepunch.co in preamble or About | **PASS** |

## Vocabulary gate (agents)

LIFEPUNCH canon names only: **bitcoinmining**, **hashd**, **GPU racks**, **Bitcoin Miner hub**.  
Do **not** re-introduce legacy third-party miner/admin CLI names in greps, rules, docs, or comments.

```powershell
# Study archives must stay absent (gitignored path — never commit)
Get-ChildItem reference -Recurse -Directory -Filter 'third-party-bitcoin-mining-study' -ErrorAction SilentlyContinue
# expect zero directories in working tree
```

## Cloud path grep (ship assets)

```powershell
rg -i "cloud\.facepunch|packages\.facepunch" `
  lifepunch/addons/Assets/addons/lifepunch/hackerjob `
  lifepunch/addons/Assets/addons/lifepunch/bitcoinmining `
  lifepunch/addons/Assets/addons/lifepunch/governmentdatacenter
```

Run on Green box after pull — expect **zero** hits.

## Checklists

- `briefs/BITCOINMINING_PROTECTION_CHECKLIST.md`
- `briefs/HACKER_JOB_PROTECTION_CHECKLIST.md`
- `BITCOINMINING_IP_DOCTRINE.md` §6

**Portal:** lead with **LIFEPUNCH™** on all three addon listings (`addons.json`).
