# Dual IDE: Cursor (Agent) + VS Code (Copilot)

**Status:** Active on VENGEANCE (June 2026).  
**Why:** Dimmer ships in **VS Code + GitHub Copilot**. Copilot does **not** run inside Cursor. Copilot is the **primary in-editor writer** on the full monorepo; Cursor is peer for MCP bridge, flatgrass proof, and heavy plumbing.

**Copilot credit tips:** [Optimize AI credit usage in VS Code](https://code.visualstudio.com/docs/agents/guides/optimize-usage)

**Full-repo handoff:** `.github/instructions/copilot-repo-ownership.instructions.md` · paste: `lifepunch/docs/handoff/COPILOT_SBOX_EDITOR_BOOTSTRAP_PASTE.txt`

---

## Tool canon (June 2026)

```text
VS Code + Copilot = primary writer (editor, DXRP-native, workflow/stack, whole repo)
Cursor            = MCP bridge / flatgrass proof / sync scripts / legal-ops plumbing
Cornerman         = cheap distill / prep (Tier-3)
Codex             = strict reviewer / PASS · REVISE · HOLD gate (upstream DXRP)
Bloodwave         = GO / commit / ship authority
```

**VS Code can; Cursor cannot (for Copilot):** GitHub Copilot inline + Chat work in **VS Code**. Cursor supports many **other** VS Code-format extensions (C#, Razor, etc.) — install those in Cursor for MCP sessions; do **not** VSIX-hack Copilot into Cursor.

---

## STYLE routing (simplified — Copilot owns Dimmer lane)

After each DXRP-facing slice, the **active writer** emits one line when upstream pattern fit is uncertain:

| Verdict | Meaning | Action |
|---------|---------|--------|
| **`STYLE: PASS`** | Patterns match dxrp-public + law docs | Proceed to proof / commit proposal |
| **`STYLE: REVISE`** | Copilot or Cursor lists mismatch vs upstream | Fix before commit |
| **`STYLE: CURSOR_PROOF`** | Needs Claude Bridge flatgrass / replication check | Handoff packet → Cursor |

**Default:** Copilot implements Dimmer-style patterns directly in VS Code. Escalate to Cursor only for bridge proof, sync scripts, or multi-file integration Cursor already owns.

**Never paste secrets** into Copilot Chat.

---

## Gate discipline

### LifePunch addons (DXRP-mounted code)

```text
Copilot implements in VS Code + s&box editor
[If needed] HANDOFF → Cursor for bridge flatgrass proof
Bloodwave GO → commit (either IDE; one writer per file)
```

### DXRP upstream

```text
Issue approved first (e.g. #111)
Copilot or Cursor implements bounded PR slice in dxrp-public
Codex PASS · REVISE · HOLD
Flatgrass proof (Cursor + MCP when Copilot cannot see runtime)
Clean PR, no AI trailers
Bloodwave GO → ship
```

---

## One-time setup (VENGEANCE)

**VS Code:** Copilot + Copilot Chat signed in · workspace root: `lifepunchaddons` (not a subfolder) · folders: `lifepunchaddons`, `dxrp-public`.

**Cursor:** C# / Razor extensions as needed · **Disable Cursor Tab** when VS Code is open on the same repo.

**Instructions auto-load:** `.github/instructions/*.instructions.md` + `copilot-instructions.md` (see `.vscode/settings.json`).

**Smoke test (once):** open `lifepunch/.../LpHashdPanel.razor` in VS Code — confirm Copilot live; `@workspace` finds repo law.

---

## Primary risk: two writers

| VS Code (Copilot) | Cursor |
|-------------------|--------|
| Editor, prefab, ModelDoc, Razor, workflow scripts | MCP / bridge screenshots |
| Full monorepo edits (active lane) | Sync/publish plumbing |
| Cut loops in docs/scripts | Legal, Cloudflare, complex multi-agent routing |

**One writer per file.** Announce lane switch in chat before touching a file the other IDE owns.

---

## Model / credit routing

| Task | Route |
|------|--------|
| In-editor + DXRP implement | **Copilot (VS Code)** |
| Flatgrass / bridge proof | **Cursor** |
| Bulk distill | **Cornerman** |
| Upstream PR gate | **Codex** |
| Local Ollama (Blue) | Odysseus prep only — not primary ship path |

Law: `.cursor/rules/lifepunch-dxrp-style-gate.mdc`

---

## Active blockers (June 2026)

| Lane | Blocker |
|------|---------|
| **LPBitcoin** | U1.1 flatgrass proof before U2 |
| **DXRP #111** | Dimmer approval before `outline-defaults` |

---

## Related

- `lifepunch/docs/DXRP_CONTRIBUTOR_LANE.md`
- `lifepunch/docs/SBOX_RAZOR_SCSS_RULES.md`
- `.cursor/rules/lifepunch-dxrp-style-gate.mdc`
- `.github/instructions/copilot-repo-ownership.instructions.md`
