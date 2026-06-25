# DECISION-0002 — Hub owns mining

> **Status:** Active  
> **Date:** 2026-06-25  
> **Proposed by:** Design Architect  
> **Approved by:** Bloodwave  
> **Supersedes:** —  
> **Related:** DECISION-0001 · `BITCOIN_CONTROLLER_PATTERN.md`

## Decision

The **Hub** owns mining **operation policy and ledger state** (dispatch policy, wallet, linked rack registry, mining on/off permission, controller-tier upgrades). **GPU Racks** own mining **execution** and rack-local buffers.

## Reason

One brain for the farm. Terminal and racks mirror or execute — they do not own the ledger.

## Alternatives considered

- Terminal as mining authority — **rejected** (see DECISION-0005)
- Per-rack independent mining without hub — **rejected**

## Systems affected

`bitcoinhub` · `BITCOIN_DATA_FLOW.md` · hub RPC / wallet
