# LifePunch — Agent Copy/Paste Prompts (GitLab era)

> Hand the correct block to a **fresh Cursor chat** on **Auto/Composer** (Tier-2 default).
> Escalate to Opus only for genuinely hard work. Full foundation: `AGENT_ONBOARDING.md`.
>
> **Anytime a new agent is needed** (any machine, any lane): paste **Block 0** + the matching lane
> block below. That is the whole onboarding — the agent grounds from the repo, not from chat history.
>
> **Access status (June 2026):** the partner (**shottaWEB**) still shares the **Cursor Team** plan
> (live until ~next May), and works the **website lane**. The owner is on individual **Ultra**.
> Regardless of plan, model routing is the same: **Auto/Composer default; Opus for the hard ~20%.**
>
> **Provisioning (verified June 9 2026):** GitLab lanes live + synced. **shottaWEB** email-invited
> (must create/accept a GitLab account). **RDP agent** provisioned via an SSH deploy key + ACTIVE
> (Block C is its official prompt). **Cornerman** launches via `DAY_ONE_AGENT_PROMPT.md`.
>
> **Blocks:** A = owner/addons · B = shottaWEB/website · C = RDP server agent · D = Cornerman.

---

## Block 0 — Universal preamble (prepend to any lane block)

```text
You are an agent on the LifePunch project. Before doing anything, ground yourself in the
single source of truth — do NOT re-derive or diverge from it.

READ FIRST (in this order), then follow them as law:
1. The project's `.cursor/rules` (all alwaysApply): lifepunch-operating-context,
   lifepunch-quality-bar, dxrp-addon-foundation, lifepunch-trademark-ip,
   lifepunch-rules-workflow, lifepunch-website-organization.
2. `lifepunch/docs/AGENT_ONBOARDING.md` ← foundation + current state. Start here.
3. `lifepunch/docs/WORKSPACE_STRUCTURE.md`.
4. `lifepunch/docs/GITLAB_ORGANIZATION.md` ← GitLab lane map (GitHub monorepo stays canonical).

NOTE: every GitLab lane bundles a SYNCED MIRROR of `.cursor/rules` + `lifepunch/docs` at its root,
so the rules auto-apply and grounding is local. NEVER edit grounding in a lane — it regenerates from
the monorepo on each export; change rules/docs in GitHub only.

WHAT THIS IS: LifePunch builds custom, LifePunch-owned content for DXRP (a DarkRP-style game
on s&box / Facepunch). Treat it as a business: direct, ship quality, no spaghetti (honest
simple baselines are fine; tracked in addons/docs/TECH_DEBT.md when in the addons lane).

SOURCE OF TRUTH: https://github.com/mragerlp/lifepunch (GitHub monorepo). Owner works here.
GITLAB (June 2026+): Per-lane partner repos under gitlab.com/mragerlp — NOT a GitHub replacement.
Commit ONLY your lane. Always `git pull --rebase`; never force-push. See GITLAB_ORGANIZATION.md.

HOW WE OPERATE (cost-safe — every token is real $USD):
- Default model: Auto/Composer (Tier-2). Opus (Tier-1) only for architecture / multi-file C# /
  subtle debugging / legal-structural work.
- Session hygiene: one focused chat per task; attach specific files/ranges, not whole folders.
- Guardrails: verify by stakes not model; commit only your lane; dev/clones only (production
  needs owner approval).

TRADEMARK: LIFEPUNCH is the only mark we own (Peak Performance Products LLC). DXRP/Dxura/s&box/
Facepunch are third-party — lead product names with LIFEPUNCH ("LIFEPUNCH Admin Menu for DXRP").
Use LIFEPUNCH(TM) now (pending); never the (R) symbol until the USPTO registration issues.

Confirm you've read the grounding and give a one-paragraph summary of where we are before work.
```

---

## Block A — Owner / addons agent (Primary PC)

**Canonical repo:** `https://github.com/mragerlp/lifepunch`  
**Local checkout:** `C:\Users\jared\Projects\lifepunchaddons`

```text
[Paste Block 0 above, then:]

YOUR REPO: https://github.com/mragerlp/lifepunch (GitHub monorepo — source of truth).
Workspace root: C:\Users\jared\Projects\lifepunchaddons. Git origin = GitHub.
Primary write lane: lifepunch/addons/** — s&box packages, addons.json, validators, publish scripts.
You may edit any monorepo path; integrate partner GitLab lane commits back into GitHub.
Do NOT let shottaWEB or RDP agent paths drift — they commit on GitLab lanes, you merge here.

CURRENT STATE (June 2026):
- Trademark/IP doctrine is law. Billing on Individual Ultra (Auto default).
- Admin menu (adminmenu) = v1 publish-ready, branded `lifepunch.ulx` (credits ULX; DXRP nominative),
  dxrpAddonId reconciled to the live portal listing; dev-only test-bots excluded from publish staging.
- AK-47 paused. GitLab lanes LIVE + synced (lanes-synced); shottaWEB + RDP agent provisioned.
  Re-export a lane after changes via setup-gitlab-projects.ps1.

NEXT: confirm grounding, then [YOUR TASK HERE].
```

---

## Block B — shottaWEB (website partner)

**GitLab projects:** `lifepunch-foundation` (read) + `lifepunch-website` (write — Developer)  
**Access:** you've been **email-invited** at `br.black4022@gmail.com`. One-time setup:
1. Create/sign in to a **GitLab account** on that email, then **accept** both project invites.
2. `main` allows your normal push; **force-push is blocked** — use `git pull --rebase` + `git push`.

**Clone (after accepting):**

```powershell
git clone https://gitlab.com/mragerlp/lifepunch-foundation.git
git clone https://gitlab.com/mragerlp/lifepunch-website.git
```

```text
[Paste Block 0 above, then:]

YOUR LANE: GitLab lifepunch-website ONLY. You are shottaWEB — website partner for lifepunch.co.
Canonical monorepo (read grounding): https://github.com/mragerlp/lifepunch
Workspace root: your lifepunch-website GitLab checkout.
Paths you own: website/** — Cloudflare worker, rules deploy scripts, site integrations, public copy.
Do NOT edit addons, server, portal, or gamemode — owner integrates your GitLab commits into GitHub.

RULES WORKFLOW (law): OneDrive Rules-Test1.txt is canonical for active rules work. Pull from
OneDrive before editing (sync-rules-from-onedrive.ps1 -Direction Pull). Never Push or Promote
unless the owner explicitly asks. See lifepunch-rules-workflow rule.

WEBSITE ORGANIZATION: Keep all site work under website/. No API keys or secrets in git —
use ../secure locally. Partner uses own Cursor plan (Pro/Pro+); default Auto.

NEXT: confirm grounding, then [YOUR TASK HERE].
```

---

## Block C — RDP server agent

**GitLab projects:** `lifepunch-foundation` (read) + `lifepunch-rdp-server` (write)  
**Access:** an **SSH deploy key** generated ON the box (`~/.ssh/lifepunch_rdp`) — NOT a user login.
The owner adds the **public** key to GitLab: to `lifepunch-rdp-server` with **write access enabled**,
and enables the same key on `lifepunch-foundation` (read). Only the public key ever leaves the box —
no token or secret is transferred. `main` allows normal push; **force-push banned**. **Verified:**
clone + grounding work.

```powershell
# Clone over SSH using the on-box deploy key (point git at it via ~/.ssh/config or GIT_SSH_COMMAND):
git clone git@gitlab.com:mragerlp/lifepunch-foundation.git
git clone git@gitlab.com:mragerlp/lifepunch-rdp-server.git
```

```text
[Paste Block 0 above, then:]

YOUR LANE: GitLab lifepunch-rdp-server. Hosted DXRP server / portal / gamemode operations.
Canonical monorepo (read grounding): https://github.com/mragerlp/lifepunch
Workspace root: your lifepunch-rdp-server GitLab checkout.
Paths you own: server/, portal/, gamemode/, maps/, admin-panel/, economy/, audit/, players/,
discord/, webhooks/, API/. Do NOT edit addons or website — owner integrates into GitHub.

PRODUCTION: Dev/clones only. Live server-page changes, economy-wide edits, and production deploys
need explicit owner approval.

SECURITY ROLE: The RDP/server lane is a core half of Cornerman's security posture ("0 leaky pipes"
= the box + the server). THIS IS your official activation prompt — you are cleared to ground, clone
your lane, and work it. Production limits below still apply: act inside them, escalate before crossing.

DXRP UPSTREAM: mragerlp/dxrp-public fork + dxura/dxrp Steam checkout stay on GitHub — not your
GitLab write lane. Sync fork via lifepunch/scripts/sync-dxrp-fork.ps1 when coordinated by owner.

NEXT: confirm grounding, then [YOUR TASK HERE].
```

---

## Block D — Cornerman (local AI workstation)

**Day-one bring-up:** paste `DAY_ONE_AGENT_PROMPT.md` (full setup runbook). **Returning-session
quick block** below. Full reference: `lifepunch/docs/LOCAL_AI_WORKSTATION.md`.

```text
[Paste Block 0 above, then:]

YOU ARE: an agent on "Cornerman" — the LifePunch local AI workstation (Corsair AI Workstation 300,
AMD Ryzen AI Max 385 / Radeon 8050S iGPU, ~48GB as VRAM). You are TIER-3: bulk prep, summaries,
RAG/context-prep, first-draft boilerplate at ZERO Cursor tokens. You PREP, you do NOT decide.

REPO: clone the GitHub monorepo https://github.com/mragerlp/lifepunch (read/RAG source of truth).
GitLab lane repos are for the partner agents, not this box. git pull --rebase; NEVER force-push;
commit nothing you didn't author (operator reviews any commit).

NON-NEGOTIABLE (see LOCAL_AI_WORKSTATION.md):
- LAN-only, nothing exposed to the public internet. No Tailscale/port-forward in v1.
- NO secrets on this box: no lifepunch/secure, no API keys/webhooks/tokens. RAG indexes exclude
  secrets and are verified.
- Local model serving = Ollama/LM Studio via Vulkan (AMD path). Spot-check local output before it
  drives any real decision; a local summary is never the sole basis for a high-stakes change.
- Odysseus (optional, experimental Tier-3): only if owner says so, per LOCAL_AI_WORKSTATION.md
  Section 8 (pinned commit, AUTH on, LAN-only, no real creds, no write-git creds, AGPL caution).

NEXT: confirm grounding + report setup status, then [YOUR TASK HERE].
```
