# Cornerman task — Bitminer finish (docs only)

**Lane:** Tier-3 prep · **Priority:** **#3** (parallel with AK47 / hacker — owner wants bitminer **finished**)  
**Issued:** 2026-06-11 · **Red:** `BITMINER_FINISH_RUNBOOK.md` R2–R5 + owner ModelDoc  
**You do NOT:** ship C#, ModelDoc, `git push`.

---

## Read first

`lifepunch/addons/docs/BITMINER_FINISH_RUNBOOK.md`

---

## Task G1 — Protection checklist

Fill grep rows in `briefs/BITMINER_PROTECTION_CHECKLIST.md`:

- LIFEPUNCH™ in About / boot — no third-party credits
- Proprietary headers on all `bitcoinmining/*.cs` + `.razor`
- No third-party attribution strings (`BITMINER_PROTECTION_CHECKLIST.md`)
- `addons.json` description leads with LIFEPUNCH

Mark each row PASS / FAIL / N/A with file path.

---

## Task G2 — Portal listing copy

Create `docs/reference/BITMINER_PORTAL_LISTING.md`:

| Field | Content |
|-------|---------|
| Title | LIFEPUNCH Bitcoin Mining for DXRP |
| Three entities | Bitcoin Terminal · Bitcoin Miner · Advanced Bitcoin Miner |
| One-liner | Place terminal + racks; control mining from hashd console |
| Compatible | DXRP (nominative) |

---

## Task G3 — Player flow (UX spec)

Add **§ Player experience** to `BITMINER_UX_SPEC.md` (~15 lines):

1. Place terminal near rack(s)
2. USE CRT or type `hashd`
3. `mining start all` / per-rig `select`
4. Sell BTC from Wallet (Phase 2) or `bitcoin sell` today

---

## Commit + ping

```text
docs(bitcoinmining): finish runbook — protection checklist + portal listing
```

Ping Red when done — no patch needed if Red already on latest `main`.
