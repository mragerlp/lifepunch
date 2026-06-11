# Publish staging dry-run — missing `_c` (2026-06-11)

**Rule:** Dedicated server does not compile — publish tree must include `*_c` for every vmdl/prefab referenced in code.

**Staging command (when ready):**

```powershell
cd lifepunch\addons\scripts
.\prepare-publish.ps1 -Addon hackerjob
.\prepare-publish.ps1 -Addon bitcoinmining
.\prepare-publish.ps1 -Addon governmentdatacenter
```

Inspect: `lifepunch/addons/.dxrp-publish/upload-<ident>/`

---

## hackerjob — would FAIL publish today

| Resource | Repo | `_c` in repo | Staging impact |
|----------|------|--------------|----------------|
| `hacker-terminal.vmdl` | ✅ | ❌ | invisible / fallback mesh on DS |
| `advanced-hacker-terminal.vmdl` | ✅ | ❌ | same |
| `server-rack.vmdl` | ✅ | ❌ | same |
| `hacker-terminal.prefab` | ✅ | ❌ | entity won't mount |
| `advanced-hacker-terminal.prefab` | ✅ | ❌ | same |
| `server-rack.prefab` | ✅ | ❌ | same |
| `*.vmat` | ❌ | — | pink materials even if `_c` exists |
| `sounds/*.sound` | ❌ | — | silent terminals (OK for Phase 1) |

**Unblock:** ModelDoc compile all 3 vmdls + 3 prefabs; sync `_c` back to repo.

---

## bitcoinmining — PARTIAL publish

| Resource | `_c` | Notes |
|----------|------|-------|
| `gpu-rack.vmdl` | ✅ | shippable |
| `gpu-rack-stacked.vmdl` | ✅ | shippable |
| `bitcoin-terminal.vmdl` | ✅ | legacy |
| `bitcoin-miner.vmdl` | ❌ | **hub blocked** |
| `bitcoin-miner.prefab` | partial | check after hub compile |
| `gpu-rack.prefab` | ✅ | |
| `large-gpu-rack.prefab` | ✅ | |
| Sounds | ❌ | README only — exclude `.wav` until intake |

**Unblock:** hub ModelDoc + owner sounds intake before Class 9 ship.

---

## governmentdatacenter — would FAIL (empty)

| Resource | Status |
|----------|--------|
| All vmdl/prefab | **missing** |
| Code-only | `GovernmentTaxMiner.cs` ships but no world entity |

**Unblock:** intake + Red scaffold + ModelDoc.

---

## DevSpawn stripping

`prepare-publish.ps1` should exclude:

- `BitcoinMiningDevSpawn.cs` paths (bitcoinmining)
- Hacker dev commands remain in code — confirm publish script strips `HackerDevSpawn` before portal (TECH_DEBT / playtest docs).

---

## Owner one-liner after ModelDoc session

```text
Compiled: server-rack + hacker-terminal + advanced-hacker-terminal _c — ready for prepare-publish dry-run
```
