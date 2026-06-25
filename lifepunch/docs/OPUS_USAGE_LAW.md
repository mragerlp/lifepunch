# LIFEPUNCH™ — Opus Usage Law (Cursor + Anthropic API)

> **Canonical.** Agents and owner sessions follow this before spending Tier-1 (Opus / API pool).
> Complements **lifepunch-operating-context** model routing — this doc adds the **four-phase
> workflow**, **strict subsystem scope**, and **ship order** for cyber entities.

## Why this exists

Opus is the scarce resource ($400/mo API pool on Cursor Ultra). Re-asking Opus to rediscover
context on every turn burns quota without shipping. **Plan once → implement one slice → flatgrass
proof → review once** gets more value per call than looping rediscovery.

**Highest-leverage stack (June 2026):** Cursor Ultra + Anthropic API key (connected in Cursor) +
Claude Opus + **strict subsystem scope**. No workflow change required — just discipline.

**API key:** Connect Anthropic in Cursor Settings → Models (never commit keys; see
`lifepunch/secure/` off-repo policy in `LOCAL_AI_WORKSTATION.md`). Verify the key works before
routing hard work to Opus.

---

## Model Routing (June 2026)

See the full amendment in `MODEL_ROUTING_AMENDMENT_GROK_BUILD_1.md`.

| Model            | Route                                                                                                   |
|------------------|---------------------------------------------------------------------------------------------------------|
| **Opus**         | Tier-1: architecture, economy, permissions, persistence, security, multi-file C#, hard runtime debugging |
| **Grok Build 1** | Tier-2A: technical planning, repo audits, ModelDoc plans, asset maps, bounded implementation slices     |
| **Composer**     | Tier-2B: continuity, routine edits, documentation, familiar implementation                              |
| **Cornerman**    | Tier-3: bulk distillation and preparation                                                               |

**Grok Output Law (mandatory for all Grok responses):**
Every technical claim must be labeled:
1. VERIFIED FROM REPO
2. INFERRED FROM EXISTING PATTERNS
3. NEEDS SBOX-EDITOR PROOF
4. NEEDS SBOX RUNTIME PROOF
5. OWNER DECISION REQUIRED
6. OUT OF SCOPE

Grok must cite exact repo source for numbers and engine specifics. Escalate immediately on economy, permissions, security, cross-system contracts, or multi-subsystem work.

Full details (including ESCALATION LAW and PROOF LAW) live in `MODEL_ROUTING_AMENDMENT_GROK_BUILD_1.md`.

---

## Opus usage law

### Use Opus for

| Category | Examples |
|----------|----------|
| **Architecture** | New systems, cross-component contracts, state machines |
| **Debugging** | Subtle, cross-file, runtime-only failures |
| **MCP workflows** | s&box bridge + editor MCP routing, play proof loops |
| **ModelDoc setup** | vmdl/vmat/collision/attachment foundation |
| **Multi-file edits** | C# gameplay, economy, permissions integration |
| **Razor UI blockers** | PanelComponent / SCSS engine quirks, BuildHash gaps |
| **Agent planning** | Phase plans, risk lists, file maps — **no code in Phase 1** |

### Avoid Opus for

| Category | Route instead |
|----------|----------------|
| README files | Auto / Composer |
| Changelogs | Auto / Composer |
| Discord posts | Auto / Composer |
| Marketing copy | Auto / Composer |
| Documentation formatting | Auto / Composer |

Routine ~80% stays on **Auto / Composer** (separate generous pool). Escalate to Opus the moment
real complexity appears — never gamble a hard problem on a weak model to save cost.

---

## Cursor workflow — every major task

```text
Phase 1 — Opus: Implementation plan ONLY
  • No code
  • Identify files
  • List risks
  • Define done = flatgrass proof (Law 5)

Phase 2 — Opus: Implement Phase A ONLY
  • One checklist ID / one subsystem slice
  • No "while we're here" (Law 9 → BACKLOG_PARKING_LOT.md)

Phase 3 — Test in flatgrass
  • lp_map_flatgrass + fresh spawn
  • Bridge screenshot / USE proof — not editor-only

Phase 4 — Opus: Review implementation
  • Find defects before next slice or publish
```

**Session hygiene:** one focused chat per major task. Continue via a **short summary into a NEW
chat**, not a multi-million-token drag. Attach specific files/ranges, not whole folders.

---

## Strict subsystem scope — lifepunchbitcoin example

**Gate:** `lifepunch/addons/docs/ACTIVE_WORKSTREAM.md` — single active lane until Law 10 exit.

Once the Anthropic API key is connected and Opus is available, use it **exclusively on one
entity at a time** until flatgrass play proof + owner sign-off, then advance:

| Order | Entity | Repo ident | Do not start until |
|-------|--------|------------|-------------------|
| 1 | **Hub** | `bitcoinmining` / `lpbitcoin/bitcoinhub` | — (current) |
| 2 | **Terminal** | `lpbitcoin/hashdterminal` | Hub Phase A DONE + H10 sign-off |
| 3 | **GPU Rack** | `lpbitcoin/gpurack` | Terminal baseline proof |

That keeps **cost** and **context** under control while maximizing Opus on architecture, state,
and integration — not on polish loops or doc formatting.

### Hub subsystem queue (Opus-worthy slices)

Work **one item per Opus Phase 2** — not batched:

1. Collision validation (P0 — multiple convex hulls / ModelDoc)
2. Power state system (OFF → BOOTING → RUNNING …)
3. Fan animation state (Phase 2 — after static box baseline)
4. LED state machine (Law 6 — states obvious without menus)
5. Telemetry overlays
6. Interaction polish (USE prompts, hub admin UX where blocked)

UI polish that is SCSS-only and non-blocking may stay on Auto/Composer unless it hits a **Razor
UI blocker** (engine compile silent fail, BuildHash, PanelComponent).

---

## Ship / publish rhythm

One-by-one we ship addons with a controlled, structured, step-by-step workflow:

```text
ChatGPT Step 1 brief (optional) → Opus Phase 1 plan → Opus Phase 2 slice
       → flatgrass proof → Opus Phase 4 review → owner sign-off
       → prepare-publish.ps1 → portal upload (when publishReady)
```

Publish law: `lifepunch/addons/docs/DXRP_ADDON_PUBLISH_DOCTRINE.md` · active gate:
`ACTIVE_WORKSTREAM.md`.

---

## Agent checklist (session start)

- [ ] API key connected in Cursor (if using Opus via Anthropic)
- [ ] Read `ACTIVE_WORKSTREAM.md` + this doc
- [ ] Confirm which **subsystem** and **Phase** (1–4) this chat owns
- [ ] Default Auto; escalate Opus only per tables above
- [ ] Phase 1 = plan only; Phase 3 = flatgrass; no commit without owner yes

---

## Related docs

| Doc | Role |
|-----|------|
| `lifepunch/docs/AGENT_PROMPT.md` | Block 0 paste — references this law |
| `lifepunch/docs/AGENT_ONBOARDING.md` | Foundation onboarding |
| `.cursor/rules/lifepunch-operating-context.mdc` | Tier 1/2/3 pools + eyes covered |
| `.cursor/rules/lifepunch-active-workstream-gate.mdc` | Single lane gate |
| `lifepunch/addons/docs/LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md` | Machine stack P0–P4 |
| `lifepunch/docs/MCP_AGENT_ROUTING.md` | s&box MCP task routing |
