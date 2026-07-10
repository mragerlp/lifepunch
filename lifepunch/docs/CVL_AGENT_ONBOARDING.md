# CVL AGENT ONBOARDING — the one paste (LIFEPUNCH™ × DXRP)

> **THE single grounding document.** Claude Code READS this file from the repo (grounding order:
> `CLAUDE.md` → `START_HERE_AGENTS.md` → this file → the active handoff brief). Per the Transport Law
> (2026-07-09, `CLAUDE.md`), do NOT rely on pasting long files between Chat and Code — long pastes are a
> known hazard; briefs travel as repo-tracked files. When you finish reading you are grounded on: who we
> are, the history, the two work lanes, the hardware, the AI/MCP/LLM stacks, the workflow, the laws, and
> the current state.
>
> **This file is canonical in `lifepunch/docs/CVL_AGENT_ONBOARDING.md`.** `CLAUDE.md` at the repo root is
> Claude Code's first grounding read and the authoritative doctrine; if this file ever disagrees with
> `CLAUDE.md`, **`CLAUDE.md` wins** — then update this file in the GitHub monorepo (never patch only a clone).
>
> **Owner:** Bloodwave (legal author **mrragerlp** · mrragerlp@lifepunch.co; git commits **mragerlp**).
> **Repo:** `github.com/mragerlp/lifepunch`. **Updated:** July 2026.
>
> **New here?** Start at **`lifepunch/docs/START_HERE_AGENTS.md`** (thin router) — then read this whole file.
>
> **Shared worktree:** one writable agent per `lifepunch` worktree — before switching lanes, park or commit dirty work per `lifepunch/docs/WORKTREE_LANE_SAFETY.md`.

---

## 0. IF YOU READ NOTHING ELSE (10-line boot)

1. **`git pull --rebase`** on **`develop`** (Red/Mac WIP) or **`main`** (Cornerman distill) **before** doing anything.
2. **Name your node** (Red / Green / Blue / Architect) and **your surface** (Claude Code = primary build ·
   Claude Chat = plan · Codex = review). **CVL** = Cornerman · Vengeance · lifepunchnet (Green · Red · Blue).
   Architect (Mac) is outside CVL.
3. **Pick your LANE — this is the most important decision:**
   **LIFEPUNCH proprietary** (`mragerlp/lifepunch`) **OR DXRP official** (`mragerlp/dxrp-public` → `dxura/dxrp`). They have **different repos, headers, and rules. Never mix them.**
4. **Read your lane's MANDATORY READS (§12). You are not grounded until you do. Do not skip the repo.**
5. **Route by layer (§7, per `CLAUDE.md`):** Plan in Chat (Fable → Opus → Sonnet) · Build in Claude Code (Opus) · Review with Codex · Cornerman distills and feeds planning. Grok/Cursor are outside the loop, on request only.
6. **Editor truth lives on Vengeance (Red)** — all 3 s&box MCPs bind there. Cornerman reaches them over the bridge. **Runtime proof before "done";** use flatgrass / `lp_map_flatgrass` when appropriate as the low-demand proof map (Red Host Play) — not a universal requirement for every change.
7. **Never commit unprompted.** Propose scope → wait for Bloodwave **GO** → commit as `mragerlp <mragerlp@gmail.com>` with **no AI trailers**.
8. **Eyes-covered law:** no visual/playtest claim without an `sbox` bridge screenshot from Red.
9. **Owner gates:** design/economy/publish need Bloodwave **GO**. "No code during a docs/canon pass."
10. **End every turn with a HANDOFF BATON block (§10).** That is how the orchestra passes work without Bloodwave re-steering.

> **RE-GROUND ON PULL (law):** whenever you `git pull` and it brings in a change to this document or the
> relay baton, you must do a **full `git pull --rebase`** and then **re-read this whole file + your lane's
> mandatory reads (§12)** before resuming. A change here means the ground moved — never act on stale
> grounding, and never continue an old chat's assumptions past a pull.

---

## 1. Who we are

**LIFEPUNCH™** (legal entity **Peak Performance Products LLC**) is the **largest community** running **DXRP**,
the source-available DarkRP-style roleplay game by **Dxura / Dimmer**, built on **s&box** (Facepunch's
Source 2 engine). We build **proprietary** custom content — weapons, entities, jobs, staff/admin tooling,
UI, economy, server ops — for **our** LIFEPUNCH servers and to license to other DXRP servers.

The owner, **Bloodwave**, drives everything through **CVL** — Cornerman · Vengeance · lifepunchnet
(Green · Red · Blue), plus a coordinated team of AI Architects and **Architect** (Mac planner) on the side.
Treat this as a **business**: be direct, protect the IP, ship quality.

Two jobs exist here, and you must always know which one you are doing:

- **LIFEPUNCH work** — proprietary content for Bloodwave's community (our IP, our servers).
- **DXRP official work** — contributions to Dimmer's upstream game (his IP, his rules, his review).

---

## 2. The history — why this work is delicate (know it, respect it)

You are standing on 20 years of lineage. Do not treat it casually.

1. **Valve → Steam → Source 1.** Valve built the Source engine and Steam, the foundation of PC modding.
2. **Garry's Mod (GMod).** Garry Newman's sandbox on Source 1 became a modding legend.
3. **DarkRP** became the **most popular gamemode in Garry's Mod** — the definitive "serious RP economy"
   experience (jobs, money, doors, printers, crime, police).
4. **Garry got Source 2 from Valve** and built **s&box** — the spiritual successor to GMod on Source 2.
5. **DXRP by Dxura/Dimmer** is the **most popular game on s&box** and the **closest thing to Source 2
   DarkRP** — the natural heir to DarkRP's throne.
6. **LIFEPUNCH is the top community running DXRP** — community servers, custom addons, and content. We
   were **one of the biggest communities from the Garry's Mod era**, and we carry that forward on s&box.

**Why delicate:** we are a **flagship partner-community** on the most important RP game on a young engine.
Our proprietary content is defended IP; Dimmer's game is his defended IP. Sloppy work, leaked IP, broken
compatibility, or a bad public commit reflects on the whole lineage. **Quality and cleanliness are not
optional — they are the reputation.**

---

## 3. THE TWO LANES — the hard gate (read this twice)

**Before any work, declare your lane.** This is the #1 source of costly mistakes.

| | **LIFEPUNCH (proprietary)** | **DXRP OFFICIAL (upstream)** |
|---|---|---|
| **Repo** | `github.com/mragerlp/lifepunch` (private monorepo) | `github.com/mragerlp/dxrp-public` (our fork) → PR to `github.com/dxura/dxrp` |
| **Clone (Red)** | `C:\Users\jared\Projects\lifepunch` (monorepo root; nested mirror `lifepunchdxrp/`) | `C:\Users\jared\Projects\dxrp-public` (separate official-upstream clone) |
| **Branch** | **`develop`** = active work/testing/finalization · **`main`** = finalized truth | `bounty/*` or `lifepunch/fix-*` cut from `upstream/develop` |
| **Owner** | Bloodwave (ours) | Dxura/Dimmer (theirs — **All Rights Reserved**, source-available) |
| **File headers** | **PROPRIETARY & CONFIDENTIAL © 2026 lifepunch.co** block on every `.cs`/`.razor`/`.scss` | **DXRP conventions only — NO LIFEPUNCH headers** |
| **Rules** | `.cursor/rules` + this doc | `dxura/dxrp` `CONTRIBUTING.md` + `CLA.md` + `.editorconfig` |
| **Commit** | owner GO; `mragerlp`, no AI trailers | issue-first, small scoped PRs; `mragerlp`, **no AI trailers (public!)** |

**Editor instance per lane:**
- **DXRP official** needs a **clean vanilla lane running the latest DXRP `develop` fork** — no LIFEPUNCH
  addons mounted, no `lp_*` ConCmds, no `game/Libraries/*` MCP dev tools committed. Gate:
  `Ensure-DxrpUpstreamCurrent.ps1 -Sync -UpdatePin -SyncSteam`.
- **LIFEPUNCH work** can run in **any** s&box editor instance with our addons mounted — **right now the
  active session is `lpbitcoin`** (bitcoin mining lane). Mount with
  `Sync-LifePunchAddonsToDxrp.ps1 -Addon lpbitcoin`.

**NEVER:**
- Put LIFEPUNCH IP (headers, `lifepunch/` paths, branding, bitcoin/addon code) into the DXRP fork.
- Treat DXRP upstream code as ours to relicense/ship — it is Dxura's.
- Add `dxura/dxrp` as a remote inside the LIFEPUNCH monorepo.
- Commit from the Steam checkout `D:\Steam\steamapps\common\sbox\dxrp` (runtime only).

**DXRP contribution rules (verbatim intent from `CONTRIBUTING.md` / `CLA.md`):** source-available, **not**
open source; **open/claim an issue before large features** (scope + acceptance agreed first); contribute
only through Dxura-approved channels; forks exist **only** to prepare a PR back to Dxura (not to run a
separate DXRP); bounties count **only** when Dxura posts/assigns/confirms them; submission never
guarantees merge/attribution/compensation. Full lane law: **`DXRP_CONTRIBUTOR_LANE.md`**.

**Note on `lifepunchulx`:** our admin menu (`adminmenu` → package `lifepunchulx`) is **opened to all DXRP
servers for free — but not for resale**. Everything else LIFEPUNCH is proprietary and defended.

---

## 4. The hardware stack — the LifePunch web (4 nodes)

The machines are **nodes in one web**, not separate boxes. Colors are **primaries** (R/G/B), not nicknames.

| Node | Machine (spec) | Role | Repo path | Net |
|------|----------------|------|-----------|-----|
| **Red — VENGEANCE** | Corsair Vengeance (ASUS PRIME Z790-P WIFI, LGA1700) · i9-12900KS · **RTX 4090 24GB** · 64GB DDR5 · Win 11 Pro · 2×2TB NVMe (Corsair MP600 CORE XT) | **Orchestrate · s&box editor · all 3 editor MCPs · flatgrass proof · git push.** Bloodwave's **true eyes** — the only node that sees real-time editor/gameplay truth. | `C:\Users\jared\Projects\lifepunch` | LAN `192.168.1.236` |
| **Green — Cornerman** | Corsair AI Workstation 300 · **Ryzen AI Max 385** · Radeon 8050S iGPU (up to **48GB VRAM**) · **64GB LPDDR5X** · 1TB · Win 11 Pro | **Warm LM · distill · heavy headless agent implementation · MCP bridge relay.** Segway between Architect and Vengeance. **No editor of its own** — tunnels into Red's editor. Read-only deploy key → **patch-handoff** to Red. | `C:\Projects\lifepunch` | LAN `192.168.1.229` |
| **Architect — MacBook** | MacBook Air **M2** (2022) · **8GB RAM** · macOS Tahoe 26.5.2 | **Design Architect host (ChatGPT) · planner · native Cursor + Copilot · RDP → Green.** Keep it light (8GB) — ideation + comms, not heavy compute. Editor MCP not required (capable if recommended). | `~/Projects/lifepunch` | — |
| **Blue — LifepunchNET** | B650D4U-2L2T/BCM · **Ryzen 9 9950X3D** · 96GB DDR5 · 4TB NVMe · 1Gbps · Win 11 Pro | **Hosted server host.** Runs **LIFEPUNCH Official (Server 1, public)** + **Development (Server 2, addon testing before shipping to Server 1)**, Odysseus voice, Whisper STT, watchdog. Editor sessions reachable via API. **Not** DXRP Official (that is Dimmer's separate host). | `C:\lifepunch\lifepunch-rdp-server` | `205.209.104.22` |

**One-line disambiguation:** Red = runtime truth + push · Green = warm/distill/execute · Architect =
planner on Mac · Blue = hosted venue (our servers). Full detail: **`MACHINE_CAST.md`**.

> Legacy: the monorepo clone was `C:\Users\jared\Projects\lifepunchdxrp` at Projects root; product addons lived under `lifepunch/addons`. **Current:** clone `C:\Users\jared\Projects\lifepunch` with product tree **`lifepunchaddons/`** at repo root and nested **`lifepunchdxrp/`** for the DXRP fork.

---

## 5. The role stack — CVL Architect family (roles ≠ machines)

| Role | Host | Core question | Ships code? |
|------|------|---------------|-------------|
| **Bloodwave** | Owner (Red desk) | *"Is this what the player needs to see?"* — ideas, QA, GitHub issues, final GO | Final authority |
| **Design Architect** | **ChatGPT** — Mac (primary) · Red (at desk) | *"Does this make the game better?"* | **No** — CURSOR BRIEFs + design docs |
| **Integration Architect** | **Claude Code (Opus)** — Red (build + push-prep) · Codex (diff review) · Cornerman (distill only) | *"Does this match repo law and ship criteria?"* | **Yes** (owner GO; Codex reviews the diff) |
| **Distillation Architect** | **Cornerman LM** (Tier-3, Green) | *"Can this be distilled cheaper for Red?"* | No — outbox candidates only |
| **Operations Architect** | **RDP agent** on lifepunchnet (Blue) | *"Does hosted ops match Bloodwave intent?"* | Ops scripts under owner authority |

**Opus is the primary Claude Code implementer** (2026-07-09 doctrine, `CLAUDE.md`); Codex reviews the diff.
Grok/Cursor are retired to optional outside second opinion, on request only. Canon: **`CLAUDE.md`**,
**`ARCHITECT.md`**, **`MACHINE_CAST.md`**.

---

## 6. The AI / IDE stack — who does what (and why)

> **Doctrine 2026-07-09 (see `CLAUDE.md`):** `PLAN IN CHAT · BUILD IN CODE · REVIEW WITH CODEX · SHIP ONLY WITH BLOODWAVE GO`. Claude Code (Opus) is the primary implementation and editor surface.

| Layer | Tool | Use it for |
|------|------|-----------|
| **Plan** | **Claude Chat** (Fable → Opus → Sonnet) | Scope, edge cases, rulings, STOP-GO, handoff briefs. No repo edits unless asked. |
| **Build** | **Claude Code (Opus)** — primary | Repo edits, tests, s&box editor work, Sensor-Law gates, diff + proof. Commits only after a passing gate + Bloodwave GO. |
| **Review** | **Codex** | Reviews the diff post-build, pre-merge: PASS / REVISE / HOLD. Never re-litigates rulings. |
| **Green** | **Cornerman** (Tier-3, Green) | Distill / prep / audit / draft; feeds the planning layer. Flags, never decides; never ships. |

**Rule of thumb:** Chat plans it → Code builds it → Codex reviews the diff → Red proves it → Bloodwave
approves it. **Grok / Cursor are retired from the standard loop** — an optional outside second opinion on
request only, originating no deliverables (legacy dual-IDE detail: `DUAL_IDE_CURSOR_VSCODE.md`, kept for
reference only).

---

## 7. The LLM / model-routing stack — route by layer (supersedes the old tier tables)

We run best-in-class but **every token is real $USD**. The 2026-07-09 doctrine (`CLAUDE.md`) replaces the
old Tier-1/2A/2B ceiling model with a layer model — plan, build, review, Green:

| Layer | Model | Lane |
|------|-------|------|
| **Plan** | **Fable** (Chat) → Opus (heavier: architecture, canon, hard bugs) → Sonnet (budget: summaries, cheap docs) | Scope, edge cases, roadmap, briefs, rulings |
| **Build** | **Opus (Claude Code)** — primary | Repo edits, tests, s&box editor work, hard runtime debugging |
| **Review** | **Codex** | Diff review only: PASS / REVISE / HOLD |
| **Green** | **Cornerman** (Qwen Daily via LM Studio) | Distill / prep / audit / draft; feeds planning; never ships |
| *outside* | *Grok / Cursor* | *optional second opinion, on request only — not in the standard loop* |

Any task that CAN and SHOULD be done by Claude Code IS done by Claude Code. High-stakes surfaces
(economy, persistence, `[Sync(FromHost)]`, RPCs, purchase routing, migration, power/link state machines)
still require a plan first and Bloodwave GO — that discipline is unchanged; only the model names moved.

**Claim-labelling law (applies to any technical answer — Chat, Code, or Green):** label claims as
`VERIFIED FROM REPO` (file+line) / `INFERRED FROM PATTERNS` / `NEEDS SBOX-EDITOR PROOF` /
`NEEDS SBOX RUNTIME PROOF` / `OWNER DECISION REQUIRED` / `OUT OF SCOPE`. (Formerly the "Grok Output Law";
Grok is now on-request-only, so the labelling discipline transfers to whoever answers.) High-stakes
surfaces — gameplay authority, economy, permissions, security, migration, networked persistence,
cross-addon architecture, >1 substantial C# subsystem — need a plan first and Bloodwave GO. Canon:
**`CLAUDE.md`**, **`MCP_AGENT_ROUTING.md`**, **`CORNERMAN_MODEL_ROUTING.md`**.

**Four-phase workflow (major tasks, per `CLAUDE.md`):** (1) plan in Chat → (2) build one slice in Claude
Code → (3) flatgrass proof (Red) → (4) Codex diff review. lpbitcoin scope: **Hub → Terminal → GPU Rack** in order.

---

## 8. The MCP stack — editor truth binds to Vengeance (Red)

**All three s&box editor MCPs run in the Vengeance editor session. Cornerman does NOT run the editor — it
reaches these tools over the bridge (SMB + SSH tunnel).** Full wiring: **`SBOX_EDITOR_MCP.md`**; task→MCP
routing: **`MCP_AGENT_ROUTING.md`**.

| Cursor key | Marketplace package | Transport | Owns |
|------------|--------------------|-----------|------|
| **`sbox`** | `sboxskinsgg.claudebridge` ([claudebridge](https://sbox.game/sboxskinsgg/claudebridge/)) | **file IPC** (`%TEMP%\sbox-bridge-ipc`) | **After Play:** runtime C#, logs, in-game screenshots, `lp_spawn_*` / `lp_map_flatgrass` ConCmds — **the eyes.** Also editor automation + reference: scene graph, components, file inspect, docs/API search |
| **`sbox-editor`** | `notpointless.chomnr_mcp` ([chomnr_mcp](https://sbox.game/notpointless/chomnr_mcp)) | HTTP `:9090/sbox-mcp` | **Authoring compile:** ModelDoc, ShaderGraph, prefab, vmat, undo. Optional [chomnr_humanoid_retargeter](https://sbox.game/notpointless/chomnr_humanoid_retargeter) imported as chomnr tools |
| **`cornerman-lm`** | `local-llm-mcp-server` (node) → LM Studio | `:1234` (Green localhost; Red uses LAN URL) | Tier-3 distill / prep on Cornerman |

**Curated stack (2026-07-08):** `jtc.mcp-server` and `ozmium.oz_mcp` **uninstalled** — claudebridge
absorbed jtc's surface. Situational lane: `sboxcool.network-storage` mounts only when a task explicitly
names it — never a silent dependency. **Boot-order law:** editor first, THEN the agent session (or `/mcp`
reconnect) — HTTP editor MCP servers live in-editor and do not retry like the file-IPC bridge.

**Copilot (VS Code) equivalents:** `claudebridge` · `chromr-mcp` (via `.vscode/mcp.json`).

**Full-capacity bar (Red, every session):** Cursor MCP **3/3 green** (`sbox` + `sbox-editor` +
`cornerman-lm`) · editor pill green + `MCP · ≥1` (chomnr) · Claude Bridge `connected` heartbeat <30s.
Probe: `Get-CvlConnectivityStatus.ps1 -Pretty`. Refresh after any stack change:
`Invoke-CvlFullCapacityRefresh.ps1`.

**Cornerman bridge (Green triple stack):** `sbox` via SMB `\\VENGEANCE\SboxBridgeIpc`, `sbox-editor` via
SSH tunnel `localhost:9090`, `cornerman-lm` local. Preflight (Red editor up first):
**Map → Tunnel → `Test-Path \\VENGEANCE\SboxBridgeIpc\status.json`**.

**MCP law:** playtest/screenshots → `sbox` · compile/ModelDoc/vmat → `sbox-editor` · scene/docs → `sbox`.
Never claim visual verification without the right server connected. After `execute_csharp`, always sweep
`Editor/__Exec_*.cs`.

---

## 9. The software stack

| Software | Where | Purpose |
|----------|-------|---------|
| **LM Studio** | Cornerman only (`:1234` headless) | Tier-3 local inference — 3 Qwen profiles routed by task (Code / Deep / Daily-Fast). **Never on Red** (competes with editor RAM). |
| **Ollama** | Cornerman (secondary local) | Alt local model host / embeddings when needed |
| **Claude Code (Opus)** | Red (primary) | **Primary build surface** — repo edits, tests, s&box editor work, Sensor-Law gates. Grounds on `CLAUDE.md` first. |
| **Claude Chat** (Fable → Opus → Sonnet) | any | Planning layer — scope, rulings, handoff briefs |
| **Codex** | Red | Diff review — PASS / REVISE / HOLD, pre-merge |
| **Cursor / GitHub Copilot** | Red · Cornerman · Mac | Legacy IDEs — optional outside second opinion **on request only** (2026-07-09 doctrine); MCP servers may still be configured here. Not in the standard loop. |
| **ChatGPT** | Mac (primary) · Red | Design Architect (ideation, briefs) |
| **Odysseus** | Blue (lifepunchnet) | Voice comms host (Cornerman can use); optional today |

**Recommendations (open lane — adopt when Bloodwave GO):** keep LM Studio as the single Tier-3 host on
Cornerman; use Ollama only if a model isn't available in LM Studio. No new tools needed for the current
lpbitcoin scope — the bottleneck is **handoff clarity**, not tooling (see §10).

---

## 10. THE CVL ORCHESTRA — the domino + the handoff baton (the fix for "missing signals")

**The problem Bloodwave named:** agents don't signal each other, so work stalls and Bloodwave has to
re-steer every new chat. **The fix:** a fixed **handoff baton** every agent emits at the end of its turn,
plus a durable baton file so a **fresh chat is instantly grounded on "where we are / what's next."**

### 10.1 The corrected orchestra (one clean pass — no impossible steps)

```text
1. BLOODWAVE      idea / GitHub issue / player-experience intent            (Red desk — the eyes)
2. DESIGN ARCH    "Does this make the game better?" → design brief          (ChatGPT · Mac primary · no git)
3. PLAN           scope + edge cases + rulings + handoff brief             (Claude Chat: Fable → Opus → Sonnet)
4. DISTILL        warm context + tighten packet (+ optional candidates)    (Cornerman Tier-3 · outbox · feeds PLAN)
5. BUILD          build the slice, gate with the Sensor Law                (Claude Code / Opus on Red — primary)
6. PROVE          flatgrass Host Play + lp_spawn + screenshot              (RED ONLY — sbox bridge)
7. REVIEW         diff review: PASS / REVISE / HOLD                        (Codex · pre-merge)
8. FANTASY CHECK  "Does it still feel like LIFEPUNCH?" (major → Arch Review)(ChatGPT design pass)
9. CHECKPOINT     propose scope → Bloodwave GO → commit/push               (Red push · other nodes pull)
10. PUBLISH       export lane when portal-ready (owner GO)                  (Red script)
```

**Key correction to the prior flow:** Cornerman does **not** do in-editor QA — **by role** it runs headless (no IDE), not for lack of hardware. Its "QA"
is **code review, distillation, and candidate patches** — **in-editor QA and the eyes are always Red +
Bloodwave.** This removes the Cornerman↔Vengeance ping-pong that was causing the confusion. Cornerman is
**warm-up and heavy hands**, not the proving ground.

### 10.2 The HANDOFF BATON (paste at the end of every agent turn)

```text
── CVL HANDOFF ──
FROM:   <Red|GreenB|GreenA> / <Claude Code|Claude Chat|Codex|Cornerman> / <model>
LANE:   <LIFEPUNCH lpbitcoin | DXRP dxrp-public#issue>
DID:    <1–3 lines: what changed / what was decided>
STATE:  <PROVEN on flatgrass | NEEDS PROOF | PLAN ONLY | BLOCKED:<why>>  · route tag if any
NEXT:   <the single next action>
TO:     <who picks it up: Red implement | Green distill | Architect review | Bloodwave GO>
PASTE:  <exact file/paste the next node should open, e.g. handoff/CHATGPT_STEP1_PASTE.txt>
COMMIT: <none | proposed scope awaiting GO | committed <hash>>
```

Bloodwave (or the agent, if same node) relays the baton to the next node. **This is how the orchestra
signals hand-offs without you re-explaining context.**

### 10.3 The durable baton file (survives new chats)

Current relay state lives in **`lifepunch/docs/handoff/CVL_RELAY_BATON.md`** (committed on Red). A new chat
reads **this onboarding doc + the baton** and knows exactly where the work stands and what to do next.
Cornerman writes to `handoff/cornerman-outbox/`; Red absorbs into one commit.

**Emit / update the baton with one command** (Red, git-based signal bus — complements the live SSH
transport in `Send-CornermanWorkflow.ps1`):

```powershell
powershell -File lifepunch\scripts\Send-CvlHandoff.ps1 -From "Red/Cursor/Opus" -Lane "LIFEPUNCH lpbitcoin" -Did "…" -State "NEEDS PROOF" -Next "…" -To "Red prove" -Signal cornerman
```

It rewrites LATEST (archiving the prior baton to HISTORY), prints the baton for copy/paste, and optionally
drops a `to-<node>-*.txt` signal into `cornerman-outbox/`. It does **not** commit — owner gate holds.
**First-time broadcast to every node:** `handoff/CVL_FIRST_BROADCAST.txt`.

### 10.4 Sync law (mandatory)

Whoever did heavy work → the other nodes **`git pull --rebase`** before their next session. Cornerman uses a
**read-only deploy key** — local commits OK, origin via **patch-handoff on Red**
(`Pull-CornermanPatches.ps1 -Push`; quickref `handoff/GREEN_PATCH_HANDOFF_QUICKREF.txt`). Full model:
**`GREEN_EXECUTION_MODEL.md`**.

**Cornerman branch nuance:** Cornerman defaults to **`main`** as a clean truth mirror / export-stability reader;
it may read **`develop`** only when the inbox task explicitly targets active work, current testing, or a
`develop`-bound audit. Green stays read-only / distill / outbox unless Bloodwave explicitly opens a patch-handoff lane.

---

## 11. Session boot — per node + IDE

**Every session:** `git fetch` → if clean, `git pull --rebase` → read this doc → confirm node + lane →
read your lane's mandatory reads (§12) → confirm MCP/route → emit an opening baton, then work.

| Node / IDE | Grounding paste (in `lifepunch/docs/handoff/`) |
|------------|-----------------------------------------------|
| **Red · Cursor** | `RED_CURSOR_GROUNDING_PASTE.txt` (+ `RED_FULL_CAPACITY_BOOT.md`) |
| **Red · Copilot** | `RED_COPILOT_GROUNDING_PASTE.txt` |
| **Green B (Cornerman) · Cursor** | `GREEN_CORNERMAN_CURSOR_GROUNDING_PASTE.txt` (+ `GREEN_SMB_BOOT_PASTE.md`) |
| **Green B (Cornerman) · Copilot** | `GREEN_CORNERMAN_COPILOT_GROUNDING_PASTE.txt` |
| **Green A (Mac) · Cursor** | `MAC_GREEN_CURSOR_GROUNDING_PASTE.txt` |
| **Green A (Mac) · Copilot** | `MAC_GREEN_COPILOT_GROUNDING_PASTE.txt` |
| **Any · ChatGPT (Design Architect)** | `ARCHITECT_ONBOARDING_PASTE.txt` |
| **DXRP official session** | `DXRP_PARTY_CURSOR_BOOTSTRAP_PASTE.txt` (or Block F in `AGENT_PROMPT.md`) |

Master index of pastes: **`handoff/AGENT_GROUNDING_INDEX.md`**. Quick per-machine one-liners:
`*_SESSION_FIRST_MESSAGE.txt`.

---

## 12. MANDATORY READS — DO NOT SKIP THE REPO

**You are NOT grounded until you have opened and read your lane's list. Do not claim grounding or start
work otherwise.** These force full-repo understanding without pasting every file.

### Always (any LIFEPUNCH session)
1. `lifepunch/docs/CVL_AGENT_ONBOARDING.md` (this file)
2. `lifepunch/docs/BRANCH_MODEL.md` — **`main` = truth**, **`develop` = test**
3. `lifepunch/docs/MACHINE_CAST.md` — nodes + roles
4. `lifepunch/docs/GREEN_EXECUTION_MODEL.md` — three-group workflow + sync law
5. `.cursor/rules` (alwaysApply) — **repo law (wins over this doc)**
6. `lifepunchaddons/docs/ACTIVE_WORKSTREAM.md` — the single active lane gate
7. `README.md` (repo root) — 8-step boot + domain map
8. `lifepunch/docs/handoff/CVL_RELAY_BATON.md` — current relay state

### Product / gameplay (design, UX, economy)
`LIFEPUNCH_GAMEPLAY_LAWS.md` (G0–G9 + Fantasy Check) · `LIFEPUNCH_FEEL.md` · `TERMINOLOGY.md` ·
`DECISIONS/README.md` + cited `DECISION-0001…0010` · `addons/docs/BITCOIN_PLAYER_DESIGN.md`.

### Entity / ModelDoc / machine work
`addons/docs/LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md` (machines, not props; P0–P4) ·
`MODEL_FOUNDATION_PASS.md` · `MODELDOC_STUDIO_LANE.md` · `PACKAGE_STAGING_LAYOUT.md` ·
`DXRP_ADDON_PUBLISH_DOCTRINE.md` · `CYBER_REFERENCE_LAWS.md` · bitcoin: `BITCOIN_SHIP_ROADMAP.md`.

### Weapons (parallel track)
`addons/docs/LIFEPUNCH_WEAPON_IMPLEMENTATION_LAW.md` · `WEAPON_INTAKE.md` · `VIEWMODEL_RIG_PIPELINE.md`.

### DXRP OFFICIAL lane (switch brain)
`lifepunch/docs/DXRP_CONTRIBUTOR_LANE.md` (first) · `DXRP_DOCS_REFERENCE.md` · upstream
`dxura/dxrp` → `CONTRIBUTING.md`, `CLA.md`, `LICENSE.md`, `game/.editorconfig`, `game/rp.sbproj`.

### DXRP repo shape (so you understand the game you build on)
Everything is under `game/` (namespace `Dxura.RP.Game`, `game/rp.sbproj`, startup `scenes/game.scene`,
`LaunchMode: DedicatedServerOnly`). Systems in `game/Code/`: `Player/`, `Entity/`, `Equipment/`
(Weapon + Tool), `Construct/`, `World/` (Door/, Atm, Elevator…), `System/` (Admin, RP/Governance, Party,
Minigame, Event, Recovery), `Chat/Commands/`, `Sentinel/` (anti-cheat), `Api/` (dxrp.net economy/identity),
`UI/` (Razor + SCSS), `Config/` (data-driven). Jobs/economy are **backend-driven** from dxrp.net via
`game/Code/Api/`. Match this style; never copy it into LIFEPUNCH IP or vice-versa.

### LIFEPUNCH repo shape
All product/platform/business/tooling under `lifepunch/`. s&box code = one umbrella project
`lifepunchaddons/addons.sbproj` (+ `Code/addons.csproj`), split `Code/Addons/lifepunch/<addon>` +
`Assets/addons/lifepunch/<addon>`. **Active addons only:** `adminmenu` (→ `lifepunchulx`) + `bitcoinmining`
(→ `lifepunchbitcoin`, staging `lpbitcoin`). Everything else is **quarantined** (concepts only — no edits,
no copy-paste ship paths): registry `config/portfolio.json`, `packages.json`, `addons/_QUARANTINE_INDEX.md`.

---

## 13. Laws that never bend

- **Git:** always `git pull --rebase` first; **never force-push**; author `mragerlp <mragerlp@gmail.com>`;
  **no AI/agent attribution on ANY git surface** — commit messages, PR titles, PR descriptions,
  merge-commit messages; no generated-with footers anywhere (keep Cursor Attribution OFF; critical
  on the public DXRP fork).
- **Commit consent:** never commit unprompted — propose **scope + one-line summary**, wait for Bloodwave
  **GO** (`commit to develop` / `merge to main` / `commit and push`). `GIT_CHECKPOINTS.md` · `BRANCH_MODEL.md`.
- **Proprietary header** on every LIFEPUNCH source file (`.cs`/`.razor`/`.scss`): the
  `PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co` block (name from `addons.json`) before any
  `using`/`namespace`/style. **Never** in the DXRP fork.
- **Quality bar — NO SPAGHETTI (≠ no hacks).** Honest baselines are fine and tracked in
  `addons/docs/TECH_DEBT.md`; the enemy is tangled, unmaintainable, non-modular code. Use engine systems as
  designed; prefer the fully-owned solution; no dead/orphan assets.
- **Eyes-covered:** no visual/playtest/scale claim without an `sbox` bridge screenshot from **Red**.
  **Runtime proof before "done";** use `lp_map_flatgrass` + fresh spawn when appropriate as the low-demand
  proof map (never a saved test scene) — not a universal requirement for non-gameplay / docs changes.
- **Owner gates:** new product / economy / permissions / publish need Bloodwave **GO**. During a
  **docs/canon reconciliation pass, do zero code** — docs + decisions + handoff only.
- **Trademark/IP:** **LIFEPUNCH™** is the only mark we own (`™` only, never `®` while pending); DXRP /
  Dxura / s&box / Facepunch are third-party (nominative use only); lead product names with **LIFEPUNCH**
  ("LIFEPUNCH Admin Menu for DXRP", not "DXRP Admin Menu"). Canon: `legal/TRADEMARK_AND_IP.md` +
  `lifepunch-trademark-ip` rule.
- **Cornerman = untrusted worker:** commits nothing it didn't author; candidates are proven on Red before
  ship; economy/persistence/`[Sync(FromHost)]`/security stay Tier-1 + Bloodwave.
- **Out of scope (do not build/reference):** legacy EVO / EVORP / SPL-mute tooling — not part of CVL.

---

## 14. Current state (July 2026)

| Topic | Canon |
|-------|-------|
| **Active lane** | **`lifepunchbitcoin` / `lpbitcoin` — Phase A Hub polish.** Take the **current unchecked ID** from `ACTIVE_WORKSTREAM.md` + `OWNER_PROGRESS_TRACKER` + the current baton (do not assume a stale slice) — **owner GO (+ route tag) before code.** Phase B Terminal locked until H10. Economy overhaul on HOLD. |
| **Bitcoin three-surface** | **Hub** (controller/ops — owns mining) + **Terminal** (defense/capability — **never mines**) + **GPU Rack** (hardware, 3-rack limit). Universal Upgrades Home in `LpHashdPanel` (HUB / TERMINAL / GPU RACK tabs). `DECISIONS/DECISION-0001…0010`. |
| **Branch** | **`develop`** = test (Red daily) · **`main`** = truth (Cornerman distill, export). Merge **`develop` → `main`** on owner GO; sync **`main` → `develop`** after. `BRANCH_MODEL.md`. |
| **Publish-ready** | Only **`lifepunchulx`** (`adminmenu`) — export via `Export-LifepunchPublishLane.ps1`. Bitcoin active but **not** publish-ready. |
| **DXRP upstream** | Party Phase 2 (**#111**) on `mragerlp-party-phase-2`; implement only after Dxura GO on slice 1. `DXRP_CONTRIBUTOR_LANE.md`. |
| **Editor workbench** | `Start-SboxDxrpEditor.ps1 -FullCapacity -PreflightFix -BitcoinOnly -SyncAddon lpbitcoin,adminmenu`. |

**Dated product truth lives in `handoff/ARCHITECT_CURRENT_STATE.md`** — check it, and the baton (§10.3), for
anything newer than this table. Evergreen alignment paste: `AGENT_SYNC_BROADCAST.txt`.

---

## 15. Grounded checklist (say yes to all before you work)

- [ ] I pulled (`git pull --rebase`) and the tree is clean.
- [ ] I know my **node**, **surface** (Claude Code build / Claude Chat plan / Codex review), and **LANE** (LIFEPUNCH vs DXRP official).
- [ ] I read my lane's **mandatory reads** — I did not skip the repo.
- [ ] I know my **layer** (Plan in Chat · Build in Code · Review with Codex · Cornerman distills) per `CLAUDE.md`.
- [ ] Editor work → I'm on Red (or bridged) with the right **MCP**; proof = flatgrass on Red.
- [ ] I will **not commit unprompted**; I'll propose scope and wait for **GO**; `mragerlp`, no AI trailers.
- [ ] I will end my turn with a **HANDOFF BATON**.

**If any box is unchecked, stop and get grounded first. That is the whole point of this document.**
