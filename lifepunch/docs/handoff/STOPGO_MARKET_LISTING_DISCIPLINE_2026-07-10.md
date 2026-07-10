# Market-listing discipline — unlisted means unpriced, by contract

**Status:** RECORD of a ruling (2026-07-10). Write-once.
**Ruled by:** Bloodwave (via Fable).
**Occasion:** Red surfaced `marketItem?.Cost ?? 0` while disposing Packet E's E5. It was
recorded there as an observation, explicitly not a ruling. This is the ruling.
**Companions:** `STOPGO_LAW2_ENFORCEMENT_SURFACE_2026-07-10.md` (where the observation was
made and cited) · `ECONOMY_DOCTRINE.md`

---

## THE OBSERVATION

```csharp
// lifepunchdxrp/game/Code/GameManager.cs:294   (dxrp-public @ b9d6068)
var basePrice = (float)Math.Max( 0, (int)MathF.Ceiling( (marketItem?.Cost ?? 0) * EntityPriceMultiplier ) );
```

If the backend's market data does not list an entity, its base price computes to **0** and the
purchase is free.

## THE RULING

**This is an intentional upstream contract, not a bug.**

Pricing lives in the portal / JSON config. **Unlisted means unpriced.** The `?? 0` is the
contract's expression, not an oversight in it.

**No Dimmer report. No upstream issue. Nothing to fix in `dxrp-public`.**

## THE DISCIPLINE IT CREATES FOR US

Because the contract is real, the failure mode it permits is also real — on **our** servers,
with **our** entities:

> **Any entity LIFEPUNCH ships with a purchase path asserts its market listing at gate time.**
> **Unlisted = spawns free on our servers.**

This is a **gate obligation**, not a code guard. The price floor is not a constant we can read
in a diff; it is *whether the row exists* in data we serve. So the assertion belongs where data
and code meet — in the gate — and it belongs there **before** the entity ships, not after
someone notices a free printer.

The shape is by now familiar, and it is the third time tonight it has appeared: **the value is
backend data, so only a live sensor can close it.** `HealthEnabled` decides whether a drug
entity can be damaged. `GameModeMarketItemDto.Cost` decides whether our entity can be bought.
Neither answer is in the tree. A gate that reads only the tree will pass a broken thing.

## Cross-references

- `STOPGO_LAW2_ENFORCEMENT_SURFACE_2026-07-10.md` — the disposition that surfaced this, with
  the full price path: `GameModeMarketItemDto.Cost` (`Api/Dtos/GameModeMarketItemDto.cs:9`)
  applied at `GameManager.cs:294` and `:364`, and in the market UI at
  `MarketTabMenuSection.razor:189,219`.
- `PROOF_ENVIRONMENT_DOCTRINE.md` — the Sensor Law. When no sensor reads the thing under test,
  build one; here the thing under test is a row in a table the repository cannot see.
