# OPENCODE HARNESS ADOPTION — 2026-07-14

**STATUS: RATIFIED** (Bloodwave GO 2026-07-14).
**Lane record:** `C:\lifepunch\comms\copilot\0010_COPILOT_OPENCODE-AUTHORITY-RULING-SIGNED_2026-07-14.md`
**Authored into canon by:** Cursor (review/PR seat) under Bloodwave GO 2026-07-14.

## Ruling (verbatim)

> OpenCode is ratified as an implementer **harness**. When running a frontier
> cloud model, it may hold the implementer chair under the existing relief clause
> (CLAUDE.md → CODEX SEAT CHARTER + RELIEF CLAUSE) — same laws as Codex:
> proof-gated commits, attribution-clean (author mragerlp, zero AI trailers),
> Bloodwave merge gate, one seat per tree. When running CORNERMAN local models,
> it is advisory-only (Green-class). Editor DRIVE remains a separate board-named
> grant per EDITOR_ACCESS_LAW_V2_2026-07-13, grantable to
> OpenCode-with-cloud-model like any implementer.

## Model-tier table (authority follows the model)

| Provider / model | Tier | Authority |
|---|---|---|
| OpenAI (ChatGPT Pro / Plus via OpenCode) | Frontier cloud | **Implementer-eligible** under relief clause |
| GitHub Copilot (via OpenCode) | Frontier cloud | **Implementer-eligible** under relief clause |
| OpenCode Zen | Frontier cloud | **Implementer-eligible** under relief clause |
| CORNERMAN — `qwen2.5-coder-32b-instruct` | Local (LM Studio `10.10.10.2:1234`) | **Advisory-only** (Green-class) |
| CORNERMAN — `qwen/qwen3.6-35b-a3b` | Local | **Advisory-only** (Green-class) |
| CORNERMAN — `qwen/qwen3.6-27b` | Local | **Advisory-only** (Green-class) |

**Consequence:** authority follows the model, not the harness. OpenCode + frontier
cloud = implementer-eligible. OpenCode + CORNERMAN qwen = advisory-only.

## Grounding path

1. OpenCode loads repo-root `AGENTS.md` at startup (non-Claude harness entry).
2. `AGENTS.md` points to **`CLAUDE.md`** — canon of record; read in full.
3. Repo-root `opencode.json` `instructions` array lists `CLAUDE.md` first, then
   `ARCHI.md`, TRIP adoption, and this adoption doc.
4. Permission gates in `opencode.json` (unchanged by this PR):
   - `git push*` / `git merge*` / `git tag*` → **deny**
   - `git commit*` → **ask**
   - `edit` → **ask**
   - Bloodwave remains sole merge authority

## Relief-clause activation (unchanged)

Same procedure as Codex (CLAUDE.md → CODEX SEAT CHARTER + RELIEF CLAUSE):

- Explicit Bloodwave handoff naming OpenCode + the cloud model.
- Red-dark: clean known SHA, zero uncommitted diff, handoff note stating HEAD + open work.
- OpenCode ACKs and holds alone; Red ACKs on return to reclaim.
- Never both live on the canonical tree.
- While in the chair: proof-gated commits, author `mragerlp`, zero AI trailers,
  Sensor Law, Bloodwave merge gate, MIRROR.

## Editor / MCP (not wired)

s&box editor and MCP surfaces (`sbox`, `sbox-editor`) are **not** wired to OpenCode
in this adoption. Editor DRIVE stays a separate board-named grant per
`EDITOR_ACCESS_LAW_V2_2026-07-13.md`. Wiring OpenCode to the bridge requires a
**future ruling** — do not invent it.

## Related canon

- Kepler control plane: `lifepunch/docs/cvl/KEPLER_ADE_ADOPTION_2026-07-14.md`
- TRIP skills: `lifepunch/docs/cvl/TRIP_ADOPTION_2026-07-14.md`
- Console plugins: `lifepunch/docs/cvl/CONSOLE_PLUGINS_DOCTRINE.md`
