# CORNERMAN CONSULT DOCTRINE — the local models as active limbs of the CVL
Canon home: lifepunch/docs/cvl/CORNERMAN_CONSULT_DOCTRINE.md
v1 · 2026-07-13 · Ratified by Bloodwave

## 0. What changed

CORNERMAN stops being an overnight-only seat. Its models become
ACTIVE CONSULTING TOOLS available to the implementer seats (Opus/Red
and Codex) DURING implementation — a third, independent set of code
eyes the twins can query mid-task to expand their understanding of
the environment they are working in. This is a repeated process, not
a one-off: consult, verify, implement, and each pass deepens every
seat's grasp of the LIFEPUNCH codebase.

## 1. The endpoint (the whole integration)

LM Studio on CORNERMAN serves an OpenAI-compatible API:
  Base URL:  http://10.10.10.2:1234/v1   (direct link, VENGEANCE-side)
  Chat:      POST /v1/chat/completions
  Models:    routed per-request by the "model" field
  Reference: C:\lifepunch\cornerman\config\model-endpoints.json
No new software. No Ollama, no WebUI — the API is the integration.

RESIDENCY SENSOR (landing-time amendment, ratified by Bloodwave
2026-07-13 on Red's first-consult finding): GET /api/v0/models
'state' field is the truth of what can answer; /v1/models lists
availability only. Consult tooling preflights residency before any
chat call.

## 2. The models and when to use which

- DAILY (qwen3.6-35b-a3b, MoE): general reasoning, doctrine reads,
  research packets, censuses, audits — the packet workhorse.
- CODER (qwen2.5-coder-32b-instruct): code consults — second
  opinions on diffs, pattern checks, subsystem explanations, review
  passes on drafted implementations.
- MODEL-BY-PURPOSE RULE (idle packets): CORNERMAN runs lengthy
  unattended packets under WHICHEVER model fits the packet's focus —
  daily for research/audit/doctrine lanes, coder for code-census /
  code-review / implementation-study lanes. The dispatch names the
  intended model; loading/swapping models is a BLOODWAVE CONSOLE ACT
  (never seat-initiated).
- VRAM CONCURRENCY: daily (~22GB) + coder (~23GB) ≈ 45 of 48GB.
  Both can sit loaded for mixed duty, but context headroom is thin —
  if generation degrades or thrashes, drop to one model and route
  the other duty to a swap window.

## 3. The consult lane (twins -> coder, during implementation)

- Helper: lifepunch/scripts/ask-cornerman.ps1 (in-repo tooling). Takes a
  prompt, optional file paths whose contents are inlined, and an
  optional -Model override (default: coder). Posts to the endpoint,
  prints the reply. Any seat with a shell may call it mid-task.
- INTENDED USES: "review this diff before I commit", "explain what
  this subsystem does", "what pattern does the fork use for X",
  "sanity-check this approach against the file I'm pasting".
- The consult is CHEAP and LOCAL: no tokens spent, no code egress
  off the LAN (cloud-egress rule 8 of CONSOLE_PLUGINS_DOCTRINE does
  not apply — CORNERMAN is inside the wall).

## 4. The laws that bind the lane

C-A  LEADS-GRADE ONLY. Local-model output is ADVICE, the same class
     as Green packets. It never becomes a sensor by itself.
C-B  CITE-VERIFICATION LAW. Local models fabricate file:line cites.
     EVERY cite a local model produces is machine-verified against
     the live tree before it is used, quoted, or acted on. An
     unverified local cite in a seat report is a defect.
C-C  NO SEAT DRIVER. The local models consult; they never hold a
     seat, DRIVE, tree hands, or task ownership. Consult output
     lands through the querying seat's hands and judgment.
C-D  SECRETS STAY OUT. No credentials, tokens, portal player data,
     or .env contents in any consult prompt (C-1/C-2 of KEY_LEDGER
     apply to prompts too).
C-E  ATTRIBUTION. Work influenced by a consult is still the seat's
     work under normal commit discipline. Consults are process, not
     authorship — no model trailers, ever.

## 5. Green's expanded role (supersedes "overnight-only" readings)

Green/CORNERMAN now serves three duties, coexisting:
  (a) PACKET DUTY (unchanged): lengthy unattended packets, model
      chosen by packet focus per §2.
  (b) CONSULT DUTY (new): standing availability of the coder model
      to the implementer twins during active work, via §3.
  (c) REVIEW DUTY (per Editor Access Law v2 §3, "Cornerman's place"): third-sense
      back-checks on code past Opus/Codex when Fable routes one.
Packet discipline (STEP 0, R7 freshness, OUTBOX returns, ADVICE
headers, rule 18 lane paths) is UNCHANGED for (a) and (c). Duty (b)
is request/response and files nothing — the querying seat's report
carries what mattered.

## 6. Why (Bloodwave's intent, recorded)

The twins prepping and enhancing each other, plus a local third
sense, is stronger than any fixed circle: perception, navigation,
and quality compound with every pass through another set of eyes.
Use the tools we have to our advantage, make it a repeated process,
and match the complexity of the code space we are in.
