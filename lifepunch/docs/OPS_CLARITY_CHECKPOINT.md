# LifePunch — Operational clarity checkpoint

> **Checkpoint: June 2026.** Canon for how Bloodwave, every agent, and every node in the
> LifePunch web look at the stack **moving forward**. Read after `MACHINE_CAST.md` on any
> new session that touches voice, ops consoles, shortcuts, or multi-machine work.
>
> **Goal:** make both human and agent lives easier — see problems **at a glance**, not through
> a telescope. Organization here is **operational clarity**, not cosmetic sameness.

---

## 1. Doctrine (law for future work)

| Principle | What it means |
|-----------|----------------|
| **At a glance, not a telescope** | Tier color, shortcut name, preflight row, or one FAIL label should tell you *which layer* broke — not five terminals of archaeology. |
| **Icon = destination / scope** | Red/green/blue = *where voice goes* or *which box you RDP into* — not always the machine where the `.lnk` file sits. |
| **One shortcut → one orchestrator** | Every desktop action maps to a named script; installers own `.lnk` targets. No mystery args (see Voice Comms `$Args` fix). |
| **Labeled pieces, obvious swap points** | Honest baselines are fine (`TECH_DEBT.md`); spaghetti (tangled, untracked interdependencies) is not. |
| **Pull model on the web** | VENGEANCE *verifies and polls* lifepunchnet; lifepunchnet does not push to the desk. Cornerman is thin (mic + relay). |
| **Gate before stack** | Start Day stops if lifepunchnet `:9000` is down — blocker is almost always Whisper/Docker on **lifepunchnet**, not Cornerman. |

If a future change hides failure surfaces or merges unrelated scopes into one action, **stop** and split it back into labeled tiers.

---

## 2. The LifePunch web (three nodes, one system)

VENGEANCE, Cornerman, and lifepunchnet are **nodes in one web** — not three unrelated boxes.

| Node | Role | One line |
|------|------|----------|
| **VENGEANCE** | Hub | Build, decide, Cursor, GitHub source of truth, paste target |
| **Cornerman** | LAN helper | Mic (AT2020), PTT relay, local Tier-3 prep — no secrets |
| **lifepunchnet** | Hosted venue | Whisper `:9000`, watchdog `:9101`, session hub `:9102`, DXRP ops |

**VENGEANCE** is the only host that reaches both LAN (Cornerman) and internet (lifepunchnet).

Full cast: `lifepunch/docs/MACHINE_CAST.md`.

### 2b. RGB integration (not a group nickname)

**R** = VENGEANCE · **G** = Cornerman · **B** = lifepunchnet. Uniform primaries are **channels**, not
"everyone together." Additive mixes: **Yellow** (R+G voice desk), **Cyan** (G+B STT/hub feed),
**Magenta** (B+R status/checkpoint), **White** (full CVL go), **Black** (no signal). **Rainbow** =
gradient maturity over logged hub history — **not yet**; we are in **standard RGB** phase.

Canon: `lifepunch/docs/CVL_RGB_DOCTRINE.md`. Probe: `Get-CvlUniversalCheckpoint.ps1` prints RGB state.

---

## 3. Visual language (uniform = readable ops)

Applied per node via `lifepunch/branding/lifepunch-ops/Apply-LifePunchOpsConsole.ps1`:

| Signal | Meaning |
|--------|---------|
| **Tri-stack app icon** | Target **white-light** integration (all three primaries lit) — not "rainbow" yet |
| **Red** accent / icon | **R** — VENGEANCE desk or voice **to** VENGEANCE/Cursor |
| **Green** | **G** — Cornerman |
| **Blue / cyan** | **B** — lifepunchnet |
| **Gray taskbar** | Same on every node (taskbar only — title bars keep per-node accent) |
| **Dark mode + wallpaper** | Same wallpaper family; RDP sessions inherit remote box theme |
| **Console: black + accent** | PowerShell/conhost/WT schemes match node color; body text gray/white via `Voice-Console.ps1` (readable on black) |
| **PowerShell tab thumbnail** | Shared retro desktop icon on every node — `lifepunch-ops/icons/powershell-prompt-thumbnail.png` |
| **Explorer icons** | Gray folder + gray `.txt` on **every node** — art: `OneDrive\Desktop\uniforms\PNGs\`; apply: `Set-LifePunchExplorerIcons.ps1` (Win11 folders need HKLM Shell Icons — UAC once) |

Uniform standards: `OneDrive\Desktop\uniforms\UNIFORM_STANDARDS.md` · repo `lifepunch/branding/lifepunch-ops/UNIFORM_STANDARDS.md`.
Outfits + shortcuts: `OUTFITS.md` · `shortcut-icons/SHORTCUT_ICONS.md`.

Refresh all VENGEANCE `.lnk` icons:

```powershell
cd <repo>\lifepunch\scripts
powershell -ExecutionPolicy Bypass -File .\Install-LifePunchShortcutIcons.ps1
```

---

## 4. Desktop shortcuts (VENGEANCE) — tier → job

**Rule:** **Universal (tri-stack)** = spans **all three nodes** (full voice path or whole-path preflight).
**Single-destination** = red / green / blue.

| Shortcut | Icon tier | Scope | Orchestrator |
|----------|-----------|-------|--------------|
| **LifePunch — Start Day** | **Universal** | **Full stack:** lifepunchnet gate `:9000` + VENGEANCE watchers + SSH Cornerman PTT | `Start-LifePunchDay.ps1` |
| **LifePunch Voice Preflight** | **Universal** | Cross-node health check only (no windows started) | `Test-VoiceCommsReady.ps1` |
| **LifePunch Voice Comms** | **VENGEANCE (red)** | VENGEANCE watchers only — paste, session sync, host watch | `start-voice-comms.ps1` |
| **Cornerman — Talk to Vengeance** | **Cornerman (green)** | **On VENGEANCE desktop:** Red→Green signal (SSH relay + RDP to Cornerman) | `Start-TalkToVengeance.ps1` |
| **Talk to Vengeance** | **VENGEANCE (red)** | **On Cornerman desktop only:** PTT relay (red = voice **to** VENGEANCE) | `Talk to Vengeance.cmd` |
| **Cornerman (RDP)** | **Cornerman (green)** | RDP `192.168.1.227` | `Install-LifePunchRemoteShortcuts.ps1` |
| **lifepunchnet (RDP)** | **lifepunchnet (blue)** | RDP `205.209.104.22` | same |

### Daily habit (Bloodwave)

1. Power on **VENGEANCE** (Cornerman + lifepunchnet on or wake on LAN).
2. Double-click **LifePunch — Start Day**.
3. Preflight all green → **F7** Ready → **F8** talk → **Ctrl+V** in Cursor.

Use **Voice Comms** / **Cornerman — Talk to Vengeance** when restarting **part** of the stack only.

Party checklist: `lifepunch/docs/LIFEPUNCH_PARTY_HANDOFF.md` · architecture: `lifepunch/docs/VOICE_DAY_ARCHITECTURE.md`.

---

## 5. What Start Day starts (three windows + relay)

On success, **Start Day** opens on VENGEANCE:

| Window | Script | Job |
|--------|--------|-----|
| LifePunch Voice Watch | `start-vengeance-voice-watch.ps1` | Poll Cornerman outbox → clipboard → paste |
| LifePunch Session Sync | `start-session-sync.ps1` | Bridge logs → lifepunchnet `:9102` |
| LifePunch lifepunchnet Watch | `start-server-host-watch.ps1` | Poll `:9101` health |

Then SSH-starts **Cornerman** `Start-CornermanVoiceRelay.ps1` (same job as Talk to Vengeance).

**Voice Comms** = rows 1–3 only (no relay). **Cornerman — Talk to Vengeance** = Yellow path (Green relay) only.

---

## 6. Per-node agent cheat sheet

| Node | You care about | Key paths / runbooks |
|------|----------------|----------------------|
| **VENGEANCE** | Shortcuts, watchers, GitHub integration | `lifepunch/scripts/`, Block A in `AGENT_PROMPT.md` |
| **Cornerman** | PTT relay, no secrets, patch handoff | `LOCAL_AI_WORKSTATION.md`, Block D, `Talk to Vengeance.cmd` |
| **lifepunchnet** | Whisper `:9000`, boot tasks, session hub | `LIFEPUNCHNET_INSTRUCTIONS.txt`, `Install-LifePunchNetBoot.ps1`, Block C |
| **shottaWEB** | Website lane only — knows cast vocabulary | Block B, `SHOTTAWEB_HANDOFF.txt` |

---

## 7. Failure surfaces (at a glance)

| Symptom | Usually | Look here |
|---------|---------|-----------|
| Start Day stops at gate | lifepunchnet Whisper down | RDP lifepunchnet, Docker, `deploy-whisper.ps1` |
| Empty transcript | Same — no STT | `:9000` /health |
| Paste never fires | Voice watch or Cornerman SSH | Voice Comms window, `cornerman` SSH |
| Wrong shortcut icon | Installer tier mismatch | `LifePunch-ShortcutIcons.ps1`, `Install-LifePunchShortcutIcons.ps1` |
| Blank PowerShell on double-click | Empty `.lnk` Arguments | Never use `$Args` as a function param in installers |

Preflight script: `Test-VoiceCommsReady.ps1` · ports: `VOICE_PIPELINE_STATUS.md`.

---

## 8. Repo map (edit in GitHub monorepo only)

| Concern | Canonical path |
|---------|------------------|
| Shortcut icon tiers | `lifepunch/branding/shortcut-icons/` + `.cursor/rules/lifepunch-shortcut-icons.mdc` |
| Explorer icons (all nodes) | `OneDrive\Desktop\uniforms\` + `Set-LifePunchExplorerIcons.ps1` + `.cursor/rules/lifepunch-explorer-icons.mdc` |
| Uniform standards (web) | `OneDrive\Desktop\uniforms\UNIFORM_STANDARDS.md` · repo `lifepunch-ops/UNIFORM_STANDARDS.md` |
| Shortcut installers | `lifepunch/scripts/Install-LifePunch*.ps1` |
| Reboot prep (all nodes) | `lifepunch/scripts/Prep-LifePunchReboot.ps1` · lifepunchnet: `server/scripts/Prep-LifePunchReboot-Lifepunchnet.ps1` |
| Start Day orchestrator | `lifepunch/scripts/Start-LifePunchDay.ps1` |
| Ops uniform / consoles | `lifepunch/branding/lifepunch-ops/` |
| lifepunchnet boot | `lifepunch/server/scripts/Install-LifePunchNetBoot.ps1` |
| Agent onboarding | `lifepunch/docs/AGENT_ONBOARDING.md`, `AGENT_PROMPT.md`, `AGENT_SYNC_BROADCAST.txt` |
| Machine vocabulary | `lifepunch/docs/MACHINE_CAST.md` |

GitLab lanes get a **read-only mirror** of `lifepunch/docs` + `.cursor/rules` on export — never edit grounding in a lane clone.

---

## 9. Agent onboarding order (any machine)

1. `git fetch` → `git pull --rebase` (if clean tree)
2. `lifepunch/docs/MACHINE_CAST.md`
3. **`lifepunch/docs/OPS_CLARITY_CHECKPOINT.md`** (this file)
4. `lifepunch/docs/AGENT_ONBOARDING.md`
5. Lane block in `lifepunch/docs/AGENT_PROMPT.md` (A / B / C / D)

Paste `AGENT_SYNC_BROADCAST.txt` into a stale chat to force alignment.

---

## 10. Moving forward

- New ops shortcuts: pick tier from **scope**, document in `SHORTCUT_ICONS.md`, wire installer, run `Install-LifePunchShortcutIcons.ps1`.
- New nodes in the web: add to `MACHINE_CAST.md`, `nodes.json`, ops pack, and shortcut tier map before shipping.
- Agents: **capture once** in these docs — do not re-derive the voice stack or icon rules in chat.

This checkpoint is what got us here. Treat it as armor until Bloodwave replaces it with a newer checkpoint.
