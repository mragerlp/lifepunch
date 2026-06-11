# Asset intake — LIFEPUNCH Cyber Ecosystem

Drop packs on VENGEANCE; tell Red the folder path. Scripts will mirror into `LPaddons` oneliner entity folders.

---

## Already in repo

| Pack | Path | Notes |
|------|------|-------|
| GPU racks | `models/.../gpu-rack/` | Anim FBX exists — wire `power_on`/`power_off` |
| Ophion hub | `entities/bitcoinminer/source/Ophion.fbx` | Needs ModelDoc + hub anim |
| Hacker terminal | `hacker-terminal.fbx` | Green Cornerman CRT |
| Advanced terminal | shares hacker mesh | Red UI skin |
| Server rack | `server-rack.dae` + PBR textures | Basic rack — cornerman upgrades |
| Advanced server rack | `advanced-server-rack.obj` | Vengeance-tier rack — higher upgrade caps |
| Cornerman UI | `ui/cornerman/*.png` | Optional CRT chrome beyond green SCSS |
| Vengeance UI | `ui/vengeance/*.png` | Red tier console art |
| Gov terminal | `police-terminal.obj` + lifepunchnet PNGs | `governmentdatacenter` — unblocks govdb scan |

---

## Need from owner (drop in Downloads, then ping Red)

### Bitcoin mining (`bitcoinmining`)

| # | Asset | Ideal format | Drop folder |
|---|-------|--------------|-------------|
| 1 | **Bitcoin Miner hub** (Ophion) | FBX + textures + **anim list** | `Downloads\bitcoinminer` ✅ partial |
| 2 | Hub **power on/off** clips | Named in FBX or separate | same zip |
| 3 | **Sounds** (you supply) | WAV/MP3 | `Downloads\bitcoinminer-sounds\` |

Sound order: `startup` → `fan_loop` → `fan_down` → `metal_hit` → `smoke` → `explode`

### Hacker job (`hackerjob`)

| # | Asset | Notes |
|---|-------|-------|
| 4 | **Cornerman console art** | ✅ `Intake-HackerCornermanUi.ps1` |
| 5 | **Vengeance console art** | ✅ `Intake-AdvancedHackerTerminal.ps1` |
| 6 | **Advanced server rack** | ✅ `Intake-AdvancedServerRack.ps1` — ModelDoc TODO |
| 7 | In-world **job props** | If job is not CRT-first — laptops, desks, etc. |

### Government (`governmentdatacenter`) — **drop `governmentdatacenter`**

| # | Asset | Notes |
|---|-------|-------|
| 8 | **Government datacenter** landmark | Large map prop + blue miner cluster |
| 9 | **Government terminal** | ✅ `Intake-GovernmentTerminal.ps1` — police-terminal.obj + ui/lifepunchnet |
| 10 | Tax miner visual | Blue-tinted rack OR unique mesh |
| 11 | Optional **datacenter interior** | RP landmark |

**Owner drop folder (canonical):** `OneDrive\Desktop\governmentdatacenter\` with `source/` + `textures/`

---

## After drop — Red runs

```powershell
Intake-BitcoinMinerHub.ps1 -SourceRoot "$env:USERPROFILE\Downloads\bitcoinminer"
Intake-BitcoinMinerSounds.ps1 -SourceRoot "$env:USERPROFILE\Downloads\bitcoinminer-sounds"
Intake-GovernmentDatacenter.ps1   # landmark mesh — Desktop\governmentdatacenter
Intake-GovernmentTerminal.ps1     # police CRT pack — addon stuff\governmentterminal
Intake-HackerServerRack.ps1       # server-rack DAE + textures
Intake-AdvancedServerRack.ps1
Intake-HackerCornermanUi.ps1
```

---

## Folder convention (LPaddons oneliners)

```text
entities/bitcoinminer/     # hub prefab + source
entities/gpurack/
entities/largegpurack/
entities/hackerterminal/   # future rename from hacker-terminal
entities/serverrack/
entities/governmentdatacenter/   # landmark
entities/governmentterminal/
```

Portal **slugs** may stay dashed (`bitcoin-miner`); disk folders = oneliners.

---

## Owner blueprint (incoming)

When the blueprint lands, these fields let Red intake in one pass:

| Field | Example |
|-------|---------|
| Pack folders | `Downloads\bitcoinminer-sounds`, `Desktop\governmentdatacenter` |
| Hub anim names | `power_on`, `power_off` in Ophion FBX |
| Material slot list | Ophion mesh → texture folder mapping |
| Gov landmark scale | meters or “match server-rack height” |
| Terminal skins | cornerman / vengeance / hashd / lifepunchnet — which are new art vs SCSS-only |
| Sound filenames | `hub-startup.wav`, `hub-fan-loop.wav`, … |

Code scaffold already wired: `BitcoinMinerHubEntity`, encryption catalog, hub registry, `lp_spawn_bitcoin_miner_hub`.

## Ping format

```text
Assets ready: governmentdatacenter at Desktop\governmentdatacenter
Blueprint: <paste or attach path>
```

Red will intake, update `ASSET_INVENTORY.md`, ModelDoc compile list, and wire sounds/anims.
