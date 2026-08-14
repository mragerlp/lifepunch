# TWO-LANE MOUNT ARCHITECTURE — big crate, lean mount (2026-07-19)

Owner-articulated. THIS resolves the central tension: a BIG owned crate (every fork/tool/extension) vs a LEAN runtime (no 672-tool bloat, no cap-blowing, light task lanes). They are NOT contradictory — they are different LAYERS.

## THE PRINCIPLE
THE CRATE IS BIG. THE MOUNT IS LEAN.
- CRATE (armory/reference): all owned forks + extensions + tools + s&box MCPs = the complete set of what's AVAILABLE. Big is GOOD here — more owned capability = more to draw from. This is the reference library.
- LANE (runtime mount): any task mounts ONLY the specific toolset it needs, scoped to the task. Never bloated because it never mounts the whole crate.

## WHY IT WORKS (least-privilege as ARCHITECTURE, not just security)
The governance doctrine's LEAST-PRIVILEGE clause, applied for LIGHTNESS as well as security: agents MOUNT only what the task needs. The 672-cap / Grok-250 problem NEVER happens because no lane mounts 672 tools — it mounts the ~15 it needs for THIS task, drawn from a crate of hundreds. Same clause, two payoffs: security + performance.

## TWO-LANE MODEL (owner's concrete mechanism)
- EDITOR LANE — light, focused: the specific s&box toolsets for the work at hand, curated FROM sboxclaude's 25 toolsets (not all 275). Kept deliberately minimal so editor work stays fast and doesn't blow caps.
- BROAD / SCOPED-TASK LANE — different mount: whatever THAT task needs (web eye, Context7, odysseus search, different extensions/tool-callings), also scoped, also lean — a DIFFERENT lean set.
- More lanes as needed; each is a task-scoped lean slice of the big crate.

## THE MCP'S REAL JOB = SELECTIVE EXPOSURE
The CVL MCP is NOT one fat server exposing everything. It is a CRATE + a MOUNTING SYSTEM: holds everything (big, owned, reference), surfaces only the slice a lane calls for. Serve the crate; expose the slice.

## FORKS = WORKFLOW STACKS PER LANE (owner-articulated, the organizing logic)
Real work spans many FOCUSES (editor, UI, research, git, telemetry, s&box code, deployment). The forks are NOT a random collection — gathered by capability, they SELF-SORT into coherent per-lane workflow stacks. The organization IS the crate, sorted by focus. Draft lane stacks (each lean, task-scoped, drawn from the big crate):
- EDITOR lane -> sboxclaude toolsets (curated from 25) + sboxvscodeextension (API schema) + roslyn (C# analysis) + slang (shaders) + eye (visual ref) + Razor. All s&box-editor, nothing else.
- UI/UX lane -> eye (extract reference DNA) + uiuxpromax (design taste) + Razor.
- RESEARCH lane -> eye (web read) + context7 (live docs) + odysseus/SearXNG (search).
- GIT/REPO lane -> gitlens (blame/history/worktrees) + roslyn (analyze).
- TELEMETRY/SENTINEL lane (Blue) -> grafana + Prometheus.
- WORKFLOW-CAPTURE lane -> workflow-snapshot-replay + superpowers/TRIP.
- BODY/INFERENCE layer (crosscuts all lanes) -> Blackbox gateway (cheap routing) + opencode/cline harnesses.

## WHY BIG CRATE = SMART (not just safe)
A big crate is what lets EVERY focus have a complete stack to call on. Small crate -> some lanes under-equipped -> agents guess where a tool is missing -> slop. Deep crate -> every focus fully stocked -> no under-equipped lane -> no missing-tool slop. Crate DEPTH directly serves lane COVERAGE. Maps to CVL pitch: "each agent boots with the exact tools your vision requires" — lane defines focus, focus defines stack, MCP mounts that stack.

FROM: Fable (Jarvis), owner-articulated + ratified 2026-07-19.
