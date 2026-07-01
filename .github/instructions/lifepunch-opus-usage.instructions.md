---
applyTo: "**"
description: "Opus/API pool discipline — four-phase workflow, strict subsystem scope, ship order"
sourceRule: ".cursor/rules/lifepunch-opus-usage.mdc"
---

> **Synced from** `.cursor/rules/lifepunch-opus-usage.mdc` â€” edit source there, then re-run `Sync-CursorRulesToCopilotInstructions.ps1`.

# LifePunch — Opus Usage Law

**Canonical:** `lifepunch/docs/OPUS_USAGE_LAW.md`

## Core law

> Opus = scarce $400/mo API pool. **Plan once → implement one slice → flatgrass proof → review once.**
> Do not burn Opus rediscovering context every turn.

**Stack:** Cursor Ultra + Anthropic API key (Cursor Settings, never in git) + Opus + **strict subsystem scope**.

## Use Opus for

Architecture · debugging · MCP workflows · ModelDoc setup · multi-file C# · Razor UI **blockers** · agent planning (Phase 1, no code).

## Avoid Opus for

README · changelogs · Discord · marketing · doc formatting → **Auto / Composer**.

## Task route tags (Cursor Auto is NOT a routing guarantee)

Auto is fine for routine work but does **not** lock/expose the model it picked. Honor any route tag on a
task; if the required route is not active, **switch to it or stop and tell Bloodwave** — never silently substitute.

| Tag | Do |
|-----|----|
| `AUTO OK` | Auto / Composer |
| `OPUS REQUIRED` | Manually select Opus (Tier-1) |
| `GROK REQUIRED` | Manually select Grok Build 1 (Tier-2A) |
| `GREEN CODE REQUIRED` | Cornerman / LM Studio Qwen Coder (Tier-3 candidate) |
| `GREEN DEEP REQUIRED` | Cornerman / LM Studio Qwen dense (Tier-3 distill/warm) |

**Never let Auto silently substitute** for: economy · persistence · `[Sync(FromHost)]` · RPCs · purchase
routing · CPU/Core→Compute Profile migration · hub power/link cascade · terminal defense · final
major-slice / commit-critical review. Canonical: `lifepunch/docs/OPUS_USAGE_LAW.md` § Task route tags.

## Four-phase workflow (major tasks)

| Phase | Who | What |
|-------|-----|------|
| **1** | Opus | Plan only — files, risks, definition of done. **No code.** |
| **2** | Opus | Implement **Phase A / one slice only** |
| **3** | Any + bridge | **Flatgrass** play proof — not editor-only |
| **4** | Opus | Review — find defects before next slice |

One focused chat per major task; fresh chat + short summary for the next phase.

## lifepunchbitcoin ship order (strict scope)

Opus exclusively on **one entity until flatgrass proof + owner sign-off**, then advance:

1. **Hub** (`lpbitcoin/bitcoinhub`) — active
2. **Terminal** — after Hub Phase A + H10
3. **GPU Rack** — after Terminal baseline

Hub Opus slices (one per Phase 2): collision validation → power state → fan anim → LED state machine → telemetry overlays → interaction polish.

**Gate:** `ACTIVE_WORKSTREAM.md` · machine stack: `LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md`.
