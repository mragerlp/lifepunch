# Hacker Job — terminal platform brief

**Issued:** 2026-06-11 · **Owner priority:** Hacker Job depth (after brief gun test)  
**Canon:** `addons/docs/HACKER_JOB_SPEC.md` · `branding/lifepunch-ops/THEME.md`

---

## Vision

A **real** retro terminal experience — not a menu with green paint. Players boot **`cornerman.exe`**, run commands, solve **time-boxed puzzles**, scan live players, and steal **wallet cash only** (never bank). Same **terminal engine** later forks to:

| Skin | Addon / use | Prompt | Accent |
|------|-------------|--------|--------|
| **Hacker** (ship first) | `hackerjob` | `cornerman@rig:~$` | `#00FF7F` |
| **Miner** (done Phase 1.5) | `bitcoinmining` | `cornerman@rig:~$` | `#00FF7F` |
| **Government** (later) | lifepunchnet / future addon | `lifepunch@lifepunch.net:~$` | `#00D4FF` |

BitcoinMiningAddon proved the shell (boot, scroll, upgrade panel). Hacker Job goes **deeper**: multi-screen flow, puzzles, scan target picker, server-validated payouts.

---

## Player flow (target)

```text
USE terminal → boot sequence → cornerman.exe
  → scan          (list live SteamIDs / names — server list)
  → select target (click row or `hack <id>`)
  → puzzle        (coding mini-game, timer visible)
  → result        (wallet transfer or fail + cooldown)
```

**Hard rules:** wallet-only · server validates puzzle + money · Hacker job gate · audit log every transfer.

---

## Puzzle lane (Cornerman designs, Red implements)

Examples to catalog (pick 3–5 for MVP):

| Type | Player does | Validates on server |
|------|-------------|---------------------|
| Syntax fix | Complete broken one-liner (`if (wallet > 0) { drain(); }`) | hash of normalized answer |
| Pipe grep | `scan \| grep "Bloodwave"` style command | expected token match |
| Decode | base64/hex blob → correct passphrase | string compare |
| Buffer | fill N-char key before timer expires | timing + answer id |
| Sequence | type boot commands in order from help | state machine |

Puzzles are **fiction** — no real code execution on server. Client shows terminal; server holds puzzle id + solution hash + expiry.

---

## Assets

| Piece | Path / status |
|-------|----------------|
| Design spec | `HACKER_JOB_SPEC.md` (DRAFT) |
| Code scaffold | `Code/Addons/lifepunch/hackerjob/HackerJob.cs` |
| Authoring UI | `Downloads/newaddons/hackerterminal/source/bitcointerminal/` |
| CRT mesh | Same family as `bitcoin-terminal` (own vmdl per addon) |
| Portal package | `dxrpAddonId` in `addons.json` — foundation-only |

---

## Green deliverables

See `CORNERMAN_HACKER_JOB_TERMINAL_TASK.md` — flow wireframe, puzzle catalog, `cornerman.exe` command tree, gov DB prep scaffold.

**Red** ships Razor + entity after owner tweaks Green distill.

---

## Related

- `BITCOINMINING_UX_SPEC.md` §6 Relation to Hacker Job
- `branding/lifepunch-ops/outfits/lifepunchnet/TIER-SPEC.md` — government `ls` fiction
- `AUDIT_LOG_REFERENCE.md` — hack transfers
