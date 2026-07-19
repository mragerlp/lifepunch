import pathlib

ROOT = pathlib.Path(r"C:\Users\jared\Projects\lifepunch\.tmp-cvlbrand")
p = ROOT / "index.html"
s = p.read_text(encoding="utf-8")
orig = s
EM = "\u2014"
ARR = "\u2192"
MID = "\u00b7"

def rep(old, new, count=1):
    global s
    assert s.count(old) == count, f"anchor x{s.count(old)} (want {count}): {old[:80]!r}"
    s = s.replace(old, new)

# ============ 1. JS: three-key data model ============
rep(
    'var PILLAR_KEYS = ["workflows", "knowledge", "governance", "outcomes"];\n'
    '      var CORNER_TO_PILLAR = { tl: "workflows", tr: "knowledge", bl: "governance", br: "outcomes" };',
    'var PILLAR_KEYS = ["c", "v", "l"];\n'
    '      var SEAT_TO_CARD = { "seat-c": "c", "seat-v": "v", "seat-l": "l" };'
)

rep(
    """      function pillarFromEl(el) {
        if (!el) return null;
        for (var k in CORNER_TO_PILLAR) {
          if (el.classList.contains(k)) return CORNER_TO_PILLAR[k];
        }
        var href = el.getAttribute("href") || "";
        for (var i = 0; i < PILLAR_KEYS.length; i++) {
          if (href.indexOf("#" + PILLAR_KEYS[i]) !== -1) return PILLAR_KEYS[i];
        }
        return null;
      }""",
    """      function pillarFromEl(el) {
        if (!el) return null;
        for (var k in SEAT_TO_CARD) {
          if (el.classList.contains(k)) return SEAT_TO_CARD[k];
        }
        var card = el.getAttribute("data-card") || "";
        if (PILLAR_KEYS.indexOf(card) !== -1) return card;
        return null;
      }"""
)

# Orbit angles: C=NW, V=NE, L=S (bottom-center)
rep(
    """      /*
       * True polar hang \u2014 one pillar per quadrant, one ring each.
       * Angles in canvas atan2 space (0 = east, + = clockwise/down).
       * NO column hacks. NO governance Y shove. Buttons sit on the oval.
       */
      function pillarOrbits() {
        /*
         * One primary orbit \u00b7 four equal quadrants.
         * Decorative inner rings are separate (orbitRingRadii) \u2014 buttons share the outer seat
         * so nothing looks "thrown" into empty space (Governance was the casualty of ringI:3).
         */
        return {
          workflows:  { ang: -Math.PI * 0.75 }, /* NW  135\u00b0 */
          knowledge:  { ang: -Math.PI * 0.25 }, /* NE   45\u00b0 */
          outcomes:   { ang:  Math.PI * 0.25 }, /* SE   45\u00b0 */
          governance: { ang:  Math.PI * 0.75 }  /* SW 135\u00b0 */
        };
      }""",
    """      /*
       * True polar hang \u2014 three letter seats on the orbit (V2B three-card law).
       * Angles in canvas atan2 space (0 = east, + = clockwise/down).
       */
      function pillarOrbits() {
        /*
         * One primary orbit \u00b7 C northwest, V northeast, L due south.
         * Decorative inner rings are separate (orbitRingRadii) \u2014 seats share the outer ring.
         */
        return {
          c: { ang: -Math.PI * 0.75 }, /* NW 135\u00b0 */
          v: { ang: -Math.PI * 0.25 }, /* NE  45\u00b0 */
          l: { ang:  Math.PI * 0.5 }   /* S   90\u00b0 */
        };
      }"""
)

rep(
    """      var VEIN_SIDE = {
        workflows:  -1,
        governance:  1,
        knowledge:   1,
        outcomes:   -1
      };""",
    """      var VEIN_SIDE = {
        c: -1,
        v:  1,
        l: -1
      };"""
)

rep("        /* Shared outer orbit \u2014 all four connectors sit on the same ring */",
    "        /* Shared outer orbit \u2014 all three letter seats sit on the same ring */")

# ============ 2. HTML: hero buttons + cards + pillar row ============
rep(
    '<div class="arch-map" role="navigation" aria-label="Architecture map: open System pillars">',
    f'<div class="arch-map" role="group" aria-label="Method map: the C {MID} V {MID} L cards">'
)

# tl + tr chips (adjacent lines) -> C + V buttons
old_tltr = s[s.index('<a class="arch-node tl"'):s.index('<div class="arch-hub-wrap">')]
new_ctv = (
    '<button class="arch-node seat-c" type="button" data-card="c" aria-expanded="false"'
    ' aria-controls="cvl-card-c" aria-label="C \u2014 Collaborative. Open card.">'
    '<span class="arch-letter">C</span></button>\n'
    '          <button class="arch-node seat-v" type="button" data-card="v" aria-expanded="false"'
    ' aria-controls="cvl-card-v" aria-label="V \u2014 Value. Open card.">'
    '<span class="arch-letter">V</span></button>\n'
    '          '
)
assert old_tltr.count("arch-node") == 2, "tl/tr slice wrong"
s = s.replace(old_tltr, new_ctv)

# bl + br chips -> single L button
old_blbr = s[s.index('<a class="arch-node bl"'):s.index('</div>', s.index('<a class="arch-node bl"'))]
assert old_blbr.count("arch-node") == 2, "bl/br slice wrong"
new_l = (
    '<button class="arch-node seat-l" type="button" data-card="l" aria-expanded="false"'
    ' aria-controls="cvl-card-l" aria-label="L \u2014 Loop. Open card.">'
    '<span class="arch-letter">L</span></button>\n        '
)
s = s.replace(old_blbr, new_l)

# Cards: sibling right after .arch-map closes (before .hero-grid close)
map_close_anchor = new_l + "</div>\n"
assert s.count(map_close_anchor) == 1
cards_html = map_close_anchor + f"""
        <div class="cvl-cards">
          <div class="cvl-card" id="cvl-card-c" role="region" aria-label="Collaborative" tabindex="-1" hidden>
            <p class="cvl-card-kicker">C {EM} Collaborative</p>
            <p class="cvl-card-body">Agents and humans in one loop {EM} with one human key. Your agents research, draft, build, and propose. Nothing ships, spends, or escalates without your explicit go. That&rsquo;s not a feature bolted on; it&rsquo;s the architecture.</p>
            <a class="cvl-card-link" href="/system/">How the method works {ARR}</a>
          </div>
          <div class="cvl-card" id="cvl-card-v" role="region" aria-label="Value" tabindex="-1" hidden>
            <p class="cvl-card-kicker">V {EM} Value</p>
            <p class="cvl-card-body">Judged by business outcomes {EM} counted, not claimed. Every capability we install is wired to a metric your business already cares about, with monitoring and an audit trail behind it. Evidence, not vibes.</p>
            <a class="cvl-card-link" href="/work/">See it under load {ARR}</a>
          </div>
          <div class="cvl-card" id="cvl-card-l" role="region" aria-label="Loop" tabindex="-1" hidden>
            <p class="cvl-card-kicker">L {EM} Loop</p>
            <p class="cvl-card-body">Observe {ARR} Architect {ARR} Implement {ARR} Review. Each stage closes only on your approval and feeds the next. The system improves every pass {EM} and the record survives every session, so nothing falls back into the black hole.</p>
            <a class="cvl-card-link" href="/system/">Walk the loop {ARR}</a>
          </div>
        </div>
"""
s = s.replace(map_close_anchor, cards_html)

# Pillar mono row under the hero CTA row (disambiguated by the arch-map that follows)
cta_anchor = """            <a class="btn btn-secondary" href="/system/">See how it works</a>
          </div>
        </div>

        <div class="arch-map\""""
assert s.count(cta_anchor) == 1
s = s.replace(cta_anchor, f"""            <a class="btn btn-secondary" href="/system/">See how it works</a>
          </div>
          <p class="hero-pillar-row" aria-label="System lanes">
            <a href="/system/#workflows">Workflows</a><span aria-hidden="true">{MID}</span><a href="/system/#knowledge">Knowledge</a><span aria-hidden="true">{MID}</span><a href="/system/#governance">Governance</a><span aria-hidden="true">{MID}</span><a href="/system/#outcomes">Outcomes</a>
          </p>
        </div>

        <div class="arch-map\"""")

# ============ 3. CSS: seats, letters, cards, pillar row ============
rep(
    """    /* Positions come from JS (orbit hang-off). Corner classes only set stagger. */
    .arch-node.tl,
    .arch-node.tr,
    .arch-node.br,
    .arch-node.bl {
      top: 50%;
      left: 50%;
      right: auto;
      bottom: auto;
      transform: translate(-50%, -50%);
    }
    .arch-node.tl { animation-delay: 0.4s; }
    .arch-node.tr { animation-delay: 0.52s; }
    .arch-node.bl { animation-delay: 0.64s; }
    .arch-node.br { animation-delay: 0.76s; }
    .arch-node.tl:hover,
    .arch-node.tl:focus-visible,
    .arch-node.tl.is-active,
    .arch-node.tl.is-lit,
    .arch-node.tl.is-linked,
    .arch-node.tl.is-receiving,
    .arch-node.tr:hover,
    .arch-node.tr:focus-visible,
    .arch-node.tr.is-active,
    .arch-node.tr.is-lit,
    .arch-node.tr.is-linked,
    .arch-node.tr.is-receiving,
    .arch-node.br:hover,
    .arch-node.br:focus-visible,
    .arch-node.br.is-active,
    .arch-node.br.is-lit,
    .arch-node.br.is-linked,
    .arch-node.br.is-receiving,
    .arch-node.bl:hover,
    .arch-node.bl:focus-visible,
    .arch-node.bl.is-active,
    .arch-node.bl.is-lit,
    .arch-node.bl.is-linked,
    .arch-node.bl.is-receiving {
      transform: translate(-50%, -50%) translateY(-2px) scale(1.03);
    }""",
    """    /* Positions come from JS (orbit hang-off). Seat classes only set stagger. */
    .arch-node.seat-c,
    .arch-node.seat-v,
    .arch-node.seat-l {
      top: 50%;
      left: 50%;
      right: auto;
      bottom: auto;
      transform: translate(-50%, -50%);
    }
    .arch-node.seat-c { animation-delay: 0.4s; }
    .arch-node.seat-v { animation-delay: 0.52s; }
    .arch-node.seat-l { animation-delay: 0.64s; }
    .arch-node.seat-c:hover,
    .arch-node.seat-c:focus-visible,
    .arch-node.seat-c.is-active,
    .arch-node.seat-c.is-lit,
    .arch-node.seat-c.is-linked,
    .arch-node.seat-c.is-receiving,
    .arch-node.seat-v:hover,
    .arch-node.seat-v:focus-visible,
    .arch-node.seat-v.is-active,
    .arch-node.seat-v.is-lit,
    .arch-node.seat-v.is-linked,
    .arch-node.seat-v.is-receiving,
    .arch-node.seat-l:hover,
    .arch-node.seat-l:focus-visible,
    .arch-node.seat-l.is-active,
    .arch-node.seat-l.is-lit,
    .arch-node.seat-l.is-linked,
    .arch-node.seat-l.is-receiving {
      transform: translate(-50%, -50%) translateY(-2px) scale(1.03);
    }
    /* V2B letter seats + cards */
    button.arch-node {
      appearance: none;
      -webkit-appearance: none;
      border-radius: 0;
      min-width: 3.1rem;
      min-height: 3.1rem;
      padding: 0.72rem 1.05rem;
    }
    .arch-node .arch-letter {
      font-size: 1.45em;
      font-weight: 600;
      line-height: 1;
      letter-spacing: 0;
    }
    .cvl-cards { display: contents; }
    .cvl-card {
      position: absolute;
      z-index: 6;
      left: 50%;
      bottom: 4%;
      transform: translateX(-50%);
      width: min(26rem, 92%);
      padding: 1rem 1.15rem 1.1rem;
      border: 1px solid rgba(146, 250, 17, 0.4);
      border-radius: 0;
      background: rgba(5, 7, 5, 0.96);
      box-shadow: 0 0 32px rgba(0, 0, 0, 0.55);
      text-align: left;
      animation: cvlCardIn 0.22s ease both;
    }
    .cvl-card:focus { outline: none; }
    .cvl-card-kicker {
      margin: 0 0 0.5rem;
      font-family: var(--cvl-mono);
      font-size: 0.74rem;
      font-weight: 600;
      letter-spacing: 0.1em;
      text-transform: uppercase;
      color: var(--cvl-lime);
    }
    .cvl-card-body {
      margin: 0 0 0.7rem;
      font-size: 0.92rem;
      line-height: 1.6;
      color: var(--cvl-ink-dim);
    }
    .cvl-card-link {
      font-family: var(--cvl-mono);
      font-size: 0.78rem;
      font-weight: 600;
      letter-spacing: 0.05em;
      text-transform: uppercase;
      color: var(--cvl-lime);
      text-decoration: none;
    }
    .cvl-card-link:hover,
    .cvl-card-link:focus-visible {
      text-decoration: underline;
      outline: none;
    }
    @keyframes cvlCardIn {
      from { opacity: 0; transform: translateX(-50%) translateY(6px); }
      to { opacity: 1; transform: translateX(-50%) translateY(0); }
    }
    .hero-pillar-row {
      margin: 1.1rem 0 0;
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      gap: 0.55rem;
      font-family: var(--cvl-mono);
      font-size: 0.72rem;
      letter-spacing: 0.08em;
      text-transform: uppercase;
      color: var(--cvl-muted);
    }
    .hero-pillar-row a {
      color: var(--cvl-muted);
      text-decoration: none;
      transition: color 0.18s ease;
    }
    .hero-pillar-row a:hover,
    .hero-pillar-row a:focus-visible {
      color: var(--cvl-lime);
      outline: none;
    }"""
)

# Reduced motion: kill card entrance + pillar row rise
rep(
    """      .arch-hub-wrap,
      .arch-hub,
      .arch-node,
      .arch-scan,
      .hero-scan::before {
        animation: none !important;
        opacity: 1 !important;
        transition-duration: 100ms !important;
      }""",
    """      .arch-hub-wrap,
      .arch-hub,
      .arch-node,
      .cvl-card,
      .hero-pillar-row,
      .arch-scan,
      .hero-scan::before {
        animation: none !important;
        opacity: 1 !important;
        transition-duration: 100ms !important;
      }"""
)

# Small-hero media block seat positions (~1589)
rep(
    """      .arch-node.tl { top: 14%; left: 20%; right: auto; transform: translateX(-50%); }
      .arch-node.tr { top: 40%; right: 1%; left: auto; transform: translateY(-50%); }
      .arch-node.bl { top: 56%; left: 1%; right: auto; transform: translateY(-50%); }
      .arch-node.br { bottom: 12%; top: auto; left: 74%; right: auto; transform: translateX(-50%); }""",
    """      .arch-node.seat-c { top: 16%; left: 18%; right: auto; transform: translateX(-50%); }
      .arch-node.seat-v { top: 16%; right: 4%; left: auto; transform: translateX(-50%); }
      .arch-node.seat-l { bottom: 10%; top: auto; left: 50%; right: auto; transform: translateX(-50%); }"""
)

# Home entrance delays (~1810)
rep(
    """    /* Chips arrive last \u2014 after the veins have grown out to meet them */
    body[data-page="home"] .arch-node.tl { animation-duration: 1.3s !important; animation-delay: 4.6s !important; }
    body[data-page="home"] .arch-node.tr { animation-duration: 1.3s !important; animation-delay: 4.9s !important; }
    body[data-page="home"] .arch-node.bl { animation-duration: 1.3s !important; animation-delay: 5.2s !important; }
    body[data-page="home"] .arch-node.br { animation-duration: 1.3s !important; animation-delay: 5.5s !important; }""",
    """    /* Letters arrive last \u2014 after the veins have grown out to meet them */
    body[data-page="home"] .arch-node.seat-c { animation-duration: 1.3s !important; animation-delay: 4.6s !important; }
    body[data-page="home"] .arch-node.seat-v { animation-duration: 1.3s !important; animation-delay: 4.9s !important; }
    body[data-page="home"] .arch-node.seat-l { animation-duration: 1.3s !important; animation-delay: 5.2s !important; }"""
)

# Desktop CSS orbit seats (~1823)
rep(
    """    /* CSS orbit seats \u2014 desktop + mobile (override JS hang-off) */
    body[data-page="home"] .arch-node.tl,
    body[data-page="home"] .arch-node.tr,
    body[data-page="home"] .arch-node.bl,
    body[data-page="home"] .arch-node.br {
      right: auto !important;
      bottom: auto !important;
      transform: translate(-50%, -50%) !important;
    }
    body[data-page="home"] .arch-node.tl {
      top: calc(50% - var(--arch-r, 32%)) !important;
      left: calc(50% - var(--arch-r, 32%)) !important;
    }
    body[data-page="home"] .arch-node.tr {
      top: calc(50% - var(--arch-r, 32%)) !important;
      left: calc(50% + var(--arch-r, 32%)) !important;
    }
    body[data-page="home"] .arch-node.bl {
      top: calc(50% + var(--arch-r, 32%)) !important;
      left: calc(50% - var(--arch-r, 32%)) !important;
    }
    body[data-page="home"] .arch-node.br {
      top: calc(50% + var(--arch-r, 32%)) !important;
      left: calc(50% + var(--arch-r, 32%)) !important;
    }""",
    """    /* CSS orbit seats \u2014 desktop + mobile (override JS hang-off) */
    body[data-page="home"] .arch-node.seat-c,
    body[data-page="home"] .arch-node.seat-v,
    body[data-page="home"] .arch-node.seat-l {
      right: auto !important;
      bottom: auto !important;
      transform: translate(-50%, -50%) !important;
    }
    body[data-page="home"] .arch-node.seat-c {
      top: calc(50% - var(--arch-r, 32%)) !important;
      left: calc(50% - var(--arch-r, 32%)) !important;
    }
    body[data-page="home"] .arch-node.seat-v {
      top: calc(50% - var(--arch-r, 32%)) !important;
      left: calc(50% + var(--arch-r, 32%)) !important;
    }
    body[data-page="home"] .arch-node.seat-l {
      top: calc(50% + var(--arch-r, 32%)) !important;
      left: 50% !important;
    }"""
)

# Desktop grouped hover translate (~1883)
old_desktop_hover = """    body[data-page="home"] .arch-node.tl:hover,
    body[data-page="home"] .arch-node.tl:focus-visible,
    body[data-page="home"] .arch-node.tl.is-active,
    body[data-page="home"] .arch-node.tl.is-lit,
    body[data-page="home"] .arch-node.tl.is-linked,
    body[data-page="home"] .arch-node.tl.is-receiving,
    body[data-page="home"] .arch-node.tr:hover,
    body[data-page="home"] .arch-node.tr:focus-visible,
    body[data-page="home"] .arch-node.tr.is-active,
    body[data-page="home"] .arch-node.tr.is-lit,
    body[data-page="home"] .arch-node.tr.is-linked,
    body[data-page="home"] .arch-node.tr.is-receiving,
    body[data-page="home"] .arch-node.br:hover,
    body[data-page="home"] .arch-node.br:focus-visible,
    body[data-page="home"] .arch-node.br.is-active,
    body[data-page="home"] .arch-node.br.is-lit,
    body[data-page="home"] .arch-node.br.is-linked,
    body[data-page="home"] .arch-node.br.is-receiving,
    body[data-page="home"] .arch-node.bl:hover,
    body[data-page="home"] .arch-node.bl:focus-visible,
    body[data-page="home"] .arch-node.bl.is-active,
    body[data-page="home"] .arch-node.bl.is-lit,
    body[data-page="home"] .arch-node.bl.is-linked,
    body[data-page="home"] .arch-node.bl.is-receiving {
      transform: translate(-50%, -50%) translateY(-1px) scale(1.03) !important;
    }"""
new_desktop_hover = """    body[data-page="home"] .arch-node.seat-c:hover,
    body[data-page="home"] .arch-node.seat-c:focus-visible,
    body[data-page="home"] .arch-node.seat-c.is-active,
    body[data-page="home"] .arch-node.seat-c.is-lit,
    body[data-page="home"] .arch-node.seat-c.is-linked,
    body[data-page="home"] .arch-node.seat-c.is-receiving,
    body[data-page="home"] .arch-node.seat-v:hover,
    body[data-page="home"] .arch-node.seat-v:focus-visible,
    body[data-page="home"] .arch-node.seat-v.is-active,
    body[data-page="home"] .arch-node.seat-v.is-lit,
    body[data-page="home"] .arch-node.seat-v.is-linked,
    body[data-page="home"] .arch-node.seat-v.is-receiving,
    body[data-page="home"] .arch-node.seat-l:hover,
    body[data-page="home"] .arch-node.seat-l:focus-visible,
    body[data-page="home"] .arch-node.seat-l.is-active,
    body[data-page="home"] .arch-node.seat-l.is-lit,
    body[data-page="home"] .arch-node.seat-l.is-linked,
    body[data-page="home"] .arch-node.seat-l.is-receiving {
      transform: translate(-50%, -50%) translateY(-1px) scale(1.03) !important;
    }"""
rep(old_desktop_hover, new_desktop_hover)

# Mobile seats (~2456)
rep(
    """      /* Corner seats on a tight diamond \u2014 override JS hang-off */
      body[data-page="home"] .arch-node.tl,
      body[data-page="home"] .arch-node.tr,
      body[data-page="home"] .arch-node.bl,
      body[data-page="home"] .arch-node.br {
        right: auto !important;
        bottom: auto !important;
        transform: translate(-50%, -50%) scale(var(--arch-chip-scale)) !important;
      }
      body[data-page="home"] .arch-node.tl {
        top: calc(50% - var(--arch-r)) !important;
        left: calc(50% - var(--arch-r)) !important;
      }
      body[data-page="home"] .arch-node.tr {
        top: calc(50% - var(--arch-r)) !important;
        left: calc(50% + var(--arch-r)) !important;
      }
      body[data-page="home"] .arch-node.bl {
        top: calc(50% + var(--arch-r)) !important;
        left: calc(50% - var(--arch-r)) !important;
      }
      body[data-page="home"] .arch-node.br {
        top: calc(50% + var(--arch-r)) !important;
        left: calc(50% + var(--arch-r)) !important;
      }""",
    """      /* Letter seats on a tight triangle \u2014 override JS hang-off */
      body[data-page="home"] .arch-node.seat-c,
      body[data-page="home"] .arch-node.seat-v,
      body[data-page="home"] .arch-node.seat-l {
        right: auto !important;
        bottom: auto !important;
        transform: translate(-50%, -50%) scale(var(--arch-chip-scale)) !important;
      }
      body[data-page="home"] .arch-node.seat-c {
        top: calc(50% - var(--arch-r)) !important;
        left: calc(50% - var(--arch-r)) !important;
      }
      body[data-page="home"] .arch-node.seat-v {
        top: calc(50% - var(--arch-r)) !important;
        left: calc(50% + var(--arch-r)) !important;
      }
      body[data-page="home"] .arch-node.seat-l {
        top: calc(50% + var(--arch-r)) !important;
        left: 50% !important;
      }
      body[data-page="home"] .cvl-card {
        position: static !important;
        transform: none !important;
        width: 100% !important;
        margin-top: 0.85rem;
      }
      body[data-page="home"] .cvl-cards { display: block; width: 100%; }""",
)

# Mobile grouped hover (~2480)
old_mobile_hover = old_desktop_hover.replace("    body", "      body").replace(
    "      transform: translate(-50%, -50%) translateY(-1px) scale(1.03) !important;\n    }",
    "        transform: translate(-50%, -50%) scale(calc(var(--arch-chip-scale) * 1.04)) translateY(-1px) !important;\n      }")
new_mobile_hover = new_desktop_hover.replace("    body", "      body").replace(
    "      transform: translate(-50%, -50%) translateY(-1px) scale(1.03) !important;\n    }",
    "        transform: translate(-50%, -50%) scale(calc(var(--arch-chip-scale) * 1.04)) translateY(-1px) !important;\n      }")
rep(old_mobile_hover, new_mobile_hover)

# Pillar row entrance: piggyback the CTA rise + reduce guard
rep(
    """    body[data-page="home"] .hero .cta-row {
      animation: cvlRiseIn 1.3s cubic-bezier(0.22, 1, 0.36, 1) 0.95s both;
    }""",
    """    body[data-page="home"] .hero .cta-row {
      animation: cvlRiseIn 1.3s cubic-bezier(0.22, 1, 0.36, 1) 0.95s both;
    }
    body[data-page="home"] .hero-pillar-row {
      animation: cvlRiseIn 1.3s cubic-bezier(0.22, 1, 0.36, 1) 1.1s both;
    }"""
)
rep(
    """      body[data-page="home"] .hero-brand-stack,
      body[data-page="home"] .hero h1,
      body[data-page="home"] .hero-lead,
      body[data-page="home"] .hero .cta-row {
        animation: none !important;
      }""",
    """      body[data-page="home"] .hero-brand-stack,
      body[data-page="home"] .hero h1,
      body[data-page="home"] .hero-lead,
      body[data-page="home"] .hero .cta-row,
      body[data-page="home"] .hero-pillar-row {
        animation: none !important;
      }"""
)

# ============ 4. JS: card open/close controller ============
hero_iife_end = """      raf = requestAnimationFrame(draw);
    })();

    /* Engagement loop \u2014 stage \u2192 PCB feeder into AI chip; chip lights on hover + finish */"""
assert s.count(hero_iife_end) == 1
card_js = """      raf = requestAnimationFrame(draw);
    })();

    /* V2B three-card law \u2014 C\u00b7V\u00b7L letter seats open their method cards */
    (function () {
      var map = document.querySelector(".arch-map");
      if (!map) return;
      var btns = Array.prototype.slice.call(map.querySelectorAll(".arch-node[data-card]"));
      if (!btns.length) return;
      var openId = null;

      function cardFor(id) { return document.getElementById("cvl-card-" + id); }
      function btnFor(id) {
        for (var i = 0; i < btns.length; i++) {
          if (btns[i].getAttribute("data-card") === id) return btns[i];
        }
        return null;
      }

      function closeCard(refocus) {
        if (!openId) return;
        var card = cardFor(openId);
        var btn = btnFor(openId);
        if (card) card.hidden = true;
        if (btn) {
          btn.setAttribute("aria-expanded", "false");
          btn.classList.remove("is-active");
          if (refocus) btn.focus();
        }
        openId = null;
      }

      function openCard(id) {
        if (openId === id) { closeCard(false); return; }
        closeCard(false);
        var card = cardFor(id);
        var btn = btnFor(id);
        if (!card || !btn) return;
        card.hidden = false;
        btn.setAttribute("aria-expanded", "true");
        btn.classList.add("is-active");
        openId = id;
        card.focus({ preventScroll: true });
      }

      btns.forEach(function (btn) {
        btn.addEventListener("click", function () {
          openCard(btn.getAttribute("data-card"));
        });
      });

      document.addEventListener("keydown", function (e) {
        if (e.key === "Escape" && openId) closeCard(true);
      });

      document.addEventListener("click", function (e) {
        if (!openId) return;
        var card = cardFor(openId);
        var inCard = card && card.contains(e.target);
        var onBtn = e.target.closest && e.target.closest(".arch-node[data-card]");
        if (!inCard && !onBtn) closeCard(false);
      });
    })();

    /* Engagement loop \u2014 stage \u2192 PCB feeder into AI chip; chip lights on hover + finish */"""
s = s.replace(hero_iife_end, card_js)

assert s != orig
p.write_text(s, encoding="utf-8")
print("V2B hero transform OK")

# Residue sensor: no dangling four-key seat refs on home
import re
left = []
for pat in [r"arch-node\s+tl", r"arch-node\s+tr", r"arch-node\s+bl", r"arch-node\s+br",
            r"\.arch-node\.tl", r"\.arch-node\.tr", r"\.arch-node\.bl", r"\.arch-node\.br",
            "CORNER_TO_PILLAR"]:
    hits = re.findall(pat, s)
    if hits:
        left.append((pat, len(hits)))
print("residue:", left if left else "none")
print("seat-c:", s.count("seat-c"), "| cvl-card:", s.count("cvl-card"),
      "| hero-pillar-row:", s.count("hero-pillar-row"))
