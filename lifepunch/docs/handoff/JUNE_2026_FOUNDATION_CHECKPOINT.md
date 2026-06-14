# Foundation checkpoint — June 2026 (all nodes pull this)

**Git anchor:** push to `github.com/mragerlp/lifepunch` `main` after this doc lands.  
**Paste to Cornerman / lifepunchnet:** `AGENT_SYNC_BROADCAST.txt` after pull.

---

## What changed (recovery brief)

| Topic | Canon |
|-------|-------|
| **Two-repo model** | **Core** = law + WIP + quarantine. **Publish** = `lifepunch-published` export only. `PUBLISH_REPO_LANE.md` |
| **Git checkpoints** | Agent **recommends** commit scope; Bloodwave **approves**. `GIT_CHECKPOINTS.md` |
| **Quarantine** | Active dev: `adminmenu` → **lifepunchulx**, `bitcoinmining` → **lifepunchbitcoin**. Everything else frozen — `portfolio.json` + `QUARANTINE_REGISTER.md` |
| **Package names** | Public branches = **packageSlug** in `addons/config/packages.json` — `PACKAGE_NAMING_STANDARD.md` |
| **Publish-ready now** | **`lifepunchulx`** (`lifepunch.ulx`) — LifePunch servers; not for resale |
| **Bitcoin** | **lifepunchbitcoin** (`lifepunch.bitcoin`) — Ophion P0; start `addons/docs/LIFEPUNCH_BITCOIN_START.md` — NOT publish export until visual sign-off |
| **Ideation** | ChatGPT Step 1 → CURSOR BRIEF → Cursor on VENGEANCE. `WORKFLOW_IDEATION_FIRST.md` |
| **Export** | `Export-LifepunchPublishLane.ps1` reads `publishReadyAddons` |

---

## Per-node actions

### VENGEANCE (primary)
```powershell
cd C:\Users\jared\Projects\lifepunchaddons
git pull --rebase
# Already pushed by integrator — verify: git log -1 --oneline
```

### Cornerman (read-only clone)
```powershell
cd <cornerman-clone>
git fetch
git pull --rebase
# If behind and cannot push: patch-handoff to VENGEANCE (LOCAL_AI_WORKSTATION.md §7c)
```
Read: Block D in `AGENT_PROMPT.md` · dual MCP restore: `Restore-CornermanDualStack.ps1`

### lifepunchnet (RDP server lane)
```powershell
cd C:\lifepunch\lifepunch-rdp-server
git fetch
git pull --rebase
```
Read: Block C in `AGENT_PROMPT.md`

### shottaWEB (website lane)
GitLab `lifepunch-website` — pull after monorepo export if foundation docs referenced.

---

## Publish repo (separate remote)

| Item | Value |
|------|-------|
| Display | **LIFEPUNCH™ Published Addons** |
| GitHub | `mragerlp/lifepunch-published` (private) |
| Local | `C:\Users\jared\Projects\lifepunch-published` |
| Contents | `adminmenu` only until bitcoin Ophion sign-off |

Re-export:
```powershell
powershell -File lifepunch\scripts\Export-LifepunchPublishLane.ps1 -Target C:\Users\jared\Projects\lifepunch-published
```

---

## Next build lane (after infra ChatGPT brief)

1. **Tonight optional:** ChatGPT hardware/efficiency audit — `handoff/CHATGPT_HARDWARE_EFFICIENCY_PASTE.txt`
2. **Then:** Bitcoin Ophion P0 — `addons/docs/LIFEPUNCH_BITCOIN_START.md` + `briefs/BITCOIN_OPHION_CURSOR_BRIEF.md`
3. **Do not** extend quarantined idents without owner promote + ChatGPT brief

---

## You are not paranoid

Recovery = **pushed commits + onboarding docs + this handoff**. New agents start at `AGENT_PROMPT.md` Block 0 + `AGENT_ONBOARDING.md` Tonight table — not chat memory.
