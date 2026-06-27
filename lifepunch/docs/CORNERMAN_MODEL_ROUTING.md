# Cornerman — model routing (when to switch)

**Box:** Green (Cornerman) · **Runtime:** LM Studio `:1234` · **Red warms from VENGEANCE**

Cornerman is the **Tier-3 local worker lane** — cheap, local, and **untrusted** (not "weak"). It does real
work: code candidates, distill, reports, and prep. It is **not final authority** for ship decisions — VENGEANCE
(Cursor / Opus) compiles + proves in s&box, and **Bloodwave approves commits**. Red owns integration.

> **Rule of thumb:** Qwen Coder can cook contained code. Green Deep warms the kitchen. Grok finds the
> ingredients. Opus owns the risky recipe. Bloodwave approves the meal.

**Eyes covered:** Green cannot see the game or the owner's screen. Say **Cornerman's eyes are covered**
before any visual, spawn, scale, or playtest claim — files and distills are not the viewport.

**Decision register (distill law):** Cite `DECISION-####` from `lifepunch/docs/DECISIONS/` instead of re-explaining settled architecture. Pull context from `KNOWLEDGE/` for balance and rejected ideas. RFC `Draft` = not decided.

---

## Four Green profiles (warm the right one)

Tier-3 is a **lane**, not one model. Cornerman runs several local Qwen profiles — different jobs, not
the same worker. Exact LM Studio keys must be verified on Cornerman with `lms ls --llm --detailed`;
do not hardcode a key that does not exist on the box.

| Profile | Model role (LM Studio key) | Use for | Not for |
|---------|----------------------------|---------|---------|
| **Green Code** | Qwen Coder / Qwen3 Coder (`qwen2.5-coder-32b-instruct`) | Contained C#/Razor/SCSS candidate patches, refactors, read-only view models, patch-ready diffs | Final authority on economy, persistence, `[Sync(FromHost)]`, purchase routing, commits |
| **Green Deep** | Qwen dense reasoning (`qwen/qwen3.6-27b`) | Long repo/canon distill, architecture warm packets, Opus/Grok packet prep, scope-risk review, migration warm-up | Fast triage |
| **Green Daily** (default) | Qwen daily/MoE (`qwen/qwen3.6-35b-a3b`) | Reports, summaries, audits, Red handoffs, daily long runs, plan-drift comparison | Deep authority decisions |
| **Green Fast** | Small Qwen (`qwen/qwen3.5-9b`) | Quick file location, short summaries, routing checks, fast task classification | Important implementation |

**Default on boot:** Green Daily + embed. Warm **Green Deep** for long repository-level work (full
lpaddons ecosystem prep, big GO SHELL batches, cyber-law + menu overhauls). Warm **Green Code** for
contained implementation candidates (Razor/SCSS cleanup, static UI shell cleanup, read-only status
dashboards, helper refactors, patch-ready diff proposals) — VENGEANCE then applies/recreates, compiles,
proves in s&box, and decides whether to ask Opus for review **before** any Bloodwave-approved commit.

### Green Code may write candidate patches — VENGEANCE owns the rest

Green Code can propose real code, but VENGEANCE owns: applying/recreating the patch, compiling, proving
in s&box, deciding whether Opus review is needed, and commit/push **only after Bloodwave approval**.
High-risk slices (Hub off→unlink cascade, CPU/Core→Compute Profile migration, purchase routing, Terminal
defense, cross-entity logic, money/persistence/`[Sync]`) require an **Opus plan**; Green Code may
implement a candidate only **after** that plan.

**Canonical catalog file:** `lifepunch/config/cornerman-tier3-models.json` — edit this when adopting a newer LLM; run `Fix-CornermanLmServe.ps1` + see `CVL_FULL_CAPACITY_UPDATES.md` § Cornerman LLM.

**Loaded vs catalog:** LM Studio `/v1/models` lists every downloaded model even when not in VRAM. Trust `lms ps` (or warm-script output `LOADED in VRAM`) — not the GUI progress bar stalling at ~97%.

### GUI vs server (headless)

| Piece | Required? | Notes |
|-------|-----------|-------|
| **LM Studio GUI window** | **No** | Close it after first-time setup (Developer Mode + models downloaded). |
| **`lms server` on `:1234`** | **Yes** | Headless API — `Start-CornermanLmStudio.ps1` runs `lms server start`. |
| **Models in VRAM** | **Daily: 2** | Distill + embed loaded via `lms load`. Coder on disk until `WarmCoder`. |
| **SSH terminal on Red** | **No** | One-shot warm/probe only. Watchdog on Green keeps serve alive. |
| **jared logged in on Green** | **Yes** | Watchdog task is Interactive/logon-scoped; box must be on + auto-login session. |

**Fix everything from VENGEANCE (one command):**

```powershell
powershell -File lifepunch\scripts\Fix-CornermanLmServe.ps1
```

**Load Green Deep manually on Cornerman (for long sessions):**

```powershell
# On Cornerman
lms load qwen/qwen3.6-27b --gpu max -y
```

Recommended LM Studio settings for Green Deep:
- Quant: Q6_K_L (or best stable Q6)
- Context: 32768
- Thinking: ON
- Preserve Thinking: OFF
- Temperature: 0.6
- Top P: 0.95
- Top K: 20
- GPU offload: maximum stable

Do not run Qwen3-Coder-Next as daily — minimum ~42 GB footprint leaves insufficient headroom on 64 GB unified.

---

## Red commands (VENGEANCE)

```powershell
cd lifepunch\scripts

# Default distill (doc lane)
powershell -File Send-CornermanWorkflow.ps1 -Action WarmDistill

# Qwen 2.5 Coder (C#/Razor draft lane)
powershell -File Send-CornermanWorkflow.ps1 -Action WarmCoder

# Distill + performance plan + optional voice relay
powershell -File Send-CornermanWorkflow.ps1 -Action FullPerformance
```

**On Green (manual):**

```powershell
powershell -File C:\lifepunch\cornerman\Start-CornermanLmStudio.ps1 -WarmModel distill
powershell -File C:\lifepunch\cornerman\Start-CornermanLmStudio.ps1 -WarmModel coder
```

---

## Per-task rule (put in every inbox brief)

| Task type | Warm before start |
|-----------|-------------------|
| **Inventory project** — spec review, slots one-pager, llad UI notes | `WarmDistill` (P0 default) |
| **Inventory P2** — hotbar HUD `.razor.scss` draft (task 6 only) | `WarmCoder` — Opus on Red |
| Docs / distill / outbox summary | `WarmDistill` (or stay on default) |
| C# / Razor / scss draft | `WarmCoder` — then Opus on Red |
| Voice PTT only | Model irrelevant — STT is lifepunchnet |

**Off-Cursor (June 2026):** Green has no Cursor. If the brief does not say `WarmCoder`, assume **distill**.

---

## Current lpbitcoin slice routing

| Slice | Preferred route |
|-------|-----------------|
| Static Upgrades shell cleanup | Green Code or Composer; Opus optional review |
| 3-box Upgrades home launcher | Green Code candidate; VENGEANCE proof |
| GPU Rack target-home UI | Green Code candidate; VENGEANCE proof |
| U1 Servers status dashboard (read-only) | Green Code candidate first; Opus review optional |
| U2 Hub power/link cascade | **Opus plan required**; Green Code may implement candidate after plan |
| U3 CPU/Core → Compute Profile migration | Green Deep warm packet → **Opus required** |
| U4 full GPU Rack upgrade economy | **Opus required** |
| Hub upgrade effects | **Opus required** |
| Terminal defense/capability upgrades | **Opus required** |

Auto/Composer is fine for routine work (`AUTO OK`) but is **not** a routing guarantee. When a task says
`OPUS REQUIRED` / `GROK REQUIRED` / `GREEN CODE REQUIRED` / `GREEN DEEP REQUIRED`, the Integration
Architect must either switch to that route or stop and tell Bloodwave the required route is not active.
Auto may not silently substitute models for economy, persistence, `[Sync(FromHost)]`, RPCs, purchase
routing, migration, power/link state machines, or final major-slice review. **Canonical tag definition:**
`OPUS_USAGE_LAW.md` § Task route tags (mirrored in `MCP_AGENT_ROUTING.md` + the always-applied
`lifepunch-opus-usage` rule).

---

## Do not

- Run s&box / ModelDoc on Green for ship work
- Treat Qwen 2.5 output as done without Red review on economy, permissions, or multi-file integration
- Use Lemonade on Cornerman — STT is lifepunchnet `:9000`

---

## Inbox pointer

`C:\lifepunch\cornerman\inbox\GREEN-WORKFLOW-DIRECTIVE.json` — Red refreshes via `Push-CornermanWorkflowDirective.ps1`.

---

## LM Link (LM Studio remote models — preview, June 2026)

**Product:** [LM Link](https://lmstudio.ai/link) — LM Studio + Tailscale (`tsnet`) mesh. Load models on
a remote machine; use them on another as if local. E2E encrypted P2P; no public endpoints. Preview
rollout (LM Studio account; batched access).

### Fit in the LifePunch web

| | |
|--|--|
| **Host (GPU)** | Cornerman — distill / coder / embed on Green's Vulkan iGPU |
| **Client** | VENGEANCE — LM Studio desktop sees Green's models in the loader |
| **API surface** | Unchanged: `http://localhost:1234/v1` on the client; LM Link routes to remote weights |
| **LAN today** | Red still uses `Send-CornermanWorkflow.ps1` + SSH to warm models on Green; direct `http://192.168.1.227:1234` also works on subnet |

### What LM Link could simplify

- Off-LAN access to Green's models (travel, desk away from home LAN) without port-forward or SSH tunnels.
- One LM Studio UI on VENGEANCE listing local + remote models — tools already on `:1234` work unchanged.

### What LM Link does **not** replace

| Still separate | Why |
|----------------|-----|
| **Claude Bridge** | s&box viewport / playtest — LM Link is LLM inference only; agents stay **blind** without bridge |
| **Cornerman inbox/outbox** | Tier-3 distill handoff, `GREEN-WORKFLOW-DIRECTIVE.json`, patch flow |
| **lifepunchnet `:9000`** | Hosted Whisper STT — not LM Studio |
| **Tier routing law** | Green = prep/draft; Red / Opus = integration and ship |
| **`Send-CornermanWorkflow.ps1`** | Until adopted: still canonical for warm/switch on Green headless boot |

### Adoption status

**Not enabled yet** — document and evaluate when preview access is granted. Does not change v1
LAN-only posture in `LOCAL_AI_WORKSTATION.md` §6 until owner opts in.

**Enablement sketch (when ready):**

1. **Green:** LM Studio or `llmster` running; `lms login` → `lms link enable` (add to headless boot if headless).
2. **Red:** LM Studio with Link; link Green; load remote distill/coder from loader.
3. **Verify:** client `localhost:1234` serves a model whose weights live on Green; prompts stay E2E encrypted per LM Studio FAQ.

**Coexistence:** LM Link uses embedded Tailscale `tsnet` — per LM Studio FAQ, should not interfere with a full Tailscale tailnet if one is added later for other services.

**Refs:** `LOCAL_AI_WORKSTATION.md` §6 (networking), §7b (SSH/RDP), §7d (LM Link).  
**Stack updates:** `CVL_FULL_CAPACITY_UPDATES.md` · `Invoke-CvlFullCapacityRefresh.ps1`
