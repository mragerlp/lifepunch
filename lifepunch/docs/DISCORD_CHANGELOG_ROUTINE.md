# Discord changelog routine (end of workday)

**Owner:** Mr. Rager posts manually to Discord — no webhook automation yet.  
**Agent duty:** At natural end-of-session (or when owner says "changelog"), produce one `diff`-fenced block for copy-paste.

---

## Scope (player-facing only)

- **Addons:** DXRP in-game tweaks — entities, jobs, economy, UI, sounds, placement.
- **Editor:** s&box playtest tooling, dev spawn helpers, ModelDoc milestones (only if players would notice downstream).
- **Website:** lifepunch.co / rules / portal listing changes players see.

**Exclude:** Cornerman/LM Studio, git, trademark filings, internal scripts, third-party study audits.

---

## Format

```diff
Addons:
+ <addition>
- <removal or breaking change>

Editor:
+ <tooling players benefit from indirectly>

Website:
+/- <site change>
```

Use `+` for additions/improvements, `-` for removals/adjustments. Keep each line one short sentence. Lead with **LIFEPUNCH** or feature name where it helps recognition.

---

## Agent checklist before posting

1. Scan today's commits / session summary for **shippable** player-visible deltas.
2. Do not leak third-party names, study paths, or internal hostnames.
3. If nothing player-visible shipped, say so — owner may skip posting.
4. Save draft to `lifepunch/docs/handoff/DISCORD_CHANGELOG_LATEST.md` (overwrite each session).
