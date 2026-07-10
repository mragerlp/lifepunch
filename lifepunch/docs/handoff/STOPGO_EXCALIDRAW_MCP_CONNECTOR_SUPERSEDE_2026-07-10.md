# STOP-GO — Excalidraw MCP Connector, SUPERSEDING RECORD

- **Supersedes:** `STOPGO_EXCALIDRAW_MCP_CONNECTOR_2026-07-10.md` — **in its §2 fail-mode claim only.**
  That record stays byte-unmodified. Everything else in it (scope table, untrusted-read rule,
  confirmed-write rule, bounded first test, rollback, the future-connector template) **remains in force.**
- **Status:** CANON — decision record, ruled 2026-07-10. GO given for the config edit.
- **Ruled by:** Bloodwave (via Fable). Observed and transcribed by Red.
- **Sensor build:** `claude-code/2.1.187 (claude-desktop, agent-sdk/0.3.205)` on Red.
- **Companions:** `PROOF_ENVIRONMENT_DOCTRINE.md` (the Sensor Law) · `README.md` (write-once law)

---

## WHY THIS RECORD EXISTS

The original brief's §2 rests on a claim about what happens when the API-key environment
variable is unset. Red sourced that claim from Anthropic's published MCP documentation, which
states that Claude Code **fails to parse the config** when a required environment variable is
unset and carries no default.

**That claim is FALSE on `claude-code/2.1.187`.** It was falsified by a sensor, not by argument.

The original is a committed canon record and is therefore write-once. It is not annotated. It is
superseded here, by filename, per the law in `README.md`.

---

## WHAT WAS OBSERVED

### 1. An unset bare `${VAR}` does not fail to parse

A scratch project carried two servers in one `.mcp.json`: a `probe` server referencing an unset
`${LP_PROBE_UNSET_VAR}`, and a second server named **`canary`** referencing nothing. `canary` was
the blast-radius sensor: if one missing variable takes down the file, `canary` disappears with it.

`canary` survived. The config parsed. Claude Code emitted a diagnostic instead:

```
[Contains warnings] Project config (shared via .mcp.json)
 └ [Warning] [probe] mcpServers.probe: Missing environment variables: LP_PROBE_UNSET_VAR
```

Confirmed a second time against the **real** repo config after the edit landed, with
`EXCALIDRAW_API_KEY` unset: `sbox` and `sbox-editor` both still registered, and the warning named
`EXCALIDRAW_API_KEY` exactly. **Adding the connector cannot take the bridge config down.**

### 2. The wire capture — what is actually transmitted

A loopback TCP listener captured the real request. The question "does it fail loudly, or silently
load with an empty Bearer token?" is a question about the wire, so the wire was read.

**Bare `${VAR}`, variable unset:**

```
POST /mcp HTTP/1.1
Authorization: Bearer ${LP_PROBE_UNSET_VAR}
User-Agent: claude-code/2.1.187 (claude-desktop, agent-sdk/0.3.205)
```

The **literal, unexpanded placeholder** is transmitted. Not an empty token. `claude mcp list`
renders the result as `× Failed to connect`.

**The `${VAR:-unset}` default — Red's own prior proposal:**

```
Authorization: Bearer unset
```

No warning. No diagnostics block at all. It loads silently with a bogus token.

### 3. `mcp list` approval state is per-surface, not global

In the CLI, `sbox`, `sbox-editor` and `excalidraw` all report `Pending approval` — while `sbox` is
simultaneously **connected** in the live desktop session. CLI and desktop track MCP approval
separately. Consequence: **`claude mcp list` is not a sensor for connection or auth state** in this
repo, because it never reaches the connect step for an unapproved server. This is why the auth
mitigation below cannot be discharged by reading a list.

---

## THE WITHDRAWN DEFAULT, AND WHY

Red proposed `${EXCALIDRAW_API_KEY:-unset}`. The justification was protecting Green and Mac from a
whole-file parse failure. **That justification rested on the false doc claim above.** The parse
failure does not exist, so the default protected against nothing — and it introduced the exact
failure mode the owner had forbidden.

Bloodwave's ruling on why `unset` is worse than the placeholder:

> `Bearer unset` is a string that **looks like a value**. It fails today, and silently succeeds the
> day someone's key is literally `unset`, or the day the API's rejection semantics change.
> `Bearer ${EXCALIDRAW_API_KEY}` is not a plausible token. It cannot be mistaken for authenticated.
> It 401s by construction.

**Withdrawn.** The shipped form is bare `${EXCALIDRAW_API_KEY}`, no default.

---

## THE FAIL-LOUD RULING

**Refuse-to-load does not exist in `.mcp.json`.** No form of the config causes Claude Code to
decline to start a server. The bar is therefore ruled **CLEARED by the bare `${VAR}` form**, on the
strength of its aggregate observed behavior:

1. a named startup warning identifying the exact missing variable, **and**
2. a failed connection, **and**
3. no valid-looking token ever on the wire.

It is warn-and-continue, not refuse-to-load. It is loud in the only dimension that matters: **it can
never be mistaken for working.**

---

## MANDATORY MITIGATION — observe auth, never assume it

**A warn-and-continue connector in a dead state must be proven dead, not assumed live.**

Before **any** canvas call, Red must observe that the `excalidraw` server loaded **and
authenticated**. *"The server appears in the list"* is not authentication. The sensor is:

- **Negative control (captured 2026-07-10, above).** Variable unset → the placeholder goes on the
  wire → connection fails. Same config, same URL.
- **Positive ID — a read-only authenticated call.** With the key set, Red calls a **read-only**
  excalidraw tool that must consult the workspace, and observes workspace-specific data come back.
  A 401/403 proves not-authenticated. A workspace payload is a response **only a valid key could
  produce** — the behavior is the ID.

The two together are a differential: connection state flips on the Authorization value alone.

**Collision case, ruled in advance.** If the connector exposes **no** read-only tool, then the first
authenticated call would necessarily be a **write** — and a write cannot serve as the auth probe,
because §1 of the original brief requires every write to be proposed and GO'd first. In that case
Red **STOPs and asks**. It does not "just try a write" to see if the key works.

---

## THE APPROVED EDIT

`C:\Users\jared\Projects\lifepunch\.mcp.json` — **git-tracked.**

```json
"excalidraw": {
  "type": "http",
  "url": "https://api.excalidraw.com/api/v1/mcp",
  "headers": { "Authorization": "Bearer ${EXCALIDRAW_API_KEY}" }
}
```

**The secret-keeping guarantee is the indirection, not a `.gitignore` line.** No ignore line exists
or could: `.mcp.json` is tracked, and ignoring it would require untracking it, deleting the `sbox`
bridge config for every node. The committed bytes contain the variable's **name**. They never
contain its **value**. There is no sequence of `git add` mistakes that commits a key the file never
held.

**Boundary, stated plainly:** this proves the key stays out of **git**. It does not hide the key
from a shell on Red — `$env:EXCALIDRAW_API_KEY` is readable by any process Red runs. *"Red never
sees it"* holds by discipline, not by a wall Red cannot climb.

Bloodwave sets the value by hand, in a terminal Red does not read:

```
setx EXCALIDRAW_API_KEY "<API_KEY>"
```

`setx` writes the user environment; only **new** processes inherit it. Claude Code must be fully
restarted.

**Unverified and labelled:** `https://api.excalidraw.com/api/v1/mcp` is taken from the original
brief as given. Red has not resolved it.

---

## SEQUENCE (GO given 2026-07-10)

1. Restart Claude Code **before** `setx` — the free sensor. Observe the unset-var warning and the
   failed connect. Fail-loud behavior **verified, not assumed.**
2. Bloodwave runs `setx EXCALIDRAW_API_KEY <key>`. The value never appears in a relay, in chat, or
   in any file Red writes.
3. Restart Claude Code.
4. Red confirms the server loads **and authenticates**, per the mitigation above.
5. **STOP.** Canvas WRITE is a separate propose-and-STOP.

## PRE-COMMIT GATE (original brief §6)

```bash
git grep -n -I -E 'Bearer +[A-Za-z0-9._-]{8,}' -- . \
  | grep -v -E '\$\{|<[A-Z_]+>|__[A-Z_]+__|placeholder'
```

Baselined **CLEAN**. The exclusions are load-bearing, not decorative: untuned, the pattern fires on
`lifepunch/server/observability/blackbox/blackbox.yml.template:18` (`Bearer __STATUS_TOKEN__`), a
placeholder. A gate that cries wolf on a template is a gate people learn to ignore.

---

## WHAT THIS RECORD ADDS TO THE CONNECTOR TEMPLATE

The original brief's §7 lists what every future connector inherits. This record adds two items:

- **A vendor's documentation is a declaration, not an observation.** Config-time and wire-level
  behavior get a sensor before a connector's failure mode is written into canon.
- **Loading is not authenticating.** Every connector that carries a credential declares, up front,
  the read-only sensor that proves the credential was accepted — and what it does when no such
  sensor exists.

## Cross-references

- `STOPGO_EXCALIDRAW_MCP_CONNECTOR_2026-07-10.md` — the original. Byte-unmodified. Its §2 fail-mode
  claim is superseded here; every other section stands.
- `PROOF_ENVIRONMENT_DOCTRINE.md` — the Sensor Law. *A declaration is not an observation* is the
  same law that says a compile log is not a positive code-string ID.
- `README.md` — write-once: records are superseded by filename, never annotated.
