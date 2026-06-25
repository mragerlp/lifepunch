# DECISION-0005 — Terminal never mines

> **Status:** Active  
> **Date:** 2026-06-25  
> **Proposed by:** Design Architect  
> **Approved by:** Bloodwave  
> **Supersedes:** —  
> **Related:** DECISION-0002

## Decision

**HASHD Terminal** is presentation and commands only. Closing the HASHD Terminal does not alter the Hub's mining permission or the Rack's execution state. Rack accrual continues while Hub power and permission remain valid.

## Reason

Real control-room fantasy — operator walks away, farm keeps working. Terminal is not a second controller.

## Alternatives considered

- Terminal as mining authority — **rejected** (duplicates hub)
- Mining stops when CRT closes — **rejected**

## Systems affected

`hashdterminal` · `BITCOIN_DATA_FLOW.md` · terminal command layer
