# LIFEPUNCH CONTENT PIPELINE — Blender->s&box + cosmetics (2026-07-19)

LIFEPUNCH game-content ideas/tools surfaced during the armor gather. DIFFERENT TRACK from the Cavelux armor (content, not MCP infra) — but captured so they're not lost. Some are ACTIVE needs, some horizon.

## ACTIVE NEED — the Blender(.blend) -> s&box pipeline (unblocks stuck assets)
PROBLEM: animations + colors/materials trapped in .blend files with no clean path into s&box (rigging/skinning/VMDL + material transfer is the wall).
TOOLS (both zeljkovranjes/notpointless lineage, proven elite s&box builders):
- zeljkovranjes/auto-rigger (PUBLIC repo) — in-editor pure-C# deep-learning auto-rigger: 7 neural models turn any mesh -> skinned FBX + VMDL, live joint-editing preview, optional vast.ai cloud rigging. Fixes MESH + RIG + SKINNING -> VMDL (the s&box model format).
- notpointless Humanoid Retargeter + Mixamo importer (s&box workshop packages, first-party distributed) — maps existing animations onto the rig. Fixes ANIMATION transfer.
- Together: .blend -> rigged, animated s&box model.
CAVEAT (honest): auto-rigger does RIG, not materials. COLORS/MATERIALS are an ADJACENT step — s&box uses VMAT (its own material/shader system); Blender materials don't auto-carry; re-author/import into s&box format (slang/shader fork may help here). Don't expect one tool to do rig+anim+color.

## HORIZON — cosmetics / donor purchasables
- Animated tag effects (ref: CoD:WaW clan-tag effects — gold shimmer, flames, glitch, gradient). Donor-Law compliant (social/QoL only, zero power). Cash or $LP purchasables. Lands in the CUSTOMIZE tab (already designed). zeljkovranjes-class s&box shader/UI effects = proven feasible.

## NOTE — zeljkovranjes = top s&box capability-sensor
Keeps demonstrating the CEILING of what's possible in s&box (sbox-mcp, auto-rigger, shader effects). Not a dependency — proof the hard s&box things you want are ACHIEVABLE. Watch what he ships. His honesty (built self-hosted Ory, then said "don't, use hosted") = high-signal source.

## LANE NOTE
This is LIFEPUNCH content, a different track than the Cavelux armor build. The armor (eye + s&box competence + these tools) is eventually what helps an agent RUN pipelines like this — so it's a preview of the armor's payoff, not off-mission. But conscious lane-shift: content vs infra.

FROM: Fable (Jarvis), 2026-07-19.
