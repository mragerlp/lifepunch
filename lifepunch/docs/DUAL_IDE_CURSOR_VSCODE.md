# Dual IDE: Cursor (Agent) + VS Code (Copilot)

**Status:** Active on VENGEANCE (June 2026).  
**Why:** Dimmer ships in **VS Code + GitHub Copilot**. Copilot does **not** run inside Cursor. Bloodwave uses Copilot mainly to **draft instructions for Cursor**; **VS Code can** run Copilot mirror review when **Cursor Agent routes it**.

**Copilot credit tips:** [Optimize AI credit usage in VS Code](https://code.visualstudio.com/docs/agents/guides/optimize-usage)

---

## Tool canon (June 2026)

```text
Cursor            = writer / MCP / proof / commit / STYLE routing judgment
VS Code + Copilot = instruction relay + Copilot mirror (when Agent says VS_MIRROR)
Cornerman         = cheap distill / prep
Codex             = strict reviewer / PASS · REVISE · HOLD gate
Bloodwave         = GO / commit / ship authority
```

**VS Code can; Cursor cannot (for Copilot):** GitHub Copilot inline + Chat work in **VS Code**. Cursor supports many **other** VS Code-format extensions (C#, Razor, etc.) — install those in Cursor for authoring; do **not** VSIX-hack Copilot into Cursor.

---

## STYLE routing (Agent judgment — Bloodwave does not pick)

After each DXRP-facing or upstream slice, Cursor Agent **must** emit one line:

| Verdict | Meaning | Bloodwave action |
|---------|---------|------------------|
| **`STYLE: PASS`** | Agent read upstream refs; patterns match | None — proceed to flatgrass / commit proposal |
| **`STYLE: VS_MIRROR`** | Agent wants Copilot’s Dimmer-environment pass | Open listed files in **VS Code** only; paste supplied Copilot prompt; **do not edit** unless Agent revises after |

**Agent default:** try `STYLE: PASS` via reference reads in `dxrp-public` + law docs. Escalate to `VS_MIRROR` when: new UI surface, unfamiliar DXRP subsystem, first slice on a pattern, or agent uncertainty on TabMenu / Sync / Razor SCSS.

**Bloodwave + Copilot (daily):** Copilot Chat → instructions/scope for Cursor — not file editing.

**Never paste secrets** into Copilot Chat.

---

## Gate discipline

### LifePunch addons (DXRP-mounted code)

```text
Copilot (optional) → Bloodwave drafts Cursor instruction
Cursor Agent implements slice
Agent emits STYLE: PASS | VS_MIRROR
[If VS_MIRROR] VS Code Copilot mirror on listed files only
Cursor MCP / Stop → Play / flatgrass proof
Bloodwave GO → commit
```

### DXRP upstream

```text
Issue approved first (e.g. #111)
Cursor Agent implements bounded PR slice
Agent STYLE gate → VS_MIRROR if needed
Codex PASS · REVISE · HOLD
Flatgrass proof (Cursor + MCP)
Clean PR, no AI trailers
Bloodwave GO → ship
```

---

## One-time setup (VENGEANCE)

**VS Code:** Copilot + Copilot Chat signed in · folders: `lifepunchaddons`, `dxrp-public`.

**Cursor:** C# / Razor extensions as needed · **Disable Cursor Tab** when VS Code is open on the same repo.

**Smoke test (once):** open `lifepunch/.../LpHashdPanel.razor` in VS Code — confirm Copilot live; no rewrite.

---

## Primary risk: two writers

VS Code **edits** only when Bloodwave explicitly switches writer there. `VS_MIRROR` = **review** (read Copilot suggestions; report back to Cursor if REVISE).

| VS Code | Cursor |
|---------|--------|
| Copilot mirror when Agent routes | All implementation |
| Instruction drafting (Bloodwave) | MCP / flatgrass proof |
| Read Dimmer PRs | Commits (with GO) |

---

## Model / credit routing

| Task | Route |
|------|--------|
| Instruction / scope draft | **Copilot Chat** (Bloodwave → Cursor) |
| Implement + STYLE gate | **Cursor Agent** |
| Copilot mirror | **VS Code** when `VS_MIRROR` only |
| Bulk distill | **Cornerman** |
| Upstream PR gate | **Codex** |

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
