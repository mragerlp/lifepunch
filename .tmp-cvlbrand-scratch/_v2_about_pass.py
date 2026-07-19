import pathlib

ROOT = pathlib.Path(r"C:\Users\jared\Projects\lifepunch\.tmp-cvlbrand")
EM = "\u2014"
TM = "\u2122"

p = ROOT / "about" / "index.html"
s = p.read_text(encoding="utf-8")

# ---- CSS: paragraphs + craft list inside the panel (before Legal comment) ----
css_anchor = "    /* Legal page */"
assert s.count(css_anchor) == 1
about_css = """    /* V2 about body \u2014 P1\u2013P9 paragraphs + craft list */
    body[data-page="about"] .about-brief .about-p {
      margin: 0 0 1rem;
      max-width: 44rem;
      font-size: clamp(0.95rem, 1.2vw, 1.02rem);
      line-height: 1.7;
      color: var(--cvl-ink-dim);
      text-wrap: pretty;
    }
    body[data-page="about"] .about-brief .about-p strong {
      color: var(--cvl-ink);
      font-weight: 600;
    }
    body[data-page="about"] .about-brief .about-craft {
      margin: 0 0 1.15rem;
      padding: 0.85rem 0.95rem;
      border: 1px solid rgba(146, 250, 17, 0.18);
      background: #030503;
      list-style: none;
      font-family: var(--cvl-mono);
      font-size: clamp(0.82rem, 1.1vw, 0.92rem);
      line-height: 1.55;
      color: var(--cvl-ink);
      columns: 2;
      column-gap: 1.5rem;
    }
    body[data-page="about"] .about-brief .about-craft li {
      margin: 0 0 0.45rem;
      break-inside: avoid;
    }
    body[data-page="about"] .about-brief .about-craft li::before {
      content: "\u203a ";
      color: var(--cvl-lime);
      font-weight: 600;
    }
    @media (max-width: 640px) {
      body[data-page="about"] .about-brief .about-craft { columns: 1; }
    }
    /* Legal page */"""
s = s.replace(css_anchor, about_css)

# ---- Body: replace lede + PASS line with P1-P9 ----
old_body_start = s.index('<p class="lede">')
old_body_end = s.index('</div>', s.index('<p class="about-body">'))
old_block = s[old_body_start:old_body_end]

new_block = f'''<p class="lede">
              Most businesses don&rsquo;t have an <span class="hl">AI problem</span> \u2014
              they have an <span class="hl">AI-fluency barrier</span>.
            </p>
            <p class="about-p">
              We build AI systems that mold to how a business already works \u2014
              <strong>governed, wired in, and handed over</strong> so the owner turns the keys.
            </p>
            <p class="about-p">
              The tools exist; the system around them doesn&rsquo;t. That system is what we
              build. <strong>You should run the system; the system shouldn&rsquo;t run you.</strong>
            </p>
            <p class="about-p">
              We use the <strong>CVL method</strong> \u2014 the Collaborative Value Loop, the
              methodology we designed and now install for clients. It builds AI capability
              around real operations: model and platform selection, retrieval built from your
              own documents and data, agent roles with permission boundaries, human approval
              gates on anything that ships or spends, and monitoring \u2014 then documentation,
              training, and handoff, so your team owns it. We also extend every agent in the
              workflow with a custom-built MCP server, molded to your operation \u2014 so each
              agent boots with the exact tools your vision requires, grounded at every step.
            </p>
            <p class="about-p">
              No losing track, and no falling into the black hole: endless tokens and endless
              hours burned digging for context before the real building even starts.
            </p>
            <p class="about-p">
              I run this method live on <strong>LIFEPUNCH{TM}</strong>, my own development &amp;
              community operation, where AI agents handle research, planning, coding,
              documentation, task handoffs, testing discipline, project organization, and the
              cybersecurity that locks the whole operation.
            </p>
            <p class="about-p">
              The goal was never to &ldquo;use AI&rdquo; \u2014 it was a repeatable system that
              operates clearly, ships faster, and wastes fewer resources. That system is what
              we now install for clients.
            </p>
            <ul class="about-craft">
              <li>Branding &amp; brand assets</li>
              <li>Simple lead tracking &amp; CRM</li>
              <li>Websites and digital presence</li>
              <li>Databases for proprietary work</li>
              <li>AI Agent &ldquo;grounding&rdquo; to a database or repo</li>
              <li>Custom tools, dashboards, and internal systems</li>
              <li>Documentation, onboarding, and operational playbooks</li>
              <li>UI/UX planning for customer-facing and team-facing products</li>
              <li>Release gates and quality-control workflows</li>
            </ul>
            <p class="about-p">
              <strong>Every business benefits from better systems.</strong> Bring scattered
              ideas; leave with something organized, usable, and yours to run.
            </p>
          '''
s = s.replace(old_block, new_block)

# ---- aria-label: company reference reads Cavelux ----
s = s.replace('aria-label="About Collaborative Value Loop"', 'aria-label="About Cavelux"')

# ---- Meta descriptions echo P1 ----
old_desc = "One integrator. Your architecture."
new_desc = f"Most businesses don't have an AI problem {EM} they have an AI-fluency barrier. Cavelux installs the system around the tools."
for attr in ['name="description"', 'property="og:description"', 'name="twitter:description"']:
    tgt = f'{attr} content="{old_desc}"'
    assert tgt in s, attr
    s = s.replace(tgt, f'{attr} content="{new_desc}"')

p.write_text(s, encoding="utf-8")
print("about rewrite OK")

# Sensors
checks = ["AI-fluency barrier", "custom-built MCP server", "operational playbooks",
          "LIFEPUNCH\u2122", "black hole", "yours to run"]
s2 = p.read_text(encoding="utf-8")
for c in checks:
    print(f"  {c}: {s2.count(c)}")
