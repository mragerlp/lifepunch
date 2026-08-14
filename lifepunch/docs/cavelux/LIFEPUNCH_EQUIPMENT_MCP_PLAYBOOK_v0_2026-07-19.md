# CVL SUPER-AGENT MCP — BUILD PLAYBOOK v0 (skeleton, 2026-07-19)

Status: SKELETON. Fable-authored. Owner feeds reference material into the [[SLOT]] markers; then an implementing Code seat runs it. Owner does NOT build; Fable does NOT build — a Code seat implements, owner merges (FABLE_SCOPE_v2).

---

## WHAT THIS IS — THE HEADLINE (ratified 2026-07-19)
This is **UNIVERSAL ARMOR** — an MCP for a super-agent. NOT a product (a product = people using CVL's services without CVL's involvement = the opposite of what CVL is). NOT LIFEPUNCH-stamped (LIFEPUNCH is merely the first purpose it's pointed at). It is **CVL-level apparatus that sits ABOVE any single project** — the nervous system of the ORB: one coherent operating intelligence that is MODEL-AGNOSTIC and inherits full competence on connect, regardless of which brain (Claude / Kimi K3 / GPT / …) is driving.

## THE AGAR METAPHOR + ARMOR FRAME (owner, ratified 2026-07-19)
- **The MCP is a CELL that grows by absorbing the RIGHT tools** (Playwright/Fetch/Filesystem/s&box-schema/workflows/knowledge = pellets). It swallows capability and becomes dominant on the board.
- **BUT DON'T GET TOO BIG** — the cell that eats indiscriminately gets slow + becomes a target. CONCRETE ROOT (owner correction 2026-07-19): the 672-tool cap was blown specifically by the s&box EDITOR MCPs (native 7269 + chomnr 9090) — they carry the massive tool counts; Grok (250 cap) couldn't even mount them. So the mass isn't little utilities — it's the s&box editor surface itself. DESIGN REQUIREMENT: the armor must expose a CURATED s&box editor interface (get_bridge_status, screenshot, the handful of build/inspect verbs), NOT proxy all 600+ raw editor tools — else it inherits the bloat and becomes un-mountable in lean harnesses (the exact failure). Lean = curation of the editor surface, because that's where the mass lives. Absorb the RIGHT tools, not ALL. This is the KNIFE on tool selection.
- **COMPATIBLE across platforms, VS CODE PRIMARY** — the armor fits every body. VS Code = the main arena where implementing agents fight, so the MCP is primarily called there; compatible everywhere so any harness can don it. Universal armor, not VS-Code-only.
- **The chat window (Fable) is the FALLBACK + the COMMANDER** — role division that completes the CVL: FABLE/COMMS fires the agents, sets the problem, holds the intent. Implementing agents in VS Code don't originate the vision — they need to be EQUIPPED to attack it. The MCP is armor + superpowers, NOT a brain: it doesn't decide what to fight, it makes whoever fights CAPABLE (survive s&box without dying to hallucination). Intent from the loop (Fable/comms); capability from the cell (the armor). Swappable warrior, constant armor.

WE ARE BUILDING THE UNIVERSAL ARMOR.

## OWNERSHIP + PLACEMENT
**PPP LLC** (parent) → **CVL** (the AI-integrator brand; owns the METHOD + this apparatus) → the MCP is a **CVL asset, above projects**. **LIFEPUNCH** = the FIRST PURPOSE the MCP is wired to — a configured target it READS, not its owner, not the tree it's buried in.
PLACEMENT (design consequence): the apparatus is separable from the project by design. Long-term it wants its OWN home (own repo under PPP/CVL), with LIFEPUNCH as a configured target. [[SLOT-I: owner decides repo home — own CVL repo vs bootstrap inside lifepunch tree then extract. Recommendation: build in a clean CVL-owned repo from the start so it's never LIFEPUNCH-entangled.]]

## THE SOCKET MODEL (why it's a super-agent, owner's insight)
- **VS Code = the universal harness host** — every implementer worth using (Claude Code, Codex, opencode+Kimi K3, Cursor) runs INSIDE VS Code. It's the one room where you swap which model/agent drives without changing anything else.
- **The model/agent = the interchangeable part** — pick by task, cost, or capability.
- **The CVL MCP = the CONSTANT** — whichever agent is seated, it connects to the same MCP and inherits the same equipment (grounding, board, s&box competence, doctrine).
WHY THIS IS THE WHOLE POINT: it DECOUPLES "which model" from "how competent." Normally swapping Claude→Kimi means re-grounding + re-teaching engine quirks. With the MCP as the invariant, you swap the BRAIN and competence comes WITH THE SOCKET — the new agent is instantly as fluent + s&box-equipped as the last. Model choice becomes a free variable tuned per task, not a costly re-onboarding. Kimi's cheapness / Claude's judgment / GPT's reach — all inherit the same rig. THAT is the super-agent: one operating intelligence indifferent to which model currently drives.

## IP FENCE (non-negotiable)
LIFEPUNCH proprietary data (economy numbers, doctrine text, the tree) lives in what the MCP READS — never baked into the apparatus's own logic. The apparatus is CVL (super-agent infrastructure, model+project-agnostic). The data + purpose are LIFEPUNCH's. No bleed. This separability is what makes it a super-agent MCP rather than a LIFEPUNCH tool.

---

## THE EQUIPMENT FUNCTION (why it coheres the system)
ONE MCP server = the standard rig every LIFEPUNCH agent boots with. Connect once → the agent is uniformly equipped with the operation's workflows, databases, libraries, and knowledge — no per-harness config drift, no grounding-paste fragility. It is the "boot ROM" that makes a generic coder into a LIFEPUNCH agent. It aggregates/points to existing tools (Superpowers, TRIP, Context7) + exposes the one tree (comms/doctrine/board) — it does not re-implement them.

## TWO PURPOSES (owner, ratified 2026-07-19)
The MCP serves TWO distinct functions — both first-class:

**PURPOSE 1 — COHERE the agent system** (the orb layer). Grounding, board, doctrine, dispatches, workflows wired uniformly so scattered seats become one operating intelligence. Covered by the read/equip tool surface below.

**PURPOSE 2 — EQUIP FOR s&box** (the domain-capability layer). s&box development is genuinely HARD — harder than most AI-integration domains (a paper business needs a DB + email; s&box needs an engine whisperer). Proprietary engine, restricted SCSS (no @media/inline-flex/comment-word-parse), Razor quirks, the editor bridge, .vsnd_c/.prefab asset compilation, T1/T2/T3 portal config layers, the whole DXRP framework — NONE of it is in any model's training data and NO off-the-shelf MCP covers it. The MCP gives every connecting agent the wide array of s&box-specific tooling + hard-won engine knowledge so it is instantly s&box-COMPETENT, not starting from zero on the hardest engine to work in. THE HARDER THE DOMAIN, THE MORE THIS LAYER CARRIES — this is why the MCP matters more here than a simpler AI integration would.

PURPOSE-2 tool/capability candidates (owner + Green research refine): editor bridge access (get_bridge_status, take_screenshot, the native 7269/chomnr surfaces) · SCSS/Razor rule-checks + the known-traps sheet · asset/compile awareness (.vsnd_c/.prefab/.vmat conventions) · T1→T2→T3 config-layer lookups · DXRP framework knowledge + upstream map · s&box docs/reference-pattern retrieval · the UI port pipeline (design-outside→port-in) once ratified. [[SLOT-H: owner's full list of s&box tools/capabilities an agent needs to be competent — pairs with SLOT-C.]]
CAPTURED EVIDENCE (owner-sourced, real): (1) **S&box API Tools** VS Code extension (alexistb2904.sbox-api-tools, v0.1.0, MIT) — C# API intellisense/validation/diagnostics/18+ snippets against the OFFICIAL s&box API schema. KEY INSIGHT: it's a VS-Code extension = equips only the editor, NOT every harness — exactly the fragmentation the CVL MCP solves. The MCP should EXPOSE what this taps (the s&box API schema) as a tool ANY harness (Cursor/Codex/opencode) can call. Model on it / tap the same schema. (2) tailwand (sbox.game/tristan/tailwand) — utility classes in-engine (UI port). (3) chomnr_mcp + sklmr.razordesigner already in lifepunchdxrp/Libraries — in-tree MCP/Razor patterns to model on (SLOT-F).

## PHASE DISCIPLINE (safety — non-negotiable)
- PHASE 1 (this build): READ + EQUIP only. Exposes/points to knowledge + databases. ZERO new authority — cannot file work, cannot mutate board, cannot bypass owner-GO. Physically incapable of breaking Transport Law because it has no write tools.
- PHASE 2 (later, separate design pass): write tools (file_dispatch etc.), each ENFORCING the three keys + Rule-17 IN the tool so the server becomes the enforcer of CVL law, never a bypass. NOT in this build.

## STACK DECISION
- SDK: **C# MCP SDK** (github.com/modelcontextprotocol/csharp-sdk; NuGet ModelContextProtocol + .Core). Rationale: same .NET world as s&box game code; owner-preferred. [[SLOT-A: owner confirm C# vs TypeScript — TS is lighter for a pure read server; C# unifies with game code. Owner's call.]]
- Transport: stdio (local, per-harness) to start — matches how Filesystem/Desktop Commander wire into Claude Desktop + CLI harnesses.
- Distribution: [[SLOT-B: how seats get it — npx/uvx-style one-liner in each harness config, or a pinned local build path. Owner input.]]

## PHASE-1 TOOL SURFACE (the read/equip verbs — DRAFT, owner refines)
Grounding/DB reads (the one tree):
- `read_board(tail?)` → BOARD.md tail-read
- `read_owner_queue()` → OWNER_QUEUE.md
- `list_dispatches(seat)` / `read_dispatch(seat, n)` → dispatch\<seat>\ files
- `list_filings(seat, n?)` / `read_filing(seat, n)` → seat comms folders
- `get_doctrine(name)` → the canon docs (CLAUDE.md, ARCHI.md, DXRP_PLATFORM_DOCTRINE, UI_STANDARD, MENU_SHELL, etc.)
Equipment/knowledge pointers:
- `list_skills()` → what Superpowers + TRIP + lifepunch-* skills exist + where (so a booting agent self-verifies its rig)
- `get_pipeline(name)` → e.g. the UI port pipeline doctrine once ratified
- `boot_digest()` → the highest-numbered fable\ boot digest + board tail + queue = one-call grounding (replaces the grounding paste)
- `read_web(url)` — **RENDER-CAPABLE web reader** (headless browser / JS-capable fetch, e.g. Playwright or the reference Fetch server). PROVEN-NEEDED 2026-07-19: raw fetch chokes on JS-rendered sites (collaborativevalueloop.com, Reddit, GitHub-rendered pages = "premature close"); the Windows-MCP that would've rendered them was FAILED/disconnected in the Fable harness. An agent must be able to read live sites (CVL's own site, dxrp.net portal pages, UI references) without hitting a JS wall. This is standard equipment, not optional.

### DESIGN FORK — how the CVL MCP "swallows" other servers (Playwright/Fetch/Filesystem/s&box-schema) (owner insight 2026-07-19)
The CVL MCP does NOT reimplement these — it AGGREGATES them so an agent stepping into the bubble inherits ALL sensors (render-web, screenshot, tree, editor, API) through ONE connection instead of wiring each per-harness (and forgetting half). Two ways to build the swallow — Phase-1 build-seat decides:
- OPTION 1 BUNDLE/PROXY: CVL MCP wraps + re-exposes the other servers' tools through itself. Agent sees ONE server; tools sourced from many. Cleaner single-socket, more build work.
- OPTION 2 MANIFEST/ORCHESTRATE: CVL MCP is one server among several in config, but ENSURES the others are present + points the agent to them (boot-check + equip role). The "bubble" = the config-set CVL MCP guarantees. Lighter build.
Both deliver the bubble (agent inherits the full sensory apparatus); they differ in whether it's literally one server or one guaranteed SET. This is the core Phase-1 architecture call.
[[SLOT-C: owner's full list of what a fresh agent must be able to READ to be instantly LIFEPUNCH-fluent. This is the heart — owner feeds it.]]

## REFERENCE MATERIAL (owner drops here)
- [[SLOT-D: repo paths the server reads — confirm the canonical tree root(s) + comms root the server points at.]]
- [[SLOT-E: the exact doctrine/knowledge file manifest the server should expose via get_doctrine.]]
- [[SLOT-F: any existing example MCP server in-tree to model on — note: sklmr.razordesigner + notpointless.chomnr_mcp exist in lifepunchdxrp/Libraries; chomnr_mcp may be a build reference.]]
- [[SLOT-G: Superpowers/TRIP skill locations per harness so list_skills points correctly.]]

## BUILD STEPS (implementing seat runs; filled once SLOTs are populated)
1. Scaffold C# MCP server (Core package), stdio transport.
2. Implement Phase-1 read tools against [[SLOT-D]] paths.
3. Local test: connect from one harness, call boot_digest() + read_board() + get_doctrine() → verify identical output to direct file reads.
4. Cross-harness test: wire into a second harness config, confirm same tools resolve.
5. Attribution-clean commit → push → open own PR → report PR#. MERGE HELD (SELF-PR CLOSE per SCOPE_v2 Amendment 1).
6. Owner merges; then wire the server into each harness config (owner console for the config edits).

## OPEN CALLS (owner)
Q1. SLOT-A language: C# (unify w/ game) or TypeScript (lighter read server)?
Q2. Which Code seat builds it — Red (editor-adjacent, but busy w/ UI) / a dedicated Code seat / Codex?
Q3. Parallel with UI season, or after? (It's Code-seat work; can run alongside — doesn't touch UI hands.)

FROM: Fable. Skeleton ready — owner populates SLOTs A-G, I cut v1, implementing seat runs it.
