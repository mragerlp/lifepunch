# SBOX_LIBRARY_PLAYBOOK.md

Status: CANON — drafted 2026-07-08 from a full sweep of the live library tree.
Home: `lifepunch/docs/` (contains tooling strategy; non-shippable).
Companions: `SBOX_EDITOR_MCP.md` · `MCP_AGENT_ROUTING.md` · CVL §8.
Source: Fable paste (handoff/, 2026-07-08), transcribed by Red same day —
uninstalls DONE, storage-medium line in canon, live-state claims verified
at transcription (tree = 27; fork subset recounted, see LAW 1).

---

## LAW 1 — The library tree of truth

**`D:\Steam\steamapps\common\sbox\dxrp\game\Libraries` is the single source of
truth for the s&box editor library stack.** Every editor session runs against
this tree, and it must remain identical across sessions.

The repo fork's `lifepunchdxrp/game/Libraries/` is an UNMAINTAINED SUBSET
(6 entries as of 2026-07-08 post-cleanup — its stale jtc copy was removed in
the trim debris pass — including one, `bopcompany.glow`, that exists ONLY
there and not in the live tree). It is not the stack. Any agent auditing
libraries audits the D:\ tree.

**Stack-change rule:** installing, removing, or updating a library in the live
tree is a canon change — it goes through Bloodwave and updates the manifest
below in the same pass. No silent drift.

## LAW 2 — MCP stack: curated, not maximal

The agent-capable MCP stack is the COMPLEMENTARY SET, not every server present:

| Server | Library | Transport | Role |
|---|---|---|---|
| `sbox` | sboxskinsgg.claudebridge | stdio / file-IPC (survives editor restarts) | TEST & MANIPULATE lane — playtest, simulated input, debug draw/viz, asset ops, method invocation, scaffolding. 197 handlers. Proven live. |
| `sbox-editor` | notpointless.chomnr_mcp | HTTP :9090 (lives INSIDE editor) | AUTHOR lane — ModelDoc, ShaderGraph, prefabs, scenes, components, code, project, cloud/marketplace, retargeter. |
| (situational) | sboxcool.network-storage MCP | bun, per-repo | Storage-work sessions only — scaffold/validate collections, endpoints, workflows. |
| (this seat) | Blender MCP | Claude Desktop connector | Asset prep — Blender scene ops, screenshots, renders, API docs. Fable-seat lane, not Red. |

**TRIMMED (Bloodwave GO 2026-07-08, EXECUTED same day):** `jtc.mcp-server` and
`ozmium.oz_mcp` — both strict subsets of claudebridge+chomnr. Uninstalled by
Bloodwave from the live tree; debris (mcp.json, LpJtcMcpAutostart.cs overlay,
mirror copies, scripts/configs/docs references) cleaned by Red. Redundant
servers reduce agent capability: duplicated tool schemas burn context and
split routing. Curated = maximal. Do not reinstall.

## LAW 3 — Boot order & session grounding

The HTTP MCP servers live inside the editor process. Therefore:

1. **Editor up first** (on Red), THEN start/reconnect the agent session
   (or `/mcp` reconnect mid-session). Otherwise the chomnr lane silently
   doesn't exist.
2. Verify `/mcp` shows the curated stack green.
3. Bridge heartbeat green → fire any queued identity assertion.
4. **Stack check:** confirm the live tree matches the manifest below.
   A missing/extra/version-bumped library is reported before work starts.

## THE VISION LOOP — how the agent sees and learns

An editor session has eyes and hands; use them as a loop, not one-shots:

- **See:** claudebridge debug draw/viz + screenshots (supershot for
  quality captures, marketing frames, and before/after evidence).
- **Act:** chomnr authoring tools or claudebridge manipulation/invocation.
- **Verify:** claudebridge playtest + simulated input — drive the actual
  gameplay path and screenshot the result. Proof gates (gate-1 pattern:
  purchase → restart → verify rehydration) are SCRIPTABLE with this loop.
- **Learn:** every capability exercised for the first time promotes a
  playbook line from UNTESTED to VERIFIED with a date (protocol at bottom).

---

## THE MANIFEST — live tree, 2026-07-08 sweep (27 keepers post-trim)

Legend — LANE: A = agent-direct · H = human-drives, agent-consumes output ·
F = Fable-seat (Desktop) · TIER: 1 current arcs · 2 UI armory · 3 asset
pipeline · 4 gameplay/parked. Versions pinned by a Red pass
(`.version` file per library); only spot-read values are shown.

| Library | Tier | Lane | Purpose (one line) |
|---|---|---|---|
| sboxskinsgg.claudebridge | 1 | A | Test/manipulate MCP lane — playtest, input sim, debug viz, invoke, scaffold |
| notpointless.chomnr_mcp | 1 | A | Author MCP lane — ModelDoc/ShaderGraph/prefab/scene/cloud/retargeter |
| dicta.panelrendertarget | 1 | A | Razor panels on world surfaces WITH input — tablets, consoles, terminal screens |
| dreams.ultimatelightmanager | 1 | A | Scene-light orchestration (single component) — gate 3 candidate |
| sboxcool.network-storage | 1 | A | Cloud persistence: SteamID docs, endpoints, atomic increments, own MCP |
| gamah.skafinity | 1 | A | Procedural deterministic music (seeded, mixer-routed) — the audio capability |
| subzerostudios.supershot | 1 | A | High-quality screenshots — evidence, marketing, portal page |
| isotope.gitversioncontrol (1.0.306347) | 1 | H | Git UI inside the editor — human convenience; agents use real git per CVL |
| sklmr.razordesigner | 2 | H | WYSIWYG Razor designer — humans design, agents consume Templates/Serialization |
| kikozl.sbox_ui_designer | 2 | H | SECOND visual UI designer — redundancy pair with razordesigner, audition pending |
| lilboi.ui-pro | 2 | A | UI component library |
| tristan.tailwand | 2 | A | Tailwind-style utilities for Razor — adoption = UI-standard canon decision FIRST |
| igor.reactivity | 2 | A | Reactive state for panels |
| resync.sbtween | 2 | A | Tweening — stepper micro-animations, light transitions |
| kamishell.blender_bridge | 3 | H/F | Editor-side Blender link — pairs with Fable-seat Blender MCP |
| brax.unrealimporter | 3 | H | Unreal-format asset conversion for the stashed model library |
| evilinc.modeliconeditor | 3 | H | Inventory/market icons — bricks, black-market items |
| ali3nsystems.lib-shader_graph_extras | 3 | A | Extra ShaderGraph nodes — future patterned rack-light work |
| notpointless.chomnr_humanoid_retargeter | 3 | A | Animation retargeting (driven by chomnr RetargeterTools) — dormant until characters |
| fish.scc | 4 | A | Shrimple CHARACTER CONTROLLER — NOT source control. Movement pair w/ xmovement |
| xenthio.xmovement | 4 | A | Movement controller — redundancy pair with fish.scc, purpose undocumented |
| fish.shrimple_ragdolls | 4 | A | Ragdolls (scc sibling) |
| bugge.meshsplitter | 4 | A | Mesh cutting/destruction |
| xaz.goo | 4 | A | Goo/soft physics effects |
| xaz.hit_shapes | 4 | A | Hitbox shapes |
| saico.easysplashscreen | 4 | H | Server splash/branding — quick LIFEPUNCH win someday |
| sboxshare.sboxshare | 4 | ? | Unprobed — content sharing by name; probe before first use |

**Trim record:** jtc.mcp-server + ozmium.oz_mcp uninstalled 2026-07-08
(Bloodwave, by hand; debris cleaned by Red). oz_mcp had no salvageable
CLAUDE.md at cleanup time.

**Tree diff on sweep date:** live tree lacks `bopcompany.glow` (repo fork only);
repo fork lacks 23 of the live tree's entries. Glow decision → OPEN ITEMS.

---

## PLAYBOOK ENTRIES — Tier 1 detail

### sboxskinsgg.claudebridge — the proof-gate machine
REACH FOR: any "does it actually work" question; driving gameplay; seeing state.
ENTRY: Editor handlers — Playtest, PlayInput, DebugDraw, DebugViz, AssetTool,
InvokeMethod (the escape hatch: call arbitrary editor/game methods),
InputAction, Scaffold, NpcBrain.
VERIFIED (2026-07-08): live all session, 197 handlers, survives editor restarts
(file-IPC). UNTESTED: screenshot fidelity vs supershot; NpcBrain surface.
NOTE: status JSON reports `port: 29015` — cosmetic (it is file-IPC).

### notpointless.chomnr_mcp — the authoring lane
REACH FOR: creating/editing assets, prefabs, scenes, shader graphs; marketplace
installs (CloudTools can FETCH missing packages mid-session); retargeting.
ENTRY: Tools/ — Asset, Cloud, Code, Component, Content, Editor, GameObject,
Graph, ModelDoc, Prefab, Project, Retargeter, Scene.
VERIFIED (2026-07-08): endpoint alive :9090. UNTESTED in-session: all tools
(connect editor-first per LAW 3, then exercise).

### dicta.panelrendertarget — interactive world screens
REACH FOR: chemist tablet, hacker deck, FBI LIFEPUNCHNET console, Mayor
data-center terminal, in-world HASHD screens.
ENTRY: TargetScreen / ITargetScreen, TargetPanelInput, TargetRootPanel,
PanelSceneObject, ScreenPanel.
PATTERN: razordesigner designs the panel → panelrendertarget mounts it on a
prop with input routing. UNTESTED: all — first exercise should be a trivial
panel on a cube before any real build leans on it.

### sboxcool.network-storage — powerful, governed
REACH FOR: cross-server persistence, audited increments, server endpoints —
IF AND ONLY IF the storage-medium decision names it.
GOVERNANCE: the lpbitcoin ledger's storage medium is decided in canon
(UPGRADE_ARC_DESIGN.md decision 9 addendum): host-local FileSystem.Data
flushed at commit = lean default; network-storage = named alternative. The
economy's transactional truth NEVER silently becomes a third-party cloud
dependency (sboxcool.com uptime/vendor risk).
ENTRY: NetworkStorage.Configure/CallEndpoint/SaveDocument/UpdateDocument
(Increment with source+reason), SaveStateTracker, NetLog; secret keys stay in
Editor/.env, never in code (its own README's rule — honor it).
BONUS: ships its own MCP server (bun) — load only for storage sessions.

### gamah.skafinity — procedural audio
REACH FOR: RadioEntity infinite stations, terminal/casino ambience, per-base
seeded vibes (shareable seeds are emergent social content).
ENTRY: SkafinityPlayer component (MixerName, PlaySeed "tag:n", NextSong,
RerollVibe, SaveCurrentToFile) · optional SkafinityMusicPanel (re-themeable
SCSS — can wear HASHD/ULX skin) · MusicGen.Generate for offline WAV.
DETERMINISM RULE from its docs: VibeCodec is append-only — never reorder
fields or shared seeds change meaning. UNTESTED: all.

### dreams.ultimatelightmanager + (glow, pending)
REACH FOR: gate 3 rack power lights; any scene-light orchestration.
OPEN: glow (Glowable/GlowOutline outline layer) is NOT in the live tree —
install it or replan gate 3 as emissive+lightmanager only. Decide before
gate 3 opens.

### subzerostudios.supershot
REACH FOR: proof-gate evidence frames, before/after UI comparisons, portal
publish page assets, marketing. UNTESTED: agent-drivable vs human-only.

## PLAYBOOK ENTRIES — Tier 2 rules of engagement

- **razordesigner vs sbox_ui_designer:** audition both on the stepper's
  confirm dialog; loser is trimmed. Until then razordesigner is presumed
  primary (deeper feature surface: templates, wiring, validation).
- **tailwand:** NOT adopted until a UI-standard canon amendment says so —
  utility-class styling conflicts with the token-based standard unless
  deliberately reconciled.
- **reactivity + sbtween:** free to use inside addon panels; note first
  uses in VERIFIED lines.
- **ui-pro:** inventory its components before the stepper build; reuse
  beats reinvention only if it can wear HASHD tokens.

---

## SESSION-LEARNING PROTOCOL

1. Every editor session that exercises a library capability for the first
   time appends a dated VERIFIED line to that library's entry (or flips an
   UNTESTED line). One line, evidence-grade: what was called, what happened.
2. Surprises (API differs from playbook, tool missing, version drift) are
   corrections to THIS FILE in the same session's docs delta — the playbook
   is living canon, wrong entries are bugs.
3. Redundancy pairs (UI designers; movement controllers) carry their
   audition outcome here when decided, then the loser exits via LAW 1's
   stack-change rule.
4. New library installs arrive WITH a playbook entry — no entry, no install.

## OPEN ITEMS (2026-07-08)

- [x] Ledger storage medium — DONE: in canon as UPGRADE_ARC_DESIGN.md
      decision 9 addendum (FileSystem.Data default; network-storage named
      alternative); slice-1 code complies
- [ ] glow: install to live tree vs gate-3 replan — Bloodwave's call before
      gate 3 opens
- [x] jtc + oz_mcp trim — DONE 2026-07-08 (uninstalled + debris cleaned)
- [x] Red pass: pin all 27 `.version` values — DONE 2026-07-08
      (cvl-stack-pins.json `libraryTree` section, sweep-dated)
- [ ] Red pass: enumerate claudebridge's 197 handlers + chomnr tool schemas
      into an appendix (the VERIFIED backbone)
- [ ] Red pass: panelrendertarget first-exercise (trivial panel on a cube)
- [ ] xmovement vs fish.scc: document why two movement controllers, or trim
- [ ] Probe sboxshare.sboxshare before first use

---
