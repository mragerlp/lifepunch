# Primary IDE: GitHub Copilot (Integration Architect — VENGEANCE)

**Status:** Copilot promoted to primary — VENGEANCE (July 2026).  
**Why:** Dxura ships on GitHub + VS Code. Copilot is GitHub-native. Persistent session memory, worktree-native, parallel agent support, and live sbox MCP bridge proven in editor. Cursor remains available as a fallback reference tool only.

**Copilot credit tips:** [Optimize AI credit usage in VS Code](https://code.visualstudio.com/docs/agents/guides/optimize-usage)

---

## Tool canon (July 2026 — updated)

```text
GitHub Copilot    = PRIMARY writer / MCP / proof / commit (with GO) / STYLE routing judgment
Cursor            = LEGACY fallback / reference only (not primary)
Cornerman         = cheap distill / prep
Codex             = strict reviewer / PASS · REVISE · HOLD gate
Bloodwave         = GO / commit / ship authority
```

**MCP stack (all 4 servers — .vscode/mcp.json):** `sbox` · `sbox-editor` · `cornerman-lm` · `sbox-jtc`  
**Commit hygiene:** No auto-commit hook — all commits are explicit shell steps after Bloodwave GO. No AI co-authored-by trailers.  
**Cursor rules (.mdc):** Not loaded by Copilot — agent enforces `lifepunch-commit-hygiene`, `lifepunch-quality-bar`, and SCSS constraints from knowledge. See `.cursor/rules/` for reference.

---

## STYLE routing (agent judgment — Bloodwave does not pick)

After each DXRP-facing or upstream slice, Copilot Agent **must** emit one line:

| Verdict | Meaning | Bloodwave action |
|---------|---------|------------------|
| **`STYLE: PASS`** | Agent read upstream refs; patterns match | None — proceed to flatgrass / commit proposal |
| **`STYLE: REVIEW`** | Agent wants a pass on specific files | Agent reviews inline; revises if needed |

**Agent default:** try `STYLE: PASS` via reference reads in `dxrp-public` + law docs. Escalate to `STYLE: REVIEW` when: new UI surface, unfamiliar DXRP subsystem, first slice on a pattern, or uncertainty on TabMenu / Sync / Razor SCSS.

**Never paste secrets** into Copilot Chat.

---

## Gate discipline

### LifePunch addons (DXRP-mounted code)

```text
Copilot Agent implements slice (with GO)
Agent emits STYLE: PASS | STYLE: REVIEW
Copilot MCP → Stop → Play → flatgrass proof
Bloodwave GO → git commit (explicit shell command, no hook)
```

### DXRP upstream

```text
Issue approved first (e.g. #111)
Copilot Agent implements bounded PR slice
Agent STYLE gate
Codex PASS · REVISE · HOLD
Flatgrass proof (Copilot + MCP)
Clean PR, no AI trailers
Bloodwave GO → ship
```

---

## Commit workflow (manual — no auto-commit hook)

Copilot has no equivalent to Cursor's `auto-commit-push.ps1`. All commits are explicit:

```powershell
cd C:\Users\jared\Projects\lifepunchaddons
git add <files>
git commit -m "<type>(<scope>): <description>"
git push
```

**Laws:** No `Co-authored-by` trailers. Commit author = `mragerlp`. Bloodwave must give GO before any commit/push.

---

## One-time setup (VENGEANCE)

**GitHub Copilot app + VS Code:** signed in · workspace `lifepunchaddons` · `.vscode/mcp.json` present (all 4 servers).  
**Cursor:** available as fallback reference only — C#/Razor extension host if needed. Do not use as primary agent.

---

## Primary risk: two writers

Only ONE tool writes at a time. Copilot is the writer. Cursor is read-only reference if opened.

| Copilot | Cursor (legacy) |
|---------|-----------------|
| All implementation | Reference/fallback only |
| MCP / flatgrass proof | Do not commit from here |
| Commits (with GO) | Do not use as primary agent |

---

## Model / credit routing

| Task | Route |
|------|--------|
| Implement + STYLE gate | **Copilot Agent (VENGEANCE)** |
| Bulk distill | **Cornerman** |
| Upstream PR gate | **Codex** |
| Design / economy brief | **Design Architect (ChatGPT)** |

---

## Active state (July 2026)

| Lane | State |
|------|-------|
| **LPBitcoin** | U1.1 committed — H4/H5 next, GO pending |
| **lifepunchulx r10** | committed — portal upload pending |
| **Monnow Rev 9** | staging ready — portal pin pending |

---

## Related

- `lifepunch/docs/MCP_AGENT_ROUTING.md`
- `lifepunch/addons/docs/SBOX_RAZOR_SCSS_RULES.md`
- `.cursor/rules/` (reference — not loaded by Copilot; agent enforces from knowledge)
