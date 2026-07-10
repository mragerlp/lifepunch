# Transport Law addendum — G: follow-up, the measurement

**Status:** RECORD of a measurement (2026-07-10). Closes §4 of
`STOPGO_TRANSPORT_G_READSURFACE_2026-07-10.md`, which is byte-unmodified and
is not annotated. Cited here by filename, per the write-once law.

**Sensor:** `list_allowed_directories` from the **Chat seat**, post-connector-revival.
The world under test is the Chat seat's Filesystem connector — not Red's disk. Red
cannot read that world and did not attempt to.

---

## THE MEASUREMENT

**Allowed:** `C:\` · `D:\` · `G:\` · the UNC inbox root.

**Reads through `G:` — DENIED, both forms.** The failure is a server-side
symlink/UNC validation bug, not a permission the ruling can grant.

## THE VERDICT — listed-allowed is not readable

`G:` is **listed as allowed and unreadable in practice.** A **local-copy hop to
`C:\`** is required for any file the Chat seat must actually read.

This is the shape the Sensor Law keeps producing: *an allowlist entry is a
declaration; a successful read is an observation.* §4 of the superseded record
asserted `G:` readability as ruled-but-unmeasured, and it was right to withhold
the claim — the measurement came back the other way. Had the ruling been trusted
as a green, every Chat-seat read through `G:` would have failed at the moment it
was needed, and the ruling would have been blamed last.

## CONSEQUENCE for the transport

- The partial-staleness claim in the superseded record **stands**: the Chat seat
  *can* reach a filesystem connector.
- Its practical reach through `G:` is **zero** until the validation bug is fixed.
- The inbox-only scope is unchanged; the outbox still needs a hop.
- **Net effect today:** paste and attach remain the working transport. Nothing
  about the long-paste hazard changes.

## Cross-references

- `STOPGO_TRANSPORT_G_READSURFACE_2026-07-10.md` — the ruling this measures. Its
  §4 asked for exactly this one-line follow-up. Frozen; superseded in §4 only.
- `PROOF_ENVIRONMENT_DOCTRINE.md` — the Sensor Law. *A declaration is not an
  observation.*
- `STOPGO_CONNECTOR_INSTRUCTION_BLOCKS_2026-07-10.md` — the untrusted-data
  template `G:` inherits.
