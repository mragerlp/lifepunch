# GATE VERDICT — Odysseus P0: the Green seat is up

- **Status:** **RECORD. FROZEN.** The gate was executed and its verdict recorded, so script and
  result freeze together as one document. A re-run needs a **new** gate script citing this one.
- **Verdict:** **ALL P0 LINES GREEN.**
- **Split provenance:** split from `GATE_ODYSSEUS_P0_CHECKLIST_2026-07-10.md` on 2026-07-10 under
  the hybrid-split ruling, when P0's verdict landed. That file **keeps its original filename** and
  holds the **un-run P1 remainder** as a live instrument. Each cites the other by filename.
  **Neither annotates the other.**
- **Charter:** `STOPGO_ODYSSEUS_CORNER_LOOP_CHARTER_2026-07-10.md`
- **Executed by:** Bloodwave and Odysseus at Green's keyboard. Red was passive except for one
  sanctioned act.

`GATE HEADER: NODE: Green (Cornerman) · IDENTITY: Bloodwave at Green's keyboard · RED IS PASSIVE`

---

## LAW — whose sensor is whose

**CVL Sync Law:** *Code does not validate against its own tree what another machine executes.*
Red cannot assert one fact about Green. Every line marked **[GREEN ASSERTS]** was measured on
Green, by Green, before the next line ran. Red's job was to declare what it validated against
and then get out of the way.

**Green fast-fail:** no retries, no detach, no polling loops, no CIM/WMI, no `schtasks`. Any
error or hang past ~20 s → abort, report the raw error, stop. Do not "try the next thing."

---

## THE DECLARATION

> **`expectedClones` (lifepunch) = `bc76eab`**
> **full: `bc76eab5e0e4237147416531ec41bd596a8053f8`**

Declared by Red in the P0 GO relay, 2026-07-10, against an **observed** `origin/develop` tip with
the docs freeze verified against the remote immediately beforehand.

**Odysseus reported an identical HEAD and correctly WITHHELD the match pending Red's
declaration.** That is the law working on its first contact: *the authoring node declares the
commits it validated against; the worker asserts them on its own node before reading a byte.* A
worker that matches an undeclared value has not asserted anything — **it has agreed with itself.**
Packet E is what that looks like when the agreement happens to be wrong.

---

## MEASURED FACTS, and who measured them

| Fact | Value | Sensor |
|---|---|---|
| Claude Code on Green | **2.1.206**, native exe at `C:\Users\jared\.local\bin\claude.exe` | Bloodwave, on Green |
| Claude Code on Red | **2.1.187**, npm shim at `C:\Users\jared\AppData\Roaming\npm\claude.cmd` | Red (`claude --version`; the wire capture's `User-Agent` agrees) |
| Green repo | `C:\Projects\lifepunch` | Odysseus, in seat |
| Green outbox | `C:\lifepunch\cornerman\OUTBOX` | Odysseus, in seat |
| **Return lane** | **`\\10.10.10.2\CornermanOutbox`** (direct link) | Red, observed enumeration |
| LAN route | `\\192.168.1.229\CornermanOutbox` — **UNVERIFIED, not broken.** No test owed. | — |
| Hostname `CORNERMAN` | **has never resolved from Red's seat.** The inbox lane always ran by IP. | Red, `PathNotFound` |

> **The two seats are not the same build.** Red is `2.1.187`; Green is `2.1.206`. Harness behavior
> does not cross the version gap. Every line below records **which seat measured it.**

---

## THE MCP CLAUSE — two independent facts, no compound "and"

The instrument predicted: *"the warning names `EXCALIDRAW_API_KEY`, and the other MCP servers
still register."* **The second half of that was a RED-surface prediction. It does not freeze as
if it described Green.** Odysseus measured `enabledMcpjsonServers=[]` and
`disabledMcpjsonServers=[]` in seat, and the two facts have **independent mechanisms**:

**FACT 1 — `excalidraw` warns, and the config PARSES.** The warning is verbatim
*"Missing environment variables: EXCALIDRAW_API_KEY"*. This is a **config diagnostic on 2.1.206**
and it fires **independent of approval state**.

*Consequence:* the instrument's STOP branch — *"if instead the whole config fails to parse, STOP"* —
is **closed, not taken.** `2.1.206` parses, as `2.1.187` did. The finding in
`STOPGO_EXCALIDRAW_MCP_CONNECTOR_SUPERSEDE_2026-07-10.md` survives the version gap on a second,
independently measured build. **It needs no superseding record.**

**FACT 2 — `sbox`, `sbox-editor` and `excalidraw` were NEVER APPROVED.** Never rejected, either:
**absence-by-approval, measured.** For a seat that never touches editors this is
**correct-by-charter**, not a failure. Odysseus has no editor and needs none.

*The two facts share no mechanism.* A parse diagnostic and an approval state are different
surfaces, and joining them with an "and" would have frozen a causal claim nobody measured.

---

## P0.1 — PATH fix  **[GREEN ASSERTS]** — **PASS**

Read the **User** PATH, never the process PATH — collapsing the machine PATH into the user PATH
is the classic way to break a box with one line.

```powershell
$u = [Environment]::GetEnvironmentVariable('Path','User')
if ( $u -notlike '*\.local\bin*' ) {
    [Environment]::SetEnvironmentVariable('Path', "$u;C:\Users\jared\.local\bin", 'User')
}
```

`setx`-class changes reach **new processes only.** Fresh terminal, then:

```powershell
(Get-Command claude).Source     # expect C:\Users\jared\.local\bin\claude.exe
claude --version                # expect 2.1.206
```

**OBSERVED:** `claude.exe` **2.1.206** at `C:\Users\jared\.local\bin\claude.exe`. Asserted on Green.

## P0.2 — Auth on Green  **[GREEN ASSERTS]** — **PASS**

`claude` authenticates interactively against Bloodwave's account. Red cannot see, hold, or verify
that credential and was never shown it.

**OBSERVED:** `claude` launched in `C:\Projects\lifepunch` with **no auth prompt.** Asserted on Green.

## P0.3 — The OUTBOX return lane — **PASS**

The return lane is Green → Red. It is **not** the Chat seat's `G:` connector, which maps Green's
*inbox* and whose reads are **denied in practice** by a server symlink/UNC validation bug
(`STOPGO_TRANSPORT_G_READSURFACE_FOLLOWUP_2026-07-10.md`). The two surfaces fail differently.

**ACL principal — RULED 2026-07-10: Bloodwave's user account.** Not `Everyone`, not a machine
account, not a group. Green printed its own principal (`"$env:COMPUTERNAME\$env:USERNAME"`) rather
than Red composing it — an account name is part of a machine's identity, and the machine asserts
its own.

### THE ACCEPTANCE SENSOR IS THE OBSERVED READ, NOT THE RESOLVED PATH

> **EXISTENCE IS NOT READABILITY.** Ratified 2026-07-10.

`Test-Path` proves a path **resolves**. It does not prove the caller can **read** it. This is not
theoretical: `G:` is *listed-allowed and unreadable in practice.* An allowlist entry is a
declaration; a successful read is an observation. A `True` from `Test-Path` on a share whose NTFS
ACL denied Red would have looked identical and shipped a broken lane straight into **P1 case C**.

**OBSERVED, in order, one attempt each, no retries:**

| Act | Result |
|---|---|
| `Test-Path \\CORNERMAN\CornermanOutbox` | `False` — `ItemNotFoundException`, *"Cannot find path … because it does not exist"*, HResult `0x80131501`, `PathNotFound`. **Not** `AccessDenied`. |
| `Test-Path \\10.10.10.2\CornermanOutbox` | **`True`**, first try. SMB session established ⇒ auth honoured. |
| `Get-ChildItem \\10.10.10.2\CornermanOutbox` | **READ SUCCEEDED — 137 entries, no exception.** First five: `patches` · `patches-latest` · `task-20260706-031500-routing-validation` · `task-20260706-033000-cornerman-docs-drift` · `task-20260706-225614-machine-spec-drift-audit-run-1-bounded` |

**The enumeration is the acceptance sensor of record.** Share ACL and NTFS ACL intersect in Red's
favour, observed from the side that has to do the reading.

### NTFS, as Odysseus measured it on Green

- `BUILTIN\Users` — **ReadAndExecute**
- **All ACEs inherited.** No explicit ACE for the principal.
- `Authenticated Users` — **Modify**, *locally*.

**Therefore the SHARE ACL is the read-only guarantor, not NTFS.** *Observation, not a ruling:* the
read-only property holds for Red **because it arrives over this share**. A local process on Green,
or any other share or path onto that folder, is not bound by it. The guarantee is a property of the
route, not of the directory.

## P0.4 — Clone freshness  **[GREEN ASSERTS]** — **PASS**

*The clone is a sensor.* Packet E's failure was Red validating input paths against **Red's** tree
while the worker read **Green's**. Never assume; assert.

```powershell
cd C:\Projects\lifepunch
git fetch --prune
git rev-parse HEAD        # must equal the expectedClones value Red declared in the GO relay
git status --porcelain    # must be EMPTY
```

**OBSERVED:** Green's HEAD matched **`bc76eab`** by name; tree clean. Odysseus **withheld the match
until Red declared** — see THE DECLARATION above. **Refuse by name; never substitute.**

**Nested-clone trap (carried, still true):** `lifepunchdxrp/` is `.gitignore`d and separately
cloned. It does **not** travel with the parent's `git pull`, and a hand-copied folder sits frozen
indefinitely. A git-less snapshot is not a clone and nothing on it can be verified at all. Assert
it separately, or declare it out of scope for the packet — **in writing.**

## P0.5 — Cold grounding  **[GREEN ASSERTS]** — **PASS**, scored by Fable

Launch, the only sanctioned form. No wrapper, no launcher, no `ollama` between Bloodwave and the seat:

```
cd C:\Projects\lifepunch
claude
```

**OBSERVED:** Odysseus walked the `CLAUDE.md` chain **unaided**, named the **two laws** and the
**hybrid-split** ruling, and asserted its own world-state. **The chain was as much under test as
the seat, and both passed.**

## P0.6 — Out of scope  **[GREEN ASSERTS]** — **PASS**

**OBSERVED:** Docker and Ollama **untouched**. LM Studio `:1234` is the ratified muscle.
**Presence is not permission** — held.

---

## P0 ACCEPTANCE — as executed

```
P0.1   PASS   claude.exe 2.1.206 at C:\Users\jared\.local\bin — asserted on Green
P0.2   PASS   claude launched in C:\Projects\lifepunch, no auth prompt — asserted on Green
P0.3   PASS   return lane \\10.10.10.2\CornermanOutbox — READ OBSERVED, 137 entries, no exception.
              Acceptance sensor = the enumeration, NOT the resolved path.
              Share ACL is the read-only guarantor; NTFS grants Authenticated Users Modify locally.
              CORNERMAN never resolved from Red. LAN route UNVERIFIED-not-broken, no test owed.
P0.4   PASS   Green HEAD == bc76eab, matched BY NAME, tree clean. Odysseus withheld pending
              Red's declaration — correct.
P0.5   PASS   Odysseus grounded cold, named two laws + hybrid-split unaided. Scored by Fable.
P0.6   PASS   Docker/Ollama untouched; LM Studio :1234 the only muscle.
MCP    FACT 1 excalidraw warns "Missing environment variables: EXCALIDRAW_API_KEY"; config PARSES.
              A 2.1.206 config diagnostic, independent of approval state. STOP branch NOT taken.
       FACT 2 sbox / sbox-editor / excalidraw NEVER APPROVED, never rejected —
              absence-by-approval, correct-by-charter for a seat that never touches editors.
              Two facts, two mechanisms, no compound "and".
```

**VERDICT: ALL P0 LINES GREEN. The Green seat is up.** P1 proceeds under
`GATE_ODYSSEUS_P0_CHECKLIST_2026-07-10.md`, the live instrument.

---

## Cross-references

- `GATE_ODYSSEUS_P0_CHECKLIST_2026-07-10.md` — the un-run P1 remainder. Keeps the original
  filename by ruling. Editable until **its** verdict lands.
- `STOPGO_ODYSSEUS_CORNER_LOOP_CHARTER_2026-07-10.md` — the charter this gate serves.
- `STOPGO_TRANSPORT_G_READSURFACE_FOLLOWUP_2026-07-10.md` — *listed-allowed, unreadable in
  practice.* The precedent that made the enumeration, not the path, the sensor.
- `STOPGO_EXCALIDRAW_MCP_CONNECTOR_SUPERSEDE_2026-07-10.md` — its finding survives the version
  gap; FACT 1 is a second, independently measured confirmation on `2.1.206`.
- `STOPGO_CORNERMAN_CLONE_FRESHNESS_2026-07-10.md` · `CORNERMAN_HEADLESS_DROP_WORKER.md` —
  `expectedClones` is declared by the authoring node, in a machine-checked field.
