# LifePunch addons — agent pointer

Codex / Claude / Cursor agents opened on `lifepunchaddons` must ground at the **monorepo root**:

`C:\Users\jared\Projects\lifepunch`

Read in order:

1. `../AGENTS.md` / `../CLAUDE.md`
2. `../lifepunch/docs/START_HERE_AGENTS.md`
3. Active workstream + relevant skills under `../.agents/skills/` and `../.claude/skills/`

MCP for s&box: parent `../.mcp.json` (Claude) and `%USERPROFILE%\.codex\config.toml` (Codex).  
Editor-first: bridge + chomnr need `sbox-dev` running (`Start-SboxDxrpEditor.ps1`).
