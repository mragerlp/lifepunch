# LifePunch — MCP agent routing (CVL canon)

**Status:** Locked June 2026 · **Source:** CVL topology handoff + Red/Green ops  
**Companion:** `SBOX_EDITOR_MCP.md` (install/wiring) · `CORNERMAN_MODEL_ROUTING.md` (Tier-3 models)

ChatGPT Plus/Pro on the desk is **Architect** (design brain) — paste `handoff/to-chatgpt-mcp-topology-handoff.txt` for infra refinement only.
**Cursor on VENGEANCE integrates and commits.** Green distill prep only; Red owns ship.

**Stack updates / full capacity:** `CVL_FULL_CAPACITY_UPDATES.md` · `Invoke-CvlFullCapacityRefresh.ps1`

---

## Machine roles (do not collapse)

| Node | IP | Owns |
|------|-----|------|
| **VENGEANCE (R)** | 192.168.1.236 | s&box editor, git, integrate, `sbox` + `sbox-editor` + `sbox-jtc` + `cornerman-lm` |
| **Cornerman (G)** | 192.168.1.229 | LM Studio `:1234`, same 3 MCP keys (SMB + tunnel + local LM) |
| **lifepunchnet (B)** | hosted | Hub/logs — out of scope for MCP routing |

**No LM Studio on Red.** Tier-3 inference stays on Green.

---

## Q1 — Task → MCP → model routing (law)

| Task type | MCP | Cursor tier | Never use | Why |
|-----------|-----|-------------|-----------|-----|
| Playtest spawn (`lp_map_flatgrass`, `lp_spawn_*`) | `sbox` | Tier-2 | `sbox-editor` | Runtime ConCmds need play/bridge |
| In-game screenshot / visual verify | `sbox` | Tier-2 | Opus alone | Eyes require bridge |
| Runtime UI / HUD in play mode | `sbox` | Tier-2 | `cornerman-lm` | No game state on distill |
| Bitcoin hub scale in spawned scene | `sbox` | Tier-2 | Prefab JSON guess | Scene truth only via play |
| Hub powered emissive / animation check | `sbox` | Tier-2 | ModelDoc only | Emissive behavior is runtime |
| Compile `bitcoin-miner.vmdl` | `sbox-editor` | Tier-2 | `sbox` | ModelDoc is editor MCP |
| Fix vmat / material compile errors | `sbox-editor` | Tier-2 | `execute_csharp` first | chomnr compile + errors |
| Remap material slots on vmdl | `sbox-editor` | Tier-2 | Hand-edit KV3 blind | ModelDoc + undo |
| GPU rack vmdl / fan shader | `sbox-editor` | Tier-2 | Tier-3 draft as ship | Authoring is editor-bound |
| Pull `_c` after editor compile | Tier-2 script | Tier-2 | chomnr for publish folder | Repo sync is Red shell |
| Edit bitcoin miner prefab in editor | `sbox-editor` | Tier-2 | Raw file write w/o compile | Prefab needs editor graph |
| Scene hierarchy / transform audit (no compile) | `sbox-jtc` | Tier-2 | Code-only guess | `scene_*` tools |
| s&box API / docs lookup | `sbox-jtc` | Tier-2 | Training-data guess | `sbox_search_docs` / `sbox_search_api` |
| Project file read / glob inspect | `sbox-jtc` | Tier-2 | Blind repo read when editor truth needed | `file_list` / `project_info` |
| Editor console / compile log readback | `sbox-jtc` or `sbox-editor` | Tier-2 | — | jtc for quick console; chomnr for compile panel |
| Razor terminal UI markup | Tier-2 (files) | Tier-2 | `sbox-editor` for .razor | Code lane; build in editor after |
| Multi-file C# hub ↔ rack wallet | Opus | Tier-1 | Tier-3 | Economy + integration stakes |
| IPressable / permission paths | Opus | Tier-1 | Tier-3 | DXRP integration |
| Security / economy audit | Opus | Tier-1 | Tier-3 | Stakes |
| Summarize DXRP upstream diff | `cornerman-lm` | Tier-3 | Opus | Bulk distill |
| Classify inbox / log dump | `cornerman-lm` | Tier-3 | Opus | Prep only |
| Draft markdown research brief | `cornerman-lm` | Tier-3 | Ship without Red | Green outbox only |
| Trademark / LIFEPUNCH wording review | Opus | Tier-1 | Tier-3 | Legal stakes |
| Portal listing copy (Class 9 careful) | Opus | Tier-1 | Tier-3 | ITU / specimen law |
| Portal publish staging (`prepare-publish`) | Tier-2 script | Tier-2 | MCP | Script + owner sign-off |
| Architecture / TECH_DEBT decision | Opus | Tier-1 | `sbox` | Thinking in Cursor |
| Repo-grounded technical planning + ModelDoc/asset maps | Grok Build 1 | Tier-2A | Opus (escalate on stakes) | See MODEL_ROUTING_AMENDMENT_GROK_BUILD_1.md (2026-06-25) |
| Bounded Razor/SCSS implementation | Grok Build 1 or Composer | Tier-2A/2B | Tier-1 unless hard | Grok good for planning + bounded slices |
| Green editor work via tunnel | `sbox-editor` on G | Tier-2 | Local chomnr on G | chomnr only on Red host |
| Green play verify | `sbox` on G (SMB) | Tier-2 | Green-only without SMB | UNC must see heartbeat |

---

## Q2 — Green dual-stack boot order

### After reboot (Red then Green)

**VENGEANCE (Red) — first**

1. `git pull --rebase` (clean tree)
2. `powershell -File lifepunch\scripts\Test-PreLaunchCheckup.ps1 -Fix`
3. `powershell -File lifepunch\scripts\Start-SboxDxrpEditor.ps1 -PreflightFix`
4. Cursor → Reload Window → MCP **4/4 green** (`sbox`, `sbox-editor`, `sbox-jtc`, `cornerman-lm`)
5. Editor pill → green + **MCP · ≥1** (chomnr); jtc dock → **listening on :29015/mcp**

**CORNERMAN (Green) — second** (requires Red editor up for tunnel + bridge heartbeat)

1. `Restore-CornermanDualStack.ps1` from Red **or** on-box `Install-CornermanGreenMcp.ps1`
2. SMB map once (password): `Map-CornermanBridgeShare.ps1`
3. `Start-CornermanSboxEditorTunnel.ps1 -Background`
4. LM headless: watchdog + `Fix-CornermanLmServe.ps1` if needed
5. Green Cursor → Reload Window → MCP **3/3 green**

### Failure signatures

| Symptom | Layer | Likely cause |
|---------|-------|--------------|
| `sbox` red on Green, OK on Red | SMB | UNC map dropped / wrong creds |
| `sbox-editor` red on Green, OK on Red | SSH tunnel | Tunnel dead; Red editor closed |
| `cornerman-lm` red on Red only | LAN | Green `:1234` down / firewall |
| `cornerman-lm` red on Green only | Local LM | `lms server` not loaded |
| Bridge OK Red, play fails | Editor | s&box not in DXRP project |
| All green, editor tools timeout on G | Tunnel latency | Heavy ModelDoc over SSH |

### Auto-fix vs owner password

| Fix | Automated | Needs owner |
|-----|-----------|-------------|
| Refresh `mcp.json` | `Install-VengeanceMcpStack.ps1` | — |
| Warm LM / watchdog | `Fix-CornermanLmServe.ps1` | — |
| Editor tunnel restart | SSH `Start-CornermanSboxEditorTunnel.ps1 -Background` | SSH key must exist |
| SMB share on Red | — | Elevated `net share` once on Red |
| SMB map on Green | — | `Map-CornermanBridgeShare.ps1` + VENGEANCE password |
| Remove `OFF_CURSOR_ACTIVE` | `Restore-CornermanDualStack.ps1` | — |

### Red vs Green Cursor — no duplicate commits

| Lane | Green | Red |
|------|-------|-----|
| Git commit / push | **Never** | **Owner integrate only** |
| Distill / outbox markdown | Yes | Absorb into repo |
| C# / Razor ship code | Draft only | Write + validate + commit |
| Editor asset compile | Via tunnel (mirror Red) | Primary |
| Playtest | Via SMB bridge | Primary |

Green outputs → `C:\lifepunch\cornerman\outbox\` → Red pastes or ingests → **one commit on Red**.

---

## Q3 — SSH tunnel `:9090` (Green → Red chomnr)

| Question | Answer |
|----------|--------|
| Acceptable latency | **&lt;300 ms** RPC round-trip for snappy tools; **300–800 ms** tolerable for compile; **&gt;1 s** feels broken for iterative ModelDoc |
| Mitigations | Tunnel watchdog task; `BatchMode` SSH key; restart on editor launch; **do heavy compile batches on Red** |
| Never through tunnel | Long `execute_csharp` chains; bulk shader graph iteration; first-time compile of huge vmdl — run on **Red Cursor** |

**Bitcoin miner same-session pattern:** ModelDoc/vmat on **Red `sbox-editor`** → play screenshot on **Red `sbox`** (or Green `sbox` via SMB). Do not split compile and play across tunnel if latency spikes.

---

## Q4 — Project memory (5 files)

Load via **Cursor rules** pointing at these paths — not bridge addons.

| File | Contents | Who updates |
|------|----------|-------------|
| `lifepunch/docs/memory/CURRENT_SPRINT.md` | Active P0/P1, owner sign-offs | Red |
| `lifepunch/docs/memory/SYSTEMS_SNAPSHOT.md` | Addon arch one-liners (hub/rack/wallet) | Red |
| `lifepunch/docs/memory/DECISIONS_LOG.md` | Dated ADR-style bullets | Red |
| `lifepunch/docs/memory/CONNECTIVITY_LAST_GOOD.md` | Last full-capacity probe timestamp | Red (script append) |
| `lifepunch/docs/memory/GREEN_OUTBOX_INDEX.md` | Pointers to Cornerman outbox drops | Green distill → Red merges |

**Architect tip:** mirror §0–§3 of `to-chatgpt-mcp-topology-handoff.txt` into **CLV Project** (infra only). Product design uses **Architect** (`ARCHITECT.md`).

---

## Q5 — Tier-3 trust boundary (10 examples)

| Example | Trust Tier-3? | Escalate Opus? |
|---------|-----------------|----------------|
| Summarize 40-page DXRP changelog | Yes | No |
| Draft `VISIBLE_POCKET_UI_NOTES.txt` | Yes | Red edits before ship |
| Propose Bitcoin terminal copy | Yes | Yes before player-facing ship |
| Generate C# hub wallet transfer | No | **Yes** — economy |
| Refactor `IPressable` across addons | No | **Yes** |
| Classify third-party vs LIFEPUNCH IP | No | **Yes** — legal |
| Suggest portal listing title | Yes draft | **Yes** before Class 9 claim |
| Regex for log parsing | Yes | No |
| Razor HUD layout from screenshot desc | Yes draft | Red + play verify |
| "Is this hub scale correct?" | No | **Yes** + `sbox` screenshot |

---

## Q6 — LM MCP shape

**Keep `georgepok/local-llm-mcp-server` (node) on both machines.**

| Approach | Fit |
|----------|-----|
| Node MCP → LM OpenAI API `:1234` | **Yes** — one LM host on Green; Red uses LAN URL; Green uses localhost |
| LM Studio native MCP host | No — duplicates tool surface; LM stays inference-only |

---

## Q7 — Watch-CvlConnectivity P0 vs P2

| Signal | Severity |
|--------|----------|
| Red bridge heartbeat stale (&gt;120s) | **P0** |
| Red `sbox-editor` HTTP down (editor open) | **P0** |
| Red `mcp.json` missing key | **P0** |
| Green Tier-3 `:1234` unreachable from Red | **P0** |
| Green `OFF_CURSOR_ACTIVE` present | **P0** (dual-stack required) |
| Green SMB `status.json` unreadable | **P0** on Green sessions |
| Green tunnel `:9090` down | **P2** unless Green editing |
| LM GUI eating RAM on Green | **P2** |
| Red optional telemetry services | **P2** |
| Editor pill MCP·0 clients | **P2** (warn; fix before heavy chomnr) |

---

## Q8 — Anti-patterns (10)

| Failure | Prevention |
|---------|------------|
| Agent uses `sbox-editor` for play spawn | Routing table + `SBOX_EDITOR_MCP.md` law |
| Calls Claude Bridge "Tier-3 thinker" | §2 naming in handoff |
| LM Studio opened on Red | Prelaunch bloat scan |
| Green off-Cursor drift | `Restore-CornermanDualStack.ps1`; preflight **fails** off-Cursor |
| Stale SSH tunnel | Tunnel watchdog; restart with editor |
| SMB map lost after reboot | Persistent `net use` + cmdkey |
| `execute_csharp` leaks `__Exec_*.cs` | Sweep after every exec session |
| Green commits to GitHub | Off-cursor handoff: Red only |
| Visual claim without screenshot | Eyes-covered law |
| Saved test scene as proof | `lp_map_flatgrass` + fresh spawn |

---

## Bitcoin miner hub — per-step MCP (same session)

1. **vmat compile / slot remap** → Red `sbox-editor`
2. **vmdl scale / import_scale** → Red `sbox-editor`
3. **Pull `_c` to repo** → Red PowerShell sync script
4. **Spawn hub on flatgrass** → Red `sbox`
5. **Screenshot + scale vs citizen** → Red `sbox`
6. **Powered emissive / grille** → Red `sbox` (+ `sbox-editor` if material)
7. **Portal publish** → Red script + Opus review — **not** until owner visual sign-off
