# LIFEPUNCH — Mission

> **Owner of the purpose layer.** This doc owns the *why*. It states the goal, the strategic logic of the two lanes, and the differentiation. It does **not** restate the law (specs, paths, lanes-as-operations, forbidden lists) — that lives in the canon docs indexed by `START_HERE_AGENTS.md`. Read this first to know *what we're doing and why*; read the law to know *how*.

## The goal

**Prove the game and lead the community.**

DXRP — Dxura's Source 2 successor to Garry's Mod DarkRP, running on s&box — went from two full servers to near-empty. The diagnosis is content. Dimmer builds the *game*; he can't also build the *content* that proves it's worth playing.

LIFEPUNCH does two things at once, and they are the mission:
1. **Prove DXRP-on-s&box is worth playing** — by shipping the proprietary content that draws players back to the game mode at all.
2. **Lead the community** — be and remain the most prestigious, most-played community running DXRP.

These are one objective. Proving the game is how we lead the community; leading the community is what gives us the reach to prove the game.

## Why the two lanes both matter

LIFEPUNCH works in two lanes. They are not parallel businesses — they are two moves in one game, and each makes the other stronger.

- **Upstream (official / Dimmer):** contributing to DXRP core strengthens the game LIFEPUNCH leads. Our servers only matter if the game underneath them thrives. Every upstream bounty protects the foundation our own business stands on. This is not charity or credibility-farming — it is foundation maintenance.
- **Proprietary (LIFEPUNCH content):** the prestige content nobody else has is the **moat** — the reason players choose LIFEPUNCH over any other DXRP host.

Each lane compounds the other: leading the community gives us the reach to prove the game; contributing to the game keeps the platform worth leading.

**This is why the lanes must never contaminate each other.** The separation is not bureaucracy — it is what keeps both lanes valuable. Proprietary content leaking upstream gives away the moat. Upstream work depending on proprietary additions breaks when Dimmer pulls it, damaging the foundation. Keeping the lanes clean *is* the strategy working.

## The differentiation: quality is the moat

Out-shipping every other DXRP host on quality is the strategy. Not more content — *better* content. The prestige that makes players choose LIFEPUNCH is earned by shipping work good enough that other hosts can't match it. Quality-as-moat is why the engineering quality bar exists, why we ship the stable baseline before the impressive one ("box before bones"), and why we verify against reality instead of asserting.

> This is the *strategic* sense of quality — the differentiation. It is distinct from (and enforced by) the engineering quality-bar rule in `.cursor/rules/`.

## The integrity test (named)

Both lanes begin from a clean, vanilla, latest-state DXRP pull. The lane is defined by **destination and ownership**, not by game name — both lanes are DXRP.

Every piece of work must pass one test:

> **"Would this survive a clean vanilla DXRP pull?"**

- **LIFEPUNCH (proprietary):** must survive as an *additive layer* on vanilla DXRP — it layers on top, never modifies core, ships as an addon to the DXRP portal, stays compatible with vanilla.
- **Upstream (official):** must *be* clean DXRP plus the contribution, carrying **nothing proprietary** — it modifies core and ships back to Dimmer.

If proprietary content is inseparable from core, or upstream work depends on proprietary additions, it fails the test. This test is the operational expression of "keep the lanes clean."

*For the full operational lane law, forbidden lists, and paths, see* `DXRP_CONTRIBUTOR_LANE.md` *and the canon indexed by* `START_HERE_AGENTS.md`.
