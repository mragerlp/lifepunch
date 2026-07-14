# COMMIT AUTHORSHIP — MIS-AUTHORED HISTORY: **LEAVE IT ALONE** (ruled)

**RATIFIED 2026-07-14, Bloodwave.** Word: *"leave history alone."* BOARD:
`BLOODWAVE | WORD | Three rulings on red\0036 … (3) 28 MIS-AUTHORED COMMITS = LEAVE HISTORY ALONE`.
Source record: `comms\red\0036`. Graduated to canon (and **corrected**) by `comms\red\0037`.

> **CLASS: RULED. Write-once.** Supersede with a new record; never edit in place.

---

## THE RULING

**No rewrite. No force-push. No filter-branch. No rebase of merged history.**

The mis-authored commits are **merged, published history on `develop` and `main`**. Correcting them means
**rewriting published history**, which is destructive, requires a force-push to protected branches, and
would invalidate every SHA any record in this repo cites. **Dozens of tracked canon files cite SHAs.**

> ## THE CURE IS WORSE THAN THE DISEASE. THE HISTORY STANDS.

**Any future cleanup is a deliberate, own-slice ruling — not a cleanup task, not a rider, and never a
side-effect of some other slice.**

---

## THE HARD RULE (unchanged, `CLAUDE.md`)

```
Author: mragerlp <mragerlp@gmail.com>
No AI attribution on any git surface, including PR bodies.
```

## ⚠ THE ACTUAL SCOPE — LARGER THAN FIRST REPORTED

`red\0036` reported **28** mis-authored commits. **That number is correct but it is not the whole
census.** Re-verified on `origin/develop` @ `f60874ff` (`git log --pretty="%an <%ae>" | sort | uniq -c`):

| Count | Identity | Verdict |
|---:|---|---|
| **734** | `mragerlp <mragerlp@gmail.com>` | ## **CORRECT** — the hard rule |
| **92** | `Bloodwave <mragerlp@gmail.com>` | **DEVIATES** — right email, *visible-layer* name in the author field |
| **28** | `mrragerlp <mrragerlp@lifepunch.co>` | **DEVIATES** — the `red\0036` finding |
| **13** | `mragerlp <286452925+mragerlp@users.noreply.github.com>` | **DEVIATES** — GitHub web-UI noreply address |

> **THREE of the four identities deviate from the hard rule, not one — 133 commits, not 28.**
> `red\0036` looked for the alias it was told to grep for **and found only what it grepped for.** The
> ruling ("leave history alone") **covers all of it** and is unchanged. But **the record must state the
> true scope, or the next seat who runs this census will think they have found a new defect.**

*This is the grep-shaped-hole defect: **a search finds what it was told to look for, and reports silence
about everything it never asked about.** Same family as GREEN-BY-OMISSION — the check ran, the check
passed, and the check could not see the rest.*

---

## THE LEAK IS CLOSED GOING FORWARD

**Sensor:** `git config user.name` → `mragerlp` · `git config user.email` → `mragerlp@gmail.com`.
**The live config is CLEAN.** New commits land correctly. The defect is historical, bounded, and **not
accruing.**

---

## ⚠ DO NOT "FIX" THE ALIAS IN FILES — IT IS RATIFIED CANON

**`mrragerlp` IS NOT A TYPO.** `lifepunch/docs/BLOODWAVE_ALIAS.md` ratifies a **three-layer identity**:

| Layer | Value | Where it belongs |
|---|---|---|
| **Visible** | `Bloodwave` | prose, BOARD, relays |
| **Legal / proprietary author** | `mrragerlp@lifepunch.co` | **IN THE FILES** — the IP-ownership layer |
| **Git commit identity** | `mragerlp <mragerlp@gmail.com>` | **THE AUTHOR FIELD ONLY** |

**122 tracked files carry `mrragerlp` intentionally.** A rider once fired to "fix the `mrragerlp` typo"
would have **corrupted 122 files and deleted the IP-ownership layer.** It was caught (`red\0036`) and
**nothing was changed.**

> ## THE ALIAS IS **RIGHT IN THE FILES** AND **WRONG IN THE AUTHOR FIELD**.
> These are opposite defects that look identical to a grep. **`BLOODWAVE_ALIAS.md:68` warns about exactly
> this** — that a username rename conflates the layers. **It did.**
> **Never run a repo-wide `mrragerlp` → `mragerlp` replacement. Ever.**

FROM: Red
