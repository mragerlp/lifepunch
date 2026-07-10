# GATE SCRIPT — `[Sync]` on `AdvancedRack` (two clients)

**Prepared, not built.** Ruling 3: host-side assertion is not sufficient, because the bug
*is* host/client disagreement — a host-only gate measures the wrong side by definition.

`GATE HEADER: SCENE: fast (blank.scene) · IDENTITY: two`
Red drives the host. Bloodwave is the second client.

See `NONOWNER_CLIENT_READ_SURFACE_2026-07-10.md` for the truth-vs-authority framing and the
`AccessPinHash` reader question.

---

## The bug being gated

`LpBitcoinRackEntity.cs:32`

```csharp
[Property] public bool AdvancedRack { get; set; }        // no [Sync]
```

Every sibling carries `[Property, ReadOnly] [Sync( SyncFlags.FromHost )]`:
`LinkedHubId` (`:39`), `AssignedSlotToken` (`:45`), `IsMining` (`:46`), `BitcoinAmount` (`:47`),
`ClockGhz` (`:48`), `CoreCount` (`:49`), `MiningProgress` (`:50`), `ComputeTier` (`:55`).

`YieldMultiplier` and `DisplayName` are **derived** from `AdvancedRack`
(`LpBitcoinRackEntity.cs:58`, `:65`). So a client that does not receive `AdvancedRack`
computes the wrong yield and the wrong name.

> **Citations corrected 2026-07-10** against the source, before the gate ran. They were
> `:29`, `:56`, `:63`, `~:1622`, and the sibling list omitted `MiningProgress`. The frozen
> record `NONOWNER_CLIENT_READ_SURFACE_2026-07-10.md` already had `:32` right. A gate that
> points at the wrong line is a sensor pointed at the wrong world.

**Prefab-spawned racks may be fine** — `gpurack.prefab` serialises `AdvancedRack: false`,
`advancedgpurack.prefab` serialises `true`, and prefab data ships with the network spawn.
**Runtime host-assigned racks are the suspect path:**

- `LpBitcoinDevSpawn.SpawnRackPrefabInternal` — `rack.AdvancedRack = stacked;`
  (`LpBitcoinDevSpawn.cs:1628`), set *after* `ClonePrefabAt` and *before* `NetworkSpawnIfNeeded`.
- `LpBitcoinUi.CreatePreviewRack` — `rack.AdvancedRack = advanced;` (`LpBitcoinUi.cs:93`),
  host-local only, so invisible in preview.

**That distinction is the whole gate.** Do not assume the prefab path is safe; measure it.

---

## Order of operations (do not reorder)

The fix must be **proven to be needed** before it is applied, or the gate proves nothing.

### Phase A — reproduce the disagreement (BEFORE any code change)

1. Host (Red): open `blank.scene`, `start_play`, host a listen server.
2. Client (Bloodwave): join.
3. Host console:
   ```
   lp_bitcoin_clear_spawns
   lp_spawn_gpu_rack             # standard, prefab-borne value
   lp_spawn_advanced_gpu_rack    # advanced, prefab-borne value  (fixed 2026-07-09)
   ```
4. **Assert on BOTH sides** for each of the two racks:

   | property | host | client | must match |
   |---|---|---|---|
   | `AdvancedRack` | | | yes |
   | `DisplayName` | | | yes |
   | `YieldMultiplier` | | | yes |

   Sensor on the host: `get_runtime_property` on the rack GameObject.
   Sensor on the client: the world nameplate renders `DisplayName`; read it from the
   client's screen.

   **`DevRackReplicaProbe` is CONDITIONAL, not pre-built (ruled 2026-07-10).** Phase A runs on
   the nameplate as-is. **No speculative code before Phase A says it is needed.** If observation
   shows the nameplate cannot carry C3/C4, **STOP in-sitting** and propose the probe; Bloodwave
   GOs it live from the keyboard (the CVL Sync Law's live exception applies — the human at the
   keyboard is the sensor). It builds as **clearly-marked dev scaffolding**, on the
   `DevTrackRowProbe` pattern, and its retain-or-remove is ruled **after** the gate, never
   during it.

5. Now the suspect path — a rack whose flag is assigned at runtime, not by prefab:
   ```
   lp_bitcoin_clear_spawns
   lp_spawn_large_gpu_rack       # goes through SpawnStackedRack -> AdvancedRack = true at runtime
   ```
   Assert the same three properties on both sides.

6. **Record the result.** If host and client agree everywhere, the bug is *latent, not
   live*, and that is the finding — say so, and gate the fix as a hardening change rather
   than a bug fix. If they disagree, capture the exact divergence; that is the reproduction.

### Phase B — apply the fix

```csharp
[Property, ReadOnly] [Sync( SyncFlags.FromHost )] public bool AdvancedRack { get; set; }
```

**Verify `[ReadOnly]` does not break the two host-side assignment sites.** In s&box
`[ReadOnly]` governs the *inspector*, not code assignment — but confirm against the current
API with `describe_type` before wiring, per the API-drift rule. If it does block code
assignment, drop `[ReadOnly]` and keep `[Sync]`; the sibling pattern is a convention, the
sync is the requirement.

Sync to the editor tree, hotload, assert **FRESH**: compile log timestamp postdates the
write, plus a **positive code-string ID** — plant a `Log.Info` in the rack's spawn path
whose text exists only in this version, and observe it.

### Phase C — prove the fix

Repeat Phase A steps 3–5 verbatim. Every host/client pair must now match, including the
runtime-assigned rack from step 5.

Then one negative check: with the client still connected, spawn a rack on the host and
confirm the client's `DisplayName` updates **without a rejoin**. `SyncFlags.FromHost`
should push it; if the client only picks it up on join, the property is being seeded by
prefab data rather than replicated, and the gate has not actually proven replication.

---

## Acceptance

```
FRESH    compile log postdates write + positive code-string ID
A        pre-fix behaviour recorded (agree or disagree, stated plainly)
B        [Sync] applied; [ReadOnly] verified against current API, not memory
C1       prefab standard rack   — host == client (AdvancedRack, DisplayName, Yield)
C2       prefab advanced rack   — host == client
C3       runtime-assigned rack  — host == client   <- the actual bug
C4       live update, no rejoin — client repaints on host spawn
```

**Nothing commits until C3 and C4 pass.** A green on C1/C2 alone proves only that prefab
data ships, which was never in doubt.

---

## Then, and only then: PayoutTarget

`PayoutTarget ( PlayerBank | FundPile | CityFunds )` as `[Property, ReadOnly] + [Sync]`.

The attribute fix above establishes the pattern and proves the transport. Deposit sites that
PayoutTarget redirects are enumerated in `RECON_WALLET_TRANSFERS_2026-07-09.md` §6
(`LpBitcoinHubEntity.cs:1009`, `:1028`, `:1051`, `:1075/1076`).

Refuse-paths name the missing **INSTITUTION**, never the config. The institution check
belongs at the deposit sites, not in the UI — the UI renders the refusal, it does not decide
it.
