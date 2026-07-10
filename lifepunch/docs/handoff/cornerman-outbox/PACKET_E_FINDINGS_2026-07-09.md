# PACKET E FINDINGS: Chemist-lane Grounding
**Date:** 2026-07-09
**Author:** Headless Audit Worker (Green)
**Attestation:**
- DXRP Inputs read from `dxrp-public` commit `b9d6068` (branch `develop`).
- Canon `ECONOMY_DOCTRINE.md` read from `lifepunch` monorepo pin `987ac89`.
- Verification: Red confirmed byte-identity of all 12 DXRP input paths between `b9d6068` and feature branch `e6d3026`.

---

## E1 - Weed Pipeline, End-to-End

**Stage Graph:**
The vanilla implementation follows a strict linear pipeline:
`PlanterEntity` (Growth) -> `WeedHarvestEntity` (Wet) -> `DryRackEntity` (Drying) -> `WeedHarvestEntity` (Dried) -> `RollingTableEntity` (Processing) -> `WeedHarvestEntity` (Joint/Packed).

**Stage 1: PlanterEntity (Growth)**
- **Source:** `lifepunchdxrp/game/Code/Entity/Entities/PlanterEntity.cs`
- **State Machine:**
    - States: `Soiled` (bool), `Watered` (bool), `HasLight` (bool), `Stage` (int), `GrowthProgress` (float).
    - Transitions: `Stage` increments when `GrowthProgress` reaches 1.0. `GrowthProgress` is clamped between 0 and 1 based on `TimeSince` vs `Plant.TimeToGrow`.
- **Timers:**
    - Growth Duration: Configured in `PlantResource.TimeToGrow` (Asset property).
    - Light Check Interval: 30s if `HasLight` is true, 5s if false (`PlanterEntity.cs:63-64`).
- **Player Action:**
    - `OnTriggerEnter` handles soil/water/seed insertion via `ContainerEntity` checks (`PlanterEntity.cs:135-165`).
    - Harvest via `Press` event (`PlanterEntity.cs:85-95`), which calls `OnHarvestHost`.
- **Wiremod/MetaWire:** None exposed. The entity relies on `ContainerEntity` interaction for inputs.
- **Yield/Quality Field:** `PlantResource.Harvest` (GameObject reference) is cloned and spawned. No quality variable is carried; the output is a raw `WeedHarvestEntity`.

**Stage 2: DryRackEntity (Drying)**
- **Source:** `lifepunchdxrp/game/Code/Entity/Entities/Drug/DryRackEntity.cs`
- **State Machine:**
    - States: `SlotDryTimes` (List<TimeUntil?>), `OccupiedSlots` (int).
    - Transitions: Slot moves from `null` (empty) to `TimeUntil` (drying) to `null` (ready) when timer expires.
- **Timers:**
    - Dry Duration: `DryRackEntity.DryTime` (Property, default 140s).
- **Player Action:**
    - `OnTriggerEnter` accepts `WeedHarvestEntity` if `Dried` is false. Destroys input, sets slot timer.
    - No manual player action to advance; purely time-based.
- **Wiremod/MetaWire:** None exposed.
- **Yield/Quality Field:** The `WeedHarvestEntity` is destroyed and replaced by a new `DriedWeedGameObject` clone. The `Dried` flag is set to true on the new entity (`DryRackEntity.cs:65`). Quality is not tracked; the output is a "Dried" weed entity.

**Stage 3: RollingTableEntity (Processing)**
- **Source:** `lifepunchdxrp/game/Code/Entity/Entities/Drug/RollingTableEntity.cs`
- **State Machine:**
    - States: `UnprocessedWeed` (uint), `ProcessedWeed` (uint), `AutoProcessTime` (TimeUntil?).
    - Transitions: `UnprocessedWeed` decrements, `ProcessedWeed` increments on process.
- **Timers:**
    - Auto-Process Interval: `AutoProcessInterval` (const 30s).
    - Auto-Process Cost: `AutoProcessCost` (const 2000).
- **Player Action:**
    - `OnTriggerEnter` accepts `WeedHarvestEntity` if `Dried` is true and `UnprocessedWeed < 6`.
    - `OnProcess` RPC advances state (manual plucking).
    - `OnMakeProduct` RPC consumes `ProcessedWeed` to spawn final product (Joint or Packed).
    - `OnStartAutoProcessBuy` RPC initiates auto-plucking (costs money).
- **Wiremod/MetaWire:** None exposed.
- **Yield/Quality Field:** `ProcessedWeed` count determines output. `OnMakeProduct` spawns `JointGameObject` (count 3) or `PackedGameObject` (count 1) based on `isJoint` bool. No quality metric is passed to the final item.

**Stage 4: WeedHarvestEntity (Final Product)**
- **Source:** `lifepunchdxrp/game/Code/Entity/Entities/Drug/WeedHarvestEntity.cs`
- **State:** `Dried` (bool).
- **Yield/Quality Field:** The entity itself is the yield. It has no internal quality stat. The `Dried` flag distinguishes it from wet weed.

**Missed Stages/Discrepancies:**
- The pipeline lacks a "Curing" stage. The canon mentions "DryRack" but the code only has one drying phase.
- No quality degradation or improvement mechanics exist in the vanilla code.
- No wiremod hooks are exposed for any stage.

---

## E2 - DrugDrop Internals

**Source:** `lifepunchdxrp/game/Code/World/DrugDrop.cs`

**Price-Fluctuation Mechanism:**
- **Formula:** `PaymentPerDrop = Random.Next(DrugDropMinPrice, DrugDropMaxPrice)`.
- **Tick/Interval:** Controlled by `Config.Current.Game.DrugDropPriceChangeCycle`.
- **RNG Source:** `Sandbox.Game.Random.Next` (`DrugDrop.cs:36`).
- **Clamp:** None; relies on config min/max.
- **Anchor Verification:** The Red pre-read is **CONFIRMED**. The price is **NOT** fixed at spawn. It re-rolls every `DrugDropPriceChangeCycle` seconds (`DrugDrop.cs:33-37`). The `DisplayText` (`DrugDrop.cs:105`) reflects the *current* price, not the spawn price.

**Sell Flow:**
1. Player places `weed_brick` tagged GameObject into trigger (`OnTriggerEnter`, `DrugDrop.cs:73-85`).
2. `CountdownContext` is attached to the object (`BroadcastToggleCountdownContext`, `DrugDrop.cs:96-103`).
3. After `DrugDropSellTime` expires, `QueueBundlePayout` is called (`DrugDrop.cs:48-55`).
4. Bundle is destroyed (`bundle.Root.Destroy()`).
5. Payout is queued in `_pendingPayoutTotal` and `_pendingSoldCounts` (`DrugDrop.cs:52-54`).
6. `OnSecondlyUpdate` checks `_nextPayout` timer. If elapsed, `DropMoneyHost` is called with the total pending amount (`DrugDrop.cs:59-61`).
7. Player stats (`weed-sold`) are incremented (`DrugDrop.cs:63-65`).

**Cooldowns:**
- **Per-Drop:** No explicit cooldown on the drop entity itself, but the `CountdownContext` enforces `DrugDropSellTime`.
- **Per-Player:** No explicit cooldown on the player selling.
- **Global:** No global cooldown.

**Config-vs-Hardcoded Split:**
- **Config:** `DrugDropMinPrice`, `DrugDropMaxPrice`, `DrugDropPriceChangeCycle`, `DrugDropSellTime` (`Config.Current.Game.*`).
- **Hardcoded:** None in `DrugDrop.cs`.

---

## E2b - PALLETS

**Finding:** No pallet entity exists in the pinned tree (`dxrp-public` commit `b9d6068`). The input files do not contain any pallet-related code.
**Verdict:** Skip. No generic container found. Coke/meth bricks cannot ride the same container free based on this tree.

---

## E3 - Coke/meth Extension Map

**Inherit-vs-Fork Decision Surface:**
- `DrugDrop` is a `Component`, not an `Entity`. It is not subclassed by any drug-specific drop in the vanilla code.
- `WeedHarvestEntity` is a specific entity type. To support coke/meth, a new entity type (e.g., `CokeDropEntity`) would likely need to be created or `DrugDrop` would need to be refactored to accept a generic "brick" interface.
- **Window-Gated Drop Needs:**
    1.  **Timed Open Windows:** `DrugDrop.cs` has no window logic. A variant would need to inject a `IsOpen` check into `OnTriggerEnter` and `OnSecondlyUpdate`.
    2.  **Scheduled Spawn:** `DrugDrop` is a static map entity. A window-gated variant would need a spawner component or a timer to enable/disable the trigger.
    3.  **Moving Vehicle Host:** `DrugDrop` uses `WorldPosition` for payouts. A moving host would require tracking the vehicle's position and handling detachment/reattachment logic, which is absent.

**Code Seam:**
- The primary seam is `OnTriggerEnter` (`DrugDrop.cs:67`) and `OnSecondlyUpdate` (`DrugDrop.cs:29`).
- A window-gated variant would plug into `OnTriggerEnter` to reject items outside windows and `OnSecondlyUpdate` to manage the window state.

---

## E4 - Hack-Immunity Ground Truth

**Verdict:** **FLAGGED**

**Analysis:**
- **Economy Doctrine Law 2:** "Drug entities are explicitly hack-immune."
- **Code Verification:**
    - `PlanterEntity`: Inherits `BaseEntity`. No explicit hack-immunity tag or guard. It has `IAreaDamageReceiver`? No. It has `IContextualObject`, `IPressable`. It can be damaged by `AreaDamage` if it inherits from `BaseEntity` which typically has `HealthComponent`.
    - `DryRackEntity`: Inherits `BaseEntity`. No explicit immunity.
    - `RollingTableEntity`: Inherits `BaseEntity`. No explicit immunity.
    - `WeedHarvestEntity`: Inherits `BaseEntity`. No explicit immunity.
    - `DrugDrop`: Inherits `Component`. It is not an `Entity`, so it cannot be damaged by `AreaDamage` directly. However, it can be destroyed by `GameObject.Destroy()`.
- **Theft/Interaction Surface:**
    - `PlanterEntity` has `OnTriggerEnter` for `ContainerEntity`. It does not have a `TakeDamage` override that blocks damage. If `BaseEntity` has a `HealthComponent`, it can be damaged.
    - `DrugDrop` has no `IAreaDamageReceiver`. It is immune to area damage.
    - **Explicit Guard:** None of the drug entities have a tag like `Constants.HackImmuneTag` or a guard in `TakeDamage` that returns early.
- **Conclusion:** The doctrine claim is **FLAGGED** as unenforced. The code relies on the *absence* of damage hooks on `DrugDrop` (Component) and potentially the lack of damageable health on `PlanterEntity` (if it doesn't have a health component, which is not visible in the snippet but `BaseEntity` usually does). However, `DryRackEntity` and `RollingTableEntity` are `BaseEntity` instances and likely have health, making them vulnerable to damage/looting unless `BaseEntity`'s damage logic is globally restricted for these types, which is not evident.

---

## E5 - Riders (Close the Capital Leg)

**Printer Spawn Cost:**
- **Source:** `lifepunchdxrp/game/Code/Entity/Entities/PrinterEntity.cs`
- **Finding:** The `PrinterEntity` does not have a hardcoded spawn cost in the entity code. The cost is likely defined in the `PrinterEntityConfig` asset or a global config not present in this file. The `PrinterEntityConfig` class has `BaseMoneyGeneration`, `BalanceCapacity`, `GenerationInterval`, `ColorHex`. No spawn cost property is visible.
- **Note:** The task asks for spawn/purchase cost. This is not in the provided file.

**Salary Table:**
- **Source:** `lifepunchdxrp/game/Code/System/RP/SalaryPaymentSystem.cs`
- **Per-Job Salary Values:** `player.Job.Salary` (from `GameManager.Instance.SalaryMultiplier`). The actual values are in `player.Job`, which is not in the input files.
- **Pay Interval:** `PayCycleSeconds` (Property, default 300s).
- **Configuration:** `Config.Current.Game.SalaryPaymentEnabled` enables the system. `Config.Current.Game.GovernanceTaxEnabled` and `Governance.Current.TaxRate` affect the net pay.

**Outbox SHA:** `PACKET_E_FINDINGS_2026-07-09.md`