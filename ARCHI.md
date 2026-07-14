# ARCHI.md - LIFEPUNCH architecture memory (TRIP)

> **SUBORDINATE TO `CLAUDE.md`.** This file is the TRIP-workflow architecture snapshot -
> a fast technical orientation read, not law. On any conflict, `CLAUDE.md` and
> `lifepunch/docs/cvl/` win and this file is the defect. Maintained via `TRIP-compact`;
> updated by the release step of each TRIP cycle. Adopted per
> `lifepunch/docs/cvl/TRIP_ADOPTION_2026-07-14.md`.

## What this repo is

LIFEPUNCH: a monorepo for an s&box (Source 2) game product built on the DXRP platform,
plus its website, portal, legal, docs, and multi-agent development law (CVL).

## Top-level layout

| Path | What it is |
|------|-----------|
| `CLAUDE.md` | Canon of record - roles, laws, hard rules. First read, always. |
| `AGENTS.md` | Pointer to CLAUDE.md for non-Claude harnesses. |
| `lifepunch/` | Docs, scripts, website, portal, legal. |
| `lifepunch/docs/cvl/` | The governing law (seats, transport, editor access, keys). |
| `lifepunch/docs/handoff/` | CANON: write-once rulings, STOP-GOs, briefs. |
| `handoff/` (root) | SCRATCH: untracked proof artifacts. Nothing reads it. |
| `lifepunchaddons/` | The in-repo addon/product code (s&box C#, Razor, SCSS). |
| `lifepunchdxrp/` | Untracked nested private DXRP mirror for server testing. |
| `.claude/skills/` + `.agents/skills/` | Paired tracked skill surfaces (byte-updated in the same PR). |

## Build & runtime truth

- The s&box editor compiles a **hand-synced copy** under `D:\Steam\...\dxrp\game`, NOT
  this repo. Sync: `lifepunch/scripts/Sync-LifePunchAddonsToDxrp.ps1` (`-WhatIf` first).
- Editor is reachable over three MCP surfaces (see `docs/cvl/TRIPLE_MCP_STACK_2026-07-13.md`);
  exactly one board-named seat holds DRIVE.
- Local consult muscle: CORNERMAN workstation, LM Studio at `10.10.10.2:1234`
  (`lifepunch/scripts/ask-cornerman.ps1`; daytime coder = qwen2.5-coder-32b-instruct).

## Key domains

- **Economy**: Law A/B, faucet audit, TOCTOU debit-restore - see `lifepunch-economy` skill
  and `lifepunch/docs/DXRP_PLATFORM_DOCTRINE.md` (Donor Law §9, $LP Currency Law §9b).
- **Config**: three-tier T1 server engine > T2 gamemode > T3 addon defaults; secrets only
  in server convars - see `lifepunch-config` skill.
- **UI**: Razor + SCSS under DXRP parity rules - see `lifepunch-razor-ui` skill.

## Git lane

`develop -> main`, PRs only, Bloodwave merges. Never commit on `develop`/`main`.
Author `mragerlp <mragerlp@gmail.com>`, zero AI attribution anywhere.
