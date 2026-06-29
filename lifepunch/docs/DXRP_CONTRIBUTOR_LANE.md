# DXRP contributor lane (upstream bounty / vanilla work)

**Status:** Active — Bloodwave on Dxura DXRP dev team (June 2026).  
**When:** Any session touching **`mragerlp/dxrp-public`** or opening PRs to **`dxura/dxrp:develop`**.  
**Not when:** LifePunch addon ship lane (`lifepunchaddons` monorepo, proprietary addons, portal publish).

---

## Two repos — never collapse

| Lane | Clone path | Remote | Commit? | Contains |
|------|------------|--------|---------|----------|
| **LifePunch (private)** | `C:\Users\jared\Projects\lifepunchaddons` | `github.com/mragerlp/lifepunch` | Yes (owner approves) | LIFEPUNCH™ addons, legal, portal, server ops, proprietary headers |
| **DXRP fork (public upstream)** | `C:\Users\jared\Projects\dxrp-public` | `origin` → `mragerlp/dxrp-public`, `upstream` → `dxura/dxrp` | Yes (bounty/PR branches) | Vanilla DXRP gamemode only — **no LifePunch IP** |

**Steam editor checkout:** `D:\Steam\steamapps\common\sbox\dxrp` — runtime only; **never commit** from there.

**Do not** add `dxura/dxrp` as a remote inside the LifePunch monorepo (different history + disclosure rules).

---

## Agent focus switch (paste at session start)

### DXRP upstream session

```text
FOCUS: DXRP upstream (mragerlp/dxrp-public → dxura/dxrp develop)
Clone: C:\Users\jared\Projects\dxrp-public
Branch: bounty/* or lifepunch/fix-* from develop — NOT lifepunch main

FORBIDDEN in this session:
- LifePunch proprietary file headers (© lifepunch.co blocks)
- lifepunch/ paths, addons.json, LIFEPUNCH™ branding, portal publish, bitcoin lane code
- Copying LifePunch addon C# into dxrp-public
- Committing local machine paths (D:/Steam, game/Libraries/* MCP dev tools, editor _c noise)

REQUIRED:
- Match DXRP style (TabMenu patterns, dxrp.json localization, existing UI components)
- Small scoped PRs; cite GitHub issue (#73 party, etc.)
- Rebase on upstream develop before PR: lifepunch\scripts\sync-dxrp-fork.ps1

Editor gate (when allowed): Ensure-DxrpUpstreamCurrent.ps1 -Sync -UpdatePin -SyncSteam
Proof: flatgrass / bridge — not editor-only for HUD interactivity
```

### LifePunch ship session

```text
FOCUS: LifePunch private monorepo (lifepunchaddons)
Gate: ACTIVE_WORKSTREAM.md + BITCOIN_SHIP_ROADMAP.md
Do NOT edit dxrp-public unless explicitly bouncing an upstream fix back to the fork.
```

---

## Sync loop (DXRP fork)

```powershell
cd C:\Users\jared\Projects\lifepunchaddons
git pull --rebase

powershell -File lifepunch\scripts\sync-dxrp-fork.ps1
# After work on bounty branch:
powershell -File lifepunch\scripts\sync-dxrp-fork.ps1 -PushOrigin
```

Pin: `lifepunch/config/dxrp-upstream-pin.json` — update after upstream bump.

PR target: **`mragerlp/dxrp-public:<branch>` → `dxura/dxrp:develop`**

Canon: `lifepunch/docs/DXRP_DOCS_REFERENCE.md` § LifePunch to DXRP Fork Bridge.

---

## Clean working tree (dxrp-public)

Before every commit / before asking Dimmer for review:

```powershell
cd C:\Users\jared\Projects\dxrp-public
git status -sb

# Discard local editor noise + machine-specific csproj/slnx (NEVER commit these):
git restore -- game/Assets game/Code/rp.csproj game/Editor/rp.editor.csproj game/rp.slnx
git restore -- game/Code/Chat/Chat.Handler.cs game/Code/Chat/MessageType.cs game/Code/System/RP/PartyRoom.cs
git restore -- game/Code/UI/HUD/Chat/

# Do NOT git add game/Libraries/* (local MCP dev tools)
```

Commit **only** intentional `.cs` / `.razor` / `.scss` / `dxrp.json` party (or bounty) files.

---

## Commit hygiene — NO AI attribution (hard law)

Full law + recovery: **`.cursor/rules/lifepunch-commit-hygiene.mdc`**. Upstream-specific points:

- **No AI/agent co-author trailers ever** (`Co-authored-by: Cursor <cursoragent@cursor.com>`, Claude,
  Copilot, etc.). They render Cursor as a co-author on the public PR — a bad look on a bounty.
  **June 2026 incident:** PR #77 shipped the Cursor trailer; cleaned via `filter-branch` + force-with-lease.
- **Root cause:** Cursor **Settings → Agent → Attribution** (Commit + PR Attribution) auto-injects it.
  Keep both **OFF** (UI toggle, not `settings.json`). It also wraps `git commit*`, so `commit --amend`
  can't strip it — use `git filter-branch --msg-filter` (see the rule).
- **Install the backstop hook per clone** (blocks any AI trailer at commit time):
  ```powershell
  powershell -File lifepunch\scripts\Install-CommitHygieneHook.ps1
  ```
- **Don't spam `#73` in every commit.** Clean commit subjects (`fix(party): align HUD drag + collapse`);
  reference the issue in the **PR title/body** (`feat: … (#73)`), not each commit — that's what posts
  every commit into the issue timeline.
- **Pre-push scan:**
  ```powershell
  git log <upstream-base>..HEAD --format='%H%n%B' | Select-String 'cursoragent|Co-authored'
  ```

---

## Current bounty: Party system (#73) — SHIPPED to PR #77

PR **#77** (`mragerlp:bounty/73-party-system` → `dxura/dxrp:develop`): **open · mergeable: clean**,
22 files / +2609 / -5, head `914967a`. Dimmer approved ("you can continue"); his one criticism (4
syncvars → 1 GUID→struct netdict) is implemented as a single `[Sync(FromHost)] NetDictionary<Guid,
PartyData> Parties`. All commits authored by `mragerlp`, **no AI trailer** (history cleaned 2026-06-29).

**Branch:** `bounty/73-party-system` on `mragerlp/dxrp-public`  
**Done:** Party HUD Alt-gated drag + collapse chevron (mirrors `AdminTickets` + `DraggablePanel`);
`/party` menu equal-width roster cards. Awaiting Dimmer's review/merge.

---

## External docs for Dimmer / PR workflow

| Doc | URL / path |
|-----|------------|
| DXRP fork bridge | `lifepunch/docs/DXRP_DOCS_REFERENCE.md` |
| Upstream pin | `lifepunch/config/dxrp-upstream-pin.json` |
| Operator wiki | `https://github.com/dxura/dxrp-public/wiki/Operator` |
| DXRP docs | `https://docs.dxrp.net/` |
| Public addons reference | `https://dxrp.net/addons` |
| This lane | `lifepunch/docs/DXRP_CONTRIBUTOR_LANE.md` |

---

## Trademark note (upstream work)

DXRP/Dxura/s&box = third party (nominative use only). Upstream PRs use **DXRP conventions**, not LIFEPUNCH™ headers or LifePunch proprietary blocks.
