# Law 2's enforcement surface is BACKEND DATA — Packet E disposition (E4 · E5 · E2b)

**Status:** RECORD of a ruling and its sensor readings (2026-07-10). Write-once.
**Ruled by:** Bloodwave (via Fable), on Red's reading of the pinned DXRP tree.
**Disposes:** Packet E's `E4` (FLAGGED), `E5` (riders), `E2b` (pallets).
**Source record:** `cornerman-outbox/PACKET_E_FINDINGS_2026-07-09.md` — Green's record,
byte-verbatim, unmodified. Its verdicts are corrected here, never edited there.

**Sensor provenance.** Red read the **pinned blob** at `dxrp-public` commit `b9d6068` —
Green's pin — not Red's worktree, which sits at `e6d3026`. `BaseEntity.cs` was **not** among
Packet E's twelve byte-verified input paths, so Green never saw it. The file happens to be
identical at both commits; that was checked, not assumed.

---

## E4 — the doctrine claim is neither enforced nor contradicted in code

**Economy Doctrine Law 2:** *"Drug entities are explicitly hack-immune."*

**`BaseEntity` does not carry a HealthComponent by default.** It carries a nullable one, and
creates it only on a backend flag:

```
game/Code/Entity/BaseEntity.cs:33    public HealthComponent? HealthComponent { get; set; }   // "(If we have one)"
game/Code/Entity/BaseEntity.cs:137   if ( !entity.HealthEnabled ) { HealthComponent.Destroy(); HealthComponent = null; return; }
```

`HealthEnabled` is **an API DTO field**, served by dxrp.net:

```
game/Code/Api/Dtos/GameModeEntityDto.cs:10    public bool HealthEnabled { get; init; }
game/Code/Api/Dtos/GameModeEntityDto.cs:11    public float HealthAmount { get; init; }
```

**THE RULING.** Law 2's enforcement surface is **backend data, not code.** No code guard
exists, and none can close the question: whether a drug entity is damageable is decided per
entity by a value this repository does not own. A grep can never resolve it — not because the
search was insufficient, but because the answer is not in the tree.

**Green's FLAGGED verdict STANDS. Green's reasoning is CORRECTED.**

Green inferred: *"`BaseEntity` … typically has `HealthComponent`,"* therefore `DryRackEntity`
and `RollingTableEntity` *"likely have health, making them vulnerable."* That inference runs
backwards. There is **no default health**. The correct statement is that these entities have
health **if and only if the backend says so**, and the repository is silent either way.

The verdict was right. The road to it was wrong. Recording both is the point — a right answer
reached by a broken sensor is a false green that has not gone off yet.

## E4 CLOSURE SENSOR (owed to the Chemist-lane gate)

The only sensor that reads the thing under test is a **live damage probe**:

> Apply damage to a `DryRackEntity` and a `RollingTableEntity` in-editor, and **assert zero
> damage taken.**

A host-side code assertion cannot close this — the claim is about a value the host receives,
not a value the host computes. *A declaration is not an observation*, and a DTO field is a
declaration until something hits the entity.

## E5 — the capital leg's numbers are backend DTO fields, and the tree holds only multipliers

**Printer purchase cost is `GameModeMarketItemDto.Cost` — a backend DTO field.**

```
game/Code/Api/Dtos/GameModeMarketItemDto.cs:9    public int Cost { get; init; }
```

It is looked up by market entry, not stored on the entity — `GameModeEntityDto` carries no price
field of any kind. The printer's only entity-side config knobs are `PrinterDecayEnabled` and
`PrinterDestroyAfterDisconnectTime = 3600f` (`game/Code/Config/GameConfig.Systems.cs:94-95`).

```csharp
// game/Code/GameManager.cs:292-294
var marketItem = GameModeMarketItems.All
    .FirstOrDefault( x => x.Type == GameModeMarketItemType.Entity && x.ReferenceId == entity.Id );
var basePrice = (float)Math.Max( 0, (int)MathF.Ceiling( (marketItem?.Cost ?? 0) * EntityPriceMultiplier ) );
```

Applied again at `GameManager.cs:364` and in the market UI at
`game/Code/UI/Menus/TabMenu/Sections/MarketTabMenuSection.razor:189,219`.

The **only in-tree number** is the multiplier's default, `EntityPriceMultiplier = 1f`
(`game/Code/GameManager.cs:27`), transiently scaled by `*= 0.75f` during a flash sale
(`game/Code/System/Event/Events/FlashSaleEvent.cs:22`).

### Observation, not a ruling — a missing market item prices the entity at ZERO

`marketItem?.Cost ?? 0` (`GameManager.cs:294`). If the backend's market data does not list an
entity, its base price computes to **0** and the purchase is free. This is **upstream DXRP
behavior**, not a LIFEPUNCH defect, and it is recorded here only because the capital leg cannot
be reasoned about without it: the price floor is not a code constant, it is *whether the row
exists*. Not ruled on. Not a bug report. Named so a later session does not rediscover it.

**Per-job salary: no table exists in-tree.** `GameModeJobDto.Salary`
(`game/Code/Api/Dtos/GameModeJobDto.cs:14`, `int`, `init`) is served by the API and consumed at
`game/Code/System/RP/SalaryPaymentSystem.cs:50`:

```csharp
var baseSalary = (uint)(player.Job.Salary * GameManager.Instance.SalaryMultiplier * (isAfk ? 0.5 : 1));
```

The one hardcoded salary anywhere in `game/Code` is `GameModeJobs.cs:141 → Salary = 0`, whose
context (`Guid.NewGuid()`, `models/citizen/citizen.vmdl`, `Health = 100`) shows it is a
**synthesized fallback job**, not a job table.

**This is the answer, not a failed search.** It agrees with `CVL_AGENT_ONBOARDING.md` §12:
jobs and economy are backend-driven from dxrp.net via `game/Code/Api/`.

**E5 closure:** the capital leg closes by a **live purchase-UI read**, filed as a
chair-session micro-item.

## E2b — PALLETS: a pin-bounded negative, parked

Packet E reported *"no pallet entity exists in the pinned tree."* That is a statement about
**commit `b9d6068`**, not about DXRP. A pallet may exist upstream past that pin.

- Red's trees, 2026-07-10: `lifepunchdxrp` HEAD `e6d3026`; `C:\Users\jared\Projects\dxrp-public`
  HEAD `0ee91dd`. Both still contain `b9d6068`.
- **PARKED:** the pallet question reopens **only** on a `dxrp-public` re-pin past `b9d6068`
  (`Ensure-DxrpUpstreamCurrent.ps1 -Sync -UpdatePin -SyncSteam`). Any coke/meth
  "can bricks ride the same container" design inherits this blocker.

**The general form, worth carrying:** *a negative result inherits the boundary of the tree it
was read in.* "No X exists" is never a fact about the project; it is a fact about a commit. Say
which one, or the finding will be re-read later as universal.

## Cross-references

- `cornerman-outbox/PACKET_E_FINDINGS_2026-07-09.md` — Green's record. Verbatim, unmodified.
- `ECONOMY_DOCTRINE.md` — Law 2, whose enforcement surface this record locates.
- `PROOF_ENVIRONMENT_DOCTRINE.md` — the Sensor Law. *A declaration is not an observation.*
- `NONOWNER_CLIENT_READ_SURFACE_2026-07-10.md` — the same shape one layer up: authority is
  safe, truth is unverified until something reads it from the other side.
