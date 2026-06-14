# PagerDuty — Cursor MCP setup (Bloodwave)

Configure **locally on VENGEANCE**. Never paste your API token into chat or commit it to git.

---

## 1. Generate a PagerDuty User API token

1. Log in to [PagerDuty](https://www.pagerduty.com/)
2. Follow PagerDuty’s guide: [Generate your PagerDuty API token](https://support.pagerduty.com/main/docs/pagerduty-mcp-server-integration-guide#generate-your-pagerduty-api-token)
3. Create a **User API token** with the scopes PagerDuty documents for MCP
4. Copy the token — you will paste it **only** into your local MCP config

---

## 2. Add token to Cursor MCP config

Cursor merges the PagerDuty plugin. Configure via **your user** `mcp.json` (survives plugin cache updates):

**File:** `%USERPROFILE%\.cursor\mcp.json`

Add or merge this server block (keep your existing `sbox`, `sbox-editor`, etc.):

```json
{
  "mcpServers": {
    "pagerduty-mcp": {
      "url": "https://mcp.pagerduty.com/mcp",
      "headers": {
        "Authorization": "Token YOUR_TOKEN_HERE"
      }
    }
  }
}
```

**Rules:**

- Keep the literal prefix `Token ` (space after Token) before the token value
- Replace `YOUR_TOKEN_HERE` with your User API token
- Do **not** use `${PAGERDUTY_API_TOKEN}` unless you also set that env var in Windows

**Alternative — environment variable:**

1. Windows: System → Environment Variables → User → New  
   - Name: `PAGERDUTY_API_TOKEN`  
   - Value: your token (no `Token ` prefix in the env var)
2. In `mcp.json`:

```json
"Authorization": "Token ${PAGERDUTY_API_TOKEN}"
```

Only works if Cursor expands env vars in MCP headers (verify after reload).

---

## 3. Reload Cursor

**Ctrl+Shift+P** → **Developer: Reload Window**

Then **Settings → MCP** — `pagerduty-mcp` should show green.

---

## 4. Smoke test (in Cursor chat)

Ask the agent to list PagerDuty services or on-call — only after MCP is green.

If red: token typo, missing `Token ` prefix, or token revoked.

---

## 5. Wire Grafana alerts → PagerDuty (later)

Phase 1 Grafana is on lifepunchnet (`CVL_OBSERVABILITY_LANE.md`). To page on downtime:

1. Grafana → **Alerting** → **Contact points** → New → **PagerDuty**
2. Paste PagerDuty **Integration key** (service-specific — different from User API token)
3. Alert rule example: `probe_success{service="whisper"} == 0` for 2m

| Token type | Used for |
|------------|----------|
| **User API token** | Cursor MCP (manage incidents from IDE) |
| **Integration key** | Grafana/email → PagerDuty service |

---

## Security

- User API token = full MCP access — treat like a password
- Store in `mcp.json` or env var only on VENGEANCE
- Rotate in PagerDuty if exposed
- Never commit to `mragerlp/lifepunch`

Plugin reference (cache path — do not edit; use user `mcp.json` instead):

```3:7:C:\Users\jared\.cursor\plugins\cache\cursor-public\pagerduty\f489c6b0c4937b19e05ce384910d49ed7327da7c\mcp.json
    "headers": {
      "Authorization": "Token ${PAGERDUTY_API_TOKEN}"
    },
```
