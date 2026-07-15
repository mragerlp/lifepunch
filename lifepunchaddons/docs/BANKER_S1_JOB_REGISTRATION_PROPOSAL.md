# LIFEPUNCH™ Banker S1 — job registration proposal

**Issue:** #138 · **Status:** proposal-only · **Surface:** portal T2 `jobs[]` plus addon-manifest draft  
**Activation:** none. These rows are not portal-ready until Bloodwave rules the open choices and the
portal generates real identifiers. This slice adds no gameplay, economy, Razor, or SCSS code.

## 1. Existing canon: two readings, no decision

### `BANKER_JOB_SPEC.md` reading

- The June draft describes three possible roles: Banker/Teller, Bank Manager, and Bank Security.
- Exact job names and DXRP registration are explicitly open.
- Its vault is described as a separate host ledger with scheduled interest.
- It treats vault breaches as a future signed escalation and keeps hacker theft wallet-only.

### `INSTITUTIONS_DOCTRINE.md` reading

- Ratified canon describes exactly an elected Banker with attached Bank Guard slots.
- The vault is a voluntary at-risk investment fund, explicitly separate from the always-safe DXRP
  portal bank balance.
- Yield must come from real production and fees, never scheduled minting.
- Cash-pile robbery and crypto-vault hacking are designed counterplay.

### Reconciliation boundary

For S1, both readings support a Banker job and a security role. They conflict on role count, vault
identity, yield, and raid posture. This proposal therefore carries only **Banker** and **Bank Guard**
T2 row shapes from the ratified doctrine, while preserving the older three-role reading as an open
alternative. It decides no economy or heist behavior.

## 2. T2 job-row proposal

Shape source: `lifepunch/docs/server-setup/config/GAMEMODE_CONFIG_T2_2026-07-12.json` `jobs[]`.
Mayor is the election exemplar: both `voteRequired` and `electionRequired` are `true`.

The following is deliberately non-importable until every `<...>` placeholder is replaced in the
portal. Salaries, slot caps, play-time gates, colors, clothes, equipment, and identifiers are T2
configuration choices—not hardcoded addon defaults.

### Banker

```json
{
  "id": "<PORTAL_GENERATED_BANKER_JOB_UUID>",
  "gameModeJobGroupId": "<BANK_JOB_GROUP_UUID_OR_RULED_EXISTING_GROUP_UUID>",
  "prerequisiteJobId": null,
  "name": "LIFEPUNCH™ Banker",
  "description": "Elected steward of the Bank and its at-risk investment fund.",
  "color": "<T2_TUNABLE:BANKER_JOB_COLOR>",
  "model": "<T2_TUNABLE:BANKER_MODEL>",
  "clothes": "<T2_TUNABLE:BANKER_CLOTHES_ARRAY>",
  "jobTags": ["Banker"],
  "salary": "<T2_TUNABLE:BANKER_SALARY>",
  "includeDefaultEquipment": true,
  "gameModeEquipmentIds": "<T2_TUNABLE:BANKER_EQUIPMENT_UUID_ARRAY>",
  "health": "<T2_TUNABLE:BANKER_HEALTH>",
  "demoteOnRespawn": "<T2_TUNABLE:BANKER_DEMOTE_ON_RESPAWN>",
  "interaction": null,
  "selectable": true,
  "demotable": "<T2_TUNABLE:BANKER_DEMOTABLE>",
  "playTime": "<T2_TUNABLE:BANKER_PLAY_TIME_OR_NULL>",
  "maxCount": "<T2_TUNABLE:BANKER_MAX_COUNT>",
  "voteRequired": "<R5_OPTION:true_DOCTRINE_OR_false_NON_ELECTED>",
  "electionRequired": "<R5_OPTION:true_MAYOR_EXEMPLAR_OR_false_NON_ELECTED>"
}
```

Recommended doctrine-aligned variant, pending R5: `maxCount = 1`, `voteRequired = true`, and
`electionRequired = true`. Those values are not activated or treated as ruled by this document.

### Bank Guard

```json
{
  "id": "<PORTAL_GENERATED_BANK_GUARD_JOB_UUID>",
  "gameModeJobGroupId": "<BANK_JOB_GROUP_UUID_OR_RULED_EXISTING_GROUP_UUID>",
  "prerequisiteJobId": "<RULING:BANKER_JOB_UUID_OR_null>",
  "name": "LIFEPUNCH™ Bank Guard",
  "description": "Defends the Bank and its depositors; may never assist a Bank Raid.",
  "color": "<T2_TUNABLE:BANK_GUARD_JOB_COLOR>",
  "model": "<T2_TUNABLE:BANK_GUARD_MODEL>",
  "clothes": "<T2_TUNABLE:BANK_GUARD_CLOTHES_ARRAY>",
  "jobTags": ["BankGuard"],
  "salary": "<T2_TUNABLE:BANK_GUARD_SALARY>",
  "includeDefaultEquipment": true,
  "gameModeEquipmentIds": "<T2_TUNABLE:BANK_GUARD_EQUIPMENT_UUID_ARRAY>",
  "health": "<T2_TUNABLE:BANK_GUARD_HEALTH>",
  "demoteOnRespawn": "<T2_TUNABLE:BANK_GUARD_DEMOTE_ON_RESPAWN>",
  "interaction": null,
  "selectable": true,
  "demotable": true,
  "playTime": "<T2_TUNABLE:BANK_GUARD_PLAY_TIME_OR_NULL>",
  "maxCount": "<T2_TUNABLE:BANK_GUARD_MAX_COUNT>",
  "voteRequired": "<RULING:false_OR_SERVER_POLICY>",
  "electionRequired": false
}
```

The doctrine says Guard slots are “attached” to the Banker, but it does not define whether DXRP
should enforce that through `prerequisiteJobId`, a job tag, or later host-side vacancy behavior.
That field remains open.

## 3. Package naming proposal

Apply `PACKAGE_NAMING_STANDARD.md` without renaming tracked trees in S1:

- `packageSlug`: `lifepunchbanker` — public branch/listing identity.
- `packageFolder`: `lpbanker` — target parent for future consolidated package work.
- `sboxIdentifier`: `lifepunch.banker`.
- `repoIdent`: `bankerjob` — legacy monorepo and publish-mount identity until a separately approved
  Phase 4 migration.
- Display title: `LIFEPUNCH™ Banker Job for DXRP`.

The current asset intake under `Assets/addons/lifepunch/lpbanker/` is staging evidence, not approval
to silently change the published mount from `addons/lifepunch/bankerjob`. A later migration must
move and validate assets atomically. No new source files belong under the legacy
`Code/Addons/lifepunch/bankerjob/` tree.

The accompanying `addons.json` row is a **registration draft** using `ident: bankerjob` and empty
`contents`. It does not claim a portal addon UUID, compiled code, or publish readiness.

## 4. Deferred job-gated behavior stub

No C# stub ships in S1. A safe gate needs both portal-generated job UUIDs and a verified DXRP runtime
job API. Neither exists in this proposal, and using names or tags as authority would be a bypass.

When ruled, the first stub must:

1. Resolve the caller’s host-authoritative current job.
2. Compare against configured Banker/Bank Guard job UUIDs supplied through the approved config path.
3. Return an offline/unauthorized prompt only; perform no value movement.
4. Default closed when configuration or job state is unavailable.

## 5. Decisions deferred to Bloodwave

1. R2: DXRP bank extension or separate at-risk fund.
2. R3: whether yield exists and, if so, its production-backed contract.
3. R5: elected Banker via Mayor-style vote/election fields.
4. Older three-role draft or doctrine’s Banker + Bank Guard pair.
5. Bank Guard prerequisite enforcement and all T2 tunable values.
6. Phase 4 migration timing for `lpbanker` / `bankerjob` paths.
