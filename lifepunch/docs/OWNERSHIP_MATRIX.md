# LIFEPUNCH™ — Ownership matrix

> **Status:** Active  
> **Why does this exist?** One lookup for *who decides what* — stops AI from mixing Architect briefs with Integrator commits or Distiller canon.  
> **Index only** — role detail lives in `ARCHITECT.md`, `MACHINE_CAST.md`, and `.cursor/rules`. Hosts are **not** cognitive owners.

---

## Cognitive / operational roles (CVL Architect family)

| Role | Where | Decides | Does not |
|------|-------|---------|----------|
| **Bloodwave** | Everywhere | Final approval, commit consent, portal ship, trademark | — |
| **Design Architect** | VENGEANCE (Red) — ChatGPT | Player fantasy, laws, patterns, RFCs, decision *proposals* | Commit code · claim playtest · override repo law |
| **Integration Architect** | VENGEANCE (Red) — Cursor | Repo law, MCP, slices, flatgrass proof, implementation | Redesign without brief |
| **Distillation Architect** | Cornerman (Green) — Tier-3 prep | Summarize, outbox, cite **DECISION-####** by ID | Ship code · override decisions · set law |
| **Operations Architect** | lifepunchnet (Blue) — RDP agent | Ops tasks on hosted server **under Bloodwave authority** | Addon design · gameplay doctrine |
| **Infrastructure Architect** | ChatGPT CLV Project | Node/MCP/preflight diagnosis (advisory) | Repo commits · gameplay law |

Legacy aliases: Architect · Integrator · Distiller · RDP server agent — still valid in paths and paste files.

---

## Hosts and machines (not decision owners)

| Host | Role | Notes |
|------|------|-------|
| **VENGEANCE** | Red primary PC | Checkout, Cursor, s&box MCP hub — not a "brain" separate from roles above |
| **Cornerman** | Green LAN box | Local LM `:1234`, distill prep — not source of truth |
| **lifepunchnet** | Blue hosted runtime | DXRP ops, Whisper, watchdog, session hub — **operational machine**, not owner of infrastructure *design* decisions |

Infrastructure **design** routes to **Bloodwave** (+ Architect brief where applicable). lifepunchnet **runs** what Bloodwave approves.

---

## Topic routing

| Topic | Route to |
|-------|----------|
| **Gameplay philosophy** | Design Architect proposes → Bloodwave approves → `LIFEPUNCH_GAMEPLAY_LAWS.md` |
| **Implementation** | Integration Architect (Cursor) |
| **Final approval** | Bloodwave |
| **Distill / prep** | Distillation Architect (Cornerman) |
| **Infrastructure routing** | Infrastructure Architect (CLV) advisory · Bloodwave decides |
| **Legal / trademark** | Bloodwave + `lifepunch/legal/` |
| **Economy (DXRP)** | Integration Architect + Bloodwave for grants |
| **Hosted server ops** | Operations Architect on lifepunchnet under Bloodwave |

---

## Document types

| Type | Location | Proposes | Approves merge |
|------|----------|----------|----------------|
| **Law** | `LIFEPUNCH_GAMEPLAY_LAWS.md`, `.cursor/rules`, `CYBER_REFERENCE_LAWS.md` | Architect | Bloodwave |
| **Decision** | `DECISIONS/DECISION-####-*.md` | Architect | Bloodwave |
| **RFC** (draft) | `RFC/RFC-0005` only (frozen) | Architect | Bloodwave → becomes Decision |
| **Knowledge** | `KNOWLEDGE/**` *(optional / deferred)* | Anyone | Architect curates |
| **Canon spec** | `addons/docs/BITCOIN_*.md` | Architect | Bloodwave before implementation |
| **Scratch / templates** | `scratch/**`, `templates/**` *(deferred)* | — | Never merged as law |

---

## Escalation

| Situation | Route to |
|-----------|----------|
| "Does this feel like LIFEPUNCH™?" | Architect · Fantasy Check |
| "Does this compile and match law?" | Integrator |
| "Is this decided already?" | `DECISIONS/` index · cite **DECISION-####** |
| "Still under debate?" | `RFC-0005` only — Draft = do not implement |
| Multi-file C# / economy | Integrator **Opus** slice |

---

## Related

| Doc | Role |
|-----|------|
| `ARCHITECT.md` | Architect workflow detail |
| `MACHINE_CAST.md` | CVL host map |
| `DECISIONS/README.md` | Decision register index |
| `DESIGN_DECISION_LOG.md` | Thin index → decisions |

---

*v1.1 — 2026-06-25 — Hosts vs cognitive roles; defer KNOWLEDGE/templates in routing*
