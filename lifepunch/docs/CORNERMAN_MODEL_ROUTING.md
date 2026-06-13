# Cornerman — model routing (when to switch)

**Box:** Green (Cornerman) · **Runtime:** LM Studio `:1234` · **Red warms from VENGEANCE**

Cornerman is **Tier-3 prep** — distill and draft, not production C# decisions. Red (VENGEANCE / Cursor Opus) owns integration.

**Eyes covered:** Green cannot see the game or the owner's screen. Say **Cornerman's eyes are covered**
before any visual, spawn, scale, or playtest claim — files and distills are not the viewport.

---

## Two models (not one)

| Mode | LM Studio model | Use when |
|------|-----------------|----------|
| **distill** (default) | `qwen/qwen3.6-35b-a3b` | Spec summaries, 10-line distills, inbox/outbox docs, RAG prep, work-queue hygiene |
| **coder** | `qwen2.5-coder-32b-instruct` | Multi-file C# **drafts**, Razor/scss first passes, terminal command tables — **Red must review before ship** |

**Default on boot:** `daily` = distill + embed (`Invoke-CornermanHeadlessBoot.ps1`). **Tier-3 catalog** = all three on disk; **Tier-3 serve** = distill + embed loaded — **not** both big models at once (~45 GB). Warm **coder** only when the brief says so.

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
