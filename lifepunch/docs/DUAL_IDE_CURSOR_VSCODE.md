# Dual IDE: Cursor (Agent) + VS Code (Copilot)

**Status:** Active on VENGEANCE (June 2026).  
**Why:** Dxura staff (Dimmer) ships in **VS Code + GitHub Copilot**. Copilot is **not supported inside Cursor**. Bloodwave uses **both IDEs on both repos** so LifePunch addon code and upstream DXRP work stay Dimmer-aligned.

**Copilot credit tips:** [Optimize AI credit usage in VS Code](https://code.visualstudio.com/docs/agents/guides/optimize-usage)

---

## Tool canon (June 2026)

```text
Cursor           = writer / MCP / proof / commit
VS Code + Copilot = mirror reviewer / upstream-style sanity pass
Cornerman        = cheap distill / prep
Codex            = strict reviewer / PASS · REVISE · HOLD gate
Bloodwave        = GO / commit / ship authority
```

### Primary risk: two editors becoming two writers

**VS Code is a review mirror — not a second implementation lane** unless Bloodwave explicitly chooses to edit there.

| Do in VS Code | Do not in VS Code (default) |
|---------------|----------------------------|
| Open touched `.cs` / `.razor` / `.scss` after Cursor lands a slice | Multi-file refactors |
| Copilot inline — read suggestions, compare to DXRP style | Accept large Copilot rewrites without Cursor re-proof |
| Copilot Chat — “does this match TabMenu / Sync patterns?” | Copilot Agent on whole-repo tasks |
| Read-only walkthrough of Dimmer PRs | Stop → Play / flatgrass proof |
| | `git commit` (unless Bloodwave explicitly switched writer to VS Code) |

**Cursor remains the only implementation + MCP proof authority** unless Bloodwave explicitly switches tools.

---

## Gate discipline

### LifePunch addons

```text
Cursor Agent implements slice
VS Code opens touched .cs / .razor / .scss
Copilot sanity-checks DXRP-style patterns (review only — no rewrite)
Cursor performs MCP / Stop → Play / flatgrass proof
Bloodwave approves commit
```

### DXRP upstream

```text
Issue approved first (e.g. #111)
Cursor Agent implements bounded PR slice
VS Code Copilot mirror pass
Codex final scope/proof review (PASS · REVISE · HOLD)
Flatgrass proof (Cursor + MCP)
Clean PR, no AI trailers
Bloodwave GO / ship
```

---

## One-time setup (VENGEANCE)

1. Install [VS Code](https://code.visualstudio.com/).
2. Extensions (`Ctrl+Shift+X`): **GitHub Copilot**, **GitHub Copilot Chat** (publisher: **GitHub**).
3. `Ctrl+Shift+P` → **GitHub Copilot: Sign In**.
4. **File → Open Folder** → `C:\Users\jared\Projects\lifepunchaddons` (loads `.vscode/extensions.json`).
5. Optional second window: `C:\Users\jared\Projects\dxrp-public`.

### Smoke test (mirror live — do not rewrite)

Open in VS Code:

```text
lifepunch/addons/Code/Addons/lifepunch/lpbitcoin/bitcoinhub/code/ui/LpHashdPanel.razor
```

Confirm Copilot inline (gray suggestion) and Copilot Chat respond. **Do not ask Copilot to rewrite the file** — activation check only.

When VS Code is open on a repo: Cursor → **Disable Cursor Tab** (`Ctrl+Shift+P`).

---

## Role detail

| Tool | Owns |
|------|------|
| **Cursor Agent / Composer** | Multi-file slices, architecture, s&box MCP, flatgrass proof, commits (with Bloodwave GO) |
| **Cursor Tab** | Inline in Cursor when VS Code is **closed** on that folder |
| **VS Code Copilot** | Mirror reviewer — inline + Chat on **already-written** files |
| **Cornerman** | Distill, inbox prep, Tier-3 drafts — not writer, not proof |
| **Codex** | Strict reviewer gate before upstream PR ship |
| **Bloodwave** | GO, commit consent, ship authority |

**Never:** VSIX-hack Copilot into Cursor · Cursor Tab + Copilot inline on the same file · Copilot Agent + Cursor Agent on the same slice in parallel.

---

## Repo workflows

### LifePunch monorepo (`lifepunchaddons`)

- **Implement + prove:** Cursor only (`ACTIVE_WORKSTREAM.md`, MCP, flatgrass).
- **Mirror:** VS Code on touched addon files — DXRP-facing code should match upstream patterns (`SBOX_RAZOR_SCSS_RULES.md`, `[Sync(FromHost)]`, TabMenu).
- **Sync mount before playtest:** `Sync-LifePunchAddonsToDxrp.ps1 -Addon lpbitcoin`.

### DXRP upstream (`dxrp-public`)

- **Implement:** Cursor on approved issue branches (`mragerlp-party-phase-2`, etc.).
- **Mirror + Dimmer parity:** VS Code Copilot on changed gamemode files.
- **Canon:** `lifepunch/docs/DXRP_CONTRIBUTOR_LANE.md` · [#111](https://github.com/dxura/dxrp/issues/111).

---

## Model / credit routing

| Task | Route |
|------|--------|
| Bitcoin hub C# / Razor blockers | Cursor **Opus** — `OPUS_USAGE_LAW.md` |
| Routine edits, docs | Cursor **Auto / Composer** |
| DXRP party slice (#111) | Cursor write; VS Code **review only** |
| Bulk distill / classify | **Cornerman** — not Copilot |
| Pre-PR strict review (upstream) | **Codex** PASS · REVISE · HOLD |

---

## Commit hygiene

- Author: **`mragerlp <mragerlp@gmail.com>`** only.
- **No** AI co-author trailers — Cursor **Settings → Agent → Attribution OFF**.
- Hook: `lifepunch\scripts\Install-CommitHygieneHook.ps1`.

---

## Active blockers (June 2026)

| Lane | Blocker |
|------|---------|
| **LPBitcoin** | U1.1 — Stop → Play / flatgrass proof before U2 |
| **DXRP Party #111** | Wait for Dimmer/Dxura approval before `outline-defaults` |
| **Copilot in Cursor** | Not supported — do not chase |

**Red (VENGEANCE):** verify VS Code Copilot mirror smoke test, then return to active proof gate.  
**Green (Cornerman):** no change.  
**Architect:** Cursor = only implementation/proof authority unless Bloodwave switches tools.

---

## Quick reference

```text
LifePunch ship:
  Cursor writes + MCP proves
  VS Code mirrors (review only)
  Bloodwave GO → commit

DXRP upstream:
  Issue GO → Cursor slice → VS Code mirror → Codex review → flatgrass → PR
```

---

## Related

- `lifepunch/docs/DXRP_CONTRIBUTOR_LANE.md`
- `lifepunch/docs/OPUS_USAGE_LAW.md`
- `lifepunch/docs/SBOX_RAZOR_SCSS_RULES.md`
- `.cursor/rules/lifepunch-commit-hygiene.mdc`
