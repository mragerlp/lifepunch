# Dual IDE: Cursor (Agent) + VS Code (Copilot)

**Status:** Active on VENGEANCE (June 2026).  
**Why:** Dxura staff (Dimmer) ships in **VS Code + GitHub Copilot**. Copilot is **not supported inside Cursor**. Bloodwave uses **both IDEs on both repos** so LifePunch addon code and upstream DXRP work stay Dimmer-aligned and actually compile/review the same way upstream does.

**Copilot credit tips:** [Optimize AI credit usage in VS Code](https://code.visualstudio.com/docs/agents/guides/optimize-usage) — plan in one chat, implement in another; exclude noisy paths; disable unused MCP in VS Code.

---

## Role split (both repos)

| Tool | Owns |
|------|------|
| **Cursor Agent / Composer** | Multi-file slices, architecture, s&box MCP (bridge, editor), flatgrass proof, git commit/push, `.cursor/rules` |
| **Cursor Tab** | Inline completions in Cursor when VS Code is **closed** on that folder |
| **VS Code Copilot (inline)** | Ghost-text completions the way Dimmer writes — spot-check after Cursor lands a slice |
| **VS Code Copilot Chat** | Single-file / diff review, “does this match DXRP TabMenu/Razor patterns?” |
| **VS Code Copilot Agent** | Small planning forks only — **not** whole-repo refactors (burns credits; use Cursor instead) |

**Never:** VSIX-hack Copilot into Cursor · run Cursor Tab + Copilot inline on the **same file** · run Copilot Agent + Cursor Agent on the **same slice** in parallel.

---

## One-time setup (VENGEANCE)

1. Install [VS Code](https://code.visualstudio.com/).
2. Extensions (`Ctrl+Shift+X`): **GitHub Copilot**, **GitHub Copilot Chat** (publisher: **GitHub**).
3. `Ctrl+Shift+P` → **GitHub Copilot: Sign In**.
4. Open workspace folders (same clones Cursor uses — **do not duplicate repos**):
   - `C:\Users\jared\Projects\lifepunchaddons` — LifePunch monorepo (addons, docs, scripts)
   - `C:\Users\jared\Projects\dxrp-public` — upstream DXRP fork

Opening the monorepo root loads `.vscode/extensions.json` (Copilot recommendations) and shared exclusion hints.

---

## Cursor Tab vs Copilot (one inline engine per folder)

When VS Code is open on a repo:

- Cursor: `Ctrl+Shift+P` → **Disable Cursor Tab** (or status bar **Tab** → Disable globally).

When back to Cursor-only (e.g. MCP playtest session without VS Code on that tree):

- Re-enable Cursor Tab.

---

## Repo workflows

### LifePunch monorepo (`lifepunchaddons`)

| Phase | Cursor | VS Code + Copilot |
|-------|--------|-------------------|
| **Plan** | Agent + `ACTIVE_WORKSTREAM.md` / rules | Optional Copilot Chat on a pasted slice plan |
| **Implement** | Agent — `lifepunch/addons/Code`, Razor, ModelDoc prep | Open **touched files only**; inline suggests DXRP-style C#/Razor |
| **DXRP-facing code** | Sync mount: `Sync-LifePunchAddonsToDxrp.ps1` | Match patterns from `dxrp-public` (TabMenu, `[Sync(FromHost)]`, `dxrp.json` keys) |
| **Playtest** | s&box MCP, flatgrass, `lp_*` ConCmds | **Do not** playtest from VS Code — eyes stay in Cursor |
| **Commit** | Preferred (MCP context, hooks) | OK if Cursor Tab off and files saved — author `mragerlp` only |

**Dimmer-aligned mirror:** LifePunch addons that run **on** DXRP should read like upstream gamemode code — same Razor SCSS class-root rules, same host-authoritative sync patterns, no LifePunch headers in `dxrp-public`. Use Copilot in VS Code on **both** trees when touching shared concepts (party UI, admin panels, rank permissions).

### DXRP upstream (`dxrp-public`)

| Phase | Cursor | VS Code + Copilot |
|-------|--------|-------------------|
| **Implement** | Agent on `lifepunch/*` or `mragerlp-party-phase-2` branches | Parity pass on changed `.cs` / `.razor` |
| **Review Dimmer** | PR prep, rebase | Copilot Chat on his diffs / issues |
| **Commit / PR** | Primary | Same hygiene as Cursor |

Canon: `lifepunch/docs/DXRP_CONTRIBUTOR_LANE.md` · tracker [#111](https://github.com/dxura/dxrp/issues/111) (Party Phase 2).

---

## Daily loop (any lane)

```text
1. Plan     → Cursor (or one short Copilot Plan pass) — issue link + slice name only
2. Build    → Cursor Agent — one focused slice
3. Mirror   → VS Code — open changed files; Copilot inline + Chat sanity check
4. Prove    → Cursor only — flatgrass / bridge / compile
5. Commit   → one IDE per slice; save all; no AI co-author trailers
```

**New chat per slice** (`Ctrl+N` in Copilot Chat; fresh Cursor chat with bootstrap paste).

**Exclude noise** (both IDEs): `_c` outputs, `.dxrp-publish/`, `game/Libraries/*`, large logs — see `.vscode/settings.json` in monorepo.

---

## Model / credit discipline

| Task | Route |
|------|--------|
| Bitcoin hub C# / Razor blockers | Cursor **Opus** (API pool) per `OPUS_USAGE_LAW.md` |
| Routine edits, localization, docs | Cursor **Auto / Composer** |
| DXRP party slice (#111) | Cursor Agent; VS Code Copilot **review only** |
| Inline “next line” completion | VS Code Copilot |
| Bulk distill / classify | Cornerman (Tier-3) — not Copilot |

VS Code: lighter models for boilerplate; reasoning models only for plan/debug; `/compact` long chats; [full guide](https://code.visualstudio.com/docs/agents/guides/optimize-usage).

---

## Commit hygiene (both IDEs)

- Author: **`mragerlp <mragerlp@gmail.com>`** only.
- **No** `Co-authored-by: Cursor / Copilot / Claude` — Cursor **Settings → Agent → Attribution OFF**.
- Hook: `lifepunch\scripts\Install-CommitHygieneHook.ps1` on each clone that commits.

---

## Quick reference

```text
LifePunch ship day:
  Cursor Agent → lifepunchaddons (implement + MCP proof)
  VS Code Copilot → mirror pass on touched addon files
  Cursor Tab OFF while VS Code open on lifepunchaddons

DXRP upstream day:
  Cursor Agent → dxrp-public (branch from develop)
  VS Code Copilot → Dimmer parity + PR review
  Cursor Tab OFF while VS Code open on dxrp-public
```

---

## Related

- `lifepunch/docs/DXRP_CONTRIBUTOR_LANE.md` — fork paths, #111, sync scripts
- `lifepunch/docs/OPUS_USAGE_LAW.md` — when not to burn API pool
- `lifepunch/docs/SBOX_RAZOR_SCSS_RULES.md` — Razor patterns Copilot should match
- `.cursor/rules/lifepunch-commit-hygiene.mdc`
