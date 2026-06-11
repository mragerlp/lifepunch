# LifePunch Government Database — Concept Stub (NOT greenlit)

> **Status:** Placeholder for a future DXRP system. Build **after** Hacker Job economy is signed off and shipping.  
> This file exists so the roadmap does not live only in chat.

---

## Intent (owner direction, 2026-06-11)

After the Hacker Job terminal is deep enough (puzzles, wallet hacks, Cornerman terminal skin aligned with Bitcoin Miner), add a **Government Database** — a separate in-world system players interact with for records, warrants, fines, or RP bureaucracy (exact feature set TBD at sign-off).

## Relationship to other addons

| Addon | Role |
|-------|------|
| **Hacker Job** | Offensive — scan players, puzzle-gated wallet theft |
| **Bitcoin Miner** | Economy generation — hashd terminal, mining loop |
| **Government Database** | Institutional — likely read-heavy, staff/police facing, audit trails |

Shared **visual language:** Cornerman green terminal (`#00FF7F` on `#0a0f0a`) but distinct program name and copy (not `cornerman.exe` — e.g. `govdb.exe` or agency-branded shell).

## Open questions (in-depth pass)

- Which DXRP jobs can access (police, mayor, judge)?
- Read-only vs. write actions (warrants, arrests, tax records)?
- Tie-in to Hacker Job counterplay (traces, alerts)?
- Server-authoritative audit log requirements?
- Separate `simple-entity` terminal or map-fixed kiosk?

## Next step

Owner greenlights feature set → add `governmentdatabase` row to `addons.json` → Opus architecture pass → scaffold entity + terminal (do not start code until then).
