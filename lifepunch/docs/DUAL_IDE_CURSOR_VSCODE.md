# Primary IDE: GitHub Copilot (Integration Architect — VENGEANCE)

> **SUPERSEDED (2026-07-09) by `CLAUDE.md`.** The primary build surface is now **Claude Code (Opus)**, not
> Copilot or Cursor. Both are retired to optional outside second opinion, on request only. This dual-IDE
> guidance is historical reference (MCP config detail may still apply when a legacy IDE is used).

**Status:** Copilot primary — VENGEANCE (June 2026).  
**Why:** Dimmer ships in **VS Code + GitHub Copilot**. Copilot does **not** run inside Cursor. Copilot is the **primary in-editor writer** on the full monorepo; **Cursor** remains peer for MCP bridge, flatgrass proof, sync scripts, and heavy plumbing.

**Copilot credit tips:** [Optimize AI credit usage in VS Code](https://code.visualstudio.com/docs/agents/guides/optimize-usage)

**Full-repo handoff:** `.github/instructions/copilot-repo-ownership.instructions.md` · paste: `lifepunch/docs/handoff/COPILOT_SBOX_EDITOR_BOOTSTRAP_PASTE.txt` · `lifepunch/docs/handoff/COPILOT_NEW_SESSION_BOOTSTRAP.txt`

---

## Tool canon (June 2026)

```text
VS Code + Copilot = primary writer (editor, DXRP-native, workflow/stack, whole repo, MCP in VS Code)
Cursor            = MCP bridge / flatgrass proof / sync scripts / legal-ops plumbing (peer, not legacy-only)
Cornerman         = cheap distill / prep (Tier-3)
Codex             = strict reviewer / PASS · REVISE · HOLD gate (upstream DXRP)
Bloodwave         = GO / commit / ship authority
```

**VS Code can; Cursor cannot (for Copilot):** GitHub Copilot inline + Chat work in **VS Code**. Cursor supports many **other** VS Code-format extensions (C#, Razor, etc.) — install those in Cursor for bridge-heavy sessions; do **not** VSIX-hack Copilot into Cursor.

**MCP stack (VS Code — `.vscode/mcp.json`):** `sbox` · `sbox-editor` · `cornerman-lm`  
**Commit hygiene:** No AI co-authored-by trailers. Bloodwave GO before commit/push.  
**Cursor rules (.mdc):** Copilot loads mirror via `.github/instructions/` — edit source in `.cursor/rules/`, then `Sync-CursorRulesToCopilotInstructions.ps1`.

---

## STYLE routing (active writer emits one line)

| Verdict | Meaning | Action |
|---------|---------|--------|
| **`STYLE: PASS`** | Patterns match dxrp-public + law docs | Proceed to proof / commit proposal |
| **`STYLE: REVISE`** | Mismatch vs upstream | Fix before commit |
| **`STYLE: CURSOR_PROOF`** | Needs Claude Bridge flatgrass / replication check | Handoff packet → Cursor |

**Default:** Copilot implements Dimmer-style patterns in VS Code. Escalate to Cursor for bridge proof, sync scripts, or multi-file integration Cursor owns.

**Never paste secrets** into Copilot Chat.

---

## Gate discipline

### LifePunch addons (DXRP-mounted code)

```text
Copilot implements in VS Code + s&box editor (+ MCP when in VS Code)
[If needed] HANDOFF → Cursor for bridge flatgrass proof
Bloodwave GO → commit (one writer per file)
```

### DXRP upstream

```text
Issue approved first (e.g. #111)
Copilot or Cursor implements bounded PR slice in dxrp-public
Codex PASS · REVISE · HOLD
Flatgrass proof (Copilot MCP in VS Code, or Cursor bridge when needed)
Clean PR, no AI trailers
Bloodwave GO → ship
```

---

## Commit workflow (explicit — no auto-commit hook)

```powershell
cd C:\Users\jared\Projects\lifepunch
git add <files>
git commit -m "<type>(<scope>): <description>"
git push
```

**Laws:** No `Co-authored-by` trailers. Author = `mragerlp <mragerlp@gmail.com>`. Bloodwave GO before commit/push.

---

## One-time setup (VENGEANCE)

**VS Code:** Copilot + Copilot Chat signed in · workspace root: `lifepunchaddons` (not a subfolder) · `dxrp-public` as second folder if needed · `.vscode/mcp.json` present.

**Cursor:** C# / Razor + bridge MCP when Copilot hands off proof/plumbing work.

**Instructions auto-load:** `.github/instructions/*.instructions.md` + `copilot-instructions.md` (see `.vscode/settings.json`).

**Smoke test (once):** open `lifepunch/.../LpHashdPanel.razor` in VS Code — Copilot live; `@workspace` finds repo law.

---

## Primary risk: two writers

| VS Code (Copilot) | Cursor |
|-------------------|--------|
| Editor, prefab, ModelDoc, Razor, workflow scripts | Bridge screenshots / replication proof |
| Full monorepo edits (active lane) | Sync/publish plumbing |
| MCP in VS Code (sbox stack) | Legal, Cloudflare, complex multi-agent routing |

**One writer per file.** Announce lane switch before touching a file the other IDE owns.

---

## Model / credit routing

| Task | Route |
|------|--------|
| In-editor + DXRP implement | **Copilot (VS Code)** |
| Flatgrass / bridge proof (when Copilot MCP insufficient) | **Cursor** |
| Bulk distill | **Cornerman** |
| Upstream PR gate | **Codex** |
| Design / economy brief | **Design Architect (ChatGPT)** |
| Local Ollama (Blue) | Odysseus prep only — not primary ship path |

Law: `.cursor/rules/lifepunch-dxrp-style-gate.mdc`

---

## Active state (June 2026)

| Lane | State |
|------|-------|
| **LPBitcoin** | Phase A Hub — U1.1 / flatgrass proof gate |
| **Monorepo** | `lifepunchaddons` canonical path (LIFEPUNCH rename docs in flight) |

---

## Related

- `lifepunch/docs/DXRP_CONTRIBUTOR_LANE.md`
- `lifepunch/docs/MCP_AGENT_ROUTING.md`
- `lifepunchaddons/docs/SBOX_RAZOR_SCSS_RULES.md`
- `.cursor/rules/lifepunch-dxrp-style-gate.mdc`
- `.github/instructions/copilot-repo-ownership.instructions.md`
