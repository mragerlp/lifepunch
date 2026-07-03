# Package naming sync — all CVL nodes (June 2026)

**Git:** after `git pull --rebase`, read `lifepunchaddons/docs/PACKAGE_NAMING_STANDARD.md` and `config/packages.json`.

---

## Law (one line)

**packageSlug** = public branch name (`lifepunchbitcoin`, …). **s&box** = `lifepunch.{suffix}`. **repo folder** = legacy ident until migration (`bitcoinmining`, …).

---

## Public branch set

| packageSlug | s&box | repo folder |
|-------------|-------|-------------|
| lifepunchulx | lifepunch.ulx | adminmenu |
| lifepunchbitcoin | lifepunch.bitcoin | bitcoinmining |
| lifepunchhacker | lifepunch.hacker | hackerjob |
| lifepunchbanker | lifepunch.banker | bankerjob |
| lifepunchswat | lifepunch.swat | *(reserved)* |
| lifepunchak47 | lifepunch.ak47 | ak47 |
| lifepunchdrugprocessing | lifepunch.drugprocessing | advanceddrugprocessing |
| lifepunchdrugdrops | lifepunch.drugdrops | additionaldroplocations |
| lifepunchdeserteagle | lifepunch.deserteagle | deagle |
| lifepunchdoublebarreledshotgun | lifepunch.doublebarreledshotgun | doublebarrelshotgun |

---

## Active dev (unchanged scope)

- **Publish now:** `lifepunchulx` only
- **Build now:** `lifepunchbitcoin` Ophion P0 — start doc: `addons/docs/LIFEPUNCH_BITCOIN_START.md`
- **Quarantine:** everything else frozen per `portfolio.json`

---

## Per node

| Node | Action |
|------|--------|
| **VENGEANCE** | Integrate lane; s&box editor; `Start-SboxDxrpEditor.ps1 -SyncAddon bitcoinmining` |
| **Cornerman** | `git pull --rebase`; grounding only — no bitcoin code commits |
| **lifepunchnet** | `git pull --rebase` on `lifepunch-rdp-server` if docs referenced |
| **ChatGPT LIFEPUNCH™** | Use **packageSlug** in briefs, not legacy ident |

Sync paste also updated: `AGENT_SYNC_BROADCAST.txt`
