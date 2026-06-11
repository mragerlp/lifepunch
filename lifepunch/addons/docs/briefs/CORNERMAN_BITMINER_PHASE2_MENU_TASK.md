# Cornerman task — Bitminer Phase 2 module menu (draft only)

**Lane:** Tier-3 UI prep · **Red ships** after Opus review on VENGEANCE  
**Issued:** 2026-06-11  
**Status:** **Draft complete** (2026-06-10) — wireframe + amber tokens + outbox  
**Prerequisite:** Phase 1 HASHD rig control shipped (`BitminerTerminal.razor`)

---

## Goal

Draft the **module menu** shell for `menu` command — wireframes + SCSS tokens — **amber HASHD** (`#f0a500`), reusing **ops-console rail/module patterns** from `HACKER_OPS_CONSOLE_SPEC.md`.

**You do NOT:** change economy RPCs, dual-build seams, or `BitminerEntity.cs`.

---

## Read first

| Doc | Section |
|-----|---------|
| `BITMINER_UX_SPEC.md` | §3b modules, §3a boot |
| `HACKER_OPS_CONSOLE_SPEC.md` | Rail + module platform (amber palette swap) |
| `BitminerTerminal.razor` | Phase 1 — RPCs to wire |
| `BITMINER_PROTECTION_CHECKLIST.md` | About tab = LIFEPUNCH™ only |

---

## Deliverables

| # | Artifact | Path | Status |
|---|----------|------|--------|
| 1 | Wireframe | `briefs/BITMINER_PHASE2_WIREFRAME.md` | ✅ |
| 2 | SCSS tokens | `briefs/BITMINER_PHASE2_TOKENS.scss` | ✅ (amber, not green) |
| 3 | `menu` / `_activeModule` spec | In wireframe § view mode | ✅ |
| 4 | RAG outbox | `C:\lifepunch\cornerman\outbox\BITMINER_PHASE2_MENU.md` | ✅ |
| 5 | Protection audit | `briefs/BITMINER_PROTECTION_CHECKLIST.md` | ✅ |
| 6 | UX spec drift fix | `BITMINER_UX_SPEC.md` | ✅ |

---

## RPC wiring summary (Red)

| Module | RPC |
|--------|-----|
| Dashboard START/STOP | `SetMiningState(bool)` |
| Wallet SELL ALL | `RequestSellBitcoin()` |
| Upgrades INSTALL | `RequestUpgrade(Cpu \| Cores)` |
| Log | `HandleCommand` unchanged |
| About | static copy only |

---

## Commit (local)

```text
docs(bitcoinmining): Phase 2 module wireframe, amber tokens, protection audit
```

Ping Red: patch handoff → implement modules in `BitminerTerminal.razor`; fix protection checklist items.
