# Blue (lifepunchnet) — pull Grafana Phase 1

**Exported:** 2026-06-14  
**GitHub mono:** `f0410da`  
**GitLab rdp-server:** `a3f5b39`

## On lifepunchnet (elevated)

```powershell
cd C:\lifepunch\lifepunch-rdp-server
git fetch
git pull --rebase
git log -1 --oneline
# expect: a3f5b39 or newer (mono @f0410da)

cd lifepunch\server\scripts
powershell -ExecutionPolicy Bypass -File .\Install-LifepunchnetObservability.ps1 -RemoteAddress 71.250.46.224
```

## `-RemoteAddress` law

- **Must be a full IPv4** (four octets), e.g. `71.250.46.224`
- **Use VENGEANCE home public IP** — same value as `hub-ingest-allowlist.txt` / CVL firewall scripts
- **Not** a partial LAN like `192.168.236` (invalid)
- LAN IPs only if you intentionally scope to a specific on-prem client (unusual for Blue Public profile rules)

## After install

- Grafana: `http://<lifepunchnet-ip>:3000` — password `C:\lifepunch\observability\secrets\grafana-admin.txt`
- VENGEANCE test: `powershell -File lifepunch\scripts\Test-LifepunchnetObservability.ps1`
