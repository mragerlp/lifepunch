# CAVELUX MCP IMPLEMENTATION PLAN — clone, study, build (2026-07-19)

Owner-directed. This is the handoff from design (Fable) to build (Red/Code seats). The gather is complete (30 repos, parent/child split by naming convention). The spec is banked. Phase 1 = read+equip, zero new authority.

## PHASE 0 — CLONE + ORGANIZE (Red, on VENGEANCE first)
Clone all 30 forks into a Cavelux workspace on each machine. The naming convention IS the architecture:
- `cavelux*` repos = PARENT layer (universal tools, any client)
- `lifepunch*` repos = CHILD layer (s&box/LIFEPUNCH-specific)

### Folder structure (per machine):
```
C:\Users\jared\Projects\cavelux\          # VENGEANCE (Red)
C:\Projects\cavelux\                       # CORNERMAN (Green)
[Blue path TBD]                            # LIFEPUNCHNET (Blue)

  cavelux/
    mcp/                    # the private cavelux repo (the assembly home)
    forks/
      parent/               # cavelux* repos (universal layer)
        bodies/             # opencode, cline, kimicode, kilocode, continue, odysseus
        prompts/            # superpowers, TRIPworkflow, uiuxpromax
        context/            # context7
        resources/          # vscodegitlens, garfana, netdata, mongodb, supabase
        mcp-build/          # pythonsdk, typescriptsdk, servers, githubmcpserver
        code-quality/       # sonarlintvscode, inspector
        infra/              # vscodecontainers, markitdown, springtools
        analysis/           # roslyn, slang
      child/                # lifepunch* repos (s&box/LIFEPUNCH layer)
        sbox-mcp/           # sboxclaude, chromrsboxmcp
        content-pipeline/   # humanoidretargeter
        server-ops/         # dxrp-public
    comms/                  # fresh comms lane for cavelux repo work
      BOARD.md
      dispatch/
        red/
        green/
        fable/
    tools/                  # proven standalone tools
      eye.js                # the seeing organ (copy from C:\Users\jared\eye.js)
```

### Clone script (Red runs on VENGEANCE):
```bash
# Parent layer (cavelux*)
PARENT_REPOS=(
  caveluxopencode caveluxcline caveluxkimicode caveluxkilocode caveluxcontinue caveluxodysseus
  caveluxsuperpowers caveluxTRIPworkflow caveluxuiuxpromax
  caveluxcontext7
  caveluxvscodegitlens caveluxgarfana caveluxnetdata caveluxmongodb caveluxsupabase
  caveluxpythonsdk caveluxtypescriptsdk caveluxservers caveluxgithubmcpserver
  caveluxsonarlintvscode caveluxinspector
  caveluxvscodecontainers caveluxmarkitdown caveluxspringtools
  caveluxroslyn caveluxslang
)

# Child layer (lifepunch*)
CHILD_REPOS=(
  lifepunchsboxclaude lifepunchchromrsboxmcp
  lifepunchhumanoidretargeter
  dxrp-public
)

# Clone all (Red adapts paths for PowerShell)
for repo in "${PARENT_REPOS[@]}"; do
  git clone "https://github.com/mragerlp/$repo" "parent/$repo"
done
for repo in "${CHILD_REPOS[@]}"; do
  git clone "https://github.com/mragerlp/$repo" "child/$repo"
done

# Clone the private assembly home
git clone "https://github.com/mragerlp/cavelux" mcp/
```

## PHASE 1 — STUDY (Green, long scan packet)
Green clones the same set on CORNERMAN, then deep-scans each fork with a per-fork template:
- What it IS (README + structure + key files)
- What it PROVIDES for the MCP (the wireable piece: schema, tools, resources, prompts)
- Which LANE it serves (editor/UI/research/git/telemetry/workflow/body/build)
- Wire recommendation (how the MCP wraps/serves it)
- Keep/modify/watch verdict with evidence
Output: structured per-fork analysis, modular (each fork = own section), feeds the build spec.

## PHASE 2 — BUILD THE PARENT MCP (Red, into private cavelux repo)
Build the Cavelux parent MCP server. Phase 1 = READ + EQUIP ONLY, zero new authority.
Build tools: caveluxpythonsdk (FastMCP) for quick tools, caveluxtypescriptsdk for TS tools.
Reference: caveluxservers (official MCP server examples).

### First organs to wrap (proven/ready):
1. **eye.js** → `read_web_text`, `read_web_shot`, `read_web_dom`, `read_web_styles`, `read_web_tokens`, `read_web_motion` Tools
2. **Tree/board/doctrine** → Resources (serve the LIFEPUNCH tree as the brain's project air)
3. **Superpowers + TRIP** → Prompts (the first guns — reusable workflow templates)
4. **Context7** → Context (already live as hosted MCP; wire as the brain's technical air)

### Governance (every tool satisfies the contract):
Per CVL_GOVERNANCE_DOCTRINE: default-deny, least-privilege, evidence-before-acceptance, human-controlled-canon. Each tool spec'd with: named owner, read/write classification, permission ceiling, evidence returned, failure behavior, Bloodwave gate for destructive/canonical ops.

### Two-lane mount (per TWO_LANE_MOUNT_ARCHITECTURE):
The MCP exposes lane-stacks (not the whole crate). Each lane = a lean, task-scoped slice. The mounting system selects which tools/resources/prompts a given agent session gets, by role + task.

## PHASE 3 — BUILD THE CHILD (LIFEPUNCH layer, stacked on parent)
After parent MCP is proven (Phase 2), stack the LIFEPUNCH child:
- s&box competence: sboxclaude toolsets (curated from 25, NOT all 275) + chromrsboxmcp + sboxvscodeextension API schema (data/ folder) + roslyn analysis API + slang
- LIFEPUNCH tree/doctrine/board as Resources
- DXRP portal reader (read-only, fenced, owner-establishes-auth)
- LIFEPUNCH-specific lane definitions

## CANON DOCS THE BUILD GROUNDS ON (all in C:\lifepunch\comms\fable\):
- CAVELUX_CVL_ANATOMY_CANON_2026-07-19.md — the body
- CVL_GOVERNANCE_DOCTRINE_2026-07-19.md — the law (four clauses + tool contract)
- TWO_LANE_MOUNT_ARCHITECTURE_2026-07-19.md — big crate / lean mount + per-lane stacks
- CAVELUX_PARENT_CHILD_MCP_ARCHITECTURE_2026-07-19.md — parent-first, child stacks on top
- CVL_ARMOR_FORK_INVENTORY_2026-07-19.md — the 30-fork master parts-list
- MACHINE_ROLE_CANON_2026-07-19.md — Blue sentinel / Green coexister / Red embodied
- BLACKBOX_STUDY_2026-07-19.md — the cheap-inference gateway
- SBOX_EDITOR_LOADOUT_2026-07-19.md — Red's harness extensions + s&box schema target
- RUNBOOK_WEB_PAGE_READING_2026-07-19.md — the eye (6 modes, proven)
- LIFEPUNCH_CONTENT_PIPELINE_2026-07-19.md — .blend pipeline + cosmetics (content track)

## BUILD ORDER (the stepping stones):
1. Red: clone all 30 forks on VENGEANCE (Phase 0) ← FIRST
2. Green: clone + deep-scan packet (Phase 1) ← PARALLEL with Red's build
3. Red: build parent MCP Phase 1 — wrap eye + serve tree + arm superpowers/TRIP (Phase 2)
4. Prove parent MCP works (eye as Tool, tree as Resource, superpowers as Prompt)
5. Stack LIFEPUNCH child (Phase 3)
6. Wire Green + Blue to reach the MCP
7. Coordination proof — one machine files through MCP, another picks up, surfaces to conductor

FROM: Fable (Jarvis), 2026-07-19. The plan. Build against the banked canon. Forge before stack. Parent first.
