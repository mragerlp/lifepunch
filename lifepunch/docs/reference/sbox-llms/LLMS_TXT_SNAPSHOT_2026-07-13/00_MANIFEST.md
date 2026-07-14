# MANIFEST — s&box `llms.txt` snapshot, 2026-07-13

**Class:** REFERENCE SNAPSHOT (dated, verbatim, write-once) · **Fetched by:** Red (Claude Code Opus)
**Fetch date (UTC):** 2026-07-13
**Purpose:** local, machine-verifiable engine truth — so an s&box citation can be **checked against a
real page** instead of recalled. Serves the **local-cite fabrication law**
(`CORNERMAN_CONSULT_DOCTRINE` C-B: *every local file:line cite is machine-verified before use*) and
the `sbox-engine-truth` skill's *derive, never recall* rule.

---

## 1. SOURCE — verified live before anything was written

| | |
|---|---|
| **Index URL** | `https://sbox.game/llms.txt` |
| **HTTP status** | **200** |
| **Content-Type** | `text/plain; charset=utf-8` |
| **Index size** | **14,921 bytes** · 249 lines |
| **Page base** | `https://sbox.game/dev/doc/**` (raw markdown — the index states pages are fetchable by appending `.md`) |

**The source is what it claims to be.** It is Facepunch's own index, self-described:
> *"s&box is a game engine built on Valve's Source 2 and the latest .NET technology, developed by
> Facepunch… The engine source code is open source under the MIT License at
> `https://github.com/Facepunch/sbox-public`"*

**No source was substituted.** Per the dispatch: had it been dead or not what it claimed, this item
would have STOPPED. It was live and genuine, so it proceeded.

## 2. WHAT WAS PULLED

| | |
|---|---|
| **Doc pages fetched** | **234 / 234** — `/dev/doc/**.md` |
| **Failures** | **0** |
| **Doc bytes** | **601,357** |
| **Total incl. index** | **616,278 bytes** · **235 files** |

Directory layout **mirrors the official URL paths** — `dev/doc/<path>.md` maps 1:1 to
`https://sbox.game/dev/doc/<path>.md`. Any file here is re-verifiable against its live URL by
reconstructing that path.

## 3. EXCLUSIONS — reported, not silent

- **`/api`** — the single non-`.md` link in the index (*"Browse the s&box API by type and
  namespace"*). It is an **interactive API browser, not a markdown document**. There is no verbatim
  page to snapshot, so **it was excluded.** The **live API browser and reflection remain the source
  of truth for API surface** — this snapshot is documentation, **not an API reference**, and it must
  never be cited as one.
- **Nothing else was excluded.** The `/dev/doc/**` tree was pulled **complete**, bounded strictly to
  the official `sbox.game` host. No third-party, community, or inferred sources were included.

## 4. INTEGRITY CHECKS (a 200 is not proof of content)

- **HTML/SPA-shell scan:** all 234 `.md` files checked for `<!DOCTYPE` / `<html>`. **Zero hits** — no
  error page is wearing a `.md` name.
- **Short-file audit:** 7 files are under 100 bytes. **Each was opened and confirmed a genuine
  upstream section stub**, not a truncated fetch — e.g. `rendering/shader-graph.md` is literally
  `# Shader Graph` with no body. **They are short upstream, not broken here.**
  *(A byte count alone cannot tell "short" from "failed." They were read.)*

## 5. HOW TO USE IT — and its limits

**This is a DATED SNAPSHOT, not a live mirror.** It is truth **as of 2026-07-13** and **it will
rot.** s&box moves.

- ✅ **Cite it** for engine documentation, and say which snapshot you cited.
- ✅ **Machine-verify** an s&box claim against a real page here instead of recalling one.
- ❌ **Never** treat it as the current API surface — **reflection and the live editor win**, always
  (`sbox-engine-truth`: *derive, never recall*).
- ❌ **Never** let it override the **runtime**. A doc page is a static sensor. It proves nothing about
  what the editor is running (`lifepunch-editor-gate`).

**Refreshing** = a **new dated snapshot directory**, never an edit to this one. Write-once.

FROM: Red (Claude Code Opus)
