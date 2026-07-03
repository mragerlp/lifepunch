# Cornerman task — LIFEPUNCH Cyber Ecosystem distill

**Lane:** Tier-3 prep · **Priority:** **P1** (owner greenlit full ecosystem)  
**Red:** C#, intake, ModelDoc, economy Opus · **Green:** distill only — no ship C#

**Warm:** `Send-CornermanWorkflow.ps1 -Action WarmDistill`

---

## Read first

1. `lifepunchaddons/docs/LIFEPUNCH_CYBER_ECOSYSTEM.md`
2. `lifepunchaddons/docs/ASSET_INTAKE_CYBER_ECOSYSTEM.md`
3. `lifepunchaddons/docs/GOVERNMENT_DATABASE_SPEC.md` (update cap $50k, tick 30m)
4. `hackerjob/docs/HACKER_SERVER_RACK_SPEC.md`
5. `bitcoinmining` — owner compromise: 2 hubs × (3 small + 1 large rack)

---

## Deliverables (outbox)

Red seeded repo canon — **distill/simplify for RAG**, do not duplicate verbatim:

| Repo source (pull main) | Outbox target |
|-------------------------|---------------|
| `LIFEPUNCH_CYBER_ECOSYSTEM.md` | `CYBER_ECOSYSTEM_ONE_PAGER.md` |
| `BITCOINMINING_ENCRYPTION_SPEC.md` + `BitcoinMinerEncryptionCatalog.cs` | `BITCOINMINING_ENCRYPTION_UPGRADE_TABLE.md` |
| `HACKER_PVP_INFRA.md` | `HACKER_PVP_INFRA_FLOW.md` |
| `GOV_DATACENTER_ROLEPLAY.md` | same name in outbox (tighten) |
| `UPGRADE_TIER_STANDARD.md` | same name in outbox |
| `HACKER_OPS_CONSOLE_SPEC.md` + owner note | `HASHD_AUTH_PATTERN.md` + `HACKER_UI_REVIEW_NOTES.md` |

Add: **open questions** list for owner playtest walkthrough.

---

## Do NOT

- Edit ship C# or ModelDoc on Green
- Ship only LifePunch-owned audio/models (`BITCOINMINING_IP_DOCTRINE.md`)
- Redesign amber hashd menu — additions only

---

## Ping Red

```text
OK cornerman cyber-ecosystem distill — outbox/*.md ready
```
