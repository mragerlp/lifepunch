# Cornerman backlog — portal ops, staff handbooks, donor webhooks

**Logged:** 2026-06-13 (owner AFK prep idea)  
**Lane:** Tier-3 distill + structured research — **Red integrates**; Green does not ship or commit.

## Why this matters

Cornerman can run **slow, low-cost, offline** passes over DXRP portal surface area while Red is in editor or away. Outputs are staff handbooks, integration checklists, and webhook design — not live server changes.

## P0 deliverables (when queued)

### 1. Staff handbook — commands from portal

- Inventory every **console/chat command** exposed or documented on the DXRP portal for the LifePunch tenant.
- Cross-reference with in-game `ICommand` / chat handlers in DXRP gamemode + LifePunch addons.
- Produce ranked tables: **staff-only**, **donor/VIP**, **player**, **debug/editor**.
- Format: printable handbook sections (rank → allowed commands → syntax → audit notes).

### 2. Portal necessity map — online server using DXRP gamemode

For each portal area, answer: **required for live server?** / **optional** / **LifePunch-specific**.

Candidate areas to audit:

| Portal area | Question |
|-------------|----------|
| Server token / authorize | Required for editor + dedicated parity |
| Ranks + permissions | Staff menu, whitelist, donor tiers |
| Rank assignments | Steam ID → rank grants |
| Equipment / content rows | Weapons, entities, jobs |
| Economy / wallets | If tenant uses portal economy hooks |
| Bans / sanctions | Join gate via `ServerApiLink` |
| Audit log | Staff visibility + compliance |
| Key-value / settings | Owner customizations (e.g. staff menu settings) |
| Ruleset / game mode config | Map, max players, overrides |
| Webhooks / integrations | Donor fulfillment, Tebex, Discord, etc. |

Output: `PORTAL_NECESSITY_MATRIX.md` — what must be configured before a public server is "complete."

### 3. Donor package webhooks

- Document how donor purchases should flow: **payment provider → webhook → portal action → rank/equipment grant**.
- List portal/API endpoints or actions that apply packages (rank grant, equipment unlock, KV flags).
- Gap analysis: what LifePunch must build vs what DXRP portal already exposes.
- Propose webhook payload shapes + idempotency + audit trail (no secrets in repo).

## Constraints (law)

- **Cornerman's eyes are covered** — portal screenshots/specimens from owner only; distill from docs + API schema if available.
- **No secrets** in repo (tokens, webhook signing keys, EIN, etc.).
- **Distill only** unless brief says `WarmCoder` for draft webhook handler stubs — Red reviews before any C# ships.
- **Nominative use:** DXRP/Dxura as third-party platform; LIFEPUNCH as publisher on our goods.

## Red queue trigger (when owner says go)

```powershell
# Example — create dedicated push script when brief is finalized
Send-CornermanWorkflow.ps1 -Action WarmDistill
# Push brief + portal export paths to C:\lifepunch\cornerman\inbox\
```

## Related

- `lifepunch/admin-panel/` — permission JSON reconciliation
- `lifepunch/portal/` — DXRP portal tab docs
- `CORNERMAN_OFF_CURSOR_HANDOFF.md` — Green idle workflow
- `CORNERMAN_MODEL_ROUTING.md` — distill vs coder
