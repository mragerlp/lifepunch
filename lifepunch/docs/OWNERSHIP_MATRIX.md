# LIFEPUNCH™ — Ownership matrix

> **Status:** Active  
> **Why does this exist?** One lookup for *who decides what* — stops AI from mixing Architect briefs with Integrator commits or Distiller canon.

---

## Topic ownership

| Topic | Owner | Does | Does not |
|-------|-------|------|----------|
| **Gameplay philosophy** | **Architect** | Player fantasy, laws, patterns, RFCs, decisions | Commit code · claim playtest |
| **Implementation** | **Integrator** (Cursor) | Repo law, MCP, slices, flatgrass proof | Redesign without brief |
| **Final approval** | **Bloodwave** | Sign-off, commit consent, portal ship | — |
| **Distill / prep** | **Distiller** (Cornerman) | Summarize, outbox, reference **DECISION-####** by ID | Ship code · override decisions |
| **Infrastructure** | **lifepunchnet** | Hosted ops, voice, watchdog | Addon design |
| **Legal / trademark** | **Bloodwave** + repo `lifepunch/legal/` | Filings, specimens, IP doctrine | — |
| **Economy (DXRP)** | **Integrator** + owner for grants | Wire to gamemode APIs | Invent parallel currency without brief |

---

## Document types

| Type | Location | Owner proposes | Owner approves merge |
|------|----------|----------------|----------------------|
| **Law** | `LIFEPUNCH_GAMEPLAY_LAWS.md`, `.cursor/rules`, `CYBER_REFERENCE_LAWS.md` | Architect | Bloodwave |
| **Decision** | `DECISIONS/DECISION-####-*.md` | Architect | Bloodwave |
| **RFC** (draft) | `RFC/RFC-####-*.md` | Architect | Bloodwave → becomes Decision |
| **Knowledge** | `KNOWLEDGE/**` | Anyone | Architect curates; no gate for notes |
| **Canon spec** | `addons/docs/BITCOIN_*.md` | Architect | Bloodwave before implementation |
| **Scratch** | `scratch/**` | Anyone | **Never merged as canon** |

---

## Escalation

| Situation | Route to |
|-----------|----------|
| "Does this feel like LIFEPUNCH™?" | Architect · Fantasy Check |
| "Does this compile and match law?" | Integrator |
| "Is this decided already?" | `DECISIONS/` index · cite **DECISION-####** |
| "Still under debate?" | `RFC/` — do not implement until promoted |
| Multi-file C# / economy | Integrator **Opus** slice |

---

## Related

| Doc | Role |
|-----|------|
| `ARCHITECT.md` | Architect role detail |
| `DECISIONS/README.md` | Decision register index |
| `RFC/README.md` | RFC workflow |
| `KNOWLEDGE/README.md` | Accumulated knowledge vs law |

---

*v1.0 — 2026-06-25*
