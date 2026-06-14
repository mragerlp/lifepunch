# CVL observability — Phase 1 (June 2026)

**Grafana on lifepunchnet** probes CVL signal ports. **PagerDuty** is optional alerting (Cursor MCP + Grafana contact point later).

## What Phase 1 monitors

| Service | Port | Probe |
|---------|------|-------|
| Whisper | `:9000` | `GET /health` (no auth) |
| Watchdog | `:9101` | `GET /status` (Bearer `status-token.txt`) |
| Session hub | `:9102` | `GET /status` (Bearer) |

Stack on lifepunchnet (Docker):

```text
Blackbox exporter → HTTP probes to host.docker.internal
Prometheus        → scrapes probe_success / probe_duration_seconds (localhost :9091)
Grafana           → :3000 dashboard "LifePunch CVL — Phase 1"
```

**Not in Phase 1:** MCP bridges, VENGEANCE RAM, OpenTelemetry, PagerDuty auto-wire (manual setup).

---

## Install (lifepunchnet RDP — elevated)

Prerequisites: `Install-LifePunchNetBoot.ps1` already ran (`status-token.txt` exists).

```powershell
cd C:\lifepunch\lifepunch-rdp-server\lifepunch\server\scripts
git pull --rebase
powershell -ExecutionPolicy Bypass -File .\Install-LifepunchnetObservability.ps1 -RemoteAddress 71.250.46.224
```

Replace `71.250.46.224` with VENGEANCE home public IP (same as other CVL firewall rules).

**On-box paths:**

| Path | Role |
|------|------|
| `C:\lifepunch\observability\` | Docker compose + rendered configs |
| `C:\lifepunch\observability\secrets\grafana-admin.txt` | Grafana `admin` password (**never commit**) |
| Task `LifePunch-Observability-Deploy` | AtLogon — restarts stack after reboot |

Re-deploy after token rotation:

```powershell
powershell -ExecutionPolicy Bypass -File C:\lifepunch\observability\deploy-observability.ps1
```

---

## VENGEANCE access

1. RDP or browser: `http://205.209.104.22:3000` (or your lifepunchnet IP)
2. Login: `admin` + password from lifepunchnet `secrets\grafana-admin.txt`
3. Dashboard: **LifePunch → LifePunch CVL — Phase 1**

Preflight from VENGEANCE:

```powershell
powershell -File lifepunch\scripts\Test-LifepunchnetObservability.ps1
```

Optional `server-host-watch.local.json`:

```json
"grafanaPort": 3000
```

---

## PagerDuty (optional)

Cursor MCP setup: `lifepunch/docs/PAGERDUTY_CURSOR_SETUP.md`

Grafana → Alerting → Contact points → PagerDuty when you want pages on `probe_success == 0`.

---

## Related

- `server/observability/README.md` — file layout
- `Install-LifePunchNetBoot.ps1` — `:9000` / `:9101` / `:9102` boot
- `SBOX_EDIT_STANDARDS.md` — editor bar (separate from Grafana)
