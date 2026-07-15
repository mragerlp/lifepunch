# `comms/STATUS.json` SCHEMA AND CHECKPOINT CONTRACT

**Contract version: v1.1 (2026-07-15).** v1.1 adds `OPENCODE` and `CURSOR` to the
`inFlightSeats` enum; producer ownership and every other field contract remain unchanged.

## Producer checklist

- [ ] Red writes `C:\lifepunch\comms\STATUS.json` at every arc close and before every handoff.
- [ ] Read Git state and BOARD through EOF immediately before generation.
- [ ] Populate `headSha`, `branch`, and `dirtyFiles` from Red's actual canonical tree.
- [ ] Populate `openRulings` only from explicit unresolved ruling records; never infer.
- [ ] Populate `inFlightSeats` only from Bloodwave's explicit current seat-state words; absence of lane files is not status.
- [ ] Populate `lastBoardSeqPerSeat` from the latest non-colliding per-seat BOARD/file census.
- [ ] Use Red's real UTC clock and `generatedBy: "RED"`.
- [ ] Validate against the schema, replace the prior file atomically, then parse/read back the committed bytes.
- [ ] On failure, preserve the last valid STATUS file, report loudly, and do not claim a new checkpoint.

## Normative JSON Schema

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "lifepunch/docs/cvl/STATUS_JSON_SCHEMA.md#status-json-v1.1",
  "title": "LIFEPUNCH CVL machine-state checkpoint v1.1",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "headSha",
    "branch",
    "dirtyFiles",
    "openRulings",
    "inFlightSeats",
    "lastBoardSeqPerSeat",
    "generatedAtUtc",
    "generatedBy"
  ],
  "properties": {
    "headSha": {
      "type": "string",
      "pattern": "^[0-9a-f]{40}$"
    },
    "branch": {
      "type": "string",
      "minLength": 1
    },
    "dirtyFiles": {
      "type": "array",
      "uniqueItems": true,
      "items": { "type": "string", "minLength": 4 }
    },
    "openRulings": {
      "type": "array",
      "uniqueItems": true,
      "items": { "type": "string", "minLength": 1 }
    },
    "inFlightSeats": {
      "type": "array",
      "uniqueItems": true,
      "items": {
        "type": "string",
        "enum": ["FABLE", "RED", "CODEX", "GREEN", "OPENCODE", "CURSOR"]
      }
    },
    "lastBoardSeqPerSeat": {
      "type": "object",
      "additionalProperties": false,
      "required": ["FABLE", "RED", "CODEX", "GREEN"],
      "properties": {
        "FABLE": { "type": "integer", "minimum": 0 },
        "RED": { "type": "integer", "minimum": 0 },
        "CODEX": { "type": "integer", "minimum": 0 },
        "GREEN": { "type": "integer", "minimum": 0 }
      }
    },
    "generatedAtUtc": {
      "type": "string",
      "format": "date-time",
      "pattern": "Z$"
    },
    "generatedBy": {
      "const": "RED"
    }
  }
}
```

## Field contract

- [ ] `headSha`: full lowercase 40-hex SHA of Red's `HEAD` at generation.
- [ ] `branch`: exact checked-out branch name; detached HEAD is a generation fault unless Bloodwave explicitly ruled it.
- [ ] `dirtyFiles`: exact sorted, unique lines from `git status --porcelain=v1 --untracked-files=all`, preserving the two status columns and repo-relative path; `/` is the path separator.
- [ ] `openRulings`: stable record identifier/path plus short title for each explicitly unresolved ruling. An empty list means Red was given an explicit no-open-rulings state; it is not guessed.
- [ ] `inFlightSeats`: seats Bloodwave explicitly declared active at generation. Representable values are `FABLE`, `RED`, `CODEX`, `GREEN`, `OPENCODE`, and `CURSOR`. Bloodwave is not a seat. Empty means an explicit none-active state, not silence.
- [ ] `lastBoardSeqPerSeat`: greatest integrity-clean filed SEQ observed for each seat; `0` means no valid sequence observed. A collision or unresolved gap blocks generation.
- [ ] `generatedAtUtc`: Red's system UTC in RFC 3339 form ending in `Z`.
- [ ] `generatedBy`: literal `RED`.

## Consumer checklist

- [ ] Validate before use; schema failure is `BOOT-FAULT`.
- [ ] Treat STATUS as a checkpoint, not a heartbeat.
- [ ] Use `lastBoardSeqPerSeat` to find BOARD/file events appended after the checkpoint.
- [ ] Treat BOARD append-order, not timestamps, as authoritative ordering.
- [ ] Never infer liveness from a file's presence or absence.
- [ ] Repository `CLAUDE.md`, valid STATUS, and BOARD deltas outrank narrative `FABLE_STATE.md` on conflict.
- [ ] A stale-but-valid STATUS may describe the last close/handoff; do not silently rewrite it from consumer observations.

## Illustrative shape - not current state

```json
{
  "headSha": "0000000000000000000000000000000000000000",
  "branch": "develop",
  "dirtyFiles": [],
  "openRulings": [],
  "inFlightSeats": [],
  "lastBoardSeqPerSeat": {
    "FABLE": 0,
    "RED": 0,
    "CODEX": 0,
    "GREEN": 0
  },
  "generatedAtUtc": "2026-01-01T00:00:00Z",
  "generatedBy": "RED"
}
```
