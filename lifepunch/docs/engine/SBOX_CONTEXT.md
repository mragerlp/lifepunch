# SBOX_CONTEXT.md — s&box Engine Ground Truth for AI Agents
Canon home: lifepunch/docs/engine/SBOX_CONTEXT.md
(tracked graduation of the sbox-engine-truth skill —
ONE source of truth; the skill file points at this doc)
v1 — drafted by Fable #4 (fable\SBOX_CONTEXT_FABLE_DRAFT_2026-07-13.md),
landed by Red 2026-07-13. Landed VERBATIM except §6, whose factual
premise Red machine-REFUTED against the tree before landing — the
correction is marked in place, per the authored-correction clause of
the draft itself ("Red may correct any line he can machine-refute
against the pinned fork, citing file:line").

## 0. WHY THIS FILE EXISTS
AI training data is saturated with LEGACY Source / Garry's Mod /
old-s&box APIs. Modern s&box is a different engine. Every agent
reads this file at task start (skills-first rule, CLAUDE.md) and
verifies any uncertain API against the PINNED FORK SOURCE on disk
(lifepunchdxrp/ — the entire engine-side codebase is greppable),
citing file:line. Never write an API call from memory alone.

## 1. ARCHITECTURE — SCENE SYSTEM, NOT ENTITIES
- s&box uses a Unity-like GameObject/Component model.
  Components inherit `Component` (or project bases like
  `SingletonComponent<T>`, DXRP's `BaseEntity`). There is NO
  legacy `Entity` class, NO `Library` attribute, NO old Source
  entity IO.
- GameObjects own transforms/hierarchy; behavior lives in
  components; discovery via `GetComponent<T>()` /
  `Components.Get<T>()` idioms — copy the exact idiom used in the
  neighboring shipped code, not a remembered one.
- Prefabs (.prefab) are authored assets; *.prefab_c / *.vmdl_c /
  *.vmat_c / *.sound_c are COMPILED artifacts the editor
  regenerates. Never hand-edit _c files; binary _c churn in git
  status is editor noise (0 source lines) — but staging pipelines
  must ship regenerated _c or assets 404 at runtime (proven:
  server-hum.sound_c miss).

## 2. NETWORKING
- Replication via attributes: `[Sync]` on properties; host
  authority via `[Rpc.Host]` methods; caller identity via
  `Rpc.CallerId`. Host-side loops gate with
  `if ( !Networking.IsHost ) return;`.
- NO `#if CLIENT` / `#if SERVER` preprocessor split. That is
  legacy. (Project exception: `LIFEPUNCH_LOCAL` dev harness blocks
  exist and are explicitly dev-only.)
- A property WITHOUT [Sync] is client-local. This has bitten us:
  weapon spread had no [Sync] and shot traces were client-
  authored (Packet M DQ-25). When a value must be authoritative,
  prove the sync path, don't assume it.
- Gamemode config syncs to clients — SECRETS NEVER go in T2/T3
  config; server convars only (Client-sync secrets law).

## 3. MONEY & STATE (project law, engine-adjacent)
- Money amounts are uint; every subtraction clamps at zero; loud
  ERROR sentinel on impossible states.
- Async money flows: DEBIT-BEFORE-AWAIT; on failure restore ONLY
  the debited amount ADDITIVELY (never overwrite a later balance).
  Known-correct exemplar: LpBitcoinHubEntity debit-restore path
  (do not "fix" it).
- Every issuance/mint/movement of value carries a sensor
  (LP_*_SENSOR Log.Info convention at minimum). Silent issuance is
  a defect class (J4-F3).
- SnapshotSystem restores on EVERY boot (no crash gate). World
  value objects must be snapshot-excluded or they mint on restart.

## 4. CONFIG LAYERS (check BEFORE writing code)
T1 = server engine config (portal, restart-activated).
T2 = gamemode config (portal Save + Sync; client-visible).
T3 = addon shipped defaults (+ portal configOverride per entity).
Live-tunable knobs: portal Store atomic key
`<addon>:config:settings`, read RAW via
`ServerApiClient.GetStore` — NEVER `GetStoreJson` (bare catch ->
default(T): a silent $0 economy). Per-field positive validation +
legacy fallback. Shipped exemplar: LpBitcoinPortalEconomySync.

## 5. RAZOR / SCSS (s&box UI)
- Razor gotchas (all field-proven): never two adjacent `@()`
  expressions in one attribute (transpiler emits `(A)(B)` and the
  class collapses); `@code` blocks stay ASCII; when a cascade of
  errors appears, hunt the FIRST generated-file error, not the
  windowed tail.
- s&box SCSS is NOT web SCSS: no `@media`; `inline-flex` invalid;
  the parser reads words out of COMMENTS (a commented selector can
  still break you).
- SCSS-only `url()` images may not enter the client download
  dependency graph (open defect lane — btc.png). Don't rely on
  SCSS-referenced assets shipping.
- Currency UI follows LAW 17 (Currency Identity): colored SIGN is
  the invariant (฿ bitcoin-orange = BTC, $ green = cash); green
  never on power/status/BTC-adjacent controls.

## 6. BUILD & PROOF REALITY

**THE ONLY PROVEN COMPILE SENSOR IS THE EDITOR.** Agents cannot
compile-prove statically today. Static work therefore ships as
UNVERIFIED-until-editor-gate; the sensors are a compile/hotload log
POSTDATING the write plus a positive code-string ID (Sensor Law /
FRESH standard).

**RED'S CORRECTION (2026-07-13, machine-verified).** The draft of
this file asserted "no .sln/.csproj in the fork." **That is false, and
it is corrected here rather than frozen into canon.** The tree carries
a full .NET project surface:

    lifepunchdxrp/game/rp.slnx                 (fork solution, .slnx format)
    lifepunchdxrp/game/Code/rp.csproj          (net10.0, Microsoft.NET.Sdk.Razor)
    lifepunchaddons/addons.slnx
    lifepunchaddons/Code/addons.csproj
    lifepunch/scripts/Install-VengeanceIdeStack.ps1:145
        -> literally documents: "dotnet build Code\addons.csproj (from addons root)"

What red\0015 §7 actually established is narrower than the draft's
wording: **no instrument, gate, or CI in this repo compiles through
`dotnet`, and no seat has ever produced a dotnet-build sensor.** That
is a statement about our *instruments*, not about the *artifacts* —
and the two were conflated.

**THE EXPERIMENT WAS RUN (2026-07-13, Bloodwave-authorized). ANSWER:
`dotnet build` IS NOT A COMPILE SENSOR — AND ITS OUTPUT IS A TRAP.**
The editor-only law is now PROVEN, with a named mechanism, rather than
assumed.

    dotnet build lifepunchaddons/Code/addons.csproj   (SDK 10.0.300, clean tree)
    -> exit 1 · 42 errors first pass, 82 on --no-incremental · 7 warnings
    -> EVERY error is CS0246 "type or namespace not found". ZERO are real defects.
       Unresolved: IReadOnlyList<> (24) · Player (22) · Obsolete/ObsoleteAttribute (24)
                   · Func<,> (4) · IEnumerable<>, List<>, HealthComponent (2 each)

**READ THAT LIST BEFORE TRUSTING THE OUTPUT.** `IReadOnlyList`, `List`,
`Func`, and `ObsoleteAttribute` are **BCL types**. A compiler that cannot
find `ObsoleteAttribute` is not judging our code — it is missing its
reference set. Two gaps, both machine-confirmed:

1. **NO IMPLICIT/GLOBAL USINGS.** `addons.csproj` declares
   `<Using Include="Sandbox.Internal.GlobalGameNamespace" Static="true" />`
   but **no `<ImplicitUsings>`**, and LP source files declare **zero
   `using` directives of their own** (verified: `LpBitcoinIdent.cs` has
   none). The s&box compiler injects that global set; `dotnet` does not.
   So every `System` / `System.Collections.Generic` type vanishes.
2. **NO GAMEMODE REFERENCE.** `Player` and `HealthComponent` are DXRP
   gamemode types (`lifepunchdxrp/game/Code/Player/Player.*.cs`, built by
   `rp.csproj`). `addons.csproj` references the Sandbox engine DLLs and
   `Base Library.csproj`, but **never the gamemode assembly** — which the
   editor has in scope when it compiles an addon.

**THE DANGER IS THE FALSE POSITIVE, NOT THE FAILURE.** This build reports
**82 errors against shipped, working, in-production code.** A seat that
runs it and reads the output naively files 82 phantom defects and sends
someone hunting ghosts. **If you run `dotnet build` here, its errors are
NOT evidence.** Do not cite them, do not "fix" them.

**THE LEAD (open, unclaimed).** The gap is narrow and now named: implicit
usings + a gamemode reference. Closing it would hand this project the
static compile sensor every static seat lacks. But `addons.csproj` is
**editor-GENERATED** (its `OutputPath` points into
`D:/Steam/.../sbox/.vs/output/`), so a hand-edit is overwritten on the
next editor regeneration — any real fix must survive that, which makes it
a slice, not a one-liner. **Until that slice lands and shows a positive
code-string ID, the EDITOR remains the only compile sensor.**

- Editor sessions are governed by EDITOR_LAUNCH_LAW (launch-set
  rule: never sync a lone addon) and the editor gate skill. One
  editor driver at a time (Red).
- Publish pipeline: stager with shared-infra ownership map +
  dependency-CLOSURE GATE in prepare-publish (strips comments/
  string literals to kill false positives). Two-bundle publishes
  need the sibling-snapshot pattern (stager purges upload root).

## 7. GOLDEN EXAMPLES
docs/engine/examples/ holds compile-PROVEN components only.
Rule: an example earns "golden" status ONLY after an editor
compile + runtime sensor postdating its last edit. Prefer
CURATING small shipped components from the tree over authoring
fresh ones. Agents: base syntax, naming, and idioms of new
components exactly on these files.
Current status: ExampleNetworkedMachine.cs is a CANDIDATE
(authored, NOT compile-proven — see its header) until Red's first
editor gate stamps it.

## 8. WHEN UNCERTAIN
Grep the fork. Cite file:line. A claim without a sensor is a
claim. If the fork and this document disagree, the fork is right
and this document gets a correction PR.
