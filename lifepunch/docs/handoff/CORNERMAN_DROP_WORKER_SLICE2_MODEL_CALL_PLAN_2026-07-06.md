# Cornerman Drop Worker — Slice 2 Model-Call Plan (Revised, 2026-07-06)

**Status:** PLAN ONLY — no implementation performed. Revision 1 after Codex REVISE verdict.
**Repo:** `mragerlp/lifepunch` · branch `develop` · Slice 1 baseline commit `57308c0`
**Supersedes:** the Slice 2 sections of the original chat-only plan (Rev 0).
**Read with:** `lifepunch/docs/CORNERMAN_HEADLESS_DROP_WORKER.md` (Slice 1 runbook) ·
`lifepunch/docs/handoff/CORNERMAN_HEADLESS_DROP_WORKER_OPUS_V2_PLAN_2026-07-06.md` (Slice 1 design) ·
`lifepunch/docs/handoff/CORNERMAN_DROP_WORKER_SLICE1_TEST_REPORT_2026-07-06.md` (Slice 1 evidence)

Slice 2 adds a **local LM Studio / Qwen model endpoint call** and real `report.md`
generation to the headless drop worker on Green. Endpoint:
`http://127.0.0.1:1234/v1/chat/completions`; availability probe:
`http://127.0.0.1:1234/v1/models`. Localhost only — no cloud fallback, no network
egress beyond localhost, enforced in code.

---

## 1. Default model-call policy

**The worker's default behavior remains Slice 1 dry-run, permanently.**
A model call is a doubly-explicit event requiring independent operator intent AND
packet intent:

```text
model call happens  <=>  worker invoked with -EnableModelCall
                         AND packet has modelCall.enabled == true
                         AND packet does NOT have constraints.noModelCall == true
```

Canonical decision table:

| `-EnableModelCall` | `modelCall.enabled` | `constraints.noModelCall` | Result |
|---|---|---|---|
| no  | absent / false | any          | **dry-run** (Slice 1 behavior, zero HTTP) |
| no  | true           | any          | **fail closed** — `model-call-requested-but-worker-not-enabled` (zero HTTP) |
| yes | absent / false | any          | **dry-run** (zero HTTP) |
| yes | true           | true         | **fail closed** — packet self-contradiction (requests a model call while forbidding it; zero HTTP) |
| yes | true           | false/absent | model call permitted — **only after every pre-HTTP gate passes** |

Rules:

- **Missing `modelCall` object means dry-run.** Legacy Slice 1 packets (no
  `modelCall` field at all) are treated as `modelCall.enabled: false` and always
  dry-run. **No model call can ever happen by accident from a legacy packet.**
- `modelCall.enabled: true` **without** `-EnableModelCall` fails closed with
  failure stage `model-call-requested-but-worker-not-enabled` and **zero HTTP
  requests**.
- `-EnableModelCall` **without** packet opt-in (`modelCall.enabled: true`) runs
  dry-run validation only, with **zero HTTP requests**. The switch alone never
  causes a model call — it only unlocks the capability for packets that request it.
- `constraints.noModelCall: true` prevents model calls. Standing alone it forces
  dry-run; combined with `modelCall.enabled: true` it fails closed (malformed
  intent must be surfaced, not guessed at) — zero HTTP either way.
- There is no config file or environment default that flips model calls on
  machine-wide. Every invocation chooses explicitly via the switch.

## 2. Packet / schema additions

Schema v2 reserves a new **optional** `modelCall` object:

```json
"modelCall": {
  "enabled": false,
  "requiredModel": null,
  "allowFallback": false
}
```

Field rules:

- `enabled` (bool) — **defaults false**. Absent object is equivalent to
  `enabled: false`.
- `requiredModel` (string | null, default null) — when set, this exact model id
  must appear in the `/v1/models` probe result AND must agree with the model the
  routeTag resolves to via config. Disagreement fails closed as
  `model-route-conflict`. When null, the model is resolved purely from routeTag.
- `allowFallback` (bool) — **defaults false, and Slice 2 ignores `true`**.
  Slice 2 never falls back to a different model under any setting; a missing
  requested/routed model always fails closed as `model-unavailable`. The field is
  reserved so a future slice can implement controlled fallback behind its own
  Bloodwave GO. In Slice 2, `allowFallback: true` produces a warning in the report
  ("fallback not implemented; ignored") and changes nothing.
- A malformed `modelCall` object (e.g. non-bool `enabled`) is a schema failure —
  fail closed before anything else.

Route tag → model intent (resolved via a new `model-endpoints.json` config,
deployed live to `C:\lifepunch\cornerman\config\model-endpoints.json`):

| routeTag | Intent | Proposed default (loaded on Green at plan time) |
|---|---|---|
| `GREEN DEEP REQUIRED` | deep reasoning | `qwen/qwen3.6-27b` (owner-confirmed) |
| `GREEN CODE REQUIRED` | coder | `qwen2.5-coder-32b-instruct` |
| `AUTO OK` | not routed to Green | **rejected** (AUTO OK belongs on Red) |

`meta.json` records both sides of the opt-in on every run:

```json
"workerModelCallEnabled": true,
"packetModelCallRequested": true
```

so every artifact shows exactly why a run did or did not call the model. Full
model metadata (endpoint, modelId, probe result, call timings, prompt/output
sizes, finishReason, temperature, maxTokens, packed input files) is added to
`meta.json` on model runs; `failureStage` identifies where any failure occurred.

## 3. Format-aware output validation

The generic "must contain at least one markdown heading" rule from Rev 0 is
**withdrawn**. Output validity is dispatched on `deliverable.format`:

| Format | Validity requirements | Section handling |
|---|---|---|
| `markdown` | non-empty text · no blocked scan hits (dxrp-official) | if `deliverable.expectedSections` is present: best-effort heading/label matching. Missing sections are **warnings** in report + meta (`missingExpectedSections`), not failures. **All** sections missing (zero matches) fails as `model-invalid` (output ignored the contract entirely) |
| `json` | full model output body parses as valid JSON **after optional outer code-fence stripping** · no blocked scan hits before writing | expected-keys checking reserved for a later slice; Slice 2 validates parse only |
| `text` | non-empty (non-whitespace) text · no blocked scan hits | none |
| anything else | **fail closed before the model call** — unsupported format is caught at schema validation (gate 2). Defense-in-depth: the output validator also fails closed if dispatch ever receives an unknown format | — |

Ordering per format: scan (dxrp-official) → format validity → section
best-effort. The no-IP/trailer scan always runs on the **raw** output before any
write, regardless of format.

**Non-markdown deliverables must never be rejected for lacking markdown
headings.** A valid JSON or text deliverable passes without any heading check.

## 4. Pre-HTTP hard gates

**Canonical statement: no HTTP request — not even the `/v1/models` probe — may
happen until ALL gates below pass.** The probe is the first network action of
any kind, and it is only reached after the full gate chain is green.

Gate order (fail closed at the first failure):

1. Task JSON parse
2. Schema validation (required fields, enums, id format, `modelCall` object
   shape, `deliverable.format` supported)
3. repoProfile validation + profile registry lookup
4. Clone path exists / is a git repo
5. Remote identity matches registry `expectedRemotes`
6. Dirty-tree check (untracked = dirty)
7. Focus/profile agreement
8. Branch/base law (+ dxrp-official pr-review `reviewBranch` rule)
9. Input path safety (repo-relative, no `..`, profile forbid-prefixes, existence)
10. Glob expansion (rooted in clone, no escape) + combined maxBytes / context-cap
    check over readFiles + expanded readGlobs
11. forbiddenScope gate
12. Output-type gate (`allowedOutputTypes`)
13. routeTag / model-route validation (routeTag maps to a configured model
    intent; `AUTO OK` rejected; `requiredModel` vs route agreement)
14. Localhost-only endpoint validation (config URL must start with
    `http://127.0.0.1:` or `http://localhost:` — anything else fails closed)
15. modelCall opt-in policy (full decision table from Section 1)
16. dxrp-official pre-call no-IP / AI-trailer scan over: instruction ·
    contextNotes · every readFiles content · every expanded readGlobs content

Any gate failure produces, with **zero HTTP performed**:

- `error.md` (with the specific `failureStage`)
- failed `meta.json` (`status: failed`)
- failed ack (`ok:false`)
- history `<id>.fail.json`
- lock released in `finally`

Gates 1–12 and 16 are the proven Slice 1 chain (extended by glob expansion in
gate 10, which also closes the Slice 1 "readGlobs not scanned" honesty gap);
gates 13–15 are new Slice 2 gates inserted **before** any network activity.

Post-call failure stages (after gates pass and HTTP occurs):
`endpoint-down` · `model-unavailable` · `model-route-conflict` ·
`model-timeout` · `model-empty` · `model-invalid` · `output-scan-blocked`.
On `output-scan-blocked` (dxrp-official), the generated text is discarded and
never written anywhere including logs — only blocked token names are recorded.

## 5. Updated test plan

Mock-endpoint harness (PowerShell `HttpListener` on a scratch `127.0.0.1` port
with a **request counter**) — every case asserts the observed HTTP request count
explicitly. Zero-HTTP is a tested invariant, not a convention.

Zero-HTTP tests (mock listener must observe **0 requests**):

| # | Case | Expected result |
|---|---|---|
| 1 | Legacy Slice 1 packet (no `modelCall` object), switch off | dry-run OK |
| 2 | `constraints.noModelCall: true` (switch on and off) | dry-run OK; contradiction case fails closed |
| 3 | `modelCall.enabled: true`, worker started **without** `-EnableModelCall` | fail `model-call-requested-but-worker-not-enabled` |
| 4 | `-EnableModelCall` on, packet lacks `modelCall.enabled: true` | dry-run OK |
| 5 | Invalid packet JSON (switch on) | fail closed |
| 6 | Unknown repoProfile (switch on) | fail closed |
| 7 | Wrong clone remotes (switch on) | fail closed |
| 8 | Dirty clone (switch on) | fail closed |
| 9 | Forbidden dxrp-official input path (switch on) | fail closed |
| 10 | Unsupported `deliverable.format` (e.g. `html`) | fail closed at schema |
| 11 | `requiredModel` conflicts with routeTag config | fail `model-route-conflict` |

Model-call and output-validation tests (switch on + packet opt-in):

| # | Case | Expected result |
|---|---|---|
| 12 | All gates pass, markdown deliverable, happy path | probe + 1 call; real report with model meta |
| 13 | `format: json` deliverable — valid JSON output **without any markdown headings** | **passes** (markdown rule not applied) |
| 14 | `format: json` — model returns non-JSON prose | fail `model-invalid` |
| 15 | `format: text` — model returns whitespace-only | fail `model-empty` |
| 16 | dxrp-official — mock output contains a blocked token (e.g. `LifePunch`) | fail `output-scan-blocked`; error.md carries token name only; no report written |
| 17 | readGlobs expand, get packed AND scanned; expansion over maxBytes fails pre-call (0 HTTP); glob escaping clone root rejected (0 HTTP) | per case |
| 18 | Markdown `expectedSections` partially missing | warnings, still OK; all sections missing fails `model-invalid` |
| 19 | Endpoint down / probe non-200 | fail `endpoint-down` |
| 20 | Routed model absent from probe (incl. `allowFallback: true`) | fail `model-unavailable` (fallback ignored; probe only) |
| 21 | Mock delays past timeout | fail `model-timeout` |
| 22 | Non-localhost endpoint URL in config | fail closed (0 HTTP) |

Live smoke (manual, only after the mock matrix is fully green): one real
`lifepunch-private` markdown audit packet run with `-EnableModelCall` +
`modelCall.enabled: true` against actual LM Studio on Green — the first real
generated report.

Evidence artifact:
`lifepunch/docs/handoff/CORNERMAN_DROP_WORKER_SLICE2_TEST_REPORT_<date>.md` —
Slice 1 matrix format plus an explicit "HTTP request count" column.

## 6. Scope lock

Slice 2 still **excludes** all of the following (each requires its own future
slice + separate Bloodwave GO):

- scheduler install (Windows Task Scheduler)
- Red drop helper (`Push-CornermanTaskPacket.ps1`)
- candidate-patch mode (`mode: candidate-patch` remains rejected)
- patch creation or application
- commit / push / PR automation of any kind (worker never mutates git)
- source / product file edits — no `lifepunchaddons/**`, no `lifepunchdxrp/**`,
  no `dxrp-public` edits
- model cloud fallback / any network egress beyond localhost
- runtime / editor proof claims (Cornerman's eyes remain covered)

Files planned to change at implementation GO (for Codex reference):
`CornermanDropWorker.Lib.ps1` (model functions + glob expansion),
`Invoke-CornermanDropWorker.ps1` (`-EnableModelCall` + gates 13–15 + model flow),
`cornerman-model-endpoints.example.json` (new config template),
`cornerman-task-packet.schema.json` (`modelCall` object),
`CORNERMAN_HEADLESS_DROP_WORKER.md` (runbook Slice 2 section),
Slice 2 test report artifact. Nothing else.

Recommended commit message after implementation and review:
`feat(cornerman): add local model report generation`

---

*Plan artifact only. No worker script, schema JSON, or config was modified. No
model call was made. No commit or push was performed.*
