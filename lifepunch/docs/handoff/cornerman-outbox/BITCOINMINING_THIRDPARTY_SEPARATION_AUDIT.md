# Third-party bitcoin miner study vs LIFEPUNCH Bitcoin Miner — separation audit

**Issued:** 2026-06-13 · **Lane:** Tier-3 distill prep · **Eyes:** covered (file diff only)  
**Study source (never repo):** `C:\lifepunch\reference-intake\bitcoinmining\third-party-bitminer-study\` on Green  
**LifePunch ship tree:** `lifepunchaddons/{Code,Assets}/addons/lifepunch/bitcoinmining/`

---

## Verdict: **CLEAR** — ship LifePunch addon; no separation rework required

Continue playtest/publish prep. Study material stays **outside** the monorepo under `reference-intake/`.

---

## 1. File inventory (27 files staged on Green)

| | Third-party study | LifePunch (ship tree) |
|---|-------------------|------------------------|
| **Code** | 0 `.cs`; 3 Razor UI files (study terminal) | **14** `.cs` + `HashdTerminal.razor` + `.scss` — proprietary headers |
| **Entities** | 1 monolithic rig prefab | **4** prefabs: hub, terminal, small rack, large rack |
| **Models** | Single combined rig mesh | Ophion hub, GPU Farm racks, bitcoin-terminal |
| **Sounds** | 4 roles + third-party WAV binaries | CC0 intake under `sounds/bitcoinminer/` (owner WAVs + `_c`) |

---

## 2. UI / architecture — materially different

| Pattern | Study package | LifePunch canon |
|---------|---------------|-----------------|
| Terminal brand | Third-party OS + shell prompt fiction | **HASHD** · `rig0>` · amber LifePunch fiction |
| Namespace | Dxura game entities | `LifePunch.DXRP.Addons.BitcoinMining` · `HashdTerminal` |
| Entity binding | Single-rig component | `BitcoinMinerHubEntity` + `GpuRackEntity` + registries |
| Hub model | Combined rig mesh | Separate **Ophion hub** + rack hardware |
| Security | None in study UI sample | **4-digit PIN gate**, hub wallet, encryption tiers |
| UI chrome | Basic title bar + close | Material icons, panel sizes, ghost telemetry, upgrade rail |

Study Razor is a **genre reference** (terminal lines, command shell shape) — not copy-paste of LifePunch UI markup, namespace, or hub/rack split.

**Credits command (study only):** study terminal includes a `credits` command naming third-party authors. LifePunch **`about`** prints LIFEPUNCH™ proprietary notice only — never ship third-party credits.

**Economy:** LifePunch BTC sell is **`$1000`/BTC** (`GpuRackEntity.BitcoinValue`). Upgrade ladders remain per-rack cash costs in `GpuRackEntity` — retune before ship if desired.

---

## 3. Ship-tree leak scan (LifePunch monorepo)

```text
rg -i "forbidden-third-party-tokens" lifepunchaddons --glob "**/bitcoinmining/**"  → 0 matches
```

No third-party slug strings in the LifePunch ship tree. `addons.json` lists four content rows under `lifepunch.bitcoinmining`.

---

## 4. Sound policy

Study package ships **third-party** WAV binaries. LifePunch ships **different** CC0-recorded files. Role names overlap (`server_hum`, `keyboard`, …) — genre convention only.

---

## 5. Operator recommendation

1. **No IP rework** — finish playtest (`BITCOINMINING_PLAYTEST.md`), market row, remove `BitcoinMiningDevSpawn.cs` before publish.
2. **Never commit** `reference-intake/bitcoinmining/third-party-bitminer-study/` to git.
3. Re-audit only if full third-party **C#** bundle surfaces later.

**Ping line:** `OK third-party separation CLEAR — outbox/BITCOINMINING_THIRDPARTY_SEPARATION_AUDIT.md`
