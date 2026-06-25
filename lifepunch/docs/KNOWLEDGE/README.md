# LIFEPUNCH™ — Knowledge base

> **Status:** Seed only — **expansion deferred until the active lpbitcoin gate exits** (Law 10 / owner sign-off).  
> **Why does this exist?** **Laws** say what we must do. **Terminology** says what we call things (`TERMINOLOGY.md`). **Knowledge** is what we learned — balance, rejections, optional feel notes. Lower ceremony.

**Not law.** If knowledge conflicts with `LIFEPUNCH_GAMEPLAY_LAWS.md`, `.cursor/rules`, or an **Active** `DECISION-####`, **law wins**.

**Not mandatory on agent boot** — read files here only when the active task touches balance, rejections, or lane notes.

---

## Terminology vs knowledge (same family, different jobs)

| | **Terminology** | **Knowledge** |
|---|-----------------|---------------|
| **File** | `lifepunch/docs/TERMINOLOGY.md` | `lifepunch/docs/KNOWLEDGE/**` |
| **Scope** | **Whole repo** — Red/Green/Blue, Bloodwave, lpbitcoin vs bitcoinmining, Hub vs Terminal | **Per-topic learning** — tuning, journey, rejected ideas |
| **Who updates** | When naming settles (Architect + owner) | Architect curates; Bloodwave trains Integrator via notes here |
| **Agent use** | "Which machine am I on? Which entity?" | "What did we already try? What hour is this feature for?" |

Example: **"Cornerman"** and **"Green"** → **Terminology**. **"Rejected CPU-on-rack"** → **Knowledge** (`bitcoin/rejected-ideas.md`).

---

## vs other doc types

| Type | Location |
|------|----------|
| **Law** | `LIFEPUNCH_GAMEPLAY_LAWS.md`, rules |
| **Decision** | `DECISIONS/DECISION-####` |
| **RFC** | `RFC/` (Draft = not decided) |
| **Canon spec** | `addons/docs/BITCOIN_*.md` |
| **Scratch** | `scratch/` — never published |

---

## Tree

```text
KNOWLEDGE/
  bitcoin/
    mining-terminology.md   ← lane notes (names → TERMINOLOGY.md)
    balancing-notes.md
    rejected-ideas.md
  gameplay/
    player-fantasy.md
    progression.md
    player-feel.md          ← optional Fantasy Check / feel notes
  architecture/
    ownership-pattern.md
```

---

## Distiller (Green) routing

1. **Cite** `DECISION-####` — do not re-argue hub upgrades every distill.
2. **Names** → `TERMINOLOGY.md` (one line, not a lecture).
3. **Context** → link `KNOWLEDGE/bitcoin/*` for balance/rejected.
4. **RFC Draft** → say "not decided."

---

## Future: LIFEPUNCH_WIKI/

Post–Law 10 encyclopedia — **P3**. Do not build until bitcoin ships.

---

*v1.1 — 2026-06-25*
