# CORNERMAN FOR AGENTS — How to Use the AI Workstation

> **Owner of the Cornerman-usage layer.** This doc teaches agents (primarily GitHub
> Copilot on VENGEANCE) when and how to offload work to Cornerman (Green) during
> active development sessions. Read `LIFEPUNCH_MISSION.md` for the why;
> `CVL_AGENT_ONBOARDING.md` for machine roles; `CORNERMAN_HEADLESS_DROP_WORKER.md`
> for worker internals. This doc owns the *agent-facing usage pattern* only.

---

## The machine model (non-negotiable)

- **VENGEANCE (Red) is the cockpit.** Editor, IDEs, git, verification, Bloodwave's
  eyes and hands. All human-facing work happens here. The only node with
  editor/gameplay truth.
- **Cornerman (Green) is an appliance.** No monitor, no IDE, no RDP for daily work.
  One job: hold a model warm on LM Studio (`:1234`) and process drop-worker packets.
  Text in, text out. It never opens the editor for dev work.
  - Sole exception: a Steam/s&box **test client** for 2-player testing — a body,
    not a workspace.
- **The handoff is files and prep, never synced editor sessions.** Cornerman needs
  the repo clone (`C:\Projects\lifepunch`) and a task packet — nothing else.

## What Cornerman does (and never does)

**DOES — the work that would otherwise interrupt Bloodwave's build flow:**
1. **Distill** — summarize canon, DECISIONs, long docs into what the current task
   needs ("the 5 constraints this panel must respect").
2. **Prep** — assemble escalation packets for Opus/Grok (pack files, summarize the
   problem, structure for review).
3. **Audit / compare** — check work against canon: naming/layout conformance,
   lane-cleanliness ("would this survive a clean vanilla DXRP pull?"),
   doc-vs-doc drift.
4. **Draft** — first-pass non-code text: addon docs, README stubs, TECH_DEBT
   entries, structured Markdown notes.

**NEVER:**
- Editor or game-facing work. Cornerman is blind by role — it cannot verify scale,
  materials, colliders, entity usability. That is Red's job, always.
- Ship decisions, commits, pushes, final authority. Tier-3 is untrusted:
  VENGEANCE compiles/proves, Bloodwave approves. Cornerman flags and drafts —
  smoke detector, not firefighter.
- Claiming verification of anything it cannot check. If eyes are needed, say so.

## Model policy — LOAD ONCE, NO PER-TASK SWAPS

Bloodwave loads **one** big model at session start and it stays warm all session.
JIT auto-load is OFF (deliberately — prevents VRAM contention). Agents must form
tasks for the **loaded** model, not the theoretically optimal one.

| Model | Route tag | Job | When |
|---|---|---|---|
| **Daily — `qwen/qwen3.6-35b-a3b`** | `GREEN DAILY REQUIRED` | Audits, drift reports (fast MoE) | **LIVE — session default for audits.** 76s proven on a live drift audit where Deep timed out. |
| **Deep — `qwen/qwen3.6-27b`** | `GREEN DEEP REQUIRED` | Light distill/prep only (demoted — audit-size prompts time out) | Load for distill/prep drafting sessions. |
| **Code — `qwen2.5-coder-32b-instruct`** | `GREEN CODE REQUIRED` | Contained C#/Razor/SCSS candidate patches | Deliberate "coding mode" swap only. Rare. Red compiles/proves everything. |
| embed — nomic-embed-text-v1.5 | — | RAG embeddings | Tiny; can stay resident always. |

**Runtime rules (violating these caused hours of failures — they are law):**
- ONE big model in VRAM at a time. `neverLoadTogether: [distill, coder]`.
- **Thinking is enforced OFF per-request by the worker** (`chat_template_kwargs:
  enable_thinking=false` in the request body). LM Studio UI toggles do NOT govern
  API calls — never rely on them. Thinking ON + large prompt = model burns its
  output budget reasoning and returns empty (`finish_reason: length`).
- **Default Context Length = Custom 32000.** Never Model-maximum on unified
  memory.
- **Runtime auto-update OFF.** **Max idle TTL 240.**
- Context math: 27b loads at 32k tokens. Keep packed inputs (canon + drift files)
  under ~86k chars. Big single files (e.g. `LOCAL_AI_WORKSTATION.md`) get their
  own packet.
- `callTimeoutSec` is 900 in the live config. Expect ~3–8 min per Deep task.

## The offload pattern (how an agent actually uses the queue)

When Bloodwave states the session's work ("I'm building the Terminal panel"),
the agent:

1. **Names the session model.** Default: *"Load Daily (35b-a3b), only model."*
   Deep (27b) only for light distill/prep drafting sessions; Code for
   candidate-patch coding. (Thinking is enforced off by the worker per-request.)
2. **Recognizes offload moments** — anything matching DOES above that would pull
   Bloodwave out of the editor. Proactively offers: *"Cornerman can distill
   DECISION-0010 + the Hub arch while you build — want me to queue it?"*
3. **Forms the packet** with `New-CornermanTaskPacket.ps1`
   (`lifepunch/scripts/cornerman/`):
   - `-RepoProfile lifepunch-private` (or `dxrp-official` for upstream work —
     the profile's `forbidInputPrefixes` blocks proprietary paths; never bypass)
   - `-RouteTag` for the **loaded** model
   - `-Type` distill|audit|summarize|... · mode is always `report` (builder-enforced;
     patch mode is unreachable — the worker rejects it)
   - `-RequiredDocs` = the canon the task grounds on (mission, CVL, DECISIONs)
   - `-ReadFiles`/`-ReadGlobs` = the target files (worker reads ONLY cited files)
   - `-RequestModelCall -RequiredModel <exact model id>`
   - For audits, use the sharp instruction: *"List a finding ONLY when canon and
     an input give two different non-empty values for the same field. Do NOT list
     omissions, identical values, or phrasing differences."*
4. **Drops it:** `Send-CornermanTaskPacket.ps1` (SSH-base64, SHA256-verified —
   the proven transport; SMB bridge is a future upgrade).
5. **Gives Bloodwave the one-line trigger** to run ON GREEN:
   `powershell -NoProfile -File C:\Projects\lifepunch\lifepunch\scripts\cornerman\Invoke-CornermanWorkerOnce.ps1 -EnableModelCall`
   — run SYNCHRONOUSLY **on the box ONLY** (paste into a Green terminal / one RDP
   admin window). SSH-launched runs have killed two live runs — the trigger is
   never launched over SSH, detached or otherwise (Start-Process dies on
   disconnect), never polled with CIM/WMI (hangs under load), never schtasks
   (no-scheduler law).
6. **Collects:** `Get-CornermanLatestReport.ps1 -ShowContent` (from Red) and tells
   Bloodwave the result is in and he's clear to proceed.

## Fast-fail discipline (all Green operations)

No retries. No detach. No polling loops. No self-healing. Any error or hang past
~20s (file/state ops) → abort, report the RAW error + state, STOP for diagnosis.
Errors go to the diagnostic layer (Bloodwave/Claude); agents do not work around
transport failures on their own.

## Lane discipline

- LIFEPUNCH work → `lifepunch-private` profile. DXRP-official work → the
  `dxrp-official` profile, whose forbid-prefixes block all LIFEPUNCH paths
  (including via `requiredDocs` — enforced in code). Never mix.
- The universal test for anything near the lane boundary: **"Would this survive a
  clean vanilla DXRP pull?"** (see `LIFEPUNCH_MISSION.md`).

## Session bootstrap (Bloodwave's two-minute startup)

1. Cornerman on → LM Studio → load the session model (default **Daily/35b-a3b**;
   context length Custom 32000). Leave it warm all session. JIT stays OFF.
2. Vengeance: open the editor + Copilot. State the session's work.
3. Agent names the model (confirm it matches what's loaded), then offers offloads
   as they arise. Bloodwave runs triggers when given; agent collects and reports.

## Deferred (do not attempt without explicit Bloodwave GO)

- **SMB work-queue bridge** (share Green's inbox/outbox → mounted by Red):
  transport upgrade, must be built interactively on-box (SSH sessions can't
  persist `net use` to the desktop session). Not a prerequisite.
- **Any scheduler / unattended automation.** The worker stamps
  `scheduler-install` in `actionsNotPerformed` by design.
