# LifePunch â€” GitHub Copilot repository instructions

**Machine:** VENGEANCE Â· **Workspace:** `lifepunchaddons` (github.com/mragerlp/lifepunch)

## Source of truth

| Layer | Path |
|-------|------|
| **Cursor law (edit here)** | `.cursor/rules/*.mdc` |
| **Copilot mirror (generated)** | `.github/instructions/*.instructions.md` |

Regenerate after any rule change:

```powershell
powershell -File lifepunch\scripts\Sync-CursorRulesToCopilotInstructions.ps1
```

Last sync: **2026-06-30 21:37 UTC** Â· **20** rule files

## How Copilot loads this

VS Code applies **every** file in `.github/instructions/` with `applyTo: "**"` on **all** chat requests
in this workspace, **plus** this file (`copilot-instructions.md`).

Open workspace root `lifepunchaddons` in VS Code (not a subfolder only).

## Law hierarchy (conflicts â€” repo wins)

1. `.cursor/rules` / `.github/instructions` (this mirror)
2. `lifepunch/addons/docs/ACTIVE_WORKSTREAM.md` + `BITCOIN_SHIP_ROADMAP.md`
3. `lifepunch/docs` canon Â· `DECISIONS/`
4. Chat history (lowest)

## Active lane (June 2026)

**lifepunchbitcoin** / `lpbitcoin` only until Law 10 flatgrass + owner sign-off.
Blocked: Hacker, Banker, Government, Casino, â€¦

## Git / commits

- Author: `mragerlp <mragerlp@gmail.com>` only
- **Never** AI `Co-authored-by` / Cursor trailers in commits
- Propose scope; wait for Bloodwave **yes** before commit

## Copilot â†” Cursor handoff

- **Copilot (VS Code):** DXRP/s&box editor-native work, Razor, prefab/ModelDoc, Dimmer-style patterns
- **Cursor:** MCP bridge, flatgrass proof, sync scripts, multi-file integration
- One **writer** per file; `git pull --rebase` before picking up handoff

## Mirrored rules (20)

- `dxrp-addon-foundation.mdc` â†’ `instructions/dxrp-addon-foundation.instructions.md`
- `lifepunch-active-workstream-gate.mdc` â†’ `instructions/lifepunch-active-workstream-gate.instructions.md`
- `lifepunch-agent-session-discipline.mdc` â†’ `instructions/lifepunch-agent-session-discipline.instructions.md`
- `lifepunch-ak47-lane.mdc` â†’ `instructions/lifepunch-ak47-lane.instructions.md`
- `lifepunch-bitcoinmining-ip.mdc` â†’ `instructions/lifepunch-bitcoinmining-ip.instructions.md`
- `lifepunch-commit-hygiene.mdc` â†’ `instructions/lifepunch-commit-hygiene.instructions.md`
- `lifepunch-digital-machine.mdc` â†’ `instructions/lifepunch-digital-machine.instructions.md`
- `lifepunch-dxrp-style-gate.mdc` â†’ `instructions/lifepunch-dxrp-style-gate.instructions.md`
- `lifepunch-explorer-icons.mdc` â†’ `instructions/lifepunch-explorer-icons.instructions.md`
- `lifepunch-operating-context.mdc` â†’ `instructions/lifepunch-operating-context.instructions.md`
- `lifepunch-opus-usage.mdc` â†’ `instructions/lifepunch-opus-usage.instructions.md`
- `lifepunch-quality-bar.mdc` â†’ `instructions/lifepunch-quality-bar.instructions.md`
- `lifepunch-rules-workflow.mdc` â†’ `instructions/lifepunch-rules-workflow.instructions.md`
- `lifepunch-sbox-mcp-stack.mdc` â†’ `instructions/lifepunch-sbox-mcp-stack.instructions.md`
- `lifepunch-sbox-patches.mdc` â†’ `instructions/lifepunch-sbox-patches.instructions.md`
- `lifepunch-shortcut-icons.mdc` â†’ `instructions/lifepunch-shortcut-icons.instructions.md`
- `lifepunch-trademark-ip.mdc` â†’ `instructions/lifepunch-trademark-ip.instructions.md`
- `lifepunch-ui-scale.mdc` â†’ `instructions/lifepunch-ui-scale.instructions.md`
- `lifepunch-weapon-platform.mdc` â†’ `instructions/lifepunch-weapon-platform.instructions.md`
- `lifepunch-website-organization.mdc` â†’ `instructions/lifepunch-website-organization.instructions.md`

## Manual grep (still useful)

```powershell
rg -n "your topic" .cursor\rules
Get-ChildItem .cursor\rules\*.mdc
```