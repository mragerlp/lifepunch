# VENGEANCE — s&box editing standards (June 2026)

**Bloodwave law:** Cursor **mic plugin** for voice in chat. **Whisper / PTT lanes deferred** until needed.

This doc is the **minimum bar** before ModelDoc, shaders, prefabs, or playtest work.

---

## Hardware (VENGEANCE)

| Resource | Standard | Why |
|----------|----------|-----|
| **RAM free** | ≥ 4 GB headroom; **&lt; 90%** used | s&box editor + DXRP compile spikes |
| **GPU** | Dedicated GPU for editor; no LM Studio on Red | LM on VENGEANCE competes with editor VRAM |
| **Mic** | Cursor voice input (Windows default or chosen in Cursor) | Ideation in chat — not lifepunchnet Whisper |
| **Listen** | Virtuoso or desk speakers | Operator feedback only |
| **Disk** | Steam `sbox` + `dxrp` on fast SSD | Compile + asset churn |

**Do not run on VENGEANCE during edit sessions:** LM Studio GUI, duplicate s&box instances, heavy Discord (use lifepunchnet RDP Discord if needed).

---

## Software bar (every session)

### 1. Pre-launch gate (required)

```powershell
cd C:\Users\jared\Projects\lifepunch\lifepunch\scripts
powershell -File Test-PreLaunchCheckup.ps1 -Fix
```

Pass before heavy work. With editor already open:

```powershell
powershell -File Test-PreLaunchCheckup.ps1 -Fix -RequireEditor
```

### 2. Launch editor (DXRP + owner lane)

Default syncs **art from OneDrive addon test drop** + **code from repo** (not full repo MIR):

```powershell
powershell -File Start-SboxDxrpEditor.ps1
```

Legacy full repo sync: `-RepoSync`. Full Red+Green boot: `../docs/RED_FULL_CAPACITY_BOOT.md`.

### 3. Full capacity checklist

| Surface | Pass |
|---------|------|
| **Cursor → MCP** | 4 green: `sbox`, `sbox-editor`, `sbox-jtc`, `cornerman-lm` |
| **Editor pill** | Green dot + `MCP · ≥1` (chomnr clients) |
| **Claude Bridge** | `get_bridge_status` → connected, heartbeat &lt; 30s |
| **Blender Bridge** | `http://127.0.0.1:8099/status` → `running: true`; **Auto-start Bridge on editor load** ON (saved `bridge_autostart 1`) |
| **chomnr mode** | **Approve writes** (not Full access) |

One-line probe:

```powershell
powershell -File Get-CvlConnectivityStatus.ps1 -Pretty
```

### 4. During work

- **ModelDoc / vmat / shader / prefab** → `sbox-editor`
- **Play, spawn, in-game screenshot** → `sbox`
- **Visual proof** → screenshot via MCP; agent reads PNG
- **`execute_csharp`** → sweep `Editor/__Exec_*.cs` after (see `SBOX_EDITOR_MCP.md`)

---

## Cornerman (optional — only when Green Cursor is active)

Green is **not** required for Red-only edit sessions. When Green runs Cursor:

- Triple MCP: SMB `sbox` + SSH tunnel `sbox-editor` + `cornerman-lm`
- No LM Studio **GUI** on Green (headless `:1234` only)
- Wire from Red: `RED_FULL_CAPACITY_BOOT.md` (or `Restore-CornermanDualStack.ps1`)

Skip Green checks when `OFF_CURSOR_ACTIVE.txt` is on the box.

---

## Agent stakes routing

| Work | Tier | MCP |
|------|------|-----|
| Compile fix, single vmat, spawn check | T2 | `sbox-editor` or `sbox` |
| Multi-file C#, economy, permissions | T1 (Opus) | repo + MCP as needed |
| Distill / bulk notes | T3 (Green) | `cornerman-lm` — prep only |
| ChatGPT concept / UX | Advisory | paste **CURSOR BRIEF** → Cursor |

---

## ChatGPT templates (editor-adjacent)

| Paste file | When |
|------------|------|
| `handoff/CHATGPT_STEP1_PASTE.txt` | New product ideation → CURSOR BRIEF |
| `handoff/CHATGPT_SBOX_EDIT_SESSION_PASTE.txt` | Before editor session — checklist advisory |
| `handoff/CHATGPT_VISUAL_PASS_PASTE.txt` | Asset/visual pass brief (Ophion-style) |
| `handoff/CHATGPT_ADDON_SHIP_CHECKLIST_PASTE.txt` | Pre-portal advisory review |

Process: `WORKFLOW_IDEATION_FIRST.md` · MCP law: `SBOX_EDITOR_MCP.md` · `MCP_AGENT_ROUTING.md`

---

## Deferred (not current lane)

- lifepunchnet Whisper STT / VENGEANCE PTT / Cornerman voice relay as **default** voice path
- OpenTelemetry (Grafana Phase 1 uses Prometheus blackbox probes — see `CVL_OBSERVABILITY_LANE.md`)
- DB workflow ledger (use git + `briefs/BRIEF_INDEX.md`)

Voice in Cursor = **mic plugin in chat**. Re-enable Whisper only when owner asks.
