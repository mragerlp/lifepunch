# lifepunchnet observability stack (repo source)

Copied to `C:\lifepunch\observability` by `Install-LifepunchnetObservability.ps1`.

| Path | Role |
|------|------|
| `docker-compose.yml` | Grafana :3000, Prometheus :9091 (localhost), Blackbox |
| `prometheus/prometheus.yml.template` | Scrape jobs (committed) |
| `blackbox/blackbox.yml.template` | Bearer placeholder `__STATUS_TOKEN__` |
| `rendered/` | Generated on-box at deploy — **not in git** |
| `deploy-observability.ps1` | Render + `docker compose up -d` |
| `grafana/dashboards/cvl-phase1.json` | Phase 1 UP/DOWN + latency |

Install: `../scripts/Install-LifepunchnetObservability.ps1`

Doc: `../../docs/CVL_OBSERVABILITY_LANE.md`
