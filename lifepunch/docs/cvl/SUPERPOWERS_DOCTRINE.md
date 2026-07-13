# SUPERPOWERS DOCTRINE — the 14-skill discipline, mapped to CVL moments
Canon home: lifepunch/docs/cvl/SUPERPOWERS_DOCTRINE.md
v1 · 2026-07-13 · Ratified by Bloodwave

## 0. What this is

The superpowers plugin (obra/superpowers) installs 14 process skills
that gate HOW an agent works: design before code, plans before
execution, tests before implementation, debugging before fixes,
review before merge, EVIDENCE BEFORE CLAIMS. That last one is our
Sensor Law said in another dialect — the plugin and the CVL want the
same thing. This doctrine makes the discipline MANDATORY, PERSISTENT
(boot-enforced, since sessions don't persist), and SUBORDINATED to
CVL law where the plugin's defaults would collide with it.

## 1. Activation per harness (what actually happens at session start)

- CLAUDE CODE (Red on VENGEANCE; Green's console on CORNERMAN): the
  plugin's SessionStart hook AUTO-INJECTS the full using-superpowers
  meta-skill on every startup, /clear, and compact. There is no
  activation command to run. The seat's duty is ACKNOWLEDGMENT +
  OBEDIENCE (§3 boot addendum).
- CODEX: superpowers installed via the official Codex plugin
  marketplace; the harness exposes the skills in its manifest
  (satisfies CODEX_BOOT's using-superpowers requirement outright).
  ONE-TIME BLOODWAVE CONSOLE ACT: add to ~/.codex/config.toml:
      [features]
      multi_agent = true
  (enables spawn_agent/wait_agent/close_agent for the subagent
  skills). Codex additionally honors codex-tools.md: environment
  detection before worktree/finish operations; when the sandbox
  blocks branch/push (detached HEAD), commit, then hand branch/push/
  PR to Bloodwave via the App's native controls — which is our
  two-key law arriving from the other direction.
- CORNERMAN LM STUDIO MODELS (daily/coder): NOT a superpowers
  runtime. Packet duty keeps packet discipline (STEP 0, R7, OUTBOX).
  Green's CLAUDE CONSOLE carries this doctrine; its packets do not.

## 2. THE LIFEPUNCH SKILL MAP — which skill fires at which CVL moment

Session start ........... CVL boot checklist FIRST (S-1), then
                          superpowers ACK, then the Rule is in
                          force: skill-check before ANY action.
Relay lands WITH a ruled  executing-plans. The relay/spec is the
plan or spec (the normal  plan of record; checkpoints report back
CVL dispatch) ........... through the lane, not self-approved.
Relay lands as multi-step writing-plans FIRST; the plan banks to
work WITHOUT a plan ..... the comms lane for Fable/Bloodwave gate
                          BEFORE execution begins.
Task arrives with design  brainstorming — but as PROPOSAL
genuinely unsettled ..... GENERATION ONLY (S-3): output routes to
                          Bloodwave/Fable for ruling; seats never
                          self-ratify design.
Slice needs isolation or  using-git-worktrees. A worktree is a
twins run parallel        board-named lane (S-4); worktrees are
DIFFERENT tasks ......... HOW parallel twin work stays collision-
                          free.
Any bug, defect, test     systematic-debugging BEFORE proposing
failure, weird behavior . fixes. Folds with the eyes-gate: root
                          cause without visual/runtime confirmation
                          is inference, and this skill is the
                          procedure that earns the confirmation.
Writing any feature or    test-driven-development WHERE A TEST CAN
fix ..................... BITE (scripts, tooling, CI-checkable
                          logic). Where the s&box runtime is the
                          only oracle, sensor-based proof gates
                          substitute and the seat SAYS SO EXPLICITLY
                          — silent TDD-skipping is a defect.
2+ independent subtasks   dispatching-parallel-agents /
inside one seat's task .. subagent-driven-development (Codex needs
                          multi_agent=true). Subagents are INTERNAL
                          (S-5): they file nothing; the seat owns
                          all output, discipline, and blame.
About to claim done /     verification-before-completion. MANDATORY,
fixed / passing ......... ZERO EXCEPTIONS. This is Sensor Law's
                          enforcement arm: run the verification,
                          show the output, THEN claim.
Work complete ........... requesting-code-review, routed the CVL
                          way: twin cross-review via the diff-export
                          lane, plus optional Cornerman coder
                          consult (lifepunch/scripts/ask-cornerman.ps1, cite-
                          verification law C-B applies).
Review feedback arrives . receiving-code-review: verify technically
                          before implementing; no performative
                          agreement. (Our culture already grades
                          seats UP for pushing back with sensors.)
Branch/slice finished ... finishing-a-development-branch,
                          SUBORDINATED (S-2): the skill presents
                          integration options and STOPS. Merge, PR
                          approval, ship — Bloodwave's word, always.
Creating/editing skills . writing-skills, only under a Fable-relayed
                          task; promoting a skill into the tracked
                          tree remains a PR + gate review.

## 3. Boot addendum (lands in RED_BOOT, CODEX_BOOT, GREEN_BOOT)

SUPERPOWERS CHECK (add as a numbered boot item):
  a. Confirm the meta-skill is active: hook-injected
     (Claude harness) or exposed in the harness manifest (Codex).
  b. Report the count of available superpowers skills (expect 14).
  c. State in the boot report: "skill-check discipline in force."
  Missing/inactive plugin on a Claude harness = BOOT-FAULT.
  On Codex: report-and-hold for Bloodwave.

## 4. Subordination clauses (CVL law > plugin defaults, always)

S-1  BOOT FIRST. The CVL boot checklist precedes all skill checks;
     no task (and no skill invocation for a task) before BOOT-CLEAN.
     using-superpowers itself defers to user/project instructions —
     this doctrine IS those instructions.
S-2  TWO-KEY UNTOUCHED. No skill merges, ships, publishes, deletes,
     or spends. finishing-a-development-branch ends at presenting
     options.
S-3  DESIGN AUTHORITY. Seat brainstorming generates proposals;
     ratification is Bloodwave's (with Fable). A relay carrying a
     ruled spec is settled design — executing-plans, not
     re-litigation.
S-4  WORKTREES SERVE THE LANE LAW. One DRIVE and one pair of
     canonical-tree hands at a time, board-named — unchanged.
     Worktrees isolate DIFFERENT tasks for parallel twins; working
     the SAME task (or tasks that affect each other's surfaces) in
     parallel remains forbidden. A worktree's existence and owner
     go on the BOARD.
S-5  SUBAGENTS ARE INTERNAL. They inherit the seat's laws, file no
     lane records, and their claims are the seat's claims — the
     seat machine-verifies before repeating them.
S-6  SENSOR LAW WINS. Every skill's output obeys claims-carry-
     sensors; verification-before-completion is mandatory before
     any success claim, commit, or PR.

## 5. Why this is worth its cost (Bloodwave's intent, recorded)

Skills are not persistent across session windows — but our boots
are. Encoding the discipline in boot canon makes every fresh session
start at full power instead of relearning it. Paired with the
Cornerman consult lane and twin cross-review, this is the CVL
running how it is really supposed to run: reproducible dev agents,
highest-capacity work, drastically increased quality — matched to
the complexity of the code space we are in.
