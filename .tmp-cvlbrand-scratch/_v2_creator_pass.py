import pathlib

ROOT = pathlib.Path(r"C:\Users\jared\Projects\lifepunch\.tmp-cvlbrand")
EM = "\u2014"

p = ROOT / "about" / "index.html"
s = p.read_text(encoding="utf-8")
orig = s

def rep(old, new, count=1):
    global s
    assert s.count(old) == count, f"anchor x{s.count(old)}: {old[:70]!r}"
    s = s.replace(old, new)

# ---- CSS: creator block, before the V2 about-body comment ----
rep(
    "    /* V2 about body \u2014 P1\u2013P9 paragraphs + craft list */",
    """    /* Creator block \u2014 avatar on --cvl-surface tile only (baked black RGB) */
    body[data-page="about"] .about-creator {
      display: flex;
      align-items: center;
      gap: 1.15rem;
      margin: 0 0 1.15rem;
      padding: 0.95rem;
      border: 1px solid var(--cvl-border);
      background: var(--cvl-surface);
      border-radius: 0;
    }
    body[data-page="about"] .about-creator-avatar {
      flex: 0 0 auto;
      width: clamp(6.5rem, 12vw, 8.5rem);
      height: auto;
      border: 1px solid var(--cvl-border);
      border-radius: 0;
      background: var(--cvl-bg);
      display: block;
    }
    body[data-page="about"] .about-creator-text { min-width: 0; }
    body[data-page="about"] .about-creator-text .section-label { margin-bottom: 0.4rem; }
    body[data-page="about"] .about-creator-name {
      margin: 0 0 0.2rem;
      font-family: var(--cvl-mono);
      font-size: clamp(1.15rem, 1.9vw, 1.45rem);
      font-weight: 600;
      letter-spacing: 0.06em;
      color: var(--cvl-ink);
    }
    body[data-page="about"] .about-creator-real {
      margin: 0 0 0.6rem;
      font-family: var(--cvl-mono);
      font-size: 0.75rem;
      letter-spacing: 0.06em;
      text-transform: uppercase;
      color: var(--cvl-lime);
    }
    body[data-page="about"] .about-creator-real .muted {
      color: var(--cvl-muted);
      text-transform: none;
      letter-spacing: 0.03em;
    }
    body[data-page="about"] .about-creator-copy {
      margin: 0;
      font-size: clamp(0.92rem, 1.15vw, 1rem);
      line-height: 1.65;
      color: var(--cvl-ink-dim);
      text-wrap: pretty;
    }
    @media (max-width: 640px) {
      body[data-page="about"] .about-creator {
        flex-direction: column;
        align-items: flex-start;
      }
    }
    /* V2 about body \u2014 P1\u2013P9 paragraphs + craft list */"""
)

# ---- HTML: block between P7 close and the craft list ----
anchor = """            <ul class="about-craft">"""
assert s.count(anchor) == 1
creator_html = f"""            <div class="about-creator">
              <img class="about-creator-avatar" src="/media/CAVELUX_creator_avatar_512.png" srcset="/media/CAVELUX_creator_avatar_512.png 1x, /media/CAVELUX_creator_avatar_1024.png 2x" alt="Bloodwave {EM} creator of the Collaborative Value Loop" width="512" height="512" decoding="async" />
              <div class="about-creator-text">
                <p class="section-label">The creator</p>
                <p class="about-creator-name">BLOODWAVE</p>
                <p class="about-creator-real">Jared Zerillo <span class="muted">{EM} Founder &amp; Operator</span></p>
                <p class="about-creator-copy">Every loop this method runs closes on one human key {EM} his. The Collaborative Value Loop was forged running LIFEPUNCH under real pressure, and it&rsquo;s installed for clients the same way it&rsquo;s lived: agents propose, the creator&rsquo;s rules hold, you turn the keys.</p>
              </div>
            </div>
            <ul class="about-craft">"""
s = s.replace(anchor, creator_html)

assert s != orig
p.write_text(s, encoding="utf-8")
print("creator block OK")

# ---- Version bump all pages v3.52 -> v3.53 ----
for page in pathlib.Path(ROOT).rglob("*.html"):
    t = page.read_text(encoding="utf-8")
    if "v3.52" in t:
        page.write_text(t.replace("v3.52", "v3.53"), encoding="utf-8")
        print(page.name, "->v3.53" if "index" not in str(page) else f"{page.parent.name}/index ->v3.53")
