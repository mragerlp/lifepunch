# Cornerman — model routing (when to switch)

**Box:** Green (Cornerman) · **Runtime:** LM Studio `:1234` · **Red warms from VENGEANCE**

Cornerman is **Tier-3 prep** — distill and draft, not production C# decisions. Red (VENGEANCE / Cursor Opus) owns integration.

---

## Two models (not one)

| Mode | LM Studio model | Use when |
|------|-----------------|----------|
| **distill** (default) | `qwen/qwen3.6-35b-a3b` | Spec summaries, 10-line distills, inbox/outbox docs, RAG prep, work-queue hygiene |
| **coder** | `qwen2.5-coder-32b-instruct` | Multi-file C# **drafts**, Razor/scss first passes, terminal command tables — **Red must review before ship** |

**Default on boot:** `distill` (`Invoke-CornermanHeadlessBoot.ps1`). That is why Cornerman is **not** on Qwen 2.5 unless someone explicitly warms **coder**.

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
