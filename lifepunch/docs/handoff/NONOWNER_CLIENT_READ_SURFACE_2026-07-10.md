# NON-OWNER CLIENT-READ SURFACE — truth vs authority

- **Status:** CANON — decision record, ruled 2026-07-10.
- **Ruled by:** Bloodwave (authored via Fable). Transcribed by Red, grounded against source.
- **Companions:** `GATE_ADVANCEDRACK_SYNC_TWO_CLIENT.md` (the gate that measures it) ·
  `UPGRADE_ECONOMY_DOCTRINE.md` (Terminal defense tracks) · `ECONOMY_DOCTRINE.md`
- **Feeds:** the Terminal-defense design pass, when those tracks get numbers.

---

## THE RULING — ownership is DXRP's; the client-read surface is ours

Bitcoin entities spawn **owned**, by Steam ID, via the DXRP market. **`lpbitcoin` does not wire
ownership.** `CanManageHub(callerId)`, `LinkedHubId`, and `AssignedSlotToken` all *presume* an
ownership relation that DXRP already established. Authority is host-side, and it is safe.

**The open question is not authority. It is TRUTH.**

Host-assigned properties that do not replicate produce a **truth bug**: two players look at the
same rack and disagree about what it is. Authority asks *may I act on this?* — and the answer is
already correct. Truth asks *what am I even looking at?* — and that answer is currently
unverified from any screen but the owner's.

## The known case — `AdvancedRack`

`lifepunchaddons/Code/Addons/lifepunch/bitcoinmining/LpBitcoinRackEntity.cs:32`

```csharp
[Property] public bool AdvancedRack { get; set; }
```

Every sibling on that entity carries `[Property, ReadOnly] [Sync( SyncFlags.FromHost )]` —
`LinkedHubId` (:39), `AssignedSlotToken` (:45), `IsMining` (:46), `BitcoinAmount` (:47),
`ClockGhz` (:48), `CoreCount` (:49), `MiningProgress` (:50). `AdvancedRack` carries neither
`ReadOnly` nor `Sync`. A host-assigned advanced rack therefore renders on a **non-owner** client
with the wrong `DisplayName` and the wrong `YieldMultiplier`.

This is exactly what the two-client gate's **C3** (`runtime-assigned rack — host == client`)
measures, and it must be read **from the non-owner's screen specifically**. A host-side assertion
cannot see this bug: the bug *is* host/client disagreement, so a host-only sensor measures the
wrong side by definition.

## The sharp instance — `AccessPinHash`

Does a non-owner — a **raider** — receive `AccessPinHash`?

`lifepunchaddons/Code/Addons/lifepunch/lpbitcoin/bitcoinhub/code/components/LpBitcoinHubEntity.cs:39`

```csharp
[Property, ReadOnly] [Sync( SyncFlags.FromHost )] public int AccessPinHash { get; set; }
```

**The declaration already answers half of it.** `SyncFlags.FromHost` replicates host→**all**
clients; it is not owner-scoped. So the expected answer is **yes — the raider's client holds the
hash today.** What the code cannot tell us is whether that value actually lands and is readable
on a second, non-owning client in a live two-client session. *A declaration is not an observation.*
The two-client sitting remains the only sensor that closes it, and it should now be run to
**confirm** a positive, not to discover an unknown.

**Assessment if it replicates (it almost certainly does):** it is a *hash*, not the PIN. The
physical-destruction bypass is **intended** — see the design frame below. The question to answer
is not "is this a leak" but "does a raider holding the hash change any tradeoff we intend."

## PIN DESIGN FRAME — the PIN is not a lock, it is a tradeoff surface

Brute force is **always available and always costly**:

> *You can break the system, but that destroys what's inside.*

This is the **Hacker's Dilemma at the entity level**, and it is why Intrusion Detection and
Command Authentication are **tiers, not booleans**. A boolean lock has one question — open or
shut. A tradeoff surface has a price, and the price is what the defender is actually buying.

`UPGRADE_ECONOMY_DOCTRINE.md:144` states this ruling's authority in one line:

> **Command Authentication** — loot limit: a cracked terminal at T5 still cannot `cash out` or
> `unlink` without a second factor. *Firewall stops the door; Auth limits the haul.*

A cracked terminal still cannot cash out or unlink. That is the sentence this whole record exists
to protect. It is why holding the hash is not, by itself, a defeat — and why the defense tracks
are graduated rather than binary.

## SCOPE — two passes, one sitting

They share a session and nothing else. Do not let one contaminate the other.

| | **The gate** | **The recon** |
|---|---|---|
| Question | Does `AdvancedRack` replicate? | What does a non-owner *see*? |
| Shape | Specific. C1–C4. | Exploratory. |
| Surface | one property | chips, tier labels, yields, PIN state |
| Output | **a verdict** — pass/fail, and nothing commits until C3 and C4 pass | **findings** — and the second question: *should they see it?* |
| Feeds | the `[Sync]` fix | the Terminal-defense design pass |

The gate has a verdict. The recon has no verdict and must not be given one — it feeds a design
pass that has not happened yet. Recording "the non-owner sees X" is the deliverable; ruling on
whether X is correct is not.

---

## Cross-references

- `GATE_ADVANCEDRACK_SYNC_TWO_CLIENT.md` — the two-client gate. C3 is the truth-bug measurement;
  read it from the non-owner's screen.
- `UPGRADE_ECONOMY_DOCTRINE.md` — Terminal defense tracks (Endpoint Firewall · Command
  Authentication · Intrusion Detection).
- `PROOF_ENVIRONMENT_DOCTRINE.md` — the Sensor Law. *A declaration is not an observation* is the
  same law that says a compile log is not a positive code-string ID.
