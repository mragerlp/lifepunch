# LifePunch voice — party handoff (VENGEANCE / Cornerman / lifepunchnet)

Target: **turn on VENGEANCE → double-click Start Day → PTT works.** lifepunchnet and Cornerman stay on or wake on LAN.

**Ops doctrine:** see problems **at a glance** (shortcut tier, preflight row) — not a telescope.
Canonical checkpoint: `lifepunch/docs/OPS_CLARITY_CHECKPOINT.md`.

## Shortcut tiers (VENGEANCE desktop)

| Shortcut | Icon | What |
|----------|------|------|
| **Start Day** | Tri-stack (universal) | Full stack: `:9000` gate + watchers + Cornerman relay |
| **Voice Preflight** | Tri-stack | Test only — all nodes |
| **Voice Comms** | Red | VENGEANCE watchers only |
| **Talk to Vengeance** | Red | Cornerman PTT (red = voice to VENGEANCE) |
| **Cornerman (RDP)** | Green | LAN box |
| **lifepunchnet (RDP)** | Blue | Hosted box |

## Daily workflow (Bloodwave)

1. Power on **VENGEANCE** (Cornerman + lifepunchnet already on or wake on LAN).
2. Double-click **LifePunch — Start Day** on VENGEANCE.
3. Preflight all green:
   - lifepunchnet **:9000** (gate)
   - VENGEANCE watchers running
   - Cornerman relay running
4. **F7** → Ready → **F8** hold → release → **Ctrl+V** from voice watch.

**One-liner (when green):**

> Cornerman clean. Start Day on VENGEANCE → confirm lifepunchnet :9000 + watcher + Cornerman relay → PTT F7/F8 test. Blocker is almost always lifepunchnet Whisper/Docker, not Cornerman config. Say preflight OK when all green.

---

## Party actions

| Party | Ship / run |
|-------|------------|
| **lifepunchnet** | `Install-LifePunchNetBoot.ps1` (elevated) — Docker Automatic, Whisper AtLogon, :9101/:9102 tasks, smoke test. Manual once: Docker Desktop **Start when you sign in** (Administrator). |
| **VENGEANCE** | `Start-LifePunchDay.ps1` + `Install-LifePunchDayShortcut.ps1` + `server-host-watch.local.json` (gitignored). Monorepo: `lifepunch/scripts/`. |
| **Cornerman** | `Start-CornermanVoiceRelay.ps1` on-box (`Apply-CornermanPushToTalk.ps1`). PTT via `Talk to Vengeance.cmd`. No secrets on Cornerman. |

VENGEANCE **does not** SSH to lifepunchnet in v1 — only verifies hosted ports.

---

## lifepunchnet boot (turn-on-and-forget)

**On lifepunchnet (elevated), from monorepo scripts path:**

```powershell
cd C:\lifepunch\lifepunch-rdp-server\lifepunch\server\scripts
# or copied monorepo scripts folder
powershell -ExecutionPolicy Bypass -File .\Install-LifePunchNetBoot.ps1 -RemoteAddress 71.250.46.224
```

Wires:

| Component | Mechanism |
|-----------|-----------|
| Docker daemon | `com.docker.service` → Automatic |
| Docker Desktop UI | **Manual:** Start when you sign in (Administrator) |
| Whisper :9000 | `LifePunch-Whisper-Deploy` AtLogon → `C:\lifepunch\whisper\deploy-whisper.ps1` |
| Watchdog | `LifePunch-ServerHost-Watchdog` (existing) |
| Status :9101 | `LifePunch-ServerHost-StatusServer` AtStartup (existing) |
| Session hub :9102 | `LifePunch-SessionHub` AtStartup (existing) |

Promote to monorepo / GitLab lane: branding pack, boot scripts, Start Day, Cornerman relay starter.

---

## Monorepo paths (VENGEANCE canonical)

| Asset | Path |
|-------|------|
| Start Day | `lifepunch/scripts/Start-LifePunchDay.ps1` |
| Start Day shortcut | `lifepunch/scripts/Install-LifePunchDayShortcut.ps1` |
| Cornerman relay starter | `lifepunch/scripts/Start-CornermanVoiceRelay.ps1` |
| Net boot installer | `lifepunch/server/scripts/Install-LifePunchNetBoot.ps1` |
| Whisper deploy | `lifepunch/server/whisper/deploy-whisper.ps1` |
| Branding pack | `lifepunch/branding/lifepunch-ops/` |
| Architecture | `lifepunch/docs/VOICE_DAY_ARCHITECTURE.md` |

---

## Blockers

| Symptom | Usually |
|---------|---------|
| `:9000` red from VENGEANCE | lifepunchnet Docker/Whisper not up — not Cornerman |
| Empty transcript | Same — no STT fallback in relay |
| Paste never fires | Voice watch not running or SSH to Cornerman |
