# Cornerman task — Banker hub research (no C#, no s&box)

**Lane:** Cornerman Tier-3 prep · **Output:** short markdown in `bankerjob/docs/` only  
**You do NOT:** open s&box, edit C#, `git push`, or touch `main` addon code.

## Goal

Distill how a **bank vault hub** should plug into existing LifePunch systems so Red can greenlight
implementation after terminal playtests pass.

## Read first

1. `lifepunch/addons/docs/LIFEPUNCH_HUB_PATTERN.md`
2. `lifepunch/addons/docs/BANKER_JOB_SPEC.md`
3. `lifepunch/addons/Code/Addons/lifepunch/bankerjob/docs/BANK_VAULT_HUB.md`
4. `hackerjob/docs/HACKER_PHASE2_ECONOMY_PREP.md` (wallet-only theft)
5. `bitcoinmining/docs/BITCOINMINING_TERMINAL_DOCTRINE.md` (hub wallet)

## Deliverable

Create **`bankerjob/docs/CORNERMAN_HUB_RESEARCH.md`** (max ~2 pages):

1. **Hub comparison table** — bitcoin hub vs hacker rack vs proposed bank vault hub (5 rows).
2. **DXRP wallet/bank API** — what you find in `dxura/dxrp` develop (file paths + method names) for
   moving cash wallet ↔ bank; flag if native DXRP bank already exists.
3. **RP triangle bullets** — bank self-defense vs FBI cyber vs hacker wallet (3–5 bullets each).
4. **Risks** — interest inflation, afk farming, alert spam (honest).
5. **Recommend Phase 1 scope** — smallest shippable slice (one sentence).

## Done when

File exists in repo patch export; no playtest claims; no invented API names without a source path.
