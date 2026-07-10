# CVL stack — attack-surface review (instrument)

**Status:** INSTRUMENT — checklist authored by Fable, ratified by
Bloodwave 2026-07-10. Checks unexecuted; each result freezes per the
hybrid ruling when measured. Executing seat noted per item; Green
facts are Green's to assert, Blue's are asserted at Blue's keyboard.

## Posture summary (as of authoring)

The 2026-07-10 CVL 2.0 build (Odysseus seat, CornermanOutbox share,
Excalidraw connector) added no internet-facing surface: shares are
LAN/direct-link, agent seats are outbound-HTTPS clients, not
listeners. The stack's only intentional WAN exposure is Blue
(lifepunchnet), hosting the game servers. The dominant agent-class
risk is prompt injection via read surfaces, controlled by the
read-rule doctrine (canvas law · connector instruction-block ruling
· One-Voice Law) and certified per-lane by injection probes.

## Checks

### S1 — Blue WAN listener audit  (highest value)
Where: Blue's keyboard/RDP. Check: listening sockets vs firewall
rules (Get-NetTCPConnection -State Listen + inbound rules). Pass:
game ports (27015–27018 per servers.json) open by design;
RDP/SSH/WinRM/GitLab-runner/panel ports NOT WAN-reachable — VPN or
source-allowlist only. Fail action: restrict at provider firewall
first, host firewall second.

### S2 — Tailscale disposition (Green)
Check: confirm the Tailscale interface is intentional; enumerate
tailnet devices and key expiry. Pass: Bloodwave names its purpose in
one line (it becomes the sanctioned remote-admin path). Fail action:
uninstall — an unowned overlay is standing remote reachability.

**RULED 2026-07-10: BLESSED — the sanctioned remote-admin path.**
The fail action does not apply. Rollout, device list and key expiry
are `H2` of `STOPGO_AUTOMATION_HARDENING_2026-07-10.md`. Order is
load-bearing: install Red + Blue, verify tailnet reachability, and
only THEN let `S1` close Blue's admin ports off the WAN — closing
first locks the operator out of the box he is hardening.

### S3 — LM Studio bind scope (Green)
Check: which address :1234 listens on. Pass: localhost-only unless a
ruled consumer needs LAN reach (packet transport is SMB; Odysseus
calls :1234 from the same box — localhost likely costs nothing).
Fail action: flip to localhost; LAN reach needs its own ruling.

### S4 — SMB credential hardening (Green)
Ref: Odysseus's flag — plaintext vengeance-smb.password/.user beside
the worker config. Queued fix: DPAPI/Get-Credential storage inside
the post-P1 worker code pass (worker reads protected credential,
plaintext deleted). Interim: LAN-local file, owner-accepted risk.

**RULED 2026-07-10: DPAPI is REPAIR #5 of the post-P1 worker pass —
five repairs, one PR, through the merge gate.**
`GATE_ODYSSEUS_P1_VERDICT_2026-07-10.md` records four; it froze
before this ruling landed and is not annotated. The five, in one
worker pass: (1) per-packet clone-override · (2) worker EMITS
git-derived attestation, gate verifies values not headings ·
(3) successful re-fire removes stale `error.md`/`.fail.json` ·
(4) CITATION GATE — machine-verify every `file:line` against the
pin before the report is written · (5) **this item.**
The pass queues BEHIND the chair session: Red is the editor seat
and cannot run both.
`**/vengeance-smb.password` is already `.gitignore`d, so the
plaintext credential cannot reach git; the exposure is at rest on
Green, not in history.

### S5 — Share ACL posture (Green, standing)
Ref: P0 verdict — read-only guaranteed by the SHARE ACL; NTFS grants
Authenticated Users Modify via inheritance. Check (someday):
explicit NTFS ACE on OUTBOX so the guarantee is a property of the
directory, not only the route. Same review for the inbox share.

### S6 — Secrets-at-rest sweep (Red + Green)
Ref: PSReadLine history holds a test-server authorize token
(owner-ruled acceptable); Excalidraw key via env indirection
(verified out of git twice). Check: one pass for other plaintext
credentials in shell histories, .env files, and configs outside the
repo. Rule of record: secret-bearing commands typed with a leading
space or via variables.

### S7 — Agent read-surface certifications (standing doctrine)
Canvas lane probe PASSED 2026-07-10. Connector instruction blocks
ruled (operating manual, not a voice). Share/G: files are data,
never instruction. Corner lane: P2 injection probe REQUIRED before
live sittings. Standing rule: every NEW read surface an agent gains
(connector, share, inbox) gets its own probe before trust.

### S8 — Blue lane records linkage (parking lot)
Blue's GitLab repo holds incident-response canon (rollback
pointers). One line in CVL doctrine should name how a cold session
finds it. Discoverability gap, not a hole.

## Review cadence

Re-run S1 on any Blue provisioning change; re-run S7 on any new
agent surface; the rest annually or on incident.
