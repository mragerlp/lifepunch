# Remote apps on lifepunchnet (save VENGEANCE RAM)

**Pattern:** Heavy or always-on **community/ops** apps run on **Blue** (lifepunchnet). You use them via **RDP** from VENGEANCE with **audio on your desk**.

---

## One-time setup (you)

**On VENGEANCE:**

```powershell
cd lifepunch\scripts
powershell -ExecutionPolicy Bypass -File .\Open-LifepunchnetRemoteAppsSetup.ps1
```

That refreshes the RDP shortcut (local audio), copies the install command, and opens **lifepunchnet (RDP)**.

**On lifepunchnet (elevated PowerShell in RDP):**

```powershell
cd C:\lifepunch\lifepunch-rdp-server\lifepunch\server\scripts
git pull --rebase
powershell -ExecutionPolicy Bypass -File .\Install-LifepunchnetRemoteApps.ps1
```

**On VENGEANCE after install:** Quit local Discord (system tray → Exit).

---

## Daily use

1. Work on VENGEANCE: Cursor, s&box, git.
2. RDP → **lifepunchnet (RDP)** for Discord (changelog paste, community).
3. Clipboard syncs both ways — draft on Red, paste in Discord on Blue.

Optional: **Discord mobile** for notifications without keeping RDP open.

---

## Good candidates for lifepunchnet (same pattern)

| App | Install flag | Notes |
|-----|--------------|-------|
| **Discord** | `discord` (default) | Primary ask — community posts |
| Slack | `-Apps slack` | Team chat |
| **iTunes** | `-Apps itunes` | Media — same pattern if you don't use Spotify |
| Spotify | `-Apps spotify` | Media |
| Firefox / Chrome | `-Apps firefox` | Extra browser (Edge already on Windows) |
| Odysseus | separate script | Already on Blue if `Install-Odysseus-Lifepunchnet.ps1` ran |
| Ollama | bundled with Odysseus setup | **Already live** at `:11434` on your box — skip unless probe fails |
| Session hub tail | browser `:9102/tail` | Voice/log history |

```powershell
# Example: Discord + iTunes
powershell -File .\Install-LifepunchnetRemoteApps.ps1 -Apps discord,itunes
```

---

## Keep on VENGEANCE (Red)

| App | Why |
|-----|-----|
| **Cursor** | Primary dev IDE |
| **s&box / Steam** | Playtest + ModelDoc |
| **Git / GitHub** | Canonical monorepo |
| **LifePunch Start Day** | Orchestrates CVL from desk |

## Keep on Cornerman (Green)

| App | Why |
|-----|-----|
| **LM Studio** | Tier-3 distill |
| **Voice relay** | PTT → lifepunchnet Whisper |
| **No Discord** | Green is thin prep only |

## Already on lifepunchnet (Blue)

| Service | Port |
|---------|------|
| Whisper STT | `:9000` |
| Watchdog | `:9101` |
| Session hub | `:9102` |
| Odysseus (native) | `:7000` loopback |
| Ollama (Odysseus backend) | `:11434` |
| Docker | Whisper stack |

---

## RAM rule of thumb

If it is **always-on chat/media** or **ops console** → Blue via RDP.  
If it is **game dev or addon ship** → VENGEANCE.

---

**Refs:** `LIFEPUNCH_PARTY_HANDOFF.md`, `LIFEPUNCHNET_RDP_ODYSSEUS.txt`, `Install-LifePunchRemoteShortcuts.ps1`
