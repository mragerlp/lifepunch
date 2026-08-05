# MACOS-MCP / TCC DISCLAIM — DIAGNOSIS + CLASS C PROPOSAL

**DIAGNOSED 2026-08-05**, Claude Code session on the macOS tree
(`/Users/cornermanmac/RiderProjects/lifepunch`, branch `develop`, HEAD `272e377e`, clean).
Subject: `CursorTouch/MacOS-MCP` v0.3.8, installed as Claude Desktop extension
`ant.dir.gh.cursortouch.macos-mcp` (install hash `71e7d37a284b13378de868356d0bfb22647d954afca5fc908ed632a616513f43`).
Governs against `CONSOLE_PLUGINS_DOCTRINE.md` §2 Class C and `CVL_AUTHORITY_LEVELS_2026-07-13.md` L4.

> **CLASS: DIAGNOSIS (§1–§4) — write-once, records what happened.**
> **§5 IS PROPOSED, NOT RULED.** Adoption requires an explicit Bloodwave GO. Supersede with a new
> record citing this one by filename.

---

## 0. THE FINDING IN ONE SENTENCE

**Claude Desktop deliberately strips its own TCC identity from every MCP server it spawns, so a macOS
permission granted to `Claude.app` can never reach an MCP server — the grant must be applied to the
binary Claude actually spawns.**

Here that binary is **`uv`**. Not `Claude.app`. Not the extension's venv Python.

---

## 1. THE MECHANISM

Claude Desktop does not spawn MCP servers directly. It spawns them through a shim:

```
47359  /Applications/Claude.app/Contents/MacOS/Claude          ← granted
  └─ 74215  /Applications/Claude.app/Contents/Helpers/disclaimer
       └─ 74216  uv --directory <ext> run macos-mcp serve      ← the actual TCC client
```

`disclaimer` is a 136 KB universal Mach-O whose linked symbols include:

```
_responsibility_spawnattrs_setdisclaim
_posix_spawnp
```

and whose strings include `Usage: disclaimer <command> [args...]` and
`Failed to set disclaim attribute: %s`.

`responsibility_spawnattrs_setdisclaim()` makes the spawned child **renounce the parent's TCC
responsibility** and become responsible for itself. **This is a deliberate security design, not a
defect** — it prevents an arbitrary third-party extension from silently inheriting permissions the
operator granted to Claude. **It is working as intended.** MacOS-MCP's own install documentation
("Accessibility permissions granted to the terminal or application running the MCP server") does not
account for it.

---

## 2. WHY EVERY INTERMEDIATE STATE LOOKED LIKE A CONTRADICTION

This cost several hours because the honest sensors disagreed with each other until the shim was found:

| Observation | Reading | Why it misled |
|---|---|---|
| `Claude.app` granted, `TCC.db` written | grant is real | true — but irrelevant to a disclaimed child |
| `AXIsProcessTrusted()` from a Claude Code shell | `True` | that lineage's responsible process is `com.anthropic.claude-code`, not `uv` |
| Server launched by hand | **starts clean** | hand-launch inherits the shell's identity; no disclaim |
| Claude's own spawn, same binary/env/argv | **`sys.exit(1)`** | disclaimed → answers as `uv`, which was ungranted |

**Reproducing Claude's exact `PATH`, `uv` path, and argv did NOT reproduce the failure.** Only
interposing the shim did. That is the controlled test that closed it:

```bash
# CONTROL — starts clean
/Users/<user>/.local/bin/uv --directory <ext> run macos-mcp serve < /dev/null

# TEST — reproduces Claude's failure exactly, single variable changed
/Applications/Claude.app/Contents/Helpers/disclaimer \
  /Users/<user>/.local/bin/uv --directory <ext> run macos-mcp serve < /dev/null
```

**Sensor law note:** the load-bearing sensor throughout was a direct AX call
(`AXUIElementCopyAttributeValue` → `AXWindows`), **not** `AXIsProcessTrusted()` and **not** file mtimes.
A `TCC.db` mtime check used mid-investigation was **invalid** — it watched the *user* database
(`~/Library/Application Support/com.apple.TCC/TCC.db`) while **Accessibility is a system-level service**
living in `/Library/Application Support/com.apple.TCC/TCC.db`. The conclusions held only because the AX
probe was authoritative. **A sensor pointed at the wrong artifact is not a sensor.**

---

## 3. THE GENERAL LAW THIS IMPLIES

**For ANY MCP server on macOS that needs a TCC-gated capability** (Accessibility, Screen Recording,
Automation, Full Disk Access, Camera, Microphone):

1. **The grant goes on the binary named in the server's `command` field** — the process Claude spawns
   through the shim. For `uv`/`npx`/`node`-launched servers that is the **launcher**, not the app and
   not the interpreter the launcher later selects.
2. **Granting `Claude.app` accomplishes nothing for that server.** It is not a partial fix, a
   prerequisite, or a fallback. It is orthogonal.
3. **Verification must run through the shim.** A hand-launched check passes under a different identity
   and is therefore **green-by-omission** — it cannot distinguish "the server has permission" from
   "my shell has permission."

Verification form that is actually valid:

```bash
/Applications/Claude.app/Contents/Helpers/disclaimer <the-exact-command-Claude-runs>
```

---

## 4. TWO STANDING HAZARDS OF THE FIX

**H-1 — the grant is far broader than the tool.** `uv` is a generic Python project runner. Granting it
Accessibility grants desktop control to **every `uv run` on the machine**, for every project, not to
MacOS-MCP alone. The blast radius is the launcher, and the launcher is shared.

**H-2 — the grant is pinned to an ad-hoc hash and will break silently.**

```
/Users/<user>/.local/bin/uv
  Identifier=uv-842fcb39f321fa00
  Signature=adhoc          TeamIdentifier=not set
```

TCC keys an ad-hoc-signed binary by cdhash. **A `uv` upgrade invalidates the grant**, and the failure
surfaces as an unrelated-looking MCP disconnect. **First thing to check when a previously-working
macOS MCP server dies after routine tooling maintenance.**

**H-3 — the vendor's own permission check is GREEN-BY-OMISSION.** `permissions.py:29-46`
`check_screen_recording_permission()` runs
`osascript -e 'tell application "System Events" to get version'` — which tests **Automation /
AppleEvents, not Screen Recording.** It returns `True` while Screen Recording is denied. Measured on
this stack: that check passed while `CGPreflightScreenCaptureAccess()` returned `False`. Consequence:
the `Snapshot` tool returns element tree and window list normally while its **screenshot silently comes
back empty, and the server never warns.** This is exactly the defect family named in
`FABLE_CONDUCTOR_PATTERN_2026-07-14.md` §3 — *a check that cannot distinguish "I verified it and it's
fine" from "I could not verify it" is not a check.*

Its escape hatch `MACOS_MCP_SKIP_PERMISSION_CHECK=1` (`permissions.py:95,110-114`) **downgrades the
startup gate to a warning without granting anything.** Setting it while the grant is genuinely absent
yields a server that connects, reports healthy, and fails every AX call at invocation time. **It is a
mask, not a fix, and it must never be set as a first move.**

---

## 5. PROPOSED — NOT RULED

**Classification proposed: CLASS C** (`CONSOLE_PLUGINS_DOCTRINE.md:261`, *automation with standing
effects — Bloodwave GO required*), on three grounds, any one of which is sufficient:

- **Unsandboxed `Shell` tool** including AppleScript mode — exceeds the Desktop Commander
  scope-discipline clause (`:273-278`), which confines operations to the repo, the comms lane, and
  task-named paths.
- **`macos-mcp install` registers a `launchd` background agent** — a standing service, the same shape
  that got **Understand-Anything SKIPPED 2026-07-14** pending a Class C+ ruling.
- **Full Accessibility API control of the desktop**, granted at the shared-launcher level per **H-1**.

The vendor states its own exclusions: *systems with irreplaceable data, production or shared machines,
compliance-regulated environments.*

**OPEN AND EXPLICITLY NOT RULED HERE:**

1. **Adoption itself.** Installed is not adopted. `CONSOLE_PLUGINS_DOCTRINE.md` §0: *plugins are
   CAPABILITY, NOT AUTHORITY* — **installed is not invoked.**
2. **Which seats may invoke it**, and on which hosts.
3. **Whether the `uv`-level grant (H-1) is acceptable**, or whether the server should instead run over
   `streamable-http` from a deliberately-granted host so the shim never applies and the grant scope is
   narrowed to that host.
4. **Seat identity of the authoring session.** `OPENCODE_SEAT_IDENTITY_AND_HARNESS_OPS_RULING_2026-07-15.md`
   binds seat to **harness + host + tree**, and names Green's clone as `C:\Projects\lifepunch`. This
   session is Claude Code on a **macOS** host and tree that **no ratified record contemplates**. It is
   therefore **neither Red nor Green by the letter of the ruling**, and this record claims **no seat
   authority** — it is filed as advice-class pending Bloodwave's word.
5. **Whether this record belongs in the canonical VENGEANCE tree.** It was authored on the macOS tree
   and reaches canon only through the normal gate, under Bloodwave's merge authority.

**Nothing in this record is a grant.** *Absence of a grant is not a grant*
(`CVL_AUTHORITY_LEVELS_2026-07-13.md`).

---

## 6. SENSORS (2026-08-05, this stack)

| Sensor | Pre-fix | Post-fix |
|---|---|---|
| `AXIsProcessTrusted()` **through the shim** | `False` | `True` |
| `AXUIElementCopyAttributeValue(AXWindows)` **through the shim** | `-25211` `kAXErrorAPIDisabled` | `0` — 2 windows |
| Server start **through the shim**, `MACOS_MCP_SKIP_PERMISSION_CHECK` **cleared** | `sys.exit(1)` | `Starting MCP server 'macos-mcp' with transport 'stdio'` |
| `CGPreflightScreenCaptureAccess()` through the shim | `False` | `False` — **still ungranted** |

The third row is the load-bearing one: it passed with the bypass explicitly removed
(`env -u MACOS_MCP_SKIP_PERMISSION_CHECK`), so it records a real gate, not a silenced one. The
session-level `launchctl` variable set mid-investigation was **cleared** on completion.

**`Snapshot` screenshots remain non-functional** until `uv` is granted Screen Recording as well.
