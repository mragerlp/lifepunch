# CVL ARMOR — COMPLETE FORK INVENTORY (2026-07-19)

All 13 mragerlp repos, machine-read via eye.js, sorted to the armor anatomy + four MCP primitives. This is the master parts-list the implementation plan assembles from. Owned = forked into namespace. Build discipline: forge/prove before stacking.

## THE HOME (the assembly — NOT a fork, the moat)
- **mragerlp/cavelux (PRIVATE) — the Cavelux PARENT-MCP home / the WIRED WHOLE / the moat.** This is where the forks get ASSEMBLED into the parent MCP. Distinct from the public forks: forks = the parts (commodity, owned copies, the public pattern); cavelux = the assembly (proprietary, private, the thing nobody else has). Aligns with IP-fence doctrine: "the pattern is public, the wired whole is not." The build agent commits INTO here. Reads as "page not found" unauthenticated = correct (private = the moat working).

## WHY FORK (not just install/use) — the two-way living-connection rationale
A fork is NOT a frozen snapshot — it's a LIVING connection to upstream with a controlled seam. Two-way value:
- INBOUND (crate stays current): `git pull upstream` brings latest fixes/features/patches ON YOUR TERMS. The crate never rots; you pull upstream evolution when ready, tested, not forced. Owned AND fresh.
- OUTBOUND (attributed customization + clean merge): make Cavelux/LIFEPUNCH-attributed changes ON TOP of upstream; because it's a proper fork with a clean merge base, your customizations and upstream's evolution COEXIST (3-way merge) — no forced choice between "stay current" and "make it yours." Where changes are upstream-worthy, contribute back clean (per upstream-contribution doctrine fable\0128; already practiced on dxrp-public divergence-map).
- NET: own a living, current, customizable copy with a maintained clean seam to upstream — fresh AND mine AND flows both ways. This is why forking (vs installing) is right for everything open-source.


## BODIES (harnesses / kinetics — swappable, mount by cost/physics)
- lifepunchopencode (<- anomalyco/opencode) — coding agent; .opencode configured for Grok 4.5 + Kimi K3.
- lifepunchodysseus (<- odysseus-dev/odysseus) — Green's self-hosted AI workspace; has built-in SearXNG search.
- lifepunchcline (<- cline/cline) — autonomous coding agent (SDK + IDE extension + CLI); own skills system (.cline/skills, .clinerules). Candidate body for the socket.
- [not forked, API service] Blackbox — cost-arbitrage gateway + agent runtime; owner has Pro; key held/fenced. See BLACKBOX_STUDY.

## PROMPTS (reusable task templates — "the first guns")
- lifepunchsuperpowers (<- obra/superpowers) — agentic skills framework; packaged for Claude/Codex/Cursor/agents.
- lifepunchTRIPworkflow (<- PiLastDigit/TRIP-workflow) — BS-free dev workflow + codex-ask skill. (3 commits behind upstream — sync.)
- lifepunchuiuxpromax (<- nextlevelbuilder/ui-ux-pro-max-skill) — UI/UX design intelligence (taste half of slop-killer).
- lifepunchworkflowsnapshotreplay (<- ArslantasM/workflow-snapshot-replay) — AI-native VS Code ext for WORKFLOW RECORDING & REPLAY. Ties to CVL "write the plays / re-run the play" philosophy — records agent workflows so they replay. Could feed playbook-generation. Owned.

## REFERENCE FORKS (studied for structure/architecture, not used functionally)
- lifepunchspringtools (<- spring-projects/spring-tools) — Spring Boot / Java tooling. Java is IRRELEVANT — grabbed as an ARCHITECTURAL REFERENCE for how a gold-standard, mature language-tooling extension is built (LSP patterns, efficient parsing/serving of heavy language analysis at scale). Study HOW it's structured when building own s&box tooling / curating the s&box MCP / wrapping Roslyn's analysis API. Owner ruling: reference-for-structure, legit crate member (not a stray).

## CONTEXT (brain's air #2 — live technical knowledge)
- lifepunchcontext7 (<- upstash/context7) — up-to-date library docs; ALSO live as hosted MCP in VS Code.

## RESOURCES (data/state the brain reads)
- lifepunchvscodegitlens (<- gitkraken/vscode-gitlens) — git intel, blame, worktree-agent sessions (Kepler-tied).
- lifepunchgrafana (<- grafana/grafana) — observability/telemetry; Blue-sentinel's metrics eyes (run, don't modify).

## s&box CODE COMPETENCE (3 legs — domain NOT in model training data)
- lifepunchroslyn (<- dotnet/roslyn) — C# CODE ANALYSIS (analyze actual code). SCOPE: use Microsoft.CodeAnalysis analysis-API slice, NOT the whole 144k-commit compiler.
- lifepunchslang (<- shader-slang/slang) — shader/HLSL/Slang tooling for s&box shaders.
- **lifepunchsboxvscodeextension (<- alexistb2904/sbox-vscode-extension) — THE s&box API SCHEMA, NOW OWNED (was the missing leg).** This is the OPEN SOURCE of "S&box API Tools" (all Sandbox types + hover API docs). Folders: data/ (= the s&box API TYPE DATA = the extractable Resource, the code-reference slop-fix), snippets/, syntaxes/, src/. Closes the biggest open s&box gap — the API knowledge is now forked, not rented.
- **lifepunchchromrsboxmcp (<- zeljkovranjes/sbox-mcp) — a SECOND open-source s&box MCP server.** 92 commits; Editor/ folder, animation-editor integration, map/asset import, live-play read, async/multi-arg invoke, diagnostics tools. The OWNABLE relative of the closed notpointless chomnr_mcp (was rented, now have open alternative). Study/curate alongside sboxclaude.
- lifepunchbettercomments (<- aaron-bond/better-comments) — annotation coloring; Red's harness ext (minor, completes harness set).
- lifepunchsboxvscode (<- Facepunch/sbox-vscode) — official s&box dev tools; **has schema/ folder = .addon JSON schema = IMMEDIATELY EXTRACTABLE Resource** (structured data, easier win than compiled extractions).
- **lifepunchsboxclaude (<- LouSputthole/Sbox-Claude) — THE s&box EDITOR MCP ORGAN, POSSIBLY PRE-BUILT.** "Claude Code into s&box" integration; already a native-MCP wrapper layer: v2.0.0-alpha = 215 tools / 25 TOOLSETS, v2.1.0 "Action!" = ~275 tools (Tier-2 completion, gameplay recording). This is the HARDEST organ (the curated s&box editor interface) and someone already built it. FENCE (critical): 275 tools = the "don't get too big"/672-cap edge — apply LEAST-PRIVILEGE, expose TOOLSETS by seat/task, never all 275 at once; the 25-toolset structure enables curated mounting. INVESTIGATION: study the 25 toolsets + how it wraps s&box — may shortcut building the s&box organ from scratch, or is the reference to curate down from. Forked, owned.

## THE EYE (TOOL — built + proven by us, not a fork)
- eye.js at C:\Users\jared\eye.js — 6 modes (text/shot/dom/styles/tokens/motion). The visual-reference organ.

## NOT ARMOR PARTS
- dxrp-public — the DXRP fork (server-ops + upstream-contribution lane; #111 fence landed here).
- ulx — legacy GMod admin ref; not armor.

## THE COMPLETE s&box SLOP-FIX (now fully sourced)
- SEE the reference -> eye.js (visual, F12 depth).
- KNOW the API -> S&box API Tools data (alexistb2904, community ext — NOT yet forked; extraction TBD) + lifepunchsboxvscode .addon schema.
- ANALYZE the code -> lifepunchroslyn (C# analysis API).
- SHADERS -> lifepunchslang.
- LANDS IN -> C# Razor (Red's harness ext).

## STILL-TO-GATHER / OPEN
- S&box API Tools (alexistb2904) — the API-docs/type data; not a mragerlp fork yet; extraction-as-Resource TBD.
- Blackbox remaining docs (Zero Data Retention, Provider Routing, Tool Calling).

FROM: Fable (Jarvis), 2026-07-19. Master parts-list; implementation plan assembles from here.
