---
name: sbox-api-truth
description: Offline Sandbox.* API presence/obsolete check using the vendored api-index.json. Use BEFORE inventing or recalling any Sandbox type/member when the live editor is unavailable, or as a cheap pre-check before describe_type. Does NOT replace live reflection — when the editor/bridge is up, describe_type / search_types win. Extends (does not replace) sbox-engine-truth.
---

# sbox-api-truth — offline API inventory (portable)

> **WIRED 2026-07-23** — live under `.agents/skills` + `.claude/skills` (lifepunch + lp-editor-ui). Index may be stale vs engine; live `describe_type` wins.
> Index source: `lifepunchsboxvscodeextension/data/api-index.json`  
> Index meta: schema `sbox-api-index-v1`, `generatedAt=2026-04-30`, **1873** types (~8.9 MB).

## Law (authority order)

1. **Live editor reflection** (`describe_type` / `search_types` / `get_method_signature`) — when bridge/MCP is up  
2. **This index** — offline / editor-down / quick negative check  
3. **Official docs snapshot** (`lifepunch/docs/reference/sbox-llms/…`)  
4. Memory — never

If the index and live reflection disagree, **reflection wins** and the index is stale (file a refresh task).

## When to use

- About to write `using Sandbox…` / call a type or member you have not verified in-tree  
- Editor is down, or seat has no cavelux→7269 route  
- Flagging obsolete APIs (`isObsolete` / `obsoleteMessage` on types/members)

## How (light path — do not load the whole JSON)

From the skill folder (or the staged path until wired):

```text
references/api-index.json
```

1. Grep / `rg` / `Select-String` for the **type or member name** (prefer `fullName` like `Sandbox.Component`).  
2. If **absent** → treat as UNKNOWN; do not invent; use live reflection or flag for Bloodwave.  
3. If present with `isObsolete: true` → do not use; report `obsoleteMessage`.  
4. Optional companion files:  
   - `references/sbox-csharp.tmLanguage.json` — attribute/type whitelist (Property, Sync, ConCmd, …)  
   - `references/sbox-addon.schema.json` — Org/Ident/.addon shape (from Facepunch vscode fork)

## Explicit non-goals

- Do not splice VS Code diagnostic *behavior* — only the data.  
- Do not trust snippets from the extension wholesale (house Sync/Rpc laws override).  
- Do not claim “index = current SDK” — refresh after major engine drops (see `S&BOX_UPDATE_EVALUATION.md`).

## Pair with

- `sbox-engine-truth` — in-tree idiom + house NEVER/ALWAYS  
- `sbox-api` / `sbox-build-feature` (staged from lifepunchsboxclaude) — brain + screenshot workflow  
- `lifepunch-editor-gate` — bridgeVersion NON-NULL / roundTripOk ritual
